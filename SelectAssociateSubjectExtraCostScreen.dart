import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/images.dart';
import 'package:paciolo/util/styles.dart';

import '../auth/login_screen.dart';
import '../model/LoginUserModel.dart';
import '../network/PostRequest.dart';
import '../network/ResponseListener.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';

class SelectAssociateSubjectExtraCostScreen extends StatefulWidget {
  const SelectAssociateSubjectExtraCostScreen({Key? key}) : super(key: key);

  @override
  State<SelectAssociateSubjectExtraCostScreen> createState() => _SelectAssociateSubjectExtraCostScreenState();
}

class _SelectAssociateSubjectExtraCostScreenState extends State<SelectAssociateSubjectExtraCostScreen> implements ResponseListener{

  String TAG = "_SelectAssociateSubjectExtraCostScreenState";
  bool showLoader = false;
  var currentCompanyId;
  LoginUserModel? userModel;

  List categoryDataList = List.from([]);

  var GET_CATEGORY_DATA = 4001;

  @override
  void initState() {

    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getCategory();
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
          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_FILTER_ASSOCIATE : IT.PAYMENT_REGISTRY_FILTER_ASSOCIATE,
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
              child: categoryDataList.isEmpty ? Container(
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
                child: ListView.builder(
                  itemCount: categoryDataList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  // separatorBuilder: (BuildContext context, int index) {
                  //   return const Divider(height: 1, color: Colors.black54,);
                  // },
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, {"walletId": categoryDataList[index]["id"], "walletName": categoryDataList[index]["name"]});
                          },
                          child: ListTile(
                            title: Text(
                              categoryDataList[index]["name"],
                              style: gothamRegular.copyWith(
                                fontSize: Dimensions.FONT_L,
                                color: const Color(AllColors.colorText),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Colors.black54,),
                        if(categoryDataList[index]["subs"].length > 0)
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categoryDataList[index]["subs"].length,
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            // separatorBuilder: (BuildContext context, int index) {
                            //   return const Divider(height: 1, color: Colors.black54,);
                            // },
                            itemBuilder: (BuildContext context, int childIndex) {
                              return Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: Dimensions.PADDING_L, right: Dimensions.PADDING_L),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context, {
                                          "walletId": categoryDataList[index]["subs"][childIndex]["id"],
                                          "walletName": categoryDataList[index]["subs"][childIndex]["name"]
                                        });
                                      },
                                      child: ListTile(
                                        title: Text(
                                          categoryDataList[index]["subs"][childIndex]["name"],
                                          style: gothamRegular.copyWith(
                                            fontSize: Dimensions.FONT_M,
                                            color: Color(AllColors.colorText),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1, color: Colors.black54,),
                                ],
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  void getCategory() {
    // https://devapi.paciolo.it/payment-category
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      "type": "C",
    });

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.getPaymentCategory,
        token: userModel!.authorization,
        body: body,
        responseCode: GET_CATEGORY_DATA,
        companyId: currentCompanyId,
    );
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
    if (responseCode == GET_CATEGORY_DATA) {
      debugPrint("$TAG GET MODE LIST ========> ${response[Constant.data]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data].length; i++) {
          categoryDataList.add(response[Constant.data][i]);
        }
      });
    }
  }
}
