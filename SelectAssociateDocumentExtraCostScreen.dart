import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/util/images.dart';

import '../auth/login_screen.dart';
import '../model/LoginUserModel.dart';
import '../network/PostRequest.dart';
import '../network/ResponseListener.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';

class SelectAssociateDocumentExtraCostScreen extends StatefulWidget {

  var categoryId;

  SelectAssociateDocumentExtraCostScreen({Key? key,this.categoryId}) : super(key: key);

  @override
  State<SelectAssociateDocumentExtraCostScreen> createState() => _SelectAssociateDocumentExtraCostScreenState();
}

class _SelectAssociateDocumentExtraCostScreenState extends State<SelectAssociateDocumentExtraCostScreen>
implements ResponseListener {

  String TAG = "_SelectAssociateDocumentExtraCostScreenState";
  bool showLoader = false;
  DateTime currentDate = DateTime.now();
  var currentCompanyId;
  LoginUserModel? userModel;

  TextEditingController controller = TextEditingController();

  List costList = List.from([]);

  int status = 1;

  var GET_DOCUMENT = 9001;

  @override
  void initState() {

    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
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
                child: costList.isEmpty
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
                    itemCount: costList.length,
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(height: 1, color: Colors.black54,);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, {"walletId": costList[index]["id"], "walletName": costList[index]["name"]});
                        },
                        child: ListTile(
                          title: Text(
                            costList[index]["name"],
                            style: gothamRegular.copyWith(
                              fontSize: Dimensions.FONT_M,
                              color: Color(AllColors.colorText),
                            ),
                          ),
                        ),
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
    // https://devapi.paciolo.it/payment-category/cost

    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      "category_id": widget.categoryId,
    });

    PostRequest request = PostRequest();
    request.getResponse(
      cmd: RequestCmd.getPaymentCategoryCost,
      token: userModel!.authorization,
      body: body,
      responseCode: GET_DOCUMENT,
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
    if (responseCode == GET_DOCUMENT) {
      debugPrint("$TAG GET MODE LIST ========> ${response[Constant.data]["cost"]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data]["cost"].length; i++) {
          costList.add(response[Constant.data]["cost"][i]);
        }
      });
    }
  }
}
