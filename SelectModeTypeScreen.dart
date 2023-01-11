
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/ResponseListener.dart';

import '../auth/login_screen.dart';
import '../network/GetRequest.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';
import '../util/images.dart';
import '../util/styles.dart';

class SelectModeTypeScreen extends StatefulWidget {

  var selectedModeId;

  SelectModeTypeScreen({Key? key, this.selectedModeId}) : super(key: key);

  @override
  State<SelectModeTypeScreen> createState() => _SelectModeTypeScreenState();
}

class _SelectModeTypeScreenState extends State<SelectModeTypeScreen> implements ResponseListener {

  String TAG = "_SelectWalletTypeScreenState";
  bool showLoader = false;
  DateTime currentDate = DateTime.now();
  var currentCompanyId;
  LoginUserModel? userModel;

  List walletList = List.from([]);

  var GET_MODE_LIST = 9001;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
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
          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_FILTER_MODE : IT.PAYMENT_REGISTRY_FILTER_MODE,
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
              child: walletList.isEmpty ? Container(
                child: Center(
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
                          letterSpacing: 0.5
                        ),
                      ),
                    ],
                  ),
                ),
              ) : Container(
                child: ListView.separated(
                  itemCount: walletList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(height: 1, color: Colors.black54,);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, {"modeId": walletList[index]["id"], "modeName": walletList[index]["name"]});
                      },
                      child: ListTile(
                        title: Text(
                          walletList[index]["name"],
                          style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M,
                            color: const Color(AllColors.colorText),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  void getPaymentMode() {
    // https://devapi.paciolo.it/agent/popup
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getPaymentMode,
        token: userModel!.authorization,
        responseCode: GET_MODE_LIST,
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
    if (responseCode == GET_MODE_LIST) {

      debugPrint("$TAG GET MODE LIST ========> ${response[Constant.data]["paymentMode"]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data]["paymentMode"].length; i++) {
          walletList.add(response[Constant.data]["paymentMode"][i]);
        }
      });
    }
  }
}
