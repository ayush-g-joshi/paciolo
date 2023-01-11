
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/filters/InvoiceFilterScreen.dart';
import 'package:paciolo/innerscreens/InvoiceDetailScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/images.dart';
import 'package:paciolo/util/styles.dart';
import 'package:http/http.dart' as http;

import '../network/DeleteRequest.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> with SingleTickerProviderStateMixin
    implements ResponseListener {

  String TAG = "_InvoiceListScreenState";
  static const int INVOICE_DATA = 1002;
  static const int GET_COMPANY_DATA = 1003;
  static const int DELETE_DATA = 1005;
  List paymentListData = List.from([]);
  bool showLoader = false;
  bool totalBalancePositive = false;
  var currentCompanyId;
  String totalBalance = "";
  String subTotalGreen = "";
  String subTotalRed = "";
  DateTime currentDate = DateTime.now();
  String selectedMonth = "";
  String selectedMonthInt = "0";
  String selectedYear = "";
  int _TabSelectedIndex = 0;
  int walletSelectedId = -1;
  var firstFilterValue = null;
  var result;
  late ScrollController _controller;
  LoginUserModel? userModel;
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

  int page = 1;
  int limit = 30;
  // Used to display loading indicators when _firstLoad function is running
  bool _firstDataLoading = true;
  bool _isMoreData = true;
  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;
  var documentType;
  var lastDocumentLoadedId;
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
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      lastDocumentLoadedId = userModel!.currentCompany?.lastTypeOfDocumentLoadedId;
      debugPrint("$TAG init State current Company Id ======> $currentCompanyId");
      debugPrint("$TAG init State last Document Loaded Id ======> $lastDocumentLoadedId");
      page = 1;
      _isMoreData = true;
      getCompanyData();
    });

    _controller = ScrollController();
    _controller.addListener(() {
      if(_controller.offset >= _controller.position.maxScrollExtent) {
        _loadMore();
      }
    },);

    _tabController.addListener(() {
      debugPrint("$TAG Tab Controller Index ${_tabController.index}");
      debugPrint("$TAG Tab Selected Index $_TabSelectedIndex");

      if(_tabController.index != _TabSelectedIndex) {

        setState(() {
          paymentListData.clear();
          _TabSelectedIndex = _tabController.index;
          selectedMonth = monthList[_TabSelectedIndex];
          selectedMonthInt = getCurrentMonthInt(selectedMonth);
          page = 1;
          _isMoreData = true;
          getInvoiceList(true);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
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
          onTap: (value) {

          },
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
          documentType == null ? "": "$documentType",
          style: gothamMedium.copyWith(
              color: Colors.white, fontSize: Dimensions.FONT_L),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () async {
              debugPrint("$TAG selectedYear value ======> $selectedYear");
              result = await Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return InvoiceFilterScreen(selectedYear, documentType);
                },
              ));
              debugPrint("$TAG filter data ======> ${result.toString()}");
              setState(() {
                _isMoreData = true;
                page = 1;
              });
              loadDocumentType();
            },
            child: Container(
              padding: const EdgeInsets.only(right: 10),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: paymentListData.isEmpty ? Center(
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
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ) :
          SlidableAutoCloseBehavior(
            child: ListView.builder(
              controller: _controller,
              itemCount: paymentListData.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  //padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10, 8.0),
                  decoration: BoxDecoration(
                    color: (index % 2 == 0) ? Colors.white : const Color(AllColors.colorListBack),
                    border: Border(
                      left: BorderSide(
                        width: 4.0,
                        color: paidStatusCheck(index),
                      ),
                    )
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return InvoiceDetailScreen(id: paymentListData[index]["id"],
                              title: paymentListData[index]["customer"], documentType: documentType);
                        },
                      ));
                    },
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 0, 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                subjectText(index),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    Utility.formatDate(paymentListData[index]["date"].toString()),
                                    textAlign: TextAlign.start,
                                    style: gothamRegular.copyWith(
                                      color: const Color(AllColors.colorText),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${paymentListData[index]["document_number"]}/${paymentListData[index]["document_suffix"]}",
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: gothamRegular.copyWith(
                                    color: const Color(AllColors.colorText),
                                    letterSpacing: 0.5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Slidable(
                          groupTag: '0',
                          enabled: true,
                          direction: Axis.horizontal,
                          endActionPane: ActionPane(
                            //extentRatio: 0.25,
                            motion: const ScrollMotion(),
                            children: [
                              CustomSlidableAction(
                                backgroundColor: const Color(AllColors.swipeDelete),
                                autoClose: true,
                                onPressed: (context) {
                                  setState(() {
                                    deleteDocument(paymentListData[index]["id"]);
                                  });
                                },
                                child: SvgPicture.asset(
                                  Images.swipeDeleteIcon,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              // SlidableAction(
                              //   backgroundColor: const Color(AllColors.swipeDelete),
                              //   //label: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_DELETE_BUTTON: IT.CREATE_INVOICE_TAB_3_DELETE_BUTTON,
                              //   foregroundColor: Colors.white,
                              //   icon: Icons.delete,
                              //   onPressed: (context) {
                              //     setState(() {
                              //       deleteDocument(paymentListData[index]["id"]);
                              //     });
                              //   },
                              // ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 8.0, 10.0, 8.0),
                            width: 140,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "${double.parse(paymentListData[index]["total"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    textAlign: TextAlign.end,
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: 15.sp,
                                        fontStyle: FontStyle.normal),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "${remainingToPay(index)} ${Constant.euroSign}",
                                    textAlign: TextAlign.end,
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: 15.sp,
                                        fontStyle: FontStyle.normal),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Text("SDI",
                                        style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorText),
                                          fontSize: Dimensions.FONT_M,
                                        ),
                                      ),
                                    ),
                                    paymentListData[index]["sdi_notification"] != null
                                        ? Container(
                                        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                        child: showSDIIcon(paymentListData[index]["sdi_notification"])
                                    ) : Container(
                                      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                      child: SvgPicture.asset(Images.sdi,
                                        width: 15.w,
                                        height: 12.h,
                                      ),
                                    ),
                                  ],
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
        if(_isLoadMoreRunning)
          Container(
            height: 40.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Color(AllColors.colorBlue),
                ),
                SizedBox(width: 10.w,),
                Text(
                  Constant.LANG == Constant.EN ? ENG.LOADING : IT.LOADING,
                  style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M,
                    color: const Color(AllColors.colorText),

                  ),
                )
              ],
            ),
          ),
      ],
    );
  }

  void getInvoiceList(bool loader) {
    setState(() {
      if(loader) {
        showLoader = true;
      }
      if(page == 1) {
        _firstDataLoading = true;
      }
    });

    if(result != null && result["year"] != null) {
      selectedYear = result["year"];
    }

    if(result != null && result["docType"] != null) {
      documentType = result["docType"];
    }

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getInvoiceData}$documentType/list?page=$page""&per_page=$limit&month=$selectedMonthInt&year=$selectedYear",
        token: userModel!.authorization,
        responseCode: INVOICE_DATA,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getCompanyData() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.companyAll,
        token: userModel!.authorization,
        responseCode: GET_COMPANY_DATA,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void loadDocumentType() async {
    setState(() {
      showLoader = true;
    });
    String url = Constant.SERVER_URL + RequestCmd.getInvoiceDocFilter;
    String basicAuth = 'Bearer ${userModel!.authorization}';
    Map<String, String> headers;
    if (userModel!.currentCompany?.id != null) {
      headers = {
        "content-type": 'application/json',
        'Origin': Constant.ORIGIN_URL,
        'Authorization': basicAuth,
        'Company': userModel!.currentCompany!.id.toString(),
      };
    } else {
      headers = {
        "content-type": 'application/json',
        'Origin': Constant.ORIGIN_URL,
        'Authorization': basicAuth,
      };
    }

    final response = await http.get(Uri.parse(url), headers: headers);
    debugPrint("get response body ==========> ${response.body}");
    if (jsonDecode(response.body)["success"]) {
      var responseObject = jsonDecode(response.body);
      setState(() {
        showLoader = false;

        for (int i = 0; i < responseObject[Constant.data].length; i++) {
          if (lastDocumentLoadedId == responseObject[Constant.data][i]["id"]) {
            debugPrint("$TAG current Company Document Loaded Id ======> ${responseObject[Constant.data][i]["id"]}");
            debugPrint("$TAG last Document Loaded Id ======> $lastDocumentLoadedId");
            documentType = responseObject[Constant.data][i]["name"];
            break;
          } else {
            documentType = responseObject[Constant.data][0]["name"];
          }
        }

        debugPrint("$TAG lastDocumentLoadedId ======> $lastDocumentLoadedId");
        debugPrint("$TAG documentType ======> $documentType");


        debugPrint("$TAG documentType ======> $documentType");
        debugPrint("$TAG docAllData ========> ${documentType.length}");
      });
      getInvoiceList(true);
    } else {
      setState(() {
        showLoader = false;
        if (response.statusCode == 401) {
          Utility.clearPreference();
          Utility.showErrorToast("Session expired");
        }
      });
      if (response.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
      }
    }
  }

  Widget showSDIIcon(String status) {
    SvgPicture? svg;
    switch (status) {
      case "":
        svg = SvgPicture.asset(
          Images.sdi,
          width: 15.w,
          height: 12.h,
        );
        break;
      case "RCRC":
        svg = SvgPicture.asset(
          Images.sdiRCRC,
          width: 15.w,
          height: 12.h,
        );
        break;
      case "NS":
        svg = SvgPicture.asset(
          Images.sdiNS,
          width: 15.w,
          height: 12.h,
        );
        break;
      case "INIM":
        svg = SvgPicture.asset(
          Images.sdiINIM,
          width: 15.w,
          height: 12.h,
        );
        break;
      case "ININ":
        svg = SvgPicture.asset(
          Images.sdiININ,
          width: 15.w,
          height: 12.h,
        );
        break;
      case "MC":
        svg = SvgPicture.asset(
          Images.sdiINIM,
          width: 15.w,
          height: 12.h,
        );
        break;
      default:
        svg = SvgPicture.asset(
          Images.sdi,
          width: 15.w,
          height: 12.h,
        );
        break;
    }
    return svg;
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
    if(responseCode == DELETE_DATA) {
      setState(() {
        showLoader = false;
        page = 1;
        getInvoiceList(true);
      });
    } else if(responseCode == GET_COMPANY_DATA) {
      setState(() {
        showLoader = false;
        userModel?.currentCompany = CurrentCompany.fromJson(response["current_company"]);
        Utility.setStringSharedPreference(Constant.userObject, jsonEncode(userModel));
        currentCompanyId = userModel?.currentCompany?.id;
        lastDocumentLoadedId = userModel?.currentCompany?.lastTypeOfDocumentLoadedId;
      });
      loadDocumentType();
    } else if (responseCode == INVOICE_DATA) {
      setState(() {
        if(_isLoadMoreRunning) {
          _isLoadMoreRunning = false;
          if(response[Constant.data][Constant.documentList].length <= 0) {
            _isMoreData = false;
            Utility.showToast(Constant.LANG == Constant.EN ? ENG.NO_MORE_DATA : IT.NO_MORE_DATA);
          }
          paymentListData.addAll(response[Constant.data][Constant.documentList]);
        } else {
          paymentListData.clear();
          paymentListData.addAll(response[Constant.data][Constant.documentList]);
        }

        if(page == 1) {
          _firstDataLoading = false;
        }
      });
    }
  }

  Color paidStatusCheck(int index) {

    if (double.parse(paymentListData[index]["paid"].toString()) >=
        double.parse(paymentListData[index]["total_to_paid"])) {
      return const Color(AllColors.colorGreen);

    } else if (double.parse(paymentListData[index]["paid"].toString()) == 0) {
      return const Color(AllColors.colorRed);

    } else if (double.parse(paymentListData[index]["paid"].toString()) <
        double.parse(paymentListData[index]["total_to_paid"])) {
      return const Color(AllColors.colorBlue);

    } else {
      return const Color(AllColors.colorGreen);
    }
  }

  String remainingToPay(int index) {
    var actualAmount = double.parse(paymentListData[index]["total_to_paid"]) -
        double.parse(paymentListData[index]["paid"].toString());
    return actualAmount.toStringAsFixed(2);
  }

  // Widget paidStatusCheck(int index) {
  //
  //   if (double.parse(paymentListData[index]["paid"].toString()) >=
  //       double.parse(paymentListData[index]["total_to_paid"])) {
  //     return Container(
  //       margin: EdgeInsets.only(left: 5.0, bottom: 8.0),
  //       padding: EdgeInsets.only(top: 3.0,bottom: 3.0),
  //       width: 110.w,
  //       decoration: const BoxDecoration(
  //         color: Color(AllColors.colorGreen),
  //         shape: BoxShape.rectangle,
  //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //       ),
  //       child: Text(Constant.LANG == Constant.EN ? ENG.PAID : IT.PAID,
  //         textAlign: TextAlign.center,
  //         style: gothamRegular.copyWith(
  //             color: Colors.white,
  //             letterSpacing: 0.5),
  //       ),
  //     );
  //
  //   } else if (double.parse(paymentListData[index]["paid"].toString()) == 0) {
  //     return Container(
  //       margin: EdgeInsets.only(left: 5.0, bottom: 8.0),
  //       padding: EdgeInsets.only(top: 3.0,bottom: 3.0),
  //       width: 110.w,
  //       decoration: const BoxDecoration(
  //         color: Color(AllColors.colorRed),
  //         shape: BoxShape.rectangle,
  //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //       ),
  //       child: Text(Constant.LANG == Constant.EN ? ENG.NOT_PAID : IT.NOT_PAID,
  //         textAlign: TextAlign.center,
  //         style: gothamRegular.copyWith(
  //             color: Colors.white,
  //             letterSpacing: 0.5),
  //       ),
  //     );
  //
  //   } else if (double.parse(paymentListData[index]["paid"].toString()) <
  //       double.parse(paymentListData[index]["total_to_paid"])) {
  //     return Container(
  //       margin: EdgeInsets.only(left: 5.0, bottom: 8.0),
  //       padding: EdgeInsets.only(top: 3.0,bottom: 3.0),
  //       width: 120.w,
  //       decoration: const BoxDecoration(
  //         color: Color(AllColors.colorBlue),
  //         shape: BoxShape.rectangle,
  //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //       ),
  //       child: Text(Constant.LANG == Constant.EN ? ENG.PARTIALY_PAID : IT.PARTIALY_PAID,
  //         textAlign: TextAlign.center,
  //         style: gothamRegular.copyWith(
  //             color: Colors.white,
  //             letterSpacing: 0.5),
  //       ),
  //     );
  //
  //   } else {
  //     return Container(
  //       margin: EdgeInsets.only(left: 5.0, bottom: 8.0),
  //       padding: EdgeInsets.only(top: 3.0,bottom: 3.0),
  //       width: 110.w,
  //       decoration: BoxDecoration(
  //         color: Color(AllColors.colorGreen),
  //         shape: BoxShape.rectangle,
  //         borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //       ),
  //       child: Text(Constant.LANG == Constant.EN ? ENG.PAID : IT.PAID,
  //         textAlign: TextAlign.center,
  //         style: gothamRegular.copyWith(
  //             color: Colors.white,
  //             letterSpacing: 0.5),
  //       ),
  //     );
  //   }
  // }

  Widget subjectText(int index) {
    String subjectName = "";
    if (paymentListData[index]["customer"] != null && paymentListData[index]["customer"] != "") {
      subjectName = paymentListData[index]["customer"];
    }
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        subjectName,
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: gothamRegular.copyWith(
          color: const Color(AllColors.colorText),
          overflow: TextOverflow.ellipsis,
        ),
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
        return currentDate.month.toString();
    }
  }

  void _loadMore() async {
    if (_isMoreData && _isLoadMoreRunning == false) {
      debugPrint("$TAG _loadMore _isMoreData ====> $_isMoreData");
      debugPrint("$TAG _loadMore _firstDataLoading ====> $_firstDataLoading");
      debugPrint("$TAG _loadMore _isLoadMoreRunning ====> $_isLoadMoreRunning");
      setState(() {
        _isLoadMoreRunning = true;
      });
      page += 1;
      getInvoiceList(false);
    }
  }

  void deleteDocument(int id) {
    // https://devapi.paciolo.it/document/unlink/82398

    setState(() {
      showLoader = true;
    });
    DeleteRequest deleteRequest = DeleteRequest();
    deleteRequest.getResponse(
        cmd: "${RequestCmd.deleteInvoice}/$id",
        token: userModel!.authorization,
        responseCode: DELETE_DATA,
        companyId: currentCompanyId
    );
    deleteRequest.setListener(this);
  }
}
/*
* Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: paymentListData[index]["customer"] != null
                                        ? Container(
                                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                                      child: Row(
                                        children: [
                                          subjectText(index),
                                        ],
                                      ),
                                    ) : Container(
                                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.zero,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                                              child: Text(
                                                "${double.parse(paymentListData[index]["total"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                                textAlign: TextAlign.end,
                                                style: gothamRegular.copyWith(
                                                    color: const Color(AllColors.colorText),
                                                    fontSize: 15.sp,
                                                    fontStyle: FontStyle.normal),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.5),
                                    child: Text(
                                      Utility.formatDate(paymentListData[index]["date"].toString()),
                                      textAlign: TextAlign.start,
                                      style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorText),
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 00.0, 7.5),
                                      child: Text(
                                        "${remainingToPay(index)} ${Constant.euroSign}",
                                        textAlign: TextAlign.end,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorText),
                                            fontSize: 15.sp,
                                            fontStyle: FontStyle.normal),
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: Row(
                                        children: [
                                          Text(
                                            "${paymentListData[index]["document_number"]}/${paymentListData[index]["document_suffix"]}",
                                            textAlign: TextAlign.start,
                                            style: gothamRegular.copyWith(
                                                color: const Color(AllColors.colorText),
                                                letterSpacing: 0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 00.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            child: Text("SDI",
                                              style: gothamRegular.copyWith(
                                                color: const Color(AllColors.colorText),
                                                fontSize: Dimensions.FONT_M,
                                              ),
                                            ),
                                          ),
                                          paymentListData[index]["sdi_notification"] != null
                                              ? Container(
                                              padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                              child: showSDIIcon(paymentListData[index]["sdi_notification"])
                                          ) : Container(
                                            padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                                            child: SvgPicture.asset(Images.sdi,
                                              width: 15.w,
                                              height: 12.h,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
* */