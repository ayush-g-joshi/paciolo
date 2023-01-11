import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/util/CommonCSS.dart';

import '../model/InvoicePaymentFilterModel.dart';
import '../model/InvoicePaymentTypeFilterModel.dart';
import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';

class CustomerProfileFilterScreen extends StatefulWidget {

  var paymentFilter;
  var paymentTypeFilter;

  CustomerProfileFilterScreen({Key? key, this.paymentFilter, this.paymentTypeFilter}) : super(key: key);

  @override
  State<CustomerProfileFilterScreen> createState() => _CustomerProfileFilterScreenState();
}

class _CustomerProfileFilterScreenState extends State<CustomerProfileFilterScreen> {

  String TAG = "_CustomerProfileFilterScreenState";
  bool showLoader = false;
  bool paymentChecked = false;
  bool paymentTypeChecked = false;

  List<InvoicePaymentFilterModel> paymentFilterData = List.from([
    InvoicePaymentFilterModel(id: 1, name: "Filtra dall'ultima fattura non pagata ad oggi", isChecked: false),
    InvoicePaymentFilterModel(id: 2, name: "Filtra solo anno corrente", isChecked: false),
    InvoicePaymentFilterModel(id: 3, name: "Filtra solo scorso anno", isChecked: false),
    InvoicePaymentFilterModel(id: 4, name: "Filtra da sempre", isChecked: false),
  ]);

  List<InvoicePaymentTypeFilterModel> paymentTypeFilterData = List.from([
    InvoicePaymentTypeFilterModel(name: "Tutti", value: null, isChecked: false),
    InvoicePaymentTypeFilterModel(name: "Entrate", value: 1, isChecked: false),
    InvoicePaymentTypeFilterModel(name: "Uscite", value: 0, isChecked: false),
  ]);

  @override
  void initState() {
    for(int i = 0; i < paymentFilterData.length; i++) {
      if(paymentFilterData[i].id == widget.paymentFilter) {
        paymentFilterData[i].isChecked = true;
      }
    }
    for(int i = 0; i < paymentTypeFilterData.length; i++) {
      if(paymentTypeFilterData[i].value == widget.paymentTypeFilter) {
        paymentTypeFilterData[i].isChecked = true;
      }
    }
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
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  Constant.LANG == Constant.EN ? ENG.C_P_INVOICE_FILTER_HEADING_1 : IT.C_P_INVOICE_FILTER_HEADING_1,
                  textAlign: TextAlign.start,
                  style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L
                  ),
                ),
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: paymentFilterData.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(height: 0.7, color: const Color(AllColors.colorText).withOpacity(0.4),);
                },
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Container(
                      padding: const EdgeInsets.all(Dimensions.PADDING_S),
                      child: Text(
                        paymentFilterData[index].name,
                        textAlign: TextAlign.start,
                        style: gothamRegular.copyWith(
                            color: const Color(AllColors.colorText),
                            fontSize: Dimensions.FONT_M
                        ),
                      ),
                    ),
                    value: paymentFilterData[index].isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        for(int i = 0; i < paymentFilterData.length; i++) {
                          if(paymentFilterData[index] == paymentFilterData[i]) {
                            paymentFilterData[i].isChecked = value!;
                          } else {
                            paymentFilterData[i].isChecked = false;
                          }
                        }
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 40.0.h,),
              Container(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  Constant.LANG == Constant.EN ? ENG.C_P_INVOICE_FILTER_HEADING_2 : IT.C_P_INVOICE_FILTER_HEADING_2,
                  textAlign: TextAlign.start,
                  style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L
                  ),
                ),
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: paymentTypeFilterData.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(height: 0.7, color: const Color(AllColors.colorText).withOpacity(0.4),);
                },
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Container(
                      padding: const EdgeInsets.all(Dimensions.PADDING_S),
                      child: Text(
                        paymentTypeFilterData[index].name,
                        textAlign: TextAlign.start,
                        style: gothamRegular.copyWith(
                            color: const Color(AllColors.colorText),
                            fontSize: Dimensions.FONT_M
                        ),
                      ),
                    ),
                    value: paymentTypeFilterData[index].isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        for(int i = 0; i < paymentTypeFilterData.length; i++) {
                          if(paymentTypeFilterData[index] == paymentTypeFilterData[i]) {
                            paymentTypeFilterData[i].isChecked = value!;
                          } else {
                            paymentTypeFilterData[i].isChecked = false;
                          }
                        }
                      });
                    },
                  );
                },
              ),
              // filter apply button
              InkWell(
                onTap: () {
                  var paymentFilter, paymentTypeFilter;
                  for(int i = 0; i < paymentFilterData.length; i++) {
                    if(paymentFilterData[i].isChecked) {
                      paymentFilter = paymentFilterData[i].id;
                    }
                  }
                  for(int i = 0; i < paymentTypeFilterData.length; i++) {
                    if(paymentTypeFilterData[i].isChecked) {
                      paymentTypeFilter = paymentTypeFilterData[i].value;
                    }
                  }

                  Navigator.pop(context, { "paymentFilter" : paymentFilter, "paymentTypeFilter": paymentTypeFilter});
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
}
