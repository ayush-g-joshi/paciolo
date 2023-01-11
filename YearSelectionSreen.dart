import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/styles.dart';

import '../util/Constants.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';

class YearSelectionScreen extends StatefulWidget {
  var year;
  YearSelectionScreen(this.year, {Key? key}) : super(key: key);

  @override
  State<YearSelectionScreen> createState() => _YearSelectionScreenState();
}

class _YearSelectionScreenState extends State<YearSelectionScreen> implements ResponseListener {

  String TAG = "_YearSelectionScreenState";

  bool showLoader = false;
  var currentCompanyId;
  var firstFilterValue;
  var YEAR_DATA = 2000;
  LoginUserModel? userModel;
  DateTime currentDate = DateTime.now();
  List<String> yearList = List.from([]);

  @override
  void initState() {
    debugPrint("$TAG widget year value ======> ${widget.year}");

    yearList = [
      (currentDate.year + 2).toString(),
      (currentDate.year + 1).toString(),
      (currentDate.year).toString(),
      (currentDate.year - 1).toString(),
      (currentDate.year - 2).toString(),
      (currentDate.year - 3).toString(),
      (currentDate.year - 4).toString(),
    ];


    Utility.getStringSharedPreference(Constant.userObject)
        .then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getYears();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(AllColors.colorBlue),
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
          Constant.LANG == Constant.EN ? ENG.CHOOSE_YEAR : IT.CHOOSE_YEAR,
          style: gothamMedium.copyWith(
              color: Colors.white, fontSize: Dimensions.FONT_L),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: Container(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 35.h,
                    margin: const EdgeInsets.fromLTRB(
                        Dimensions.PADDING_S,
                        Dimensions.PADDING_M,
                        Dimensions.PADDING_S,
                        Dimensions.PADDING_M
                    ),
                    child: Text(
                      yearList[index],
                      textAlign: TextAlign.start,
                      style: gothamRegular.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_M,
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(AllColors.colorBackBalance),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void getYears() {
    setState(() {
      showLoader = true;
    });
    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.getYears,
        token: userModel!.authorization,
        responseCode: YEAR_DATA,
        companyId: userModel!.currentCompany?.id);
    request.setListener(this);
  }

  @override
  void onFailed(response, statusCode) {
    setState(() {
      showLoader = false;
      if (statusCode != null && statusCode == 401) {
        Utility.clearPreference();
        Utility.showErrorToast(Constant.LANG == Constant.EN ? ENG.SESSION_EXPIRED : IT.SESSION_EXPIRED);
      }
    });
    if (statusCode != null && statusCode == 401) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ), (route) => false,
      );
    }
  }

  @override
  void onSuccess(response, responseCode) {
    if (responseCode == YEAR_DATA) {
      setState(() {
        showLoader = false;
        List<String> serverYear = List.from([]);
        for(int i =0; i< response[Constant.data].length; i++) {
          serverYear.add(response[Constant.data][i].toString());
        }

        serverYear.sort((b, a) => a.compareTo(b));
        debugPrint("$TAG main year array =======> $yearList");
        debugPrint("$TAG server year array =======> $serverYear");
        yearList.addAll(serverYear);
        debugPrint("$TAG combined year array =======> $yearList");

        List<String> result = yearList.toSet().toList();
        debugPrint("$TAG final year array =======> $result");

        yearList.clear();
        yearList.addAll(result);
      });
    }
  }
}
