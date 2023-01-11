import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';

import '../auth/login_screen.dart';
import '../model/LoginUserModel.dart';
import '../network/GetRequest.dart';
import '../util/Translation.dart';
import '../util/Utility.dart';
import '../util/dimensions.dart';
import '../util/images.dart';
import '../util/styles.dart';

class SelectAssociateSubjectScreen extends StatefulWidget {
  const SelectAssociateSubjectScreen({Key? key}) : super(key: key);

  @override
  State<SelectAssociateSubjectScreen> createState() => _SelectAssociateSubjectScreenState();
}

class _SelectAssociateSubjectScreenState extends State<SelectAssociateSubjectScreen> implements ResponseListener {

  String TAG = "_SelectAssociateSubjectScreenState";
  bool showLoader = false;
  var currentCompanyId;
  LoginUserModel? userModel;

  TextEditingController controller = TextEditingController();

  List subjectList = List.from([]);
  List filterList = List.from([]);

  var GET_SUBJECT = 9001;

  int page = 1;
  int limit = 30;
  // Used to display loading indicators when _firstLoad function is running
  bool _firstDataLoading = true;
  bool _isMoreData = true;
  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;
  late ScrollController _controller;

  @override
  void initState() {
    Utility.getStringSharedPreference(Constant.userObject).then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint(
          "$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      page = 1;
      _isMoreData = true;
      getAssociateSubject(true);
    });

    _controller = ScrollController();
    _controller.addListener(() {
      if(_controller.offset >= _controller.position.maxScrollExtent) {
        _loadMore();
      }
    },);

    controller.addListener(() {
      debugPrint("$TAG controller Listener value ======> ${controller.text.trim().toString()}");
      if (controller.text.trim().toString().isNotEmpty) {
        //onSearchTextChanged(controller.text.trim().toString().toLowerCase());
        setState(() {
          filterList.clear();

          for(int x =0; x < subjectList.length; x++) {
            if(subjectList[x]["name"].toLowerCase().startsWith(
                controller.text.trim().toString().toLowerCase())) {

              filterList.add(subjectList[x]);
            }
          }
        });
      } else {
        setState(() {
          controller.clear();
          filterList.clear();
          onSearchTextChanged('');
        });
      }
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
          Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_FILTER_ASSOCIATE_SUBJECT : IT.PAYMENT_REGISTRY_FILTER_ASSOCIATE_SUBJECT,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                            filterList.clear();
                            onSearchTextChanged('');
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
                      hintText: Constant.LANG == Constant.EN ? ENG.PAYMENT_REGISTRY_SEARCH_HINT : IT.PAYMENT_REGISTRY_SEARCH_HINT,
                      hintStyle: gothamMedium.copyWith(
                          color: Colors.grey,
                          fontSize: Dimensions.FONT_XL.sp,
                          fontWeight: FontWeight.w600
                      ),
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      //onSearchTextChanged(value.toString().toLowerCase());
                    },
                  ),
                ),
              ),
            Expanded(
              child: subjectList.isEmpty
                  ? Container(
                child: Center(
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
                            color: Color(AllColors.colorNoResult),
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              )
                  : Container(
                child: filterList.isNotEmpty || controller.text.isNotEmpty ?

                ListView.builder(
                  itemCount: filterList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  // separatorBuilder: (BuildContext context, int index) {
                  //   return const Divider(height: 1, color: Colors.black54,);
                  // },
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0, 0.0),
                      color: (index % 2 == 0) ? Colors.white : const Color(AllColors.colorListBack),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, {"subjectData": filterList[index]});
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
                                      filterList[index]["name"],
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorText),
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: Dimensions.FONT_M,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                                Container(
                                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                    child: Text(
                                      "${double.parse(subjectList[index]["remainingToPay"].toString().replaceAll("-", "")).toStringAsFixed(2)} ${Constant.euroSign}",
                                      textAlign: TextAlign.end,
                                      style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorRed),
                                          fontSize: Dimensions.FONT_M,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal),
                                    ))
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                              child: Text(
                                "N° ${filterList[index]["docCount"]}",
                                style: gothamRegular.copyWith(
                                    fontSize: Dimensions.FONT_M,
                                    color: const Color(AllColors.colorText)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ) :
                ListView.builder(
                  controller: _controller,
                  itemCount: subjectList.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  // separatorBuilder: (BuildContext context, int index) {
                  //   return const Divider(height: 1, color: Colors.black54,);
                  // },
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0, 0.0),
                      color: (index % 2 == 0) ? Colors.white : Color(AllColors.colorListBack),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context, {"subjectData": subjectList[index]});
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
                                      subjectList[index]["name"],
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: gothamRegular.copyWith(
                                          color: Color(AllColors.colorText),
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: Dimensions.FONT_M,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                                Container(
                                    padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0),
                                    child: Text(
                                      "${double.parse(subjectList[index]["remainingToPay"].toString().replaceAll("-", "")).toStringAsFixed(2)} ${Constant.euroSign}",
                                      textAlign: TextAlign.end,
                                      style: gothamRegular.copyWith(
                                          color: const Color(AllColors.colorRed),
                                          fontSize: Dimensions.FONT_M,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.normal),
                                    ))
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                              child: Text(
                                "N° ${subjectList[index]["docCount"]}",
                                style: gothamRegular.copyWith(
                                    fontSize: Dimensions.FONT_M,
                                    color: const Color(AllColors.colorText)
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ),
            if(_isLoadMoreRunning)
              Container(
                height: 40.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(AllColors.colorBlue),
                    ),
                    SizedBox(width: 10.w,),
                    Text(
                      Constant.LANG == Constant.EN ? ENG.LOADING : IT.LOADING,
                      style: gothamRegular.copyWith(
                        fontSize: Dimensions.FONT_M,
                        color: Color(AllColors.colorText),

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

  onSearchTextChanged(String text) async {
    if (text.isNotEmpty) {
      setState(() {
        // debugPrint("$TAG on Search Text Changed text =======> $text");
        // for (int i = 0; i < subjectList.length; i++) {
        //   debugPrint("$TAG subject name ========> ${subjectList[i]["name"]}");
        //   if (subjectList[i]["name"].toString().toLowerCase().contains(text)) {
        //     filterList.add(subjectList[i]);
        //     debugPrint("$TAG filter data name ========> ${filterList.length}");
        //   }
        // }
        filterList.clear();
        filterList = subjectList.where((x) => x["name"].toLowerCase().contains(text.toLowerCase())).toList();

        debugPrint("$TAG filterList length =========> ${filterList.length}");
      });
    } else {
      setState(() {
        filterList.clear();
      });
    }
  }

  void getAssociateSubject(bool isLoader) {
    // https://devapi.paciolo.it/customer/customer-list-details/?page=1&per_page=50&customer_type=undefined
    // &term=undefined&tags=&gtags=&comTags=
    setState(() {
      if(isLoader) {
        showLoader = true;
      }
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: "${RequestCmd.getAssociateSubject}?page=$page&per_page=$limit&customer_type=&term=&tags=&gtags=&comTags=",
        token: userModel!.authorization,
        responseCode: GET_SUBJECT,
        companyId: currentCompanyId);
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
      getAssociateSubject(false);
    }
  }

  @override
  void onFailed(response, statusCode) {
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
    if(responseCode == GET_SUBJECT) {
      setState(() {
        if(_isLoadMoreRunning) {
          _isLoadMoreRunning = false;
          if(response[Constant.data]["record"]["data"].length <= 0) {
            _isMoreData = false;
            Utility.showToast(Constant.LANG == Constant.EN ? ENG.NO_MORE_DATA : IT.NO_MORE_DATA);
          }
          for(int i = 0; i < response[Constant.data]["record"]["data"].length; i++) {
            subjectList.add(response[Constant.data]["record"]["data"][i]);
          }
        } else {
          showLoader = false;
          subjectList.clear();
          for (int i = 0; i <
              response[Constant.data]["record"]["data"].length; i++) {
            subjectList.add(response[Constant.data]["record"]["data"][i]);
          }
        }
      });
      debugPrint("$TAG GET subject LIST ========> ${response[Constant.data]["record"]["data"]}");
    }
  }
}
