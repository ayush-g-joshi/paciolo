
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/home/CreateInvoiceScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';

import '../auth/login_screen.dart';
import '../network/ResponseListener.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';
import '../util/images.dart';
import '../util/styles.dart';

class DocumentTypeScreen extends StatefulWidget {
  const DocumentTypeScreen({Key? key}) : super(key: key);

  @override
  State<DocumentTypeScreen> createState() => _DocumentTypeScreenState();
}

class _DocumentTypeScreenState extends State<DocumentTypeScreen> implements ResponseListener {

  String TAG = "_DocumentTypeScreenState";
  var currentCompany;
  var currentCompanyId;
  LoginUserModel? userModel;
  bool showLoader = false;
  List docAllData = List.from([]);
  int GET_DOCUMENT_LIST = 2000;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;

      loadDocumentType();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(AllColors.colorBlue),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          Constant.LANG == Constant.EN ? ENG.CREATE_INVOICE_TITLE : IT.CREATE_INVOICE_TITLE,
          style: gothamRegular.copyWith(
            fontSize: Dimensions.FONT_L,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        opacity: 0.7,
        inAsyncCall: showLoader,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: docAllData.isEmpty ? Container(
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
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ) : Container(
                child: ListView.separated(
                  itemCount: docAllData.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(height: 1, color: Colors.black54,);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return CreateInvoiceScreen(documentTypeData : docAllData[index]);
                        },));
                        //Navigator.push(context, docAllData[index]);
                      },
                      child: ListTile(
                        title: Text(
                          docAllData[index]["name"],
                          style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M,
                            color: const Color(AllColors.colorText),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void loadDocumentType() async {
    setState(() {
      showLoader = true;
    });

    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.getInvoiceDocFilter,
        token: userModel!.authorization,
        responseCode: GET_DOCUMENT_LIST,
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
    setState(() {
      docAllData.clear();

      for (int i = 0; i < response[Constant.data].length; i++) {
        docAllData.add(response[Constant.data][i]);
      }
      docAllData.sort((a, b) {
        return a["name"].toLowerCase().compareTo(b["name"].toLowerCase());
      });
      debugPrint("$TAG docAllData ========> ${docAllData.length}");
      showLoader = false;
    });
  }
}
