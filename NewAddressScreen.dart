import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paciolo/util/Utility.dart';

import '../util/CommonCSS.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';

class NewAddressScreen extends StatefulWidget {

  var addressData;
  var customerId;
  NewAddressScreen({Key? key, this.addressData, this.customerId}) : super(key: key);

  @override
  State<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {

  String TAG = "_NewAddressScreenState";
  TextEditingController addressIdentifierController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController provinceAbbreviationController = TextEditingController();
  TextEditingController stateInitialsController = TextEditingController();

  String _radioValue = "Sede legale";
  int _radioType = 1;
  bool buttonEnable = true;

  @override
  void initState() {
    if(widget.addressData == null) {
      addressIdentifierController.text = _radioValue;
      stateInitialsController.text = "IT";
    } else {
      _radioType = int.parse(widget.addressData["type"].toString());
      _radioValue = widget.addressData["type_name"].toString();
      addressIdentifierController.text = widget.addressData["type_name"].toString();
      if(widget.addressData["address1"] != null && widget.addressData["address1"] != "") {
        address1Controller.text = widget.addressData["address1"].toString();
      } else {
        address1Controller.text = "";
      }
      if(widget.addressData["address2"] != null && widget.addressData["address2"] != "") {
        address2Controller.text = widget.addressData["address2"].toString();
      } else {
        address2Controller.text = "";
      }
      if (widget.addressData["zip"] != null && widget.addressData["zip"] != "") {
        postalCodeController.text = widget.addressData["zip"].toString();
      } else {
        postalCodeController.text = "";
      }
      if (widget.addressData["city"] != null && widget.addressData["city"] != "") {
        cityController.text = widget.addressData["city"].toString();
      } else {
        cityController.text = "";
      }
      if (widget.addressData["country"] != null && widget.addressData["country"] != "") {
        provinceAbbreviationController.text = widget.addressData["country"].toString();
      } else {
        provinceAbbreviationController.text = "";
      }
      if (widget.addressData["state"] != null && widget.addressData["state"] != "") {
        stateInitialsController.text = widget.addressData["state"].toString();
      } else {
        stateInitialsController.text = "";
      }
    }
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
          icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_TITLE : IT.ADD_ADDRESS_SCREEN_TITLE,
          style: gothamRegular.copyWith(
            fontSize: Dimensions.FONT_L,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
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
                  // location / address
                  Text(
                    Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_2 : IT.ADD_ADDRESS_SCREEN_LABEL_2,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  locationTypeRadio(context),
                  const SizedBox(height: Dimensions.PADDING_L),
                  // location / address
                  // address identifier
                  Text(
                    Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_1 : IT.ADD_ADDRESS_SCREEN_LABEL_1,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  addressIdentifierField(context),
                  const SizedBox(height: Dimensions.PADDING_L),
                  // address identifier
                  // Address 1
                  Text(
                    Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_3 : IT.ADD_ADDRESS_SCREEN_LABEL_3,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  address1Field(context),
                  const SizedBox(height: Dimensions.PADDING_L),
                  // Address 1
                  // Address 2
                  Text(
                    Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_4 : IT.ADD_ADDRESS_SCREEN_LABEL_4,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  address2Field(context),
                  const SizedBox(height: Dimensions.PADDING_L),
                  // Address 2
                  // Province (Abbreviation)
                  Text(
                    Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_5 : IT.ADD_ADDRESS_SCREEN_LABEL_5,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  provinceAbbreviationField(context),
                  const SizedBox(height: Dimensions.PADDING_L),
                  // Province (Abbreviation)
                  // POSTAL CODE
                  Text(
                    Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_6 : IT.ADD_ADDRESS_SCREEN_LABEL_6,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  postalCodeField(context),
                  const SizedBox(height: Dimensions.PADDING_L),
                  // POSTAL CODE
                  // City
                  Text(
                    Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_7 : IT.ADD_ADDRESS_SCREEN_LABEL_7,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  cityField(context),
                  const SizedBox(height: Dimensions.PADDING_L),
                  // City
                  // Country (IT)
                  Text(
                    Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_8 : IT.ADD_ADDRESS_SCREEN_LABEL_8,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L,
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  stateInitialsField(context),
                  const SizedBox(height: Dimensions.PADDING_L),
                  // Country (IT)

                  InkWell(
                    onTap: () {
                      if(!buttonEnable) {
                        Utility.showToast(Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_ADD_ERROR : IT.ADD_ADDRESS_SCREEN_ADD_ERROR);
                      } else {
                        Navigator.pop(context, {
                          "address1": address1Controller.text.toString().trim(),
                          "address2": address2Controller.text.toString().trim(),
                          "city": cityController.text.toString().trim(),
                          "country": provinceAbbreviationController.text.toString().trim(),
                          "state": stateInitialsController.text.toString().trim(),
                          "type": _radioType,
                          "type_name": _radioValue,
                          "zip": postalCodeController.text.toString().trim(),
                          "error": false,
                          "id": widget.addressData != null ? widget.addressData["id"] : 0,
                          "customer_id": widget.customerId,
                        });
                      }
                    },
                    child: Container(
                      height: 50.h,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: Dimensions.PADDING_M),
                      decoration: CommonCSS.buttonDecoration(buttonEnable, 5.r, AllColors.colorGreen, 0.5, 0),
                      child: Center(
                          child: Text(
                            Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_ADD_BUTTON : IT.ADD_ADDRESS_SCREEN_ADD_BUTTON,
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
    );
  }

  Widget locationTypeRadio(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Row(
              children: [
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: "Sede legale",
                  groupValue: _radioValue,
                  onChanged: (value) {
                    setState(() {
                      debugPrint("$TAG Sede legale Radio 1 value ========> $value");
                      _radioValue = value.toString();
                      _radioType = 1;
                      addressIdentifierController.text = value.toString();
                    });
                  },
                ),
                Text(
                  Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_RADIO_1 : IT.ADD_ADDRESS_SCREEN_RADIO_1,
                  style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M,
                    color: const Color(AllColors.colorText),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: "Magazzino",
                  groupValue: _radioValue,
                  onChanged: (value) {
                    setState(() {
                      debugPrint("$TAG Magazzino Radio 2 value ========> $value");
                      _radioValue = value.toString();
                      _radioType = 2;
                      addressIdentifierController.text = value.toString();
                    });
                  },
                ),
                Text(
                  Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_RADIO_2 : IT.ADD_ADDRESS_SCREEN_RADIO_2,
                  style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M,
                    color: const Color(AllColors.colorText),
                  ),
                ),
              ],
            ),
          ],
        ),

        Row(
          children: [
            Row(
              children: [
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: "Ufficio",
                  groupValue: _radioValue,
                  onChanged: (value) {
                    setState(() {
                      debugPrint("$TAG Sede legale Radio 3 value ========> $value");
                      _radioValue = value.toString();
                      _radioType = 3;
                      addressIdentifierController.text = value.toString();
                    });
                  },
                ),
                Text(
                  Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_RADIO_3 : IT.ADD_ADDRESS_SCREEN_RADIO_3,
                  style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M,
                    color: const Color(AllColors.colorText),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 37.0,),
            Row(
              children: [
                Radio(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: "Cantiere",
                  groupValue: _radioValue,
                  onChanged: (value) {
                    setState(() {
                      debugPrint("$TAG Cantiere Radio 4 value ========> $value");
                      _radioValue = value.toString();
                      _radioType = 4;
                      addressIdentifierController.text = value.toString();
                    });
                  },
                ),
                Text(
                  Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_RADIO_4 : IT.ADD_ADDRESS_SCREEN_RADIO_4,
                  style: gothamRegular.copyWith(
                    fontSize: Dimensions.FONT_M,
                    color: const Color(AllColors.colorText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget addressIdentifierField(BuildContext context) {
    return TextFormField(
      controller: addressIdentifierController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
      cursorWidth: 1.5.w,
      onChanged: (value) {

      },
      readOnly: true,
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
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_1 : IT.ADD_ADDRESS_SCREEN_LABEL_1,
        fillColor: Colors.white,
      ),
    );
  }

  Widget address1Field(BuildContext context) {
    return TextFormField(
      controller: address1Controller,
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
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_3 : IT.ADD_ADDRESS_SCREEN_LABEL_3,
        fillColor: Colors.white,
      ),
    );
  }

  Widget address2Field(BuildContext context) {
    return TextFormField(
      controller: address2Controller,
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
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_4 : IT.ADD_ADDRESS_SCREEN_LABEL_4,
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
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_5 : IT.ADD_ADDRESS_SCREEN_LABEL_5,
        fillColor: Colors.white,
      ),
    );
  }

  Widget postalCodeField(BuildContext context) {
    return TextFormField(
      controller: postalCodeController,
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
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_6 : IT.ADD_ADDRESS_SCREEN_LABEL_6,
        fillColor: Colors.white,
      ),
    );
  }

  Widget cityField(BuildContext context) {
    return TextFormField(
      controller: cityController,
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
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_7 : IT.ADD_ADDRESS_SCREEN_LABEL_7,
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
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_LABEL_8 : IT.ADD_ADDRESS_SCREEN_LABEL_8,
        fillColor: Colors.white,
      ),
    );
  }
}