import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../model/LoginUserModel.dart';
import '../util/Constants.dart';
import '../util/Utility.dart';

class CustomerSupplierScreen extends StatefulWidget {
  var customerId;
  CustomerSupplierScreen({Key? key, this.customerId}) : super(key: key);

  @override
  State<CustomerSupplierScreen> createState() => _CustomerSupplierScreenState();
}

class _CustomerSupplierScreenState extends State<CustomerSupplierScreen> {

  String TAG = "_UsePriceListScreenState";
  bool showLoader = false;
  var currentCompanyId;
  LoginUserModel? userModel;

  List priceList = List.from([
    "Customer",
    "Supplier",
    "Customer & Supplier",
  ]);

  var GET_MODE_LIST = 9001;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
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
          Constant.LANG == Constant.EN ? ENG.CUSTOMER_EDIT_PROFILE_LABEL_10 : IT.CUSTOMER_EDIT_PROFILE_LABEL_10,
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
        child: ListView.separated(
          itemCount: priceList.length,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(height: 1, color: Colors.black54,);
          },
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Navigator.pop(context, {"name": priceList[index]});
              },
              child: ListTile(
                title: Text(
                  priceList[index],
                  style: gothamRegular.copyWith(
                      fontSize: Dimensions.FONT_M,
                      color: const Color(AllColors.colorText)
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
