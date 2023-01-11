
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/childscreens/AddNewProductScreen.dart';
import 'package:paciolo/innerscreens/DocumentTypeScreen.dart';
import 'package:paciolo/innerscreens/SearchCustomerScreen.dart';
import 'package:paciolo/model/DocumentTypeData.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/images.dart';
import 'package:paciolo/util/styles.dart';
import '../auth/login_screen.dart';
import '../childscreens/AddDeadlineScreen.dart';
import '../childscreens/EditPaymentScreen.dart';
import '../childscreens/EditProductInfoScreen.dart';
import '../childscreens/SelectPaymentMethodScreen.dart';
import '../childscreens/SelectReasonForPaymentScreen.dart';
import '../childscreens/SelectVatTypeScreen.dart';
import '../childscreens/SelectWithHoldingTypeScreen.dart';
import '../innerscreens/SearchProductScreen.dart';
import '../model/LoginUserModel.dart';
import '../model/PaymentModel.dart';
import '../network/GetRequest.dart';
import '../network/PostRequest.dart';
import '../network/ResponseListener.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';

class CreateInvoiceScreen extends StatefulWidget {

  var documentTypeData;

  CreateInvoiceScreen({Key? key, this.documentTypeData}) : super(key: key);

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> with SingleTickerProviderStateMixin
    implements ResponseListener {

  String TAG = "_CreateInvoiceScreenState";
  int _selectIndex = 0;
  bool showLoader = false;
  LoginUserModel? userModel;
  CurrentCompany? currentCompany;
  var lastDocumentLoadedId;
  var documentType;
  List<dynamic> documentTypeList = List.from([]);
  late TabController _tabController;
  var GET_DOCUMENT_VATS = 3000;
  var GET_WITH_HOLDINGS = 3001;
  var GET_DOCUMENT_TYPES = 3002;
  var GET_DOCUMENT_NUMBER = 3003;
  var GET_DOCUMENT_FILTER_TYPES = 3004;
  var GET_MEASURE_UNIT = 3005;
  var SAVE_CUSTOMER = 30010;

  List<dynamic> pensionFundVatList = List.from([]);
  List<dynamic> vatTypesDataList = List.from([]);

  List<dynamic> withListDataList = List.from([]);
  List<dynamic> withHoldingDataList = List.from([]);

  List<dynamic> measuringUnitList = List.from([]);

  DocumentTypeData? documentTypeData;
  var documentNumber;



  // first tab fields
  TextEditingController agencyNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cellPhoneController = TextEditingController();
  TextEditingController fiscalCodeController = TextEditingController();
  TextEditingController vatNumberController = TextEditingController();
  TextEditingController sdiCodeController = TextEditingController();
  TextEditingController emailPECController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController provinceAbbreviationController = TextEditingController();
  TextEditingController stateInitialsController = TextEditingController();
  TextEditingController pecEmailController = TextEditingController();


  var customerDataResult;
  var documentDataResult;

  // second tab fields
  TextEditingController documentNumberController = TextEditingController();
  TextEditingController documentCodeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  DateTime currentDate = DateTime.now();
  bool _stampValue = false;
  bool _discountValue = false;
  bool _withholdingTaxValue = false;
  bool _pensionFundValue = false;
  bool _calculateWithholdingTaxValue = false;

  String companyDescription = "";
  var pensionFundVatResult;
  double pensionFundVatValue = 0.00;
  double pensionFundVat = 0.00;
  double pensionFundAmount = 0.00;
  TextEditingController pensionFundVatController = TextEditingController();

  var withHoldingResult;
  var reasonForPaymentResult;

  TextEditingController pensionFundController = TextEditingController();
  TextEditingController stampAmountController = TextEditingController(text: "2.00");
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();

  TextEditingController withHoldingTypeController1 = TextEditingController();
  TextEditingController withHoldingTypeController2 = TextEditingController();
  TextEditingController withHoldingTypeController3 = TextEditingController();

  TextEditingController withHoldingMethodController1 = TextEditingController();
  TextEditingController withHoldingMethodController2 = TextEditingController();
  TextEditingController withHoldingMethodController3 = TextEditingController();

  TextEditingController withHoldingPercentageController1 = TextEditingController();
  TextEditingController withHoldingPercentageController2 = TextEditingController();
  TextEditingController withHoldingPercentageController3 = TextEditingController();

  double withHoldingTax1 = 0.00;
  double withHoldingTax2 = 0.00;
  double withHoldingTax3 = 0.00;
  String withHoldingTypeValue1 = "";
  String withHoldingTypeValue2 = "";
  String withHoldingTypeValue3 = "";

  String withHoldingMethodValue1 = "";
  String withHoldingMethodValue2 = "";
  String withHoldingMethodValue3 = "";

  double totalProductVat = 0.00;


  List withHoldingTypeList = List.from([]);
  var GET_WITHHOLDING_LIST = 9003;
  int withHoldingTaxVisibility = 0;

  // third tab fields
  var productResult;
  List productList = List.from([]);
  double totalPrice = 0.00;
  late SlidableController slidableController;

  ScrollController scrollController = ScrollController();
  double totalWithHoldingTax = 0.00;
  double totalVat = 0.00;
  double totalProductDiscount = 0.00;

  //fourth tab fields

  TextEditingController modeController = TextEditingController();
  double subTotal = 0.00;
  double totalPayment = 0.00;
  var GET_PAYMENT_METHOD_WITH_ID = 3006;
  var GET_PAYMENT_MODE = 3007;
  var GET_WALLET_LIST = 3008;
  var GET_CUSTOMER_PREF_LIST = 3009;
  List<dynamic> paymentMethodList = List.from([]);
  List<PaymentModel> paymentDataList = List.from([]);
  List<dynamic> paymentModeList = List.from([]);
  List<dynamic> walletList = List.from([]);
  var customerPrefId;
  bool reCalculate = false;
  var payment_mode;

  var paymentResult;
  var paymentMethodId;
  String walletName = "";
  String coordName = "";
  String modeName = "";
  bool  tabValue = true;

  double totalToShow = 0.00;

  var SAVE_DOCUMENT = 3010;

  // fifth tab fields

  TextEditingController recepientNameController = TextEditingController();
  TextEditingController pecController = TextEditingController();
  TextEditingController einvoiceTypologyController = TextEditingController();
  TextEditingController documentNumberSDIController = TextEditingController();
  TextEditingController cupCodeController = TextEditingController();
  TextEditingController cigCodeController = TextEditingController();
  TextEditingController causalController = TextEditingController();
  TextEditingController vatSDIController = TextEditingController();
  TextEditingController evaluateController = TextEditingController();
  TextEditingController termsOfPaymentController = TextEditingController();
  TextEditingController vatChargebilityController = TextEditingController();


  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {

      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      debugPrint("$TAG document Type Data ======> ${widget.documentTypeData}");

      currentCompany = userModel!.currentCompany!;
      if(currentCompany != null && currentCompany!.description != null && currentCompany!.description != "") {
        companyDescription = currentCompany!.description!;
      } else {
        companyDescription = "";
      }

      getCustomerPreferenceList();
      getWithHoldingValues();
      getPaymentMode();
      getWalletList();
      getMeasuringUnit();

      if(widget.documentTypeData != null) {
        documentDataResult = widget.documentTypeData;
        documentType = documentDataResult["name"];
        getDocumentTypes();
        getDocumentNumbers(true);

      }
    });
    _tabController = TabController(vsync: this, initialIndex: _selectIndex, length: tabValue == false ? 4 : 5);

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
        leading: IconButton(
          icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if(_selectIndex == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
              child: IconButton(
                onPressed: () async {
                  var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return const SearchCustomerScreen();
                  },));

                  setState(() {
                    if(result != null) {
                      debugPrint("$TAG Search Customer data =======> $result");
                      getCustomerPreferenceList();
                      setCustomerData(result);
                    }
                  });
                },
                icon: const Icon(Icons.person),
              ),
            ),

          if(_selectIndex == 3)
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
              child: IconButton(
                onPressed: () {
                  if(customerDataResult == null ) {
                    Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_ALERT1 : IT.CREATE_INVOICE_TAB_2_ALERT1);
                  } else if(productList.isEmpty) {
                    Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_ALERT2 : IT.CREATE_INVOICE_TAB_2_ALERT2);
                  } else if(paymentDataList.isEmpty) {
                    Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_ALERT3 : IT.CREATE_INVOICE_TAB_2_ALERT3);
                  } else {
                    createCustomer();
                    //saveDocument();
                  }
                },
                icon: const Icon(Icons.save),
              ),
            ),

          Visibility(
            visible: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB( Dimensions.PADDING_S, 8.0, 18.0, 8.0),
              child: InkWell(
                onTap: () async {
                  var result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return const DocumentTypeScreen();
                  },));

                  setState(() {
                    if(result != null) {
                      debugPrint("$TAG selected document type data =======> $result");
                      documentDataResult = result;
                      documentType = documentDataResult["name"];
                      getDocumentTypes();
                      getDocumentNumbers(true);
                    }
                  });
                },
                child: SvgPicture.asset(
                  Images.documentType,
                  height: 20,
                  width: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        title: Text(
          Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TITLE : IT.CREATE_INVOICE_TITLE,
          style: gothamRegular.copyWith(
              color: Colors.white,
              fontSize: Dimensions.FONT_L
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            debugPrint("$TAG Tab Tap index =====> $index");
            debugPrint("$TAG Tab Tap _tabController index =====> ${_tabController.index}");
            debugPrint("$TAG Tab Tap _selectIndex =====> $_selectIndex");
            setState(() {
              _selectIndex = index;
            });

            debugPrint("$TAG Tab Tap _tabController index =====> ${_tabController.index}");
            debugPrint("$TAG Tab Tap _selectIndex =====> $_selectIndex");
          },
          labelColor: Colors.white,
          isScrollable: true,
          unselectedLabelColor: const Color(AllColors.colorTabs),
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(Images.person,
                      color: Colors.white
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_TITLE_1
                        : IT.CREATE_INVOICE_TAB_TITLE_1,
                    style: gothamRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.FONT_L.sp),
                  )
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    Images.genericValue,
                    color: Colors
                        .white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_TITLE_2
                        : IT.CREATE_INVOICE_TAB_TITLE_2,
                    style: gothamRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.FONT_L.sp),
                  )
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    Images.products,
                    color: Colors.white,
                    height: 17.h,
                    width: 17.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_TITLE_3
                        : IT.CREATE_INVOICE_TAB_TITLE_3,
                    style: gothamRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.FONT_L.sp),
                  )
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    Images.wallet,
                    color: Colors.white,
                    height: 17.h,
                    width: 17.w,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_TITLE_4
                        : IT.CREATE_INVOICE_TAB_TITLE_4,
                    style: gothamRegular.copyWith(
                        color: Colors.white,
                        fontSize: Dimensions.FONT_L.sp),
                  )
                ],
              ),
            ),
            Visibility(
              visible: tabValue,
              child: Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Images.sdi,
                      color: Colors.white,
                      height: 17.h,
                      width: 17.w,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      Constant.LANG == Constant.EN
                          ? ENG.CREATE_INVOICE_TAB_TITLE_5
                          : IT.CREATE_INVOICE_TAB_TITLE_5,
                      style: gothamRegular.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.FONT_L.sp),
                    )
                  ],
                ),
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
          physics: const NeverScrollableScrollPhysics(),
          children: [
            personDataTab(),
            genericValueTab(),
            productListTab(),
            createInvoicePaymentTab(),
            Visibility(
                visible: tabValue,
                child: createInvoiceSdiTab()),
          ],
        ),
      ),
    );
  }

  Widget personDataTab() {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.all(Dimensions.PADDING_L),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.PADDING_S,
                Dimensions.PADDING_L,
                Dimensions.PADDING_S,
                Dimensions.PADDING_L,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_1_HEADING
                            : IT.CREATE_INVOICE_TAB_1_HEADING,
                        style: gothamBold.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L.sp,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          agencyNameController.clear();
                          vatNumberController.clear();
                          fiscalCodeController.clear();
                          addressController.clear();
                          address2Controller.clear();
                          cityController.clear();
                          postalCodeController.clear();
                          provinceAbbreviationController.clear();
                          stateInitialsController.clear();
                          sdiCodeController.clear();
                          pecEmailController.clear();
                        },
                        child: Text(
                          Constant.LANG == Constant.EN
                              ? ENG.CREATE_INVOICE_TAB_1_CLEAR_DATA
                              : IT.CREATE_INVOICE_TAB_1_CLEAR_DATA,
                          style: gothamRegular.copyWith(
                              color: const Color(AllColors.colorRed),
                              fontSize: Dimensions.FONT_M.sp),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.PADDING_L.h,
                  ),
                  // Name TextFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_1_LABEL_1
                            : IT.CREATE_INVOICE_TAB_1_LABEL_1,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: agencyNameController,
                          keyboardType: TextInputType.name,
                          autofocus: false,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: const EdgeInsets.only(
                                left: Dimensions.PADDING_S,
                                bottom: 8.0,
                                top: 8.0,
                                right: Dimensions.PADDING_S),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.PADDING_L.h,
                  ),
                  // VAT number TextFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_1_LABEL_2
                            : IT.CREATE_INVOICE_TAB_1_LABEL_2,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: vatNumberController,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: const EdgeInsets.only(
                                left: Dimensions.PADDING_S,
                                bottom: 8.0,
                                top: 8.0,
                                right: Dimensions.PADDING_S),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.PADDING_L.h,
                  ),
                  // fiscal code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_1_LABEL_3
                            : IT.CREATE_INVOICE_TAB_1_LABEL_3,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: fiscalCodeController,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: const EdgeInsets.only(
                                left: Dimensions.PADDING_S,
                                bottom: 8.0,
                                top: 8.0,
                                right: Dimensions.PADDING_S),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.PADDING_L.h,
                  ),
                  // Address TextFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_1_LABEL_4
                            : IT.CREATE_INVOICE_TAB_1_LABEL_4,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: addressController,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: const EdgeInsets.only(
                                left: Dimensions.PADDING_S,
                                bottom: 8.0,
                                top: 8.0,
                                right: Dimensions.PADDING_S),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.PADDING_L.h,
                  ),
                  // Address 2 TextField
                  // Address TextFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_1_LABEL_5
                            : IT.CREATE_INVOICE_TAB_1_LABEL_5,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: address2Controller,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: const EdgeInsets.only(
                                left: Dimensions.PADDING_S,
                                bottom: 8.0,
                                top: 8.0,
                                right: Dimensions.PADDING_S),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: Dimensions.PADDING_L.h,
                  ),
                  // city and postal Code TextFiled
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN
                                  ? ENG.CREATE_INVOICE_TAB_1_LABEL_6
                                  : IT.CREATE_INVOICE_TAB_1_LABEL_6,
                              style: gothamRegular.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(splashColor: Colors.transparent),
                              child: TextField(
                                controller: cityController,
                                keyboardType: TextInputType.name,
                                autofocus: false,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF1F1F1),
                                  contentPadding: const EdgeInsets.only(
                                      left: Dimensions.PADDING_S,
                                      bottom: 8.0,
                                      top: 8.0,
                                      right: Dimensions.PADDING_S),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_L.r),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_L.r),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: Dimensions.PADDING_S.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN
                                  ? ENG.CREATE_INVOICE_TAB_1_LABEL_7
                                  : IT.CREATE_INVOICE_TAB_1_LABEL_7,
                              style: gothamRegular.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(splashColor: Colors.transparent),
                              child: TextField(
                                controller: postalCodeController,
                                keyboardType: TextInputType.number,
                                autofocus: false,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF1F1F1),
                                  contentPadding: const EdgeInsets.only(
                                      left: Dimensions.PADDING_S,
                                      bottom: 8.0,
                                      top: 8.0,
                                      right: Dimensions.PADDING_S),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_L.r),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_L.r),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.PADDING_L.h,),
                  // Province TextFiled
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN
                                  ? ENG.CREATE_INVOICE_TAB_1_LABEL_8
                                  : IT.CREATE_INVOICE_TAB_1_LABEL_8,
                              style: gothamRegular.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(splashColor: Colors.transparent),
                              child: TextField(
                                controller: provinceAbbreviationController,
                                keyboardType: TextInputType.text,
                                maxLength: 2,
                                autofocus: false,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF1F1F1),
                                  contentPadding: const EdgeInsets.only(
                                      left: Dimensions.PADDING_S,
                                      bottom: 8.0,
                                      top: 8.0,
                                      right: Dimensions.PADDING_S),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_L.r),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_L.r),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: Dimensions.PADDING_S.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN
                                  ? ENG.CREATE_INVOICE_TAB_1_LABEL_9
                                  : IT.CREATE_INVOICE_TAB_1_LABEL_9,
                              style: gothamRegular.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(splashColor: Colors.transparent),
                              child: TextField(
                                controller: stateInitialsController,
                                keyboardType: TextInputType.name,
                                maxLength: 2,
                                autofocus: false,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF1F1F1),
                                  contentPadding: const EdgeInsets.only(
                                      left: Dimensions.PADDING_S,
                                      bottom: 8.0,
                                      top: 8.0,
                                      right: Dimensions.PADDING_S),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_L.r),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                    const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_L.r),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.PADDING_L.h,),
                  // SDI Code TextFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_1_LABEL_10
                            : IT.CREATE_INVOICE_TAB_1_LABEL_10,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: sdiCodeController,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: const EdgeInsets.only(
                                left: Dimensions.PADDING_S,
                                bottom: 8.0,
                                top: 8.0,
                                right: Dimensions.PADDING_S),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: Dimensions.PADDING_L.h,),
                  // PEC TextFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_1_LABEL_11
                            : IT.CREATE_INVOICE_TAB_1_LABEL_11,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: pecEmailController,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: false,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: const EdgeInsets.only(
                                left: Dimensions.PADDING_S,
                                bottom: 8.0,
                                top: 8.0,
                                right: Dimensions.PADDING_S),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: Dimensions.PADDING_M,
          right: Dimensions.PADDING_L,
          left:250.0,
          child: Container(
            height: 45.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(AllColors.colorBlue),
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.only(right: 10),
                        alignment: Alignment.center,
                        height: 45.h,
                        child: GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                Constant.LANG == Constant.EN
                                    ? ENG.CREATE_INVOICE_BUTTON_FORWARD
                                    : IT.CREATE_INVOICE_BUTTON_FORWARD,
                                textAlign: TextAlign.center,
                                style: gothamRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.FONT_L.sp),
                              ),
                              SizedBox(
                                width: Dimensions.PADDING_XS.w,
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.white,
                              )
                            ],
                          ),
                          onTap: () {
                            FocusScopeNode currentFocus=FocusScope.of(context);
                            if(!currentFocus.hasPrimaryFocus){
                              currentFocus.unfocus();
                            }
                            setState(() {
                              _selectIndex = 1;
                              _tabController.index = 1;
                            });
                          },
                        ),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget dialogBox() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        height: 280,
        child: Stack(
          children: [
            Container(
              height: 75.h,
              decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F8),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Dimensions.RADIUS_L.r),
                      topRight: Radius.circular(Dimensions.RADIUS_L.r))),
            ),
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 90.h,
                    width: 90.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 1.0,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Text(
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_1_DIALOGBOX_LABEL_1
                        : IT.CREATE_INVOICE_TAB_1_DIALOGBOX_LABEL_1,
                    style: gothamBold.copyWith(
                        color: const Color(AllColors.colorText),
                        fontSize: Dimensions.FONT_L),
                  ),
                  SizedBox(
                    height: Dimensions.PADDING_M.h,
                  ),
                  Text(
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_1_DIALOGBOX_LABEL_2
                        : IT.CREATE_INVOICE_TAB_1_DIALOGBOX_LABEL_2,
                    textAlign: TextAlign.center,
                    style: gothamRegular.copyWith(
                      height: 1.2,
                      color: const Color(AllColors.colorText),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: const Color(0xFF707070), width: 0.3.w),
                          right: BorderSide(
                              color: const Color(0xFF707070), width: 0.3.w),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft:
                              Radius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                        child: Text(
                          Constant.LANG == Constant.EN
                              ? ENG.CREATE_INVOICE_TAB_1_DIALOGBOX_LABEL_3
                              : IT.CREATE_INVOICE_TAB_1_DIALOGBOX_LABEL_3,
                          style: gothamBold.copyWith(
                              color: const Color(AllColors.colorGreen),
                              fontSize: Dimensions.FONT_L.sp),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFF707070),
                            width: 0.3.w,
                          ),
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomRight:
                              Radius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                        child: Text(
                          Constant.LANG == Constant.EN
                              ? ENG.CREATE_INVOICE_TAB_1_DIALOGBOX_LABEL_4
                              : IT.CREATE_INVOICE_TAB_1_DIALOGBOX_LABEL_4,
                          style: gothamBold.copyWith(
                              color: const Color(AllColors.colorRed),
                              fontSize: Dimensions.FONT_L.sp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget genericValueTab() {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: EdgeInsets.only(bottom: 50.0.h),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(Dimensions.PADDING_S),
                  padding: const EdgeInsets.only(top: 20, right: 12, left: 12, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Normal Invoice Text Heading
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_2_INVOICE_DATA
                            : IT.CREATE_INVOICE_TAB_2_INVOICE_DATA,
                        style: gothamBold.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_XL.h),

                      // Normal Number Heading
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_2_NUMBER
                            : IT.CREATE_INVOICE_TAB_2_NUMBER,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),

                      // number TextFiled
                      Theme(
                        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: documentNumberController,
                          keyboardType: TextInputType.number,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_NUMBER : IT.CREATE_INVOICE_TAB_2_NUMBER,
                            helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: REdgeInsets.fromLTRB(20, 0, 20, 0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_L),

                      Text(
                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_CODE_SECTION : IT.CREATE_INVOICE_TAB_2_CODE_SECTION,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),

                      // normal TextFiled
                      Theme(
                        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: documentCodeController,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: REdgeInsets.fromLTRB(20, 0, 20, 0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // Date Heading Text with Other option
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_DATE : IT.CREATE_INVOICE_TAB_2_DATE,
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                          ),
                          const SizedBox(height: Dimensions.PADDING_XS),
                          TextField(
                            controller: dateController,
                            onTap: () async {
                              _selectDate(context);
                            },
                            readOnly: true,
                            style: gothamMedium.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                            cursorColor: Colors.black,
                            cursorWidth: 1.5.w,
                            decoration: InputDecoration(
                              suffixIcon: const Icon(
                                Icons.calendar_month,
                                color: Color(AllColors.colorText),
                              ),
                              contentPadding:
                              REdgeInsets.fromLTRB(20, 0, 0, 0),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.7.w,
                                  color: const Color(AllColors.colorGrey).withOpacity(0.7),
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
                              hintStyle: gothamMedium.copyWith(
                                  color: Colors.grey,
                                  fontSize: Dimensions.FONT_XL.sp,
                                  fontWeight: FontWeight.w600),
                              hintText: Utility.getFormattedDateFromDateTime(currentDate),
                              fillColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.PADDING_L),

                      const Divider(height: 1,),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // custom checkBox
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _stampValue = !_stampValue;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 23.h,
                              width: 23.w,
                              decoration: BoxDecoration(
                                color: _stampValue == false ? Colors.white : const Color(AllColors.colorBlue),
                                borderRadius: BorderRadius.circular(3.r),
                                border: Border.all(
                                  width: 1.5.w,
                                  color: const Color(AllColors.colorBlue),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Dimensions.PADDING_M.w,),
                          Text(
                            Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_STAMP : IT.CREATE_INVOICE_TAB_2_STAMP,
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                          ),
                          SizedBox(width: Dimensions.PADDING_L.w,),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _discountValue = !_discountValue;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 23.h,
                              width: 23.w,
                              decoration: BoxDecoration(
                                color: _discountValue == false ? Colors.white : const Color(AllColors.colorBlue),
                                borderRadius: BorderRadius.circular(3.r),
                                border: Border.all(
                                  width: 1.5.w,
                                  color: const Color(AllColors.colorBlue),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Dimensions.PADDING_M.w,),
                          Text(
                            Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_DISCOUNT : IT.CREATE_INVOICE_TAB_2_DISCOUNT,
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.PADDING_M.h),
                      // stamp fields
                      Visibility(
                        visible: _stampValue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_STAMP : IT.CREATE_INVOICE_TAB_2_STAMP,
                              style: gothamBold.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_M,),
                            Theme(
                              data: Theme.of(context).copyWith(
                                splashColor: Colors.transparent,
                                hintColor: const Color(0xFFbdc6cf),
                              ),
                              child: TextField(
                                controller: stampAmountController,
                                onChanged: (value) {
                                  // setState(() {
                                  //   cashTotalWithVatCalculation();
                                  // });
                                },
                                keyboardType: TextInputType.number,
                                autofocus: false,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                ),
                                decoration: InputDecoration(
                                  hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_STAMP_AMOUNT : IT.CREATE_INVOICE_TAB_2_STAMP_AMOUNT,
                                  helperStyle:
                                  gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                  filled: true,
                                  fillColor:
                                  const Color(0xFFF1F1F1),
                                  contentPadding: REdgeInsets.fromLTRB(20, 0, 20, 0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                  ),
                                  enabledBorder:
                                  UnderlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_M.h),
                      // diccount fields
                      Visibility(
                        visible: _discountValue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN
                                  ? ENG.CREATE_INVOICE_TAB_2_DISCOUNT
                                  : IT.CREATE_INVOICE_TAB_2_DISCOUNT,
                              style: gothamBold.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_M,),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                        style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.PADDING_XS),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          splashColor: Colors.transparent,
                                          hintColor: const Color(0xFFbdc6cf),
                                        ),
                                        child: TextField(
                                          controller: discountPercentageController,
                                          onChanged: (value) {

                                          },
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          style: gothamRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: Dimensions.FONT_L,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: Constant.LANG ==
                                                Constant.EN
                                                ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE
                                                : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                            helperStyle:
                                            gothamRegular.copyWith(
                                                fontSize:
                                                Dimensions.FONT_S.sp),
                                            filled: true,
                                            fillColor:
                                            const Color(0xFFF1F1F1),
                                            contentPadding:
                                            REdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  Dimensions.RADIUS_M.r),
                                            ),
                                            enabledBorder:
                                            UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  Dimensions.RADIUS_M.r),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(width: Dimensions.PADDING_S.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constant.LANG == Constant.EN
                                            ? ENG
                                            .CREATE_INVOICE_TAB_2_DISCOUNT_AMOUNT
                                            : IT.CREATE_INVOICE_TAB_2_DISCOUNT_AMOUNT,
                                        style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: Dimensions.PADDING_XS),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          splashColor: Colors.transparent,
                                          hintColor: const Color(0xFFbdc6cf),
                                        ),
                                        child: TextField(
                                          controller: discountAmountController,
                                          onChanged: (value) {

                                          },
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          style: gothamRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: Dimensions.FONT_L,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: Constant.LANG ==
                                                Constant.EN
                                                ? ENG.CREATE_INVOICE_TAB_2_DISCOUNT_AMOUNT
                                                : IT.CREATE_INVOICE_TAB_2_DISCOUNT_AMOUNT,
                                            helperStyle:
                                            gothamRegular.copyWith(
                                                fontSize:
                                                Dimensions.FONT_S.sp),
                                            filled: true,
                                            fillColor:
                                            const Color(0xFFF1F1F1),
                                            contentPadding:
                                            REdgeInsets.fromLTRB(
                                                20, 0, 20, 0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  Dimensions.RADIUS_M.r),
                                            ),
                                            enabledBorder:
                                            UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius:
                                              BorderRadius.circular(
                                                  Dimensions.RADIUS_M.r),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_M.h),
                      const Divider(height: 1,),
                      SizedBox(height: Dimensions.PADDING_M.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            Constant.LANG == Constant.EN
                                ? ENG
                                .CREATE_INVOICE_TAB_2_CONTRIBUTION_AND_WITHHOLDING
                                : IT.CREATE_INVOICE_TAB_2_CONTRIBUTION_AND_WITHHOLDING,
                            style: gothamBold.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                          ),
                          const SizedBox(height: Dimensions.PADDING_L),

                          // custom checkBox
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  getWithHoldingType();
                                  getWithHoldingValues();
                                  setState(() {
                                    _withholdingTaxValue = !_withholdingTaxValue;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 23.h,
                                  width: 23.w,
                                  decoration: BoxDecoration(
                                      color: _withholdingTaxValue == false ? Colors.white : const Color(AllColors.colorBlue),
                                      borderRadius: BorderRadius.circular(3.r),
                                      border: Border.all(
                                          width: 1.5.w,
                                          color: const Color(AllColors.colorBlue)
                                      )
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.PADDING_M,),
                              Text(
                                Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_OR_WITHHOLDINGTAX : IT.CREATE_INVOICE_TAB_2_OR_WITHHOLDINGTAX,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_M,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimensions.PADDING_S.h,),

                          // custom checkBox
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _pensionFundValue = !_pensionFundValue;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 23.h,
                                  width: 23.w,
                                  decoration: BoxDecoration(
                                    color: _pensionFundValue == false ? Colors.white : const Color(AllColors.colorBlue),
                                    borderRadius: BorderRadius.circular(3.r),
                                    border: Border.all(
                                      width: 1.5.w,
                                      color: const Color(AllColors.colorBlue),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.PADDING_M,),
                              Text(
                                Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_OR_PENSION_FUND_BASED_ON_PREFERENCES : IT.CREATE_INVOICE_TAB_2_OR_PENSION_FUND_BASED_ON_PREFERENCES,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_M,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: Dimensions.PADDING_M.h),

                      const Divider(height: 1,),
                      SizedBox(height: Dimensions.PADDING_M.h),
                      // pension fund fields
                      Visibility(
                        visible: _pensionFundValue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PENSION_FUND : IT.CREATE_INVOICE_TAB_2_PENSION_FUND,
                              style: gothamBold.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_M,),

                            Text(
                              companyDescription,
                              style: gothamRegular.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_M,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_M,),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                        style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.PADDING_XS),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          splashColor: Colors.transparent,
                                          hintColor: const Color(0xFFbdc6cf),
                                        ),
                                        child: TextField(
                                          controller: pensionFundController,
                                          onChanged: (value) {
                                            setState(() {
                                              cashTotalWithVatCalculation();
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          style: gothamRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: Dimensions.FONT_L,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                            helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                            filled: true,
                                            fillColor:
                                            const Color(0xFFF1F1F1),
                                            contentPadding: REdgeInsets.fromLTRB(20, 0, 20, 0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white),
                                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                            ),
                                            enabledBorder:
                                            UnderlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white),
                                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: Dimensions.PADDING_S.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_VAT : IT.CREATE_INVOICE_TAB_2_VAT,
                                        style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.PADDING_XS),
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          splashColor: Colors.transparent,
                                          hintColor: const Color(0xFFbdc6cf),
                                        ),
                                        child: TextField(
                                          controller: pensionFundVatController,
                                          readOnly: true,
                                          autofocus: false,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: Dimensions.FONT_L,
                                          ),

                                          onTap: () async {
                                            pensionFundVatResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                return SelectVatTypeScreen();
                                              },
                                            ));

                                            debugPrint("$TAG pension fund vat result ======> $pensionFundVatResult");
                                            setState(() {
                                              if (pensionFundVatResult != null) {
                                                pensionFundVatController.text = pensionFundVatResult["name"];
                                                pensionFundVatValue = double.parse(pensionFundVatResult["value"].toString());
                                              }
                                            });
                                          },

                                          decoration: InputDecoration(
                                            suffixIcon: const Icon(Icons.arrow_forward_ios),
                                            hintText: Constant.LANG == Constant.EN ? ENG.PRODUCT_ADD_NEW_VAT : IT.PRODUCT_ADD_NEW_VAT,
                                            helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F1),
                                            contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white),
                                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: const BorderSide(color: Colors.white),
                                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _calculateWithholdingTaxValue = !_calculateWithholdingTaxValue;
                                                if(_calculateWithholdingTaxValue && (withHoldingPercentageController1.text != "" || withHoldingPercentageController2.text != "" || withHoldingPercentageController3.text != "")) {
                                                  cashTotalWithVatCalculation();
                                                }
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 23.h,
                                              width: 23.w,
                                              decoration: BoxDecoration(
                                                color: _calculateWithholdingTaxValue == false ? Colors.white : const Color(AllColors.colorBlue),
                                                borderRadius: BorderRadius.circular(3.r),
                                                border: Border.all(
                                                  width: 1.5.w,
                                                  color: const Color(AllColors.colorBlue)
                                                ),
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.only(bottom: 5),
                                                child: Icon(
                                                  Icons.check,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: Dimensions.PADDING_S.w),
                                          Expanded(
                                            child: Text(
                                              Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_CALCULATE_WITHHOLDING_TAX : IT.CREATE_INVOICE_TAB_2_CALCULATE_WITHHOLDING_TAX,
                                              style: gothamRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: Dimensions.FONT_L,
                                              ),
                                            ),
                                          ),
                                        ]
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: Dimensions.PADDING_S.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_CASH_TOTAL : IT.CREATE_INVOICE_TAB_2_CASH_TOTAL,
                                        style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                        ),
                                      ),
                                      const SizedBox(height: Dimensions.PADDING_XS),
                                      Theme(
                                        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                        child: Text(
                                          "${pensionFundAmount.toStringAsFixed(2)} ${Constant.euroSign}",
                                          style: gothamRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: Dimensions.FONT_L,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.PADDING_M.h,),
                            const Divider(height: 1,),
                            SizedBox(height: Dimensions.PADDING_M.h,),
                          ],
                        ),
                      ),
                      // with holding tax fields
                      Visibility(
                        visible: _withholdingTaxValue,
                        child: withHoldingTaxVisibility > 0 ? Column(
                          children: [
                            if(withHoldingTaxVisibility >= 1)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING : IT.CREATE_INVOICE_TAB_2_WITHHOLDING,
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_M,),
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE : IT.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE,
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_XS),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    splashColor: Colors.transparent,
                                    hintColor: const Color(0xFFbdc6cf),
                                  ),
                                  child: SizedBox(
                                    height: 49.h,
                                    child: TextField(
                                      controller: withHoldingTypeController1,
                                      readOnly: true,
                                      autofocus: false,
                                      style: gothamRegular.copyWith(
                                        color: Colors.black,
                                        fontSize: Dimensions.FONT_L,
                                      ),
                                      onTap: () async {
                                        withHoldingResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return SelectWithHoldingTypeScreen();
                                          },
                                        ));

                                        debugPrint("$TAG Withholding type ======> $withHoldingResult");

                                        setState(() {
                                          if (withHoldingResult != null) {
                                            withHoldingTypeController1.text = withHoldingResult["name"];
                                            withHoldingTypeValue1 = withHoldingResult["value"].toString();
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        suffixIcon: const Icon(Icons.arrow_forward_ios),
                                        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE : IT.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE,
                                        helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                        filled: true,
                                        fillColor: const Color(0xFFF1F1F1),
                                        contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_L),
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT : IT.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT,
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_XS),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                  splashColor: Colors.transparent,
                                  hintColor: const Color(0xFFbdc6cf),
                                  ),
                                  child: SizedBox(
                                    height: 49.h,
                                    child: TextField(
                                      controller: withHoldingMethodController1,
                                      readOnly: true,
                                      autofocus: false,
                                      style: gothamRegular.copyWith(
                                        color: Colors.black,
                                        fontSize: Dimensions.FONT_L,
                                      ),
                                      onTap: () async {
                                        reasonForPaymentResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return SelectReasonForPaymentScreen();
                                          },
                                        ));

                                        debugPrint("$TAG reasonForPayment ======> $reasonForPaymentResult");

                                        setState(() {
                                          if (reasonForPaymentResult != null) {
                                            withHoldingMethodController1.text = reasonForPaymentResult["name"];
                                            withHoldingMethodValue1 = reasonForPaymentResult["id"];
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        suffixIcon: const Icon(Icons.arrow_forward_ios),
                                        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT : IT.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT,
                                        helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                        filled: true,
                                        fillColor: const Color(0xFFF1F1F1),
                                        contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_L),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                            style: gothamRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions.FONT_L,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.PADDING_XS),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              splashColor: Colors.transparent,
                                              hintColor: const Color(0xFFbdc6cf),
                                            ),
                                            child: TextField(
                                              controller: withHoldingPercentageController1,
                                              onChanged: (value) {
                                                setState(() {
                                                  cashTotalWithVatCalculation();
                                                });
                                              },
                                              keyboardType: TextInputType.number,
                                              autofocus: false,
                                              style: gothamRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: Dimensions.FONT_L,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                                helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                                filled: true,
                                                fillColor: const Color(0xFFF1F1F1),
                                                contentPadding: REdgeInsets.fromLTRB(20, 0, 20, 0),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.white),
                                                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                                ),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.white),
                                                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: Dimensions.PADDING_S.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_TOTAL_WITHHOLDING : IT.CREATE_INVOICE_TAB_2_TOTAL_WITHHOLDING,
                                            style: gothamRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions.FONT_L,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.PADDING_M),
                                          // commented by nilesh to check issue on 22-12-2023
                                          /*withHoldingPercentageController1.text == null || withHoldingPercentageController1.text.isEmpty ? Text(
                                            "0.00 ${Constant.euroSign}",
                                            style: gothamRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions.FONT_L,
                                            ),
                                          ) : */Text(
                                            "${withHoldingTax1.toStringAsFixed(2)} ${Constant.euroSign}",
                                            style: gothamRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions.FONT_L,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.PADDING_S),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.PADDING_S),
                              ],
                            ),
                            
                            if(withHoldingTaxVisibility >= 2)
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING : IT.CREATE_INVOICE_TAB_2_WITHHOLDING,
                                    style: gothamRegular.copyWith(
                                      color: Colors.black,
                                      fontSize: Dimensions.FONT_L,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.PADDING_M,),
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE : IT.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE,
                                    style: gothamRegular.copyWith(
                                      color: Colors.black,
                                      fontSize: Dimensions.FONT_L,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.PADDING_XS),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      splashColor: Colors.transparent,
                                      hintColor: const Color(0xFFbdc6cf),
                                    ),
                                    child: SizedBox(
                                      height: 49.h,
                                      child: TextField(
                                        controller: withHoldingTypeController2,
                                        readOnly: true,
                                        autofocus: false,
                                        style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                        ),
                                        onTap: () async {
                                          withHoldingResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return SelectWithHoldingTypeScreen();
                                          },
                                          ));

                                          debugPrint("$TAG Withholding type ======> $withHoldingResult");

                                          setState(() {
                                            if (withHoldingResult != null) {
                                              withHoldingTypeController2.text = withHoldingResult["name"];
                                              withHoldingTypeValue2 = withHoldingResult["value"].toString();
                                            }
                                          });
                                        },
                                        decoration: InputDecoration(
                                          suffixIcon: const Icon(Icons.arrow_forward_ios),
                                          hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE : IT.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE,
                                          helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                          filled: true,
                                          fillColor: const Color(0xFFF1F1F1),
                                          contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.PADDING_L),
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT : IT.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT,
                                    style: gothamRegular.copyWith(
                                      color: Colors.black,
                                      fontSize: Dimensions.FONT_L,
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.PADDING_XS),
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                      splashColor: Colors.transparent,
                                      hintColor: const Color(0xFFbdc6cf),
                                    ),
                                    child: SizedBox(
                                      height: 49.h,
                                      child: TextField(
                                        controller: withHoldingMethodController2,
                                        readOnly: true,
                                        autofocus: false,
                                        style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                        ),
                                        onTap: () async {
                                          reasonForPaymentResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return SelectReasonForPaymentScreen();
                                          },
                                          ));

                                          debugPrint("$TAG reasonForPayment ======> $reasonForPaymentResult");

                                          setState(() {
                                            if (reasonForPaymentResult != null) {
                                              withHoldingMethodController2.text = reasonForPaymentResult["name"];
                                              withHoldingMethodValue2 = reasonForPaymentResult["id"];
                                            }
                                          });
                                        },
                                        decoration: InputDecoration(
                                          suffixIcon: const Icon(Icons.arrow_forward_ios),
                                          hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT : IT.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT,
                                          helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                          filled: true,
                                          fillColor: const Color(0xFFF1F1F1),
                                          contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.white),
                                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Dimensions.PADDING_L),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                              style: gothamRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: Dimensions.FONT_L,
                                              ),
                                            ),
                                            const SizedBox(height: Dimensions.PADDING_XS),
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                splashColor: Colors.transparent,
                                                hintColor: const Color(0xFFbdc6cf),
                                              ),
                                              child: TextField(
                                                controller:  withHoldingPercentageController2,
                                                onChanged: (value) {
                                                  setState(() {
                                                    cashTotalWithVatCalculation();
                                                  });
                                                },
                                                keyboardType: TextInputType.number,
                                                autofocus: false,
                                                style: gothamRegular.copyWith(
                                                  color: Colors.black,
                                                  fontSize: Dimensions.FONT_L,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                                  helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                                  filled: true,
                                                  fillColor: const Color(0xFFF1F1F1),
                                                  contentPadding: REdgeInsets.fromLTRB(20, 0, 20, 0),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: const BorderSide(color: Colors.white),
                                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                    borderSide: const BorderSide(color: Colors.white),
                                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: Dimensions.PADDING_S.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_TOTAL_WITHHOLDING : IT.CREATE_INVOICE_TAB_2_TOTAL_WITHHOLDING,
                                              style: gothamRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: Dimensions.FONT_L,
                                              ),
                                            ),
                                            const SizedBox(height: Dimensions.PADDING_M),
                                            withHoldingPercentageController2.text == null || withHoldingPercentageController2.text.isEmpty ? Text(
                                              "0.00 ${Constant.euroSign}",
                                              style: gothamRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: Dimensions.FONT_L,
                                              ),
                                            ) : Text(
                                              "${withHoldingTax2.toStringAsFixed(2)} ${Constant.euroSign}",
                                              style: gothamRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: Dimensions.FONT_L,
                                              ),
                                            ),
                                            const SizedBox(height: Dimensions.PADDING_S),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.PADDING_S),
                                ],
                              ),

                            if(withHoldingTaxVisibility == 3)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING : IT.CREATE_INVOICE_TAB_2_WITHHOLDING,
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_M,),
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE : IT.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE,
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_XS),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    splashColor: Colors.transparent,
                                    hintColor: const Color(0xFFbdc6cf),
                                  ),
                                  child: SizedBox(
                                    height: 49.h,
                                    child: TextField(
                                      controller: withHoldingTypeController3,
                                      readOnly: true,
                                      autofocus: false,
                                      style: gothamRegular.copyWith(
                                        color: Colors.black,
                                        fontSize: Dimensions.FONT_L,
                                      ),
                                      onTap: () async {
                                        withHoldingResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                          return SelectWithHoldingTypeScreen();
                                        },
                                        ));

                                        debugPrint("$TAG Withholding type ======> $withHoldingResult");

                                        setState(() {
                                          if (withHoldingResult != null) {
                                            withHoldingTypeController3.text = withHoldingResult["name"];
                                            withHoldingTypeValue3 = withHoldingResult["value"].toString();
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        suffixIcon: const Icon(Icons.arrow_forward_ios),
                                        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE : IT.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE,
                                        helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                        filled: true,
                                        fillColor: const Color(0xFFF1F1F1),
                                        contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_L),
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT : IT.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT,
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_XS),
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    splashColor: Colors.transparent,
                                    hintColor: const Color(0xFFbdc6cf),
                                  ),
                                  child: SizedBox(
                                    height: 49.h,
                                    child: TextField(
                                      controller: withHoldingMethodController3,
                                      readOnly: true,
                                      autofocus: false,
                                      style: gothamRegular.copyWith(
                                        color: Colors.black,
                                        fontSize: Dimensions.FONT_L,
                                      ),
                                      onTap: () async {
                                        reasonForPaymentResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                          return SelectReasonForPaymentScreen();
                                        },
                                        ));

                                        debugPrint("$TAG reasonForPayment ======> $reasonForPaymentResult");

                                        setState(() {
                                          if (reasonForPaymentResult != null) {
                                            withHoldingMethodController3.text = reasonForPaymentResult["name"];
                                            withHoldingMethodValue3 = reasonForPaymentResult["id"];
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        suffixIcon: const Icon(Icons.arrow_forward_ios),
                                        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT : IT.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT,
                                        helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                        filled: true,
                                        fillColor: const Color(0xFFF1F1F1),
                                        contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                        ),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.white),
                                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Dimensions.PADDING_L),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                            style: gothamRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions.FONT_L,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.PADDING_XS),
                                          Theme(
                                            data: Theme.of(context).copyWith(
                                              splashColor: Colors.transparent,
                                              hintColor: const Color(0xFFbdc6cf),
                                            ),
                                            child: TextField(
                                              controller:  withHoldingPercentageController3,
                                              onChanged: (value) {
                                                setState(() {
                                                  cashTotalWithVatCalculation();
                                                });
                                              },
                                              keyboardType: TextInputType.number,
                                              autofocus: false,
                                              style: gothamRegular.copyWith(
                                                color: Colors.black,
                                                fontSize: Dimensions.FONT_L,
                                              ),
                                              decoration: InputDecoration(
                                                hintText: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PERCENTAGE : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                                helperStyle: gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                                                filled: true,
                                                fillColor: const Color(0xFFF1F1F1),
                                                contentPadding: REdgeInsets.fromLTRB(20, 0, 20, 0),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.white),
                                                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                                ),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.white),
                                                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: Dimensions.PADDING_S.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_TOTAL_WITHHOLDING : IT.CREATE_INVOICE_TAB_2_TOTAL_WITHHOLDING,
                                            style: gothamRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions.FONT_L,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.PADDING_M),
                                          withHoldingPercentageController3.text == null || withHoldingPercentageController3.text.isEmpty ? Text(
                                            "0.00 ${Constant.euroSign}",
                                            style: gothamRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions.FONT_L,
                                            ),
                                          ) : Text(
                                            "${withHoldingTax3.toStringAsFixed(2)} ${Constant.euroSign}",
                                            style: gothamRegular.copyWith(
                                              color: Colors.black,
                                              fontSize: Dimensions.FONT_L,
                                            ),
                                          ),
                                          const SizedBox(height: Dimensions.PADDING_S),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.PADDING_S),
                              ],
                            ),
                          ],
                        ) : Container(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: Dimensions.PADDING_M,
          left: Dimensions.PADDING_L,
          right: Dimensions.PADDING_L,
          child: Container(
            height: 45.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(AllColors.colorBlue),
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        FocusScopeNode currentFocus=FocusScope.of(context);
                        if(!currentFocus.hasPrimaryFocus){
                          currentFocus.unfocus();
                        }
                        setState(() {
                          _selectIndex = 0;
                          _tabController.index = 0;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        height: 45.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              Constant.LANG == Constant.EN
                                  ? ENG.CREATE_INVOICE_BUTTON_BACKWARD
                                  : IT.CREATE_INVOICE_BUTTON_BACKWARD,
                              textAlign: TextAlign.center,
                              style: gothamRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.FONT_L.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 25.h,
                    width: 1.w,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        FocusScopeNode currentFocus=FocusScope.of(context);
                        if(!currentFocus.hasPrimaryFocus){
                          currentFocus.unfocus();
                        }
                        setState(() {
                          _selectIndex = 2;
                          _tabController.index = 2;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.only(right: 10),
                        alignment: Alignment.center,
                        height: 45.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN
                                  ? ENG.CREATE_INVOICE_BUTTON_FORWARD
                                  : IT.CREATE_INVOICE_BUTTON_FORWARD,
                              textAlign: TextAlign.center,
                              style: gothamRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.FONT_L.sp),
                            ),
                            SizedBox(
                              width: Dimensions.PADDING_XS.w,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget productListTab() {
    return Stack(
      children: [
        productList.isEmpty ? Container(
          margin: EdgeInsets.only(bottom: 70.0.h),
          child: Column(
            children: [
              SizedBox(height: 50.h),
              Center(child: SvgPicture.asset(Images.product_icon)),
              SizedBox(height: 35.h),
              Text(
                Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_NO_PRODUCTS: IT.CREATE_INVOICE_TAB_3_NO_PRODUCTS,
                style: gothamBold.copyWith(
                  color: const Color(AllColors.colorText),
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h),
              SizedBox(
                width: 250.w,
                child: Text(
                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_SELECT_AN_EXISTING_PRODUCT_OR_CREATE_A_NEW_ONE: IT.CREATE_INVOICE_TAB_3_SELECT_AN_EXISTING_PRODUCT_OR_CREATE_A_NEW_ONE,
                  textAlign: TextAlign.center,
                  style: gothamRegular.copyWith(
                    color: const Color(AllColors.colorText),
                    fontSize: Dimensions.FONT_L,
                  ),
                ),
              ),
              SizedBox(height: 25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AllColors.colorBlue), //button's fill color
                      elevation: 4.0, //buttons Material shadow
                      textStyle: gothamRegular.copyWith(color: Colors.white), //specify the button's text TextStyle
                      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 8.0, left: 8.0), //specify the button's Padding
                      minimumSize: const Size(180, 40), //specify the button's first: width and second: height
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular( Dimensions.RADIUS_M.r)), // set the buttons shape. Make its birders rounded etc
                      enabledMouseCursor: MouseCursor.defer, //used to construct ButtonStyle.mouseCursor
                      disabledMouseCursor: MouseCursor.uncontrolled, //used to construct ButtonStyle.mouseCursor
                      visualDensity: const VisualDensity(horizontal: 0.0, vertical: 0.0), //set the button's visual density
                      tapTargetSize: MaterialTapTargetSize.padded, // set the MaterialTapTarget size. can set to: values, padded and shrinkWrap properties
                      animationDuration: const Duration(milliseconds: 100), //the buttons animations duration
                      enableFeedback: true, //to set the feedback to true or false
                      alignment: Alignment.center, //set the button's child Alignment
                    ),
                    onPressed: () async {
                      var productResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return AddNewProductScreen();
                      },
                      ));

                      setState(() {
                        debugPrint("$TAG product data =====> $productResult");
                        if(productResult != null) {
                          productList.add(productResult);
                          cashTotalWithVatCalculation();
                        }
                      });
                    }, //set both onPressed and onLongPressed to null to see the disabled properties
                    child: Text(
                      Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_NEW_BUTTON: IT.CREATE_INVOICE_TAB_3_NEW_BUTTON,
                      textAlign: TextAlign.center,
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.PADDING_M,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AllColors.colorBlue), //button's fill color
                        elevation: 4.0, //buttons Material shadow
                        textStyle: gothamRegular.copyWith(color: Colors.white), //specify the button's text TextStyle
                        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 8.0, left: 8.0), //specify the button's Padding
                        minimumSize: const Size(180, 40), //specify the button's first: width and second: height
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular( Dimensions.RADIUS_M.r)), // set the buttons shape. Make its birders rounded etc
                        enabledMouseCursor: MouseCursor.defer, //used to construct ButtonStyle.mouseCursor
                        disabledMouseCursor: MouseCursor.uncontrolled, //used to construct ButtonStyle.mouseCursor
                        visualDensity: const VisualDensity(horizontal: 0.0, vertical: 0.0), //set the button's visual density
                        tapTargetSize: MaterialTapTargetSize.padded, // set the MaterialTapTarget size. can set to: values, padded and shrinkWrap properties
                        animationDuration: const Duration(milliseconds: 100), //the buttons animations duration
                        enableFeedback: true, //to set the feedback to true or false
                        alignment: Alignment.center, //set the button's child Alignment
                      ),
                      onPressed: () async {
                        productResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const SearchProductScreen();
                        },
                        ));

                        setState(() {
                          debugPrint("$TAG product data =====> $productResult");
                          if(productResult != null) {
                            productList.add(productResult);
                            cashTotalWithVatCalculation();
                          }
                        });
                      }, //set both onPressed and onLongPressed to null to see the disabled properties
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_EXISTING_BUTTON: IT.CREATE_INVOICE_TAB_3_EXISTING_BUTTON,
                        textAlign: TextAlign.center,
                        style: gothamRegular.copyWith(
                          fontSize: Dimensions.PADDING_M,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ),
                ],
              ),
            ],
          ),
        ) :
        Container(
          padding: const EdgeInsets.fromLTRB(3.0, 7.0, 3.0, 50.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AllColors.colorBlue), //button's fill color
                      elevation: 4.0, //buttons Material shadow
                      textStyle: gothamRegular.copyWith(color: Colors.white), //specify the button's text TextStyle
                      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 8.0, left: 8.0), //specify the button's Padding
                      minimumSize: const Size(180, 40), //specify the button's first: width and second: height
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular( Dimensions.RADIUS_M.r)), // set the buttons shape. Make its birders rounded etc
                      enabledMouseCursor: MouseCursor.defer, //used to construct ButtonStyle.mouseCursor
                      disabledMouseCursor: MouseCursor.uncontrolled, //used to construct ButtonStyle.mouseCursor
                      visualDensity: const VisualDensity(horizontal: 0.0, vertical: 0.0), //set the button's visual density
                      tapTargetSize: MaterialTapTargetSize.padded, // set the MaterialTapTarget size. can set to: values, padded and shrinkWrap properties
                      animationDuration: const Duration(milliseconds: 100), //the buttons animations duration
                      enableFeedback: true, //to set the feedback to true or false
                      alignment: Alignment.center, //set the button's child Alignment
                    ),
                    onPressed: () async {
                      var productResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return AddNewProductScreen();
                      },
                      ));

                      setState(() {
                        debugPrint("$TAG product data =====> $productResult");
                        if(productResult != null) {
                          productList.add(productResult);
                          cashTotalWithVatCalculation();

                        }
                      });
                    }, //set both onPressed and onLongPressed to null to see the disabled properties
                    child: Text(
                      Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_NEW_BUTTON: IT.CREATE_INVOICE_TAB_3_NEW_BUTTON,
                      textAlign: TextAlign.center,
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.PADDING_M,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AllColors.colorBlue), //button's fill color
                      elevation: 4.0, //buttons Material shadow
                      textStyle: gothamRegular.copyWith(color: Colors.white), //specify the button's text TextStyle
                      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 8.0, left: 8.0), //specify the button's Padding
                      minimumSize: const Size(180, 40), //specify the button's first: width and second: height
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular( Dimensions.RADIUS_M.r)), // set the buttons shape. Make its birders rounded etc
                      enabledMouseCursor: MouseCursor.defer, //used to construct ButtonStyle.mouseCursor
                      disabledMouseCursor: MouseCursor.uncontrolled, //used to construct ButtonStyle.mouseCursor
                      visualDensity: const VisualDensity(horizontal: 0.0, vertical: 0.0), //set the button's visual density
                      tapTargetSize: MaterialTapTargetSize.padded, // set the MaterialTapTarget size. can set to: values, padded and shrinkWrap properties
                      animationDuration: const Duration(milliseconds: 100), //the buttons animations duration
                      enableFeedback: true, //to set the feedback to true or false
                      alignment: Alignment.center, //set the button's child Alignment
                    ),
                    onPressed: () async {
                      productResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const SearchProductScreen();
                      },
                      ));

                      setState(() {
                        debugPrint("$TAG product data =====> $productResult");
                        if(productResult != null) {
                          productList.add(productResult);
                          cashTotalWithVatCalculation();
                        }
                      });
                    }, //set both onPressed and onLongPressed to null to see the disabled properties
                    child: Text(
                      Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_EXISTING_BUTTON: IT.CREATE_INVOICE_TAB_3_EXISTING_BUTTON,
                      textAlign: TextAlign.center,
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.PADDING_M,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: productList.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1, color: Color(AllColors.colorLightGrey),);
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        var productResult = await Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return EditProductInfoScreen(productInfo: productList[index], isAddProduct: false, index: index);
                          },
                        ));

                        setState(() {
                          if(productResult != null) {
                            debugPrint("$TAG latest data =======> $productResult");
                            productList.removeAt(int.parse(productResult["position"].toString()));
                            productList.insert(int.parse(productResult["position"].toString()), productResult["productData"]);
                            cashTotalWithVatCalculation();
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(3.0, 7.0, 3.0, 3.0),
                        color:  Colors.white,
                        child: Slidable(
                          enabled: true,
                          direction: Axis.horizontal,
                          endActionPane: ActionPane(
                            extentRatio: 0.25,
                            motion: const ScrollMotion(),
                            children: [
                              CustomSlidableAction(
                                backgroundColor: const Color(AllColors.swipeDelete),
                                //label: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_DELETE_BUTTON: IT.CREATE_INVOICE_TAB_3_DELETE_BUTTON,
                                onPressed: (context) {
                                  setState(() {
                                    productList.removeAt(index);
                                    cashTotalWithVatCalculation();
                                  });
                                },
                                child: SvgPicture.asset(
                                  Images.swipeDeleteIcon,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // commented by nilesh 17/11/2022 for description and price textfield
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                      child: Text(
                                        "${productList[index]["description"]}",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: gothamRegular.copyWith(
                                            color: const Color(
                                                AllColors.colorText),
                                            overflow:
                                            TextOverflow.ellipsis,
                                            fontSize: Dimensions.FONT_M,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                    child: Text(
                                      "${productList[index]["price"]} ${Constant.euroSign}",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: gothamRegular.copyWith(
                                          color: const Color(
                                              AllColors.colorText),
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: Dimensions.FONT_M,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                              // commented by nilesh 17/11/2022 for code, vat and discount textfield
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  if(productList[index]["product_code"] != null && productList[index]["product_code"] != "")
                                    Container(
                                      padding: const EdgeInsets.fromLTRB( Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                      child: Text(
                                        "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_CODE: IT.CREATE_INVOICE_TAB_3_CODE} ${productList[index]["product_code"]}",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorText),
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: Dimensions.FONT_S,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                  if(productList[index]["vat_display"] != null && productList[index]["vat_display"] != "")
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                        child: Text(
                                          "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_VAT: IT.CREATE_INVOICE_TAB_3_VAT} ${productList[index]["vat_display"]}",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: gothamRegular.copyWith(
                                              color: const Color(AllColors.colorText),
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: Dimensions.FONT_S,
                                              letterSpacing: 0.5),
                                        ),
                                      ),
                                    ),
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                      child: Row(
                                          children:[
                                            Text(
                                              productList[index]["tarifDiscount"] == null || productList[index]
                                              ["tarifDiscount"] == "" ? " 0" : " ${productList[index]["tarifDiscount"]}",
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: gothamRegular.copyWith(
                                                  color: const Color(AllColors.colorText),
                                                  overflow: TextOverflow.ellipsis,
                                                  fontSize: Dimensions.FONT_S,
                                                  letterSpacing: 0.5
                                              ),
                                            ),
                                            const SizedBox(width: Dimensions.PADDING_XS),
                                            Image.asset(
                                              Images.discount,
                                              width:15,
                                              height:15,
                                              color: const Color(AllColors.colorText),
                                            ),
                                          ]
                                      )
                                  ),
                                ],
                              ),
                              // commented by nilesh 17/11/2022 for quantity, unit and total textfield
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                    child: Text(
                                      productList[index]["quantity"] ==
                                          "0"
                                          ? "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_QUANTITY: IT.CREATE_INVOICE_TAB_3_QUANTITY} 1"
                                          : "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_QUANTITY: IT.CREATE_INVOICE_TAB_3_QUANTITY} ${productList[index]["quantity"]}",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: gothamRegular.copyWith(
                                          color: const Color(
                                              AllColors.colorText),
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: Dimensions.FONT_S,
                                          //      fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                      child: Text(
                                        "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_UNIT: IT.CREATE_INVOICE_TAB_3_UNIT} ${productList[index]["unit_display"]}",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: gothamRegular.copyWith(
                                            color: const Color(
                                                AllColors.colorText),
                                            overflow:
                                            TextOverflow.ellipsis,
                                            fontSize: Dimensions.FONT_S,
                                            //      fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                    child: Text(
                                      productList[index]["total"] == null || productList[index]["total"] == ""
                                          ? "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_TOTAL: IT.CREATE_INVOICE_TAB_3_TOTAL} 0.00 ${Constant.euroSign}"
                                          : "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_TOTAL: IT.CREATE_INVOICE_TAB_3_TOTAL} ${productList[index]["total"] } ${Constant.euroSign}",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: gothamRegular.copyWith(
                                          color: const Color(
                                              AllColors.colorText),
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: Dimensions.FONT_S,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5),
                                    ),
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
            ],
          ),
        ),
        // comment by nilesh 14-11-2022 backwards & come on button
        Positioned(
          bottom: Dimensions.PADDING_M,
          left: Dimensions.PADDING_L,
          right: Dimensions.PADDING_L,
          child: Container(
            height: 45.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(AllColors.colorBlue),
              borderRadius: BorderRadius.circular( Dimensions.RADIUS_M.r),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.center,
                        height: 45.h,
                        child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_BUTTON_BACKWARD: IT.CREATE_INVOICE_BUTTON_BACKWARD,
                                textAlign: TextAlign.center,
                                style: gothamRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.FONT_L.sp),
                              ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectIndex = 1;
                              _tabController.index = 1;
                            });
                          },
                        )
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 25.h,
                    width: 1.w,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      alignment: Alignment.center,
                      height: 45.h,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectIndex = 3;
                            _tabController.index = 3;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_BUTTON_FORWARD: IT.CREATE_INVOICE_BUTTON_FORWARD,
                              textAlign: TextAlign.center,
                              style: gothamRegular.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.FONT_L.sp
                              ),
                            ),
                            SizedBox(width:Dimensions.PADDING_XS.w,),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        // comment by nilesh 14-11-2022 backwards & come on button
      ],
    );
  }

  Widget createInvoicePaymentTab() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(3.0, 7.0, 3.0, 100.0),
          margin: const EdgeInsets.all(Dimensions.PADDING_M),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_PAYMENT_METHOD: IT.CREATE_INVOICE_TAB_4_PAYMENT_METHOD,
                    style: gothamRegular.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L.sp,
                    ),
                  ),
                  Visibility(
                    visible: reCalculate,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          reCalculate = false;
                          reCalculatePayment();
                        });
                      },
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_RE_CALCULATE: IT.CREATE_INVOICE_TAB_4_RE_CALCULATE,
                        style: gothamRegular.copyWith(
                          color: Colors.blue,
                          fontSize: Dimensions.FONT_L.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.PADDING_M.h,),
              Theme(
                data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: modeController,
                  readOnly: true,
                  onTap: () async {
                    var paymentMethodResult = await Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const SelectPaymentMethodScreen();
                      },
                    ));
                    setState(() {
                      if (paymentMethodResult != null) {
                        modeController.text = paymentMethodResult["name"];
                        paymentMethodId = paymentMethodResult["id"];
                        debugPrint("$TAG selected payment method id ======> ${paymentMethodId.toString()}");
                        // comment by nilesh on 28-11-2022 to load user preference based on customer id
                        //getCustomerPreferenceList();
                        getPaymentTypesWithId();

                      }
                    });
                  },
                  style: gothamRegular.copyWith(
                    color: const Color(AllColors.color),
                    fontSize: Dimensions.FONT_L,
                  ),
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.arrow_forward_ios),
                    hintText:   Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_PAYMENT_METHOD: IT.CREATE_INVOICE_TAB_4_PAYMENT_METHOD,
                    hintStyle: gothamRegular.copyWith(
                      color: const Color(AllColors.colorDocumentText),
                      fontSize: Dimensions.FONT_L,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: REdgeInsets.fromLTRB(20, 15, 15, 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular( Dimensions.RADIUS_M.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular( Dimensions.RADIUS_M.r),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: paymentDataList.isEmpty ? Container() : ListView.separated(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: paymentDataList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(height: 1, color: Colors.black54,);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () async {
                        var paymentResult = await Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return EditPaymentScreen(paymentModel: paymentDataList[index], index: index);
                          },
                        ));
                        setState(() {
                          if (paymentResult != null) {
                            reCalculate = false;
                            debugPrint("$TAG payment edit data =======> ${paymentResult.toString()}");
                            PaymentModel model = paymentResult["paymentResult"] as PaymentModel;
                            debugPrint("$TAG payment model =======> ${model.toMap()}");
                            paymentDataList.removeAt(paymentResult["index"]);
                            paymentDataList.insert(paymentResult["index"], model);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                        color: Colors.white,
                        child: Slidable(
                          enabled: true,
                          direction: Axis.horizontal,
                          endActionPane: ActionPane(
                            extentRatio: 0.25,
                            motion: const ScrollMotion(),
                            children: [
                              CustomSlidableAction(
                                backgroundColor: const Color(AllColors.swipeDelete),
                                onPressed: (context) {
                                  setState(() {
                                    paymentDataList.removeAt(index);
                                    reCalculate = true;
                                  });
                                },
                                child: SvgPicture.asset(
                                  Images.swipeDeleteIcon,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // commented by nilesh 23/11/2022 for description and date textfield
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        paymentDataList[index].date,
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
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      "${paymentDataList[index].amount} ${Constant.euroSign}",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorText),
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: Dimensions.FONT_M,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // commented by nilesh 23/11/2022 for Account and Coord textfield
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (paymentDataList[index].id != null && paymentDataList[index].id != "")
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_ACCOUNT: IT.CREATE_INVOICE_TAB_4_ACCOUNT} ${paymentDataList[index].walletType}",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorText),
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: Dimensions.FONT_S,
                                            letterSpacing: 0.5
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                      child: Text(
                                        "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_COORD: IT.CREATE_INVOICE_TAB_4_COORD} ${paymentDataList[index].coOrd}",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorText),
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: Dimensions.FONT_S,
                                            letterSpacing: 0.5
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // commented by nilesh 23/11/2022 for mode textfield
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if(paymentDataList[index].mode != null && paymentDataList[index].mode != "")
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_MODE: IT.CREATE_INVOICE_TAB_4_MODE} ${paymentDataList[index].mode}",
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          style: gothamRegular.copyWith(
                                              color: const Color(AllColors.colorText),
                                              overflow: TextOverflow.ellipsis,
                                              fontSize: Dimensions.FONT_S,
                                              letterSpacing: 0.5
                                          ),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              paymentDataList[index].isPaid = !paymentDataList[index].isPaid;
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 23.h,
                                            width: 23.w,
                                            decoration: BoxDecoration(
                                              color: paymentDataList[index].isPaid ? const Color(AllColors.colorBlue) : Colors.white,
                                              borderRadius: BorderRadius.circular(3.r),
                                              border: Border.all(
                                                  width: 1.5.w,
                                                  color: const Color(AllColors.colorBlue)
                                              ),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.only(bottom: 5),
                                              child: Icon(
                                                Icons.check,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.PADDING_XS,),
                                        Text(
                                          Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_PAID: IT.CREATE_INVOICE_TAB_4_PAID,
                                          style: gothamRegular.copyWith(
                                              fontSize: Dimensions.FONT_S,
                                              color: const Color(AllColors.colorText)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if(paymentDataList[index].refPG != null && paymentDataList[index].refPG != "")
                                Container(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_REFPG: IT.CREATE_INVOICE_TAB_4_REFPG} ${paymentDataList[index].refPG.substring(0,12)}",
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: Dimensions.FONT_S,
                                        letterSpacing: 0.5
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: Dimensions.PADDING_M,
          left: Dimensions.PADDING_L,
          right: Dimensions.PADDING_L,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AllColors.colorBlue),
                      elevation: 4.0,
                      textStyle:
                      gothamRegular.copyWith(color: Colors.white),
                      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 8.0, left: 8.0),
                      minimumSize: const Size(180, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      enabledMouseCursor: MouseCursor.defer,
                      disabledMouseCursor: MouseCursor.uncontrolled,
                      visualDensity: const VisualDensity(horizontal: 0.0, vertical: 0.0),
                      tapTargetSize: MaterialTapTargetSize.padded,
                      animationDuration: const Duration(milliseconds: 100),
                      enableFeedback: true,
                      alignment: Alignment.center,
                    ),
                    onPressed: () async {
                      paymentResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return AddDeadlineScreen(subTotal: subTotal,);
                      },
                      ));
                      setState(() {
                        if (paymentResult != null) {
                          //reCalculate = true;
                          PaymentModel model = paymentResult as PaymentModel;
                          debugPrint("$TAG product data =====> ${model.toMap()}");
                          updatePaymentCalculation(model);
                        }
                      });
                    },
                    //set both onPressed and onLongPressed to null to see the disabled properties
                    child: Text(
                      Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_ADD_DEADLINE: IT.CREATE_INVOICE_TAB_4_ADD_DEADLINE,
                      textAlign: TextAlign.center,
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.PADDING_M,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text("${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_TOTAL: IT.CREATE_INVOICE_TAB_4_TOTAL} ${totalToShow.toStringAsFixed(2)} ${Constant.euroSign}",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: gothamRegular.copyWith(
                      color: const Color(AllColors.colorText),
                      overflow: TextOverflow.ellipsis,
                      fontSize: Dimensions.FONT_L,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox( height: Dimensions.PADDING_S.h,),
              Container(
                height: 45.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(AllColors.colorBlue),
                  borderRadius: BorderRadius.circular( Dimensions.RADIUS_M.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectIndex = 2;
                              _tabController.index = 2;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            alignment: Alignment.center,
                            height: 45.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_BUTTON_BACKWARD: IT.CREATE_INVOICE_BUTTON_BACKWARD,
                                  textAlign: TextAlign.center,
                                  style: gothamRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.FONT_L.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 25.h,
                        width: 1.w,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            tabValue==false?  setState(() {
                              _selectIndex = 3;
                              _tabController.index = 3;
                            }):setState(() {
                              _selectIndex = 4;
                              _tabController.index = 4;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                            alignment: Alignment.center,
                            height: 45.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_BUTTON_FORWARD: IT.CREATE_INVOICE_BUTTON_FORWARD,
                                  textAlign: TextAlign.center,
                                  style: gothamRegular.copyWith(
                                      color: Colors.white,
                                      fontSize: Dimensions.FONT_L.sp),
                                ),
                                SizedBox(width: Dimensions.PADDING_XS.w,),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createInvoiceSdiTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.all(Dimensions.PADDING_L),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Dimensions.PADDING_S,
            Dimensions.PADDING_L,
            Dimensions.PADDING_S,
            Dimensions.PADDING_L,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipient code
              Text(
                Constant.LANG == Constant.EN
                    ? ENG.CREATE_INVOICE_TAB_5_RECIPIENT_CODE
                    : IT.CREATE_INVOICE_TAB_5_RECIPIENT_CODE,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: recepientNameController,
                  keyboardType: TextInputType.name,
                  autofocus: false,
                  style: gothamRegular.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: const EdgeInsets.only(
                        left: Dimensions.PADDING_S,
                        bottom: 8.0,
                        top: 8.0,
                        right: Dimensions.PADDING_S),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),
              // PEC number TextFiled
              Text(
                Constant.LANG == Constant.EN
                    ? ENG.CREATE_INVOICE_TAB_5_PEC
                    : IT.CREATE_INVOICE_TAB_5_PEC,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context)
                    .copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: pecController,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  style: gothamRegular.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: const EdgeInsets.only(
                        left: Dimensions.PADDING_S,
                        bottom: 8.0,
                        top: 8.0,
                        right: Dimensions.PADDING_S),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),
              // E Invoice Typology
              Text(
                Constant.LANG == Constant.EN
                    ? ENG.CREATE_INVOICE_TAB_5_INVOICE_TYPOLOGY
                    : IT.CREATE_INVOICE_TAB_5_INVOICE_TYPOLOGY,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: einvoiceTypologyController,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  style: gothamRegular.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: const EdgeInsets.only(
                        left: Dimensions.PADDING_S,
                        bottom: 8.0,
                        top: 8.0,
                        right: Dimensions.PADDING_S),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),
              // Document Number
              Text(
                Constant.LANG == Constant.EN
                    ? ENG.CREATE_INVOICE_TAB_5_DOCUMENT_NUMBER
                    : IT.CREATE_INVOICE_TAB_5_DOCUMENT_NUMBER,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: documentNumberSDIController,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  style: gothamRegular.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: const EdgeInsets.only(
                        left: Dimensions.PADDING_S,
                        bottom: 8.0,
                        top: 8.0,
                        right: Dimensions.PADDING_S),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),

              //CUP Code
              Text(
                Constant.LANG == Constant.EN
                    ? ENG.CREATE_INVOICE_TAB_5_CUP_CODE
                    : IT.CREATE_INVOICE_TAB_5_CUP_CODE,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: cupCodeController,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  style: gothamRegular.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: const EdgeInsets.only(
                        left: Dimensions.PADDING_S,
                        bottom: 8.0,
                        top: 8.0,
                        right: Dimensions.PADDING_S),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),
              // CIG Code
              Text(
                Constant.LANG == Constant.EN
                    ? ENG.CREATE_INVOICE_TAB_5_CIG_CODE
                    : IT.CREATE_INVOICE_TAB_5_CIG_CODE,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: cigCodeController,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  style: gothamRegular.copyWith(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: const EdgeInsets.only(
                        left: Dimensions.PADDING_S,
                        bottom: 8.0,
                        top: 8.0,
                        right: Dimensions.PADDING_S),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_L.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),

              //Evaluate
              Text(
                Constant.LANG == Constant.EN
                    ? ENG.CREATE_INVOICE_TAB_5_EVALUATE
                    : IT.CREATE_INVOICE_TAB_5_EVALUATE,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  hintColor: const Color(0xFFbdc6cf),
                ),
                child: TextField(
                  controller: evaluateController,
                  readOnly: true,
                  autofocus: false,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),

                  onTap: () async {
                    var     vatResult = await Navigator.push(
                        context, MaterialPageRoute(
                      builder: (context) {
                        return SelectVatTypeScreen();
                      },
                    ));

                    // debugPrint(
                    //     "$TAG filterVatResult ======> $vatResult");

                    setState(() {
                      if (vatResult != null) {
                        // vatController.text =
                        // vatResult["name"];
                        // selectedVatValue =
                        //     vatResult["value"]
                        //         .toString();
                      }
                    });
                  },

                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.arrow_forward_ios),
                    hintText:
                    Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_5_EVALUATE : IT.CREATE_INVOICE_TAB_5_EVALUATE,
                    helperStyle:
                    gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                    ),
                  ),

                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),
              //TermsOfPayment
              Text(
                Constant.LANG == Constant.EN
                    ? ENG.CREATE_INVOICE_TAB_5_TERMS_OF_PAYMENT
                    : IT.CREATE_INVOICE_TAB_5_TERMS_OF_PAYMENT,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  hintColor: const Color(0xFFbdc6cf),
                ),
                child: TextField(
                  controller: termsOfPaymentController,
                  readOnly: true,
                  autofocus: false,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),

                  onTap: () async {
                    var     vatResult = await Navigator.push(
                        context, MaterialPageRoute(
                      builder: (context) {
                        return SelectVatTypeScreen();
                      },
                    ));
                  },

                  decoration: InputDecoration(
                    suffixIcon: const Icon(
                        Icons.arrow_forward_ios),
                    hintText:
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_5_TERMS_OF_PAYMENT
                        : IT.CREATE_INVOICE_TAB_5_TERMS_OF_PAYMENT,
                    helperStyle:
                    gothamRegular.copyWith(
                        fontSize:
                        Dimensions.FONT_S.sp),
                    filled: true,
                    fillColor:
                    const Color(0xFFF1F1F1),
                    contentPadding:
                    REdgeInsets.fromLTRB(
                        20, 15, 0, 0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(
                          Dimensions.RADIUS_M.r),
                    ),
                    enabledBorder:
                    UnderlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.white),
                      borderRadius:
                      BorderRadius.circular(
                          Dimensions.RADIUS_M.r),
                    ),
                  ),

                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),
              //VAT CHARGEABILITY
              Text(
                Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_5_VAT_CHARGEABILITY : IT.CREATE_INVOICE_TAB_5_VAT_CHARGEABILITY,
                style: gothamRegular.copyWith(
                  color: Colors.black,
                  fontSize: Dimensions.FONT_L,
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS),
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  hintColor: const Color(0xFFbdc6cf),
                ),
                child: TextField(
                  controller: vatChargebilityController,
                  readOnly: true,
                  autofocus: false,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),

                  onTap: () async {

                  },

                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.arrow_forward_ios),
                    hintText:
                    Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_5_VAT_CHARGEABILITY : IT.CREATE_INVOICE_TAB_5_VAT_CHARGEABILITY,
                    helperStyle:
                    gothamRegular.copyWith(fontSize: Dimensions.FONT_S.sp),
                    filled: true,
                    fillColor:
                    const Color(0xFFF1F1F1),
                    contentPadding: REdgeInsets.fromLTRB(20, 15, 0, 0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_M.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),

              // CAUSAL
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_5_CAUSAL : IT.CREATE_INVOICE_TAB_5_CAUSAL,
                    style: gothamRegular.copyWith(
                      color: Colors.black,
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  Theme(
                    data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                    child: TextField(
                      controller: causalController,
                      keyboardType: TextInputType.text,
                      autofocus: false,
                      style: gothamRegular.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF1F1F1),
                        contentPadding: const EdgeInsets.only(
                            left: Dimensions.PADDING_S,
                            bottom: 8.0,
                            top: 8.0,
                            right: Dimensions.PADDING_S),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: Dimensions.PADDING_L.h,),
            ],
          ),
        ),
      ),
    );
  }

  void getVatValues() {
    // https://devapi.paciolo.it/vats?type=document

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getDocumentVats}?type=document",
        token: userModel!.authorization,
        responseCode: GET_DOCUMENT_VATS,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  void getWithHoldingValues() {
    // https://devapi.paciolo.it/helper/with_holding

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getWithHoldings,
        token: userModel!.authorization,
        responseCode: GET_WITH_HOLDINGS,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  void getDocumentTypes() {
    // https://devapi.paciolo.it/document/types?doc_type=Fattura

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getDocumentTypes}?doc_type=$documentType",
        token: userModel!.authorization,
        responseCode: GET_DOCUMENT_TYPES,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  void getDocumentNumbers(bool show) {
    // https://devapi.paciolo.it/document/get-document-number?suffix=THT&year=&doctype=Fattura
    setState(() {
      if(show) {
        showLoader = show;
      }
    });

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getDocumentNumber}?suffix=${currentCompany!.defaultNumeration}&year=&doctype=$documentType",
        token: userModel!.authorization,
        responseCode: GET_DOCUMENT_NUMBER,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  void getDocumentTypeName() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getInvoiceDocFilter,
        token: userModel!.authorization,
        responseCode: GET_DOCUMENT_FILTER_TYPES,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  void getMeasuringUnit() {
    // https://devapi.paciolo.it/product/measure_unit
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getMeasureUnit,
        token: userModel!.authorization,
        responseCode: GET_MEASURE_UNIT,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  void getPaymentTypesWithId() {
    // https://devapi.paciolo.it/payment/types
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getPaymentMethodType}/${paymentMethodId.toString()}",
        token: userModel!.authorization,
        responseCode: GET_PAYMENT_METHOD_WITH_ID,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  void getPaymentMode() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getPaymentModeType,
        token: userModel!.authorization,
        responseCode: GET_PAYMENT_MODE,
        companyId: currentCompany!.id);
    request.setListener(this);

  }

  void getWalletList() {
    // https://devapi.paciolo.it/agent/popup
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getWalletList}?is_open_banking=0",
        token: userModel!.authorization,
        responseCode: GET_WALLET_LIST,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  void getCustomerPreferenceList() {
    setState(() {
      showLoader = true;
    });
    var cmdUrl = "";
    if(customerDataResult == null) {
      cmdUrl = "${RequestCmd.getCustomerDocPreference}?customer_id=null";
    } else {
      cmdUrl = "${RequestCmd.getCustomerDocPreference}?customer_id=${customerDataResult["id"]}";
    }
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: cmdUrl,
        token: userModel!.authorization,
        responseCode: GET_CUSTOMER_PREF_LIST,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  @override
  void onFailed(response, statusCode) {
    setState(() {
      showLoader = false;
      if (statusCode != null && statusCode == 401) {
        Utility.clearPreference();
        Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.SESSION_EXPIRED : IT.SESSION_EXPIRED);
      }
    });
    if (statusCode != null && statusCode == 401) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen(),
      ), (route) => false,
      );
    }
  }

  @override
  void onSuccess(response, responseCode) {
    if (responseCode == GET_PAYMENT_METHOD_WITH_ID ) {
      setState(() {
        debugPrint("$TAG GET_PAYMENT_METHOD_WITH_ID ======> ${response[Constant.data]["result"]}");
        //paypal_pay_check = response[Constant.data]["result"]["paypal_pay_check"] == "0" ? false : true;
        //payment_mode = response[Constant.data]["result"]["payment_mode"];

        //debugPrint("$TAG paypal_pay_check ======> ${paypal_pay_check.toString()}");
        paymentMethodList.clear();

        for (int i = 0; i < response[Constant.data]["result"]["paymentDeadLines"].length; i++) {
          paymentMethodList.add(response[Constant.data]["result"]["paymentDeadLines"][i]);
        }
        paymentCalculation();
        showLoader = false;
        debugPrint("$TAG GET_PAYMENT_METHOD_WITH_ID ======> ${paymentMethodList.length}");
      });
    } else if (responseCode == GET_CUSTOMER_PREF_LIST) {
      debugPrint("$TAG GET GET_CUSTOMER_PREF_LIST ========> ${response[Constant.data]}");
      setState(() {
        showLoader = false;
        for (int i = 0; i < response[Constant.data].length; i++) {
          customerPrefId = response[Constant.data][i]["wallet_id"];
          payment_mode = response[Constant.data][i]["payment_mode"];

          debugPrint("$TAG GET customerPrefList Wallet ID ========> $customerPrefId");
          debugPrint("$TAG GET customerPrefList payment_mode ========> $payment_mode");
        }

        getWalletList();
        getMeasuringUnit();

      });
    } else if (responseCode == GET_WALLET_LIST) {

      debugPrint("$TAG GET WALLET LIST ========> ${response[Constant.data]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data].length; i++) {
          walletList.add(response[Constant.data][i]);
        }
      });
    } else if (responseCode == GET_PAYMENT_MODE) {
      debugPrint("$TAG GET PAYMENT MODE LIST =====> ${response[Constant.data]}");
      setState(() {
        showLoader = false;
        for (int i = 0; i < response[Constant.data].length; i++) {
          paymentModeList.add(response[Constant.data][i]);
        }
        debugPrint("$TAG GET PAYMENT MODE LIST LENGTH =====> ${paymentModeList.toString()}");
      });
    } else if (GET_DOCUMENT_FILTER_TYPES == responseCode) {
      setState(() {
        showLoader = false;
        lastDocumentLoadedId = currentCompany!.lastTypeOfDocumentLoadedId;
        documentTypeList.clear();
        for (int i = 0; i < response[Constant.data].length; i++) {
          documentTypeList.add(response[Constant.data][i]);
          if (lastDocumentLoadedId == response[Constant.data][i]["id"]) {
            debugPrint("$TAG current Company Document Loaded Id ======> ${response[Constant.data][i]["id"]}");
            debugPrint("$TAG last Document Loaded Id ======> $lastDocumentLoadedId");
            documentType = response[Constant.data][i]["name"];
            break;
          } else {
            documentType = response[Constant.data][0]["name"];
          }
        }
        getVatValues();
        getWithHoldingValues();
        getDocumentNumbers(true);
        getDocumentTypes();
      });
    } else if (GET_DOCUMENT_VATS == responseCode) {
      setState(() {
        debugPrint("$TAG GET_DOCUMENT_VATS (pension fund) list ======> ${response[Constant.data]["list"]}");
        debugPrint("$TAG GET_DOCUMENT_VATS list ======> ${response[Constant.data]["types"]}");
        showLoader = false;
        pensionFundVatList.clear();
        vatTypesDataList.clear();
        for (int i = 0; i < response[Constant.data]["list"].length; i++) {
          if(response[Constant.data]["list"][i]["pension_fund"] == 1) {
            pensionFundVatList.add(response[Constant.data]["list"][i]);
          }
        }
        for (int i = 0; i < response[Constant.data]["types"].length; i++) {
          vatTypesDataList.add(response[Constant.data]["types"][i]);
        }
      });
    } else if (GET_WITH_HOLDINGS == responseCode) {
      setState(() {
        debugPrint("$TAG GET_WITH_HOLDINGS list ======> ${response[Constant.data]["list"]}");
        debugPrint("$TAG GET_WITH_HOLDINGS withHolding ======> ${response[Constant.data]["withHolding"]}");
        withHoldingTaxVisibility = response[Constant.data]["withHolding"][0]["witholding_tax_visibility"];
        showLoader = false;
        withListDataList.clear();
        withHoldingDataList.clear();
        for (int i = 0; i < response[Constant.data]["list"].length; i++) {
          withListDataList.add(response[Constant.data]["list"][i]);
        }
        // for (int i = 0; i < 3; i++) {
        //   reasonForPaymentController[i].text = withListDataList[0]["name"];
        // }
        // selectedreasonForPaymentValue[0].text = withListDataList[0]["Id"].toString();
        // debugPrint("$TAG withHoldingTaxVisibility ${withHoldingTaxVisibility.toString()}");

        for (int i = 0; i < response[Constant.data]["withHolding"].length; i++) {
          withHoldingDataList.add(response[Constant.data]["withHolding"][i]);
        }

        debugPrint("$TAG With Holding count ============> ${withHoldingDataList[0]["witholding_tax_visibility"]}");


      });
    } else if (GET_DOCUMENT_TYPES == responseCode) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG GET_DOCUMENT_TYPES ======> ${response[Constant.data]}");
        documentTypeData = DocumentTypeData.fromJson(response[Constant.data]);
        if(documentTypeData != null && documentTypeData!.data != null) {
          if(documentTypeData!.data!.isSdiBtnEnable! && documentTypeData!.data!.isDocumentEncodingExist!){
            tabValue=true;
          } else {
            tabValue=false;
          }
        } else {
          tabValue=false;
        }
      });
    } else if (GET_DOCUMENT_NUMBER == responseCode) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG GET_DOCUMENT_NUMBER ======> ${response[Constant.data]}");
        documentNumber = response[Constant.data]["document_number"];

        if (documentNumber != null && documentNumber != "") {
          documentNumberController.text = documentNumber.toString();
        } else {
          documentNumberController.text = "";
        }

        if (currentCompany!.defaultNumeration != null && currentCompany!.defaultNumeration != "") {
          documentCodeController.text = currentCompany!.defaultNumeration.toString();
        } else {
          documentCodeController.text = "";
        }
      });
    } else if (GET_MEASURE_UNIT == responseCode) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG GET_MEASURE_UNIT ======> ${response[Constant.data]}");
        measuringUnitList.clear();

        for (int i = 0; i < response[Constant.data]["measurement_unit"].length; i++) {
          measuringUnitList.add(response[Constant.data]["measurement_unit"][i]);
        }
        debugPrint("$TAG GET_MEASURE_UNIT ======> ${measuringUnitList.length}");
      });
    } else if (responseCode == GET_WITHHOLDING_LIST) {

      debugPrint("$TAG GET_WITHHOLDING_LIST ========> ${response[Constant.data]}");
      setState(() {
        showLoader = false;

        for(int i = 0; i < response[Constant.data].length; i++) {
          withHoldingTypeList.add(response[Constant.data][i]);
        }
        // for(int i = 0; i < 3; i++) {
        //   withHoldingTypeController[i].text = withHoldingTypeList[0]["name"];
        // }
        // selectedwithHoldingValue[0].text = withHoldingTypeList[0]["value"].toString();
        // debugPrint("$TAG GET_WITHHOLDING_LIST withHoldingTypeController========> ${withHoldingTypeController[0].text}");

        debugPrint("$TAG GET_WITHHOLDING_LIST With Holding count ============> ${withHoldingDataList[0]["witholding_tax_visibility"]}");

      });
    } else if (SAVE_DOCUMENT == responseCode) {

      setState(() {
        showLoader = false;
        Navigator.of(context).pop();
        Utility.showSuccessToast(Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_ALERT4 : IT.CREATE_INVOICE_TAB_2_ALERT4);

      });
    } else if (SAVE_CUSTOMER == responseCode) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG SAVE_CUSTOMER ========> ${response[Constant.data]}");
        customerDataResult = response[Constant.data];
        saveDocument();
      });
    }
  }

  String calculateDate(days) {
    var date = DateTime.now().add(Duration(days: days));
    debugPrint("$TAG Calculate Date =======> ${date.toString()}");
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(date);
    return formatted.toString();
  }

  void getTotalSum() {
    for (int i = 0; i < productList.length; i++) {
      subTotal = subTotal + double.parse(productList[i]["total"]);
    }
    debugPrint("$TAG subtotal =======> ${subTotal.toString()}");
  }

  String getWalletName(id) {
    debugPrint("$TAG customer pref id =======> $id");
    for(int i = 0; i < walletList.length; i++) {
      if(walletList[i]["id"] == id) {
        debugPrint("$TAG getWalletName =======> ${walletList[i]["id"]}");
        walletName = walletList[i]["name"].toString();
        break;
      }
    }
    return walletName;
  }

  String getCoordName(id) {
    debugPrint("$TAG customer pref id =======> ${id}");
    for(int i = 0; i < walletList.length; i++) {

      if(walletList[i]["id"] == id) {
        debugPrint("$TAG get Co ord Name =======> ${walletList[i]["id"]}");
        coordName = walletList[i]["wallet_coordinate"].toString()=="null"?"":walletList[i]["wallet_coordinate"].toString();
        break;
      }
    }
    return coordName;
  }

  String getPaymentModeName(id) {
    debugPrint("$TAG ======> payment mode name");
    debugPrint("$TAG ======> $id");
    debugPrint("$TAG ======> payment mode length ${paymentModeList.length}");
    for(int i = 0; i < paymentModeList.length; i++) {
      if(paymentModeList[i]["id"] ==id) {
        debugPrint("$TAG ======> payment mode length ${paymentModeList.length}");
        debugPrint("$TAG ======> payment mode id ${paymentModeList[i]["id"]}");
        modeName = paymentModeList[i]["name"].toString();
        break;
      }
    }
    return modeName;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      lastDate: DateTime(2100),
      firstDate: DateTime(2000),
    );
    if (picked != null) {
      setState(() {
        debugPrint("$TAG picked date =======> ${picked.toString()}");
        currentDate = picked;
        debugPrint("$TAG new current date =======> ${currentDate.toString()}");
      });
    }
  }

  void setCustomerData(var result) {
    customerDataResult = result["customer"];
    if(customerDataResult["name"] != null && customerDataResult["name"] != "null") {
      agencyNameController.text = customerDataResult["name"].toString();
    }
    if(customerDataResult["vat_number"] != null && customerDataResult["vat_number"] != "null") {
      vatNumberController.text = customerDataResult["vat_number"].toString();
    }
    if(customerDataResult["fiscal_code"] != null && customerDataResult["fiscal_code"] != "null") {
      fiscalCodeController.text = customerDataResult["fiscal_code"].toString();
    }
    if(customerDataResult["address"] != null && customerDataResult["address"] != "null") {
      addressController.text = customerDataResult["address"].toString();
    }
    if(customerDataResult["address"] != null && customerDataResult["address"] != "null") {
      address2Controller.text = customerDataResult["address2"].toString();
    }
    if(customerDataResult["city"] != null && customerDataResult["city"] != "null") {
      cityController.text = customerDataResult["city"].toString();
    }
    if(customerDataResult["zip"] != null && customerDataResult["zip"] != "null") {
      postalCodeController.text = customerDataResult["zip"].toString();
    }
    if(customerDataResult["country"] != null && customerDataResult["country"] != "null") {
      provinceAbbreviationController.text = customerDataResult["country"].toString();
    }
    if(customerDataResult["state"] != null && customerDataResult["state"] != "null") {
      stateInitialsController.text = customerDataResult["state"].toString();
    }
    if(customerDataResult["recipient_code"] != null && customerDataResult["recipient_code"] != "null") {
      sdiCodeController.text = customerDataResult["recipient_code"].toString();
    }
    if(customerDataResult["email_pec"] != null && customerDataResult["email_pec"] != "null") {
      pecEmailController.text = customerDataResult["email_pec"].toString();
    }
    debugPrint("$TAG customer Data Result =======> $customerDataResult");
  }

  void paymentCalculation() {
    paymentDataList.clear();
    for(int i = 0; i < paymentMethodList.length; i++) {

      PaymentModel model = PaymentModel(
          id: paymentMethodList[i]["id"],
          days: paymentMethodList[i]["days"],
          endMonth: paymentMethodList[i]["end_month"],
          paymentId: paymentMethodList[i]["payment_id"],
          percentage: paymentMethodList[i]["percentage"],
          date: calculateDate(paymentMethodList[i]["days"]),
          walletId: customerPrefId,
          walletType: getWalletName(customerPrefId),
          coOrd: getCoordName(customerPrefId),
          modeId: payment_mode,
          mode: getPaymentModeName(payment_mode),
          refPG: "",
          amount: (totalToShow * (paymentMethodList[i]["percentage"] / 100)).toStringAsFixed(2),
          isPaid: false
      );
      paymentDataList.add(model);
    }
  }

  void reCalculatePayment() {
    int totalPercentage = 100;
    double remainingPercentage = 0.00;








    double availablePercentage = 0.00;
    double totalAmount = subTotal;
    double availableAmount = 0;
    double remainingAmount = 0;

    if(paymentDataList.isNotEmpty) {
      for (int i = 0; i < paymentDataList.length; i++) {
        availablePercentage += double.parse(paymentDataList[i].percentage.toString());
        availableAmount += double.parse(paymentDataList[i].amount);
        debugPrint("$TAG Percentage =========> ${paymentDataList[i].percentage}");
        debugPrint("$TAG Amount =========> ${paymentDataList[i].amount}");
      }

      debugPrint("$TAG availablePercentage =========> $availablePercentage");
      debugPrint("$TAG availableAmount =========> $availableAmount");

      remainingPercentage = totalPercentage - availablePercentage;
      remainingAmount = totalAmount - availableAmount;

      debugPrint("$TAG remaining Percentage =========> $remainingPercentage");
      debugPrint("$TAG remaining Amount =========> $remainingAmount");

      if (remainingAmount > 0.0 && totalAmount > remainingAmount) {
        PaymentModel model = PaymentModel(
          id: 0,
          days: 0,
          endMonth: 0,
          paymentId: 0,
          percentage: remainingPercentage.toStringAsFixed(2),
          date: Utility.getFormattedDateFromDateTime(currentDate),
          walletId: customerPrefId,
          walletType: getWalletName(customerPrefId),
          coOrd: getCoordName(customerPrefId),
          modeId: payment_mode,
          mode: getPaymentModeName(payment_mode),
          refPG: "",
          amount: remainingAmount.toStringAsFixed(2),
          isPaid: false,
        );
        paymentDataList.add(model);
        debugPrint("$TAG payment Data List =========> ${paymentDataList.length}");
      } else if (totalAmount > remainingAmount) {

      }
    }
  }

  void updatePaymentCalculation(PaymentModel model) {
    double totalPayment = subTotal;
    double calculatedTotalPayment = 0.00;

    for (int i = 0; i < paymentDataList.length; i++) {
      calculatedTotalPayment += double.parse(paymentDataList[i].amount);
    }
    calculatedTotalPayment += double.parse(model.amount);

    debugPrint("$TAG total Payment =======> $totalPayment");
    debugPrint("$TAG calculated Total Payment =======> $calculatedTotalPayment");

    if(calculatedTotalPayment == totalPayment) {
      debugPrint("$TAG both payments are equal");
      paymentDataList.add(model);
    } else if(calculatedTotalPayment < totalPayment) {
      debugPrint("$TAG calculated total payment is less than total payment");
      paymentDataList.add(model);
    } else {
      debugPrint("$TAG calculated total payment is grater than total payment");
      model.amount = "0.00";
      model.isPaid = false;
      paymentDataList.add(model);
      reCalculate = true;
    }
  }

  void getWithHoldingType() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getWithHoldingTypes,
        token: userModel!.authorization,
        responseCode: GET_WITHHOLDING_LIST,
        companyId: currentCompany!.id);
    request.setListener(this);
  }

  // comment by nilesh on 21-12-2022 for complete payment calculation
  void cashTotalWithVatCalculation() {
    setState(() {
      totalProductVat = 0.00;
      subTotal = 0.00;
      pensionFundVat = 0.00;
      pensionFundAmount = 0.00;
      withHoldingTax1 = 0.00;
      withHoldingTax2 = 0.00;
      withHoldingTax3 = 0.00;
      totalWithHoldingTax = 0.00;
      totalVat = 0.00;
      totalToShow = 0.00;

      List vatResult = List.from([]);
      List amount = List.from([]);

      for(int i = 0; i < productList.length; i++) {

        debugPrint("$TAG productList =======> ${productList[i]}");
        vatResult.add(productList[i]["vatResult"]);
        amount.add(productList[i]["totalWithOutVat"]);

        if(productList[i]["vat_value"] != null && productList[i]["vat_value"].toString() != "") {
          totalProductVat += ((double.parse(productList[i]["vat_value"].toString()) * double.parse(productList[i]["totalWithOutVat"].toString())) / 100);
        }
        if(productList[i]["totalWithOutVat"] != null && productList[i]["totalWithOutVat"].toString() != "") {
          subTotal += double.parse(productList[i]["totalWithOutVat"].toString());
        }
        if(productList[i]["tarifDiscount"] != null && productList[i]["tarifDiscount"].toString() != "") {
          totalProductDiscount += double.parse(productList[i]["tarifDiscount"].toString());
        }
        if(productList[i]["total"] != null && productList[i]["total"].toString() != "") {
          totalPayment += double.parse(productList[i]["total"].toString());
        }
      }
      debugPrint("$vatResult");
      debugPrint("$amount");
      if(_withholdingTaxValue) {
        if(_pensionFundValue) {

          pensionFundAmount = (pensionFundController.text.isNotEmpty ?
          double.parse(pensionFundController.text.toString().trim()) : 0.00) * subTotal / 100;

          if(pensionFundVatValue > 0) {
            pensionFundVat = (pensionFundAmount * pensionFundVatValue) / 100;
          }

          if(withHoldingPercentageController1.text.toString().isNotEmpty) {
            withHoldingTax1 = ((subTotal + pensionFundAmount) * int.parse(withHoldingPercentageController1.text.trim())) / 100;
          }
          if(withHoldingPercentageController2.text.toString().isNotEmpty) {
            withHoldingTax2 = ((subTotal + pensionFundAmount) *
                int.parse(withHoldingPercentageController2.text.trim())) / 100;
          }
          if(withHoldingPercentageController3.text.toString().isNotEmpty) {
            withHoldingTax3 = ((subTotal + pensionFundAmount) *
                int.parse(withHoldingPercentageController3.text.trim())) / 100;
          }
          totalWithHoldingTax = withHoldingTax1 + withHoldingTax2 + withHoldingTax3;
          totalVat = totalProductVat + pensionFundVat;
          totalToShow = subTotal + totalVat - pensionFundAmount - totalWithHoldingTax;
      } else {
          if(withHoldingPercentageController1.text.toString().isNotEmpty) {
            withHoldingTax1 = (subTotal * int.parse(withHoldingPercentageController1.text.trim())) / 100;
          }
          if(withHoldingPercentageController2.text.toString().isNotEmpty) {
            withHoldingTax2 = (subTotal * int.parse(withHoldingPercentageController2.text.trim())) / 100;
          }
          if(withHoldingPercentageController3.text.toString().isNotEmpty) {
            withHoldingTax3 = (subTotal * int.parse(withHoldingPercentageController3.text.trim())) / 100;
          }

          totalWithHoldingTax = withHoldingTax1 + withHoldingTax2 + withHoldingTax3;
          totalVat = totalProductVat;
          totalToShow = subTotal + totalVat - totalWithHoldingTax;
        }
      } else {
        if(_pensionFundValue) {

          if(pensionFundVatValue > 0) {
            pensionFundVat = (subTotal * pensionFundVatValue) / 100;
          }
          pensionFundAmount = (pensionFundController.text.isNotEmpty ?
          double.parse(pensionFundController.text.toString().trim()) : 0.00) * subTotal / 100;

          totalVat = totalProductVat + pensionFundVat;
          totalToShow = subTotal + totalVat - pensionFundAmount;
        } else {
          totalVat = totalProductVat;
          totalToShow = subTotal + totalVat;
        }
      }

      totalToShow = totalToShow - totalProductDiscount;

      debugPrint("$TAG pensionFundAmount ======> $pensionFundAmount");
      debugPrint("$TAG totalProductVat ======> $totalProductVat");
      debugPrint("$TAG pensionFundVat ======> $pensionFundVat");
      debugPrint("$TAG subTotal ======> $subTotal");
      debugPrint("$TAG withHoldingTax1 ======> $withHoldingTax1");
      debugPrint("$TAG withHoldingTax2 ======> $withHoldingTax2");
      debugPrint("$TAG withHoldingTax3 ======> $withHoldingTax3");
      debugPrint("$TAG totalToShow ======> $totalToShow");
      debugPrint("$TAG totalVat ======> $totalVat");
      debugPrint("$TAG totalWithHoldingTax ======> $totalWithHoldingTax");
      debugPrint("$TAG totalPayment ======> $totalPayment");
    });
  }

  String calculateDateForSaveDocument(days,checkDateType) {
    var date = DateTime.now().add(Duration(days: days));
    debugPrint("$TAG Calculate Date =======> ${date.toString()}");
    String formatted="";
    if(checkDateType=="dd"){
      DateFormat formatter = DateFormat('dd');
      formatted = formatter.format(date);
    }
    else if(checkDateType=="MM"){
      DateFormat formatter = DateFormat('MM');
      formatted = formatter.format(date);
    }
    else if(checkDateType=="yyyy"){
      DateFormat formatter = DateFormat('yyyy');
      formatted = formatter.format(date);
    }

    return formatted.toString();
  }

  List getPaymentList() {
    List documentPayment = List.from([]);
    for(int i = 0; i < paymentDataList.length; i++) {
      var payment = {
        "expire_date": {
          "day": calculateDateForSaveDocument(paymentDataList[i].days,"dd"),
          "month": calculateDateForSaveDocument(paymentDataList[i].days,"MM"),
          "year": calculateDateForSaveDocument(paymentDataList[i].days,"yyyy")
        },
        "payment_mode_id": paymentDataList[i].modeId.toString(),
        "wallet_id": paymentDataList[i].walletId.toString(),
        "wallet_coordinate": paymentDataList[i].coOrd.toString(),
        "status": false,
        "amount": paymentDataList[i].amount.toString(),
        "payment_status": paymentDataList[i].isPaid == true ? 1 : 0,
        "ref_payment": paymentDataList[i].refPG.toString(),
        "percentage": paymentDataList[i].percentage.toString(),
      };

      documentPayment.add(payment);
    }
    debugPrint("$TAG documentPayment ========> ${documentPayment.toString()}");

    return documentPayment;
  }

  List getProductList() {
    List documentProduct = List.from([]);
    for(int i=0;i<productList.length;i++) {
      var product= {
        "code": productList[i]["product_code"],
        "created_at": "",
        "description": productList[i]["description"],
        "discount": productList[i]["tarifDiscount"],
        "price": productList[i]["price"],
        "priceWithVat": productList[i]["total"],
        "product_id": productList[i]["id"] == null ? "" : productList[i]["id"],
        "quantity": productList[i]["quantity"],
        "total": productList[i]["total"],
        "type": productList[i]["unit"],
        "u_measure": productList[i]["unit"],
        "um": productList[i]["unit_display"],
        "updated_at": "",
        "vat": productList[i]["vat"],
        "vat_name": productList[i]["vat_display"],
        "vat_value": productList[i]["vat_value"],
        "document_id": widget.documentTypeData["id"],
        "id":productList[i]["id"] == null ? "" : productList[i]["id"],
        "moviment_type_object": {
          "name": "",
          "icon_name": "",
          "tooltip_message": ""
        },
        "tmp_id": "",
        "pension_fund": 1,
        "isLoaded": true,
        "productBatch": {
          "id": "",
          "name": "",
          "product_type": "",
          "product_id": "",
          "expiry_date": null
        },
        "units": [],
        "productBatchList": [
          {
            "id": "",
            "product_type": "",
            "name": "",
            "product_id": "",
            "expiry_date": null
          }
        ],
        "productTariffList": [],
        "features": [
          "product_type_product_with_warehouse",
          "product_page_rate_tarif",
          "product_page_ean",
          "product_page_price_supplier",
          "custom-fields",
          "product_page_measurement_unit",
          "product_production",
          "product-file-upload",
          "product-ecommerce"
        ],
        "warehouse_inventory": {
          "available_quantity": "",
          "reserved_quantity": "",
          "ordered_quantity": "",
          "quantity": ""
        },
        "productStats": {
          "SELL_AVG_DATA": "",
          "BUY_AVG_DATA": "",
          "LAST_PRICE":"",
          "buy_price": "",
          "sell_price": ""
        },

        "productBatchList": [
          {
            "id": "",
            "product_type": "",
            "name": "",
            "product_id": "",
            "expiry_date": ""
          }
        ],
        "productTariffList": []

      };
      documentProduct.add(product);
    }
    debugPrint("$TAG documentProduct ========> ${documentProduct.toString()}");

    return documentProduct;
  }

  List getWithholdingList() {
    List withholding = List.from([]);
    if(_withholdingTaxValue) {
      if(withHoldingPercentageController1.text != "") {
        var withholdingTax = {
          "type": withHoldingTypeValue1,
          "causal": withHoldingMethodValue1,
          "percentage": int.parse(withHoldingPercentageController1.text.trim().toString()),
          "withHoldAmount": withHoldingTax1
        };
        withholding.add(withholdingTax);
      }
      if(withHoldingPercentageController2.text != "") {
        var withholdingTax = {
          "type": withHoldingTypeValue2,
          "causal": withHoldingMethodValue2,
          "percentage": int.parse(withHoldingPercentageController2.text.trim().toString()),
          "withHoldAmount": withHoldingTax2
        };
        withholding.add(withholdingTax);
      }
      if(withHoldingPercentageController3.text != "") {
        var withholdingTax = {
          "type": withHoldingTypeValue3,
          "causal": withHoldingMethodValue3,
          "percentage": int.parse(withHoldingPercentageController3.text.trim().toString()),
          "withHoldAmount": withHoldingTax3
        };
        withholding.add(withholdingTax);
      }

      debugPrint("$TAG withholding ========> ${withholding.toString()}");
    }
    return withholding;
  }

  void createCustomer() {
    setState(() {
      showLoader = true;
    });

    var body = jsonEncode({
      "contact_type": "company",
      "company_name": agencyNameController.text.toString().trim(),
      "fiscal_code": fiscalCodeController.text.toString().trim(),
      "vat_number": vatNumberController.text.toString().trim(),
      "address1": addressController.text.toString().trim(),
      "address2": address2Controller.text.toString().trim(),
      "country": provinceAbbreviationController.text.toString().trim(),
      "zip": postalCodeController.text.toString().trim(),
      "city": cityController.text.toString().trim(),
      "state": stateInitialsController.text.toString().trim(),
      "is_customer": 1,
      "is_supplier": 1,
      "recipient_code": sdiCodeController.text.toString().trim(),
      "email_pec": emailPECController.text.toString().trim(),
      "address_array": [
        {
          "address1": addressController.text.toString().trim(),
          "address2": address2Controller.text.toString().trim(),
          "country": provinceAbbreviationController.text.toString().trim(),
          "zip": postalCodeController.text.toString().trim(),
          "city": cityController.text.toString().trim(),
          "state": stateInitialsController.text.toString().trim(),
          "type": 0,
          "type_name": ""
        }
      ],
    });

    debugPrint("$TAG create customer data =======> $body");

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.saveCustomerCreateInvoice,
        token: userModel!.authorization,
        body: body,
        responseCode: SAVE_CUSTOMER,
        companyId: currentCompany!.id);
    request.setListener(this);

  }

  void saveDocument() {
    // setState(() {
    //   showLoader = true;
    // });
    debugPrint("$TAG product result ========> $productResult");
    var body = jsonEncode({
      "order_reference": {},
      "document": {
        //"totalwithhold":  totalWithHoldingTax, // no
        //"customer_update": true, // no
        //"order_reference": {}, // no
        "totalVatCharge": totalProductVat,//productResult == null ? "" : productResult["vat_value"], // yes
        "sdi_trans_format": "", // yes
        "e_sigibilitaIVA": "", // yes
        "sdi_tp": "", // yes
        "sdi_currency": "", // yes
        "document_suffix": documentCodeController.text, // yes
        "document_create_date": { // yes
          "day": currentDate.day,
          "month": currentDate.month,
          "year": currentDate.year
        },
        "sum_pension_fund0": 0, // calculate the payment based on calculation discussed on friday
        "sum_pension_fund1": _pensionFundValue ? subTotal : 0, // calculate the payment based on calculation discussed on friday
        "pension_fund_percentage": pensionFundController.text,
        "totalVat": totalVat,
        "isTotalWithVat": 0, // yes total amount of product is included vat
        "wallet_id": customerPrefId, // yes wallet id
        "payment_mode": payment_mode, // yes
        "document_number": documentNumberController.text, // yes
        "customer_id": customerDataResult["id"].toString(), // yes
        "customer_name": agencyNameController.text, // yes
        "customer_address": addressController.text, // yes
        "customer_city": cityController.text, // yes
        "customer_email": pecEmailController.text, // yes
        "customer_fiscal_code": fiscalCodeController.text, // yes
        "customer_vat_number": vatNumberController.text, // yes
        "customer_province": provinceAbbreviationController.text, // yes
        "customer_zip": postalCodeController.text, // yes
        "customer_state": stateInitialsController.text, // yes
        "customer_shipping_city": "",  // yes
        "customer_shipping_province": "", // yes
        "customer_shipping_address": "", // yes
        "customer_shipping_zip": "", // yes
        "customer_shipping_state": "", // yes
        "customer_sdi_code": sdiCodeController.text, // yes
        "isUsingRateId": null, // yes
        "sdi_pec_destination": "", // yes
        "discount_type": "", // yes
        "is_stamp": _stampValue ? 1 : 0, // yes
        "documentPaymentTypeId": "", // yes
        "payment_type_description": modeController.text, // yes
        "discount_percent": discountPercentageController.text, // yes
        "discount_amount": discountAmountController.text, // yes
        "stamp":  _stampValue ? stampAmountController.text : "", // yes
        "warehouse_id": "", // yes
        "document_type_name": widget.documentTypeData["name"] // yes
      },
      "documentProduct": getProductList(), // yes
      "documentPayment": getPaymentList(), // yes
      "include_document_ids": [], // yes
      "transportData": {}, // yes
      "pension_fund": { // yes
        "vat_id": pensionFundVatResult == null ? "" : pensionFundVatResult["id"],
        "vatValue": pensionFundVatResult == null ? "" : pensionFundVatResult["value"],
        "pension_fund": _pensionFundValue ? 1: 0,
        "percentage": pensionFundController.text,
        "sdi_encoding_code": widget.documentTypeData["sdi_econding"] == null ? "" : widget.documentTypeData["sdi_econding"].toString(),
        "withHoldingTax": _calculateWithholdingTaxValue ? 1 : 0,
      },
      "withHoldingTax": {}, // yes
      "is_canceled": 0, // yes
      "documentFilesToUpload": [], // yes
      "withHoldingTaxDetails": _withholdingTaxValue ? getWithholdingList() : [], // yes
      "movimentationalProduct": [] // yes
    });

    debugPrint("$TAG body ===========> $body");

    // PostRequest request = PostRequest();
    // request.getResponse(
    //     cmd: RequestCmd.saveDocument,
    //     token: userModel!.authorization,
    //     body: body,
    //     responseCode: SAVE_DOCUMENT,
    //     companyId: userModel!.currentCompany?.id);
    // request.setListener(this);
  }





}