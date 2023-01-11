
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/childscreens/SelectModeTypeScreen.dart';
import 'package:paciolo/childscreens/SelectWalletTypeScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/PutRequest.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../auth/login_screen.dart';
import '../network/GetRequest.dart';
import '../network/PostRequest.dart';
import '../network/ResponseListener.dart';
import '../util/CommonCSS.dart';
import '../util/Utility.dart';

class EditTransferScreen extends StatefulWidget {
  var id;
  EditTransferScreen({Key? key, this.id}) : super(key: key);

  @override
  State<EditTransferScreen> createState() => _EditTransferScreenState();
}

class _EditTransferScreenState extends State<EditTransferScreen> implements ResponseListener {

  String TAG = "_EditTransferScreenState";

  bool showLoader = false;
  bool buttonEnable = false;
  DateTime currentDate = DateTime.now();
  DateTime currentDate2 = DateTime.now();
  var currentCompanyId;
  LoginUserModel? userModel;

  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController date2Controller = TextEditingController();
  TextEditingController modeController = TextEditingController();
  TextEditingController walletController = TextEditingController();
  TextEditingController wallet2Controller = TextEditingController();
  TextEditingController noteController = TextEditingController();

  var paymentData;

  var filterWalletResult;
  int? selectedWalletId;
  String? selectedWalletValue;

  var filterWalletResult2;
  int? selectedWalletId2;
  String? selectedWalletValue2;

  var filterModeResult;
  int? selectedModeId;
  String? selectedModeValue;

  List walletList = List.from([]);
  List walletList2 = List.from([]);
  List paymentModeList = List.from([]);

  var GET_PAYMENT_DATA = 3450;
  var GET_PAYMENT_MODE = 4000;
  var SAVE_PAYMENT_DATA = 5000;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getPaymentData();
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
                Platform.isAndroid ? Icons.close : Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            Constant.LANG == Constant.EN ? ENG.EDIT_PAYMENT_CREATE_A_TRANSFER : IT.EDIT_PAYMENT_CREATE_A_TRANSFER,
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
                            const SizedBox(height: Dimensions.PADDING_L),
                            // withdrawal resource Field
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_HEADING_1 : IT.PAYMENT_REGISTRY_T_HEADING_1,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            walletField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // withdrawal resource Field
                            // date Field
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_HEADING_2 : IT.PAYMENT_REGISTRY_T_HEADING_2,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            dateField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // date Field
                            // payment Mode Field
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_HEADING_3 : IT.PAYMENT_REGISTRY_T_HEADING_3,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            walletField2(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // payment Mode Field
                            // date Field
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_HEADING_4 : IT.PAYMENT_REGISTRY_T_HEADING_4,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            dateField2(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // date Field
                            // amount Field
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_HEADING_5 : IT.PAYMENT_REGISTRY_T_HEADING_5,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            amountField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // amount Field
                            // payment Mode Field
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_HEADING_6 : IT.PAYMENT_REGISTRY_T_HEADING_6,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            paymentModeField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // payment Mode Field
                            // note Field
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_HEADING_7 : IT.PAYMENT_REGISTRY_T_HEADING_7,
                              style: gothamMedium.copyWith(
                                color: Colors.black,
                                fontSize: Dimensions.FONT_L,
                              ),
                            ),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            noteField(context),
                            const SizedBox(height: Dimensions.PADDING_L),
                            // note Field
                            InkWell(
                              onTap: () {
                                if(amountController.text.toString().trim().isEmpty) {
                                  Utility.showToast(Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_E_AMOUNT_ERROR : IT.PAYMENT_REGISTRY_E_AMOUNT_ERROR);
                                } else {
                                  savePaymentTransaction();
                                }
                              },
                              child: Container(
                                height: 50.h,
                                width: double.infinity,
                                decoration: CommonCSS.buttonDecoration(buttonEnable, 5.r, AllColors.colorGreen, 0.5, 0),
                                child: Center(
                                    child: Text(
                                      Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_BUTTON_SAVE : IT.PAYMENT_REGISTRY_T_BUTTON_SAVE,
                                      style: gothamBold.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.FONT_L
                                      ),
                                    )
                                ),
                              ),
                            )
                          ]
                      )
                  ),
                ),
              ),
            ),
          ),
        )
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
            color: const Color(AllColors.colorGrey).withOpacity(0.7),
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

  Widget dateField(BuildContext context) {
    return TextFormField(
      onTap: () async {
        _selectDate(context);
      },
      readOnly: true,
      controller: dateController,
      style: gothamMedium.copyWith(
          color: Colors.grey,
          fontSize: Dimensions.FONT_XL.sp,
          fontWeight: FontWeight.w600
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
          child: const Icon(Icons.calendar_month, color: Colors.blue,),
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
            color: const Color(AllColors.colorGrey).withOpacity(0.7),
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

  Widget walletField2(BuildContext context) {
    return TextFormField(
      controller: wallet2Controller,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onTap: () async {
        filterWalletResult2 = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SelectWalletTypeScreen(selectedWallet: selectedWalletId2,);
          },
        ));

        debugPrint("$TAG filterWalletResult ======> $filterWalletResult2");

        setState(() {
          if(filterWalletResult2 != null) {
            wallet2Controller.text = filterWalletResult2["name"];
            selectedWalletValue2 = filterWalletResult2["name"];
            selectedWalletId2 = filterWalletResult2["id"];

            debugPrint("$TAG selectedWalletId ======> $selectedWalletId2");
            debugPrint("$TAG selectedWalletValue ======> $selectedWalletValue2");
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

  Widget dateField2(BuildContext context) {
    return TextFormField(
      onTap: () async {
        _selectDate2(context);
      },
      readOnly: true,
      controller: date2Controller,
      style: gothamMedium.copyWith(
          color: Colors.grey,
          fontSize: Dimensions.FONT_XL.sp,
          fontWeight: FontWeight.w600
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
        hintText: Utility.getFormattedDateFromDateTime(currentDate2),
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
        suffixIcon: filterModeResult != null ? IconButton(
          onPressed: () {
            setState(() {
              filterModeResult = null;
              modeController.clear();
              selectedModeId = null;
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
        hintStyle: gothamMedium.copyWith(
            color: Colors.grey,
            fontSize: Dimensions.FONT_XL.sp,
            fontWeight: FontWeight.w600
        ),
        fillColor: Colors.white,
      ),
    );
  }

  Widget amountField(BuildContext context) {
    return TextFormField(
      controller: amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      textAlign: TextAlign.start,
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onChanged: (value) {
        setState(() {
          if(amountController.text.trim().toString().isNotEmpty) {
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
                  color: Color(AllColors.colorGreen)
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
        hintText: Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_T_HEADING_1_HINT : IT.PAYMENT_REGISTRY_T_HEADING_1_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget noteField(BuildContext context) {
    return TextField(
      controller: noteController,
      keyboardType: TextInputType.multiline,
      style: gothamMedium.copyWith(
        color: Colors.black,
        fontSize: Dimensions.FONT_XL.sp,
      ),
      onChanged: (value) {
        setState(() {
          if(amountController.text.trim().toString().isNotEmpty) {
            buttonEnable = true;
          } else {
            buttonEnable = false;
          }
        });
      },
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
          hintStyle: gothamRegular.copyWith(
              letterSpacing: 0.8,
              fontSize: Dimensions.FONT_M,
              color: Colors.black
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

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate2,
      lastDate: DateTime(2100),
      firstDate: DateTime(2000),
    );
    if (picked != null) {
      setState(() {
        debugPrint("$TAG picked date =======> ${picked.toString()}");
        currentDate2 = picked;
        debugPrint("$TAG new current date =======> ${currentDate2.toString()}");
      });
    }
  }

  void getPaymentData() {
    // https://devapi.paciolo.it/account/transaction/31983
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getPositivePayment}/${widget.id}",
        token: userModel!.authorization,
        responseCode: GET_PAYMENT_DATA,
        companyId: currentCompanyId);
    request.setListener(this);
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
      } else {
        Utility.showToast(Constant.LANG == Constant.EN ? ENG.TRY_AFTER_SOMEIME : IT.TRY_AFTER_SOMEIME);
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
    if(responseCode == GET_PAYMENT_DATA) {
      setState(() {
        showLoader = false;
        debugPrint("$TAG GET_PAYMENT_DATA ======> ${response[Constant.data]}");
        paymentData = response[Constant.data];
        getPaymentMode();
      });
    } else if (responseCode == GET_PAYMENT_MODE) {

      debugPrint("$TAG GET MODE LIST ========> ${response[Constant.data]["paymentMode"]}");
      debugPrint("$TAG GET WALLET LIST ========> ${response[Constant.data]["wallet"]}");
      setState(() {
        showLoader = false;
        for(int i = 0; i < response[Constant.data]["wallet"].length; i++) {
          walletList.add(response[Constant.data]["wallet"][i]);
          walletList2.add(response[Constant.data]["wallet"][i]);
        }

        for(int i = 0; i < response[Constant.data]["paymentMode"].length; i++) {
          paymentModeList.add(response[Constant.data]["paymentMode"][i]);
        }

        if(paymentData["amount"] != null) {
          amountController.text = paymentData["amount"].toString();
          buttonEnable = true;
        }
        if(paymentData["payment_date_1"] != null) {
          String formattedDate = Utility.formatDate(paymentData["payment_date_1"].toString());
          dateController.text = formattedDate;
          DateTime date = Utility.getDateTimeFromStringDate(formattedDate);
          currentDate = date;
        }

        if(paymentData["payment_date_2"] != null) {
          String formattedDate = Utility.formatDate(paymentData["payment_date_2"].toString());
          date2Controller.text = formattedDate;
          DateTime date = Utility.getDateTimeFromStringDate(formattedDate);
          currentDate2 = date;
        }

        if(paymentData["description"] != null && paymentData["description"] != "") {
          noteController.text = paymentData["description"].toString();
        }

        if(paymentData["payment_mode_id"] != null && paymentData["payment_mode_id"] != "") {
          for(int i = 0; i < paymentModeList.length; i++) {
            if(paymentData["payment_mode_id"] == paymentModeList[i]["id"]) {
              debugPrint("$TAG payment_mode_id =====> ${paymentData["payment_mode_id"]}");
              debugPrint("$TAG paymentModeList =====> ${paymentModeList[i]["id"]}");
              selectedModeValue = paymentModeList[i]["name"].toString();
              selectedModeId = paymentModeList[i]["id"];
              break;
            }
          }
        } else {
          selectedModeValue = paymentModeList[0]["name"].toString();
          selectedModeId = paymentModeList[0]["id"];
        }
        modeController.text = selectedModeValue.toString();


        if(paymentData["wallet_id_1"] != null && paymentData["wallet_id_1"] != "") {
          for(int i = 0; i < walletList.length; i++) {
            if(paymentData["wallet_id_1"] == walletList[i]["id"]) {
              debugPrint("$TAG wallet_id_1 =====> ${paymentData["wallet_id_1"]}");
              debugPrint("$TAG walletList =====> ${walletList[i]["id"]}");
              selectedWalletValue = walletList[i]["name"].toString();
              selectedWalletId = walletList[i]["id"];
              break;
            }
          }
        } else {
          selectedWalletValue = walletList[0]["name"].toString();
          selectedWalletId = walletList[0]["id"];
        }
        walletController.text = selectedWalletValue.toString();

        if(paymentData["wallet_id_2"] != null && paymentData["wallet_id_2"] != "") {
          for(int i = 0; i < walletList2.length; i++) {
            if(paymentData["wallet_id_2"] == walletList2[i]["id"]) {
              debugPrint("$TAG wallet_id_2 =====> ${paymentData["wallet_id_2"]}");
              debugPrint("$TAG walletList =====> ${walletList2[i]["id"]}");
              selectedWalletValue2 = walletList2[i]["name"].toString();
              selectedWalletId2 = walletList2[i]["id"];
              break;
            }
          }
        } else {
          selectedWalletValue2 = walletList2[0]["name"].toString();
          selectedWalletId2 = walletList2[0]["id"];
        }
        wallet2Controller.text = selectedWalletValue2.toString();


      });
    } else if(responseCode == SAVE_PAYMENT_DATA) {
      setState(() {
        debugPrint("$TAG SAVE PAYMENT DATA ===========> $response");
        Utility.showToast(response[Constant.msg]);
      });

      Navigator.pop(context, true);
    }
  }

  void savePaymentTransaction() {
    // https://devapi.paciolo.it/account/transfer-mobile
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      'amount': double.parse(amountController.text.toString().trim()),
      'description': noteController.text.toString().trim(),
      'wallet_id_1': selectedWalletId,
      'wallet_id_2': selectedWalletId2,
      'payment_mode_id': selectedModeId,
      'payment_date_1': Utility.getFormattedDateFromDateTime(currentDate),
      'payment_date_2': Utility.getFormattedDateFromDateTime(currentDate2),
      'transaction_type': paymentData["transaction_type"],
      'transaction_id_1': paymentData["transaction_id_1"],
      'transaction_id_2': paymentData["transaction_id_2"],
    });

    PutRequest request = PutRequest();
    request.getResponse(
      cmd: "${RequestCmd.savePaymentTransfer}/${widget.id}",
      token: userModel!.authorization,
      body: body,
      responseCode: SAVE_PAYMENT_DATA,
      companyId: currentCompanyId,
    );
    request.setListener(this);

  }


}