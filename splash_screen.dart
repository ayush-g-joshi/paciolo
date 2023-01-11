import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/home/home_screen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  var TAG = "_SplashScreenState";

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      if(value != null) {
        Map<String, dynamic> json = jsonDecode(value);
        LoginUserModel userModel = LoginUserModel.fromJson(json);
        debugPrint("$TAG user object Authorization ======> ${userModel.authorization}");
        Future.delayed(const Duration(seconds: 3), () {
          if(userModel.authorization != null && userModel.authorization != "") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                return const HomeScreen();
              },
            ));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                return const LoginScreen();
              },
            ));
          }
        },);
      } else {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                return const LoginScreen();
              },
            )
          );
        },);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
       body:  Container(
         decoration: const BoxDecoration(
           gradient: LinearGradient(
             begin: Alignment.topRight,
             end: Alignment.bottomLeft,
             colors: [
               Color(0xFF2573BD),
               Color(0xFF2F9BC3),
             ],
           ),
         ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Center(
               child: Container(
                 padding: const EdgeInsets.all(40.0),
                 child: Image.asset(Images.homeLogo)
               ),
             ),
             Container(
               width: 30.0.w,
               height: 30.0.h,
               child: CircularProgressIndicator(
                 color: Colors.white,
                 strokeWidth: 3.0.r,
               )
             ),
           ],
         ),
       ),
      )
    );
  }
}
