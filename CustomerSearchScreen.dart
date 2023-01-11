
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/innerscreens/CustomerProfileScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/images.dart';

import '../network/DeleteRequest.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';

class CustomerSearchScreen extends StatefulWidget {

  var customerType;

  CustomerSearchScreen({Key? key, this.customerType}) : super(key: key);

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> implements ResponseListener {

  String TAG = "_CustomerSearchScreenState";
  bool showLoader = false;
  int page = 1;
  int limit = 20;
  LoginUserModel? userModel;
  var currentCompanyId;
  TextEditingController controller = TextEditingController();
  List customerList = List.from([]);
  var GET_SUBSCRIPTION = 1234;
  var GET_CUSTOMER = 5678;
  var DELETE_CUSTOMER = 2345;
  String searchText = "";

  // Used to display loading indicators when _firstLoad function is running
  bool _firstDataLoading = true;
  bool _isMoreData = true;
  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;
  late ScrollController scrollController;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      checkSubscription();
      getCustomerList(true);
    });

    scrollController = ScrollController();
    scrollController.addListener(() {
      if(scrollController.offset >= scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    },);

    controller.addListener(() {
      debugPrint("$TAG controller listener value ======> ${controller.text.trim().toString()}");
      if (controller.text.trim().toString().isNotEmpty) {
        if(controller.text.trim().toString().length >= 2) {
          setState(() {
            page = 1;
            searchText = controller.text.trim().toString();
            getCustomerList(false);
          });
        }
      } else {
        setState(() {
          if(searchText != "") {
            controller.clear();
            searchText = "";
            page = 1;
            getCustomerList(true);
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(AllColors.colorBlue),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(
              Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          Constant.LANG == Constant.EN ? ENG.CUSTOMERS_LIST_TITLE : IT.CUSTOMERS_LIST_TITLE,
          style: gothamRegular.copyWith(
            fontSize: Dimensions.FONT_L,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: Column(
          children: [
            // search box
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          controller.clear();
                          searchText = "";
                          page = 1;
                          getCustomerList(false);
                        });
                      },
                      icon: const Icon(Icons.cancel),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0.w,
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.7.w,
                        color: const Color(AllColors.colorGrey).withOpacity(0.7),
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
                    ),
                    filled: true,
                    hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMERS_LIST_SEARCH_FIELD_HINT : IT.CUSTOMERS_LIST_SEARCH_FIELD_HINT,
                    hintStyle: gothamMedium.copyWith(
                        color: Colors.grey,
                        fontSize: Dimensions.FONT_XL.sp,
                        fontWeight: FontWeight.w600
                    ),
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    //searchText = value;
                    //onSearchTextChanged(value.toString().toLowerCase());
                  },
                ),
              ),
            ),
            // search box
            // search customers list
            Expanded(
              child: customerList.isEmpty ? Center(
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
              ) : SlidableAutoCloseBehavior(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: customerList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Slidable(
                      enabled: true,
                      direction: Axis.horizontal,
                      endActionPane: ActionPane(
                        extentRatio: 0.20,
                        motion: const ScrollMotion(),
                        children: [
                          CustomSlidableAction(
                            backgroundColor: const Color(AllColors.swipeDelete),
                            autoClose: true,
                            onPressed: (context) {
                              setState(() {
                                deleteCustomer(customerList[index]["id"]);
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
                          //   label: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_DELETE_BUTTON: IT.CREATE_INVOICE_TAB_3_DELETE_BUTTON,
                          //   foregroundColor: Colors.white,
                          //   icon: Icons.delete,
                          //   onPressed: (context) {
                          //     setState(() {
                          //       deleteCustomer(customerList[index]["id"]);
                          //     });
                          //   },
                          // ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(3.0, 7.0, 3.0, 3.0),
                        color: (index % 2 == 0) ? Colors.white : const Color(AllColors.colorListBack),
                        child: InkWell(
                          onTap: () async {
                            var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return CustomerProfileScreen(customerId: customerList[index]["id"],);
                              },
                            ));
                            setState(() {
                              if(result != null && result["isDeleted"]) {
                                page = 1;
                                getCustomerList(true);
                              }
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                      child: Text(
                                        customerList[index]["name"],
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorText),
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: Dimensions.FONT_M,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                    child: Text(
                                      "${customerList[index]["remainingToTaken"] == null ? 0.toStringAsFixed(2) : customerList[index]["remainingToTaken"].toStringAsFixed(2)} ${Constant.euroSign}",
                                      textAlign: TextAlign.end,
                                      style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorGreen),
                                        fontSize: Dimensions.FONT_M,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: showCityAndVat(index),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                                      child: Text(
                                        "${customerList[index]["remainingToPay"] == null ? 0.toStringAsFixed(2) : customerList[index]["remainingToPay"].toStringAsFixed(2)} ${Constant.euroSign}",
                                        textAlign: TextAlign.end,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorRed),
                                            fontSize: Dimensions.FONT_M,
                                            fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // search customers list
            if(_isLoadMoreRunning)
              SizedBox(
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
        ),
      ),
    );
  }

  void checkSubscription() {
    // https://devapi.paciolo.it/plan-subscription/check_access/customers
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.checkCustomerSubscription,
        token: userModel!.authorization,
        responseCode: GET_SUBSCRIPTION,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getCustomerList(bool show) {
    // https://devapi.paciolo.it/customer/?page=1&per_page=20&customer_type=3&term=&tags=&gtags=&comTags=
    setState(() {
      if(show) {
        showLoader = true;
      }
    });

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getCustomerList}?page=$page&per_page=$limit&customer_type=${widget.customerType}&term=$searchText&tags=&gtags=&comTags=",
        token: userModel!.authorization,
        responseCode: GET_CUSTOMER,
        companyId: currentCompanyId);
    request.setListener(this);
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
      getCustomerList(false);
    }
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
    if (responseCode == DELETE_CUSTOMER) {
      setState(() {
        debugPrint("$TAG DELETE_CUSTOMER =======> ${response.toString()}");
        page = 1;
        getCustomerList(true);
      });
    } else if(responseCode == GET_SUBSCRIPTION) {
      debugPrint("$TAG response customer subscription =======> ${response.toString()}");
    } else if(responseCode == GET_CUSTOMER) {
      debugPrint("$TAG response customer list =======> ${response.toString()}");

      setState(() {
        showLoader = false;
        if(_isLoadMoreRunning) {
          _isLoadMoreRunning = false;
          if(response[Constant.data]["record"][Constant.data].length <= 0) {
            _isMoreData = false;
            Utility.showToast(Constant.LANG == Constant.EN ? ENG.NO_MORE_DATA : IT.NO_MORE_DATA);
          }
          var data = response[Constant.data]["record"][Constant.data];
          for(int i =0; i < data.length; i++) {
            customerList.add(data[i]);
          }
        } else {
          customerList.clear();
          var data = response[Constant.data]["record"][Constant.data];
          for(int i =0; i < data.length; i++) {
            customerList.add(data[i]);
          }
        }

        if(page == 1) {
          _firstDataLoading = false;
        }
      });
      debugPrint("$TAG customerList =======> ${customerList.length}");
    }
  }

  Widget showCityAndVat(int index) {
    if (customerList[index]["city"] == null) {
      return Row(
        children: [
          Container(padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),),
          Expanded(child: showVatValue(index)),
        ],
      );
    } else if (customerList[index]["city"] == "") {
      return Row(
        children: [
          Container(padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),),
          Expanded(child: showVatValue(index)),
        ],
      );
    } else {
      if(customerList[index]["city"].toString().length > 12) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(AllColors.colorText),
                size: 15,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 8.0),
              child: Text(
                customerList[index]["city"].toString().substring(0, 12),
                overflow: TextOverflow.ellipsis,
                style: gothamMedium.copyWith(
                  fontSize: Dimensions.FONT_S,
                  color: const Color(AllColors.colorText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(child: showVatValue(index)),
          ],
        );
      } else {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 8.0),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(AllColors.colorText),
                size: 15,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 8.0),
              child: Text(
                customerList[index]["city"],
                overflow: TextOverflow.ellipsis,
                style: gothamMedium.copyWith(
                  fontSize: Dimensions.FONT_S,
                  color: const Color(AllColors.colorText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(child: showVatValue(index)),
          ],
        );
      }
    }
  }

  Widget showVatValue(int index) {
    if(customerList[index]["vat_number"] == null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 8.0),
        child: Text(
          "",
          overflow: TextOverflow.ellipsis,
          style: gothamMedium.copyWith(
            color: const Color(AllColors.colorText),
            overflow: TextOverflow.ellipsis,
            fontSize: Dimensions.FONT_S,
          ),
        )
      );
    } else if(customerList[index]["vat_number"] == "") {
      return Container(
          padding: const EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 8.0),
          child: Text(
            "",
            overflow: TextOverflow.ellipsis,
            style: gothamMedium.copyWith(
              color: const Color(AllColors.colorText),
              overflow: TextOverflow.ellipsis,
              fontSize: Dimensions.FONT_S,
            ),
          )
      );
    } else {
      return Container(
          padding: const EdgeInsets.fromLTRB(5.0, 0.0, 10.0, 8.0),
          child: Text(
            "VAT: ${customerList[index]["vat_number"].toString()}",
            overflow: TextOverflow.ellipsis,
            style: gothamMedium.copyWith(
              color: const Color(AllColors.colorText),
              overflow: TextOverflow.ellipsis,
              fontSize: Dimensions.FONT_S,
            ),
          )
      );
    }
  }

  void deleteCustomer(int id) {
    setState(() {
      showLoader = true;
    });
    DeleteRequest request = DeleteRequest();
    request.getResponse(
        cmd:
        "${RequestCmd.deleteCustomer}$id",
        token: userModel!.authorization,
        responseCode: DELETE_CUSTOMER,
        companyId: currentCompanyId);
    request.setListener(this);
  }

}
