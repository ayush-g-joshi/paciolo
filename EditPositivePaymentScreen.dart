
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/childscreens/SelectModeTypeScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/PutRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../childscreens/SelectAssociateDocumentScreen.dart';
import '../childscreens/SelectAssosiateSubjectScreen.dart';
import '../childscreens/SelectWalletTypeScreen.dart';
import '../network/MultipartRequest.dart';
import '../util/CommonCSS.dart';

class EditPositivePaymentScreen extends StatefulWidget {

  bool isPositive;
  var id;
  EditPositivePaymentScreen({Key? key, required this.isPositive, this.id}) : super(key: key);

  @override
  State<EditPositivePaymentScreen> createState() => _EditPositivePaymentScreenState();
}

class _EditPositivePaymentScreenState extends State<EditPositivePaymentScreen> implements ResponseListener {

  String TAG = "_EditPositivePaymentScreenState";

  bool showLoader = false;
  DateTime currentDate = DateTime.now();
  var currentCompanyId;
  LoginUserModel? userModel;

  String? selectedWalletValue;
  int? selectedWalletId;
  String? selectedModeValue;
  int? selectedModeId;
  int? selectedCustomerId;
  String? selectedCustomerValue;
  int? selectedDocumentId;

  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  TextEditingController modeController = TextEditingController();
  TextEditingController walletController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController documentController = TextEditingController();

  var paymentData;

  List subjectList = List.from([]);
  List walletList = List.from([]);
  List paymentModeList = List.from([]);
  List documentList = List.from([]);

  var GET_PAYMENT_DATA = 2340;
  var GET_SUBJECT = 9000;
  var GET_WALLET_DATA = 9001;
  var GET_DOCUMENT = 9002;
  var GET_PAYMENT_MODE = 9003;
  var SAVE_PAYMENT_DATA = 9010;

  bool buttonEnable = false;
  var filterWalletResult;
  var filterSubjectResult;
  var filterDocumentResult;

  bool showDocument = false;
  bool walletEnable = true;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getPositivePayment();
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
            icon: Icon(Platform.isAndroid ? Icons.close : Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: widget.isPositive == true ?
          Text(
            Constant.LANG == Constant.EN ? ENG.EDIT_PAYMENT_REGISTRY_POSITIVE_PAYMENT : IT.EDIT_PAYMENT_REGISTRY_POSITIVE_PAYMENT,
            style: gothamRegular.copyWith(
              fontSize: Dimensions.FONT_L,
              color: Colors.white,
            ),
          ) :
          Text(
            Constant.LANG == Constant.EN ? ENG.EDIT_PAYMENT_REGISTRY_NEGATIVE_PAYMENT : IT.EDIT_PAYMENT_REGISTRY_NEGATIVE_PAYMENT,
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
                        // amount Field
                        Text(
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_HEADING_1 : IT.PAYMENT_REGISTRY_P_HEADING_1,
                          style: gothamMedium.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_XS),
                        amountField(context),
                        const SizedBox(height: Dimensions.PADDING_L),
                        // amount Field
                        // date Field
                        Text(
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_HEADING_2 : IT.PAYMENT_REGISTRY_P_HEADING_2,
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
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_HEADING_3 : IT.PAYMENT_REGISTRY_P_HEADING_3,
                          style: gothamMedium.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_XS),
                        paymentModeField(context),
                        const SizedBox(height: Dimensions.PADDING_L),
                        // payment Mode Field
                        // wallet Field
                        Text(
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_HEADING_4 : IT.PAYMENT_REGISTRY_P_HEADING_4,
                          style: gothamMedium.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_XS),
                        walletField(context),
                        const SizedBox(height: Dimensions.PADDING_L),
                        // wallet Field
                        // subject Field
                        Text(
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_HEADING_5 : IT.PAYMENT_REGISTRY_P_HEADING_5,
                          style: gothamMedium.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          ),
                        ),
                        const SizedBox(height: Dimensions.PADDING_XS),
                        subjectField(context),
                        const SizedBox(height: Dimensions.PADDING_L),
                        // subject Field
                        // document Field
                        Visibility(
                          visible: showDocument,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_HEADING_6 : IT.PAYMENT_REGISTRY_P_HEADING_6,
                                style: gothamMedium.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                ),
                              ),
                              const SizedBox(height: Dimensions.PADDING_XS),
                              documentField(context),
                              const SizedBox(height: Dimensions.PADDING_L),
                            ],
                          ),
                        ),
                        // document Field
                        // note Field
                        Text(
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_HEADING_7 : IT.PAYMENT_REGISTRY_P_HEADING_7,
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
                            if(!buttonEnable) {
                              Utility.showToast(Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_AMOUNT_ERROR : IT.PAYMENT_REGISTRY_P_AMOUNT_ERROR);
                            } else {
                              savePaymentTransaction();
                            }
                          },
                          child: Container(
                            height: 50.h,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: Dimensions.PADDING_M),
                            decoration: CommonCSS.buttonDecoration(buttonEnable, 5.r, AllColors.colorGreen, 0.5, 0),
                            child: Center(
                                child: Text(
                                  Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_BUTTON_SAVE : IT.PAYMENT_REGISTRY_P_BUTTON_SAVE,
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
        )
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
        hintText: Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_HEADING_1_HINT : IT.PAYMENT_REGISTRY_P_HEADING_1_HINT,
        fillColor: Colors.white,
      ),
    );
  }

  Widget dateField(BuildContext context) {
    return TextFormField(
      controller: dateController,
      style: gothamMedium.copyWith(
          color: Colors.grey,
          fontSize: Dimensions.FONT_XL.sp,
          fontWeight: FontWeight.w600
      ),
      cursorColor: Colors.black,
      cursorWidth: 1.5.w,
      onTap: () async {
        _selectDate(context);
      },
      readOnly: true,
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
          child: const Icon(
            Icons.calendar_month,
            color: Colors.blue,
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
        var filterWalletResult = await Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return SelectModeTypeScreen(selectedModeId: selectedModeId,);
          },
        ));

        debugPrint("$TAG filterWalletResult ======> $filterWalletResult");

        setState(() {
          if(filterWalletResult != null) {
            modeController.text = filterWalletResult["modeName"];
            selectedModeValue = filterWalletResult["modeName"];
            selectedModeId = filterWalletResult["modeId"];

            debugPrint("$TAG selectedModeValue ======> $selectedModeValue");
            debugPrint("$TAG selectedModeValue ======> $selectedModeValue");
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

  Widget walletField(BuildContext context) {
    return TextFormField(
      controller: walletController,
      keyboardType: TextInputType.name,
      style: gothamMedium.copyWith(
        color: walletEnable ? Colors.black : const Color(AllColors.colorGrey),
        fontSize: Dimensions.FONT_XL.sp,
      ),
      enabled: walletEnable,
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
        suffixIcon: walletEnable ? const Icon(Icons.arrow_forward_ios): null,
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
        disabledBorder: OutlineInputBorder(
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
            return const SelectAssociateSubjectScreen();
          },
        ));

        setState(() {
          if(filterSubjectResult != null) {
            debugPrint("$TAG filterSubjectResult ======> $filterSubjectResult");
            subjectController.text = filterSubjectResult["subjectData"]["name"];
            selectedCustomerId = filterSubjectResult["subjectData"]['id'];
            showDocument = true;
          }
        });
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: selectedCustomerId != null ? IconButton(
          onPressed: () {
            setState(() {
              filterSubjectResult = null;
              subjectController.clear();
              selectedCustomerId = null;
              showDocument = false;

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
        if(selectedCustomerId == null) {
          Utility.showToast(Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_P_SUBJECT_ERROR : IT.PAYMENT_REGISTRY_P_SUBJECT_ERROR,);
        } else {
          filterDocumentResult =
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SelectAssociateDocumentScreen(
                  customerId: selectedCustomerId,
                  isPositive: widget.isPositive);
            },
          ));

          setState(() {
            if (filterDocumentResult != null) {
              debugPrint("$TAG filter Document Result ======> $filterDocumentResult");
              documentController.text = filterDocumentResult["documentData"]["name"];
              selectedDocumentId = filterDocumentResult["documentData"]['id'];
            }
          });
        }
      },
      readOnly: true,
      decoration: InputDecoration(
        suffixIcon: selectedDocumentId != null ? IconButton(
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
            color: const Color(AllColors.colorGrey).withOpacity(0.7),
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
              color: const Color(AllColors.colorGrey).withOpacity(0.7),
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
        }

        for(int i = 0; i < response[Constant.data]["paymentMode"].length; i++) {
          paymentModeList.add(response[Constant.data]["paymentMode"][i]);
        }

        if(paymentData["amount"] != null) {
          amountController.text = paymentData["amount"].toString();
          buttonEnable = true;
        }
        if(paymentData["payment_date"] != null) {
          String formattedDate = Utility.formatDate(paymentData["payment_date"].toString());
          dateController.text = formattedDate;
          DateTime date = Utility.getDateTimeFromStringDate(formattedDate);
          currentDate = date;
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
        debugPrint("$TAG wallet_id =====> ${paymentData["wallet_id"]}");
        if(paymentData["wallet_id"] != null && paymentData["wallet_id"] != "") {
          debugPrint("$TAG if =====> wallet id found");
          for (int i = 0; i < walletList.length; i++) {
            debugPrint("$TAG for loop =====> ${walletList[i]["id"]}");
            if (paymentData["wallet_id"] == walletList[i]["id"]) {
              debugPrint("$TAG wallet_id =====> ${paymentData["wallet_id"]}");
              debugPrint("$TAG walletList =====> ${walletList[i]["id"]}");
              selectedWalletValue = walletList[i]["name"].toString();
              selectedWalletId = walletList[i]["id"];
              break;
            }
          }
        }

        if(selectedWalletValue != null && selectedWalletValue != "") {
          walletController.text = selectedWalletValue.toString();
        } else {
          walletController.text = "";
        }

        if(paymentData["customer_id"] != null && paymentData["customer_id"] != "") {
          getAssociateSubject();
          showDocument = true;
        }

        if(paymentData["document_name"] != null && paymentData["document_name"] != "") {
          documentController.text = paymentData["document_name"];
          selectedDocumentId = paymentData["document_id"];
        }

        if(paymentData["description"] != null && paymentData["description"] != "") {
          noteController.text = paymentData["description"].toString();
        }

        if(paymentData["wallet_id"] != null && paymentData["wallet_id"] !="") {
          getWalletData();
        }

      });

    } else if(responseCode == GET_SUBJECT) {
      setState(() {
        showLoader = false;
        subjectList.clear();
        debugPrint("$TAG GET_SUBJECT ========> ${response[Constant.data]}");
        var data = response[Constant.data]["record"][Constant.data];

        for (int i = 0; i < data.length; i++) {
          subjectList.add(data[i]);
          if(paymentData["customer_id"] == data[i]["id"]) {
            selectedCustomerId = data[i]["id"];
            selectedCustomerValue = data[i]["name"];
            break;
          }
        }
        if(selectedCustomerValue != null && selectedCustomerValue != "") {
          subjectController.text = selectedCustomerValue.toString();
        }
        getAssociateDocument();

      });
    } else if(responseCode == GET_DOCUMENT) {
      setState(() {
        showLoader = false;
        documentList.clear();
        for(int i = 0; i < response[Constant.data].length; i++) {
          documentList.add(response[Constant.data][i]);
        }
        debugPrint("$TAG GET_DOCUMENT ========> ${response[Constant.data]}");
      });
    } else if(responseCode == GET_WALLET_DATA) {

      setState(() {
        showLoader = false;
        debugPrint("$TAG GET_WALLET_DATA ========> ${response[Constant.data]}");
        selectedWalletValue = response[Constant.data]["payment_name"];
        if(selectedWalletValue != null && selectedWalletValue != "") {
          walletController.text = selectedWalletValue.toString();
        } else {
          walletController.text = "";
        }

        if(response[Constant.data]["wallet_type"] == 6) {
          walletEnable = false;
        } else {
          walletEnable = true;
        }

      });

    } else if(responseCode == SAVE_PAYMENT_DATA) {
      setState(() {
        debugPrint("$TAG SAVE_PAYMENT_DATA ========> ${response.toString()}");
        showLoader = false;
        Utility.showToast(response[Constant.msg]);
      });

      Navigator.pop(context, true);
    }
  }

  void getPositivePayment() {
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

  void getWalletData() {
    // https://devapi.paciolo.it/wallet/3503

    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getWalletById}/${paymentData["wallet_id"]}",
        token: userModel!.authorization,
        responseCode: GET_WALLET_DATA,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getAssociateSubject() {
    // https://devapi.paciolo.it/customer/?page=undefined&per_page=undefined&customer_type=undefined&term=undefined&tags=&gtags=&comTags=
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getAssociateSubject}?page=undefined&per_page=undefined&customer_type=undefined&term=undefined&tags=&gtags=&comTags=",
        token: userModel!.authorization,
        responseCode: GET_SUBJECT,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getAssociateDocument() {
    // https://devapi.paciolo.it/document/search_by_customer/43937/1
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getDocumentByCustomer}/${paymentData["customer_id"]}/${widget.isPositive == true ? 1 : -1}",
        token: userModel!.authorization,
        responseCode: GET_DOCUMENT,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void savePaymentTransaction() {
    // https://devapi.paciolo.it/account/transaction-mobile
    setState(() {
      showLoader = true;
    });
    var body = jsonEncode({
      "amount": double.parse(amountController.text.trim().toString()),
      "wallet_id": selectedWalletId,
      "customer_id": selectedCustomerId,
      "document_id": selectedDocumentId,
      "description": noteController.text.trim().toString(),
      "payment_mode_id": selectedModeId,
      "transaction_type": widget.isPositive == true ? 1 : -1,
      "mentionTags": noteController.text.trim().toString(),
      "user_tags": "[]",
      "payment_date": Utility.getFormattedDateFromDateTime(currentDate),
    });

    PutRequest request = PutRequest();
    request.getResponse(
      cmd: "${RequestCmd.saveRegistryPayment}/${widget.id}",
      token: userModel!.authorization,
      body: body,
      responseCode: SAVE_PAYMENT_DATA,
      companyId: currentCompanyId,
    );
    request.setListener(this);
  }
}
