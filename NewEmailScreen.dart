import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/styles.dart';

import '../util/CommonCSS.dart';
import '../util/dimensions.dart';

class NewEmailScreen extends StatefulWidget {
  var emailData;
  var customerId;
  NewEmailScreen({Key? key, this.emailData, this.customerId}) : super(key: key);

  @override
  State<NewEmailScreen> createState() => _NewEmailScreenState();
}

class _NewEmailScreenState extends State<NewEmailScreen> {

  String TAG = "_NewImageScreenState";
  TextEditingController emailController = TextEditingController();

  bool buttonEnable = false;

  @override
  void initState() {
    if(widget.emailData != null) {
      emailController = TextEditingController(text: widget.emailData["email"].toString());
      buttonEnable = true;
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
          Constant.LANG == Constant.EN ? ENG.ADD_EMAIL_ADDRESS_TITLE : IT.ADD_EMAIL_ADDRESS_TITLE,
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
                    Text(
                      Constant.LANG == Constant.EN ? ENG.ADD_EMAIL_ADDRESS_LABEL : IT.ADD_EMAIL_ADDRESS_LABEL,
                      style: gothamMedium.copyWith(
                        color: const Color(AllColors.colorText),
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    emailField(context),
                    const SizedBox(height: Dimensions.PADDING_L),
                    InkWell(
                      onTap: () {
                        if(!buttonEnable) {
                          Utility.showToast(Constant.LANG == Constant.EN ? ENG.ADD_ADDRESS_SCREEN_ADD_ERROR : IT.ADD_ADDRESS_SCREEN_ADD_ERROR);
                        } else {
                          Navigator.pop(context, {
                            "email": emailController.text.toString().trim(),
                            "customer_id": widget.customerId,
                            "is_default": widget.emailData != null ? widget.emailData["is_default"] : 0,
                            "is_deleted": widget.emailData != null ? widget.emailData["is_deleted"] : 0,
                            "id": widget.emailData != null ? widget.emailData["id"] : 0,
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
                              Constant.LANG == Constant.EN ? ENG.ADD_EMAIL_ADDRESS_ADD_BUTTON : IT.ADD_EMAIL_ADDRESS_ADD_BUTTON,
                              style: gothamBold.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.FONT_L
                              ),
                            )
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget emailField(BuildContext context) {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: gothamMedium.copyWith(
        color: const Color(AllColors.colorText),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: const Color(AllColors.colorText),
      cursorWidth: 1.5.w,
      onChanged: (value) {
        setState(() {
          if(Utility.emailValidation(emailController.text.toString().trim())) {
            buttonEnable = true;
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
        hintText: Constant.LANG == Constant.EN ? ENG.ADD_EMAIL_ADDRESS_LABEL : IT.ADD_EMAIL_ADDRESS_LABEL,
        fillColor: Colors.white,
      ),
    );
  }

}
