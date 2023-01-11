import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/home/home_screen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/images.dart';
import 'package:paciolo/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../innerscreens/CreateCompanyScreen.dart';
import '../util/CommonCSS.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> implements ResponseListener {

  var TAG = "_SignUpState";
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();
  var SOCIAL_LOGIN = 1001;
  var SIMPLE_LOGIN = 1002;
  bool showLoader = false;
  bool enableButton = false;
  GoogleSignInAccount? _currentUser;
  String? idToken;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    clientId: Platform.isAndroid ? Constant.GOOGLE_API_KEY : Constant.GOOGLE_API_KEY_IOS,
    scopes: <String>[
      'profile', 'email',
    ],
  );
  late final LoginResult facebookResult;
  Map<String, dynamic>? _facebookUserData;
  AccessToken? _accessToken;

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
        child: Column(
          children: [
            Container(
              height: 140.h,
              padding: EdgeInsets.zero,
              width: double.infinity,
              decoration: const BoxDecoration(
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Column(
                    children: [
                      SizedBox(height: Dimensions.PADDING_XL.h),
                      Text(
                          Constant.LANG == Constant.EN ? ENG.SIGNUP_CREATE_ACCOUNT : IT.SIGNUP_CREATE_ACCOUNT,
                        style: gothamBold.copyWith(
                            color: Colors.black,
                            letterSpacing: 0.6,
                            fontSize: Dimensions.FONT_4XL.sp),
                      ),
                      SizedBox(height: Dimensions.PADDING_S.h),
                      Text(
                        Constant.LANG == Constant.EN ? ENG.SIGNUP_SIGNIN_SOCIAL : IT.SIGNUP_SIGNIN_SOCIAL,
                        textAlign: TextAlign.center,
                        style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L.sp),
                      ),
                      SizedBox(height: Dimensions.PADDING_XL.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                                facebookLogin();
                            },
                            child: SvgPicture.asset(Images.facebook,
                              height: 65.h,
                              width: 65.w,
                            ),
                          ),
                          SizedBox(width: Dimensions.PADDING_XL.h),
                          InkWell(
                            onTap: () {
                                googleLogin();
                            },
                            child: SvgPicture.asset(Images.googlePlus,
                              height: 65.h,
                              width: 65.w,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.PADDING_XL.h),
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
                            Constant.LANG == Constant.EN ? ENG.SIGNUP_CREATE_NEW_CREDENTIAL : IT.SIGNUP_CREATE_NEW_CREDENTIAL,
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
                      textField(context),
                      SizedBox(height: 40.h),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (firstNameController.text.toString().trim().isEmpty &&
                          lastNameController.text.toString().trim().isEmpty &&
                          !Utility.emailValidation(emailController.text.toString().trim()) &&
                          passwordController.text.toString().trim().isEmpty &&
                          repeatPasswordController.text.toString().trim().isEmpty) {

                          } else {
                            register(firstNameController.text.toString().trim(),
                                lastNameController.text.toString().trim(),
                                emailController.text.toString().trim(),
                                passwordController.text.toString().trim(),
                                repeatPasswordController.text.toString().trim());
                          }
                        },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          decoration: CommonCSS.buttonDecoration(enableButton, 5.r, AllColors.colorBlue, 0.4, AllColors.colorLightBlue,),
                          child: Center(
                            child: Text(
                              Constant.LANG == Constant.EN ? ENG.SIGNUP_SIGN_IN : IT.SIGNUP_SIGN_IN,
                              style: gothamBold.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.FONT_XL.sp,
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_XL.h),
                      RichText(
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        softWrap: true,
                        maxLines: 2,
                        textScaleFactor: 1,
                        text: TextSpan(
                          style: gothamMedium.copyWith(
                            fontSize:
                            Dimensions.FONT_S.sp,
                            letterSpacing: 0.5,
                          ),
                          children:[
                            TextSpan(
                              text: Constant.LANG == Constant.EN ? ENG.LOGIN_BY_ACCESS : IT.LOGIN_BY_ACCESS,
                              style: gothamMedium.copyWith(
                                fontSize: Dimensions.FONT_S.sp,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()..onTap=(){
                                launchUrl(Uri.parse(Constant.TERMS_URL));
                              },
                              text: Constant.LANG == Constant.EN ? ENG.LOGIN_TC : IT.LOGIN_TC,
                              style: gothamMedium.copyWith(
                                  height: 0.0,
                                  color: Colors.blueAccent,
                                  fontSize: Dimensions.FONT_S.sp
                              ),
                            ),
                            TextSpan(
                              text: Constant.LANG == Constant.EN ? ENG.LOGIN_AND_THE : IT.LOGIN_AND_THE,
                              style: gothamMedium.copyWith(
                                height: 1.5.h,
                                fontSize: Dimensions.FONT_XS.sp,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()..onTap=(){
                                launchUrl(Uri.parse(Constant.PRIVACY_URL));
                              },
                              text: Constant.LANG == Constant.EN ? ENG.LOGIN_PP : IT.LOGIN_PP,
                              style: gothamMedium.copyWith(
                                  height: 0.0,
                                  color: Colors.blueAccent,
                                  fontSize: Dimensions.FONT_S.sp
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_L.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textField(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: Dimensions.PADDING_XL.h),
        // Name Filed
        TextFormField(
          controller: firstNameController,
          keyboardType: TextInputType.name,
          style: gothamMedium.copyWith(
            color: Colors.black.withOpacity(0.5),
            fontSize: Dimensions.FONT_XL.sp,
          ),
          cursorColor: Colors.black,
          cursorHeight: 25.h,
          cursorWidth: 1.5.w,
          onChanged: (value) {
            if (firstNameController.text.toString().trim().isNotEmpty &&
                lastNameController.text.toString().trim().isNotEmpty &&
            Utility.emailValidation(emailController.text.toString().trim()) &&
                passwordController.text.toString().trim().isNotEmpty &&
                repeatPasswordController.text.toString().trim().isNotEmpty) {
              if(passwordController.text.toString().trim().isNotEmpty !=
                  repeatPasswordController.text.toString().trim().isNotEmpty) {
                setState(() {
                  Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.SIGNUP_PASSWORD_NOT_MATCH : IT.SIGNUP_PASSWORD_NOT_MATCH);
                  enableButton = false;
                });
              } else {
                setState(() {
                  enableButton = true;
                });
              }
            } else {
              setState(() {
                enableButton = false;
              });
            }
          },
          decoration: InputDecoration(
              contentPadding: REdgeInsets.fromLTRB(25, 0, 0, 0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1.0.w, color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              filled: true,
              hintStyle: gothamMedium.copyWith(
                  color: Colors.grey,
                  fontSize: Dimensions.FONT_XL.sp,
                  fontWeight: FontWeight.w600
              ),
              hintText: Constant.LANG == Constant.EN ? ENG.SIGNUP_NAME : IT.SIGNUP_NAME,
              fillColor: const Color(0xFFEEF5F3)),
        ),
        SizedBox(height: Dimensions.PADDING_XL.h),

        // Last name Filed
        TextFormField(
          controller: lastNameController,
          keyboardType: TextInputType.name,
          style: gothamMedium.copyWith(
            color: Colors.black.withOpacity(0.5),
            fontSize: Dimensions.FONT_XL.sp,
          ),
          cursorColor: Colors.black,
          cursorHeight: 25.h,
          cursorWidth: 1.5.w,
          onChanged: (value) {
            if (firstNameController.text.toString().trim().isNotEmpty &&
                lastNameController.text.toString().trim().isNotEmpty &&
                Utility.emailValidation(emailController.text.toString().trim()) &&
                passwordController.text.toString().trim().isNotEmpty &&
                repeatPasswordController.text.toString().trim().isNotEmpty) {
              if(passwordController.text.toString().trim().isNotEmpty !=
                  repeatPasswordController.text.toString().trim().isNotEmpty) {
                setState(() {
                  Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.SIGNUP_PASSWORD_NOT_MATCH : IT.SIGNUP_PASSWORD_NOT_MATCH);
                  enableButton = false;
                });
              } else {
                setState(() {
                  enableButton = true;
                });
              }
            } else {
              setState(() {
                enableButton = false;
              });
            }
          },
          decoration: InputDecoration(
              contentPadding: REdgeInsets.fromLTRB(25, 0, 0, 0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1.0.w, color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              filled: true,
              hintStyle: gothamMedium.copyWith(
                  color: Colors.grey,
                  fontSize: Dimensions.FONT_XL.sp,
                  fontWeight: FontWeight.w600
              ),
              hintText: Constant.LANG == Constant.EN ? ENG.SIGNUP_LAST_NAME : IT.SIGNUP_LAST_NAME,
              fillColor: const Color(0xFFEEF5F3)),
        ),
        SizedBox(height: Dimensions.PADDING_XL.h),

        // Enter email address text filed
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: gothamMedium.copyWith(
            color: Colors.black.withOpacity(0.5),
            fontSize: Dimensions.FONT_XL.sp,
          ),
          cursorColor: Colors.black,
          cursorHeight: 25.h,
          cursorWidth: 1.5.w,
          onChanged: (value) {
            if (firstNameController.text.toString().trim().isNotEmpty &&
                lastNameController.text.toString().trim().isNotEmpty &&
                Utility.emailValidation(emailController.text.toString().trim()) &&
                passwordController.text.toString().trim().isNotEmpty &&
                repeatPasswordController.text.toString().trim().isNotEmpty) {
              if(passwordController.text.toString().trim().isNotEmpty !=
                  repeatPasswordController.text.toString().trim().isNotEmpty) {
                setState(() {
                  Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.SIGNUP_PASSWORD_NOT_MATCH : IT.SIGNUP_PASSWORD_NOT_MATCH);
                  enableButton = false;
                });
              } else {
                setState(() {
                  enableButton = true;
                });
              }
            } else {
              setState(() {
                enableButton = false;
              });
            }
          },
          decoration: InputDecoration(
              contentPadding: REdgeInsets.fromLTRB(25, 0, 0, 0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1.0.w, color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              filled: true,
              hintStyle: gothamMedium.copyWith(
                  color: Colors.grey,
                  fontSize: Dimensions.FONT_XL.sp,
                  fontWeight: FontWeight.w600
              ),
              hintText: Constant.LANG == Constant.EN ? ENG.SIGNUP_ENTER_EMAIL : IT.SIGNUP_ENTER_EMAIL,
              fillColor: const Color(0xFFEEF5F3)),
        ),
        SizedBox(height: Dimensions.PADDING_XL.h),

        // Password text filed
        TextFormField(
          controller: passwordController,
          keyboardType: TextInputType.text,
          style: gothamMedium.copyWith(
            color: Colors.black.withOpacity(0.5),
            fontSize: Dimensions.FONT_XL.sp,
          ),
          cursorColor: Colors.black,
          cursorHeight: 25.h,
          cursorWidth: 1.5.w,
          obscureText: true,
          onChanged: (value) {
            if (firstNameController.text.toString().trim().isNotEmpty &&
                lastNameController.text.toString().trim().isNotEmpty &&
                Utility.emailValidation(emailController.text.toString().trim()) &&
                passwordController.text.toString().trim().isNotEmpty &&
                repeatPasswordController.text.toString().trim().isNotEmpty) {
              if(passwordController.text.toString().trim().isNotEmpty !=
                  repeatPasswordController.text.toString().trim().isNotEmpty) {
                setState(() {
                  Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.SIGNUP_PASSWORD_NOT_MATCH : IT.SIGNUP_PASSWORD_NOT_MATCH);
                  enableButton = false;
                });
              } else {
                setState(() {
                  enableButton = true;
                });
              }
            } else {
              setState(() {
                enableButton = false;
              });
            }
          },
          decoration: InputDecoration(
              contentPadding: REdgeInsets.fromLTRB(25, 0, 0, 0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1.0.w, color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              filled: true,
              hintStyle: gothamMedium.copyWith(
                  color: Colors.grey,
                  fontSize: Dimensions.FONT_XL.sp,
                  fontWeight: FontWeight.w600
              ),
              hintText: Constant.LANG == Constant.EN ? ENG.LOGIN_PASSWORD : IT.LOGIN_PASSWORD,
              fillColor: const Color(0xFFEEF5F3)),
        ),
        SizedBox(height: Dimensions.PADDING_XL.h),

        // Repeat the password text filed
        TextFormField(
          controller: repeatPasswordController,
          keyboardType: TextInputType.text,
          style: gothamMedium.copyWith(
            color: Colors.black.withOpacity(0.5),
            fontSize: Dimensions.FONT_XL.sp,
          ),
          cursorColor: Colors.black,
          cursorHeight: 25.h,
          cursorWidth: 1.5.w,
          obscureText: true,
          onChanged: (value) {
            if (firstNameController.text.toString().trim().isNotEmpty &&
                lastNameController.text.toString().trim().isNotEmpty &&
                Utility.emailValidation(emailController.text.toString().trim()) &&
                passwordController.text.toString().trim().isNotEmpty &&
                repeatPasswordController.text.toString().trim().isNotEmpty) {
              if(passwordController.text.toString().trim().isNotEmpty !=
                  repeatPasswordController.text.toString().trim().isNotEmpty) {
                setState(() {
                  Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.SIGNUP_PASSWORD_NOT_MATCH : IT.SIGNUP_PASSWORD_NOT_MATCH);
                  enableButton = false;
                });
              } else {
                setState(() {
                  enableButton = true;
                });
              }
            } else {
              setState(() {
                enableButton = false;
              });
            }
          },
          decoration: InputDecoration(
              contentPadding: REdgeInsets.fromLTRB(25, 0, 0, 0),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1.0.w, color: Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              filled: true,
              hintStyle: gothamMedium.copyWith(
                  color: Colors.grey,
                  fontSize: Dimensions.FONT_XL.sp,
                  fontWeight: FontWeight.w600
              ),
              hintText: Constant.LANG == Constant.EN ? ENG.SIGNUP_REPEAT_PASSWORD : IT.SIGNUP_REPEAT_PASSWORD,
              fillColor: const Color(0xFFEEF5F3)),
        ),
      ],
    );
  }

  Future<void> googleLogin() async {
    try {
      await _googleSignIn.signIn().then((value) async {
        _currentUser = value;
        value?.authentication.then((value1) {
          idToken = value1.idToken;
          googleSocialLogin();
          debugPrint("$TAG accessToken ======> ${value1.accessToken}");
          debugPrint("$TAG idToken ======> ${value1.idToken}");
          return null;
        });
        debugPrint("$TAG id ======> ${value?.id}");
        debugPrint("$TAG email ======> ${value?.email}");
        debugPrint("$TAG displayName ======> ${value?.displayName}");
        debugPrint("$TAG photoUrl ======> ${value?.photoUrl}");
        return null;
      });
    } catch (error) {
      debugPrint("$TAG Error ======> $error");
    }
  }

  Future<void> _handleGoogleSignOut() async {
    await _googleSignIn.disconnect();
    setState(() {
      _currentUser = null;
    });
  }

  Future<void> facebookLogin() async {
    facebookResult = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
    // by default we request the email and the public profile
    // or FacebookAuth.i.login()
    if (facebookResult.status == LoginStatus.success) {
      // you are logged
      _accessToken = facebookResult.accessToken!;
      _facebookUserData = await FacebookAuth.instance.getUserData();
      facebookSocialLogin();
    } else {
      debugPrint("$TAG result status ======> ${facebookResult.status}");
      debugPrint("$TAG result status ======> ${facebookResult.message}");
    }
  }

  Future<void> _handleFacebookSignOut() async {
    await FacebookAuth.instance.logOut();
    setState(() {
      _accessToken = null;
      _facebookUserData = null;
    });
  }

  void googleSocialLogin() {
    setState(() {
      showLoader = true;
    });
    var jsonBody = json.encode({
      Constant.firstName: _currentUser?.displayName!.toString().split(" ").first,
      Constant.lastName: _currentUser?.displayName!.toString().split(" ").last,
      Constant.id:_currentUser?.id,
      Constant.idToken: idToken,
      Constant.email: _currentUser?.email,
      Constant.photoUrl: _currentUser?.photoUrl,
      Constant.provider: Constant.GOOGLE,
    });
    PostRequest request = PostRequest();
    request.getResponse(cmd: RequestCmd.socialLogin, token: null, body: jsonBody, responseCode: SOCIAL_LOGIN);
    request.setListener(this);
  }

  void facebookSocialLogin() {
    setState(() {
      showLoader = true;
    });
    var jsonBody = json.encode({
      Constant.firstName: _facebookUserData!["name"].toString().split(" ").first,
      Constant.lastName: _facebookUserData!["name"].toString().split(" ").last,
      Constant.id: _facebookUserData!["id"],
      Constant.idToken: _accessToken,
      Constant.email: _facebookUserData!["email"],
      Constant.photoUrl: _facebookUserData!["picture"]["data"]["url"],
      Constant.provider: Constant.FACEBOOK,
    });
    PostRequest request = PostRequest();
    request.getResponse(cmd: RequestCmd.socialLogin, token: null, body: jsonBody, responseCode: SOCIAL_LOGIN);
    request.setListener(this);
  }

  void register(String firstName, String lastName, String email, String password, String repeatPassword){
    setState(() {
      showLoader = true;
    });
    var jsonBody = json.encode({
      Constant.first_name: firstName,
      Constant.last_name: lastName,
      Constant.email: email,
      Constant.password: password,
      Constant.password_verify: repeatPassword,
    });
    PostRequest request = PostRequest();
    request.getResponse(cmd: RequestCmd.register, token: null, body: jsonBody, responseCode: SIMPLE_LOGIN);
    request.setListener(this);
  }

  @override
  void onFailed(response, statusCode) {
    setState(() {
      showLoader = false;
      if(response[Constant.msg] != null) {
        Utility.showErrorToast(response[Constant.msg]);
      } else {
        Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.TRY_AFTER_SOMEIME : IT.TRY_AFTER_SOMEIME);
      }
    });
  }

  @override
  void onSuccess(response, responseCode) {
    setState(() {
      showLoader = false;
    });
    if (response[Constant.STATUS]) {
      if(SIMPLE_LOGIN == responseCode) {
        setState(() {
          showLoader = false;
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder:
            (context) => const LoginScreen(),
          )
        );
      } else {
        setState(() {
          showLoader = false;
          LoginUserModel.fromJson(response[Constant.loginSuccessData]);
          String user = jsonEncode(LoginUserModel.fromJson(response[Constant.loginSuccessData]));
          Utility.setStringSharedPreference(Constant.userObject, user);
        });
        if(_accessToken != null) {
          _handleFacebookSignOut();
        }
        if(_currentUser != null) {
          _handleGoogleSignOut();
        }
        if(response[Constant.loginSuccessData]["current_company"] == null) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder:
              (context) => const CreateCompanyScreen(),
            )
          );
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder:
              (context) => const HomeScreen(),
            )
          );
        }
      }
    } else {
      setState(() {
        showLoader = false;
        Utility.showErrorToast(response[Constant.msg]);
      });
    }
  }
}