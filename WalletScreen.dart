import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/PostRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/images.dart';
import 'package:paciolo/util/styles.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    implements ResponseListener {
  var TAG = "_WalletScreenState";
  var currentCompanyId;
  bool showLoader = false;
  List walletData = List.from([]);
  LoginUserModel? userModel;
  var WALLET_DATA = 3000;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject)
        .then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;

      getWallet();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(Images.homeLogo, height: 20.h),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF2573BD),
                Color(0xFF2F9BC3),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
          inAsyncCall: showLoader,
          opacity: 0.7,
          child: Column(
            children: [
              // Wallet Text with Divider
              walletText(),
              // wallet data listing
              const SizedBox(
                height: Dimensions.PADDING_S,
              ),
              Expanded(
                  child: GridView.builder(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 30),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 2 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: walletData.length,
                itemBuilder: (context, index) {
                  return Card(
                    shadowColor: Colors.black54,
                    elevation: Dimensions.PADDING_S,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_XL),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(Dimensions.RADIUS_XL)),
                          border:
                              Border.all(color: Colors.black, width: 0.5.w)),
                      alignment: Alignment.center,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            showIcon(walletData[index]["wallet_type_id"]),
                            const SizedBox(
                              height: Dimensions.PADDING_S,
                            ),
                            Text(
                              walletData[index]["name"],
                              textAlign: TextAlign.center,
                              style: gothamMedium.copyWith(
                                  fontSize: Dimensions.FONT_L),
                            ),
                            const SizedBox(
                              height: Dimensions.PADDING_S,
                            ),
                            Text(
                              "${double.parse(walletData[index]["ballance"].toString()).toStringAsFixed(2)} ${Constant.euroSign}",
                              textAlign: TextAlign.center,
                              style: gothamMedium.copyWith(
                                  color: double.parse(walletData[index]
                                                  ["ballance"]
                                              .toString()) <
                                          0
                                      ? const Color(AllColors.colorBalanceRed)
                                      : Colors.black,
                                  fontSize: Dimensions.FONT_L),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ))
            ],
          )),
    );
  }

  Widget walletText() {
    return Padding(
      padding: const EdgeInsets.only(
          left: Dimensions.PADDING_L,
          right: Dimensions.PADDING_L,
          top: Dimensions.PADDING_L),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Wallet",
            style: gothamMedium.copyWith(
              fontSize: Dimensions.FONT_2XL.sp,
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(
            height: 4.h,
          ),
          Divider(
            height: 1.0.h,
            color: Colors.grey,
          )
        ],
      ),
    );
  }

  Widget showIcon(int status) {
    SvgPicture? svg;
    switch (status) {
      case 1:
        svg = SvgPicture.asset(
          Images.bancaLogo,
          semanticsLabel: 'Banca Logo',
          height: 65.h,
          width: 65.w,
          cacheColorFilter: true,
          colorBlendMode: BlendMode.saturation,
          //color: Colors.green,
        );
        break;
      case 2:
        svg = SvgPicture.asset(
          Images.creditCardLogo,
          semanticsLabel: 'Credit Card Logo',
          height: 65.h,
          width: 65.w,
          cacheColorFilter: true,
          //color: Colors.green,
        );
        break;
      case 3:
        svg = SvgPicture.asset(
          Images.cassaLogo,
          semanticsLabel: 'Cassa Logo',
          height: 65.h,
          width: 65.w,
          cacheColorFilter: true,
          //color: Colors.green,
        );
        break;
      case 4:
        svg = SvgPicture.asset(
          Images.titoliLogo,
          semanticsLabel: 'Titoli Logo',
          height: 65.h,
          width: 65.w,
          cacheColorFilter: true,
          //color: Colors.green,
        );
        break;
      case 5:
        svg = SvgPicture.asset(
          Images.altroLogo,
          semanticsLabel: 'Altro Logo',
          height: 65.h,
          width: 65.w,
          cacheColorFilter: true,
          //color: Colors.green,
        );
        break;
      case 6:
        svg = SvgPicture.asset(
          Images.bancaSincronizzataLogo,
          semanticsLabel: 'Banca Sincronizzata Logo',
          height: 65.h,
          width: 65.w,
          cacheColorFilter: true,
          //color: Colors.green,
        );
        break;
    }
    return svg!;
  }

  void getWallet() {
    setState(() {
      showLoader = true;
    });
    PostRequest request = PostRequest();
    request.getResponse(
        cmd: RequestCmd.getWalletData,
        token: userModel!.authorization,
        responseCode: WALLET_DATA,
        companyId: userModel!.currentCompany?.id);
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  void onSuccess(response, responseCode) {
    setState(() {
      showLoader = false;
    });
    if (responseCode == WALLET_DATA) {
      setState(() {
        walletData.clear();
        if (response[Constant.data].length > 0) {
          for (int i = 0; i < response[Constant.data].length; i++) {
            walletData.add(response[Constant.data][i]);
          }
          debugPrint("$TAG walletData ========> ${walletData.length}");
        }
      });
    }
  }
}
