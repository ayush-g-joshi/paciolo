
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

class SelectReasonForPaymentScreen extends StatefulWidget {

  var selectedWithHolding;

  SelectReasonForPaymentScreen({Key? key, this.selectedWithHolding}) : super(key: key);

  @override
  State<SelectReasonForPaymentScreen> createState() => _SelectReasonForPaymentScreenState();
}

class _SelectReasonForPaymentScreenState extends State<SelectReasonForPaymentScreen> implements ResponseListener {

  String TAG = "_SelectReasonForPaymentScreenState";
  bool showLoader = false;
  var currentCompanyId;
  LoginUserModel? userModel;

  List withHoldingList = List.from([]);

  var GET_WITHHOLDING_LIST = 9004;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getWithHolding();
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
          Constant.LANG == Constant.EN ? ENG.SELECT_SELECT_FOR_PAYMENT_TITLE : IT.SELECT_SELECT_FOR_PAYMENT_TITLE,
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
                child: withHoldingList.isEmpty
                    ? Container(
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
                              color: Color(AllColors.colorNoResult),
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                )
                    : Container(
                  child: ListView.separated(
                    itemCount: withHoldingList.length,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(height: 1, color: Colors.black54,);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, withHoldingList[index]);
                        },
                        child: ListTile(
                          title: Text(
                            withHoldingList[index]["name"],
                            style: gothamRegular.copyWith(
                                fontSize: Dimensions.FONT_M,
                                color: const Color(AllColors.colorText)
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

  void getWithHolding() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getWithHoldings,
        token: userModel!.authorization,
        responseCode: GET_WITHHOLDING_LIST,
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
    if (responseCode == GET_WITHHOLDING_LIST) {

      debugPrint("$TAG GET_WITHHOLDING_LIST ========> ${response[Constant.data]["list"]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data]["list"].length; i++) {
          withHoldingList.add(response[Constant.data]["list"][i]);
        }
      });
    }
  }

}
