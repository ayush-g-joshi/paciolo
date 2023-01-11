import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/childscreens/CustomerSupplierScreen.dart';
import 'package:paciolo/childscreens/NewAddressScreen.dart';
import 'package:paciolo/childscreens/NewEmailScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/PutRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../util/CommonCSS.dart';

class EditCustomerProfileScreen extends StatefulWidget {
  var customerId;

  EditCustomerProfileScreen({Key? key, this.customerId}) : super(key: key);

  @override
  State<EditCustomerProfileScreen> createState() =>
      _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState extends State<EditCustomerProfileScreen>
    implements ResponseListener {
  String TAG = "_EditCustomerProfileScreenState";
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

  var GET_CUSTOMER = 9000;
  var GET_PRICE_LIST = 9001;
  var EDIT_CUSTOMER = 9010;
  String? imageString;
  List addressArray = List.from([]);
  List emailArray = List.from([]);
  List priceList = List.from([]);
  List<String> localHashTagsList = List.from([]);
  List globalHashTagsList = List.from([]);
  var customerProfileData;

  var filterPriceResult;
  int? selectedPriceId;

  var filterCustomerSupplierResult;
  int? selectedCustomerSupplierId;
  List customerSupplier = IT.customerSupplier;
  bool buttonEnable = false;
  final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();
  final GlobalKey<TagsState> _globalTagStateKey = GlobalKey<TagsState>();
  int customer = 0;
  int supplier = 0;
  String finalLocalHashTags = "";

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject)
        .then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompany = userModel!.currentCompany;
      currentCompanyId = currentCompany?.id;
      customerSupplier = IT.customerSupplier;
      getCustomerProfile();
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
          Constant.LANG == Constant.EN
              ? ENG.CUSTOMER_EDIT_PROFILE_TITLE
              : IT.CUSTOMER_EDIT_PROFILE_TITLE,
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
              padding: const EdgeInsets.only(
                  right: Dimensions.PADDING_S, left: Dimensions.PADDING_S),
              child: Center(
                child: Text(
                  Constant.LANG == Constant.EN
                      ? ENG.CUSTOMER_EDIT_RESET
                      : IT.CUSTOMER_EDIT_RESET,
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
                      // customer profile image
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
                                  color: const Color(0xFF95989A),
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  height: 100.h,
                                  width: 100.h,
                                  margin: const EdgeInsets.all(1.0),
                                  child: imageString != null
                                      ? Image.memory(base64Decode(imageString!))
                                      : Container(),
                                ),
                              ),
                            )),
                      ),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // customer profile image
                      // agency name
                      Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_1
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_1,
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
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_2
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_2,
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
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_3
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_3,
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
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_4
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_4,
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
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_5
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_5,
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
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_6
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_6,
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
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_7
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_7,
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
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_8
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_8,
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
                        Constant.LANG == Constant.EN
                            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_10
                            : IT.CUSTOMER_EDIT_PROFILE_LABEL_10,
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
                      // global hash tags
                      globalHashTag(context),
                      const SizedBox(height: Dimensions.PADDING_L),
                      // global hash tags
                      // address
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Constant.LANG == Constant.EN
                                ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_13
                                : IT.CUSTOMER_EDIT_PROFILE_LABEL_13,
                            textAlign: TextAlign.left,
                            style: gothamMedium.copyWith(
                              color: const Color(AllColors.colorText),
                              fontSize: Dimensions.FONT_L,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              var result = await Navigator.push(context,
                                  MaterialPageRoute(
                                builder: (context) {
                                  return NewAddressScreen(
                                    addressData: null,
                                    customerId: widget.customerId,
                                  );
                                },
                              ));

                              setState(() {
                                if (result != null) {
                                  debugPrint(
                                      "$TAG add Address Field Result ======> $result");
                                  addressArray.add(result);
                                  if (addressArray.isNotEmpty &&
                                      agencyNameController.text
                                          .toString()
                                          .trim()
                                          .isNotEmpty) {
                                    buttonEnable = true;
                                  }
                                }
                              });
                            },
                            child: Text(
                              Constant.LANG == Constant.EN
                                  ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_13_HINT
                                  : IT.CUSTOMER_EDIT_PROFILE_LABEL_13_HINT,
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
                          if (buttonEnable) {
                            saveCustomerData();
                          }
                        },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                              bottom: Dimensions.PADDING_M),
                          decoration: CommonCSS.buttonDecoration(
                              buttonEnable, 5.r, AllColors.colorGreen, 0.5, 0),
                          child: Center(
                              child: Text(
                            Constant.LANG == Constant.EN
                                ? ENG.CUSTOMER_EDIT_PROFILE_SAVE_BUTTON
                                : IT.CUSTOMER_EDIT_PROFILE_SAVE_BUTTON,
                            style: gothamBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.FONT_L),
                          )),
                        ),
                      )
                    ]),
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
          if (agencyNameController.text.toString().trim().isNotEmpty) {
            if (agencyNameController.text.toString().trim().length >= 5 &&
                addressArray.isNotEmpty) {
              buttonEnable = true;
            } else {
              buttonEnable = false;
              Utility.showToast(Constant.LANG == Constant.EN
                  ? ENG.CUSTOMER_EDIT_PROFILE_ERROR_1
                  : IT.CUSTOMER_EDIT_PROFILE_ERROR_1);
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
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_1
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_1,
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
        var result = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return NewEmailScreen(
              emailData: null,
              customerId: widget.customerId,
            );
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
        suffixIcon: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.blue,
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
            color: Colors.blue,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.ADD_EMAIL_ADDRESS_TITLE
            : IT.ADD_EMAIL_ADDRESS_TITLE,
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
        return const Divider(
          height: 1,
          color: Color(AllColors.colorText),
        );
      },
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      var result =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return NewEmailScreen(
                            emailData: emailArray[index],
                            customerId: widget.customerId,
                          );
                        },
                      ));
                      setState(() {
                        if (result != null) {
                          debugPrint(
                              "$TAG add Address Field Result ======> $result");
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
                  const SizedBox(
                    width: Dimensions.PADDING_S,
                  ),
                  if (index > 0)
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
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
              Text(
                "Email: ${emailArray[index]["email"]}",
                overflow: TextOverflow.ellipsis,
                style: gothamRegular.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: Dimensions.FONT_M,
                  color: const Color(AllColors.colorText),
                ),
              ),
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
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
      onChanged: (value) {},
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
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_3
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_3,
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
      onChanged: (value) {},
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
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_4
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_4,
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
      onChanged: (value) {},
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
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_5
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_5,
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
      onChanged: (value) {},
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
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_6
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_6,
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
      onChanged: (value) {},
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
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_7
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_7,
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
      onChanged: (value) {},
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
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_8
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_8,
        fillColor: Colors.white,
      ),
    );
  }

  /*Widget priceListField(BuildContext context) {
    return TextFormField(
      controller: priceListController,
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
              return UsePriceListScreen(customerId: widget.customerId);
            },
          ));
          setState(() {
            if (result != null) {
              filterPriceResult = result;
              debugPrint("$TAG filter price Result ======> $filterPriceResult");
              priceListController.text = filterPriceResult["modeName"];
              selectedPriceId = filterPriceResult["modeId"];
            }
          });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: filterPriceResult != null ? IconButton(
          onPressed: () {
            setState(() {
              filterPriceResult = null;
              priceListController.clear();
              selectedPriceId = null;
            });
          }, icon: const Icon(Icons.cancel, color: Colors.blue,),
        ) : const Icon(Icons.arrow_forward_ios),
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
  }*/

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
        var result = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return CustomerSupplierScreen(customerId: widget.customerId);
          },
        ));

        setState(() {
          if (result != null) {
            filterCustomerSupplierResult = result;
            debugPrint(
                "$TAG filter customer Result ======> $filterCustomerSupplierResult");
            customerSupplierController.text =
                filterCustomerSupplierResult["name"].toString();
            if (filterCustomerSupplierResult["name"].toString() ==
                customerSupplier[0]) {
              customer = 1;
              supplier = 0;
            } else if (filterCustomerSupplierResult["name"].toString() ==
                customerSupplier[1]) {
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
        suffixIcon: /*filterCustomerSupplierResult != null ? IconButton(
          onPressed: () {
            setState(() {
              filterCustomerSupplierResult = null;
              customerSupplierController.clear();
              selectedCustomerSupplierId = null;
            });
          }, icon: const Icon(Icons.cancel, color: Colors.blue,),
        ) : */
            const Icon(Icons.arrow_forward_ios),
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
          Constant.LANG == Constant.EN
              ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_11
              : IT.CUSTOMER_EDIT_PROFILE_LABEL_11,
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
            )),
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
                      left: Dimensions.PADDING_S, right: Dimensions.PADDING_XS),
                  decoration: const BoxDecoration(
                    color: Color(AllColors.colorBlue),
                    borderRadius:
                        BorderRadius.all(Radius.circular(Dimensions.PADDING_S)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        localHashTagsList[index],
                        style: gothamMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.FONT_M,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: Dimensions.PADDING_XS,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            localHashTagsList.removeAt(index);
                            debugPrint(
                                "$TAG Local Hash Tags List ======> ${localHashTagsList.length}");
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
              if (localHashTagController.text.toString().trim().isNotEmpty) {
                bool isExist = false;
                for (int i = 0; i < localHashTagsList.length; i++) {
                  if (localHashTagsList[i] ==
                      localHashTagController.text.toString().trim()) {
                    isExist = true;
                  } else if (localHashTagsList[i] ==
                      "#${localHashTagController.text.toString().trim()}") {
                    isExist = true;
                  }
                  if (localHashTagsList[i] ==
                      localHashTagController.text
                          .toString()
                          .trim()
                          .toLowerCase()) {
                    isExist = true;
                  } else if (localHashTagsList[i] ==
                      "#${localHashTagController.text.toString().trim().toLowerCase()}") {
                    isExist = true;
                  } else if (localHashTagsList[i] ==
                      localHashTagController.text
                          .toString()
                          .trim()
                          .toUpperCase()) {
                    isExist = true;
                  } else if (localHashTagsList[i] ==
                      "#${localHashTagController.text.toString().trim().toUpperCase()}") {
                    isExist = true;
                  }
                }
                if (isExist) {
                  debugPrint("$TAG data is exist in array list");
                  Utility.showToast(Constant.LANG == Constant.EN
                      ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_11_ERROR
                      : IT.CUSTOMER_EDIT_PROFILE_LABEL_11_ERROR);
                } else {
                  debugPrint("$TAG data is not exist in array list");
                  if (localHashTagController.text
                      .toString()
                      .trim()
                      .contains("#")) {
                    localHashTagsList
                        .add(localHashTagController.text.toString().trim());
                    localHashTagController.clear();
                    debugPrint(
                        "$TAG local HashTags List to String =======> ${localHashTagsList.join(" ")}");
                    finalLocalHashTags = localHashTagsList.join(" ");
                  } else {
                    String value =
                        "#${localHashTagController.text.toString().trim()}";
                    localHashTagsList.add(value);
                    localHashTagController.clear();
                    debugPrint(
                        "$TAG local HashTags List to String =======> ${localHashTagsList.join(" ")}");
                    finalLocalHashTags = localHashTagsList.join(" ");
                  }
                  isExist = false;
                }
              }
            });
          },
          icon: const Icon(
            Icons.task_alt_sharp,
            color: Color(AllColors.colorGreen),
          ),
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
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_11
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_11,
        fillColor: Colors.white,
      ),
    );
  }

  Widget globalHashTag(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Constant.LANG == Constant.EN
              ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_12
              : IT.CUSTOMER_EDIT_PROFILE_LABEL_12,
          style: gothamMedium.copyWith(
            color: const Color(AllColors.colorText),
            fontSize: Dimensions.FONT_L,
          ),
        ),
        const SizedBox(height: Dimensions.PADDING_XS),
        globalHashTags(context),
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
            )),
            child: ListView.builder(
              itemCount: globalHashTagsList.length,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(
                    left: Dimensions.PADDING_XS,
                    right: Dimensions.PADDING_XS,
                  ),
                  padding: const EdgeInsets.only(
                      left: Dimensions.PADDING_S, right: Dimensions.PADDING_XS),
                  decoration: const BoxDecoration(
                    color: Color(AllColors.colorPink),
                    borderRadius:
                        BorderRadius.all(Radius.circular(Dimensions.PADDING_S)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        globalHashTagsList[index]["display"],
                        style: gothamMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.FONT_M,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: Dimensions.PADDING_XS,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            globalHashTagsList.removeAt(index);
                            debugPrint(
                                "$TAG Global Hash Tags List ======> ${globalHashTagsList.length}");
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
        var result = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return NewAddressScreen(
              addressData: null,
              customerId: widget.customerId,
            );
          },
        ));

        setState(() {
          if (result != null) {
            debugPrint("$TAG add Address Field Result ======> $result");
            addressArray.add(result);
            if (addressArray.isNotEmpty &&
                agencyNameController.text.toString().trim().isNotEmpty) {
              buttonEnable = true;
            }
          }
        });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.blue,
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
            color: Colors.blue,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600),
        hintText: Constant.LANG == Constant.EN
            ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_13_HINT
            : IT.CUSTOMER_EDIT_PROFILE_LABEL_13_HINT,
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
        return const Divider(
          height: 1,
          color: Color(AllColors.colorText),
        );
      },
      itemBuilder: (context, index) {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      var result =
                          await Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return NewAddressScreen(
                            addressData: addressArray[index],
                            customerId: widget.customerId,
                          );
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
                  const SizedBox(
                    width: Dimensions.PADDING_S,
                  ),
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
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
              Text(
                "Address 1: ${addressArray[index]["address1"]}",
                overflow: TextOverflow.ellipsis,
                style: gothamRegular.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: Dimensions.FONT_M,
                  color: const Color(AllColors.colorText),
                ),
              ),
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
              Text(
                "Address 2: ${addressArray[index]["address2"]}",
                overflow: TextOverflow.ellipsis,
                style: gothamRegular.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: Dimensions.FONT_M,
                  color: const Color(AllColors.colorText),
                ),
              ),
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
              Text(
                "City: ${addressArray[index]["city"]}",
                overflow: TextOverflow.ellipsis,
                style: gothamRegular.copyWith(
                  overflow: TextOverflow.ellipsis,
                  fontSize: Dimensions.FONT_M,
                  color: const Color(AllColors.colorText),
                ),
              ),
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
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
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
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
              const SizedBox(
                height: Dimensions.PADDING_XS,
              ),
            ],
          ),
        );
      },
    );
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

  void getPriceList() {
    // https://devapi.paciolo.it/customer/tarif/list

    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getCustomerPriceList,
        token: userModel!.authorization,
        responseCode: GET_PRICE_LIST,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void saveCustomerData() {
    // https://devapi.paciolo.it/customer/18536 use PUT
    setState(() {
      showLoader = true;

      for (int i = 0; i < emailArray.length; i++) {
        Map<String, dynamic> mapData = emailArray[i];
        mapData.remove("created_at");
        mapData.remove("updated_at");
        emailArray.removeAt(i);
        emailArray.add(mapData);
      }

      debugPrint("$TAG email array changed ========> ${emailArray.toString()}");

      for (int i = 0; i < addressArray.length; i++) {
        Map<String, dynamic> mapData = addressArray[i];
        mapData.remove("created_at");
        mapData.remove("updated_at");
        addressArray.removeAt(i);
        addressArray.add(mapData);
      }
      debugPrint(
          "$TAG address array changed ========> ${addressArray.toString()}");

      finalLocalHashTags = localHashTagsList.join(" ");
      debugPrint("$TAG final Local Hash Tags ========> $finalLocalHashTags");
    });

    var body = jsonEncode({
      "first_name": customerProfileData["first_name"],
      "last_name": customerProfileData["last_name"],
      "company_name": agencyNameController.text.toString().trim(),
      "contact_type": customerProfileData["contact_type"],
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
      "tarifId": customerProfileData["tarif_id"] != null
          ? customerProfileData["tarif_id"]
          : 0,
    });

    PutRequest request = PutRequest();
    request.getResponse(
        cmd: "${RequestCmd.editCustomer}${widget.customerId}",
        token: userModel!.authorization,
        body: body,
        responseCode: EDIT_CUSTOMER,
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
    if (responseCode == EDIT_CUSTOMER) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG EDIT CUSTOMER ========> ${response[Constant.data]}");
        Utility.showToast(response[Constant.msg]);
        Navigator.of(context).pop();
      });
    } else if (responseCode == GET_PRICE_LIST) {
      debugPrint(
          "$TAG GET MODE LIST ========> ${response[Constant.data]["list"]}");
      setState(() {
        showLoader = false;
        for (int i = 0; i < response[Constant.data]["list"].length; i++) {
          priceList.add(response[Constant.data]["list"][i]);
          if (response[Constant.data]["list"][i]["id"] ==
              customerProfileData["tarif_id"]) {
            filterPriceResult = {
              "modeId": response[Constant.data]["list"][i]["id"],
              "modeName": response[Constant.data]["list"][i]["name"]
            };
          }
        }
        if (filterPriceResult != null) {
          debugPrint("$TAG Filter Price Result ========> $filterPriceResult");
          priceListController.text = filterPriceResult["modeName"];
          selectedPriceId = filterPriceResult["modeId"];
        }
      });
    } else if (responseCode == GET_CUSTOMER) {
      setState(() {
        showLoader = false;
        addressArray.clear();

        customerProfileData = response[Constant.data];

        if (customerProfileData["tarif_id"] != null &&
            customerProfileData["tarif_id"] != "") {
          getPriceList();
        }

        if (customerProfileData["customer_hashtag"] != null &&
            customerProfileData["customer_hashtag"] != "") {
          localHashTagsList.addAll(
              customerProfileData["customer_hashtag"].toString().split(" "));
          finalLocalHashTags =
              customerProfileData["customer_hashtag"].toString();
        }

        if (customerProfileData["customersGlobalTags"] != null &&
            customerProfileData["customersGlobalTags"].length > 0) {
          for (int i = 0;
              i < customerProfileData["customersGlobalTags"].length;
              i++) {
            globalHashTagsList
                .add(customerProfileData["customersGlobalTags"][i]);
          }
        }

        if (customerProfileData["emails"] != null &&
            customerProfileData["emails"].length > 0) {
          for (int i = 0; i < customerProfileData["emails"].length; i++) {
            emailArray.add(customerProfileData["emails"][i]);
          }
        }

        if (customerProfileData["is_customer"] == 1 &&
            customerProfileData["is_supplier"] == 1) {
          filterCustomerSupplierResult = {"name": customerSupplier[2]};
          customer = 1;
          supplier = 1;
        } else if (customerProfileData["is_customer"] == 1 &&
            customerProfileData["is_supplier"] == 0) {
          filterCustomerSupplierResult = {"name": customerSupplier[0]};
          customer = 1;
          supplier = 0;
        } else {
          filterCustomerSupplierResult = {"name": customerSupplier[1]};
          customer = 0;
          supplier = 1;
        }

        customerSupplierController.text =
            filterCustomerSupplierResult["name"].toString();

        if (customerProfileData["addressAry"] != null &&
            customerProfileData["addressAry"].length > 0) {
          for (int i = 0; i < customerProfileData["addressAry"].length; i++) {
            addressArray.add(customerProfileData["addressAry"][i]);
          }
        }

        if (customerProfileData["user_image"] != null &&
            customerProfileData["user_image"] != "") {
          String imageData = response[Constant.data]["company"]["logo_uri"];
          if (imageData.contains("data:image/jpg;base64,")) {
            imageString = imageData.replaceAll("data:image/jpg;base64,", "");
          } else if (imageData.contains("data:image/png;base64,")) {
            imageString = imageData.replaceAll("data:image/png;base64,", "");
          }
        } else {
          imageString = null;
        }

        if (customerProfileData["name"] != null) {
          agencyNameController = TextEditingController(
              text: customerProfileData["name"].toString());
        } else {
          agencyNameController = TextEditingController(text: "");
        }

        // if(customerProfileData["email"] != null) {
        //   emailController = TextEditingController(text: customerProfileData["email"].toString());
        // } else if (emailArray != null && emailArray.isNotEmpty) {
        //   emailController = TextEditingController(text: emailArray[0]["email"].toString());
        // } else {
        //   emailController = TextEditingController(text: "");
        // }

        if (customerProfileData["phone1"] != null) {
          phoneController = TextEditingController(
              text: customerProfileData["phone1"].toString());
        } else {
          phoneController = TextEditingController(text: "");
        }

        if (customerProfileData["phone2"] != null) {
          cellPhoneController = TextEditingController(
              text: customerProfileData["phone2"].toString());
        } else {
          cellPhoneController = TextEditingController(text: "");
        }

        if (customerProfileData["fiscal_code"] != null) {
          fiscalCodeController = TextEditingController(
              text: customerProfileData["fiscal_code"].toString());
        } else {
          fiscalCodeController = TextEditingController(text: "");
        }

        if (customerProfileData["vat_number"] != null) {
          vatNumberController = TextEditingController(
              text: customerProfileData["vat_number"].toString());
        } else {
          vatNumberController = TextEditingController(text: "");
        }

        if (customerProfileData["recipient_code"] != null) {
          sdiCodeController = TextEditingController(
              text: customerProfileData["recipient_code"].toString());
        } else {
          sdiCodeController = TextEditingController(text: "");
        }

        if (customerProfileData["email_pec"] != null) {
          emailPECController = TextEditingController(
              text: customerProfileData["email_pec"].toString());
        } else {
          emailPECController = TextEditingController(text: "");
        }

        if (addressArray.isNotEmpty && customerProfileData["name"] != null) {
          buttonEnable = true;
        }
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
      globalHashTagsList.clear();
      imageString = null;
      buttonEnable = false;
    });
  }

  Widget localHashTags(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Tags(
            key: _tagStateKey,
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
                    fontWeight: FontWeight.bold),
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
                    }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget globalHashTags(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Tags(
            key: _globalTagStateKey,
            itemCount: globalHashTagsList.length,
            symmetry: false,
            columns: 0,
            alignment: WrapAlignment.start,
            itemBuilder: (index) {
              return ItemTags(
                key: Key(index.toString()),
                index: index,
                active: true,
                pressEnabled: false,
                activeColor: const Color(AllColors.colorPink),
                textStyle: gothamMedium.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.FONT_M,
                    fontWeight: FontWeight.bold),
                title: globalHashTagsList[index]["display"],
                removeButton: ItemTagsRemoveButton(
                    backgroundColor: const Color(AllColors.colorPink),
                    margin: EdgeInsets.zero,
                    size: 16,
                    onRemoved: () {
                      setState(() {
                        globalHashTagsList.removeAt(index);
                      });
                      return true;
                    }),
              );
            },
          ),
        ),
      ],
    );
  }
}
