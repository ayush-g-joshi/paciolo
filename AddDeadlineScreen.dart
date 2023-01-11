
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../model/PaymentModel.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';
import 'SelectPaymentModeScreen.dart';
import 'SelectWalletTypeScreen.dart';

class AddDeadlineScreen extends StatefulWidget {
  dynamic subTotal;
  AddDeadlineScreen({Key? key, this.subTotal}) : super(key: key);

  @override
  State<AddDeadlineScreen> createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {

  String TAG = "_AddDeadlineScreenState";
  bool showLoader = false;
  var accountResult;
  var modeResult;
  double total = 0.0;
  var currentDate =  DateTime.now();

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController accountController = TextEditingController();
  TextEditingController coordController = TextEditingController( );
  TextEditingController modeController = TextEditingController();
  TextEditingController refPgController = TextEditingController();
  TextEditingController paidController = TextEditingController();

  bool isPaid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:const Color(AllColors.colorBlue),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_ADD_PAYMENT : IT.PAYMENT_EDIT_NEW_ADD_PAYMENT,
          style: gothamMedium.copyWith(
              color: Colors.white,
              fontSize: Dimensions.FONT_L
          ),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
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
                    // description textFiled
                    Text(
                      Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_DATE : IT.PAYMENT_EDIT_NEW_DATE,
                      style: gothamRegular.copyWith(
                        color: const Color(AllColors.colorText),
                        fontSize: Dimensions.FONT_L,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    TextField(
                      controller: dateController,
                      onTap: () async {
                        _selectDate(context);
                      },
                      readOnly: true,
                      style: gothamRegular.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L.sp,
                      ),
                      cursorColor: Colors.black,
                      cursorWidth: 1.5.w,
                      decoration: InputDecoration(
                        suffixIcon: const Icon(Icons.calendar_month,
                          color: Color(AllColors.colorText),
                        ),
                        contentPadding: REdgeInsets.fromLTRB(20, 0, 0, 0),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0.7.w,
                            color: const Color(AllColors.colorGrey).withOpacity(0.7),
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
                        hintStyle: gothamRegular.copyWith(
                            color: Colors.grey,
                            fontSize: Dimensions.FONT_L.sp,
                            fontWeight: FontWeight.w600
                        ),
                        hintText: Utility.getFormattedDateFromDateTime(currentDate),
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // description textFiled
                    // amount and wallet textFiled
                    Row(
                      children: [
                        // amount textField
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_AMOUNT : IT.PAYMENT_EDIT_NEW_AMOUNT,
                                style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  fontSize: Dimensions.FONT_L.sp,
                                ),
                              ),
                              const SizedBox(height: Dimensions.PADDING_XS),
                              Theme(
                                data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                                child: TextField(
                                  controller: amountController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  autofocus: false,
                                  style: gothamMedium.copyWith(
                                    color: const Color(AllColors.colorText),
                                    fontSize: Dimensions.FONT_L.sp,
                                  ),
                                  onChanged: (value) {
                                  },
                                  decoration: InputDecoration(
                                    hintText:  Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_AMOUNT : IT.PAYMENT_EDIT_NEW_AMOUNT,
                                    filled: true,
                                    fillColor:const Color(0xFFF1F1F1),
                                    contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0, right: 14.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.white),
                                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: Dimensions.PADDING_XS),
                        // wallet textFiled
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_WALLET : IT.PAYMENT_EDIT_NEW_WALLET,
                                style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  fontSize: Dimensions.FONT_L.sp,
                                ),
                              ),
                              const SizedBox(height: Dimensions.PADDING_XS),
                              TextField(
                                controller: accountController,
                                readOnly: true,
                                style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  fontSize: Dimensions.FONT_L.sp,
                                ),
                                onTap: () async {
                                  accountResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return SelectWalletTypeScreen();
                                  },
                                  ));

                                  debugPrint("$TAG accountResult ======> $accountResult");
                                  setState(() {
                                    if (accountResult != null) {
                                      accountController.text = accountResult["name"];
                                      if(accountResult["wallet_coordinate"] != null) {
                                        coordController.text = accountResult["wallet_coordinate"];
                                      } else {
                                        coordController.text = "";
                                      }
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  suffixIcon: const Icon(Icons.arrow_forward_ios),
                                  hintText:  Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_WALLET: IT.PAYMENT_EDIT_NEW_WALLET,
                                  filled: true,
                                  fillColor: const Color(0xFFF1F1F1),
                                  contentPadding: const EdgeInsets.only(left: 14.0, bottom: 15.0, top: 15.0, right: 14.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // quantity and vat textFiled
                    // Coord textFiled
                    Text(
                      Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_COORD : IT.PAYMENT_EDIT_NEW_COORD,
                      style: gothamRegular.copyWith(
                          color:const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L.sp
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    Theme(
                      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                      child: TextField(
                        controller:  coordController,
                        keyboardType: TextInputType.text,
                        autofocus: false,
                        style: gothamRegular.copyWith(
                            color:const Color(AllColors.colorText),
                            fontSize: Dimensions.FONT_L.sp
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          hintText:  Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_COORD : IT.PAYMENT_EDIT_NEW_COORD,
                          hintStyle: gothamRegular.copyWith(
                              color:const Color(AllColors.colorText),
                              fontSize: Dimensions.FONT_L.sp
                          ),
                          fillColor:const Color(0xFFF1F1F1),
                          contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0, right: 14.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide:const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),
                    // Coord textFiled
                    //payment mode textFiled
                    Text(
                      Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_MODE : IT.PAYMENT_EDIT_NEW_MODE,
                      style: gothamRegular.copyWith(
                        color: const Color(AllColors.colorText),
                        fontSize: Dimensions.FONT_L.sp,
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    Theme(
                      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                      child: TextField(
                        controller: modeController,
                        readOnly: true,
                        style: gothamRegular.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L.sp,
                        ),
                        onTap: () async {
                          modeResult = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return SelectPaymentModeScreen();
                          },
                          ));

                          setState(() {
                            if (modeResult != null) {
                              debugPrint("$TAG Mode Result ======> $modeResult");
                              // {id: 3, name: Contanti, sdi_modality: MP01, is_open_banking: 0}
                              modeController.text = modeResult["name"];
                            }
                          });
                        },
                        decoration: InputDecoration(
                          suffixIcon: const Icon(Icons.arrow_forward_ios),
                          hintText:  Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_MODE : IT.PAYMENT_EDIT_NEW_MODE,
                          filled: true,
                          fillColor: const Color(0xFFF1F1F1),
                          contentPadding: const EdgeInsets.only(left: 14.0, bottom: 15.0, top: 15.0, right: 15.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),
                    //payment mode textFiled
                    //Ref. Pg. textFiled
                    Text(
                      Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_REFPG : IT.PAYMENT_EDIT_NEW_REFPG,
                      style: gothamRegular.copyWith(
                          color: const Color(AllColors.colorText),
                          fontSize: Dimensions.FONT_L.sp
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_XS),
                    Theme(
                      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
                      child: SizedBox(
                        child: TextField(
                          controller: refPgController,
                          autofocus: false,
                          style: gothamRegular.copyWith(
                            color: const Color(AllColors.colorText),
                            fontSize: Dimensions.FONT_L.sp,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            hintText:  Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_REFPG : IT.PAYMENT_EDIT_NEW_REFPG,
                            hintStyle: gothamRegular.copyWith(
                              color: const Color(AllColors.colorText),
                              fontSize: Dimensions.FONT_L.sp,
                            ),
                            fillColor: const Color(0xFFF1F1F1),
                            contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0, right: 10.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_L.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),
                    //Ref. Pg. textFiled
                    //Paid checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                isPaid = !isPaid;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 23.h,
                              width: 23.w,
                              decoration: BoxDecoration(
                                  color: isPaid ? const Color(AllColors.colorBlue) : Colors.white,
                                  borderRadius: BorderRadius.circular(3.r),
                                  border: Border.all(
                                      width: 1.5.w,
                                      color: const Color(AllColors.colorBlue)
                                  )
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        const SizedBox(width: Dimensions.PADDING_XS),
                        Text(
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_PAID : IT.PAYMENT_EDIT_NEW_PAID,
                          style: gothamRegular.copyWith(
                              color: const Color(AllColors.colorText),
                              fontSize: Dimensions.FONT_L.sp
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.PADDING_L),
                    //Paid checkbox
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AllColors.colorBlue), //button's fill color
                          elevation: 4.0, //buttons Material shadow
                          textStyle: gothamRegular.copyWith(color: Colors.white), //specify the button's text TextStyle
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 8.0, left: 8.0), //specify the button's Padding
                          minimumSize: const Size(190, 40), //specify the button's first: width and second: height
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // set the buttons shape. Make its birders rounded etc
                          enabledMouseCursor: MouseCursor.defer, //used to construct ButtonStyle.mouseCursor
                          disabledMouseCursor: MouseCursor.uncontrolled, //used to construct ButtonStyle.mouseCursor
                          visualDensity: const VisualDensity(horizontal: 0.0, vertical: 0.0), //set the button's visual density
                          tapTargetSize: MaterialTapTargetSize.padded, // set the MaterialTapTarget size. can set to: values, padded and shrinkWrap properties
                          animationDuration: const Duration(milliseconds: 100), //the buttons animations duration
                          enableFeedback: true, //to set the feedback to true or false
                          alignment: Alignment.center, //set the button's child Alignment
                        ),
                        onPressed: () async {
                          PaymentModel paymentResult = PaymentModel(
                            id: 0,
                            days: 0,
                            endMonth: 0,
                            paymentId: 0,
                            percentage:  (double.parse(amountController.text)/ widget.subTotal*100).toStringAsFixed(2),
                            date: Utility.getFormattedDateFromDateTime(currentDate),
                            walletId: accountResult["id"],
                            walletType: accountResult["name"].toString(),
                            coOrd: coordController.text.toString(),
                            modeId: modeResult["id"],
                            mode: modeResult["name"].toString(),
                            refPG: refPgController.text.toString(),
                            amount: amountController.text.toString(),
                            isPaid: isPaid,
                          );
                          Navigator.pop(context, paymentResult);
                        },
                        child:  Text(
                          Constant.LANG == Constant.EN ? ENG.PAYMENT_EDIT_NEW_ADD_PAYMENT : IT.PAYMENT_EDIT_NEW_ADD_PAYMENT,
                          textAlign: TextAlign.center,
                          style: gothamRegular.copyWith(
                            fontSize: Dimensions.PADDING_M,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

}