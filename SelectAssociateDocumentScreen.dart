import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../auth/login_screen.dart';
import '../model/LoginUserModel.dart';
import '../network/GetRequest.dart';
import '../network/ResponseListener.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';
import '../util/images.dart';
import '../util/styles.dart';

class SelectAssociateDocumentScreen extends StatefulWidget {

  var customerId;
  bool isPositive;

  SelectAssociateDocumentScreen({Key? key, this.customerId, required this.isPositive}) : super(key: key);

  @override
  State<SelectAssociateDocumentScreen> createState() =>
      _SelectAssociateDocumentScreenState();
}

class _SelectAssociateDocumentScreenState extends State<SelectAssociateDocumentScreen> implements ResponseListener {

  String TAG = "_SelectAssociateSubjectScreenState";
  bool showLoader = false;
  DateTime currentDate = DateTime.now();
  var currentCompanyId;
  LoginUserModel? userModel;

  TextEditingController controller = TextEditingController();

  List subjectList = List.from([]);
  List filterList = List.from([]);

  int status = 1;

  var GET_DOCUMENT = 9001;

  @override
  void initState() {

    status = widget.isPositive == true ? 1 : -1;

    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      loadDocumentData();
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
          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_FILTER_ASSOCIATE_DOCUMENT : IT.PAYMENT_REGISTRY_FILTER_ASSOCIATE_DOCUMENT,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                      icon: const Icon(Icons.cancel),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0.w,
                        color: Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 0.7.w,
                        color: const Color(AllColors.colorGrey).withOpacity(0.7),
                      ),
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
                    ),
                    filled: true,
                    hintText: Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_SEARCH_HINT : IT.PAYMENT_REGISTRY_SEARCH_HINT,
                    hintStyle: gothamMedium.copyWith(
                        color: Colors.grey,
                        fontSize: Dimensions.FONT_XL.sp,
                        fontWeight: FontWeight.w600
                    ),
                    fillColor: Colors.white,
                  ),
                  onChanged: onSearchTextChanged,
                ),
              ),
            ),
            Expanded(
              child: subjectList.isEmpty ? Container(
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
              ) : Container(
                child: filterList.isNotEmpty || controller.text.isNotEmpty ?
                ListView.builder(
                  itemCount: filterList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, {"documentData": filterList[index]});
                      },
                      child: Container(
                        color: (index % 2 == 0) ? Colors.white : const Color(AllColors.colorListBack),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                    child: Text(
                                      filterList[index]["name"],
                                      textAlign: TextAlign.start,
                                      style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${double.parse(filterList[index]["paid"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                        textAlign: TextAlign.end,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorGreen),
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal),
                                      ),
                                      SizedBox(height: Dimensions.PADDING_S.h,),
                                      Text(
                                        "${double.parse(filterList[index]["unpaid"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                        textAlign: TextAlign.end,
                                        style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorRed),
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ) : ListView.builder(
                  itemCount: subjectList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, {"documentData": subjectList[index]});
                      },
                      child: Container(
                        color: (index % 2 == 0) ? Colors.white : const Color(AllColors.colorListBack),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                    child: Text(
                                      subjectList[index]["name"],
                                      textAlign: TextAlign.start,
                                      style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${double.parse(subjectList[index]["paid"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                        textAlign: TextAlign.end,
                                        style: gothamRegular.copyWith(
                                            color: const Color(AllColors.colorGreen),
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.normal),
                                      ),
                                      SizedBox(height: Dimensions.PADDING_S.h,),
                                      Text(
                                        "${double.parse(subjectList[index]["unpaid"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                        textAlign: TextAlign.end,
                                        style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorRed),
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    if(responseCode == GET_DOCUMENT) {
      setState(() {
        showLoader = false;
        subjectList.clear();
        for (int i = 0; i < response[Constant.data].length; i++) {
          subjectList.add(response[Constant.data][i]);
        }
      });
      debugPrint("$TAG GET subject LIST ========> ${response[Constant.data]}");
    }
  }

  void loadDocumentData() {
    // https://devapi.paciolo.it/document/search_by_customer_with_details/9621/1
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getAssociateDocument}${widget.customerId}/$status",
        token: userModel!.authorization,
        responseCode: GET_DOCUMENT,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  onSearchTextChanged(String text) async {
    filterList.clear();
    if (text.isNotEmpty) {
      setState(() {
        for (var subjects in subjectList) {
          if (subjects["name"].toString().toUpperCase().contains(text.toUpperCase()) ||
              subjects["name"].toString().toLowerCase().contains(text.toLowerCase())) {
            filterList.add(subjects);
          } else if(subjects["name"].toString().contains(text.toLowerCase())) {
            filterList.add(subjects);
          }
        }
      });
    }
  }
}
