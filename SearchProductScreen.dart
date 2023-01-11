
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

import '../auth/login_screen.dart';
import '../childscreens/EditProductInfoScreen.dart';
import '../model/LoginUserModel.dart';
import '../network/PostRequest.dart';
import '../network/ResponseListener.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/images.dart';

class SearchProductScreen extends StatefulWidget {
  const SearchProductScreen({Key? key}) : super(key: key);

  @override
  State<SearchProductScreen> createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> implements ResponseListener  {

  String TAG = "_SearchProductScreenState";
  bool showLoader = false;
  int page = 1;
  int limit = 20;
  LoginUserModel? userModel;
  var currentCompanyId;
  TextEditingController controller = TextEditingController();
  List productList = List.from([]);
  var GET_PRODUCT = 8765;
  String searchText = "";

  // Used to display loading indicators when _firstLoad function is running
  bool _firstDataLoading = true;
  bool _isMoreData = true;
  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;
  late ScrollController scrollController;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      getProductList(true);
    });

    scrollController = ScrollController();
    scrollController.addListener(() {
      if(scrollController.offset >= scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    },);

    controller.addListener(() {
      debugPrint("$TAG controller listener value ======> ${controller.text.trim().toString()}");
      if (controller.text.trim().toString().isNotEmpty) {
        if(controller.text.trim().toString().length >= 2) {
          setState(() {
            page = 1;
            searchText = controller.text.trim().toString();
            getProductList(false);
          });
        }
      } else {
        setState(() {
          if(searchText != "") {
            controller.clear();
            searchText = "";
            page = 1;
            getProductList(true);
          }
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_loadMore);
    super.dispose();
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
          Constant.LANG == Constant.EN ? ENG.PRODUCT : IT.PRODUCT,
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
          children: [
            // search box
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          controller.clear();
                          searchText = "";
                          page = 1;
                          getProductList(false);
                        });
                      },
                      icon: const Icon(Icons.cancel),
                    ),
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
                    hintText: Constant.LANG == Constant.EN ? ENG.CUSTOMERS_LIST_SEARCH_FIELD_HINT : IT.CUSTOMERS_LIST_SEARCH_FIELD_HINT,
                    hintStyle: gothamMedium.copyWith(
                        color: Colors.grey,
                        fontSize: Dimensions.FONT_XL.sp,
                        fontWeight: FontWeight.w600
                    ),
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    //searchText = value;
                    //onSearchTextChanged(value.toString().toLowerCase());
                  },
                ),
              ),
            ),
            // search box
            // search customers list
            Expanded(
              child: productList.isEmpty
                  ? Center(
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
                          color: const Color(AllColors.colorNoResult),
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              )
                  : Container(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: productList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(3.0, 7.0, 3.0, 3.0),
                      color: (index % 2 == 0) ? Colors.white : const Color(AllColors.colorListBack),
                      child: InkWell(
                        onTap: () async {
                          // comment by nilesh change the flow of product add process on 17-11-2022
                           // Navigator.pop(context, productList[index]);
                          var productResult = await Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return EditProductInfoScreen(productInfo: productList[index], isAddProduct: true);
                            },
                          ));

                          setState(() {
                            debugPrint("$TAG latest data ======> $productResult");
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                    child: Text(
                                      "Description: ${productList[index]["description"]}",
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorText),
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: Dimensions.FONT_M,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                                Container(
                                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                    child: Text(
                                      productList[index]["product_code"] == null || productList[index]["product_code"] == "" ? "" : "Code: ${productList[index]["product_code"]}",
                                      textAlign: TextAlign.end,
                                      style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_S,
                                      ),
                                    )
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child:   Container(
                                    padding: const EdgeInsets.fromLTRB(10.0, 0.0,0.0, 8.0),
                                    child: Text(
                                      "Quantity: ${productList[index]["quantity"] == null ? 0.toStringAsFixed(2) : productList[index]["quantity"].toStringAsFixed(2)}",
                                      textAlign: TextAlign.start,
                                      style: gothamRegular.copyWith(
                                        color: const Color(AllColors.colorText),
                                        fontSize: Dimensions.FONT_S,
                                      ),
                                    )
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                                  child: Text(
                                    "${productList[index]["price"] == null ? 0.toStringAsFixed(2) : productList[index]["price"].toStringAsFixed(2)} ${Constant.euroSign}",
                                    textAlign: TextAlign.end,
                                    style: gothamRegular.copyWith(
                                      color: const Color(AllColors.colorText),
                                      fontSize: Dimensions.FONT_M,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // search customers list
            if(_isLoadMoreRunning)
              SizedBox(
                height: 40.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(AllColors.colorBlue),
                    ),
                    SizedBox(width: 10.w,),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.LOADING : IT.LOADING,
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.FONT_M,
                        color: const Color(AllColors.colorText),
                      ),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void getProductList(bool show) {
    // https://devapi.paciolo.it/customer/?page=1&per_page=20&customer_type=3&term=&tags=&gtags=&comTags=
    setState(() {
      if(show) {
        showLoader = true;
      }
    });

    var body = jsonEncode({
      "currentPage": page,
      "perPage": limit,
      "sortId": "1",
      "word": "",
      "sort_order": "1",
      "customerRateId": "0",
      "displayId": "8"
    });

    PostRequest request = PostRequest();
    request.getResponse(
       cmd: "${RequestCmd.getProductList}?page=$page&per_page=$limit&customer_type=${"318"}&term=$searchText&tags=&gtags=&comTags=",
        body: body,
        token: userModel!.authorization,
        responseCode: GET_PRODUCT,
        companyId: userModel!.currentCompany!.id);
    request.setListener(this);
  }

  void _loadMore() async {
    if (_isMoreData && _isLoadMoreRunning == false) {
      debugPrint("$TAG _loadMore _isMoreData ====> $_isMoreData");
      debugPrint("$TAG _loadMore _firstDataLoading ====> $_firstDataLoading");
      debugPrint("$TAG _loadMore _isLoadMoreRunning ====> $_isLoadMoreRunning");
      setState(() {
        _isLoadMoreRunning = true;
      });
      page += 1;

      getProductList(false);
    }
  }

  @override
  void onFailed(response, statusCode) {
    if(!mounted) return;
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
    if(responseCode == GET_PRODUCT) {
      debugPrint("$TAG response product list =======> ${response[Constant.data]}");

      setState(() {
        showLoader = false;
        if(_isLoadMoreRunning) {
          _isLoadMoreRunning = false;
          if(response[Constant.data]["products"].length <= 0) {
            _isMoreData = false;
            Utility.showToast(Constant.LANG == Constant.EN ? ENG.NO_MORE_DATA : IT.NO_MORE_DATA);
          }
          var data = response[Constant.data]["products"];
          for(int i =0; i < data.length; i++) {
            productList.add(data[i]);
          }
        } else {
          productList.clear();
          var data = response[Constant.data]["products"];
          for(int i =0; i < data.length; i++) {
            productList.add(data[i]);
          }
        }

        if(page == 1) {
          _firstDataLoading = false;
        }
      });
      debugPrint("$TAG productList =======> ${productList.length}");
    }
  }
}