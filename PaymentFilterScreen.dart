
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../util/CommonCSS.dart';

class PaymentFilterScreen extends StatefulWidget {
  var docType;
  var year;

  PaymentFilterScreen(this.year, this.docType, {Key? key}) : super(key: key);

  @override
  State<PaymentFilterScreen> createState() => _PaymentFilterScreenState();
}

class _PaymentFilterScreenState extends State<PaymentFilterScreen> implements ResponseListener {

  String TAG = "_PaymentFilterScreenState";
  int YEAR_DATA = 2001;
  int WALLET_DATA = 2002;
  bool showLoader = false;
  LoginUserModel? userModel;
  DateTime currentDate = DateTime.now();
  String selectedYear = "";
  String selectedFilterFirst = "";
  var currentCompanyId;
  var firstFilterValue;
  List<String> yearList = List.from([]);

  List<String> filterFirst = [
    "Visualizza tutti",
    "Movimentazioni dei documenti",
    "Movimentazioni delle spese extra",
    "Movimentazioni dei dipendenti"
  ];

  @override
  void initState() {
    debugPrint("$TAG widget year value ======> ${widget.year}");
    debugPrint("$TAG widget docType value ======> ${widget.docType}");

    yearList = [
      (currentDate.year + 2).toString(),
      (currentDate.year + 1).toString(),
      (currentDate.year).toString(),
      (currentDate.year - 1).toString(),
      (currentDate.year - 2).toString(),
      (currentDate.year - 3).toString(),
      (currentDate.year - 4).toString(),
    ];


    if (widget.year != null) {
      selectedYear = widget.year.toString();
      currentDate = DateTime(int.parse(widget.year.toString()));
      if (widget.docType == null) {
        selectedFilterFirst = filterFirst[0];
      } else if (widget.docType == "ACCOUNT") {
        selectedFilterFirst = filterFirst[1];
      } else if (widget.docType == "EXTRA_COST") {
        selectedFilterFirst = filterFirst[2];
      } else if (widget.docType == "EMPLOYEE") {
        selectedFilterFirst = filterFirst[3];
      } else {
        selectedFilterFirst = filterFirst[0];
      }
    } else {
      selectedYear = currentDate.year.toString();
      selectedFilterFirst = filterFirst[0];
    }

    debugPrint("$TAG selectedYear value ======> $selectedYear");
    debugPrint("$TAG selected Filter First value ======> $selectedFilterFirst");

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
          Constant.LANG == Constant.EN ? ENG.PAYMENT_TITLE : IT.PAYMENT_TITLE,
          style: gothamMedium.copyWith(
              color: Colors.white, fontSize: Dimensions.FONT_L),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: Container(
          padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  Constant.LANG == Constant.EN
                      ? ENG.CHOOSE_YEAR
                      : IT.CHOOSE_YEAR,
                  textAlign: TextAlign.start,
                  style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L),
                ),
              ),
              // year dropdown
              Visibility(
                visible: true,
                child: DropdownButtonHideUnderline(
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: DropdownButton2<String>(
                          buttonPadding:
                              const EdgeInsets.only(left: 14, right: 14),
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.r),
                            border: Border.all(
                              color: Colors.black26,
                            ),
                            color: Colors.white,
                          ),
                          buttonElevation: 2,
                          hint: Text(
                            Constant.LANG == Constant.EN
                                ? ENG.CHOOSE_YEAR
                                : IT.CHOOSE_YEAR,
                            style: gothamRegular.copyWith(
                                fontSize: Dimensions.FONT_M.sp,
                                letterSpacing: 0.5,
                                color: Colors.black),
                          ),
                          iconSize: 30,
                          isExpanded: true,
                          dropdownElevation: 8,
                          dropdownMaxHeight: 300.h,
                          dropdownDecoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10.r),
                            bottomLeft: Radius.circular(10.r),
                          )),
                          items: yearList
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: gothamRegular.copyWith(
                                          fontSize: Dimensions.FONT_M.sp,
                                          letterSpacing: 0.5,
                                          color: Colors.black),
                                    ),
                                  ))
                              .toList(),
                          value: selectedYear,
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value as String;
                            });
                          },
                        ))),
              ),
              SizedBox(
                height: 40.0.h,
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  Constant.LANG == Constant.EN
                      ? ENG.CHOOSE_DOCUMENT
                      : IT.CHOOSE_DOCUMENT,
                  textAlign: TextAlign.start,
                  style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L),
                ),
              ),
              // document type filter
              Visibility(
                visible: true,
                child: DropdownButtonHideUnderline(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DropdownButton2<String>(
                      buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                      buttonDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                        color: Colors.white,
                      ),
                      buttonElevation: 2,
                      hint: Text(
                        Constant.LANG == Constant.EN
                            ? ENG.CHOOSE_DOCUMENT
                            : IT.CHOOSE_DOCUMENT,
                        style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M.sp,
                            letterSpacing: 0.5,
                            color: Colors.black),
                      ),
                      iconSize: 30,
                      isExpanded: true,
                      dropdownElevation: 8,
                      dropdownMaxHeight: 300.h,
                      dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10.r),
                        bottomLeft: Radius.circular(10.r),
                      )),
                      items: [
                        ...filterFirst.map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: gothamRegular.copyWith(
                                  fontSize: Dimensions.FONT_M.sp,
                                  letterSpacing: 0.5,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                      value: selectedFilterFirst,
                      onChanged: (value) {
                        setState(() {
                          if (value == filterFirst[0]) {
                            firstFilterValue = null;
                          } else if (value == filterFirst[1]) {
                            firstFilterValue = "ACCOUNT";
                          } else if (value == filterFirst[2]) {
                            firstFilterValue = "EXTRA_COST";
                          } else if (value == filterFirst[3]) {
                            firstFilterValue = "EMPLOYEE";
                          }
                          selectedFilterFirst = value.toString();
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40.0.h,
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context, {"year": selectedYear, "docType": firstFilterValue});
                },
                child: Container(
                  height: 40.h,
                  width: 200.w,
                  decoration: CommonCSS.buttonDecoration(true, 5.r, AllColors.colorBlue, 0.5, 0),
                  child: Center(
                    child: Text(
                      Constant.LANG == Constant.EN ? ENG.APPLY : IT.APPLY,
                      style: gothamBold.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.FONT_XL.sp,
                          letterSpacing: 0.5),
                    ),
                  ),
                ),
              ),
            ],
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
        Utility.showErrorToast(Constant.LANG == Constant.EN
            ? ENG.SESSION_EXPIRED
            : IT.SESSION_EXPIRED);
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
        for (int i = 0; i < response[Constant.data].length; i++) {
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
        selectedYear = currentDate.year.toString();
      });
    }
  }

}