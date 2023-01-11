import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';
import 'package:permission_handler/permission_handler.dart';

import '../network/ResponseListener.dart';
import '../util/CommonCSS.dart';

class EditCompanyScreen extends StatefulWidget {
  const EditCompanyScreen({Key? key}) : super(key: key);

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> implements ResponseListener {

  String TAG = "_EditCompanyScreenState";
  var currentCompanyId;
  LoginUserModel? userModel;
  CurrentCompany? currentCompany;
  bool showLoader = false;
  var finalSelectedSocialSecurity;
  var finalTaxRegime;
  int? finalPrintTemplates;
  var companyAddressId;
  String? imageString;

  TextEditingController page2BusinessNameController = TextEditingController();
  TextEditingController companyMottoController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController surNameController = TextEditingController();
  TextEditingController vatNumberController = TextEditingController();
  TextEditingController taxCodeController = TextEditingController();

  TextEditingController phoneController = TextEditingController();
  TextEditingController websiteController = TextEditingController();

  TextEditingController addressController = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController provinceAbbreviationController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateInitialsController = TextEditingController();


  String? selectedTaxRegime;
  String? selectedSocialSecurity;
  List<String> socialSecurityStringArray = List.from([]);
  List socialSecurityMainArray = List.from([]);
  String? selectedPrintTemplates;
  List<String> printTemplatesStringArray = List.from([]);
  List printTemplatesMainArray = List.from([]);

  var GET_PENSION_FUND = 3001;
  var GET_COMPANY_COMBINATION = 3002;
  var GET_COMPANY_DETAILS = 3003;
  var SAVE_COMPANY_DATA = 4444;
  var MULTI_SAVE_COMPANY_DATA = 5555;
  var DELETE_COMPANY = 3004;

  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;
  dynamic _retrieveDataError;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompany = userModel!.currentCompany;
      currentCompanyId = currentCompany?.id;

      page2BusinessNameController = TextEditingController(text: currentCompany?.name.toString());
      if(currentCompany?.subtitle != null) {
        companyMottoController = TextEditingController(text: currentCompany?.subtitle.toString());
      } else {
        companyMottoController = TextEditingController(text: "");
      }
      if(currentCompany?.vat != null) {
        vatNumberController = TextEditingController(text: currentCompany?.vat.toString());
      } else {
        vatNumberController = TextEditingController(text: "");
      }
      if(currentCompany?.firstName != null) {
        nameController = TextEditingController(text: currentCompany?.firstName.toString());
      } else {
        nameController = TextEditingController(text: "");
      }
      if(currentCompany?.lastName != null) {
        surNameController = TextEditingController(text: currentCompany?.lastName.toString());
      } else {
        surNameController = TextEditingController(text: "");
      }
      if(currentCompany?.fiscalCode != null) {
        taxCodeController = TextEditingController(text: currentCompany?.fiscalCode.toString());
      } else {
        taxCodeController = TextEditingController(text: "");
      }


      if(currentCompany?.taxRegime != null) {
        for(int i = 0; i < IT.taxRegime.length; i++) {
          if(IT.taxRegime[i].id == currentCompany?.taxRegime) {
            selectedTaxRegime = IT.taxRegime[i].value;
            break;
          }
        }
      } else {
        selectedTaxRegime = IT.taxRegimeStringArray[0];
      }
      getCompanyDetails();
      getPensionFund();
      getCompanyCombination();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Constant.LANG == Constant.EN ? ENG.OTHERS_EDIT_COMPANY : IT.OTHERS_EDIT_COMPANY,
          style: gothamRegular.copyWith(
            fontSize: Dimensions.FONT_L,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              resetAllFields();
            },
            child: Container(
              padding: const EdgeInsets.only(right: Dimensions.PADDING_S, left: Dimensions.PADDING_S),
              child: Center(
                child: Text(
                  Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_RESET : IT.EDIT_COMPANY_RESET,
                  style: gothamBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.FONT_L.sp,
                      letterSpacing: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ModalProgressHUD(
        opacity: 0.7,
        inAsyncCall: showLoader,
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
                    const SizedBox(height: Dimensions.PADDING_L),
                    Center(
                      child: Text(
                        Constant.LANG == Constant.EN ? ENG.OTHERS_EDIT_COMPANY : IT.OTHERS_EDIT_COMPANY,
                        style: gothamMedium.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_XL,
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),

                    Center(
                      child: SizedBox(
                        height: 110.h,
                        width: 110.h,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          color: Colors.orangeAccent,
                          shape: CircleBorder(
                            side: BorderSide(
                              width: 1.w,
                              color:
                              const Color(0xFF95989A),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              height: 100.h,
                              width: 100.h,
                              margin: const EdgeInsets.all(1.0),
                              child: imageString != null ? Image.memory(base64Decode(imageString!)) : Container(),
                            ),
                          ),
                        )
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // business name
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_1_LABEL_1_HEADING : IT.EDIT_COMPANY_PAGE_1_LABEL_1_HEADING,
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
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_2_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_2_HEADING,
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
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_3_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_3_HEADING,
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
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_4_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_4_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    surNameField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // surname
                    const Divider(height: 1, color: Colors.black54,),
                    const SizedBox(height: Dimensions.PADDING_L),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_INFORMATION : IT.EDIT_COMPANY_INFORMATION,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_XL,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // vat number
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_1_LABEL_2_HEADING : IT.EDIT_COMPANY_PAGE_1_LABEL_2_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    vatNumberField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // vat number
                    // Tax code of the legal
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_4_LABEL_3_HEADING : IT.EDIT_COMPANY_PAGE_4_LABEL_3_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    taxCodeField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // Tax code of the legal
                    const Divider(height: 1, color: Colors.black54,),
                    const SizedBox(height: Dimensions.PADDING_L),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PHONE : IT.EDIT_COMPANY_PHONE,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    phoneField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    const Divider(height: 1, color: Colors.black54,),
                    const SizedBox(height: Dimensions.PADDING_L),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_WEBSITE : IT.EDIT_COMPANY_WEBSITE,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    websiteField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    const Divider(height: 1, color: Colors.black54,),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // address
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_5_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_5_HEADING,
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
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_6_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_6_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    address2Field(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // address 2
                    // province abbreviation
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_8_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_8_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    provinceAbbreviationField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // province abbreviation
                    // postal code
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_10_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_10_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    postalCodeField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // postal code
                    // city
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_7_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_7_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    cityField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // city
                    // state initials
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_9_HEADING : IT.EDIT_COMPANY_PAGE_2_LABEL_9_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    stateInitialsField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // state initials
                    const Divider(height: 1, color: Colors.black54,),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // tax drop down
                    Text(
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_3_LABEL_1_HEADING : IT.EDIT_COMPANY_PAGE_3_LABEL_1_HEADING,
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
                      Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_3_LABEL_2_HEADING : IT.EDIT_COMPANY_PAGE_3_LABEL_2_HEADING,
                      style: gothamMedium.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    socialSecurityFundDropDown(),
                    const SizedBox(height: Dimensions.PADDING_L),
                    const Divider(height: 1, color: Colors.black54,),

                    // delete button
                    const SizedBox(height: Dimensions.PADDING_L),
                    Visibility(
                      visible: false,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          showAlertDialog(context);
                        },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(AllColors.colorRed),
                                width: 1.0.w
                              ),
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(5.r)),
                          child: Center(
                            child: Text(
                              Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_DELETE_ENTER : IT.EDIT_COMPANY_DELETE_ENTER,
                              style: gothamBold.copyWith(
                                color: const Color(AllColors.colorRed),
                                fontSize: Dimensions.FONT_XL.sp,
                                letterSpacing: 0.5
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    //SizedBox(height: Dimensions.PADDING_L),
                    // reset button
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        resetAllFields();
                      },
                      child: Container(
                        height: 50.h,
                        width: double.infinity,
                        decoration: CommonCSS.buttonDecoration(true, 5.r, AllColors.colorBlue, 0.5, 0),
                        child: Center(
                          child: Text(
                            Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_RESET_FIELDS : IT.EDIT_COMPANY_RESET_FIELDS,
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
                        if(page2BusinessNameController.text.trim().toString().isEmpty) {
                          Utility.showToast(Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_1_LABEL_1_ERROR : IT.EDIT_COMPANY_PAGE_1_LABEL_1_ERROR);
                        } else if(page2BusinessNameController.text.trim().toString().isNotEmpty &&
                            page2BusinessNameController.text.trim().toString().length < 3) {
                          Utility.showToast(Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_1_LABEL_1_ERROR_1 : IT.EDIT_COMPANY_PAGE_1_LABEL_1_ERROR_1);
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
                            Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_SAVE_DATA : IT.EDIT_COMPANY_SAVE_DATA,
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
    );
  }

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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),

        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_1_LABEL_1_HINT : IT.EDIT_COMPANY_PAGE_1_LABEL_1_HINT,
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_2_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_2_HINT,
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_3_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_3_HINT,
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_4_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_4_HINT,
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_1_LABEL_2_HINT : IT.EDIT_COMPANY_PAGE_1_LABEL_2_HINT,
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_4_LABEL_3_HINT : IT.EDIT_COMPANY_PAGE_4_LABEL_3_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget phoneField(BuildContext context) {
    return TextFormField(
      controller: phoneController,
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
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PHONE_LABEL_HINT : IT.EDIT_COMPANY_PHONE_LABEL_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget websiteField(BuildContext context) {
    return TextFormField(
      controller: websiteController,
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
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_WEBSITE_LABEL_HINT : IT.EDIT_COMPANY_WEBSITE_LABEL_HINT,
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
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_5_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_5_HINT,
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
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_6_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_6_HINT,
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
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_8_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_8_HINT,
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
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_10_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_10_HINT,
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
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_7_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_7_HINT,
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
        hintText: Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_2_LABEL_9_HINT : IT.EDIT_COMPANY_PAGE_2_LABEL_9_HINT,
        fillColor: Colors.white,
      ),
    );
  }

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
                Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_3_HINT_1 : IT.EDIT_COMPANY_PAGE_3_HINT_1,
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
                Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_PAGE_3_HINT_1 : IT.EDIT_COMPANY_PAGE_3_HINT_1,
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
    if(responseCode == GET_PENSION_FUND) {
      setState(() {
        showLoader = false;
        var listArray = response[Constant.data]["list"];
        socialSecurityMainArray.clear();
        socialSecurityStringArray.clear();
        for(int i =0; i < listArray.length; i++) {
          socialSecurityMainArray.add(listArray[i]);
          socialSecurityStringArray.add(listArray[i]["Description"]);
          if(currentCompany?.pensionFund != null) {
            if(listArray[i]["Id"] == currentCompany?.pensionFund) {
              selectedSocialSecurity = listArray[i]["Description"];
            }
          }
        }

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
    } else if(responseCode == GET_COMPANY_DETAILS) {
      setState(() {

        if(response[Constant.data]["company"]["logo_uri"] != null && response[Constant.data]["company"]["logo_uri"] != "") {
          String imageData = response[Constant.data]["company"]["logo_uri"];
          if(imageData.contains("data:image/jpg;base64,")) {
            imageString = imageData.replaceAll("data:image/jpg;base64,", "");
          } else if(imageData.contains("data:image/png;base64,")) {
            imageString = imageData.replaceAll("data:image/png;base64,", "");
          }
        } else {
          imageString = null;
        }

        var companyAddress = response[Constant.data]["companyAddressDetails"];
        companyAddressId = companyAddress["company_address_id"];
        debugPrint("$TAG companyAddress[company_address_id] =========> ${companyAddress["company_address_id"]}");
        debugPrint("$TAG companyAddress[company_zip] =========> ${companyAddress["company_zip"]}");
        debugPrint("$TAG companyAddress[company_city] =========> ${companyAddress["company_city"]}");

        if(companyAddress["company_address1"] != null) {
          addressController = TextEditingController(text: companyAddress["company_address1"].toString());
          addressController.text = companyAddress["company_address1"].toString();
        } else {
          addressController = TextEditingController(text: "");
        }
        if(companyAddress["company_address2"] != null) {
          address2Controller = TextEditingController(text: companyAddress["company_address2"].toString());
          address2Controller.text = companyAddress["company_address2"].toString();
        } else {
          address2Controller = TextEditingController(text: "");
        }
        if(companyAddress["company_province"] != null) {
          provinceAbbreviationController = TextEditingController(text: companyAddress["company_province"].toString());
          provinceAbbreviationController.text = companyAddress["company_province"].toString();
        } else {
          provinceAbbreviationController = TextEditingController(text: "");
        }
        if(companyAddress["company_zip"] != null) {
          postalCodeController = TextEditingController(text: companyAddress["company_zip"].toString());
          postalCodeController.text = companyAddress["company_zip"].toString();
        } else {
          postalCodeController = TextEditingController(text: "");
        }
        if(companyAddress["company_city"] != null) {
          cityController = TextEditingController(text: companyAddress["company_city"].toString());
          cityController.text = companyAddress["company_city"].toString();
        } else {
          cityController = TextEditingController(text: "");
        }
        if(companyAddress["company_state"] != null) {
          stateInitialsController = TextEditingController(text: companyAddress["company_state"].toString());
          stateInitialsController.text = companyAddress["company_state"].toString();
        } else {
          stateInitialsController = TextEditingController(text: "");
        }
      });
    } else if(responseCode == SAVE_COMPANY_DATA) {
      Utility.showToast(Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_UPDATED : IT.EDIT_COMPANY_UPDATED);
    } else if (responseCode == MULTI_SAVE_COMPANY_DATA) {
      Utility.showToast(Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_UPDATED : IT.EDIT_COMPANY_UPDATED);
    } else if (responseCode == DELETE_COMPANY) {
      Utility.showToast(Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_DELETED : IT.EDIT_COMPANY_DELETED);
    }
  }

  void getCompanyDetails() {
    // https://devapi.paciolo.it/company/update/318
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.companyUpdate}$currentCompanyId",
        token: userModel!.authorization,
        responseCode: GET_COMPANY_DETAILS,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getPensionFund() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.pensionFund,
        token: userModel!.authorization,
        responseCode: GET_PENSION_FUND,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getCompanyCombination() {

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.companyCombination,
        token: userModel!.authorization,
        body: jsonEncode({}),
        responseCode: GET_COMPANY_COMBINATION,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void deleteCompany() {
    // https://devapi.paciolo.it/company/2654
    PostRequest request = PostRequest();
    request.getResponse(
        cmd: "${RequestCmd.deleteCompany}$currentCompanyId",
        token: userModel!.authorization,
        body: jsonEncode({}),
        responseCode: DELETE_COMPANY,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void saveCompanyData() {
    setState(() {
      showLoader = true;
    });

    var body = jsonEncode({
    "name": page2BusinessNameController.text.trim().toString(),
    "logo": "",
    "cropped_logo": "",
    "subtitle": companyMottoController.text.trim().toString(),
    "vat": vatNumberController.text.trim().toString(),
    "withholding": "",
    "withholding_on": "",
    "contribution_text": "",
    "contribution_rate": "",
    "company_number": phoneController.text.trim().toString(),
    "website": websiteController.text.trim().toString(),
    "business_sector": 0,
    "contribution_withholding": 0,
    "company_address1": addressController.text.trim().toString(),
    "company_address2": address2Controller.text.trim().toString(),
    "company_province":provinceAbbreviationController.text.trim().toString(),
    "company_zip": postalCodeController.text.trim().toString(),
    "company_city": cityController.text.trim().toString(),
    "company_state": stateInitialsController.text.trim().toString(),
    "multi_warehouse": 0,
    "tax_regime": finalTaxRegime,
    "pension_fund": finalSelectedSocialSecurity,
    "fiscal_code": taxCodeController.text.trim().toString(),
    "first_name": nameController.text.trim().toString(),
    "last_name": surNameController.text.trim().toString(),
    "companyAddressId": companyAddressId,
    "id": currentCompanyId,
    });

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: "${RequestCmd.getCurrentCompany}$currentCompanyId",
        token: userModel!.authorization,
        body: body,
        responseCode: SAVE_COMPANY_DATA,
        companyId: currentCompanyId);
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _setImageFileListFromFile(response.file);
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Future<void> imageSelection() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      setState(() {
        selectedImage = pickedFile;
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  void _setImageFileListFromFile(XFile? value) {
    selectedImage = value;
  }

  void requestPermission(BuildContext context) async {
    Permission permission = Permission.photos;
    final status = await permission.request();

    debugPrint("$TAG requestPermission =====> $status");
    if (status == PermissionStatus.granted) {
      imageSelection();
    } else {
      permissionsDenied(context);
    }
    // await SuperEasyPermissions.askPermission(Permissions.photos).then((result) async {
    //   if (result) {
    //     imageSelection();
    //   } else {
    //     bool result_2 = await SuperEasyPermissions.askPermission(Permissions.camera);
    //     if (result_2) {
    //       imageSelection();
    //     } else {
    //       permissionsDenied(context);
    //     }
    //   }
    // });
  }

  void permissionsDenied(BuildContext context) {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Permission denied",
          style: gothamRegular.copyWith(
            fontSize: Dimensions.FONT_XL,
            color: Colors.black87
          ),
        ),
        content: Container(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
          child: Text(
            "You must grant all permissions to change company profile picture",
            style: gothamRegular.copyWith(
              fontSize: Dimensions.FONT_L,
              color: Colors.black87
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: Text(
              "OK",
              style: gothamRegular.copyWith(
                fontSize: Dimensions.FONT_L,
                color: Colors.black87
              ),
            ),
          ),
        ],
      );
    });
  }

  void resetAllFields() {
    setState(() {
      page2BusinessNameController.clear();
      companyMottoController.clear();
      nameController.clear();
      surNameController.clear();
      vatNumberController.clear();
      taxCodeController.clear();
      phoneController.clear();
      websiteController.clear();
      addressController.clear();
      address2Controller.clear();
      provinceAbbreviationController.clear();
      postalCodeController.clear();
      cityController.clear();
      stateInitialsController.clear();
    });
  }

  showAlertDialog(BuildContext context) {
    // set up the AlertDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(Constant.LANG == Constant.EN ? ENG.EDIT_COMPANY_DELETE_ALERT : IT.EDIT_COMPANY_DELETE_ALERT),
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
                deleteCompany();
              },
            )
          ],
        );
      },
    );
  }

}
