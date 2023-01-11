import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../auth/login_screen.dart';
import '../util/images.dart';

class SelectPaymentModeScreen extends StatefulWidget {


  const SelectPaymentModeScreen({Key? key }) : super(key: key);

  @override
  State<SelectPaymentModeScreen> createState() => _SelectPaymentModeScreenState();
}

class _SelectPaymentModeScreenState extends State<SelectPaymentModeScreen> implements ResponseListener {

  String TAG = "_SelectPaymentModeScreenState";
  bool showLoader = false;
  DateTime currentDate = DateTime.now();
  var currentCompanyId;
  LoginUserModel? userModel;

  List paymentModeList = List.from([]);

  var GET_PAYMENT_MODE_LIST = 9009;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getPaymentMode();
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
          Constant.LANG == Constant.EN ? ENG.SELECT_PAYMENT_MODE : IT.SELECT_PAYMENT_MODE,
          style: gothamRegular.copyWith(
            fontSize: Dimensions.FONT_L,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: paymentModeList.isEmpty ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.noResult,
                      width: 300.w,
                      height: 300.h,
                      fit: BoxFit.fill,
                    ),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.NO_RESULT_TO_SHOW : IT.NO_RESULT_TO_SHOW,
                      textAlign: TextAlign.center,
                      style: gothamRegular.copyWith(
                          color: const Color(AllColors.colorNoResult),
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ) : ListView.separated(
                itemCount: paymentModeList.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(height: 1, color: Colors.black54,);
                },
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, paymentModeList[index]);
                    },
                    child: ListTile(
                      title: Text(
                        paymentModeList[index]["name"],
                        style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M,
                            color: const Color(AllColors.colorText)
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getPaymentMode() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getPaymentModeType,
        token: userModel!.authorization,
        responseCode: GET_PAYMENT_MODE_LIST,
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
    if (responseCode == GET_PAYMENT_MODE_LIST) {

      debugPrint("$TAG GET_PAYMENT_MODE_LIST ========> ${response[Constant.data]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data].length; i++) {
          paymentModeList.add(response[Constant.data][i]);
        }
      });
    }
  }
}