
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/filters/PaymentFilterScreen.dart';
import 'package:paciolo/innerscreens/CreateTransferScreen.dart';
import 'package:paciolo/innerscreens/EditPaymentExtraCostScreen.dart';
import 'package:paciolo/innerscreens/EditPositivePaymentScreen.dart';
import 'package:paciolo/innerscreens/EditTransferScreen.dart';
import 'package:paciolo/innerscreens/PositivePaymentExtraCostScreen.dart';
import 'package:paciolo/innerscreens/PositivePaymentScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/images.dart';
import 'package:paciolo/util/styles.dart';

import '../network/DeleteRequest.dart';

class PaymentListScreen extends StatefulWidget {

  PaymentListScreen({Key? key}) : super(key: key);

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> with SingleTickerProviderStateMixin
    implements ResponseListener {

  String TAG = "_PaymentListScreenState";
  var USER_DATA = 1000;
  var DELETE_DATA = 1002;
  var DELETE_EXTRA_DATA = 1003;
  List paymentListData = List.from([]);
  bool showLoader = false;
  bool totalBalancePositive = false;
  var currentCompanyId;
  String totalBalance = "";
  String subTotalGreen = "";
  String subTotalRed = "";
  DateTime currentDate = DateTime.now();
  String selectedMonth = "";
  String selectedMonthInt = "00";
  String selectedYear = "";
  int _TabSelectedIndex = 0;
  int walletSelectedId = -1;
  var firstFilterValue = null;
  LoginUserModel? userModel;
  var filterResult;
  List<String> monthList = [
    "Gen",
    "Feb",
    "Mar",
    "Apr",
    "Mag",
    "Giu",
    "Lug",
    "Ago",
    "Set",
    "Ott",
    "Nov",
    "Dic",
  ];
  late TabController _tabController;

  @override
  void initState() {
    selectedMonth = getCurrentMonthString(currentDate.month);
    selectedMonthInt = currentDate.month.toString().padLeft(2, '0');
    selectedYear = currentDate.year.toString();

    for (int i = 0; i < monthList.length; i++) {
      if (selectedMonth == monthList[i]) {
        _TabSelectedIndex = i;
      }
    }

    _tabController = TabController(length: monthList.length, initialIndex: _TabSelectedIndex, vsync: this);

    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getUserData();
    });

    _tabController.addListener(() {
      debugPrint("$TAG Tab Controller Index ${_tabController.index}");
      debugPrint("$TAG Tab Selected Index $_TabSelectedIndex");

      if(_tabController.index != _TabSelectedIndex) {

        setState(() {
          _TabSelectedIndex = _tabController.index;
          selectedMonth = monthList[_TabSelectedIndex];
          selectedMonthInt = getCurrentMonthInt(selectedMonth);
          getUserData();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(AllColors.colorBlue),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          isScrollable: true,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: monthList[0],
            ),
            Tab(
              text: monthList[1],
            ),
            Tab(
              text: monthList[2],
            ),
            Tab(
              text: monthList[3],
            ),
            Tab(
              text: monthList[4],
            ),
            Tab(
              text: monthList[5],
            ),
            Tab(
              text: monthList[6],
            ),
            Tab(
              text: monthList[7],
            ),
            Tab(
              text: monthList[8],
            ),
            Tab(
              text: monthList[9],
            ),
            Tab(
              text: monthList[10],
            ),
            Tab(
              text: monthList[11],
            ),
          ],
        ),
        title: Text(
          Constant.LANG == Constant.EN ? ENG.PAYMENT : IT.PAYMENT,
          style: gothamMedium.copyWith(
              color: Colors.white,
              fontSize: Dimensions.FONT_L
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              showBottomSheetPopUp(context);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          InkWell(
            onTap: () async {

              debugPrint("$TAG selectedYear value ======> $selectedYear");
              debugPrint("$TAG first Filter Value value ======> $firstFilterValue");

              filterResult = await Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return PaymentFilterScreen(selectedYear, firstFilterValue);
                },
              ));

              debugPrint("$TAG filter data ======> ${filterResult.toString()}");
              getUserData();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: SvgPicture.asset(
                Images.filter_solid,
                height: 20,
                width: 20,
              ),
            ),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: TabBarView(
          controller: _tabController,
          children: [
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
            listDataWidget(),
          ],
        ),
      ),
    );
  }

  Widget listDataWidget() {
    return Column(
      children: [
        Expanded(
          child: paymentListData.isEmpty ?
          Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  Images.noResult,
                  width: 300.w,
                  height: 300.h,
                  fit: BoxFit.fill,
                ),
                Text(
                  Constant.LANG == Constant.EN ? ENG.NO_RESULT_TO_SHOW : IT.NO_RESULT_TO_SHOW,
                  textAlign: TextAlign.center,
                  style: gothamRegular.copyWith(
                    color: const Color(AllColors.colorNoResult),
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ) : SlidableAutoCloseBehavior(
            child: ListView.builder(
              itemCount: paymentListData.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                return Container(
                  color: (index % 2 == 0) ? Colors.white : const Color(AllColors.colorListBack),
                  height: 82,
                  child: InkWell(
                    onTap: () async {
                      var result;
                      debugPrint("$TAG complete payment data =======> ${paymentListData[index]}");
                      if(paymentListData[index]["transfer"] == 0 && paymentListData[index]["row_type"] == "ACCOUNT") {
                        result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return EditPositivePaymentScreen(isPositive: paymentListData[index]["expiry"] == 1 ? true : false, id: paymentListData[index]["trans_id"]);
                        },));
                      } else if(paymentListData[index]["transfer"] == 1 && paymentListData[index]["row_type"] == "ACCOUNT") {
                        result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return EditTransferScreen(id: paymentListData[index]["trans_id"]);
                        },));
                      } else if(paymentListData[index]["transfer"] == 0 && paymentListData[index]["row_type"] == "EXTRA_COST") {
                        result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return EditPaymentExtraCostScreen(isPositive: paymentListData[index]["expiry"] == 1 ? true : false, id: paymentListData[index]["trans_id"],);
                        },));
                      }

                      setState(() {
                        if(result != null) {
                          getUserData();
                        }
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(10.0, 9.0, 10.0, 7.5),
                                child: Text(
                                  Utility.formatDate(paymentListData[index]["payment_date"].toString()),
                                  textAlign: TextAlign.start,
                                  style: gothamRegular.copyWith(
                                    color: const Color(AllColors.colorText),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              paymentListData[index]["document_name"] != null ? Container(
                                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 7.5),
                                child: Row(
                                  children: [
                                    documentName(index),
                                    Expanded(child: documentId(index)),
                                  ],
                                ),
                              ) : Container(
                                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 7.5),
                              ),
                              paymentListData[index]["name"] != null ? Container(
                                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 7.0),
                                child: subjectText(index),
                              ) : Container(padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 7.0),
                              ),
                            ],
                          ),
                        ),
                        //const Spacer(),
                        Slidable(
                          enabled: showSlidable(paymentListData[index]),
                          direction: Axis.horizontal,
                          endActionPane: ActionPane(
                            //extentRatio: 0.25,
                            motion: const ScrollMotion(),
                            children: [
                              if(paymentListData[index]["wallet_type_id"] != 6)
                              CustomSlidableAction(
                                backgroundColor: const Color(AllColors.swipeDelete),
                                autoClose: true,
                                onPressed: (context) {
                                  setState(() {
                                    if(paymentListData[index]["transfer"] == 0 && paymentListData[index]["row_type"] == "ACCOUNT") {
                                      deletePayment(paymentListData[index]["trans_id"]);
                                    } else if(paymentListData[index]["transfer"] == 1 && paymentListData[index]["row_type"] == "ACCOUNT") {

                                    } else if(paymentListData[index]["transfer"] == 0 && paymentListData[index]["row_type"] == "EXTRA_COST") {
                                      deleteExtraCost(paymentListData[index]["trans_id"]);
                                    }
                                  });
                                },
                                child: SvgPicture.asset(
                                  Images.swipeDeleteIcon,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              if(paymentListData[index]["wallet_type_id"] == 6)
                              CustomSlidableAction(
                                backgroundColor: const Color(AllColors.colorGrey),
                                autoClose: true,
                                onPressed: (context) {
                                },
                                child: SvgPicture.asset(
                                  Images.swipeDeleteDeniedIcon,
                                  width: 23,
                                  height: 23,
                                ),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 140,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                  child: Text(
                                    "${double.parse(paymentListData[index]["pay_amount"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    textAlign: TextAlign.end,
                                    style: gothamRegular.copyWith(
                                      color: paymentListData[index]["expiry"] == -1 ? const Color(AllColors.colorRed) : const Color(AllColors.colorGreen),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Column(
          children: [
            Container(
              height: 60.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(AllColors.colorBackBalance),
                border: Border(
                  top: BorderSide(color: Colors.black54, width: 0.7.w),
                  bottom: BorderSide(color: Colors.black54, width: 1.w),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Constant.LANG == Constant.EN ? ENG.SUB_TOTAL : IT.SUB_TOTAL,
                              textAlign: TextAlign.start,
                              style: gothamBold.copyWith(
                                  color: const Color(AllColors.colorTextBalance),
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: Dimensions.PADDING_S,),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Constant.LANG == Constant.EN ? ENG.BALANCE : IT.BALANCE,
                              textAlign: TextAlign.start,
                              style: gothamBold.copyWith(
                                  color: const Color(AllColors.colorTextBalance),
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "$subTotalGreen ${Constant.euroSign}",
                            textAlign: TextAlign.end,
                            style: gothamBold.copyWith(
                                color: const Color(AllColors.colorGreen),
                                fontSize: Dimensions.FONT_M,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_S,),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "",
                            textAlign: TextAlign.end,
                            style: gothamBold.copyWith(
                              color: const Color(AllColors.colorGreen),
                              fontSize: Dimensions.FONT_M,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            child: Text(
                              "$subTotalRed ${Constant.euroSign}",
                              textAlign: TextAlign.right,
                              style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorRed),
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: Dimensions.PADDING_S,),
                          Container(
                            child: Text(
                              "$totalBalance ${Constant.euroSign}",
                              textAlign: TextAlign.right,
                              style: gothamRegular.copyWith(
                                  color: totalBalancePositive == true ? const Color(AllColors.colorGreen) : const Color(AllColors.colorRed),
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void getUserData() {
    setState(() {
      showLoader = true;
    });

    if(filterResult != null && filterResult["year"] != null) {
      selectedYear = filterResult["year"];
      firstFilterValue = filterResult["docType"];
    }

    int? walletId;
    if (walletSelectedId == -1) {
      walletId = null;
    } else {
      walletId = walletSelectedId;
    }

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getPaymentData}?month=$selectedYear-${getCurrentMonthInt(selectedMonth)}"
            "&type_d=$firstFilterValue&wlt=$walletId",
        token: userModel!.authorization,
        responseCode: USER_DATA,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void deletePayment(int id) {
    // https://devapi.paciolo.it/document/delete-payment?id=32179&type=transcation
    setState(() {
      showLoader = true;
    });
    DeleteRequest deleteRequest = DeleteRequest();
    deleteRequest.getResponse(
        cmd: "${RequestCmd.deletePayment}?id=$id&type=transcation",
        token: userModel!.authorization,
        responseCode: DELETE_DATA,
        companyId: currentCompanyId
    );
    deleteRequest.setListener(this);
  }

  void deleteExtraCost(int id) {
    // https://devapi.paciolo.it/payment-category/delete-extracost-payment?id=915&type=transcation
    Utility.checkNetwork().then((value) {
      if(value) {
        setState(() {
          showLoader = true;
        });
        DeleteRequest deleteRequest = DeleteRequest();
        deleteRequest.getResponse(
            cmd: "${RequestCmd.deleteExtraCost}?id=$id&type=transcation",
            token: userModel!.authorization,
            responseCode: DELETE_EXTRA_DATA,
            companyId: currentCompanyId
        );
        deleteRequest.setListener(this);
      } else {
        Utility.showToast(Constant.LANG == Constant.EN ? ENG.CHECK_INTERNET : IT.CHECK_INTERNET);
      }
    }).onError((error, stackTrace) {
      debugPrint("$TAG error =====> $error");
      debugPrint("$TAG stack trace =====> $stackTrace");
    });
  }

  @override
  void onFailed(response, statusCode) {
    setState(() {
      showLoader = false;
      if(statusCode != null && statusCode == 401) {
        Utility.clearPreference();
        Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.SESSION_EXPIRED : IT.SESSION_EXPIRED);
      }
    });
    if(statusCode != null && statusCode == 401) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ), (route) => false,
      );
    }
  }

  @override
  void onSuccess(response, responseCode) {
    setState(() {
      showLoader = false;
    });
    if(responseCode == DELETE_EXTRA_DATA) {
      setState(() {
        debugPrint("$TAG DELETE_DATA =======> $response");
        getUserData();
      });
    } else if(responseCode == DELETE_DATA) {
      setState(() {
        debugPrint("$TAG DELETE_DATA =======> $response");
        getUserData();
      });
    } else if (responseCode == USER_DATA) {
      setState(() {
        paymentListData.clear();
        paymentListData.addAll(response[Constant.data][Constant.list]);

        if(response[Constant.data][Constant.total][Constant.total_paid] != null) {
          double total = double.parse(response[Constant.data][Constant.total][Constant.total_paid].toString()) -
              double.parse(response[Constant.data][Constant.total][Constant.total_give].toString());
          if (total > 0) {
            totalBalancePositive = true;
          } else {
            totalBalancePositive = false;
          }
          totalBalance = total.toStringAsFixed(2);
          subTotalGreen = double.parse(response[Constant.data][Constant.total][Constant.total_paid].toString()).toStringAsFixed(2);
          subTotalRed = double.parse(response[Constant.data][Constant.total][Constant.total_give].toString()).toStringAsFixed(2);
        } else {
          totalBalance = 0.toStringAsFixed(2);
          subTotalGreen = 0.toStringAsFixed(2);
          subTotalRed = 0.toStringAsFixed(2);
        }

      });
    }
  }

  Widget documentName(int index) {
    String documentName = "";
    var buffer = StringBuffer();

    if (paymentListData[index]["document_number"] != null &&
        paymentListData[index]["document_number"] != "") {
      buffer.write(paymentListData[index]["document_name"]);
    } else {
      buffer.write("");
    }
    documentName = buffer.toString();

    return Text(
      documentName,
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
      style: gothamBlack.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_M,
        overflow: TextOverflow.ellipsis,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget documentId(int index) {
    String documentName = "";
    var buffer = StringBuffer();

    if (paymentListData[index]["document_number"] != null &&
        paymentListData[index]["document_number"] != "") {
      buffer.write(" n ");
      buffer.write(paymentListData[index]["document_number"]);
    }

    documentName = buffer.toString();

    return Text(
      documentName,
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
      style: gothamRegular.copyWith(
        color: const Color(AllColors.colorText),
        overflow: TextOverflow.ellipsis,
        fontSize: Dimensions.FONT_S,
      ),
    );
  }

  Widget subjectText(int index) {
    String subjectName = "";
    if (paymentListData[index]["name"] != null &&
        paymentListData[index]["name"] != "") {
      subjectName = paymentListData[index]["name"];
    }
    return Text(
      subjectName,
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
      style: gothamRegular.copyWith(
        overflow: TextOverflow.ellipsis,
        color: const Color(AllColors.colorText),
      ),
    );
  }

  String getCurrentMonthString(int month) {
    switch (month) {
      case 1:
        return monthList[0];
      case 2:
        return monthList[1];
      case 3:
        return monthList[2];
      case 4:
        return monthList[3];
      case 5:
        return monthList[4];
      case 6:
        return monthList[5];
      case 7:
        return monthList[6];
      case 8:
        return monthList[7];
      case 9:
        return monthList[8];
      case 10:
        return monthList[9];
      case 11:
        return monthList[10];
      case 12:
        return monthList[11];
      default:
        return monthList[0];
    }
  }

  String getCurrentMonthInt(String month) {
    switch (month) {
      case "Gen":
        return "01";
      case "Feb":
        return "02";
      case "Mar":
        return "03";
      case "Apr":
        return "04";
      case "Mag":
        return "05";
      case "Giu":
        return "06";
      case "Lug":
        return "07";
      case "Ago":
        return "08";
      case "Set":
        return "09";
      case "Ott":
        return "10";
      case "Nov":
        return "11";
      case "Dic":
        return "12";
      default:
        return "01";
    }
  }

  void showBottomSheetPopUp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (buildContext) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 5.h,
                  width: 50.w,
                  margin: const EdgeInsets.only(top: Dimensions.PADDING_S),
                  decoration: BoxDecoration(
                    color: const Color(AllColors.colorTabs),
                    borderRadius: BorderRadius.circular(5)
                  ),
                ),
              ),
              // close button
              Visibility(
                visible: false,
                child: SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Color(AllColors.colorBlue),
                          )
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                children: [
                  Container(
                    height: 55.h,
                    child: Center(
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_CREATE_NEW_PAYMENT : IT.PAYMENT_CREATE_NEW_PAYMENT,
                        textAlign: TextAlign.start,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(AllColors.colorTabs),
                  ),
                ],
              ),
              // Registry positive payment
              InkWell(
                onTap: () async {
                  Navigator.pop(buildContext);
                  await Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PositivePaymentScreen(isPositive: true);
                  },));

                  getUserData();
                },
                child: Row(
                  children: [
                    Container(
                      width: 45.w,
                      height: 45.h,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(0, 12.0, 0, 8.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(Images.paymentIn),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 0, 0),
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_POSITIVE_PAYMENT : IT.PAYMENT_REGISTRY_POSITIVE_PAYMENT,
                        textAlign: TextAlign.start,
                        style: gothamBold.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_M,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Registry negative payment
              InkWell(
                onTap: () async {
                  Navigator.pop(buildContext);
                  await Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PositivePaymentScreen(isPositive: false);
                  },));
                  getUserData();
                },
                child: Row(
                  children: [
                    Container(
                      width: 45.w,
                      height: 45.h,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(Images.paymentOut),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 0, 0),
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_NEGATIVE_PAYMENT : IT.PAYMENT_REGISTRY_NEGATIVE_PAYMENT,
                        textAlign: TextAlign.start,
                        style: gothamBold.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_M,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Create a transfer
              InkWell(
                onTap: () async {
                  Navigator.pop(buildContext);
                  await Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const CreateTransferScreen();
                  },));

                  getUserData();
                },
                child: Row(
                  children: [
                    Container(
                      width: 45.w,
                      height: 45.h,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(Images.paymentTransfer,),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 0, 0),
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_CREATE_A_TRANSFER : IT.PAYMENT_CREATE_A_TRANSFER,
                        textAlign: TextAlign.start,
                        style: gothamBold.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_M,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Registry positive extra cost
              InkWell(
                onTap: () async {
                  Navigator.pop(buildContext);
                  await Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PositivePaymentExtraCostScreen(isPositive: true);
                  },));
                  getUserData();
                },
                child: Row(
                  children: [
                    Container(
                      width: 45.w,
                      height: 45.h,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(Images.paymentExtraIn),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 0, 0),
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_POSITIVE_EXTRA_COST : IT.PAYMENT_REGISTRY_POSITIVE_EXTRA_COST,
                        textAlign: TextAlign.start,
                        style: gothamBold.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_M,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Registry negative extra cost
              InkWell(
                onTap: () async {
                  Navigator.pop(buildContext);
                  await Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PositivePaymentExtraCostScreen(isPositive: false);
                  },));

                  getUserData();
                },
                child: Row(
                  children: [
                    Container(
                      width: 45.w,
                      height: 45.h,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(Images.paymentExtraOut),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 0.0, 0, 0),
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_NEGATIVE_EXTRA_COST : IT.PAYMENT_REGISTRY_NEGATIVE_EXTRA_COST,
                        textAlign: TextAlign.start,
                        style: gothamBold.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_M,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  bool showSlidable(var paymentData) {
    bool show;
    if(paymentData["transfer"] == 0 && paymentData["row_type"] == "ACCOUNT") {
      show = true;
    } else if(paymentData["transfer"] == 1 && paymentData["row_type"] == "ACCOUNT") {
      show = true;
    } else if(paymentData["transfer"] == 0 && paymentData["row_type"] == "EXTRA_COST") {
      show = true;
    } else {
      show = false;
    }
    return show;
  }

}

/*
* Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                child: Text(
                                  Utility.formatDate(paymentListData[index]["payment_date"].toString()),
                                  textAlign: TextAlign.start,
                                  style: gothamRegular.copyWith(
                                    color: const Color(AllColors.colorText),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                child: Text(
                                  "${double.parse(paymentListData[index]["pay_amount"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                  textAlign: TextAlign.end,
                                  style: gothamRegular.copyWith(
                                    color: paymentListData[index]["expiry"] == -1 ? const Color(AllColors.colorRed) : const Color(AllColors.colorGreen),
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          paymentListData[index]["document_name"] != null ? Container(
                            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                            child: Row(
                              children: [
                                documentName(index),
                                documentId(index),
                              ],
                            ),
                          ) : Container(
                            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                          ),
                          paymentListData[index]["name"] != null ? Container(
                              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: subjectText(index)
                                  ),
                                ],
                              ),
                            )
                          : Container(
                            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                          )
                        ],
                      ),
* */