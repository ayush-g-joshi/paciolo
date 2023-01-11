import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/images.dart';
import 'package:paciolo/util/styles.dart';

import '../util/CommonCSS.dart';
import '../util/Constants.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword>
    implements ResponseListener {

  String TAG = "_ForgotPasswordPageState";
  final TextEditingController emailController = TextEditingController();
  bool showLoader = false;
  bool enableButton = false;
  String email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 0.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF205fac),
                Color(0xFF205fac),
              ],
            ),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        progressIndicator: const CircularProgressIndicator(),
        child: Column(
          children: [
            Container(
              height: 140.h,
              padding: EdgeInsets.zero,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage(Images.logo),
                  fit: BoxFit.fill
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10, top: 5),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  height: 500.h,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: Dimensions.PADDING_XL.h),
                          Text(
                            Constant.LANG == Constant.EN ? ENG.FORGOT_PASSWORD : IT.FORGOT_PASSWORD,
                            style: gothamBold.copyWith(
                                color: Colors.black,
                                letterSpacing: 0.6,
                                fontSize: Dimensions.FONT_4XL.sp),
                          ),
                          SizedBox(height: Dimensions.PADDING_M.h),
                          Text(
                            Constant.LANG == Constant.EN ? ENG.LOGIN_HEADING : IT.LOGIN_HEADING,
                            textAlign: TextAlign.center,
                            style: gothamRegular.copyWith(
                                color: Colors.black,
                                height: 1.4,
                                fontSize: Dimensions.FONT_L.sp),
                          ),
                          SizedBox(height: Dimensions.PADDING_XL.h),
                          const Spacer(
                            flex: 2,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 4),
                                  height: 0.5.h,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                              Text(
                                Constant.LANG == Constant.EN ? ENG.FORGOT_CREDENTIAL : IT.FORGOT_CREDENTIAL,
                                style: gothamRegular.copyWith(
                                    color: Colors.black.withOpacity(0.7),
                                    letterSpacing: 0.5,
                                    fontSize: Dimensions.FONT_XS.sp),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  height: 0.5.h,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimensions.PADDING_XL.h),
                          const Spacer(
                            flex: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Enter email address text filed
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: gothamMedium.copyWith(
                                    color: Colors.black.withOpacity(0.5),
                                    fontSize: Dimensions.FONT_XL.sp,
                                  ),
                                  onChanged: (value){
                                    if (Utility.emailValidation(value)) { debugPrint("$TAG value ======> $value");
                                    setState(() {
                                      enableButton = true;
                                    });
                                    } else {
                                      setState(() {
                                        enableButton = false;
                                      });
                                    }
                                  },
                                  cursorColor: Colors.black,
                                  cursorHeight: 25.h,
                                  cursorWidth: 1.5.w,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          REdgeInsets.fromLTRB(25, 0, 0, 0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.0.w,
                                            color: Colors.grey.withOpacity(0.5)),
                                        borderRadius:
                                            BorderRadius.circular(30.0.r),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(30.0.r),
                                      ),
                                      filled: true,
                                      hintStyle: gothamMedium.copyWith(
                                          color: Colors.grey,
                                          fontSize: Dimensions.FONT_XL.sp,
                                          fontWeight: FontWeight.w600),
                                      hintText: Constant.LANG == Constant.EN ? ENG.LOGIN_EMAIL : IT.LOGIN_EMAIL,
                                      fillColor: Color(0xFFEEF5F3).withOpacity(0.5)),
                                ),
                                SizedBox(height: Dimensions.PADDING_XL.h),

                                InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if(emailController.text.toString().trim() == null ||
                                            emailController.text.toString().trim().length <= 0) {

                                    } else {
                                      forgotPassword(
                                          emailController.text.toString().trim());
                                    }

                                  },
                                  child: Container(
                                    height: 50.h,
                                    width: double.infinity,
                                    decoration: CommonCSS.buttonDecoration(enableButton, 5.r, AllColors.colorBlue, 0.4, AllColors.colorLightBlue,),
                                    child: Center(
                                      child: Text(
                                        Constant.LANG == Constant.EN ? ENG.FORGOT_RESET_PASS : IT.FORGOT_RESET_PASS,
                                        style: gothamBold.copyWith(
                                            color: Colors.white,
                                            fontSize: Dimensions.FONT_XL.sp,
                                            letterSpacing: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: Dimensions.PADDING_XL.h),
                              ],
                            ),
                          ),
                          SizedBox(height: Dimensions.PADDING_XL.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Constant.LANG == Constant.EN ? ENG.FORGOT_HAVE_CREDENTIAL : IT.FORGOT_HAVE_CREDENTIAL,
                                style: gothamMedium.copyWith(
                                  fontSize: Dimensions.FONT_L.sp,
                                  color: Colors.black,
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  Constant.LANG == Constant.EN ? ENG.FORGOT_LOGIN_NOW : IT.FORGOT_LOGIN_NOW,
                                  style: gothamMedium.copyWith(
                                    fontSize: Dimensions.FONT_L.sp,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const Spacer(flex: 9),
                        ],
                      )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void forgotPassword(String email) {
    setState(() {
      showLoader = true;
    });
    var jsonBody = json.encode({Constant.reminderEmail: email});
    PostRequest request = PostRequest();
    request.getResponse(cmd: RequestCmd.forgotPassword, token: null, body: jsonBody, responseCode: 1000);
    request.setListener(this);
  }

  @override
  void onFailed(response, statusCode) {
    setState(() {
      showLoader = false;
      Utility.showErrorToast(response[Constant.msg]);
    });
  }

  @override
  void onSuccess(response, responseCode) {
    setState(() {
      showLoader = false;
      Utility.showSuccessToast(response[Constant.msg]);
    });
  }
}
