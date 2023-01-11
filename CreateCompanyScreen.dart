
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/PutRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../network/GetRequest.dart';
import '../util/CommonCSS.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({Key? key}) : super(key: key);

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen> implements ResponseListener {

  String TAG = "_CreateCompanyScreenState";
  var currentCompanyId;
  LoginUserModel? userModel;
  bool showLoader = false;
  bool isBusiness = true;
  bool isAddress = false;
  bool isTaxAndCash = false;
  bool isElectronicInvoicing = false;

  bool isBusinessEnableButton = true;
  // page 1 business controller
  TextEditingController businessNameController = TextEditingController();
  TextEditingController vatNumberController = TextEditingController();

  bool enableButton = false;

  // page 2 address controller
  late TextEditingController page2BusinessNameController;
  TextEditingController companyMottoController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController surNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController provinceAbbreviationController = TextEditingController();
  late TextEditingController stateInitialsController;
  TextEditingController postalCodeController = TextEditingController();
  // page 3 tax regime dropdowns
  String? selectedTaxRegime;

  String? selectedWithholdingTax;
  List<String> withholdingTaxStringArray = List.from([
    "0",
    "1",
    "2",
    "3",
  ]);

  String? selectedSocialSecurity;
  List<String> socialSecurityStringArray = List.from([]);
  List socialSecurityMainArray = List.from([]);
  String? selectedPrintTemplates;
  List<String> printTemplatesStringArray = List.from([]);
  List printTemplatesMainArray = List.from([]);
  // page 4 electronic invoicing
  TextEditingController legalNameController = TextEditingController();
  TextEditingController pecController = TextEditingController();
  TextEditingController taxCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  late TextEditingController mobileCodeController;

  var GET_COMPANY_CHECK = 3000;
  var GET_PENSION_FUND = 3001;
  var GET_COMPANY_COMBINATION = 3002;
  var SAVE_COMPANY_DATA = 3010;
  var GET_UPDATE_NEW_COMPANY = 3011;
  var GET_NEWS_ALERT = 3012;
  var SET_COMPANY_COMBINATION = 3013;
  var SDI_ENABLE = 3014;
  var UPDATE_EMAIL = 3015;
  var GET_UPDATED_COMPANY_DATA = 3016;
  var SET_COMPANY_DATA = 3333;

  var newCompanyId;
  String? selectedCompanyName;
  int? finalPrintTemplates;
  var finalSelectedSocialSecurity;
  var finalTaxRegime;
  bool receiveValue = false;
  bool sendValue = false;

  @override
  void initState() {
    mobileCodeController = TextEditingController(text: "39");
    stateInitialsController = TextEditingController(text: "IT");
    page2BusinessNameController = TextEditingController(text: businessNameController.text.trim().toString());
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;

      selectedTaxRegime = IT.taxRegimeStringArray[0];
      checkCanCreateCompany();
      getPensionFund();
      getCompanyCombination();
    });
    super.initState();
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
          Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_TITLE : IT.CREATE_COMPANY_TITLE,
          style: gothamMedium.copyWith(
            color: Colors.white,
            fontSize: Dimensions.FONT_L,
          ),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: Column(
          children: [
            // business
            Visibility(
              visible: isBusiness,
              child: Container(
                margin: const EdgeInsets.all(Dimensions.PADDING_S),
                child: Card(
                  elevation: Dimensions.PADDING_XS,
                  borderOnForeground: true,
                  semanticContainer: true,
                  child: Container(
                    margin: const EdgeInsets.all(Dimensions.PADDING_S),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_1_TITLE_HEADING : IT.CREATE_COMPANY_PAGE_1_TITLE_HEADING,
                          style: gothamMedium.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_XL,
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_XS),
                        Text(
                          Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_1_TITLE_SUB_HEADING : IT.CREATE_COMPANY_PAGE_1_TITLE_SUB_HEADING,
                          style: gothamMedium.copyWith(
                            color: const Color(AllColors.colorGrey),
                            fontSize: Dimensions.FONT_M,
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_L),
                        Text(
                          Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_1_LABEL_1_HEADING : IT.CREATE_COMPANY_PAGE_1_LABEL_1_HEADING,
                          style: gothamMedium.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_XS),
                        businessNameField(context),
                        const SizedBox(height: Dimensions.PADDING_L),
                        Text(
                          Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_1_LABEL_2_HEADING : IT.CREATE_COMPANY_PAGE_1_LABEL_2_HEADING,
                          style: gothamMedium.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_XS),
                        vatNumberField(context),
                        const SizedBox(height: Dimensions.PADDING_L),
                        // go to next screen button
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            if(businessNameController.text.trim().toString().isEmpty) {
                              Utility.showToast(Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_1_LABEL_1_ERROR : IT.CREATE_COMPANY_PAGE_1_LABEL_1_ERROR);
                            } else if(businessNameController.text.trim().toString().isNotEmpty &&
                                businessNameController.text.trim().toString().length < 3) {
                              Utility.showToast(Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_1_LABEL_1_ERROR_1 : IT.CREATE_COMPANY_PAGE_1_LABEL_1_ERROR_1);
                            } else {
                              setState(() {
                                page2BusinessNameController = TextEditingController(text: businessNameController.text.trim().toString());
                                isAddress = true;
                                isBusiness = false;
                              });
                            }
                          },
                          child: Container(
                            height: 50.h,
                            width: double.infinity,
                            decoration: CommonCSS.buttonDecoration(enableButton, 5.r, AllColors.colorBlue, 0.4, AllColors.colorLightBlue,),
                            child: Center(
                              child: Text(
                                Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_CONTINUE : IT.CREATE_COMPANY_BUTTON_CONTINUE,
                                style: gothamBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.FONT_XL.sp,
                                    letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_L),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // address
            Visibility(
              visible: isAddress,
              child: Expanded(
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.PADDING_S),
                  child: Card(
                    elevation: Dimensions.PADDING_XS,
                    borderOnForeground: true,
                    semanticContainer: true,
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(Dimensions.PADDING_S),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_TITLE_HEADING : IT.CREATE_COMPANY_PAGE_2_TITLE_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_XL,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_TITLE_SUB_HEADING : IT.CREATE_COMPANY_PAGE_2_TITLE_SUB_HEADING,
                              style: gothamMedium.copyWith(
                                color: const Color(AllColors.colorGrey),
                                fontSize: Dimensions.FONT_M,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // business name
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_1_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_1_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            page2BusinessNameField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // business name
                            // company motto
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_2_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_2_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            companyMottoField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // company motto
                            // name
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_3_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_3_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            nameField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // name
                            // surname
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_4_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_4_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            surNameField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // surname
                            // address
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_5_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_5_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            addressField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // address
                            // address 2
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_6_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_6_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            address2Field(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // address 2
                            // city
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_7_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_7_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            cityField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // city
                            // province abbreviation
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_8_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_8_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            provinceAbbreviationField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // province abbreviation
                            // state initials
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_9_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_9_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            stateInitialsField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // state initials
                            // postal code
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_10_HEADING : IT.CREATE_COMPANY_PAGE_2_LABEL_10_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            postalCodeField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // postal code
                            // go back page button
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  isBusiness = true;
                                  isAddress = false;
                                });
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(AllColors.colorRed),
                                    width: 1.0.w),
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(5.r)),
                                child: Center(
                                  child: Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_COME_BACK : IT.CREATE_COMPANY_BUTTON_COME_BACK,
                                    style: gothamBold.copyWith(
                                        color: const Color(AllColors.colorRed),
                                        fontSize: Dimensions.FONT_XL.sp,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // go next page button
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  isTaxAndCash = true;
                                  isAddress = false;
                                });
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: CommonCSS.buttonDecoration(true, 5.r, AllColors.colorBlue, 0.5, 0),
                                child: Center(
                                  child: Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_CONTINUE : IT.CREATE_COMPANY_BUTTON_CONTINUE,
                                    style: gothamBold.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.FONT_XL.sp,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // save & exit button
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                saveCompanyData();
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: CommonCSS.buttonDecoration(true, 5.r, AllColors.colorGreen, 0.5, 0),
                                child: Center(
                                  child: Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_SAVE_PROFILE : IT.CREATE_COMPANY_BUTTON_SAVE_PROFILE,
                                    style: gothamBold.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.FONT_XL.sp,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // tax and cash
            Visibility(
              visible: isTaxAndCash,
              child: Expanded(
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.PADDING_S),
                  child: Card(
                    elevation: Dimensions.PADDING_XS,
                    borderOnForeground: true,
                    semanticContainer: true,
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(Dimensions.PADDING_S),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_TITLE_HEADING : IT.CREATE_COMPANY_PAGE_3_TITLE_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_XL,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_TITLE_SUB_HEADING : IT.CREATE_COMPANY_PAGE_3_TITLE_SUB_HEADING,
                              style: gothamMedium.copyWith(
                                color: const Color(AllColors.colorGrey),
                                fontSize: Dimensions.FONT_M,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // tax drop down
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_LABEL_1_HEADING : IT.CREATE_COMPANY_PAGE_3_LABEL_1_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            taxRegimeDropDown(),
                            // social security drop down
                            const SizedBox(height: Dimensions.PADDING_L),
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_LABEL_2_HEADING : IT.CREATE_COMPANY_PAGE_3_LABEL_2_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            socialSecurityFundDropDown(),
                            // with holding drop down
                            const SizedBox(height: Dimensions.PADDING_L),
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_LABEL_3_HEADING : IT.CREATE_COMPANY_PAGE_3_LABEL_3_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            withholdingTaxDropDown(),
                            // print template drop down
                            const SizedBox(height: Dimensions.PADDING_L),
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_LABEL_4_HEADING : IT.CREATE_COMPANY_PAGE_3_LABEL_4_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            printTemplatesDropDown(),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // go back page button
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  isTaxAndCash = false;
                                  isAddress = true;
                                });
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(AllColors.colorRed),
                                        width: 1.0.w),
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(5.r)),
                                child: Center(
                                  child: Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_COME_BACK : IT.CREATE_COMPANY_BUTTON_COME_BACK,
                                    style: gothamBold.copyWith(
                                        color: const Color(AllColors.colorRed),
                                        fontSize: Dimensions.FONT_XL.sp,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // go next page button
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  isTaxAndCash = false;
                                  isElectronicInvoicing = true;
                                });
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: CommonCSS.buttonDecoration(true, 5.r, AllColors.colorBlue, 0.5, 0),
                                child: Center(
                                  child: Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_CONTINUE : IT.CREATE_COMPANY_BUTTON_CONTINUE,
                                    style: gothamBold.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.FONT_XL.sp,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // save & exit button
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                saveCompanyData();
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: CommonCSS.buttonDecoration(true, 5.r, AllColors.colorGreen, 0.5, 0),
                                child: Center(
                                  child: Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_SAVE_PROFILE : IT.CREATE_COMPANY_BUTTON_SAVE_PROFILE,
                                    style: gothamBold.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.FONT_XL.sp,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // electronic invoicing
            Visibility(
              visible: isElectronicInvoicing,
              child: Expanded(
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.PADDING_S),
                  child: Card(
                    elevation: Dimensions.PADDING_XS,
                    borderOnForeground: true,
                    semanticContainer: true,
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(Dimensions.PADDING_S),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_TITLE_HEADING : IT.CREATE_COMPANY_PAGE_4_TITLE_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_XL,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_TITLE_SUB_HEADING : IT.CREATE_COMPANY_PAGE_4_TITLE_SUB_HEADING,
                              style: gothamMedium.copyWith(
                                color: const Color(AllColors.colorGrey),
                                fontSize: Dimensions.FONT_M,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),

                            // Legal representative
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_1_HEADING : IT.CREATE_COMPANY_PAGE_4_LABEL_1_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            legalField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // Legal representative
                            // PEC email of the company
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_2_HEADING : IT.CREATE_COMPANY_PAGE_4_LABEL_2_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            pecField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // PEC email of the company
                            // Tax code of the legal
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_3_HEADING : IT.CREATE_COMPANY_PAGE_4_LABEL_3_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            taxCodeField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // Tax code of the legal
                            // Email where to receive
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_5_HEADING : IT.CREATE_COMPANY_PAGE_4_LABEL_5_HEADING,
                              textAlign: TextAlign.start,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            emailField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // Email where to receive
                            // mobile number
                            Text(
                              Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_4_HEADING : IT.CREATE_COMPANY_PAGE_4_LABEL_4_HEADING,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                mobileCodeField(context),
                                const SizedBox(height: Dimensions.PADDING_XS),
                                Expanded(child: mobileField(context)),
                              ],
                            ),
                            CheckboxListTile(
                              contentPadding:EdgeInsets.zero,
                              title: Text(
                                Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_CHECK_1_HEADING : IT.CREATE_COMPANY_PAGE_4_CHECK_1_HEADING,
                                style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  fontSize: Dimensions.FONT_M,
                                ),
                              ),
                              value: sendValue,
                              onChanged: (newValue) {
                                setState(() {
                                  sendValue = newValue as bool;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            CheckboxListTile(
                              contentPadding:EdgeInsets.zero,
                              title: Text(
                                Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_CHECK_2_HEADING : IT.CREATE_COMPANY_PAGE_4_CHECK_2_HEADING,
                                style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  fontSize: Dimensions.FONT_M,
                                ),
                              ),
                              value: receiveValue,
                              onChanged: (newValue) {
                                setState(() {
                                  receiveValue = newValue as bool;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                            ),

                            const SizedBox(height: Dimensions.PADDING_L),
                            // mobile number
                            // go back page button
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  isElectronicInvoicing = false;
                                  isTaxAndCash = true;
                                });
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(AllColors.colorRed),
                                        width: 1.0.w),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.r)
                                ),
                                child: Center(
                                  child: Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_COME_BACK : IT.CREATE_COMPANY_BUTTON_COME_BACK,
                                    style: gothamBold.copyWith(
                                        color: const Color(AllColors.colorRed),
                                        fontSize: Dimensions.FONT_XL.sp,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // go next page button
                            // save & exit button
                            InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                if(taxCodeController.text.trim().toString().isNotEmpty &&
                                    legalNameController.text.trim().toString().isEmpty) {
                                  Utility.showToast(Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_1_ERROR: IT.CREATE_COMPANY_PAGE_4_LABEL_1_ERROR);
                                } else if(taxCodeController.text.trim().toString().isNotEmpty &&
                                    pecController.text.trim().toString().isEmpty) {
                                  Utility.showToast(Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_2_ERROR: IT.CREATE_COMPANY_PAGE_4_LABEL_2_ERROR);

                                } else if(taxCodeController.text.trim().toString().isNotEmpty &&
                                    mobileController.text.trim().toString().isEmpty) {
                                  Utility.showToast(Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_4_ERROR: IT.CREATE_COMPANY_PAGE_4_LABEL_4_ERROR);

                                } else {
                                  saveCompanyData();
                                }
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: CommonCSS.buttonDecoration(true, 5.r, AllColors.colorGreen, 0.5, 0),
                                child: Center(
                                  child: Text(
                                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_BUTTON_SAVE_PROFILE : IT.CREATE_COMPANY_BUTTON_SAVE_PROFILE,
                                    style: gothamBold.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.FONT_XL.sp,
                                        letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_L),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // first page fields starts
  Widget businessNameField(BuildContext context) {
    return TextFormField(
      controller: businessNameController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {
        if (businessNameController.text.toString().trim().isNotEmpty &&
            businessNameController.text.toString().trim().length >= 3) {
          setState(() {
            enableButton = true;
          });
        } else {
          setState(() {
            enableButton = false;
          });
        }
      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_1_LABEL_1_HINT : IT.CREATE_COMPANY_PAGE_1_LABEL_1_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget vatNumberField(BuildContext context) {
    return TextFormField(
      controller: vatNumberController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_1_LABEL_2_HINT : IT.CREATE_COMPANY_PAGE_1_LABEL_2_HINT,
        fillColor: Colors.white,
      ),
    );
  }
  // first page fields ends

  // second page fields starts
  Widget page2BusinessNameField(BuildContext context) {
    return TextFormField(
      controller: page2BusinessNameController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_1_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_1_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget companyMottoField(BuildContext context) {
    return TextFormField(
      controller: companyMottoController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_2_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_2_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget nameField(BuildContext context) {
    return TextFormField(
      controller: nameController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_3_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_3_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget surNameField(BuildContext context) {
    return TextFormField(
      controller: surNameController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_4_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_4_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget addressField(BuildContext context) {
    return TextFormField(
      controller: addressController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_5_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_5_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget address2Field(BuildContext context) {
    return TextFormField(
      controller: address2Controller,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_6_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_6_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget cityField(BuildContext context) {
    return TextFormField(
      controller: cityController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_7_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_7_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget provinceAbbreviationField(BuildContext context) {
    return TextFormField(
      controller: provinceAbbreviationController,
      keyboardType: TextInputType.name,
      maxLength: 2,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_8_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_8_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget stateInitialsField(BuildContext context) {
    return TextFormField(
      controller: stateInitialsController,
      keyboardType: TextInputType.name,
      maxLength: 2,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_9_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_9_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget postalCodeField(BuildContext context) {
    return TextFormField(
      controller: postalCodeController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_2_LABEL_10_HINT : IT.CREATE_COMPANY_PAGE_2_LABEL_10_HINT,
        fillColor: Colors.white,
      ),
    );
  }
  // second page fields ends

  // third page fields starts
  Widget taxRegimeDropDown() {
    return DropdownButtonHideUnderline(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton2<String>(
              buttonPadding:
              const EdgeInsets.only(left: 14, right: 14),
              buttonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(
                  color: Colors.black26,
                ),
                color: Colors.white,
              ),
              buttonElevation: 2,
              hint: Text(
                Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_HINT_1 : IT.CREATE_COMPANY_PAGE_3_HINT_1,
                style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M.sp,
                    letterSpacing: 0.5,
                    color: Colors.black),
              ),
              iconSize: 30,
              isExpanded: true,
              dropdownElevation: 8,
              dropdownMaxHeight: 300.h,
              dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  )),
              items: IT.taxRegimeStringArray.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M.sp,
                    letterSpacing: 0.5,
                    color: Colors.black
                  ),
                ),
              )).toList(),
              value: selectedTaxRegime,
              onChanged: (taxRegimeItem) {
                setState(() {
                  selectedTaxRegime = taxRegimeItem as String;
                  for(int i=0; i < IT.taxRegime.length; i++){
                    if(IT.taxRegime[i].value == selectedTaxRegime) {
                      finalTaxRegime = IT.taxRegime[i].id;
                      break;
                    }
                  }
                });
              },
            )
        )
    );
  }

  Widget withholdingTaxDropDown() {
    return DropdownButtonHideUnderline(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton2<String>(
              buttonPadding:
              const EdgeInsets.only(left: 14, right: 14),
              buttonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(
                  color: Colors.black26,
                ),
                color: Colors.white,
              ),
              buttonElevation: 2,
              hint: Text(
                Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_HINT_2 : IT.CREATE_COMPANY_PAGE_3_HINT_2,
                style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M.sp,
                    letterSpacing: 0.5,
                    color: Colors.black),
              ),
              iconSize: 30,
              isExpanded: true,
              dropdownElevation: 8,
              dropdownMaxHeight: 300.h,
              dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  )),
              items: withholdingTaxStringArray.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: gothamRegular.copyWith(
                      fontSize: Dimensions.FONT_M.sp,
                      letterSpacing: 0.5,
                      color: Colors.black
                  ),
                ),
              )).toList(),
              value: selectedWithholdingTax,
              onChanged: (value) {
                setState(() {
                  selectedWithholdingTax = value as String;
                });
              },
            )
        )
    );
  }

  Widget socialSecurityFundDropDown() {
    return DropdownButtonHideUnderline(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton2<String>(
              buttonPadding:
              const EdgeInsets.only(left: 14, right: 14),
              buttonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(
                  color: Colors.black26,
                ),
                color: Colors.white,
              ),
              buttonElevation: 2,
              hint: Text(
                Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_HINT_1 : IT.CREATE_COMPANY_PAGE_3_HINT_1,
                style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M.sp,
                    letterSpacing: 0.5,
                    color: Colors.black),
              ),
              iconSize: 30,
              isExpanded: true,
              dropdownElevation: 8,
              dropdownMaxHeight: 300.h,
              dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  )),
              items: socialSecurityStringArray.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: gothamRegular.copyWith(
                      fontSize: Dimensions.FONT_M.sp,
                      letterSpacing: 0.5,
                      color: Colors.black
                  ),
                ),
              )).toList(),
              value: selectedSocialSecurity,
              onChanged: (value) {
                setState(() {
                  selectedSocialSecurity = value as String;
                  for(int i=0; i< socialSecurityMainArray.length; i++){
                    if(socialSecurityMainArray[i]["Description"] == selectedSocialSecurity) {
                      finalSelectedSocialSecurity = socialSecurityMainArray[i]["id"];
                      break;
                    }
                  }
                });
              },
            )
        )
    );
  }

  Widget printTemplatesDropDown() {
    return DropdownButtonHideUnderline(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton2<String>(
              buttonPadding:
              const EdgeInsets.only(left: 14, right: 14),
              buttonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(
                  color: Colors.black26,
                ),
                color: Colors.white,
              ),
              buttonElevation: 2,
              hint: Text(
                Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_3_HINT_1 : IT.CREATE_COMPANY_PAGE_3_HINT_1,
                style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M.sp,
                    letterSpacing: 0.5,
                    color: Colors.black),
              ),
              iconSize: 30,
              isExpanded: true,
              dropdownElevation: 8,
              dropdownMaxHeight: 300.h,
              dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10.r),
                    bottomLeft: Radius.circular(10.r),
                  )),
              items: printTemplatesStringArray.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: gothamRegular.copyWith(
                      fontSize: Dimensions.FONT_M.sp,
                      letterSpacing: 0.5,
                      color: Colors.black
                  ),
                ),
              )).toList(),
              value: selectedPrintTemplates,
              onChanged: (value) {
                setState(() {
                  selectedPrintTemplates = value as String;
                  for(int i=0; i< printTemplatesMainArray.length; i++) {
                    if(printTemplatesMainArray[i]["name"] == selectedPrintTemplates) {
                      finalPrintTemplates = int.parse(printTemplatesMainArray[i]["id"].toString());
                      break;
                    }
                  }
                });
              },
            )
        )
    );
  }
  // third page fields ends

  // fourth page fields starts
  Widget legalField(BuildContext context) {
    return TextFormField(
      controller: legalNameController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_1_HINT : IT.CREATE_COMPANY_PAGE_4_LABEL_1_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget taxCodeField(BuildContext context) {
    return TextFormField(
      controller: taxCodeController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_3_HINT : IT.CREATE_COMPANY_PAGE_4_LABEL_3_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget pecField(BuildContext context) {
    return TextFormField(
      controller: pecController,
      keyboardType: TextInputType.emailAddress,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_2_HINT : IT.CREATE_COMPANY_PAGE_4_LABEL_2_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget emailField(BuildContext context) {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      decoration: InputDecoration(
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_5_HINT : IT.CREATE_COMPANY_PAGE_4_LABEL_5_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget mobileField(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: TextFormField(
        controller: mobileController,
        keyboardType: TextInputType.number,
        style: gothamMedium.copyWith(
          color: Colors.black,
          fontSize: Dimensions.FONT_XL.sp,
        ),
        cursorColor: Colors.black,
        cursorWidth: 1.5.w,
        onChanged: (value) {

        },
        decoration: InputDecoration(
          contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
          hintStyle: gothamMedium.copyWith(
              color: Colors.grey,
              fontSize: Dimensions.FONT_XL.sp,
              fontWeight: FontWeight.w600
          ),
          hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_4_HINT_2 : IT.CREATE_COMPANY_PAGE_4_LABEL_4_HINT_2,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget mobileCodeField(BuildContext context) {
    return SizedBox(
      width: 50.w,
      child: TextFormField(
        controller: mobileCodeController,
        keyboardType: TextInputType.number,
        style: gothamMedium.copyWith(
          color: Colors.black,
          fontSize: Dimensions.FONT_XL.sp,
        ),
        maxLength: 4,
        //maxLengthEnforcement: MaxLengthEnforcement.,
        cursorColor: Colors.black,
        cursorWidth: 1.5.w,
        onChanged: (value) {

        },
        decoration: InputDecoration(
          counterText: "",
          contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
          hintStyle: gothamMedium.copyWith(
              color: Colors.grey,
              fontSize: Dimensions.FONT_XL.sp,
              fontWeight: FontWeight.w600
          ),
          hintText: Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_PAGE_4_LABEL_4_HINT_1 : IT.CREATE_COMPANY_PAGE_4_LABEL_4_HINT_1,
          fillColor: Colors.white,
        ),
      ),
    );
  }
  // fifth page fields starts

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
    if(responseCode == GET_COMPANY_CHECK) {
      setState(() {
        showLoader = false;
        var data = response[Constant.data];
        debugPrint("$TAG data isAccessible ======> ${data["isAccessible"]}");
      });

    } else if(responseCode == GET_PENSION_FUND) {
      setState(() {
        var listArray = response[Constant.data]["list"];
        socialSecurityMainArray.clear();
        socialSecurityStringArray.clear();
        for(int i =0; i < listArray.length; i++) {
          socialSecurityMainArray.add(listArray[i]);
          socialSecurityStringArray.add(listArray[i]["Description"]);
        }

        selectedSocialSecurity = listArray[0]["Description"];

        debugPrint("$TAG socialSecurityMainArray ======> ${socialSecurityMainArray.length}");
        debugPrint("$TAG socialSecurityStringArray ======> ${socialSecurityStringArray.length}");

      });
    } else if(responseCode == GET_COMPANY_COMBINATION) {
      setState(() {
        printTemplatesMainArray.clear();
        printTemplatesStringArray.clear();
        for(int i =0; i < response[Constant.data].length; i++) {
          printTemplatesMainArray.add(response[Constant.data][i]);
          printTemplatesStringArray.add(response[Constant.data][i]["name"]);
        }
        selectedPrintTemplates = response[Constant.data][0]["name"];

        debugPrint("$TAG printTemplatesMainArray ======> ${printTemplatesMainArray.length}");
        debugPrint("$TAG printTemplatesStringArray ======> ${printTemplatesStringArray.length}");
      });
    } else if(responseCode == SAVE_COMPANY_DATA) {
        setState(() {
          newCompanyId = response[Constant.data]["insertId"].toString();
          setCompany();

        });
    } else if(responseCode == SET_COMPANY_DATA) {
        updateCompany();
    } else if(responseCode == GET_UPDATE_NEW_COMPANY) {
        if(finalPrintTemplates != null) {
          insertCombination();
        } else {
          if (legalNameController.text.trim().toString().isNotEmpty) {
            enableSDI();
          } else {
            getUpdatedCompany();
          }
        }
    }else if(responseCode == SET_COMPANY_COMBINATION) {
      if (legalNameController.text.trim().toString().isNotEmpty) {
        enableSDI();
      } else {
        getUpdatedCompany();
      }
    } else if(responseCode == SDI_ENABLE) {
        updateEmail();
    } else if(responseCode == UPDATE_EMAIL) {
      getUpdatedCompany();
    } else if(responseCode == GET_UPDATED_COMPANY_DATA) {
      setState(() {
        showLoader = false;
        userModel?.currentCompany = CurrentCompany.fromJson(response["current_company"]);
        Utility.setStringSharedPreference(Constant.userObject, jsonEncode(userModel));
        currentCompanyId = userModel?.currentCompany?.id;
        debugPrint("$TAG GET UPDATED COMPANY DATA currentCompanyId ========> ${userModel?.currentCompany?.id}");
        debugPrint("$TAG GET UPDATED COMPANY DATA ========> page redirection");
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
      });
    }
  }

  void checkCanCreateCompany() {
    // https://devapi.paciolo.it/plan-subscription/check_access/company
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.checkAccessCreateCompany,
        token: userModel!.authorization,
        responseCode: GET_COMPANY_CHECK,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getPensionFund() {
    // https://devapi.paciolo.it/pension_fund

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.pensionFund,
        token: userModel!.authorization,
        responseCode: GET_PENSION_FUND,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getCompanyCombination() {
    // https://devapi.paciolo.it/company-option/get-combinations
    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.companyCombination,
        token: userModel!.authorization,
        body: jsonEncode({}),
        responseCode: GET_COMPANY_COMBINATION,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void saveCompanyData() {
    // https://devapi.paciolo.it/company/add
    setState(() {
      showLoader = true;
    });

    var body = jsonEncode({
      "name": businessNameController.text.trim().toString(),
      "logo": "",
      "cropped_logo": "",
      "subtitle": companyMottoController.text.trim().toString(),
      "vat": vatNumberController.text.trim().toString(),
      "withholding":"",
      "withholding_on":"",
      "contribution_text":"",
      "contribution_rate":"",
      "company_number": "",
      "website":"",
      "business_sector":"",
      "contribution_withholding": 0,
      "company_address1": addressController.text.trim().toString(),
      "company_address2": address2Controller.text.trim().toString(),
      "company_province": provinceAbbreviationController.text.trim().toString(),
      "company_zip": postalCodeController.text.trim().toString(),
      "company_city": cityController.text.trim().toString(),
      "company_state": stateInitialsController.text.trim().toString(),
      "multi_warehouse": 0,
      "tax_regime": finalTaxRegime,
      "pension_fund": finalSelectedSocialSecurity,
      "fiscal_code": "",
      "first_name": nameController.text.trim().toString(),
      "last_name": surNameController.text.trim().toString(),
      "companyAddressId":"",
      "emails[]": "",
      "warehouse_name[]":"",
      "with_holding": selectedWithholdingTax
    });

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.companyADD,
        token: userModel!.authorization,
        body: body,
        responseCode: SAVE_COMPANY_DATA,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void updateCompany() {
    // https://devapi.paciolo.it/company/update/2652

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.companyUpdate}$newCompanyId",
        token: userModel!.authorization,
        responseCode: GET_UPDATE_NEW_COMPANY,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void setCompany() {
    // https://devapi.paciolo.it/company/update/2652

    PutRequest request = PutRequest();
    request.getResponse(
        cmd: RequestCmd.setCompanyId,
        token: userModel!.authorization,
        body: json.encode({
          Constant.id : newCompanyId
        }),
        responseCode: SET_COMPANY_DATA,
        companyId: userModel!.currentCompany?.id);
    request.setListener(this);
  }

  void getAllNewsAlert() {
    // https://devapi.paciolo.it/news-alert/get-all-news-alert/2652
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.companyUpdate}$newCompanyId",
        token: userModel!.authorization,
        responseCode: GET_NEWS_ALERT,
        companyId: newCompanyId);
    request.setListener(this);
  }

  void insertCombination() {
    // https://devapi.paciolo.it/company-option/insert-combinations

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.insertCombination,
        token: userModel!.authorization,
        body: jsonEncode({
          "id": selectedPrintTemplates
        }),
        responseCode: SET_COMPANY_COMBINATION,
        companyId: newCompanyId);
    request.setListener(this);
  }

  void enableSDI() {
    // https://devapi.paciolo.it/sdi/enable

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.sdiEnable,
        token: userModel!.authorization,
        body: jsonEncode({
          "email": pecController.text.trim().toString(),
          "fiscal_code": taxCodeController.text.trim().toString(),
          "mobile_number": mobileController.text.trim().toString(),
          "mobile_number_prefix" : mobileCodeController.text.trim().toString(),
          "name": legalNameController.text.trim().toString()
        }),
        responseCode: SDI_ENABLE,
        companyId: newCompanyId);
    request.setListener(this);
  }

  void updateEmail() {
    // https://devapi.paciolo.it/user/update_email_option

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.userUpdateEmail,
        token: userModel!.authorization,
        body: jsonEncode({
          "email_recipient": emailController.text.trim().toString(),
          "is_email_recevied_invoice": receiveValue,
          "is_email_sdi": sendValue
        }),
        responseCode: UPDATE_EMAIL,
        companyId: newCompanyId);
    request.setListener(this);
  }

  void getUpdatedCompany() {

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.companyAll,
        token: userModel!.authorization,
        responseCode: GET_UPDATED_COMPANY_DATA,
        companyId: newCompanyId);
    request.setListener(this);
  }

}
