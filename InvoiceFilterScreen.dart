import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../util/CommonCSS.dart';

class InvoiceFilterScreen extends StatefulWidget {
  var year;
  var documentType;

  InvoiceFilterScreen(this.year, this.documentType, {Key? key}) : super(key: key);

  @override
  State<InvoiceFilterScreen> createState() => _InvoiceFilterScreenState();
}

class _InvoiceFilterScreenState extends State<InvoiceFilterScreen> implements ResponseListener {

  String TAG = "_InvoiceFilterScreenState";
  int YEAR_DATA = 2001;
  int DOC_TYPE_DATA = 2002;
  int UPDATE_DOC_TYPE = 2003;
  int GET_COMPANY_DATA = 2004;
  int GET_UPDATED_COMPANY_DATA = 2005;

  bool showLoader = false;
  LoginUserModel? userModel;
  DateTime currentDate = DateTime.now();
  String selectedYear = "";
  String selectedDocType = "";
  var currentCompanyId;
  var lastDocumentLoadedId;
  List<String> yearList = List.from([]);

  List docAllData = List.from([]);
  List<String> docTypeFilter = List.from([]);

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

    if (widget.year != null) {
      selectedYear = widget.year.toString();
      currentDate = DateTime(int.parse(widget.year.toString()));
    } else {
      selectedYear = currentDate.year.toString();
    }
    debugPrint("$TAG selectedYear value ======> $selectedYear");

    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getYears();
      getCompanyData();
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
          Constant.LANG == Constant.EN ? ENG.INVOICE_TITLE : IT.INVOICE_TITLE,
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
                  Constant.LANG == Constant.EN ? ENG.CHOOSE_YEAR : IT.CHOOSE_YEAR,
                  textAlign: TextAlign.start,
                  style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L
                  ),
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
                            Constant.LANG == Constant.EN ? ENG.CHOOSE_YEAR : IT.CHOOSE_YEAR,
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
                          items: yearList.map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: gothamRegular.copyWith(
                                fontSize: Dimensions.FONT_M.sp,
                                letterSpacing: 0.5,
                                color: Colors.black
                              ),
                            ),
                          )).toList(),
                          value: selectedYear,
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value as String;
                            });
                          },
                        )
                    )
                ),
              ),
              SizedBox(
                height: 40.0.h,
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  Constant.LANG == Constant.EN ? ENG.CHOOSE_DOCUMENT : IT.CHOOSE_DOCUMENT,
                  textAlign: TextAlign.start,
                  style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L
                  ),
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
                      hint: Text(Constant.LANG == Constant.EN ? ENG.CHOOSE_DOCUMENT : IT.CHOOSE_DOCUMENT,
                        style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M.sp,
                            letterSpacing: 0.5,
                            color: Colors.black
                        ),
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
                        ...docTypeFilter.map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: gothamRegular.copyWith(
                                  fontSize: Dimensions.FONT_M.sp,
                                  letterSpacing: 0.5,
                                  color: Colors.black
                              ),
                            ),
                          ),
                        ),
                      ],
                      value: selectedDocType,
                      onChanged: (value) {
                        setState(() {
                          selectedDocType = value.toString();
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
                  for (int i = 0; i < docAllData.length; i++) {
                    if (docAllData[i]["name"] == selectedDocType) {
                      saveDocument(i);
                      break;
                    }
                  }
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
    var body = jsonEncode(
        {'pid': null, 'type': "document", 'year': currentDate.year - 4});

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.getYears,
        token: userModel!.authorization,
        body: body,
        responseCode: YEAR_DATA,
        companyId: userModel!.currentCompany?.id);
    request.setListener(this);
  }

  void getCompanyData() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.companyAll,
        token: userModel!.authorization,
        responseCode: GET_COMPANY_DATA,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getDocuments() async {
    setState(() {
      showLoader = true;
    });

    String url = Constant.SERVER_URL + RequestCmd.getInvoiceDocFilter;
    String basicAuth = 'Bearer ${userModel!.authorization}';
    Map<String, String> headers;
    if (userModel!.currentCompany?.id != null) {
      headers = {
        "content-type": 'application/json',
        'Origin': Constant.ORIGIN_URL,
        'Authorization': basicAuth,
        'Company': userModel!.currentCompany!.id.toString(),
      };
    } else {
      headers = {
        "content-type": 'application/json',
        'Origin': Constant.ORIGIN_URL,
        'Authorization': basicAuth,
      };
    }

    final response = await http.get(Uri.parse(url), headers: headers);
    debugPrint("get response body ==========> ${response.body}");
    if (jsonDecode(response.body)["success"]) {
      var responseObject = jsonDecode(response.body);
      setState(() {
        docAllData.clear();
        docAllData.addAll(responseObject[Constant.data]);
        for (int i = 0; i < docAllData.length; i++) {
          docTypeFilter.add(docAllData[i]["name"]);
        }
        for (int i = 0; i < docAllData.length; i++) {
          if (lastDocumentLoadedId == docAllData[i]["id"]) {
            selectedDocType = docAllData[i]["name"];
            break;
          } else {
            selectedDocType = docAllData[0]["name"];
          }
        }

        debugPrint("$TAG docTypeFilter ========> ${docTypeFilter.length}");
        debugPrint("$TAG docAllData ========> ${docAllData.length}");
        showLoader = false;
      });
    } else {
      setState(() {
        showLoader = false;
        if (response.statusCode == 401) {
          Utility.clearPreference();
          Utility.showErrorToast("Session expired");
        }
      });
      if (response.statusCode == 401) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
      }
    }
  }

  void saveDocument(int index) {
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      "currentDocumentTypeText": docAllData[index]["name"].toString(),
      "currentDocumentTypeId": docAllData[index]["id"],
      "currentDocumentTypeExpireDate": docAllData[index]["expiry_date"]
    });

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.updateSelectedDocFilter,
        token: userModel!.authorization,
        body: body,
        responseCode: UPDATE_DOC_TYPE,
        companyId: userModel!.currentCompany?.id);
    request.setListener(this);
  }

  void getUpdatedCompanyList() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.companyAll,
        token: userModel!.authorization,
        responseCode: GET_UPDATED_COMPANY_DATA,
        companyId: currentCompanyId);
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
    if(responseCode == GET_COMPANY_DATA) {
      setState(() {
        showLoader = false;
        userModel?.currentCompany = CurrentCompany.fromJson(response["current_company"]);
        Utility.setStringSharedPreference(Constant.userObject, jsonEncode(userModel));
        currentCompanyId = userModel?.currentCompany?.id;
        lastDocumentLoadedId = userModel?.currentCompany?.lastTypeOfDocumentLoadedId;
      });
      getDocuments();
    } else if (responseCode == YEAR_DATA) {
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
        selectedYear = currentDate.year.toString();
      });
    } else if (responseCode == UPDATE_DOC_TYPE) {
      setState(() {
        showLoader = false;
      });
      Navigator.pop(context, {"year": selectedYear, "docType": selectedDocType});
    } else if (responseCode == GET_UPDATED_COMPANY_DATA) {
      setState(() {
        showLoader = false;
        userModel?.currentCompany = CurrentCompany.fromJson(response["current_company"]);
        Utility.setStringSharedPreference(Constant.userObject, jsonEncode(userModel));
      });
    }
  }
}