
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import 'EditInvoiceScreen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  var id;
  var title;
  var documentType;

  InvoiceDetailScreen({Key? key, this.id, this.title, this.documentType});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> implements ResponseListener {
  var TAG = "_InvoiceDetailScreenState";
  LoginUserModel? userModel;
  var currentCompanyId;
  bool showLoader = false;
  var INVOICE_INFO_DATA = 3000;
  var documentObject;
  var withHoldingTaxObject;
  var docTotalData;
  var documentPaymentArray = [];
  var documentProductArray = [];
  String expiryDate = "";
  String expiryDateMsg = "";
  var amountDataArray = [];

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getInvoiceDetail();
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
        leading: IconButton(
          icon: Icon(
              Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: widget.title == null
            ? Text(
                "Document",
                style: gothamRegular.copyWith(
                  fontSize: Dimensions.FONT_L,
                  color: Colors.white,
                ),
              )
            : Text(
                "${widget.title}",
                style: gothamRegular.copyWith(
                  fontSize: Dimensions.FONT_L,
                  color: Colors.white,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return EditInvoiceScreen(documentObject:documentObject);
                },
              ));
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_horiz_outlined,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: documentObject == null ? Container() : Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 70.h,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: const Color(AllColors.colorGrey),
                                width: 0.4.w),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: documentObject["document_create_date"] != null ? Text(
                                  Utility.formatInvoiceDocInfoDate(documentObject["document_create_date"]).toString(),
                                  style: gothamRegular.copyWith(
                                    fontSize: Dimensions.FONT_M,
                                    color: const Color(AllColors.colorText),
                                  ),
                                ): Text(
                                  "",
                                  style: gothamRegular.copyWith(
                                    fontSize: Dimensions.FONT_M,
                                    color: const Color(AllColors.colorText),
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                                elevation: 4.0,
                              ),
                              onPressed: () {},
                              child: Text(
                                Constant.LANG == Constant.EN ? ENG.INVOICE_VIEW_DOCUMENT : IT.INVOICE_VIEW_DOCUMENT,
                                style: gothamRegular.copyWith(
                                  fontSize: Dimensions.FONT_M,
                                  color: const Color(AllColors.colorBlue),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "${documentObject["document_number"]} /${documentObject["document_suffix"]}",
                                        textAlign: TextAlign.right,
                                        style: gothamRegular.copyWith(
                                          overflow: TextOverflow.clip,
                                          fontSize: Dimensions.FONT_M,
                                          color: const Color(AllColors.colorText),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        height: 90.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F8F2),
                          border: Border(
                            bottom: BorderSide(
                                color: const Color(AllColors.colorGrey),
                                width: 0.4.w),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.check,
                                      color: Color(0xFF339966),
                                      size: 18,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(left: 5),
                                      child: Text(
                                        "To Weld",
                                        style: TextStyle(
                                            color: Color(0xFF339966)),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                    Constant.LANG == Constant.EN ? ENG.INVOICE_TOTAL_INVOCIE : IT.INVOICE_TOTAL_INVOCIE,
                                  style: TextStyle(
                                      color: const Color(0xFF339966),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                )
                              ],
                            ),
                            Center(
                              child: Text(
                                "${Constant.euroSign} ${vatCalculationWithAmount(documentProductArray)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Color(AllColors.colorText),
                                    fontWeight: FontWeight.bold,
                                    fontSize: Dimensions.FONT_M),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 20.0),
                        height: 150.h,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: const Color(AllColors.colorBlue),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_CUSTOMER : IT.DOCUMENT_DETAILS_CUSTOMER,
                                      style: gothamRegular.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.FONT_XL,
                                      ),
                                    ),
                                    SizedBox(height: 14.h,),
                                    Center(
                                      child: Text(
                                        "${documentObject["customer_name"]}",
                                        textAlign: TextAlign.center,
                                        style: gothamRegular.copyWith(
                                          color: Colors.white,
                                          fontSize: Dimensions.FONT_XL,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h,),
                                    Text(
                                      "${documentObject["customer_vat_number"]}",
                                      style: gothamRegular.copyWith(
                                        color: Colors.white,
                                        fontSize: Dimensions.FONT_XL,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8.0.h,),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: const Color(AllColors.colorInvoicePayment),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      Constant.LANG == Constant.EN ? ENG.PAYMENT : IT.PAYMENT,
                                      style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorBlue),
                                        fontSize: Dimensions.FONT_XL,
                                      ),
                                    ),
                                    SizedBox(height: 14.h,),
                                    Text(
                                      expiryDate,
                                      style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_XL,
                                      ),
                                    ),
                                    SizedBox(height: 12.h,),
                                    Text(
                                      expiryDateMsg,
                                      style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_XL,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: ListView.builder(
                          itemCount: documentProductArray.length,
                          scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 15),
                                        height: 0.4,
                                        width: double.infinity,
                                        color: const Color(AllColors.colorText).withOpacity(0.3),
                                      ),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width / 2.5,
                                          height: 35.h,
                                          decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 2.5,
                                              ),
                                            ],
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(30.r)
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${Constant.LANG == Constant.EN ? ENG.PRODUCT : IT.PRODUCT} ${(index + 1)}",
                                              textAlign: TextAlign.center,
                                              style: gothamBold.copyWith(
                                                color: const Color(AllColors.colorText),
                                                fontSize: Dimensions.FONT_XL.sp
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7.h,),
                                  Container(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: documentProductArray[index]["description"] != null ? Text(
                                                "${documentProductArray[index]["description"]}",
                                                style: gothamBold.copyWith(
                                                    color: const Color(AllColors.colorText),
                                                    fontSize: Dimensions.FONT_L.sp,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ): Text(
                                                "",
                                                style: gothamBold.copyWith(
                                                  color: const Color(AllColors.colorText),
                                                  fontSize: Dimensions.FONT_L.sp,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              "${documentProductArray[index]["quantity"]} x ${double.parse(documentProductArray[index]["price"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                              style: gothamRegular.copyWith(
                                                color: const Color(AllColors.colorText),
                                                fontSize: Dimensions.FONT_XL.sp
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 8.h,),
                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //   children: [
                                        //     Text(
                                        //       "",
                                        //       style: gothamRegular.copyWith(
                                        //         color: const Color(AllColors.colorText),
                                        //         fontSize: Dimensions.FONT_XL.sp
                                        //       ),
                                        //     ),
                                        //     Text(
                                        //       "${double.parse(documentProductArray[index]["total_withoutvat"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                        //       style: gothamBold.copyWith(
                                        //         color: const Color(AllColors.colorText),
                                        //         fontSize: Dimensions.FONT_XL.sp
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                        SizedBox(height: 8.h,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                if(documentProductArray[index]["vat_value"] != null && documentProductArray[index]["vat_value"] != "")
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(30.r),
                                                      color: const Color(AllColors.colorText)
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 3.0),
                                                    child: Text(
                                                      "${Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_VAT : IT.DOCUMENT_DETAILS_VAT} ${double.parse(documentProductArray[index]["vat_value"].toString())}%".toUpperCase(),
                                                      textAlign: TextAlign.center,
                                                      style: gothamRegular.copyWith(
                                                          color: Colors.white,
                                                          fontSize: Dimensions.FONT_M.sp
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 7.w,),
                                                if(double.parse(documentProductArray[index]["discount"].toString()) > 0)
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30.r),
                                                        color: const Color(AllColors.colorBlue)
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 3.0),
                                                      child: Text(
                                                        "${Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_DISCOUNT : IT.DOCUMENT_DETAILS_DISCOUNT} ${double.parse(documentProductArray[index]["discount"].toString())}%",
                                                        textAlign: TextAlign.center,
                                                        style: gothamRegular.copyWith(
                                                            color: Colors.white,
                                                            fontSize: Dimensions.FONT_M.sp
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Text(
                                              "${double.parse(documentProductArray[index]["total_withoutvat"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                              style: gothamBold.copyWith(
                                                  color: const Color(AllColors.colorText),
                                                  fontSize: Dimensions.FONT_XL.sp
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            height: 0.4,
                            width: double.infinity,
                            color: const Color(AllColors.colorText).withOpacity(0.3),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width / 2.5,
                              height: 35.h,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 2.5,
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(30.r)),
                              child: Center(
                                child: Text(
                                  Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_AMOUNT : IT.DOCUMENT_DETAILS_AMOUNT,
                                  textAlign: TextAlign.center,
                                  style: gothamBold.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_XL.sp),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h,),
                      Column(
                        children: [
                          if(docTotalData["TotalPensionFund"] != null && docTotalData["TotalPensionFund"] > 0)
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              height: 40.h,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_PENSION_FUND : IT.DOCUMENT_DETAILS_PENSION_FUND,
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_XL.sp),
                                  ),
                                  Text(
                                    "${double.parse(docTotalData["TotalPensionFund"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_L),
                                  )
                                ],
                              ),
                            ),
                          if(docTotalData["TotalPensionFund"] != null && docTotalData["TotalPensionFund"] > 0)
                            Divider(height: 0.5.h, color: const Color(AllColors.colorText).withOpacity(0.5),),
                          if(docTotalData["TotalPensionFundVat"] != null && docTotalData["TotalPensionFundVat"] > 0)
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              height: 40.h,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_PENSION_FUND_VAT : IT.DOCUMENT_DETAILS_PENSION_FUND_VAT,
                                    style: gothamRegular.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_XL.sp,
                                    ),
                                  ),
                                  Text(
                                    "${double.parse(docTotalData["TotalPensionFundVat"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    style: gothamRegular.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_L,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          if(docTotalData["TotalPensionFundVat"] != null && docTotalData["TotalPensionFundVat"] > 0)
                            Divider(height: 0.5.h, color: const Color(AllColors.colorText).withOpacity(0.5),),
                          if(docTotalData["TotalWithoutVat0"] != null && docTotalData["TotalWithoutVat0"] > 0)
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              height: 40.h,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_TOTAL_WITHOUT_VAT_0 : IT.DOCUMENT_DETAILS_TOTAL_WITHOUT_VAT_0,
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_XL.sp),
                                  ),
                                  Text(
                                    "${double.parse(docTotalData["TotalWithoutVat0"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_L),
                                  )
                                ],
                              ),
                            ),
                          if(docTotalData["TotalWithoutVat0"] != null && docTotalData["TotalWithoutVat0"] > 0)
                            Divider(height: 0.5.h, color: const Color(AllColors.colorText).withOpacity(0.5),),
                          if(docTotalData["TotalWithoutVat1"] != null && docTotalData["TotalWithoutVat1"] > 0)
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              height: 40.h,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_TOTAL_WITHOUT_VAT_1 : IT.DOCUMENT_DETAILS_TOTAL_WITHOUT_VAT_1,
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_XL.sp),
                                  ),
                                  Text(
                                    "${double.parse(docTotalData["TotalWithoutVat1"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_L),
                                  )
                                ],
                              ),
                            ),
                          if(docTotalData["TotalWithoutVat1"] != null && docTotalData["TotalWithoutVat1"] > 0)
                            Divider(height: 0.5.h, color: const Color(AllColors.colorText).withOpacity(0.5),),
                          if(docTotalData["Stamp"] != null && docTotalData["Stamp"] > 0)
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              height: 40.h,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_STAMP : IT.DOCUMENT_DETAILS_STAMP,
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_XL.sp),
                                  ),
                                  Text(
                                    "${double.parse(docTotalData["Stamp"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_L),
                                  )
                                ],
                              ),
                            ),
                          if(docTotalData["Stamp"] != null && docTotalData["Stamp"] > 0)
                            Divider(height: 0.5.h, color: const Color(AllColors.colorText).withOpacity(0.5),),
                          Container(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            height: 40.h,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_VAT : IT.DOCUMENT_DETAILS_VAT,
                                  style: gothamRegular.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_XL.sp),
                                ),
                                Text(
                                  "${double.parse(docTotalData["TotalVat"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                  style: gothamRegular.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_L),
                                )
                              ],
                            ),
                          ),
                          Divider(height: 0.5.h, color: const Color(AllColors.colorText).withOpacity(0.5),),
                          if(docTotalData["TotalWitholdingTax"] != null && docTotalData["TotalWitholdingTax"] > 0)
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              height: 40.h,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_WITHHOLDING_TAX : IT.DOCUMENT_DETAILS_WITHHOLDING_TAX,
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_XL.sp),
                                  ),
                                  Text(
                                    "${double.parse(docTotalData["TotalWitholdingTax"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_L),
                                  )
                                ],
                              ),
                            ),
                          if(docTotalData["TotalWitholdingTax"] != null && docTotalData["TotalWitholdingTax"] > 0)
                            Divider(height: 0.5.h, color: const Color(AllColors.colorText).withOpacity(0.5),),
                          Container(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            height: 40.h,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_TOTAL : IT.DOCUMENT_DETAILS_TOTAL,
                                  style: gothamBold.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_XL.sp),
                                ),
                                Text(
                                  "${vatCalculationWithAmount(documentProductArray)} ${Constant.euroSign}",
                                  style: gothamBold.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_L),
                                )
                              ],
                            ),
                          ),
                          if(docTotalData["TotalToPaid"] != null && docTotalData["TotalToPaid"] > 0)
                            Divider(height: 0.5.h, color: const Color(AllColors.colorText).withOpacity(0.5),),
                          if(docTotalData["TotalToPaid"] != null && docTotalData["TotalToPaid"] > 0)
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              height: 40.h,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_TOTAL_TO_PAY : IT.DOCUMENT_DETAILS_TOTAL_TO_PAY,
                                    style: gothamBold.copyWith(
                                        color: const Color(AllColors.colorRed),
                                        fontSize: Dimensions.FONT_XL.sp),
                                  ),
                                  Text(
                                    "${double.parse(docTotalData["TotalToPaid"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                                    style: gothamBold.copyWith(
                                        color: const Color(AllColors.colorRed),
                                        fontSize: Dimensions.FONT_L),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h,),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: Platform.isAndroid ? 50.h : 70.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.email_rounded,
                          color: Color(AllColors.colorBlue),
                        ),
                        Text(
                            Constant.LANG == Constant.EN ? ENG.LOGIN_EMAIL : IT.LOGIN_EMAIL,
                          style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M,
                            color: const Color(AllColors.colorText),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.share,
                          color: Color(AllColors.colorBlue),
                        ),
                        Text(
                            Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_SHARE : IT.DOCUMENT_DETAILS_SHARE,
                          style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M,
                            color: const Color(AllColors.colorText),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.local_print_shop_outlined,
                          color: Color(AllColors.colorBlue),
                        ),
                        Text(
                          Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_PRINT : IT.DOCUMENT_DETAILS_PRINT,
                          style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M,
                            color: const Color(AllColors.colorText),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.compare_arrows,
                          color: Color(AllColors.colorBlue),
                        ),
                        Text(
                          Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_TRANSFORM_IN : IT.DOCUMENT_DETAILS_TRANSFORM_IN,
                          style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M,
                            color: const Color(AllColors.colorText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getInvoiceDetail() {
    setState(() {
      showLoader = true;
    });

    GetRequest request = GetRequest();
    request.getResponse(
      cmd: "${RequestCmd.getInvoiceDocInfo}${widget.documentType}/document-detail/${widget.id}?isRowCLick=false&isMobile=true",
      token: userModel!.authorization,
      responseCode: INVOICE_INFO_DATA,
      companyId: currentCompanyId
    );
    request.setListener(this);
  }

  @override
  void onFailed(response, statusCode) {
    setState(() {
      showLoader = false;
      if (statusCode != null && statusCode == 401) {
        Utility.clearPreference();
        Utility.showErrorToast("Session expired");
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
    if (responseCode == INVOICE_INFO_DATA) {
      setState(() {
        debugPrint("$TAG response =======> ${response[Constant.data]}");
        documentObject = response[Constant.data]["document"];
        withHoldingTaxObject = response[Constant.data]["withHoldingTax"];
        documentPaymentArray = response[Constant.data]["documentPayment"];
        documentProductArray = response[Constant.data]["documentProduct"];
        docTotalData = response[Constant.data]["docTotalData"];


        debugPrint("$TAG response documentObject =======> $documentObject");
        debugPrint("$TAG response withHoldingTaxObject =======> $withHoldingTaxObject");
        debugPrint("$TAG response documentPaymentArray =======> $documentPaymentArray");
        debugPrint("$TAG response documentProductArray =======> $documentProductArray");
        debugPrint("$TAG response docTotalData =======> $docTotalData");

        showLoader = false;

        expiryDateMsg = checkExpiryDate(documentPaymentArray);
      });
    }
  }

  String checkExpiryDate(List<dynamic> documentPaymentArray) {
    if (documentPaymentArray.isEmpty) {
      expiryDate = "";
      return "No expiry Date";
    } else if (documentPaymentArray.isNotEmpty) {
      String date = Utility.formatInvoiceDocInfoDate(
          documentPaymentArray[0]["expire_date"].toString());
      var difference = Utility.daysBetween(
          DateFormat("dd/MM/yyyy").parse(date), DateTime.now());
      expiryDate = date;

      if (difference < 0) {
        return "${Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_DEADLINE : IT.DOCUMENT_DETAILS_DEADLINE} $difference ${Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_DAY : IT.DOCUMENT_DETAILS_DAY}";
      } else if(difference == 1) {
        return "${Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_DEADLINE : IT.DOCUMENT_DETAILS_DEADLINE} $difference ${Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_DAY : IT.DOCUMENT_DETAILS_DAY}";
      } else {
        return "${Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_DEADLINE : IT.DOCUMENT_DETAILS_DEADLINE} $difference ${Constant.LANG == Constant.EN ? ENG.DOCUMENT_DETAILS_DAYS : IT.DOCUMENT_DETAILS_DAYS}";
      }
    } else {
      return "";
    }
  }

  String vatCalculation(List<dynamic> documentProductArray) {
    debugPrint(
        "$TAG Document Payment Array =======> ${documentProductArray.toString()}");
    if (documentProductArray.isEmpty) {
      return "0.00";
    } else {
      double totalVat = 0.0;
      for (int i = 0; i < documentProductArray.length; i++) {
        if(documentProductArray[i]["vat_value"] > 0) {
          totalVat += ((documentProductArray[i]["vat_value"] * documentProductArray[i]["price"]) / 100);
        }
      }
      return totalVat.toStringAsFixed(2);
    }
  }

  String vatCalculationWithAmount(List<dynamic> documentProductArray) {
    debugPrint("$TAG Document Product Array =======> ${documentProductArray.toString()}");
    double totalAmount = 0.00;
    for (int i = 0; i < documentProductArray.length; i++) {
      totalAmount += documentProductArray[i]["total"];
    }
    return totalAmount.toStringAsFixed(2);
  }
}