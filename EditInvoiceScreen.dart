
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

class EditInvoiceScreen extends StatefulWidget {

  var documentObject;

  EditInvoiceScreen({Key? key, this.documentObject}) : super(key: key);

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> with SingleTickerProviderStateMixin
    implements ResponseListener {

  String TAG = "_EditInvoiceScreenState";
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

  List<dynamic> pensionFundVatList = List.from([]);
  List<dynamic> vatTypesDataList = List.from([]);

  List<dynamic> withListDataList = List.from([]);
  List<dynamic> withHoldingDataList = List.from([]);

  List<dynamic> measuringUnitList = List.from([]);

  DocumentTypeData? documentTypeData;
  var documentNumber;
  var documentResponse;


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

  var vatResult;
  String? selectedVatValue;
  TextEditingController vatController = TextEditingController();

  List<TextEditingController> withHoldingTypeController = List.from([]);

  var withHoldingResult;
  List<TextEditingController> selectedwithHoldingValue = List.from([]);
  List<TextEditingController> reasonForPaymentController = List.from([]);
  var reasonForPaymentResult;
  List<TextEditingController> selectedreasonForPaymentValue = List.from([]);
  List<TextEditingController> withHoldingController = List.from([]);

  TextEditingController pensionFundController = TextEditingController();
  TextEditingController stampAmountController = TextEditingController(text:"2.00");
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController discountPercentageController = TextEditingController();

  var totalVat;
  var CashTotal = "0.00";

  List<TextEditingController> TotalWithHolding = List.from([]);

  List withHoldingTypeList = List.from([]);
  var GET_WITHHOLDING_LIST = 9003;
  int withholdingTaxVisibility = 0;

  var pensionFundObject;



  // third tab fields
  var productResult;
  List productList = List.from([]);
  double totalPrice = 0.00;
  late SlidableController slidableController;

  ScrollController scrollController = ScrollController();


  // fourth tab field

  TextEditingController modeController = TextEditingController();
  double subTotal = 0.00;
  var GET_PAYMENT_METHOD_WITH_ID = 3006;
  var GET_PAYMENT_MODE = 3007;
  var GET_WALLET_LIST = 3008;
  var GET_CUSTOMER_PREF_LIST = 3009;
  List<dynamic> paymentActualDataList = List.from([]);
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
  bool tabValue = true;


  var SAVE_DOCUMENT = 3010;
  var GET_DOCUMENT_DETAIL = 3011;

  // fifth tab fields

  TextEditingController recepientNameController = TextEditingController();
  TextEditingController pecController = TextEditingController();
  TextEditingController einvoiceTypologyController = TextEditingController();
  TextEditingController documentNumberSDIController = TextEditingController();
  TextEditingController cupCodeController = TextEditingController();
  TextEditingController cigCodeController = TextEditingController();
  TextEditingController causalController = TextEditingController();
  TextEditingController vatSDIController = TextEditingController();




  @override
  void initState() {

    debugPrint("$TAG documentObject============> ${widget.documentObject}");
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {

      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      debugPrint("$TAG document Type Data ======> ${widget.documentObject}");

      currentCompany = userModel!.currentCompany!;
      getDocumentDetail();
      getPaymentMode();
      //   getCustomerPreferenceList();
      //   getWithHoldingValues();
      //   getPaymentMode();
      //   getWalletList();
      //   getMeasuringUnit();
      //
      //   if(widget.documentObject != null) {
      //     documentDataResult = widget.documentObject;
      //     documentType = documentDataResult["name"];
      //     getDocumentTypes();
      //     getDocumentNumbers(true);
      //
      //   }
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
                        //   getCustomerPreferenceList();
                        updateCustomerData(result);
                      }
                    });
                  },
                  icon: const Icon(Icons.person)
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
                    //saveDocument();
                  }
                },
                icon: const Icon(Icons.save)
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
          Constant.LANG == Constant.EN ? ENG.EDIT_INVOICE_TITLE : IT.EDIT_INVOICE_TITLE,
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
                  SizedBox(
                    height: Dimensions.PADDING_L.h,
                  ),
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
                  SizedBox(
                    height: Dimensions.PADDING_L.h,
                  ),
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
                    )),
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
                      SizedBox(height: 25.h),

                      // Normal Number Heading
                      Text(
                          Constant.LANG == Constant.EN
                              ? ENG.CREATE_INVOICE_TAB_2_NUMBER
                              : IT.CREATE_INVOICE_TAB_2_NUMBER,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          )),
                      const SizedBox(height: Dimensions.PADDING_XS),

                      // number TextFiled
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: documentNumberController,
                          keyboardType: TextInputType.number,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            hintText: Constant.LANG == Constant.EN
                                ? ENG.CREATE_INVOICE_TAB_2_NUMBER
                                : IT.CREATE_INVOICE_TAB_2_NUMBER,
                            helperStyle: gothamRegular.copyWith(
                                fontSize: Dimensions.FONT_S.sp),
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding:
                            REdgeInsets.fromLTRB(20, 0, 20, 0),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_M.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_M.r),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_L),

                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_2_CODE_SECTION
                            : IT.CREATE_INVOICE_TAB_2_CODE_SECTION,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),

                      // normal TextFiled
                      Theme(
                        data: Theme.of(context)
                            .copyWith(splashColor: Colors.transparent),
                        child: TextField(
                          controller: documentCodeController,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                          decoration: InputDecoration(
                            helperStyle: gothamRegular.copyWith(
                                fontSize: Dimensions.FONT_S.sp),
                            filled: true,
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding:
                            REdgeInsets.fromLTRB(20, 0, 20, 0),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_M.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_M.r),
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
                            Constant.LANG == Constant.EN
                                ? ENG.CREATE_INVOICE_TAB_2_DATE
                                : IT.CREATE_INVOICE_TAB_2_DATE,
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
                                  color: const Color(AllColors.colorGrey)
                                      .withOpacity(0.7),
                                ),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_S.r),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.7.w,
                                  color: const Color(AllColors.colorGrey)
                                      .withOpacity(0.7),
                                ),
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_S.r),
                              ),
                              filled: true,
                              hintStyle: gothamMedium.copyWith(
                                  color: Colors.grey,
                                  fontSize: Dimensions.FONT_XL.sp,
                                  fontWeight: FontWeight.w600),
                              hintText: Utility.getFormattedDateFromDateTime(
                                  currentDate),
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
                                color: _stampValue == false
                                    ? Colors.white
                                    : const Color(AllColors.colorBlue),
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
                          SizedBox(
                            width: Dimensions.PADDING_M.w,
                          ),
                          Text(
                            Constant.LANG == Constant.EN
                                ? ENG.CREATE_INVOICE_TAB_2_STAMP
                                : IT.CREATE_INVOICE_TAB_2_STAMP,
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                          ),
                          SizedBox(
                            width: Dimensions.PADDING_L.w,
                          ),
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
                                  color: _discountValue == false
                                      ? Colors.white
                                      : const Color(AllColors.colorBlue),
                                  borderRadius: BorderRadius.circular(3.r),
                                  border: Border.all(
                                      width: 1.5.w,
                                      color:
                                      const Color(AllColors.colorBlue)),
                                ),
                                child: _discountValue
                                    ? const Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                          SizedBox(
                            width: Dimensions.PADDING_M.w,
                          ),
                          Text(
                            Constant.LANG == Constant.EN
                                ? ENG.CREATE_INVOICE_TAB_2_DISCOUNT
                                : IT.CREATE_INVOICE_TAB_2_DISCOUNT,
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.PADDING_M.h),

                      Visibility(
                        visible: _stampValue,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                Constant.LANG == Constant.EN
                                    ? ENG.CREATE_INVOICE_TAB_2_STAMP
                                    : IT.CREATE_INVOICE_TAB_2_STAMP,
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
                                    //   cashTotalWithVatCalculation(
                                    //       productResult);
                                    // });
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
                                        ? ENG.CREATE_INVOICE_TAB_2_STAMP_AMOUNT
                                        : IT.CREATE_INVOICE_TAB_2_STAMP_AMOUNT,
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
                            ]),),
                      SizedBox(height: Dimensions.PADDING_M.h),
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
                                          Constant.LANG == Constant.EN
                                              ? ENG
                                              .CREATE_INVOICE_TAB_2_PERCENTAGE
                                              : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
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
                            ]),),
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
                                      _withholdingTaxValue =
                                      !_withholdingTaxValue;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 23.h,
                                    width: 23.w,
                                    decoration: BoxDecoration(
                                        color: _withholdingTaxValue == false
                                            ? Colors.white
                                            : const Color(
                                            AllColors.colorBlue),
                                        borderRadius:
                                        BorderRadius.circular(3.r),
                                        border: Border.all(
                                            width: 1.5.w,
                                            color: const Color(
                                                AllColors.colorBlue))),
                                    child: _withholdingTaxValue
                                        ? const Padding(
                                      padding:
                                      EdgeInsets.only(bottom: 5),
                                      child: Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Padding(
                                      padding:
                                      EdgeInsets.only(bottom: 5),
                                      child: Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )),
                              const SizedBox(
                                width: Dimensions.PADDING_M,
                              ),
                              Text(
                                Constant.LANG == Constant.EN
                                    ? ENG
                                    .CREATE_INVOICE_TAB_2_OR_WITHHOLDINGTAX
                                    : IT.CREATE_INVOICE_TAB_2_OR_WITHHOLDINGTAX,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_M,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Dimensions.PADDING_S.h,
                          ),

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
                                        color: _pensionFundValue == false
                                            ? Colors.white
                                            : const Color(
                                            AllColors.colorBlue),
                                        borderRadius:
                                        BorderRadius.circular(3.r),
                                        border: Border.all(
                                            width: 1.5.w,
                                            color: const Color(
                                                AllColors.colorBlue))),
                                    child: _pensionFundValue
                                        ? const Padding(
                                      padding:
                                      EdgeInsets.only(bottom: 5),
                                      child: Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    )
                                        : const Padding(
                                      padding:
                                      EdgeInsets.only(bottom: 5),
                                      child: Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )),
                              const SizedBox(
                                width: Dimensions.PADDING_M,
                              ),
                              Text(
                                Constant.LANG == Constant.EN
                                    ? ENG
                                    .CREATE_INVOICE_TAB_2_OR_PENSION_FUND_BASED_ON_PREFERENCES
                                    : IT.CREATE_INVOICE_TAB_2_OR_PENSION_FUND_BASED_ON_PREFERENCES,
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
                              Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_PENSION_FUND_NAME : IT.CREATE_INVOICE_TAB_2_PENSION_FUND_NAME,
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
                                              cashTotalWithVatCalculation(productResult);
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
                                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_VAT : IT.CREATE_INVOICE_TAB_2_VAT,
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
                                          controller: vatController,
                                          readOnly: true,
                                          autofocus: false,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: Dimensions.FONT_L,
                                          ),

                                          onTap: () async {
                                            vatResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                return SelectVatTypeScreen();
                                              },
                                            ));

                                            debugPrint("$TAG filterVatResult ======> $vatResult");

                                            setState(() {
                                              if (vatResult != null) {
                                                vatController.text = vatResult["name"];
                                                selectedVatValue = vatResult["value"].toString();
                                              }
                                            });
                                          },

                                          decoration: InputDecoration(
                                            suffixIcon: const Icon(Icons.arrow_forward_ios),
                                            hintText:
                                            Constant.LANG == Constant.EN ? ENG.PRODUCT_ADD_NEW_VAT : IT.PRODUCT_ADD_NEW_VAT,
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
                                      )
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _calculateWithholdingTaxValue = !_calculateWithholdingTaxValue;
                                              cashTotalWithVatCalculation(productResult);
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
                                                color: const Color(AllColors.colorBlue),
                                              ),
                                            ),
                                            child: const Padding(padding: EdgeInsets.only(bottom: 5),
                                              child: Icon(
                                                Icons.check,
                                                size: 18,
                                                color:
                                                Colors.white,
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
                                      ]),
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
                                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_CASH_TOTAL : IT.CREATE_INVOICE_TAB_2_CASH_TOTAL,
                                        style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: Dimensions.PADDING_XS),
                                      Theme(
                                        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                        child: Text(
                                          "$CashTotal ${Constant.euroSign}",
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

                      Visibility(
                        visible: _withholdingTaxValue,
                        child: Container(
                          height:MediaQuery.of(context).size.height,
                          width:MediaQuery.of(context).size.width,
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: withholdingTaxVisibility,
                              itemBuilder: (BuildContext context, int index) {
                                withHoldingController.add(new TextEditingController());
                                withHoldingTypeController.add(new TextEditingController());
                                reasonForPaymentController.add(new TextEditingController());
                                TotalWithHolding.add(new TextEditingController());
                                selectedreasonForPaymentValue.add(new TextEditingController());
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      Constant.LANG == Constant.EN
                                          ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING
                                          : IT.CREATE_INVOICE_TAB_2_WITHHOLDING,
                                      style: gothamRegular.copyWith(
                                          color: Colors.black,
                                          fontSize: Dimensions.FONT_L,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: Dimensions.PADDING_M,
                                    ),
                                    Text(
                                      Constant.LANG == Constant.EN
                                          ? ENG.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE
                                          : IT.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE,
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
                                          controller: withHoldingTypeController[index],
                                          readOnly: true,
                                          autofocus: false,
                                          style: gothamRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: Dimensions.FONT_L,
                                          ),
                                          onTap: () async {
                                            withHoldingResult = await Navigator.push(
                                                context, MaterialPageRoute(
                                              builder: (context) {
                                                return SelectWithHoldingTypeScreen();
                                              },
                                            ));

                                            debugPrint(
                                                "$TAG Withholding type ======> $withHoldingResult");

                                            setState(() {
                                              if (withHoldingResult != null) {
                                                withHoldingTypeController[index].text =
                                                withHoldingResult["name"];
                                                selectedwithHoldingValue[index].text =
                                                    withHoldingResult["value"]
                                                        .toString();
                                              }
                                            });
                                          },
                                          decoration: InputDecoration(
                                            suffixIcon:
                                            const Icon(Icons.arrow_forward_ios),
                                            hintText: Constant.LANG == Constant.EN
                                                ? ENG
                                                .CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE
                                                : IT.CREATE_INVOICE_TAB_2_WITHHOLDING_TYPE,
                                            helperStyle: gothamRegular.copyWith(
                                                fontSize: Dimensions.FONT_S.sp),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F1),
                                            contentPadding:
                                            REdgeInsets.fromLTRB(20, 15, 0, 0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius: BorderRadius.circular(
                                                  Dimensions.RADIUS_M.r),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius: BorderRadius.circular(
                                                  Dimensions.RADIUS_M.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.PADDING_L),
                                    Text(
                                      Constant.LANG == Constant.EN
                                          ? ENG
                                          .CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT
                                          : IT.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT,
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
                                          controller: reasonForPaymentController[index],
                                          readOnly: true,
                                          autofocus: false,
                                          style: gothamRegular.copyWith(
                                            color: Colors.black,
                                            fontSize: Dimensions.FONT_L,
                                          ),
                                          onTap: () async {
                                            reasonForPaymentResult =
                                            await Navigator.push(context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return SelectReasonForPaymentScreen();
                                                  },
                                                ));

                                            debugPrint(
                                                "$TAG reasonForPayment ======> $reasonForPaymentResult");

                                            setState(() {
                                              if (reasonForPaymentResult != null) {
                                                reasonForPaymentController[index].text =
                                                reasonForPaymentResult["name"];
                                                selectedreasonForPaymentValue[index].text =
                                                reasonForPaymentResult["id"];
                                              }
                                            });
                                          },
                                          decoration: InputDecoration(
                                            suffixIcon:
                                            const Icon(Icons.arrow_forward_ios),
                                            hintText: Constant.LANG == Constant.EN
                                                ? ENG
                                                .CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT
                                                : IT.CREATE_INVOICE_TAB_2_REASON_FOR_PAYMENT,
                                            helperStyle: gothamRegular.copyWith(
                                                fontSize: Dimensions.FONT_S.sp),
                                            filled: true,
                                            fillColor: const Color(0xFFF1F1F1),
                                            contentPadding:
                                            REdgeInsets.fromLTRB(20, 15, 0, 0),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius: BorderRadius.circular(
                                                  Dimensions.RADIUS_M.r),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                              borderRadius: BorderRadius.circular(
                                                  Dimensions.RADIUS_M.r),
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
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                Constant.LANG == Constant.EN
                                                    ? ENG
                                                    .CREATE_INVOICE_TAB_2_PERCENTAGE
                                                    : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
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
                                                    hintColor:
                                                    const Color(0xFFbdc6cf),
                                                  ),
                                                  child: TextField(
                                                    controller:  withHoldingController[index],
                                                    onChanged: (value) {
                                                      setState(() {
                                                        cashTotalWithVatCalculation(
                                                            productResult);
                                                      });
                                                    },
                                                    keyboardType:
                                                    TextInputType.number,
                                                    autofocus: false,
                                                    style: gothamRegular.copyWith(
                                                      color: Colors.black,
                                                      fontSize: Dimensions.FONT_L,
                                                    ),
                                                    decoration: InputDecoration(
                                                      hintText: Constant.LANG ==
                                                          Constant.EN
                                                          ? ENG
                                                          .CREATE_INVOICE_TAB_2_PERCENTAGE
                                                          : IT.CREATE_INVOICE_TAB_2_PERCENTAGE,
                                                      helperStyle:
                                                      gothamRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_S.sp),
                                                      filled: true,
                                                      fillColor:
                                                      const Color(0xFFF1F1F1),
                                                      contentPadding:
                                                      REdgeInsets.fromLTRB(
                                                          20, 0, 20, 0),
                                                      focusedBorder:
                                                      OutlineInputBorder(
                                                        borderSide: const BorderSide(
                                                            color: Colors.white),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .RADIUS_M.r),
                                                      ),
                                                      enabledBorder:
                                                      UnderlineInputBorder(
                                                        borderSide: const BorderSide(
                                                            color: Colors.white),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            Dimensions
                                                                .RADIUS_M.r),
                                                      ),
                                                    ),
                                                  ))
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
                                                    .CREATE_INVOICE_TAB_2_TOTAL_WITHHOLDING
                                                    : IT.CREATE_INVOICE_TAB_2_TOTAL_WITHHOLDING,
                                                style: gothamRegular.copyWith(
                                                  color: Colors.black,
                                                  fontSize: Dimensions.FONT_L,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: Dimensions.PADDING_M),
                                              TotalWithHolding[index].text==null || TotalWithHolding[index].text.isEmpty?  Text(
                                                "0.00 ${Constant.euroSign}",
                                                style: gothamRegular.copyWith(
                                                  color: Colors.black,
                                                  fontSize: Dimensions.FONT_L,
                                                ),
                                              ):Text(
                                                "${TotalWithHolding[index].text} ${Constant.euroSign}",
                                                style: gothamRegular.copyWith(
                                                  color: Colors.black,
                                                  fontSize: Dimensions.FONT_L,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: Dimensions.PADDING_S),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // const SizedBox(
                                    //     height: Dimensions.PADDING_S),
                                  ],
                                );}),
                        ),


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
                          getTotalSum();
                          cashTotalWithVatCalculation(productResult);
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
                            getTotalSum();
                            cashTotalWithVatCalculation(productResult);

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
                          cashTotalWithVatCalculation(productResult);
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
                          cashTotalWithVatCalculation(productResult);
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
                                  });
                                },
                                child: SvgPicture.asset(
                                  Images.swipeDeleteIcon,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              // SlidableAction(
                              //   onPressed: (context) {
                              //     setState(() {
                              //       productList.removeAt(index);
                              //     });
                              //   },
                              //   backgroundColor: const Color(AllColors.swipeDelete),
                              //   label: Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_DELETE_BUTTON: IT.CREATE_INVOICE_TAB_3_DELETE_BUTTON,
                              //   foregroundColor: Colors.white,
                              //   icon: Icons.delete,
                              // ),
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
                                  if(productList[index]["vat_name"] != null && productList[index]["vat_name"] != "")
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            Dimensions.PADDING_S, 0.0, Dimensions.PADDING_S, 8.0),
                                        child: Text(
                                          "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_VAT: IT.CREATE_INVOICE_TAB_3_VAT} ${productList[index]["vat_name"]}",
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
                                              productList[index]["discount"] == null || productList[index]
                                              ["discount"] == "" ? " 0" : " ${productList[index]["discount"]}",
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
                                        "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_UNIT: IT.CREATE_INVOICE_TAB_3_UNIT} ${productList[index]["um"]}",
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
                                      productList[index]["total"] ==
                                          null ||
                                          productList[index]
                                          ["total"] ==
                                              ""
                                          ? "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_3_TOTAL: IT.CREATE_INVOICE_TAB_3_TOTAL} 0 ${Constant.euroSign}"
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
                                        dateFormat(paymentActualDataList[index]["expire_date"] ),
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
                                      "${paymentActualDataList[index]["amount"]} ${Constant.euroSign}",
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
                              //   commented by nilesh 23/11/2022 for Account and Coord textfield
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (paymentActualDataList[index]["id"] != null && paymentActualDataList[index]["id"] != "")
                                    Container(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_ACCOUNT: IT.CREATE_INVOICE_TAB_4_ACCOUNT} ${paymentActualDataList[index]["wallet_name"]}",
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
                                      child: paymentActualDataList[index]["wallet_coordinate"]!=null || paymentActualDataList[index]["wallet_coordinate"].toString()!="null"?Text(
                                        "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_COORD: IT.CREATE_INVOICE_TAB_4_COORD} ${paymentActualDataList[index]["wallet_coordinate"]}",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorText),
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: Dimensions.FONT_S,
                                            letterSpacing: 0.5
                                        ),
                                      ): Text(
                                        Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_COORD: IT.CREATE_INVOICE_TAB_4_COORD,
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
                                  if(paymentActualDataList[index]["payment_name"] != null && paymentActualDataList[index]["payment_name"] != "")
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          "${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_MODE: IT.CREATE_INVOICE_TAB_4_MODE} ${paymentActualDataList[index]["payment_name"].toString()}",
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
                                            bool isPaid = paymentActualDataList[index]["payment_status"] == "0" ? false : true;
                                            setState(() {
                                              isPaid = !isPaid;
                                            });
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 23.h,
                                            width: 23.w,
                                            decoration: BoxDecoration(
                                              color: paymentActualDataList[index]["payment_status"] == "0" ? const Color(AllColors.colorBlue) : Colors.white,
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
                  Text("${Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_4_TOTAL: IT.CREATE_INVOICE_TAB_4_TOTAL} ${subTotal.toStringAsFixed(2)} ${Constant.euroSign}",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: gothamRegular.copyWith(
                      color: const Color(AllColors.colorText),
                      overflow: TextOverflow.ellipsis,
                      fontSize: Dimensions.FONT_XL,
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
                  controller: vatSDIController,
                  readOnly: true,
                  autofocus: false,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),

                  onTap: () async {

                  },

                  decoration: InputDecoration(
                    suffixIcon: const Icon(
                        Icons.arrow_forward_ios),
                    hintText:
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_5_EVALUATE
                        : IT.CREATE_INVOICE_TAB_5_EVALUATE,
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
                  controller: vatSDIController,
                  readOnly: true,
                  autofocus: false,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Dimensions.FONT_L,
                  ),

                  onTap: () async {

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
              SizedBox(
                height: Dimensions.PADDING_L.h,
              ),
              //VAT CHARGEABILITY
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_5_VAT_CHARGEABILITY
                        : IT.CREATE_INVOICE_TAB_5_VAT_CHARGEABILITY,
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
                      controller: vatSDIController,
                      readOnly: true,
                      autofocus: false,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),

                      onTap: () async {

                      },

                      decoration: InputDecoration(
                        suffixIcon: const Icon(
                            Icons.arrow_forward_ios),
                        hintText:
                        Constant.LANG == Constant.EN
                            ? ENG.CREATE_INVOICE_TAB_5_VAT_CHARGEABILITY
                            : IT.CREATE_INVOICE_TAB_5_VAT_CHARGEABILITY,
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
                ],
              ),
              SizedBox(
                height: Dimensions.PADDING_L.h,
              ),




              // CAUSAL
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Constant.LANG == Constant.EN
                        ? ENG.CREATE_INVOICE_TAB_5_CAUSAL
                        : IT.CREATE_INVOICE_TAB_5_CAUSAL,
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
    // https://devapi.paciolo.it/payment/modes
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

  void getDocumentDetail() {
    debugPrint("getdoc =======> ${RequestCmd.getDocumentDetail}Fattura/document-detail/${widget.documentObject["invoice_id"]}?isRowCLick=false");
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getDocumentDetail}Fattura/document-detail/${widget.documentObject["invoice_id"].toString()}?isRowCLick=false",
        token: userModel!.authorization,
        responseCode: GET_DOCUMENT_DETAIL,
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
    if (responseCode == GET_DOCUMENT_DETAIL ) {
      setState(() {
        debugPrint("$TAG GET_DOCUMENT_DETAIL ======> ${response[Constant.data].toString()}");
        debugPrint("$TAG GET_DOCUMENT_DETAIL documentPayment======> ${response[Constant.data]["documentPayment"].toString()}");

        documentResponse = response[Constant.data]["document"];

        setCustomerData(response[Constant.data]["document"]);
        setGenericValueData(response[Constant.data]["document"]);
        modeController.text = response[Constant.data]["document"]["payment_type_description"];

        debugPrint("$TAG GET_DOCUMENT_DETAIL documentPayment======> ${response[Constant.data]["documentPayment"] .toString()}");

        productList.clear();

        for (int i = 0; i < response[Constant.data]["documentProduct"].length; i++) {
          debugPrint("$TAG GET_DOCUMENT_DETAIL documentProduct======> ${response[Constant.data]["documentProduct"][i].toString()}");

          productList.add(response[Constant.data]["documentProduct"][i]);

        }

        var paymentObject = response[Constant.data]["documentPayment"];

        for (int i = 0; i < paymentObject.length; i++) {
          debugPrint("$TAG GET_DOCUMENT_DETAIL documentProduct======> ${paymentObject[i].toString()}");
          paymentActualDataList.add(paymentObject[i]);
          String modeName = "";
          for(int j = 0; j < paymentModeList.length; j++) {
            if(paymentObject[i]["payment_mode_id"] == paymentModeList[i]["id"]) {
              modeName = paymentModeList[i]["name"];
            }
          }

          // expiry - today = days
          // expiry month = endmonth
          // id = payment id
          // percentage = calculate manual from total payment
          paymentDataList.add(PaymentModel(
            id: paymentObject[i]["id"],
            days: calculateDays(paymentObject[i]["expire_date"]),
            endMonth: paymentObject[i]["id"],
            paymentId: paymentObject[i]["id"],
            percentage: paymentObject[i]["id"],
            date: dateFormat(paymentObject[i]["expire_date"]),
            walletId: paymentObject[i]["wallet_id"],
            walletType: paymentObject[i]["wallet_item_name"],
            coOrd: paymentObject[i]["wallet_coordinate"] == null ? "" : paymentObject[i]["wallet_coordinate"],
            modeId: paymentObject[i]["payment_mode_id"],
            mode: modeName,
            refPG: paymentObject[i]["ref_payment"],
            amount: paymentObject[i]["amount"].toString(),
            isPaid: paymentObject[i]["payment_status"] == 0 ? false : true,
          ));

        }
        for (int i = 0; i < response[Constant.data]["withHoldingTaxDetails"].length; i++) {
          debugPrint("$TAG GET_DOCUMENT_DETAIL withHoldingTax ======> ${response[Constant.data]["withHoldingTaxDetails"][i].toString()}");

          withListDataList.add(response[Constant.data]["withHoldingTaxDetails"][i]);
        }
        getTotalSum();

        showLoader = false;

        pensionFundObject = response[Constant.data]["pension_fund"];
        debugPrint("");
        debugPrint("$TAG GET_DOCUMENT_DETAIL pensionFundObject ====> $pensionFundObject");
        if(pensionFundObject != null) {
          _pensionFundValue = true;
          setPensionFund();
        }

        getVatValues();

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

            if(pensionFundObject != null) {
              if (pensionFundObject["vat_id"] == response[Constant.data]["list"][i]["id"]) {
                vatController.text = response[Constant.data]["list"][i]["name"];
                selectedVatValue = response[Constant.data]["list"][i]["value"];
              }
            }
          }
        }
        for (int i = 0; i < response[Constant.data]["types"].length; i++) {
          vatTypesDataList.add(response[Constant.data]["types"][i]);
        }

      });
    } else  if (responseCode == GET_PAYMENT_MODE) {
      debugPrint("$TAG GET PAYMENT MODE LIST =====> ${response[Constant.data]}");
      setState(() {
        showLoader = false;
        for (int i = 0; i < response[Constant.data].length; i++) {
          paymentModeList.add(response[Constant.data][i]);
        }
        debugPrint("$TAG GET PAYMENT MODE LIST LENGTH =====> ${paymentModeList.toString()}");
      });
    }
    //  if (responseCode == GET_PAYMENT_METHOD_WITH_ID ) {
    //   setState(() {
    //     debugPrint("$TAG GET_PAYMENT_METHOD_WITH_ID ======> ${response[Constant.data]["result"]}");
    //     //paypal_pay_check = response[Constant.data]["result"]["paypal_pay_check"] == "0" ? false : true;
    //     //payment_mode = response[Constant.data]["result"]["payment_mode"];
    //
    //     //debugPrint("$TAG paypal_pay_check ======> ${paypal_pay_check.toString()}");
    //     paymentMethodList.clear();
    //
    //     for (int i = 0; i < response[Constant.data]["result"]["paymentDeadLines"].length; i++) {
    //       paymentMethodList.add(response[Constant.data]["result"]["paymentDeadLines"][i]);
    //     }
    //     paymentCalculation();
    //     showLoader = false;
    //     debugPrint("$TAG GET_PAYMENT_METHOD_WITH_ID ======> ${paymentMethodList.length}");
    //   });
    // } else if (responseCode == GET_CUSTOMER_PREF_LIST) {
    //   debugPrint("$TAG GET GET_CUSTOMER_PREF_LIST ========> ${response[Constant.data]}");
    //   setState(() {
    //     showLoader = false;
    //     for (int i = 0; i < response[Constant.data].length; i++) {
    //       customerPrefId = response[Constant.data][i]["wallet_id"];
    //       payment_mode = response[Constant.data][i]["payment_mode"];
    //
    //       debugPrint("$TAG GET customerPrefList Wallet ID ========> $customerPrefId");
    //       debugPrint("$TAG GET customerPrefList payment_mode ========> $payment_mode");
    //     }
    //
    //     getWalletList();
    //     getMeasuringUnit();
    //
    //   });
    // } else if (responseCode == GET_WALLET_LIST) {
    //
    //   debugPrint("$TAG GET WALLET LIST ========> ${response[Constant.data]}");
    //   setState(() {
    //     showLoader = false;
    //     for(int i = 0; i < response[Constant.data].length; i++) {
    //       walletList.add(response[Constant.data][i]);
    //     }
    //   });
    // } else  if (responseCode == GET_PAYMENT_MODE) {
    //   debugPrint("$TAG GET PAYMENT MODE LIST =====> ${response[Constant.data]}");
    //   setState(() {
    //     showLoader = false;
    //     for (int i = 0; i < response[Constant.data].length; i++) {
    //       paymentModeList.add(response[Constant.data][i]);
    //     }
    //     debugPrint("$TAG GET PAYMENT MODE LIST LENGTH =====> ${paymentModeList.toString()}");
    //   });
    // } else if (GET_DOCUMENT_FILTER_TYPES == responseCode) {
    //   setState(() {
    //     showLoader = false;
    //     lastDocumentLoadedId = currentCompany!.lastTypeOfDocumentLoadedId;
    //     documentTypeList.clear();
    //     for (int i = 0; i < response[Constant.data].length; i++) {
    //       documentTypeList.add(response[Constant.data][i]);
    //       if (lastDocumentLoadedId == response[Constant.data][i]["id"]) {
    //         debugPrint("$TAG current Company Document Loaded Id ======> ${response[Constant.data][i]["id"]}");
    //         debugPrint("$TAG last Document Loaded Id ======> $lastDocumentLoadedId");
    //         documentType = response[Constant.data][i]["name"];
    //         break;
    //       } else {
    //         documentType = response[Constant.data][0]["name"];
    //       }
    //     }
    //     getVatValues();
    //     getWithHoldingValues();
    //     getDocumentNumbers(true);
    //     getDocumentTypes();
    //   });
    // } else if (GET_DOCUMENT_VATS == responseCode) {
    //   setState(() {
    //     debugPrint("$TAG GET_DOCUMENT_VATS (pension fund) list ======> ${response[Constant.data]["list"]}");
    //     debugPrint("$TAG GET_DOCUMENT_VATS list ======> ${response[Constant.data]["types"]}");
    //     showLoader = false;
    //     pensionFundVatList.clear();
    //     vatTypesDataList.clear();
    //     for (int i = 0; i < response[Constant.data]["list"].length; i++) {
    //       if(response[Constant.data]["list"][i]["pension_fund"] == 1) {
    //         pensionFundVatList.add(response[Constant.data]["list"][i]);
    //       }
    //     }
    //     for (int i = 0; i < response[Constant.data]["types"].length; i++) {
    //       vatTypesDataList.add(response[Constant.data]["types"][i]);
    //     }
    //   });
    // } else if (GET_WITH_HOLDINGS == responseCode) {
    //   setState(() {
    //     debugPrint("$TAG GET_WITH_HOLDINGS list ======> ${response[Constant.data]["list"]}");
    //     debugPrint("$TAG GET_WITH_HOLDINGS withHolding ======> ${response[Constant.data]["withHolding"]}");
    //     withholdingTaxVisibility=response[Constant.data]["withHolding"][0]["witholding_tax_visibility"];
    //     showLoader = false;
    //     withListDataList.clear();
    //     withHoldingDataList.clear();
    //     for (int i = 0; i < response[Constant.data]["list"].length; i++) {
    //       withListDataList.add(response[Constant.data]["list"][i]);
    //     }
    //     for (int i = 0; i < 3; i++) {
    //       reasonForPaymentController[i].text =
    //       withListDataList[0]["name"];
    //     }
    //     selectedreasonForPaymentValue[0].text =
    //         withListDataList[0]["Id"]
    //             .toString();
    //     debugPrint("$TAG withholdingTaxVisibility ${withholdingTaxVisibility.toString()}");
    //
    //     for (int i = 0; i < response[Constant.data]["withHolding"].length; i++) {
    //       withHoldingDataList.add(response[Constant.data]["withHolding"][i]);
    //     }
    //   });
    // } else if (GET_DOCUMENT_TYPES == responseCode) {
    //   setState(() {
    //     showLoader = false;
    //     debugPrint("$TAG GET_DOCUMENT_TYPES ======> ${response[Constant.data]}");
    //     documentTypeData = DocumentTypeData.fromJson(response[Constant.data]);
    //     if(documentTypeData != null && documentTypeData!.data != null) {
    //       if(documentTypeData!.data!.isSdiBtnEnable! && documentTypeData!.data!.isDocumentEncodingExist!){
    //         tabValue=true;
    //       } else {
    //         tabValue=false;
    //       }
    //     } else {
    //       tabValue=false;
    //     }
    //   });
    // } else if (GET_DOCUMENT_NUMBER == responseCode) {
    //   setState(() {
    //     showLoader = false;
    //     debugPrint("$TAG GET_DOCUMENT_NUMBER ======> ${response[Constant.data]}");
    //     documentNumber = response[Constant.data]["document_number"];
    //
    //     if (documentNumber != null && documentNumber != "") {
    //       documentNumberController.text = documentNumber.toString();
    //     } else {
    //       documentNumberController.text = "";
    //     }
    //
    //     if (currentCompany!.defaultNumeration != null && currentCompany!.defaultNumeration != "") {
    //       documentCodeController.text = currentCompany!.defaultNumeration.toString();
    //     } else {
    //       documentCodeController.text = "";
    //     }
    //   });
    // } else if (GET_MEASURE_UNIT == responseCode) {
    //   setState(() {
    //     showLoader = false;
    //     debugPrint("$TAG GET_MEASURE_UNIT ======> ${response[Constant.data]}");
    //     measuringUnitList.clear();
    //
    //     for (int i = 0; i < response[Constant.data]["measurement_unit"].length; i++) {
    //       measuringUnitList.add(response[Constant.data]["measurement_unit"][i]);
    //     }
    //     debugPrint("$TAG GET_MEASURE_UNIT ======> ${measuringUnitList.length}");
    //   });
    // }
    // else   if (responseCode == GET_WITHHOLDING_LIST) {
    //
    //   debugPrint("$TAG GET_WITHHOLDING_LIST ========> ${response[Constant.data]}");
    //   setState(() {
    //     showLoader = false;
    //
    //     for(int i = 0; i < response[Constant.data].length; i++) {
    //       withHoldingTypeList.add(response[Constant.data][i]);
    //     }
    //     for(int i = 0; i < 3; i++) {
    //       withHoldingTypeController[i].text =
    //       withHoldingTypeList[0]["name"];
    //     }
    //
    //     selectedwithHoldingValue[0].text =
    //         withHoldingTypeList[0]["value"]
    //             .toString();
    //     debugPrint("$TAG GET_WITHHOLDING_LIST withHoldingTypeController========> ${withHoldingTypeController[0].text}");
    //   });
    // }
    //
    // else if (SAVE_DOCUMENT == responseCode) {
    //
    //   setState(() {
    //     showLoader = false;
    //     Navigator.of(context).pop();
    //     Utility.showSuccessToast(Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TAB_2_ALERT4 : IT.CREATE_INVOICE_TAB_2_ALERT4);
    //
    //   });
    // }
  }

  // coment by nilesh added on 19-12-2022 for calculate pension fund
  void setPensionFund() {
    var amount = pensionFundObject["totalwithoutvat1"];
    var percentage = pensionFundObject["percentage"];

    double finalAmount = (amount * percentage) / 100;

    pensionFundController.text = percentage.toString();
    CashTotal = finalAmount.toStringAsFixed(2);

    if(pensionFundObject["withHoldingTax"] == 1) {
      _calculateWithholdingTaxValue = true;
    }
  }

  String calculateDate(days) {
    var date = DateTime.now().add(Duration(days: days));
    debugPrint("$TAG Calculate Date =======> ${date.toString()}");
    DateFormat formatter = DateFormat('dd-MM-yyyy');
    String formatted = formatter.format(date);
    return formatted.toString();
  }

  int calculateDays(String expiryDate) {
    DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(expiryDate);
    var inputDate = DateTime.parse(parseDate.toString());
    debugPrint("$TAG calculateDays inputDate =====> $inputDate");
    DateTime date2 = DateTime.now();
    int difference = inputDate.difference(date2).inDays;
    debugPrint("$TAG calculateDays difference =====> $difference");
    return difference;
  }

  String dateFormat(date) {
    DateTime parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(date);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('dd/MM/yyyy');
    var outputDate = outputFormat.format(inputDate);
    return outputDate.toString();
  }

  void getTotalSum() {
    for (int i = 0; i < productList.length; i++) {
      subTotal = subTotal + double.parse(productList[i]["total"].toString());
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
    customerDataResult = result;
    if(customerDataResult["customer_name"] != null && customerDataResult["customer_name"] != "null") {
      agencyNameController.text = customerDataResult["customer_name"].toString();
    }
    if(customerDataResult["customer_vat_number"] != null && customerDataResult["customer_vat_number"] != "null") {
      vatNumberController.text = customerDataResult["customer_vat_number"].toString();
    }
    if(customerDataResult["customer_fiscal_code"] != null && customerDataResult["customer_fiscal_code"] != "null") {
      fiscalCodeController.text = customerDataResult["customer_fiscal_code"].toString();
    }
    if(customerDataResult["customer_address"] != null && customerDataResult["customer_address"] != "null") {
      addressController.text = customerDataResult["customer_address"].toString();
    }
    if(customerDataResult["customer_address"] != null && customerDataResult["customer_address"] != "null") {
      address2Controller.text = customerDataResult["customer_address"].toString();
    }
    if(customerDataResult["customer_city"] != null && customerDataResult["customer_city"] != "null") {
      cityController.text = customerDataResult["customer_city"].toString();
    }
    if(customerDataResult["customer_zip"] != null && customerDataResult["customer_zip"] != "null") {
      postalCodeController.text = customerDataResult["customer_zip"].toString();
    }
    if(customerDataResult["customer_province"] != null && customerDataResult["customer_province"] != "null") {
      provinceAbbreviationController.text = customerDataResult["customer_province"].toString();
    }
    if(customerDataResult["customer_state"] != null && customerDataResult["customer_state"] != "null") {
      stateInitialsController.text = customerDataResult["customer_state"].toString();
    }
    if(customerDataResult["customer_sdi_code"] != null && customerDataResult["customer_sdi_code"] != "null") {
      sdiCodeController.text = customerDataResult["customer_sdi_code"].toString();
    }
    if(customerDataResult["customer_email"] != null && customerDataResult["customer_email"] != "null") {
      pecEmailController.text = customerDataResult["customer_email"].toString();
    }
    debugPrint("$TAG customer Data Result =======> $customerDataResult");
  }

  void setGenericValueData(var result) {
    customerDataResult = result;
    if(customerDataResult["document_number"] != null && customerDataResult["document_number"] != "null") {
      documentNumberController.text = customerDataResult["document_number"].toString();
    }
    if(customerDataResult["document_suffix"] != null && customerDataResult["document_suffix"] != "null") {
      documentCodeController.text = customerDataResult["document_suffix"].toString();
    }
    if(customerDataResult["is_stamp"] != null && customerDataResult["is_stamp"] != "null") {
      _stampValue = customerDataResult["is_stamp"].toString() == "0" ? false : true;
    }


    if(customerDataResult["document_create_date"] != null && customerDataResult["document_create_date"] != "null") {
      currentDate = DateTime.parse(customerDataResult["document_create_date"]) ;
    }
    debugPrint("$TAG customer Data Result =======> $customerDataResult");
  }

  void updateCustomerData(var result) {
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
    for(int i = 0; i < paymentActualDataList.length; i++) {

      PaymentModel model = PaymentModel(
          id: paymentActualDataList[i]["id"],
          days: paymentActualDataList[i]["days"],
          endMonth: paymentActualDataList[i]["end_month"],
          paymentId: paymentActualDataList[i]["payment_id"],
          percentage: paymentActualDataList[i]["percentage"],
          date: calculateDate(paymentActualDataList[i]["days"]),
          walletId: customerPrefId,
          walletType: getWalletName(customerPrefId),
          coOrd: getCoordName(customerPrefId),
          modeId: payment_mode,
          mode: getPaymentModeName(payment_mode),
          refPG: "",
          amount: (subTotal * (paymentActualDataList[i]["percentage"] / 100)).toStringAsFixed(2),
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

  void cashTotalWithVatCalculation(productResult) {
    if(productResult["quantity"].isEmpty || productResult["quantity"] == "") {
      totalVat = "0.00";
    } else if(productResult["vat_value"] == null || productResult["vat_value"] == "") {

      if(productResult["tarifDiscount"].isEmpty || productResult["tarifDiscount"] == "") {
        double total = (double.parse(productResult["quantity"]) * double.parse(productResult["price"] .isEmpty?"0.0":productResult["price"]));
        debugPrint("$TAG CashTotal vat calculation total ======> $total");
        double vatValue = 0.0;
        debugPrint("$TAG CashTotal vat calculation vatValue ======> $vatValue");
        double finalTotal = total + vatValue - 0;
        double finalTotal2 = finalTotal * double.parse(pensionFundController.text.isEmpty?"0.0":pensionFundController.text) / 100;
        debugPrint("$TAG CashTotal vat calculation finalTotal ======> $finalTotal");
        CashTotal = finalTotal2.toStringAsFixed(2);

        double finalTotal3 = total * double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text) / 100;
        double finalTotal4 =( total * double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text) / 100)
            +( (double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text)* finalTotal2 / 100));
        _calculateWithholdingTaxValue==false?
        TotalWithHolding[0].text=finalTotal3.toStringAsFixed(2):TotalWithHolding[0].text=finalTotal4.toStringAsFixed(2);

        double finalTotal5 = total * double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text) / 100;
        double finalTotal6 =( total * double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text) / 100)
            +( (double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text)* finalTotal2 / 100));
        _calculateWithholdingTaxValue==false?TotalWithHolding[1].text=finalTotal5.toStringAsFixed(2):TotalWithHolding[1].text=finalTotal6.toStringAsFixed(2);

        double finalTotal7 = total * double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text) / 100;
        double finalTotal8 =( total * double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text) / 100)
            +( (double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text)* finalTotal2 / 100));

        _calculateWithholdingTaxValue==false? TotalWithHolding[2].text=finalTotal7.toStringAsFixed(2):TotalWithHolding[2].text=finalTotal8.toStringAsFixed(2);
      } else {
        double total = (double.parse(productResult["quantity"]) * double.parse(productResult["price"].isEmpty?"0.0":productResult["price"]));
        debugPrint("$TAG CashTotal vat calculation total ======> $total");
        double vatValue = 0.0;
        debugPrint("$TAG CashTotal vat calculation vatValue ======> $vatValue");
        double discount = (total + vatValue) * double.parse(productResult["tarifDiscount"].toString()) / 100;
        double finalTotal = total + vatValue - discount;
        double finalTotal2 = finalTotal * double.parse(pensionFundController.text.isEmpty?"0.0":pensionFundController.text) / 100;
        debugPrint("$TAG CashTotal vat calculation finalTotal ======> $finalTotal");
        CashTotal = finalTotal2.toStringAsFixed(2);

        double finalTotal3 = total * double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text) / 100;
        double finalTotal4 =( total * double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text) / 100)
            +( (double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text)* finalTotal2 / 100));
        _calculateWithholdingTaxValue==false?
        TotalWithHolding[0].text=finalTotal3.toStringAsFixed(2):TotalWithHolding[0].text=finalTotal4.toStringAsFixed(2);

        double finalTotal5 = total * double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text) / 100;
        double finalTotal6 =( total * double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text) / 100)
            +( (double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text)* finalTotal2 / 100));

        _calculateWithholdingTaxValue==false?
        TotalWithHolding[1].text=finalTotal5.toStringAsFixed(2):TotalWithHolding[1].text=finalTotal6.toStringAsFixed(2);

        double finalTotal7 = total * double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text) / 100;
        double finalTotal8 =( total * double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text) / 100)
            +( (double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text)* finalTotal2 / 100));

        _calculateWithholdingTaxValue==false?
        TotalWithHolding[2].text=finalTotal7.toStringAsFixed(2):TotalWithHolding[2].text=finalTotal8.toStringAsFixed(2);

      }
    } else {
      if(productResult["tarifDiscount"].isEmpty || productResult["tarifDiscount"] == "") {
        double total = (double.parse(productResult["quantity"]) * double.parse(productResult["price"].isEmpty?"0.0":productResult["price"]));
        debugPrint("$TAG CashTotal vat calculation total ======> $total");
        double vatValue = total * double.parse(productResult["vat_value"].toString()) / 100;
        debugPrint("$TAG CashTotal vat calculation vatValue ======> $vatValue");
        double finalTotal = total + vatValue - 0;

        double finalTotal2 = total * double.parse(pensionFundController.text.isEmpty?"0.0":pensionFundController.text) / 100;
        debugPrint("$TAG CashTotal vat calculation finalTotal ======> $finalTotal");
        CashTotal = finalTotal2.toStringAsFixed(2);

        double finalTotal3 = total * double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text) / 100;
        double finalTotal4 =( total * double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text) / 100)
            +( (double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text)* finalTotal2 / 100));
        _calculateWithholdingTaxValue == false? TotalWithHolding[0].text = finalTotal3.toStringAsFixed(2) : TotalWithHolding[0].text = finalTotal4.toStringAsFixed(2);

        double finalTotal5 = total * double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text) / 100;
        double finalTotal6 =( total * double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text) / 100)
            +( (double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text)* finalTotal2 / 100));

        _calculateWithholdingTaxValue == false? TotalWithHolding[1].text = finalTotal5.toStringAsFixed(2) : TotalWithHolding[1].text = finalTotal6.toStringAsFixed(2);


        double finalTotal7 = total * double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text) / 100;
        double finalTotal8 =( total * double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text) / 100)
            +( (double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text)* finalTotal2 / 100));

        _calculateWithholdingTaxValue == false? TotalWithHolding[2].text = finalTotal7.toStringAsFixed(2) : TotalWithHolding[2].text = finalTotal8.toStringAsFixed(2);

      } else {
        double total = (double.parse(productResult["quantity"]) * double.parse(productResult["price"].isEmpty?"0.0":productResult["price"]));
        debugPrint("$TAG CashTotal vat calculation total ======> $total");
        double vatValue = total * double.parse(productResult["vat_value"]!) / 100;
        debugPrint("$TAG CashTotal vat calculation vatValue ======> $vatValue");
        double discount = (total + vatValue) * double.parse(productResult["discount"].toString()) / 100;
        double finalTotal = total + vatValue - discount;
        double finalTotal2 = total * double.parse(pensionFundController.text.isEmpty?"0.0":pensionFundController.text) / 100;
        debugPrint("$TAG CashTotal vat calculation finalTotal ======> $finalTotal");
        CashTotal = finalTotal2.toStringAsFixed(2);

        double finalTotal3 = total * double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text) / 100;
        double finalTotal4 =( total * double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text) / 100)
            +( (double.parse(withHoldingController[0].text.isEmpty?"0.0":withHoldingController[0].text)* finalTotal2 / 100));


        _calculateWithholdingTaxValue==false?
        TotalWithHolding[0].text=finalTotal3.toStringAsFixed(2):TotalWithHolding[0].text=finalTotal4.toStringAsFixed(2);

        double finalTotal5 = total * double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text) / 100;
        double finalTotal6 =( total * double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text) / 100)
            +( (double.parse(withHoldingController[1].text.isEmpty?"0.0":withHoldingController[1].text)* finalTotal2 / 100));

        _calculateWithholdingTaxValue==false?
        TotalWithHolding[1].text=finalTotal5.toStringAsFixed(2):TotalWithHolding[1].text=finalTotal6.toStringAsFixed(2);

        double finalTotal7 = total * double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text) / 100;
        double finalTotal8 =( total * double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text) / 100)
            +( (double.parse(withHoldingController[2].text.isEmpty?"0.0":withHoldingController[2].text)* finalTotal2 / 100));

        _calculateWithholdingTaxValue==false?
        TotalWithHolding[2].text=finalTotal7.toStringAsFixed(2):TotalWithHolding[2].text=finalTotal8.toStringAsFixed(2);
      }
    }
  }

  String calculateDateForSaveDocument(days, checkDateType) {
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
    for(int i=0;i<paymentDataList.length;i++) {
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
      documentPayment.insert(i, payment);
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
        "document_id": widget.documentObject["id"],
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
    for(int i=0;i<withholdingTaxVisibility;i++) {
      var withholdingTax= {
        "type":withHoldingTypeController.isEmpty?"": withHoldingTypeController[i].text,
        "causal": selectedreasonForPaymentValue.isEmpty?"":selectedreasonForPaymentValue[i].text,
        "percentage": withHoldingController.isEmpty?"":withHoldingController[i].text,
        "withHoldAmount": TotalWithHolding.isEmpty?"":TotalWithHolding[i].text
      };
      withholding.add(withholdingTax);
    }
    debugPrint("$TAG withholding ========> ${withholding.toString()}");

    return withholding;
  }



  void updateDocument() {
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      "document": {
        "invoice_id": documentResponse["invoice_id"],
        "document_create_date": {
          "day": currentDate.day,
          "month": currentDate.month,
          "year": currentDate.year
        },
        "document_number": documentResponse["document_number"],
        "document_suffix": documentResponse["document_suffix"],
        "payment_deadline_id": documentResponse["payment_deadline_id"],
        "payment_note": documentResponse["payment_note"],
        "document_amount": documentResponse["document_amount"],
        "document_status": documentResponse["document_status"],
        "document_type_id": documentResponse["document_type_id"],
        "document_type_name": documentResponse["document_type_name"],
        "document_notes": "",
        "product_move": 0,
        "warehouse_id": documentResponse["warehouse_id"],
        "agent_id": documentResponse["agent_id"],
        "agent_percent": documentResponse["agent_percent"],
        "is_canceled": documentResponse["is_canceled"],
        "company_id": documentResponse["company_id"],
        "customer_id": documentResponse["customer_id"],
        "customer_name": documentResponse["customer_name"],
        "customer_fiscal_code": documentResponse["customer_fiscal_code"],
        "customer_vat_number": documentResponse["customer_vat_number"],
        "customer_email": documentResponse["customer_email"],
        "customer_note": documentResponse["customer_note"],
        "contact_type": documentResponse["contact_type"],
        "customer_address": documentResponse["customer_address"],
        "customer_city": documentResponse["customer_city"],
        "customer_zip": documentResponse["customer_zip"],
        "customer_state": documentResponse["customer_state"],
        "customer_province": documentResponse["customer_province"],
        "customer_shipping_address": "",
        "customer_shipping_city": "",
        "customer_shipping_zip": "",
        "customer_shipping_state": "",
        "customer_shipping_province": "",
        "sdi_trans_format": "",
        "sdi_pec_destination": "",
        "sdi_tp": "",
        "sdi_currency": 1,
        "e_sigibilitaIVA": "",
        "customer_sdi_code": "jendra111",
        "is_received": 0,
        "codice_cig": null,
        "codice_cup": null,
        "id_documento": null,
        "sdi_causale": null,
        "is_stamp": 0,
        "stamp": 2,
        "discount_type": "SC",
        "discount_percent": 10,
        "discount_amount": 100,
        "payment_type_description": "30 – 60 – 90 giorni FM",
        "id": null,
        "document_id": null,
        "revenue_cost_category_id": null,
        "is_delete": null,
        "created_at": null,
        "updated_at": null,
        "rev_ass_id": null,
        "rev_id": null,
        "isUsingRateId": null,
        "tags": [

        ],
        "order_reference": {

        },
        "sum_pension_fund0": 0,
        "sum_pension_fund1": 50.4,
        "pension_fund_percentage": 5.04,
        "totalVat": 1.1088,
        "totalVatCharge": 11.088,
        "isTotalWithVat": 1,
        "wallet_id": 517,
        "payment_mode": 9,
        "documentPaymentTypeId": 756
      },
      "include_document_ids": [

      ],
      "documentProduct": getProductList(),
      "documentPayment": getPaymentList(),
      "transportData": null,
      "docTypeDetail": {
        "id": 1,
        "name": "Fattura",
        "mov_products": -1,
        "expiry_date": 1,
        "positive": 1,
        "cancelable": 0,
        "partial": 0,
        "transport_type": 0,
        "opposite_document": 5,
        "sdi_econding": "TD01",
        "pension_fund_expire_date": "-1",
        "type": 0,
        "is_recived_type": 0,
        "is_inverted": 0,
        "soggetto_emittente": "TZ",
        "integratioj": 0
      },
      "pension_fund": {
        "id": 13565,
        "document_id": 84217,
        "vat_id": 27,
        "percentage": 10,
        "totalwithoutvat1": 50.4,
        "sdi_encoding_code": "TC07",
        "withHoldingTax": 0,
        "created_at": "2022-12-20T08:10:15.000Z",
        "updated_at": "2022-12-20T08:34:13.000Z",
        "vatValue": 22,
        "Description": "Ente nazionale assistenza agenti e rappresentanti di commercio (ENASARCO)",
        "pensionfundsum_enasarco": -1
      },
      "withHoldingTax": {
        "id": 12321,
        "document_id": 84217,
        "percentage": 0,
        "type": "",
        "causal": 0,
        "created_at": "2022-12-20T08:34:13.000Z",
        "updated_at": "2022-12-20T08:34:13.000Z"
      },
      "withHoldingTaxDetails": [
        {
          "id": 12321,
          "document_id": 84217,
          "percentage": 0,
          "type": "RT01",
          "causal": 1,
          "created_at": "2022-12-20T08:34:13.000Z",
          "updated_at": "2022-12-20T08:34:13.000Z",
          "withHoldAmount": 0
        },
        {
          "id": 12322,
          "document_id": 84217,
          "percentage": 0,
          "type": "RT01",
          "causal": 1,
          "created_at": "2022-12-20T08:34:13.000Z",
          "updated_at": "2022-12-20T08:34:13.000Z",
          "withHoldAmount": 0
        },
        {
          "id": 12323,
          "document_id": 84217,
          "percentage": 0,
          "type": "RT01",
          "causal": 1,
          "created_at": "2022-12-20T08:34:13.000Z",
          "updated_at": "2022-12-20T08:34:13.000Z",
          "withHoldAmount": 0
        }
      ],
      "is_exist_in_sdi_operation": false,
      "is_already_in_task_pa": false,
      "is_document_encoding_exist": true,
      "is_document_encoding_exist_pa": false,
      "movimentationalProduct": [

      ],
      "is_customer_update": 0,
      "docTotalData": {

      }
    });

    debugPrint("$TAG body ===========> $body");

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.saveDocument,
        token: userModel!.authorization,
        body: body,
        responseCode: SAVE_DOCUMENT,
        companyId: userModel!.currentCompany?.id);
    request.setListener(this);
  }

}