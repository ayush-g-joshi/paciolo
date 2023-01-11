
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';

import '../auth/login_screen.dart';
import '../childscreens/CustomerSupplierScreen.dart';
import '../childscreens/NewAddressScreen.dart';
import '../childscreens/NewEmailScreen.dart';
import '../model/LoginUserModel.dart';
import '../util/CommonCSS.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';

class CreateCustomerScreen extends StatefulWidget {
  const CreateCustomerScreen({Key? key}) : super(key: key);

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> implements ResponseListener {

  String TAG = "_CreateCustomerState";
  bool showLoader = false;
  var currentCompanyId;
  LoginUserModel? userModel;
  CurrentCompany? currentCompany;

  TextEditingController agencyNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cellPhoneController = TextEditingController();
  TextEditingController fiscalCodeController = TextEditingController();
  TextEditingController vatNumberController = TextEditingController();
  TextEditingController sdiCodeController = TextEditingController();
  TextEditingController emailPECController = TextEditingController();

  TextEditingController priceListController = TextEditingController();
  TextEditingController customerSupplierController = TextEditingController();
  TextEditingController localHashTagController = TextEditingController();
  TextEditingController addAddressController = TextEditingController();

  List addressArray = List.from([]);
  List emailArray = List.from([]);
  List<String> localHashTagsList = List.from([]);

  var filterCustomerSupplierResult;
  int? selectedCustomerSupplierId;
  List customerSupplier = IT.customerSupplier;
  bool buttonEnable = false;
  final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
  int customer = 0;
  int supplier = 0;
  String finalLocalHashTags = "";
  var SAVE_CUSTOMER = 1000;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompany = userModel!.currentCompany;
      currentCompanyId = currentCompany?.id;
      customerSupplier = IT.customerSupplier;

      customer = 1;
      supplier = 1;
      customerSupplierController.text = customerSupplier[2];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(AllColors.colorBlue),
        title: Text(
          Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_TITLE : IT.CUSTOMER_CREATE_TITLE,
          style: gothamMedium.copyWith(
              color: Colors.white,
              fontSize: Dimensions.FONT_L
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              resetAllFields();
            },
            child: Container(
              padding: const EdgeInsets.only(
                  right: Dimensions.PADDING_S, left: Dimensions.PADDING_S),
              child: Center(
                child: Text(
                  Constant.LANG == Constant.EN
                      ? ENG.CUSTOMER_CREATE_RESET
                      : IT.CUSTOMER_CREATE_RESET,
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
                      // agency name
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_1 : IT.CUSTOMER_CREATE_PROFILE_LABEL_1,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      agencyNameField(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // agency name
                      // email
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_2 : IT.CUSTOMER_CREATE_PROFILE_LABEL_2,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      emailField(context),
                      const SizedBox(height: Dimensions.PADDING_S),
                      // address
                      // address list
                      showEmailList(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // email
                      // phone
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_3 : IT.CUSTOMER_CREATE_PROFILE_LABEL_3,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      phoneField(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // phone
                      // cell phone
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_4 : IT.CUSTOMER_CREATE_PROFILE_LABEL_4,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      cellPhoneField(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // cell phone
                      // fiscal code
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_5 : IT.CUSTOMER_CREATE_PROFILE_LABEL_5,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      fiscalCodeField(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // fiscal code
                      // vat number
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_6 : IT.CUSTOMER_CREATE_PROFILE_LABEL_6,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      vatNumberField(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // vat number
                      // sdi code
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_7 : IT.CUSTOMER_CREATE_PROFILE_LABEL_7,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      sdiCodeField(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // sdi code
                      // email pec
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_8 : IT.CUSTOMER_CREATE_PROFILE_LABEL_8,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      emailPECField(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // email pec
                      // Customer or Supplier
                      Text(
                        Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_10 : IT.CUSTOMER_CREATE_PROFILE_LABEL_10,
                        style: gothamMedium.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      customerSupplierField(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // Customer or Supplier
                      // local hash tags
                      localHashTag(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // local hash tags
                      // address
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Constant.LANG == Constant.EN ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_13 : IT.CUSTOMER_EDIT_PROFILE_LABEL_13,
                            textAlign: TextAlign.left,
                            style: gothamMedium.copyWith(
                              color: const Color(AllColors.colorText),
                              fontSize: Dimensions.FONT_L,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return NewAddressScreen(addressData: null, customerId: null,);
                              },
                              ));

                              setState(() {
                                if (result != null) {
                                  debugPrint("$TAG add Address Field Result ======> $result");
                                  addressArray.add(result);
                                  if(addressArray.isNotEmpty && agencyNameController.text.toString().trim().isNotEmpty) {
                                    buttonEnable = true;
                                  }
                                }
                              });
                            },
                            child: Text(
                              Constant.LANG == Constant.EN ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_13_HINT : IT.CUSTOMER_EDIT_PROFILE_LABEL_13_HINT,
                              textAlign: TextAlign.right,
                              style: gothamMedium.copyWith(
                                color: Colors.blue,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      //addAddressField(context),
                      const SizedBox(height: Dimensions.PADDING_S),
                      // address
                      // address list
                      showAddressList(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      const SizedBox(height: Dimensions.PADDING_L),
                      InkWell(
                        onTap: () {
                          if(buttonEnable) {
                            saveCustomerData();
                          }
                        },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: Dimensions.PADDING_M),
                          decoration: CommonCSS.buttonDecoration(buttonEnable, 5.r, AllColors.colorGreen, 0.5, 0),
                          child: Center(
                              child: Text(
                                Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_SAVE_BUTTON : IT.CUSTOMER_CREATE_PROFILE_SAVE_BUTTON,
                                style: gothamBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.FONT_L
                                ),
                              )
                          ),
                        ),
                      )
                    ]
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget agencyNameField(BuildContext context) {
    return TextFormField(
      controller: agencyNameController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
      cursorWidth: 1.5.w,
      onChanged: (value) {
        setState(() {
          if(agencyNameController.text.toString().trim().isNotEmpty) {
            if(agencyNameController.text.toString().trim().length >= 5 && addressArray.isNotEmpty) {
              buttonEnable = true;
            } else {
              buttonEnable = false;
              Utility.showToast(Constant.LANG == Constant.EN ? ENG.CUSTOMER_EDIT_PROFILE_ERROR_1 : IT.CUSTOMER_EDIT_PROFILE_ERROR_1);
            }
          } else {
            buttonEnable = false;
          }
        });
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
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_1 : IT.CUSTOMER_CREATE_PROFILE_LABEL_1,
        fillColor: Colors.white,
      ),
    );
  }

  Widget emailField(BuildContext context) {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.text,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
      cursorWidth: 1.5.w,
      onTap: () async {
        var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NewEmailScreen(emailData: null, customerId: null,);
        },
        ));
        setState(() {
          if (result != null) {
            debugPrint("$TAG add email Field Result ======> $result");
            emailArray.add(result);
          }
        });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.arrow_forward_ios, color: Colors.blue,),
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
            color: Colors.blue,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_EMAIL_ADDRESS_TITLE : IT.ADD_EMAIL_ADDRESS_TITLE,
        fillColor: Colors.white,
      ),
    );
  }

  Widget showEmailList(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: emailArray.length,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(height: 1, color: Color(AllColors.colorText),);
      },
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.PADDING_XS,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return NewEmailScreen(emailData: emailArray[index], customerId: null,);
                      },
                      ));
                      setState(() {
                        if (result != null) {
                          debugPrint("$TAG add Address Field Result ======> $result");
                          emailArray.removeAt(index);
                          emailArray.add(result);
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Color(AllColors.colorBlue),
                    ),
                  ),
                  const SizedBox(width: Dimensions.PADDING_S,),
                  if(index > 0)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          emailArray.removeAt(index);
                        });
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Color(AllColors.colorRed),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.PADDING_XS,),
              Text(
                "Email: ${emailArray[index]["email"]}",
                overflow: TextOverflow.ellipsis,
                style: gothamRegular.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: Dimensions.FONT_M,
                  color: const Color(AllColors.colorText),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS,),
            ],
          ),
        );
      },
    );
  }

  Widget phoneField(BuildContext context) {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
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
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_3 : IT.CUSTOMER_CREATE_PROFILE_LABEL_3,
        fillColor: Colors.white,
      ),
    );
  }

  Widget cellPhoneField(BuildContext context) {
    return TextFormField(
      controller: cellPhoneController,
      keyboardType: TextInputType.phone,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
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
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_4 : IT.CUSTOMER_CREATE_PROFILE_LABEL_4,
        fillColor: Colors.white,
      ),
    );
  }

  Widget fiscalCodeField(BuildContext context) {
    return TextFormField(
      controller: fiscalCodeController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
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
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_5 : IT.CUSTOMER_CREATE_PROFILE_LABEL_5,
        fillColor: Colors.white,
      ),
    );
  }

  Widget vatNumberField(BuildContext context) {
    return TextFormField(
      controller: vatNumberController,
      keyboardType: TextInputType.number,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
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
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_6 : IT.CUSTOMER_CREATE_PROFILE_LABEL_6,
        fillColor: Colors.white,
      ),
    );
  }

  Widget sdiCodeField(BuildContext context) {
    return TextFormField(
      controller: sdiCodeController,
      keyboardType: TextInputType.text,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
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
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_7 : IT.CUSTOMER_CREATE_PROFILE_LABEL_7,
        fillColor: Colors.white,
      ),
    );
  }

  Widget emailPECField(BuildContext context) {
    return TextFormField(
      controller: emailPECController,
      keyboardType: TextInputType.emailAddress,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
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
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_8 : IT.CUSTOMER_CREATE_PROFILE_LABEL_8,
        fillColor: Colors.white,
      ),
    );
  }

  Widget customerSupplierField(BuildContext context) {
    return TextFormField(
      controller: customerSupplierController,
      keyboardType: TextInputType.text,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
      cursorWidth: 1.5.w,
      onTap: () async {
        var result =
        await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return CustomerSupplierScreen(customerId: null);
          },
        ));

        setState(() {
          if (result != null) {
            filterCustomerSupplierResult = result;
            debugPrint("$TAG filter customer Result ======> $filterCustomerSupplierResult");
            customerSupplierController.text = filterCustomerSupplierResult["name"].toString();
            if(filterCustomerSupplierResult["name"].toString() == customerSupplier[0]) {
              customer = 1;
              supplier = 0;
            } else if(filterCustomerSupplierResult["name"].toString() == customerSupplier[1]) {
              customer = 0;
              supplier = 1;
            } else {
              customer = 1;
              supplier = 1;
            }
          }
        });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.arrow_forward_ios),
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
        fillColor: Colors.white,
      ),
    );
  }

  Widget localHashTag(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_11 : IT.CUSTOMER_CREATE_PROFILE_LABEL_11,
          style: gothamMedium.copyWith(
            color: const Color(AllColors.colorText),
            fontSize: Dimensions.FONT_L,
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_XS),
        localHashTagField(context),
        const SizedBox(height: Dimensions.PADDING_L),
        // used for testing purpose added on 20-10-2022 by Nilesh if not works then remove it
        localHashTags(context),
        Visibility(
          visible: false,
          child: Container(
            height: Dimensions.PADDING_4XL,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(
              top: Dimensions.PADDING_XS,
              bottom: Dimensions.PADDING_XS,
            ),
            decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(AllColors.colorGrey).withOpacity(0.7),
                  width: 1.0,
                )
            ),
            child: ListView.builder(
              itemCount: localHashTagsList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(
                    left: Dimensions.PADDING_XS,
                    right: Dimensions.PADDING_XS,
                  ),
                  padding: const EdgeInsets.only(
                      left: Dimensions.PADDING_S,
                      right: Dimensions.PADDING_XS
                  ),
                  decoration: const BoxDecoration(
                    color: Color(AllColors.colorBlue),
                    borderRadius: BorderRadius.all(
                        Radius.circular(Dimensions.PADDING_S)
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        localHashTagsList[index],
                        style: gothamMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.FONT_M,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: Dimensions.PADDING_XS,),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            localHashTagsList.removeAt(index);
                            debugPrint("$TAG Local Hash Tags List ======> ${localHashTagsList.length}");

                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget localHashTagField(BuildContext context) {
    return TextFormField(
      controller: localHashTagController,
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter(RegExp(r'\s'), allow: false),
      ],
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
      cursorWidth: 1.5.w,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              if(localHashTagController.text.toString().trim().isNotEmpty) {
                bool isExist = false;
                for(int i = 0; i < localHashTagsList.length; i++) {
                  if(localHashTagsList[i] == localHashTagController.text.toString().trim()) {
                    isExist = true;
                  } else if(localHashTagsList[i] == "#${localHashTagController.text.toString().trim()}") {
                    isExist = true;
                  } if(localHashTagsList[i] == localHashTagController.text.toString().trim().toLowerCase()) {
                    isExist = true;
                  } else if(localHashTagsList[i] == "#${localHashTagController.text.toString().trim().toLowerCase()}") {
                    isExist = true;
                  } else if(localHashTagsList[i] == localHashTagController.text.toString().trim().toUpperCase()) {
                    isExist = true;
                  } else if(localHashTagsList[i] == "#${localHashTagController.text.toString().trim().toUpperCase()}") {
                    isExist = true;
                  }
                }
                if(isExist) {
                  debugPrint("$TAG data is exist in array list");
                  Utility.showToast(Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_11_ERROR : IT.CUSTOMER_CREATE_PROFILE_LABEL_11_ERROR);
                } else {
                  debugPrint("$TAG data is not exist in array list");
                  if(localHashTagController.text.toString().trim().contains("#")) {
                    localHashTagsList.add(localHashTagController.text.toString().trim());
                    localHashTagController.clear();
                    debugPrint("$TAG local HashTags List to String =======> ${localHashTagsList.join(" ")}");
                    finalLocalHashTags = localHashTagsList.join(" ");
                  } else {
                    String value = "#${localHashTagController.text.toString().trim()}";
                    localHashTagsList.add(value);
                    localHashTagController.clear();
                    debugPrint("$TAG local HashTags List to String =======> ${localHashTagsList.join(" ")}");
                    finalLocalHashTags = localHashTagsList.join(" ");
                  }
                  isExist = false;
                }
              }
            });
          },
          icon: const Icon(Icons.task_alt_sharp, color: Color(AllColors.colorGreen),),
        ),
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
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_11 : IT.CUSTOMER_CREATE_PROFILE_LABEL_11,
        fillColor: Colors.white,
      ),
    );
  }

  Widget addAddressField(BuildContext context) {
    return TextFormField(
      controller: addAddressController,
      keyboardType: TextInputType.text,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
      cursorWidth: 1.5.w,
      onTap: () async {
        var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NewAddressScreen(addressData: null, customerId: null,);
        },
        ));

        setState(() {
          if (result != null) {
            debugPrint("$TAG add Address Field Result ======> $result");
            addressArray.add(result);
            if(addressArray.isNotEmpty && agencyNameController.text.toString().trim().isNotEmpty) {
              buttonEnable = true;
            }
          }
        });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.arrow_forward_ios, color: Colors.blue,),
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
            color: Colors.blue,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMER_CREATE_PROFILE_LABEL_13_HINT : IT.CUSTOMER_CREATE_PROFILE_LABEL_13_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget showAddressList(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addressArray.length,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(height: 1, color: Color(AllColors.colorText),);
      },
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.PADDING_XS,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      var result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return NewAddressScreen(addressData: addressArray[index], customerId: null,);
                      },
                      ));
                      setState(() {
                        if (result != null) {
                          debugPrint("$TAG add Address Field Result ======> $result");
                          addressArray.removeAt(index);
                          addressArray.add(result);
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Color(AllColors.colorBlue),
                    ),
                  ),
                  const SizedBox(width: Dimensions.PADDING_S,),
                  //if(index > 0)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          addressArray.removeAt(index);
                        });
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Color(AllColors.colorRed),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.PADDING_XS,),
              Text(
                "Address 1: ${addressArray[index]["address1"]}",
                overflow: TextOverflow.ellipsis,
                style: gothamRegular.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: Dimensions.FONT_M,
                  color: const Color(AllColors.colorText),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS,),
              Text(
                "Address 2: ${addressArray[index]["address2"]}",
                overflow: TextOverflow.ellipsis,
                style: gothamRegular.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: Dimensions.FONT_M,
                  color: const Color(AllColors.colorText),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS,),
              Text(
                "City: ${addressArray[index]["city"]}",
                overflow: TextOverflow.ellipsis,
                style: gothamRegular.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: Dimensions.FONT_M,
                  color: const Color(AllColors.colorText),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_XS,),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Province: ${addressArray[index]["country"]}",
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.FONT_M,
                        color: const Color(AllColors.colorText),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Country: ${addressArray[index]["state"]}",
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.FONT_M,
                        color: const Color(AllColors.colorText),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.PADDING_XS,),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Type: ${addressArray[index]["type_name"]}",
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.FONT_M,
                        color: const Color(AllColors.colorText),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "ZIP: ${addressArray[index]["zip"]}",
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.FONT_M,
                        color: const Color(AllColors.colorText),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.PADDING_XS,),
            ],
          ),
        );
      },
    );
  }

  Widget localHashTags(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Tags(
            key:_tagStateKey,
            itemCount: localHashTagsList.length,
            symmetry: false,
            columns: 0,
            alignment: WrapAlignment.start,
            itemBuilder: (index) {
              return ItemTags(
                key: Key(index.toString()),
                index: index,
                active: true,
                pressEnabled: false,
                activeColor: const Color(AllColors.colorBlue),
                textStyle: gothamMedium.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.FONT_M,
                    fontWeight: FontWeight.bold
                ),
                title: localHashTagsList[index],
                removeButton: ItemTagsRemoveButton(
                    backgroundColor: const Color(AllColors.colorBlue),
                    margin: EdgeInsets.zero,
                    size: 16,
                    onRemoved: () {
                      setState(() {
                        localHashTagsList.removeAt(index);
                      });
                      return true;
                    }
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void saveCustomerData() {
    // https://devapi.paciolo.it/customer/18536 use PUT
    setState(() {
      showLoader = true;

      for(int i = 0; i < emailArray.length; i++) {
        Map<String, dynamic> mapData = emailArray[i];
        mapData.remove("created_at");
        mapData.remove("updated_at");
        emailArray.removeAt(i);
        emailArray.add(mapData);
      }

      debugPrint("$TAG email array changed ========> ${emailArray.toString()}");

      for(int i = 0; i < addressArray.length; i++) {
        Map<String, dynamic> mapData = addressArray[i];
        mapData.remove("created_at");
        mapData.remove("updated_at");
        addressArray.removeAt(i);
        addressArray.add(mapData);
      }
      debugPrint("$TAG address array changed ========> ${addressArray.toString()}");

      finalLocalHashTags = localHashTagsList.join(" ");
      debugPrint("$TAG final Local Hash Tags ========> $finalLocalHashTags");
    });

    var body = jsonEncode({
      "first_name": "",
      "last_name": "",
      "company_name": agencyNameController.text.toString().trim(),
      "contact_type": "",
      "companyemail": emailArray[0]["email"],
      "emails": emailArray,
      "phone1": phoneController.text.toString().trim(),
      "phone2": cellPhoneController.text.toString().trim(),
      "fiscal_code": fiscalCodeController.text.toString().trim(),
      "vat_number": vatNumberController.text.toString().trim(),
      "address1": addressArray[0]["address1"],
      "address2": addressArray[0]["address2"],
      "country": addressArray[0]["country"],
      "zip": addressArray[0]["zip"],
      "city": addressArray[0]["city"],
      "state": addressArray[0]["state"],
      "is_customer": customer,
      "is_supplier": supplier,
      "customer_hashtag": finalLocalHashTags,
      "recipient_code": sdiCodeController.text.toString().trim(),
      "email_pec": emailPECController.text.toString().trim(),
      "address_array": addressArray,
      "tarifId": null,
    });

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.saveCustomer,
        token: userModel!.authorization,
        body: body,
        responseCode: SAVE_CUSTOMER,
        companyId: currentCompanyId);
    request.setListener(this);
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
    if (responseCode == SAVE_CUSTOMER) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG SAVE CUSTOMER ========> ${response[Constant.data]}");
        Utility.showToast(response[Constant.msg]);
        Navigator.of(context).pop();
      });
    }
  }

  void resetAllFields() {
    setState(() {
      agencyNameController.clear();
      phoneController.clear();
      cellPhoneController.clear();
      fiscalCodeController.clear();
      vatNumberController.clear();
      sdiCodeController.clear();
      emailPECController.clear();
      priceListController.clear();
      customerSupplierController.clear();
      localHashTagController.clear();

      customer = 0;
      supplier = 0;
      filterCustomerSupplierResult = null;
      addressArray.clear();
      emailArray.clear();
      localHashTagsList.clear();
      finalLocalHashTags = "";
      buttonEnable = false;
    });
  }
}