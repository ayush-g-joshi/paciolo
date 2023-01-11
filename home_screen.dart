
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paciolo/home/CustomerScreen.dart';
import 'package:paciolo/home/InvoiceListScreen.dart';
import 'package:paciolo/home/OthersScreen.dart';
import 'package:paciolo/home/PaymentListScreen.dart';
import 'package:paciolo/home/CreateInvoiceScreen.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/images.dart';

import '../innerscreens/DocumentTypeScreen.dart';
import '../model/LoginUserModel.dart';
import '../network/PostRequest.dart';
import '../util/Utility.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements ResponseListener {

  String TAG = "_HomeScreenState";
  int _selectedIndex = 0;
  List navigationList = [
    PaymentListScreen(),
    const InvoiceListScreen(),
    const DocumentTypeScreen(),
    const CustomerScreen(),
    const OthersScreen(),
  ];
  LoginUserModel? userModel;
  int? currentCompanyId;
  var NOTIFICATION_DATA = 9000;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;

      FirebaseMessaging.instance.getToken().then((value) {
        if (value != null) {
          debugPrint("$TAG user FCM Token ======> $value");
          updateNotificationToken(value);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationList[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Images.document,
              height: 20,
              width: 20,
              matchTextDirection: true,
              color: const Color(AllColors.colorLightGrey),
            ),
            label: 'Document',
            activeIcon: SvgPicture.asset(
              Images.document,
              height: 20,
              width: 20,
              matchTextDirection: true,
              color: const Color(AllColors.colorBlue),
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Images.customer,
              height: 20,
              width: 20,
              matchTextDirection: true,
              color: const Color(AllColors.colorLightGrey),
            ),
            label: 'Customer',
            activeIcon: SvgPicture.asset(
              Images.customer,
              height: 20,
              width: 20,
              matchTextDirection: true,
              color: const Color(AllColors.colorBlue),
            ),
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_outlined,
              size: 35.0,
              color: Color(AllColors.colorBlue),
            ),
            label: "",
            activeIcon: Icon(
              Icons.add_circle_outlined,
              size: 35.0,
              color: Color(AllColors.colorBlue),
            ),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Images.products,
              height: 20,
              width: 20,
              matchTextDirection: true,
              color: const Color(AllColors.colorLightGrey),
            ),
            label: 'Products',
            activeIcon: SvgPicture.asset(
              Images.products,
              height: 20,
              width: 20,
              matchTextDirection: true,
              color: const Color(AllColors.colorBlue),
            ),
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 20,
              width: 30,
              child: SvgPicture.asset(
                Images.others,
                height: 20,
                width: 20,
                fit: BoxFit.contain,
                matchTextDirection: true,
                color: const Color(AllColors.colorLightGrey),
              ),
            ),
            label: 'Others',
            activeIcon: SizedBox(
              height: 20,
              width: 30,
              child: SvgPicture.asset(
                Images.others,
                height: 20,
                width: 20,
                fit: BoxFit.contain,
                matchTextDirection: true,
                color: const Color(AllColors.colorBlue),
              ),
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(AllColors.colorBlue),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void updateNotificationToken(String? value) {
    var body = jsonEncode({
      "device_token": value,
      "device_type": Platform.isAndroid ? Constant.ANDROID : Constant.IOS,
      "user_id": userModel!.userInfo!.id
    });

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.notificationTokenUpdate,
        token: userModel!.authorization,
        body: body,
        responseCode: NOTIFICATION_DATA,
        companyId: userModel!.currentCompany?.id);
    request.setListener(this);
  }

  @override
  void onFailed(response, statusCode) {
    debugPrint("$TAG Update Notification Token on failed ========> ${response.toString()}");
  }

  @override
  void onSuccess(response, responseCode) {
    if (responseCode == NOTIFICATION_DATA) {
      debugPrint("$TAG Update Notification Token on Success ========> ${response.toString()}");
    }
  }
}
