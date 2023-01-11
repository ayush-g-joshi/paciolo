import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/childscreens/SelectAssociateSubjectExtraCostScreen.dart';
import 'package:paciolo/childscreens/SelectModeTypeScreen.dart';
import 'package:paciolo/childscreens/SelectWalletTypeScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../auth/login_screen.dart';
import '../childscreens/SelectAssociateDocumentExtraCostScreen.dart';
import '../network/GetRequest.dart';
import '../network/ResponseListener.dart';
import '../util/CommonCSS.dart';
import '../util/Constants.dart';

class PositivePaymentExtraCostScreen extends StatefulWidget {

  bool isPositive;
  PositivePaymentExtraCostScreen({Key? key, required this.isPositive}) : super(key: key);

  @override
  State<PositivePaymentExtraCostScreen> createState() => _PositivePaymentExtraCostScreenState();
}

class _PositivePaymentExtraCostScreenState extends State<PositivePaymentExtraCostScreen> implements ResponseListener {

  String TAG = "_PositivePaymentExtraCostScreenState";
  bool showLoader = false;
  bool buttonEnable = false;
  DateTime currentDate = DateTime.now();
  var currentCompanyId;
  LoginUserModel? userModel;

  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController modeController = TextEditingController();
  TextEditingController walletController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  var filterModeResult;
  int? selectedModeId;
  String? selectedModeValue;

  var filterWalletResult;
  int? selectedWalletId;
  String? selectedWalletValue;

  var filterSubjectResult;
  int? selectedSubjectId;
  String? selectedSubjectValue;

  var filterDocumentResult;
  int? selectedDocumentId;
  String? selectedDocumentValue;

  List walletList = List.from([]);
  List paymentModeList = List.from([]);
  List categoryDataList = List.from([]);

  var GET_PAYMENT_MODE = 4000;
  var GET_CATEGORY_DATA = 4001;
  var SAVE_PAYMENT_DATA = 4003;

  bool showDocument = false;

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
        backgroundColor: Color(AllColors.colorBlue),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(
              Platform.isAndroid ? Icons.close : Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: widget.isPositive == true ?
        Text(
          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_POSITIVE_EXTRA_COST : IT.PAYMENT_REGISTRY_POSITIVE_EXTRA_COST,
          style: gothamRegular.copyWith(
            fontSize: Dimensions.FONT_L,
            color: Colors.white,
          ),
        ) :
        Text(
          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_NEGATIVE_EXTRA_COST : IT.PAYMENT_REGISTRY_NEGATIVE_EXTRA_COST,
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
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            margin: const EdgeInsets.all(Dimensions.PADDING_S),
            child: Card(
              elevation: Dimensions.PADDING_XS,
              borderOnForeground: true,
              semanticContainer: true,
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(Dimensions.PADDING_S),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimensions.PADDING_L),
                      Center(
                        child: Text(
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_MAIN : IT.PAYMENT_REGISTRY_E_HEADING_MAIN,
                          style: gothamMedium.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_XL,
                          ),
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_L),
                      // amount Field
                      Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_1 : IT.PAYMENT_REGISTRY_E_HEADING_1,
                        style: gothamMedium.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_XS),
                      amountField(context),
                      SizedBox(height: Dimensions.PADDING_L),
                      // amount Field
                      // date Field
                      Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_2 : IT.PAYMENT_REGISTRY_E_HEADING_2,
                        style: gothamMedium.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_XS),
                      dateField(context),
                      SizedBox(height: Dimensions.PADDING_L),
                      // date Field
                      // payment Mode Field
                      Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_3 : IT.PAYMENT_REGISTRY_E_HEADING_3,
                        style: gothamMedium.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_XS),
                      paymentModeField(context),
                      SizedBox(height: Dimensions.PADDING_L),
                      // payment Mode Field
                      // wallet Field
                      Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_4 : IT.PAYMENT_REGISTRY_E_HEADING_4,
                        style: gothamMedium.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_XS),
                      walletField(context),
                      SizedBox(height: Dimensions.PADDING_L),
                      // wallet Field
                      // subject Field
                      Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_5 : IT.PAYMENT_REGISTRY_E_HEADING_5,
                        style: gothamMedium.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_XS),
                      subjectField(context),
                      SizedBox(height: Dimensions.PADDING_L),
                      // subject Field
                      // document Field
                      Visibility(
                        visible: showDocument,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_6 : IT.PAYMENT_REGISTRY_E_HEADING_6,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            SizedBox(height: Dimensions.PADDING_XS),
                            documentField(context),
                            SizedBox(height: Dimensions.PADDING_L),
                          ],
                        ),
                      ),
                      // document Field
                      // note Field
                      Text(
                        Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_7 : IT.PAYMENT_REGISTRY_E_HEADING_7,
                        style: gothamMedium.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                      ),
                      SizedBox(height: Dimensions.PADDING_XS),
                      noteField(context),
                      SizedBox(height: Dimensions.PADDING_L),
                      // note Field
                      InkWell(
                        onTap: () {
                          if(buttonEnable) {
                            savePaymentTransaction();
                          }
                        },
                        child: Container(
                          height: 50.h,
                          width: double.infinity,
                          decoration: CommonCSS.buttonDecoration(buttonEnable, 5.r, AllColors.colorGreen, 0.5, 0),
                          child: Center(
                              child: Text(
                                Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_BUTTON_SAVE : IT.PAYMENT_REGISTRY_E_BUTTON_SAVE,
                                style: gothamBold.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.FONT_L
                                ),
                              )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget amountField(BuildContext context) {
    return TextFormField(
      controller: amountController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {
        setState(() {
          if(amountController.text.toString().trim().isNotEmpty &&
          subjectController.text.toString().trim().isNotEmpty) {
            buttonEnable = true;
          } else {
            buttonEnable = false;
          }
        });
      },
      decoration: InputDecoration(
        suffixIcon: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: widget.isPositive == true ? Color(AllColors.colorGreen) : Color(AllColors.colorRed)
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(Dimensions.RADIUS_S.r),
                bottomRight: Radius.circular(Dimensions.RADIUS_S.r),
              )
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(
              Constant.euroSign,
              textAlign: TextAlign.center,
              style: gothamRegular.copyWith(
                  fontSize: Dimensions.FONT_XL,
                  color: Colors.black
              ),
            ),
          ),
        ),
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_HEADING_1_HINT : IT.PAYMENT_REGISTRY_E_HEADING_1_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget dateField(BuildContext context) {
    return TextFormField(
      onTap: () async {
        _selectDate(context);
      },
      readOnly: true,
      controller: dateController,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      decoration: InputDecoration(
        suffixIcon: Container(
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              border: Border.all(
                  color: Colors.grey
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(Dimensions.RADIUS_S.r),
                bottomRight: Radius.circular(Dimensions.RADIUS_S.r),
              )
          ),
          child: Icon(Icons.calendar_month,
            color: Colors.blue,),
        ),
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        hintText: Utility.getFormattedDateFromDateTime(currentDate),
        fillColor: Colors.white,
      ),
    );
  }

  Widget paymentModeField(BuildContext context) {
    return TextFormField(
      controller: modeController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onTap: () async {
        filterModeResult = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SelectModeTypeScreen(selectedModeId: selectedModeId,);
          },
        ));

        debugPrint("$TAG filterWalletResult ======> $filterModeResult");

        setState(() {
          if(filterModeResult != null) {
            modeController.text = filterModeResult["modeName"];
            selectedModeValue = filterModeResult["modeName"];
            selectedModeId = filterModeResult["modeId"];

            debugPrint("$TAG selectedModeValue ======> $selectedModeValue");
            debugPrint("$TAG selectedModeValue ======> $selectedModeValue");
          }
        });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.arrow_forward_ios),
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        fillColor: Colors.white,
      ),
    );
  }

  Widget walletField(BuildContext context) {
    return TextFormField(
      controller: walletController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onTap: () async {
        filterWalletResult = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SelectWalletTypeScreen(selectedWallet: selectedWalletId,);
          },
        ));

        debugPrint("$TAG filterWalletResult ======> $filterWalletResult");

        setState(() {
          if(filterWalletResult != null) {
            walletController.text = filterWalletResult["name"];
            selectedWalletValue = filterWalletResult["name"];
            selectedWalletId = filterWalletResult["id"];
            debugPrint("$TAG selectedWalletId ======> $selectedWalletId");
            debugPrint("$TAG selectedWalletValue ======> $selectedWalletValue");
          }
        });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.arrow_forward_ios),
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        fillColor: Colors.white,
      ),
    );
  }

  Widget subjectField(BuildContext context) {
    return TextFormField(
      controller: subjectController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onTap: () async {
        filterSubjectResult = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SelectAssociateSubjectExtraCostScreen();
          },
        ));

        debugPrint("$TAG filterWalletResult ======> $filterSubjectResult");

        setState(() {
          if(filterSubjectResult != null) {
            if(filterSubjectResult["walletName"] != selectedSubjectValue) {
              documentController.clear();
              filterDocumentResult = null;
              selectedDocumentValue = null;
              selectedDocumentId = null;
            }
            subjectController.text = filterSubjectResult["walletName"];
            selectedSubjectValue = filterSubjectResult["walletName"];
            selectedSubjectId = filterSubjectResult["walletId"];

            showDocument = true;

            debugPrint("$TAG selectedWalletId ======> $selectedSubjectId");
            debugPrint("$TAG selectedWalletValue ======> $selectedSubjectValue");
            if(amountController.text.toString().trim().isNotEmpty &&
                subjectController.text.toString().trim().isNotEmpty) {
              buttonEnable = true;
            } else {
              buttonEnable = false;
            }
          }
        });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: const Icon(Icons.arrow_forward_ios),
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        fillColor: Colors.white,
      ),
    );
  }

  Widget documentField(BuildContext context) {
    return TextFormField(
      controller: documentController,
      keyboardType: TextInputType.number,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onTap: () async {
        if(selectedSubjectId == null) {
          Utility.showToast(Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_SUBJECT_ERROR : IT.PAYMENT_REGISTRY_P_SUBJECT_ERROR,);
        } else {
          filterDocumentResult =
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SelectAssociateDocumentExtraCostScreen(
                categoryId: selectedSubjectId,);
            },
          ));

          debugPrint("$TAG filterWalletResult ======> $filterDocumentResult");

          setState(() {
            if (filterDocumentResult != null) {
              documentController.text = filterDocumentResult["walletName"];
              selectedDocumentValue = filterDocumentResult["walletName"];
              selectedDocumentId = filterDocumentResult["walletId"];

              if(amountController.text.toString().trim().isNotEmpty &&
                  subjectController.text.toString().trim().isNotEmpty) {
                buttonEnable = true;
              } else {
                buttonEnable = false;
              }
            }
          });
        }
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: filterDocumentResult != null ? IconButton(
          onPressed: () {
            setState(() {
              filterDocumentResult = null;
              documentController.clear();
              selectedDocumentId = null;
            });
          }, icon: const Icon(Icons.cancel, color: Colors.blue,),
        ) : const Icon(Icons.arrow_forward_ios),
        contentPadding: REdgeInsets.fromLTRB(10, 0, 0, 0),
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
            color: Color(AllColors.colorGrey).withOpacity(0.7),
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget noteField(BuildContext context) {
    return TextField(
      controller: noteController,
      keyboardType: TextInputType.multiline,
      style: gothamRegular.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      maxLines: 5,
      textAlign: TextAlign.start,
      decoration:  InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 0.7.w,
              color: Color(AllColors.colorGrey).withOpacity(0.7),
            ),
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
          ),
          contentPadding: REdgeInsets.all(Dimensions.PADDING_S),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.0.w,
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_S.r),
          ),
          hintText: "",
          hintStyle: gothamMedium.copyWith(
              color: Colors.grey,
              fontSize: Dimensions.FONT_XL.sp,
              fontWeight: FontWeight.w600
          ),
          border: InputBorder.none
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      lastDate: DateTime(2100),
      firstDate: DateTime(2000),
    );
    if (picked != null) {
      setState(() {
        debugPrint("$TAG picked date =======> ${picked.toString()}");
        currentDate = picked;
        debugPrint("$TAG new current date =======> ${currentDate.toString()}");
      });
    }
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
        responseCode: GET_PAYMENT_MODE,
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
      } else if(statusCode != null && statusCode == 500) {
        Utility.showErrorToast(response[Constant.msg]);
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
    if (responseCode == GET_PAYMENT_MODE) {

      debugPrint("$TAG GET MODE LIST ========> ${response[Constant.data]["paymentMode"]}");
      debugPrint("$TAG GET WALLET LIST ========> ${response[Constant.data]["wallet"]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data]["wallet"].length; i++) {
          walletList.add(response[Constant.data]["wallet"][i]);
        }

        for(int i = 0; i < response[Constant.data]["paymentMode"].length; i++) {
          paymentModeList.add(response[Constant.data]["paymentMode"][i]);
        }

        selectedWalletValue = walletList[0]["name"].toString();
        selectedWalletId = walletList[0]["id"];

        selectedModeValue = paymentModeList[0]["name"].toString();
        selectedModeId = paymentModeList[0]["id"];

        modeController.text = selectedModeValue.toString();
        walletController.text = selectedWalletValue.toString();

      });
    } else if(responseCode == SAVE_PAYMENT_DATA) {
      setState(() {
        debugPrint("$TAG GET subject LIST ========> ${response.toString()}");
        showLoader = false;
        Utility.showToast(response[Constant.msg]);
      });

      Navigator.pop(context);
    }
  }

  void savePaymentTransaction() {
    // https://devapi.paciolo.it/payment-category/save-payment-mobile
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      "amount": double.parse(amountController.text.trim().toString()),
      "wallet_id": selectedWalletId,
      "customer_id": selectedSubjectId,
      "document_id": selectedDocumentId,
      "description": noteController.text.trim().toString(),
      "payment_mode_id": selectedModeId,
      "transaction_type": widget.isPositive == true ? 1 : -1,
      "mentionTags": noteController.text.trim().toString(),
      "payment_date": Utility.getFormattedDateFromDateTime(currentDate),
    });

    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.savePaymentCategoryCost,
        token: userModel!.authorization,
        body: body,
        responseCode: SAVE_PAYMENT_DATA,
        companyId: currentCompanyId,
    );
    request.setListener(this);
  }

}