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

class SelectUnitTypeScreen extends StatefulWidget {

  var selectedVat;

  SelectUnitTypeScreen({Key? key, this.selectedVat}) : super(key: key);

  @override
  State<SelectUnitTypeScreen> createState() => _SelectUnitTypeScreenState();
}

class _SelectUnitTypeScreenState extends State<SelectUnitTypeScreen> implements ResponseListener {

  String TAG = "_SelectUnitTypeScreenState";
  bool showLoader = false;
  DateTime currentDate = DateTime.now();
  var currentCompanyId;
  LoginUserModel? userModel;

  List unitList = List.from([]);

  var GET_UNIT_LIST = 9003;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getVatType();
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
          Constant.LANG == Constant.EN ? ENG.SELECT_UNIT_TYPE : IT.SELECT_UNIT_TYPE,
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
                child: unitList.isEmpty
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
                              color: const Color(AllColors.colorNoResult),
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ) : Container(
                  child: ListView.separated(
                    itemCount: unitList.length,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(height: 1, color: Colors.black54,);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, {"unit_display": unitList[index]["name"] });
                        },
                        child: ListTile(
                          title: Text(
                            unitList[index]["name"],
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

  void getVatType() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getMeasureUnit,
        token: userModel!.authorization,
        responseCode: GET_UNIT_LIST,
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
    if (responseCode == GET_UNIT_LIST) {

      debugPrint("$TAG GET VAT LIST ========> ${response[Constant.data]["measurement_unit"]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data]["measurement_unit"].length; i++) {
          unitList.add(response[Constant.data]["measurement_unit"][i]);
        }
      });
    }
  }
}