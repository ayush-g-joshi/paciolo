
import 'dart:convert';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/filters/CustomerProfileFilterScreen.dart';
import 'package:paciolo/innerscreens/EditCustomerProfileScreen.dart';
import 'package:paciolo/model/ChartModel.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/DeleteRequest.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/BarChartDataWidget.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/images.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;

import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';
import 'InvoiceDetailScreen.dart';

class CustomerProfileScreen extends StatefulWidget {
  var customerId;

  CustomerProfileScreen({Key? key, this.customerId}) : super(key: key);

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> with SingleTickerProviderStateMixin
    implements ResponseListener {
  String TAG = "_CustomerProfileScreenState";
  bool showLoader = false;
  late TabController _tabController;
  int tabSelectedIndex = 0;
  LoginUserModel? userModel;
  var currentCompanyId;
  bool editProfile = true;
  bool deleteProfile = true;
  bool filterProfile = false;

  // first tabs data
  var customerProfileData;
  var GET_CUSTOMER = 1000;
  var DELETE_CUSTOMER = 9999;
  var GET_INVOICE_AMOUNT = 9222;
  String? imageString;
  List addressArray = List.from([]);
  var selectedYear;
  List<ChartModel> graphData = List.from([]);
  List<charts.Series<ChartModel, String>> series = List.from([]);

  List<BarChartGroupData> barChartGroupList = List.from([]);
  double maxAmount = 0.0;

  // second tabs data
  var GET_TOTAL_INVOICE = 1001;
  var GET_TOTAL_DOCUMENT_INVOICE = 1002;
  var GET_UN_PAID_INVOICE = 1003;

  int limit = 10;
  int offset = 0;

  // show this on left
  double totalGiven = 0.00;
  double totalPaid = 0.00;
  double totalRemaining = 0.00;

  // show this on right
  double totalPaymentGiven = 0.00;
  double totalPaymentPaid = 0.00;
  double totalPaymentRemaining = 0.00;

  List documentsList = List.from([]);

  // third tabs data
  var GET_ALL_INVOICES = 1004;

  List allDocumentsList = List.from([]);
  var documentTotalAmount = 0.0;
  var paymentTotalAmount = 0.0;
  var allInvoicesTotal = 0.0;

  var paymentFilter = 1, paymentTypeFilter = null;

  @override
  void initState() {
    _tabController = TabController(length: 3, initialIndex: tabSelectedIndex, vsync: this);
    selectedYear = DateTime.now().year;
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getCustomerProfile();
    });

    _tabController.addListener(() {
      debugPrint("$TAG Tab Controller Index ${_tabController.index}");
      debugPrint("$TAG Tab Selected Index $tabSelectedIndex");

      if (_tabController.index != tabSelectedIndex) {
        setState(() {
          tabSelectedIndex = _tabController.index;
          if (tabSelectedIndex == 0) {
            editProfile = true;
            deleteProfile = true;
            filterProfile = false;
            getCustomerProfile();
          } else if (tabSelectedIndex == 1) {
            editProfile = false;
            deleteProfile = false;
            filterProfile = false;
            getUserPaymentList();
            getUserDocumentPaymentList();
            getUnPaidInvoice();
          } else {
            editProfile = false;
            deleteProfile = false;
            filterProfile = true;
            getAllInvoices();
          }
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TITLE : IT.CUSTOMER_PROFILE_TITLE,
          style: gothamRegular.copyWith(
            fontSize: Dimensions.FONT_L,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Visibility(
            visible: editProfile,
            child: InkWell(
              onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return EditCustomerProfileScreen(customerId: widget.customerId,);
                  },));
              },
              child: Container(
                padding: const EdgeInsets.only(
                    right: Dimensions.PADDING_S, left: Dimensions.PADDING_S),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Visibility(
            visible: deleteProfile,
            child: InkWell(
              onTap: () {
                showAlertDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.only(
                    right: Dimensions.PADDING_S, left: Dimensions.PADDING_S),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Visibility(
            visible: filterProfile,
            child: InkWell(
              onTap: () async {
                var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return CustomerProfileFilterScreen(paymentFilter: paymentFilter, paymentTypeFilter: paymentTypeFilter);
                },));
                setState(() {
                  if(result != null) {
                    debugPrint("$TAG situation filter data =====> $result");
                    paymentFilter = result["paymentFilter"];
                    paymentTypeFilter = result["paymentTypeFilter"];
                    getAllInvoices();
                  }
                });
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
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          isScrollable: false,
          unselectedLabelColor: const Color(AllColors.colorTabs),
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Text(
                Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_1 : IT.CUSTOMER_PROFILE_TAB_1,
                style: gothamRegular.copyWith(
                    color: tabSelectedIndex == 0 ? Colors.white : const Color(AllColors.colorTabs),
                    fontSize: Dimensions.FONT_L.sp),
              ),
            ),
            Tab(
              child: Text(
                Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_2 : IT.CUSTOMER_PROFILE_TAB_2,
                style: gothamRegular.copyWith(
                    color: tabSelectedIndex == 1 ? Colors.white : const Color(AllColors.colorTabs),
                    fontSize: Dimensions.FONT_L.sp),
              ),
            ),
            Tab(
              child: Text(
                Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_3 : IT.CUSTOMER_PROFILE_TAB_3,
                style: gothamRegular.copyWith(
                    color: tabSelectedIndex == 2 ? Colors.white : const Color(AllColors.colorTabs),
                    fontSize: Dimensions.FONT_L.sp),
              ),
            ),
          ],
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: TabBarView(
          controller: _tabController,
          children: [
            customerProfile(context),
            customerSituation(context),
            customerInvoice(context),
          ],
        ),
      ),
    );
  }

  Widget customerProfile(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: customerProfileData == null ? Center(
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
                  Constant.LANG == Constant.EN
                      ? ENG.NO_RESULT_TO_SHOW
                      : IT.NO_RESULT_TO_SHOW,
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
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // profile card view
                Card(
                  margin: const EdgeInsets.only(top: Dimensions.PADDING_M, left: Dimensions.PADDING_M, right: Dimensions.PADDING_M,),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(Dimensions.PADDING_L),
                  ),
                  elevation: Dimensions.PADDING_XS,
                  borderOnForeground: true,
                  semanticContainer: true,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Dimensions.PADDING_L),
                            topRight: Radius.circular(Dimensions.PADDING_L),
                          )
                        ),
                        child: Stack(
                          children: [
                            Container(
                              //padding: const EdgeInsets.only(top: Dimensions.PADDING_S, bottom: Dimensions.PADDING_S),
                              height: 65.h,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xfff1f1f1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(Dimensions.PADDING_L),
                                  topRight: Radius.circular(Dimensions.PADDING_L),
                                )
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.only(top: Dimensions.PADDING_S, bottom: Dimensions.PADDING_S),
                                height: 130.h,
                                width: 130.h,
                                alignment: Alignment.center,
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  color: Colors.orangeAccent,
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      width: 1.w,
                                      color: const Color(0xFF95989A),
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: 110.h,
                                      width: 110.h,
                                      margin: const EdgeInsets.all(1.0),
                                      child: imageString != null ? Image.memory(base64Decode(imageString!)) : Container(),
                                    ),
                                  ),
                                )
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.only(
                            left: Dimensions.PADDING_XS,
                            right: Dimensions.PADDING_XS),
                        child: Text(
                          "${customerProfileData["name"]}",
                          textAlign: TextAlign.center,
                          style: gothamBold.copyWith(
                            color: const Color(AllColors.colorText),
                            fontSize: Dimensions.FONT_XL
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_M),
                      Container(
                        margin: const EdgeInsets.only(
                            left: Dimensions.PADDING_XS,
                            right: Dimensions.PADDING_XS),
                        child: Text(
                          "${customerProfileData["customer_hashtag"]}",
                          textAlign: TextAlign.center,
                          style: gothamRegular.copyWith(
                              overflow: TextOverflow.ellipsis,
                              color: const Color(0xFF888787),
                              fontSize: Dimensions.FONT_M),
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_M),
                      // buttons for call and email
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              if (customerProfileData["phone1"] != null &&
                                  customerProfileData["phone1"] != "") {
                                callService(customerProfileData["phone1"]);
                              } else if (customerProfileData["phone2"] != null &&
                                  customerProfileData["phone2"] != "") {
                                callService(customerProfileData["phone2"]);
                              } else {
                                Utility.showToast(
                                  Constant.LANG == Constant.EN
                                      ? ENG.CUSTOMER_PROFILE_TAB_1_PHONE_ERROR
                                      : IT.CUSTOMER_PROFILE_TAB_1_PHONE_ERROR,);
                              }
                            },
                            child: Container(
                              height: 36,
                              width: 120.w,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 2.0,
                                    ),
                                  ],
                                  color: const Color(
                                      AllColors.colorBlue),
                                  borderRadius:
                                  BorderRadius.circular(
                                      Dimensions.PADDING_S)),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    Constant.LANG == Constant.EN
                                        ? ENG.CUSTOMER_PROFILE_TAB_1_TITLE_1
                                        : IT.CUSTOMER_PROFILE_TAB_1_TITLE_1,
                                    style: gothamRegular.copyWith(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (customerProfileData["email"] != null &&
                                  customerProfileData["email"] != "") {
                                emailService(
                                    customerProfileData["email"]);
                              } else {
                                Utility.showToast(
                                  Constant.LANG == Constant.EN
                                      ? ENG.CUSTOMER_PROFILE_TAB_1_EMAIL_ERROR
                                      : IT.CUSTOMER_PROFILE_TAB_1_EMAIL_ERROR,);
                              }
                            },
                            child: Container(
                              height: 36,
                              width: 120.w,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(Dimensions.PADDING_S)),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.email,
                                    size: 16,
                                    color:
                                    Color(AllColors.colorText),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    Constant.LANG == Constant.EN
                                        ? ENG.CUSTOMER_PROFILE_TAB_1_TITLE_2
                                        : IT.CUSTOMER_PROFILE_TAB_1_TITLE_2,
                                    textAlign: TextAlign.center,
                                    style: gothamRegular.copyWith(
                                      color: const Color(
                                          AllColors.colorText),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              height: 36,
                              width: 120.w,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(Dimensions.PADDING_S),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.share,
                                    size: 16,
                                    color:
                                    Color(AllColors.colorText),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    Constant.LANG == Constant.EN
                                        ? ENG.CUSTOMER_PROFILE_TAB_1_TITLE_3
                                        : IT.CUSTOMER_PROFILE_TAB_1_TITLE_3,
                                    style: gothamRegular.copyWith(
                                      color: const Color(
                                          AllColors.colorText),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.PADDING_M),
                    ],
                  ),
                ),
                // graph view
                //loadGraph(),
                if(barChartGroupList != null && barChartGroupList.isNotEmpty)
                newGraphChart(),
                // address card view
                Card(
                  margin: const EdgeInsets.only(top: Dimensions.PADDING_M, left: Dimensions.PADDING_M, right: Dimensions.PADDING_M,),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.PADDING_L),
                  ),
                  elevation: Dimensions.PADDING_XS,
                  borderOnForeground: true,
                  semanticContainer: true,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.all(
                        Radius.circular(Dimensions.PADDING_L),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 50),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(Dimensions.PADDING_L),
                              bottomRight: Radius.circular(Dimensions.PADDING_L),
                            )
                          ),
                          child: ListView.separated(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.only(
                                left: Dimensions.PADDING_M,
                                top: 0,
                                right: Dimensions.PADDING_M,
                                bottom: 0),
                            itemCount: addressArray.length,
                            shrinkWrap: true,
                            separatorBuilder: (BuildContext context, int index) {
                              return Divider(
                                height: 1.5.h,
                                color: Colors.black12,
                              );
                            },
                            itemBuilder: (BuildContext context, int index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: Dimensions.PADDING_M.h,
                                ),
                                Text(
                                  customerAddress(index),
                                  textAlign: TextAlign.start,
                                  style: gothamMedium.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_M),
                                ),
                                SizedBox(
                                  height: Dimensions.PADDING_M.h,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15,
                          left: 10,
                          right: 0,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_pin,
                                color: Color(AllColors.colorText),
                              ),
                              Text(
                                Constant.LANG == Constant.EN
                                    ? ENG.CUSTOMER_PROFILE_TAB_1_TITLE_4
                                    : IT.CUSTOMER_PROFILE_TAB_1_TITLE_4,
                                style: gothamBold.copyWith(
                                    color: const Color(AllColors.colorText),
                                    fontSize: Dimensions.FONT_L),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // address card view
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget customerSituation(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 30, bottom: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 8.0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_2_TITLE_1 : IT.CUSTOMER_PROFILE_TAB_2_TITLE_1,
                          style: gothamBold.copyWith(
                            color: const Color(AllColors.colorBlue),
                            fontSize: Dimensions.FONT_M
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text("${totalPaid.toStringAsFixed(2)} ${Constant.euroSign}",
                          style: gothamBold.copyWith(
                              fontSize: Dimensions.FONT_L
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 60,
                      child: VerticalDivider(color: Colors.black12)),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_2_TITLE_4 : IT.CUSTOMER_PROFILE_TAB_2_TITLE_4,
                          style: gothamBold.copyWith(
                            color: const Color(AllColors.colorBlue),
                            fontSize: Dimensions.FONT_M
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text("${totalPaymentPaid.toStringAsFixed(2)} ${Constant.euroSign}",
                          style: gothamBold.copyWith(
                            fontSize: Dimensions.FONT_L
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_2_TITLE_2 : IT.CUSTOMER_PROFILE_TAB_2_TITLE_2,
                          style: gothamBold.copyWith(
                              color: const Color(AllColors.colorBlue),
                              fontSize: Dimensions.FONT_M),
                        ),
                        SizedBox(height: 10.h),
                        Text("${totalGiven.toStringAsFixed(2)} ${Constant.euroSign}",
                          style: gothamBold.copyWith(
                              fontSize: Dimensions.FONT_L
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height: 60,
                      child: VerticalDivider(color: Colors.black12)),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_2_TITLE_5 : IT.CUSTOMER_PROFILE_TAB_2_TITLE_5,
                          style: gothamBold.copyWith(
                            color: const Color(AllColors.colorBlue),
                            fontSize: Dimensions.FONT_M
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text("${totalPaymentGiven.toStringAsFixed(2)} ${Constant.euroSign}",
                          style: gothamBold.copyWith(
                            fontSize: Dimensions.FONT_L
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_2_TITLE_3 : IT.CUSTOMER_PROFILE_TAB_2_TITLE_3,
                          style: gothamBold.copyWith(
                            color: const Color(AllColors.colorBlue),
                            fontSize: Dimensions.FONT_M
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text("${totalRemaining.toStringAsFixed(2)} ${Constant.euroSign}",
                          style: gothamBold.copyWith(
                            fontSize: Dimensions.FONT_L
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60, child: VerticalDivider(color: Colors.black12)),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_2_TITLE_6 : IT.CUSTOMER_PROFILE_TAB_2_TITLE_6,
                          style: gothamBold.copyWith(
                            color: const Color(AllColors.colorBlue),
                            fontSize: Dimensions.FONT_M
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text("${totalPaymentRemaining.toStringAsFixed(2)} ${Constant.euroSign}",
                          style: gothamBold.copyWith(
                            fontSize: Dimensions.FONT_L
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_L),
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: Text(
            Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_2_TITLE_7 : IT.CUSTOMER_PROFILE_TAB_2_TITLE_7,
            style: gothamBold.copyWith(fontSize: Dimensions.FONT_L),
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_M,),
        const Divider(height: 1.5, thickness: 1.0, color: Colors.black12,),
        Expanded(
          child: ListView.builder(
            itemCount: documentsList.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10, 8.0),
                decoration: BoxDecoration(
                    color: (index % 2 == 0)
                        ? Colors.white
                        : const Color(AllColors.colorListBack),
                    border: Border(
                      left: BorderSide(
                        width: 4.0,
                        color: paidStatusCheck(3),
                      ),
                    )),
                child: InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: documentsList[index]
                                        ["document_date_number"] !=
                                    null
                                ? Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 0.0, 8.0),
                                    child: Row(
                                      children: [
                                        documentTitle(index),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        0.0, 0.0, 0.0, 8.0),
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
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 0.0, 0.0, 8.0),
                                      child: Text(
                                        "${documentTotal(index)} ${Constant.euroSign}",
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
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.5),
                            child: Text(
                              Utility.formatDate(documentsList[index]["date"]),
                              textAlign: TextAlign.start,
                              style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  letterSpacing: 0.5),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.fromLTRB(
                                  0.0, 0.0, 00.0, 7.5),
                              child: Text(
                                "${paymentTotal(index)} ${Constant.euroSign}",
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
                                    "${documentBalance(index)} ${Constant.euroSign}",
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
                                children: const [],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget customerInvoice(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: allDocumentsList.isEmpty ?
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
                  Constant.LANG == Constant.EN
                      ? ENG.NO_RESULT_TO_SHOW
                      : IT.NO_RESULT_TO_SHOW,
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
          ListView.builder(
            itemCount: allDocumentsList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10, 8.0),
                decoration: BoxDecoration(
                  color: (index % 2 == 0) ? Colors.white : const Color(AllColors.colorListBack),
                ),
                child: InkWell(
                  onTap: () {
                    debugPrint("$TAG allDocumentsList =========> ${allDocumentsList[index]}");
                    if(allDocumentsList[index]["id"] != null && allDocumentsList[index]["id"] != "") {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return InvoiceDetailScreen(id: allDocumentsList[index]["id"], title: customerProfileData["first_name"],
                            documentType: allDocumentsList[index]["document_type_name"]);
                      },
                      ));
                    }
                  },
                  child: Column(
                    children: [
                      if(allDocumentsList[index]["dtotal"] != null && allDocumentsList[index]["dtotal"] != "" && double.parse(allDocumentsList[index]["dtotal"]) > 0)
                      Container(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SvgPicture.asset(
                            //   Images.allDocuments,
                            //   height: 15,
                            //   width: 15,
                            //   color: Colors.black,
                            // ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_3_DOCUMENT : IT.CUSTOMER_PROFILE_TAB_3_DOCUMENT,
                                textAlign: TextAlign.end,
                                style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  letterSpacing: 0.5,
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            const SizedBox(width: Dimensions.PADDING_XS,),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                allDocumentTotal(index),
                                //textAlign: TextAlign.end,
                                style: gothamRegular.copyWith(
                                  color: allDocumentsList[index]["expiry_date"] == -1 ? const Color(AllColors.colorRed) : const Color(AllColors.colorGreen),
                                  letterSpacing: 0.5,
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if(allDocumentsList[index]["ptotal"] != null && allDocumentsList[index]["ptotal"] != "" && double.parse(allDocumentsList[index]["ptotal"]) > 0)
                      Container(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_TAB_3_PAYMENT : IT.CUSTOMER_PROFILE_TAB_3_PAYMENT,
                                textAlign: TextAlign.end,
                                style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            const SizedBox(width: Dimensions.PADDING_XS,),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                allPaymentTotal(index),
                                textAlign: TextAlign.end,
                                style: gothamRegular.copyWith(
                                  color: allDocumentsList[index]["expiry_date"] == -1 ? const Color(AllColors.colorRed) : const Color(AllColors.colorGreen),
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: allDocumentsList[index]["document_date_number"] != null ? Container(
                              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                              child: Row(
                                children: [
                                  allDocumentTitle(index),
                                ],
                              ),
                            ) : Container(
                              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              Utility.formatDate(allDocumentsList[index]["date"]),
                              textAlign: TextAlign.start,
                              style: gothamRegular.copyWith(
                                color: const Color(AllColors.colorText),
                                letterSpacing: 0.5,
                                fontSize: Dimensions.FONT_M,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              "${allDocumentBalance(index)} ${Constant.euroSign}",
                              textAlign: TextAlign.end,
                              style: gothamRegular.copyWith(
                                color: double.parse(allDocumentBalance(index)) < 0 ? const Color(AllColors.colorRed) : const Color(AllColors.colorGreen),
                                fontSize: Dimensions.FONT_M,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Column(
          children: [
            Container(
              height: 80.h,
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
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${documentTotalAmount.toStringAsFixed(2)} ${Constant.euroSign}",
                              textAlign: TextAlign.end,
                              style: gothamBold.copyWith(
                                  color: checkPaymentNegative(documentTotalAmount) == false
                                      ? const Color(AllColors.colorGreen)
                                      : const Color(AllColors.colorRed),
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
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            child: Text(
                              "${paymentTotalAmount.toStringAsFixed(2)} ${Constant.euroSign}",
                              textAlign: TextAlign.right,
                              style: gothamRegular.copyWith(
                                  color: checkPaymentNegative(paymentTotalAmount) == false
                                      ? const Color(AllColors.colorGreen)
                                      : const Color(AllColors.colorRed),
                                  fontSize: Dimensions.FONT_M,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: Dimensions.PADDING_S,),
                          Container(
                            child: Text(
                              "${allInvoicesTotal.toStringAsFixed(2)} ${Constant.euroSign}",
                              textAlign: TextAlign.right,
                              style: gothamRegular.copyWith(
                                  color: checkPaymentNegative(allInvoicesTotal) == false
                                      ? const Color(AllColors.colorGreen)
                                      : const Color(AllColors.colorRed),
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

  Widget documentTitle(int index) {
    return Expanded(
      flex: 1,
      child: Text(
        documentsList[index]["document_date_number"],
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        style: gothamRegular.copyWith(
          color: const Color(AllColors.colorText),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String documentTotal(int index) {
    String total = "";
    if (documentsList[index]["dtotal"] == null) {
      total = "0.00";
    } else if (documentsList[index]["dtotal"] == "") {
      total = "0.00";
    } else {
      total = double.parse(documentsList[index]["dtotal"].toString())
          .toStringAsFixed(2);
    }
    return total;
  }

  String paymentTotal(int index) {
    String total = "";
    if (documentsList[index]["ptotal"] == null) {
      total = "0.00";
    } else if (documentsList[index]["ptotal"] == "") {
      total = "0.00";
    } else {
      total = double.parse(documentsList[index]["ptotal"].toString())
          .toStringAsFixed(2);
    }
    return total;
  }

  String documentBalance(int index) {
    String total = "";
    if (documentsList[index]["balance"] == null) {
      total = "0.00";
    } else if (documentsList[index]["balance"] == "") {
      total = "0.00";
    } else {
      total = double.parse(documentsList[index]["balance"].toString())
          .toStringAsFixed(2);
    }
    return total;
  }

  Color paidStatusCheck(int index) {
    if (index == 1) {
      return const Color(AllColors.colorGreen);
    } else if (index == 2) {
      return const Color(AllColors.colorBlue);
    } else {
      return const Color(AllColors.colorRed);
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

  void getCustomerProfile() {
    // https://devapi.paciolo.it/customer/39804
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getCustomerById}${widget.customerId}",
        token: userModel!.authorization,
        responseCode: GET_CUSTOMER,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getUserPaymentList() {
    // https://devapi.paciolo.it/warehouse_timeline/invoice_amounts
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      "year": DateTime.now().year,
      "customerId": widget.customerId
    }); // getTotalInvoiceAmount

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.getTotalInvoiceAmount,
        token: userModel!.authorization,
        body: body,
        responseCode: GET_TOTAL_INVOICE,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getUserDocumentPaymentList() {
    // https://devapi.paciolo.it/warehouse_timeline/total_rem_document
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode(
        {"year": DateTime.now().year, "customerId": widget.customerId});

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.getTotalDocumentInvoiceAmount,
        token: userModel!.authorization,
        body: body,
        responseCode: GET_TOTAL_DOCUMENT_INVOICE,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getUnPaidInvoice() {
    // https://devapi.paciolo.it/timeline/customer-document-data?id=2326&limit=10&offset=0&type=undefined&active_filter=1&positive_filter=1

    GetRequest request = GetRequest();
    request.getResponse(
        cmd:
            "${RequestCmd.getUnPaidInvoiceList}?id=${widget.customerId}&limit=$limit&offset=$offset&type=&active_filter=1&positive_filter=1",
        token: userModel!.authorization,
        responseCode: GET_UN_PAID_INVOICE,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getAllInvoices() {
    // https://devapi.paciolo.it/timeline/customer-document-data?id=39804&limit=10&offset=0&type=undefined&active_filter=4&positive_filter=null
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getUnPaidInvoiceList}?id=${widget.customerId}&limit=$limit&offset=$offset&type=&active_filter=$paymentFilter&positive_filter=$paymentTypeFilter",
        token: userModel!.authorization,
        responseCode: GET_ALL_INVOICES,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getInvoiceAmount() {
    // https://devapi.paciolo.it/warehouse_timeline/invoice_amounts
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      "year": selectedYear,
      "customerId": widget.customerId
    });
    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.getAllInvoiceAmountMonthWise,
        token: userModel!.authorization,
        body: body,
        responseCode: GET_INVOICE_AMOUNT,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  @override
  void onFailed(response, statusCode) {
    setState(() {
      showLoader = false;
      if (statusCode != null && statusCode == 401) {
        Utility.clearPreference();
        Utility.showErrorToast(Constant.LANG == Constant.EN
            ? ENG.SESSION_EXPIRED
            : IT.SESSION_EXPIRED);
      }
    });
    if (statusCode != null && statusCode == 401) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  void onSuccess(response, responseCode) {
    if (responseCode == GET_INVOICE_AMOUNT) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG GET INVOICE AMOUNT ============> ${response.toString()}");
        graphData.clear();

        List graphDataList = List.from([]);
        graphDataList.addAll(response[Constant.data]);

        graphDataList.sort((a, b) {
          return a["month"].compareTo(b["month"]);
        },);
        debugPrint("$TAG graphDataList =======> $graphDataList");

        for (int i = 0; i < graphDataList.length; i++) {
          graphData.add(ChartModel(
            month: IT.monthList[int.parse(graphDataList[i]["month"].toString()) - 1],
            totalGiven: double.parse(graphDataList[i]["total_given"].toString()).toStringAsFixed(2),
            totalPaid: double.parse(graphDataList[i]["total_paid"].toString()).toStringAsFixed(2),
            barColor: charts.ColorUtil.fromDartColor(const Color(0xff1e8ab7)),));
        }

        var maxValuePaid = double.parse(graphData[0].totalPaid);
        var maxValueGiven = double.parse(graphData[0].totalGiven);
        for (var i = 0; i < graphData.length; i++) {

          if (double.parse(graphData[i].totalGiven) > maxValueGiven) {
            maxValueGiven = double.parse(graphData[i].totalGiven);
          }
          if (double.parse(graphData[i].totalPaid) > maxValuePaid) {
            maxValuePaid = double.parse(graphData[i].totalPaid);
          }
        }

        maxAmount = maxValuePaid + maxValueGiven;

        getGroupData();

        series = [
          charts.Series(
              id: Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_GRAPH_POSITIVE : IT.CUSTOMER_PROFILE_GRAPH_POSITIVE,
              data: graphData,
              domainFn: (ChartModel series, _) => series.month,
              measureFn: (ChartModel series, _) => double.parse(series.totalPaid),
              colorFn: (ChartModel series, _) => series.barColor
          ),
          charts.Series(
              id: Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_GRAPH_NEGATIVE : IT.CUSTOMER_PROFILE_GRAPH_NEGATIVE,
              data: graphData,
              domainFn: (ChartModel series, _) => series.month,
              measureFn: (ChartModel series, _) => double.parse(series.totalGiven),
              colorFn: (ChartModel series, _) => charts.ColorUtil.fromDartColor(const Color(0xffe77e23))
          )
        ];
      });
    } else if (responseCode == DELETE_CUSTOMER) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG DELETE CUSTOMER ============> ${response.toString()}");
        Utility.showToast(Constant.LANG == Constant.EN ? ENG.DELETE_CUSTOMER_SUCCESS_MESSAGE : IT.DELETE_CUSTOMER_SUCCESS_MESSAGE);
        Navigator.pop(context, {"isDeleted": true});
      });
    } else if (responseCode == GET_CUSTOMER) {
      setState(() {
        showLoader = false;
        addressArray.clear();

        customerProfileData = response[Constant.data];
        var array = customerProfileData["addressAry"];

        if(array != null) {
          for (int i = 0; i < array.length; i++) {
            addressArray.add(array[i]);
          }
        }

        if (customerProfileData["user_image"] != null &&
            customerProfileData["user_image"] != "") {
          String imageData = customerProfileData["user_image"];
          if (imageData.contains("data:image/jpg;base64,")) {
            imageString = imageData.replaceAll("data:image/jpg;base64,", "");
          } else if (imageData.contains("data:image/png;base64,")) {
            imageString = imageData.replaceAll("data:image/png;base64,", "");
          }
        } else {
          imageString = null;
        }
        getInvoiceAmount();
      });
    } else if (responseCode == GET_TOTAL_INVOICE) {
      setState(() {
        showLoader = false;
        double totalGiven = 0.0, totalPaid = 0.0;

        for (int i = 0; i < response[Constant.data].length; i++) {
          totalGiven = double.parse(
                  response[Constant.data][i]["total_given"].toString()) +
              totalGiven;
          totalPaid = double.parse(
                  response[Constant.data][i]["total_paid"].toString()) +
              totalPaid;
        }

        debugPrint("$TAG total given =============> $totalGiven");
        debugPrint("$TAG total paid =============> $totalPaid");

        totalGiven = totalGiven;
        totalPaid = totalPaid;
        totalRemaining = totalPaid - totalGiven;
      });
    } else if (responseCode == GET_TOTAL_DOCUMENT_INVOICE) {
      setState(() {
        showLoader = false;
        if (response[Constant.data]["total_to_given"] == null) {
          totalPaymentGiven = 0.0;
        } else {
          totalPaymentGiven = double.parse(
              response[Constant.data]["total_to_given"].toString());
        }

        if (response[Constant.data]["total_to_paid"] == null) {
          totalPaymentPaid = 0.0;
        } else {
          totalPaymentPaid =
              double.parse(response[Constant.data]["total_to_paid"].toString());
        }

        totalPaymentRemaining = totalPaymentPaid - totalPaymentGiven;
      });
    } else if (responseCode == GET_UN_PAID_INVOICE) {
      setState(() {
        documentsList.clear();
        if(response[Constant.data]["documents"] != null) {
          for (int i = 0; i < response[Constant.data]["documents"].length; i++) {
            documentsList.add(response[Constant.data]["documents"][i]);
          }
        }
      });
    } else if (responseCode == GET_ALL_INVOICES) {
      setState(() {
        showLoader = false;
        allDocumentsList.clear();

        if(response[Constant.data]["bothTotal"] != null) {
          debugPrint("$TAG document total ==========> ${response[Constant.data]["bothTotal"][0]["document_total"]}");
          debugPrint("$TAG payment total ==========> ${response[Constant.data]["bothTotal"][0]["payment_total"]}");
            documentTotalAmount = double.parse(response[Constant.data]["bothTotal"][0]["document_total"].toString());
            paymentTotalAmount = double.parse(response[Constant.data]["bothTotal"][0]["payment_total"].toString());
        }

        if(response[Constant.data]["documents"] != null) {
          for (int i = 0; i < response[Constant.data]["documents"].length; i++) {
            allDocumentsList.add(response[Constant.data]["documents"][i]);
          }
        }
        if(allDocumentsList != null && allDocumentsList.isNotEmpty) {
          allInvoicesTotal = double.parse(allDocumentsList.last["balance"].toString());
        }
      });
    }
  }

  String customerAddress(int index) {
    String address = "";
    var buffer = StringBuffer();

    if (addressArray[index]["address1"] != null &&
        addressArray[index]["address1"] != "") {
      buffer.write(addressArray[index]["address1"]);
      buffer.write(", ");
    } else {
      buffer.write("");
    }
    if (addressArray[index]["address2"] != null &&
        addressArray[index]["address2"] != "") {
      buffer.write(addressArray[index]["address2"]);
      buffer.write(", ");
    } else {
      buffer.write("");
    }
    if (addressArray[index]["city"] != null &&
        addressArray[index]["city"] != "") {
      buffer.write(addressArray[index]["city"]);
      buffer.write(", ");
    } else {
      buffer.write("");
    }
    if (addressArray[index]["state"] != null &&
        addressArray[index]["state"] != "") {
      buffer.write(addressArray[index]["state"]);
      buffer.write(", ");
    } else {
      buffer.write("");
    }
    if (addressArray[index]["country"] != null &&
        addressArray[index]["country"] != "") {
      buffer.write(addressArray[index]["country"]);
      buffer.write(", ");
    } else {
      buffer.write("");
    }
    if (addressArray[index]["zip"] != null &&
        addressArray[index]["zip"] != "") {
      buffer.write(addressArray[index]["zip"]);
    } else {
      buffer.write("");
    }
    address = buffer.toString();

    return address;
  }

  callService(String? mobile) async {
    if (Platform.isIOS) {
      Uri uri = Uri(scheme: 'tel', path: mobile!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not Launch ${uri.toString()}';
      }
    } else {
      Uri uri = Uri.parse("tel:$mobile");
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not Launch ${uri.toString()}';
      }
    }
  }

  emailService(String? primaryEmail) async {
    Uri uri = Uri(scheme: 'mailto', path: primaryEmail!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not Launch ${uri.toString()}';
    }
  }

  Widget allDocumentTitle(int index) {
    if(allDocumentsList[index]["document_date_number"] != null && allDocumentsList[index]["document_date_number"] != "") {
      return Expanded(
        flex: 1,
        child: Text(
          allDocumentsList[index]["document_date_number"],
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(AllColors.colorText),
            overflow: TextOverflow.ellipsis,
            fontSize: Dimensions.FONT_M,
          ),
        ),
      );
    } else {
      return const Expanded(
        flex: 1,
        child: Text(
          "",
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Color(AllColors.colorText),
            overflow: TextOverflow.ellipsis,
            fontSize: Dimensions.FONT_M,
          ),
        ),
      );
    }
  }

  String allDocumentTotal(int index) {
    String total = "";
    if (allDocumentsList[index]["dtotal"] == null) {
      total = "0.00 ${Constant.euroSign}";
    } else if (allDocumentsList[index]["dtotal"] == "") {
      total = "0.00 ${Constant.euroSign}";
    } else {
      total = "${double.parse(allDocumentsList[index]["dtotal"].toString()).toStringAsFixed(2)} ${Constant.euroSign}";
    }
    return total;
  }

  String allPaymentTotal(int index) {
    String total = "";
    if (allDocumentsList[index]["ptotal"] == null) {
      total = "0.00 ${Constant.euroSign}";
    } else if (allDocumentsList[index]["ptotal"] == "") {
      total = "0.00 ${Constant.euroSign}";
    } else {
      total = "${double.parse(allDocumentsList[index]["ptotal"].toString()).toStringAsFixed(2)} ${Constant.euroSign}";
    }
    return total;
  }

  String allDocumentBalance(int index) {
    String total = "";
    if (allDocumentsList[index]["balance"] == null) {
      total = "0.00";
    } else if (allDocumentsList[index]["balance"] == "") {
      total = "0.00";
    } else {
      total = double.parse(allDocumentsList[index]["balance"].toString()).toStringAsFixed(2);
    }
    return total;
  }

  void deleteCustomer() {
    // https://devapi.paciolo.it/customer/72271
    setState(() {
      showLoader = true;
    });
    DeleteRequest request = DeleteRequest();
    request.getResponse(
        cmd:
        "${RequestCmd.deleteCustomer}${widget.customerId}",
        token: userModel!.authorization,
        responseCode: DELETE_CUSTOMER,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(Constant.LANG == Constant.EN ? ENG.DELETE_CUSTOMER_PROFILE : IT.DELETE_CUSTOMER_PROFILE),
          actions: [
            TextButton(
              child: const Text(Constant.LANG == Constant.EN ? ENG.NO : IT.NO),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text(Constant.LANG == Constant.EN ? ENG.YES : IT.YES),
              onPressed: () {
                Navigator.pop(context);
                deleteCustomer();
              },
            ),
          ],
        );
      },
    );
  }

  bool checkPaymentNegative(double amount) {
    if (amount > 0) {
      return false;
    } else {
      return true;
    }
  }

  Widget loadGraph() {
    return Card(
      margin: const EdgeInsets.only(top: Dimensions.PADDING_S, left: Dimensions.PADDING_S, right: Dimensions.PADDING_S,),
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(Dimensions.PADDING_L),
      ),
      elevation: Dimensions.PADDING_XS,
      borderOnForeground: true,
      semanticContainer: true,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: Dimensions.PADDING_S, left: Dimensions.PADDING_S, right: Dimensions.PADDING_S,),
            child: Text(
              Constant.LANG == Constant.EN ? ENG.CUSTOMER_PROFILE_GRAPH_TITLE : IT.CUSTOMER_PROFILE_GRAPH_TITLE,
              style: gothamRegular.copyWith(
                fontSize: Dimensions.FONT_L,
                color: const Color(AllColors.colorText),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: Dimensions.PADDING_S, left: Dimensions.PADDING_S, right: Dimensions.PADDING_S,),
            width: MediaQuery.of(context).size.width,
            height: 350.h,
            child: charts.BarChart(
              series,
              animate: true,
              barGroupingType: charts.BarGroupingType.grouped,
              vertical: true,
              behaviors: [charts.SeriesLegend()],
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    var style = gothamRegular.copyWith(
      color: const Color(AllColors.colorText),
      fontSize: 10,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Gen';
        break;
      case 1:
        text = 'Feb';
        break;
      case 2:
        text = 'Mar';
        break;
      case 3:
        text = 'Apr';
        break;
      case 4:
        text = 'Mag';
        break;
      case 5:
        text = 'Giu';
        break;
      case 6:
        text = 'Lug';
        break;
      case 7:
        text = 'Ago';
        break;
      case 8:
        text = 'Set';
        break;
      case 9:
        text = 'Ott';
        break;
      case 10:
        text = 'Nov';
        break;
      case 11:
        text = 'Dic';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget newGraphChart() {
    return BarChartDataWidget(barChartGroupList: barChartGroupList, maxAmount: maxAmount);
  }

  List<BarChartGroupData> getGroupData() {
    barChartGroupList.clear();
    for(int i = 0; i < graphData.length; i++) {
      barChartGroupList.add(
        BarChartGroupData(
          x: i,
          groupVertically: true,
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: double.parse(graphData[i].totalPaid),
              color: const Color(0xff1e8ab7),
              width: 5,
            ),
            BarChartRodData(
              fromY: double.parse(graphData[i].totalPaid),
              toY: double.parse(graphData[i].totalPaid) + double.parse(graphData[i].totalGiven),
              color: const Color(0xffe77e23),
              width: 5,
            ),
          ],
        ),
      );
    }
    return barChartGroupList;
  }

}