
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../util/Constants.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';
import '../util/styles.dart';
import 'SelectUnitTypeScreen.dart';
import 'SelectVatTypeScreen.dart';

class EditProductInfoScreen extends StatefulWidget {
  var productInfo;
  var unitData;
  var vatData;
  bool isAddProduct;
  var index;
  EditProductInfoScreen({Key? key, this.productInfo, this.unitData, this.vatData, required this.isAddProduct, this.index}) : super(key: key);

  @override
  State<EditProductInfoScreen> createState() => _EditProductInfoScreenState();
}

class _EditProductInfoScreenState extends State<EditProductInfoScreen> {

  String TAG = "_EditProductInfoScreenState";
  bool showLoader = false;
  String? selectedVatValue;
  var vatResult;
  double total = 0.0;

  TextEditingController descriptionController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController vatController = TextEditingController();
  TextEditingController priceController = TextEditingController(text:"0.0");
  TextEditingController unitController = TextEditingController();
  TextEditingController productCodeController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController totalWithoutVatController = TextEditingController();

  @override
  void initState() {
    if(widget.productInfo != null) {
      getTextEditingController();
    }
    super.initState();
  }

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
          Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_TITLE: IT.PRODUCT_EDIT_NEW_TITLE,
          style: gothamMedium.copyWith(
              color: Colors.white, fontSize: Dimensions.FONT_L),
        ),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showLoader,
        opacity: 0.7,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            margin: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.r),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // commented by swati 17/11/2022 for description textFiled
                  Text(
                      Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_DESCRIPTION: IT.PRODUCT_EDIT_NEW_DESCRIPTION,
                      style: gothamRegular.copyWith(
                        color: Colors.black,
                        fontSize: Dimensions.FONT_L,
                      )),
                  const SizedBox(height: Dimensions.PADDING_XS),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      hintColor:const Color(0xFFbdc6cf),
                    ),
                    child: SizedBox(
                      height: 43.h,
                      child: TextField(
                        controller: descriptionController,
                        autofocus: false,
                        style: gothamRegular.copyWith(
                          color: Colors.black,
                          fontSize: Dimensions.FONT_L,
                        ),
                        decoration: InputDecoration(
                          hintText: Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_DESCRIPTION: IT.PRODUCT_EDIT_NEW_DESCRIPTION,
                          filled: true,
                          fillColor:const Color(0xFFF1F1F1),
                          contentPadding: const EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0, right: 10.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide:const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(15.0.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.PADDING_L),

                  // commented by swati 17/11/2022 for quantity and vat textFiled
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_QUANTITY: IT.PRODUCT_EDIT_NEW_QUANTITY,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                )),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Theme(
                              data: Theme.of(context).copyWith(
                                splashColor: Colors.transparent,
                                hintColor: const Color(0xFFbdc6cf),
                              ),
                              child: SizedBox(
                                height: 43.h,
                                child: TextField(
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                  autofocus: false,
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      vatCalculationWithTotal();
                                    });

                                  },
                                  decoration: InputDecoration(
                                    hintText: Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_QUANTITY: IT.PRODUCT_EDIT_NEW_QUANTITY,
                                    filled: true,
                                    fillColor:const Color(0xFFF1F1F1),
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0,
                                        bottom: 8.0,
                                        top: 8.0,
                                        right: 10.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Colors.white),
                                      borderRadius:
                                      BorderRadius.circular(15.r),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Colors.white),
                                      borderRadius:
                                      BorderRadius.circular(15.0.r),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),

                      //commented by swati 17/11/2022 VAT textFiled
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_VAT: IT.PRODUCT_EDIT_NEW_VAT,
                              style: gothamRegular.copyWith(
                                  color: const Color(AllColors.colorText),
                                  fontSize: Dimensions.FONT_L.sp),
                            ),
                            SizedBox(height: 15.h,),
                            Theme(
                              data: Theme.of(context).copyWith(
                                splashColor: Colors.transparent,
                                hintColor: const Color(0xFFbdc6cf),
                              ),
                              child: SizedBox(
                                height: 43.h,
                                child: TextField(
                                  controller: vatController,
                                  readOnly: true,
                                  autofocus: false,
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                  ),
                                  onTap: () async {
                                    vatResult = await Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return SelectVatTypeScreen();
                                      },
                                    ));

                                    debugPrint("$TAG filterVatResult ======> $vatResult");

                                    setState(() {
                                      if (vatResult != null) {
                                        vatController.text = vatResult["name"];
                                        selectedVatValue = vatResult["value"].toString();
                                        vatCalculationWithTotal();
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    suffixIcon:
                                    const Icon(Icons.arrow_forward_ios),
                                    hintText: Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_VAT: IT.PRODUCT_EDIT_NEW_VAT,
                                    filled: true,
                                    fillColor: const Color(0xFFF1F1F1),
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0,
                                        bottom: 8.0,
                                        top: 8.0,
                                        right: 10.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Colors.white),
                                      borderRadius:
                                      BorderRadius.circular(15.r),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      const BorderSide(color: Colors.white),
                                      borderRadius:
                                      BorderRadius.circular(15.0.r),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.PADDING_L),

                  // commented by swati 17/11/2022 for price textFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_PRICE: IT.PRODUCT_EDIT_NEW_PRICE,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          )),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          hintColor:const Color(0xFFbdc6cf),
                        ),
                        child: SizedBox(
                          height: 43.h,
                          child: TextField(
                            controller:  priceController,
                            keyboardType: TextInputType.number,
                            autofocus: false,
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                            onChanged: (value) {
                              setState(() {
                                vatCalculationWithTotal();

                              });
                            },
                            decoration: InputDecoration(
                              filled: true,
                              hintText: Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_PRICE: IT.PRODUCT_EDIT_NEW_PRICE,
                              fillColor:const Color(0xFFF1F1F1),
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0,
                                  bottom: 8.0,
                                  top: 8.0,
                                  right: 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.0.r),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: Dimensions.PADDING_L),

                  //commented by swati 17/11/2022 for product code textFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_PRODUCT_CODE: IT.PRODUCT_EDIT_NEW_PRODUCT_CODE,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          )),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          hintColor:const Color(0xFFbdc6cf),
                        ),
                        child: SizedBox(
                          height: 43.h,
                          child: TextField(
                            controller: productCodeController,
                            autofocus: false,
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              hintText: Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_PRODUCT_CODE: IT.PRODUCT_EDIT_NEW_PRODUCT_CODE,
                              helperStyle: gothamRegular.copyWith(
                                  fontSize: Dimensions.FONT_XS.sp),
                              fillColor:const Color(0xFFF1F1F1),
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0,
                                  bottom: 8.0,
                                  top: 8.0,
                                  right: 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.0.r),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: Dimensions.PADDING_L),

                  //commented by swati 17/11/2022 for unit textFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_UNIT: IT.PRODUCT_EDIT_NEW_UNIT,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          )),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          hintColor:const Color(0xFFbdc6cf),
                        ),
                        child: SizedBox(
                          height: 43.h,
                          child: TextField(
                            controller: unitController,
                            readOnly: true,
                            autofocus: false,
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                            onTap: () async {
                              var unitResult = await Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SelectUnitTypeScreen();
                                    },
                                  ));

                              debugPrint(
                                  "$TAG filterUnitResult ======> ${unitResult["unitName"]}");

                              setState(() {
                                if (unitResult != null) {
                                  unitController.text =
                                  unitResult["unit_display"];
                                }
                              });
                            },
                            decoration: InputDecoration(
                              suffixIcon: const Icon(Icons.arrow_forward_ios),
                              hintText: Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_UNIT_MEASURE: IT.PRODUCT_EDIT_NEW_UNIT_MEASURE,
                              helperStyle: gothamRegular.copyWith(
                                  fontSize: Dimensions.FONT_XS.sp),
                              filled: true,
                              fillColor: const Color(0xFFF1F1F1),
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0,
                                  bottom: 9.0,
                                  top: 10.0,
                                  right: 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.0.r),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: Dimensions.PADDING_L),

                  //commented by swati 17/11/2022 for discount textFiled
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_DISCOUNT_PER: IT.PRODUCT_EDIT_NEW_DISCOUNT_PER,
                          style: gothamRegular.copyWith(
                            color: Colors.black,
                            fontSize: Dimensions.FONT_L,
                          )),
                      const SizedBox(height: Dimensions.PADDING_XS),
                      Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          hintColor:const Color(0xFFbdc6cf),
                        ),
                        child: SizedBox(
                          height: 43.h,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: discountController,
                            autofocus: false,
                            onChanged: (value) {
                              setState(() {
                                vatCalculationWithTotal();
                              });

                            },
                            style: gothamRegular.copyWith(
                              color: Colors.black,
                              fontSize: Dimensions.FONT_L,
                            ),
                            decoration: InputDecoration(
                              hintText: Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_DISCOUNT: IT.PRODUCT_EDIT_NEW_DISCOUNT,
                              helperStyle: gothamRegular.copyWith(
                                  fontSize: Dimensions.FONT_XS.sp),
                              filled: true,
                              fillColor: const Color(0xFFF1F1F1),
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0,
                                  bottom: 9.0,
                                  top: 10.0,
                                  right: 10.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15.0.r),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: Dimensions.PADDING_L),

                  //commented by swati 17/11/2022 for total textFiled
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_TOTAL_WITH_VAT: IT.PRODUCT_EDIT_NEW_TOTAL_WITH_VAT,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                )),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Theme(
                              data: Theme.of(context).copyWith(
                                splashColor: Colors.transparent,
                                hintColor:const Color(0xFFbdc6cf),
                              ),
                              child: SizedBox(
                                height: 43.h,

                                child:  Text(totalController.text.isEmpty?"0.00 ${Constant.euroSign}":"${totalController.text} ${Constant.euroSign}",
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_NEW_TOTAL_WITHOUT_VAT: IT.PRODUCT_EDIT_NEW_TOTAL_WITHOUT_VAT,
                                style: gothamRegular.copyWith(
                                  color: Colors.black,
                                  fontSize: Dimensions.FONT_L,
                                )),
                            const SizedBox(height: Dimensions.PADDING_XS),
                            Theme(
                              data: Theme.of(context).copyWith(
                                splashColor: Colors.transparent,
                                hintColor:const Color(0xFFbdc6cf),
                              ),
                              child: SizedBox(
                                height: 43.h,
                                child:  Text( totalWithoutVatController.text.isEmpty?"0.00 ${Constant.euroSign}": "${totalWithoutVatController.text} ${Constant.euroSign}",
                                  style: gothamRegular.copyWith(
                                    color: Colors.black,
                                    fontSize: Dimensions.FONT_L,
                                  ),
                                ),

                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.PADDING_4XL),
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
                        if(quantityController.text == "") {
                          Utility.showToast(Constant.LANG == Constant.EN ? ENG.ADD_PRODUCT_CHECK_1 : IT.ADD_PRODUCT_CHECK_1);
                        } else if(priceController.text == "") {
                          Utility.showToast(Constant.LANG == Constant.EN ? ENG.ADD_PRODUCT_CHECK_2 : IT.ADD_PRODUCT_CHECK_2);
                        } else {
                          Map<String, dynamic> productResult;
                          if (vatResult != null) {
                            productResult = {
                              "product_code": productCodeController.text,
                              "description": descriptionController.text,
                              "quantity": quantityController.text,
                              "unit_display": unitController.text,
                              "price": priceController.text,
                              "vat_value": vatResult["value"],
                              "vat_display": vatResult["name"],
                              "vat": vatResult["id"],
                              "vatResult": vatResult,
                              "tarifDiscount": discountController.text,
                              "total": totalController.text,
                              "id": widget.productInfo["id"],
                              "unit": widget.productInfo["unit"],
                              "totalWithOutVat": totalWithoutVatController.text,
                            };
                          } else {
                            productResult = {
                              "product_code": productCodeController.text,
                              "description": descriptionController.text,
                              "quantity": quantityController.text,
                              "unit_display": unitController.text,
                              "price": priceController.text,
                              "vat_value": widget.productInfo["vat_value"],
                              "vat_display": widget.productInfo["vat_display"],
                              "vat": widget.productInfo["vat"],
                              "tarifDiscount": discountController.text,
                              "total": totalController.text,
                              "id": widget.productInfo["id"],
                              "unit": widget.productInfo["unit"],
                              "vatResult": widget.productInfo["vatResult"],
                              "totalWithOutVat": totalWithoutVatController.text,
                            };
                          }
                          debugPrint("$TAG productResult =====> $productResult");

                          if (widget.isAddProduct) {
                            Navigator.pop(context, productResult);
                            Navigator.pop(context, productResult);
                          } else {
                            Navigator.pop(context, {"productData": productResult, "position": widget.index});
                          }
                        }
                      },
                      child: widget.isAddProduct == true ? Text(Constant.LANG == Constant.EN ? ENG.PRODUCT_ADD_BUTTON : IT.PRODUCT_ADD_BUTTON,
                        textAlign: TextAlign.center,
                        style: gothamRegular.copyWith(
                          fontSize: Dimensions.PADDING_M,
                          color: Colors.white,
                        ),
                      ) : Text(Constant.LANG == Constant.EN ? ENG.PRODUCT_EDIT_BUTTON : IT.PRODUCT_EDIT_BUTTON,
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
    );
  }

  getTextEditingController() {

    debugPrint("$TAG widget product info ===========> ${widget.productInfo}");

    descriptionController.text = widget.productInfo["description"] == null
        ? ""
        : widget.productInfo["description"].toString();
    quantityController.text = widget.productInfo["quantity"] == 0
        ? "1"
        : widget.productInfo["quantity"].toString();
    vatController.text =
    widget.productInfo["vat_display"] == null ? "" : widget.productInfo["vat_display"].toString();
    priceController.text =
    widget.productInfo["price"] == null ? "" : widget.productInfo["price"].toString();
    unitController.text = widget.productInfo["unit_display"] == null
        ? ""
        : widget.productInfo["unit_display"].toString();
    productCodeController.text = widget.productInfo["product_code"] == null
        ? ""
        : widget.productInfo["product_code"].toString();
    discountController.text = widget.productInfo["tarifDiscount"] == null
        ? ""
        : widget.productInfo["tarifDiscount"].toString();

    selectedVatValue = widget.productInfo["vat_value"] == null ? "" : widget.productInfo["vat_value"].toString();
    vatCalculationWithTotal();
    calculationWithoutVatTotal();
  }

  void vatCalculationWithTotal() {

    if(quantityController.text.isEmpty || quantityController.text == "") {
      totalController.text = "0.00";
      calculationWithoutVatTotal();
    } else if(selectedVatValue == null || selectedVatValue == "") {

      if(discountController.text.isEmpty || discountController.text == "") {
        double total = (double.parse(quantityController.text) * double.parse(priceController.value.text.isEmpty?"0.0":priceController.value.text));
        debugPrint("$TAG vat calculation total ======> $total");
        double vatValue = 0.0;
        debugPrint("$TAG vat calculation vatValue ======> $vatValue");
        double finalTotal = total + vatValue - 0;
        debugPrint("$TAG vat calculation finalTotal ======> $finalTotal");
        totalController.text = finalTotal.toStringAsFixed(2);

        calculationWithoutVatTotal();

      } else {
        double total = (double.parse(quantityController.text) * double.parse(priceController.value.text.isEmpty?"0.0":priceController.value.text));
        debugPrint("$TAG vat calculation total ======> $total");
        double vatValue = 0.0;
        debugPrint("$TAG vat calculation vatValue ======> $vatValue");
        double discount = (total + vatValue) * double.parse(discountController.text.toString()) / 100;
        double finalTotal = total + vatValue - discount;
        debugPrint("$TAG vat calculation finalTotal ======> $finalTotal");
        totalController.text = finalTotal.toStringAsFixed(2);


        calculationWithoutVatTotal();
      }
    } else {
      if(discountController.text.isEmpty || discountController.text == "") {
        double total = (double.parse(quantityController.text) * double.parse(priceController.value.text.isEmpty?"0.0":priceController.value.text));
        debugPrint("$TAG vat calculation total ======> $total");
        double vatValue = total * double.parse(selectedVatValue!) / 100;
        debugPrint("$TAG vat calculation vatValue ======> $vatValue");
        double finalTotal = total + vatValue - 0;
        debugPrint("$TAG vat calculation finalTotal ======> $finalTotal");
        totalController.text = finalTotal.toStringAsFixed(2);


        calculationWithoutVatTotal();
      } else {
        double total = (double.parse(quantityController.text) * double.parse(priceController.value.text.isEmpty?"0.0":priceController.value.text));
        debugPrint("$TAG vat calculation total ======> $total");
        double vatValue = total * double.parse(selectedVatValue!) / 100;
        debugPrint("$TAG vat calculation vatValue ======> $vatValue");
        double discount = (total + vatValue) * double.parse(discountController.text.toString()) / 100;
        double finalTotal = total + vatValue - discount;
        debugPrint("$TAG vat calculation finalTotal ======> $finalTotal");
        totalController.text = finalTotal.toStringAsFixed(2);

        calculationWithoutVatTotal();
      }
    }
  }

  void calculationWithoutVatTotal() {

    if((quantityController.text.isEmpty || quantityController.text == "") && priceController.text.isEmpty || priceController.text == "") {
      totalWithoutVatController.text = "0.00";
    }

    else
    if(discountController.text.isEmpty || discountController.text == "") {
      double total = (double.parse(quantityController.text) * double.parse(priceController.value.text.isEmpty?"0.0":priceController.value.text));
      double finalTotalWithoutVat= total - 0;
      totalWithoutVatController.text = finalTotalWithoutVat.toStringAsFixed(2);
    } else {
      double total = (double.parse(quantityController.text) * double.parse(priceController.value.text.isEmpty?"0.0":priceController.value.text));
      double discountWithoutVat = total * double.parse(discountController.text.toString()) / 100;
      double finalTotalWithoutVat= total - discountWithoutVat;
      totalWithoutVatController.text = finalTotalWithoutVat.toStringAsFixed(2);
    }

  }
}
