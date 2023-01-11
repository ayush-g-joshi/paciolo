import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:paciolo/auth/login_screen.dart';
import 'package:paciolo/innerscreens/CreateCompanyScreen.dart';
import 'package:paciolo/innerscreens/EditCompanyScreen.dart';
import 'package:paciolo/model/LoginUserModel.dart';
import 'package:paciolo/network/GetRequest.dart';
import 'package:paciolo/network/PutRequest.dart';
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';
import 'package:paciolo/util/Translation.dart';
import 'package:paciolo/util/Utility.dart';
import 'package:paciolo/util/dimensions.dart';
import 'package:paciolo/util/styles.dart';

class OthersScreen extends StatefulWidget {
  const OthersScreen({Key? key}) : super(key: key);

  @override
  State<OthersScreen> createState() => _OthersScreenState();
}

class _OthersScreenState extends State<OthersScreen> implements ResponseListener {

  String TAG = "_OthersScreenState";
  LoginUserModel? userModel;
  var currentCompanyId;
  bool showLoader = false;
  bool showCompanyDropdown = false;
  List<CurrentCompany> companyList = List.from([]);
  List<String> companyNameList = List.from([]);
  String? selectedCompany;
  var COMPANY_DATA = 2000;
  var SET_COMPANY_DATA = 2003;
  var GET_UPDATED_COMPANY_DATA = 2005;
  String changedCompany = "";

  @override
  void initState() {

    Utility.getStringSharedPreference(Constant.userObject)
        .then((String? value) {
      Map<String, dynamic> json = jsonDecode(value!);
      userModel = LoginUserModel.fromJson(json);
      debugPrint("$TAG user object Authorization ======> ${userModel!.authorization}");
      currentCompanyId = userModel!.currentCompany?.id;
      selectedCompany = userModel!.currentCompany?.name;
      getCompanyList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(AllColors.colorBlue),
        title: Text(
          Constant.LANG == Constant.EN ? ENG.OTHERS : IT.OTHERS,
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
          margin: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(showCompanyDropdown)
                Container(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    Constant.LANG == Constant.EN ? ENG.OTHERS_SELECT_COMPANY : IT.OTHERS_SELECT_COMPANY,
                    textAlign: TextAlign.start,
                    style: gothamMedium.copyWith(
                        color: const Color(AllColors.colorText),
                        fontSize: Dimensions.FONT_L
                    ),
                  ),
                ),
              if(showCompanyDropdown)
              companyDropDown(context),
              const SizedBox(height: 6,),
              const Divider(height: 1, color: Colors.black54,),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return const CreateCompanyScreen();
                  },));
                },
                child: Container(
                  width: double.infinity,
                  height: 50.0.h,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Constant.LANG == Constant.EN ? ENG.CREATE_COMPANY_TITLE : IT.CREATE_COMPANY_TITLE,
                    textAlign: TextAlign.start,
                    style: gothamMedium.copyWith(
                        color: const Color(AllColors.colorText),
                        fontSize: Dimensions.FONT_L
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.black54,),
              InkWell(
                onTap: () {
                  showAlertDialog(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50.0.h,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Constant.LANG == Constant.EN ? ENG.OTHERS_LOGOUT : IT.OTHERS_LOGOUT,
                    textAlign: TextAlign.start,
                    style: gothamMedium.copyWith(
                      color: const Color(AllColors.colorText),
                      fontSize: Dimensions.FONT_L
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.black54,),
            ],
          ),
        ),
      ),
    );
  }

  // dropDown Button select company
  Widget companyDropDown(BuildContext context) {
    return Row(
      children: [
        Visibility(
          visible: true,
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: DropdownButtonHideUnderline(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: DropdownButton2<String>(
                    buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                    buttonDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(
                        color: Colors.black26,
                      ),
                      color: Colors.white,
                    ),
                    buttonElevation: 2,
                    hint: Text(
                      Constant.LANG == Constant.EN ? ENG.OTHERS_SELECT_COMPANY : IT.OTHERS_SELECT_COMPANY,
                      style: gothamRegular.copyWith(
                          fontSize: Dimensions.FONT_M.sp, color: Colors.black),
                    ),
                    iconSize: 30,
                    isExpanded: true,
                    dropdownElevation: 8,
                    dropdownMaxHeight: 300.h,
                    dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.r),
                          bottomLeft: Radius.circular(10.r),
                        )
                    ),
                    items: companyNameList.map((String cc) => DropdownMenuItem<String>(
                        value: cc,
                        child: Text(
                          cc.toString(),
                          style: gothamRegular.copyWith(
                            fontSize: Dimensions.FONT_M,
                          ),
                        ),
                      )
                    ).toList(),
                    value: selectedCompany,
                    onChanged: (value) {
                      setState(() {
                        changedCompany = value!;
                        for(int i=0; i <companyList.length; i++) {
                          if(value == companyList[i].name) {
                            currentCompanyId = companyList[i].id;
                            //userModel?.currentCompany = companyList[i];
                            //Utility.setStringSharedPreference(Constant.userObject, jsonEncode(userModel));
                            break;
                          }
                        }
                        updateCompany(currentCompanyId);
                      });
                    },
                  )
                )
              ),
            ),
          ),
        ),
        IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const EditCompanyScreen();
              },));
            },
            icon: const Icon(Icons.edit, color: Color(AllColors.colorBlue),),
        ),
      ],
    );
  }

  showAlertDialog(BuildContext context) {
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text(Constant.LANG == Constant.EN ? ENG.DO_YOU_WANT_TO_LOGOUT : IT.DO_YOU_WANT_TO_LOGOUT),
          actions: [
            TextButton(
              child: const Text(Constant.LANG == Constant.EN ? ENG.NO : IT.NO),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text(Constant.LANG == Constant.EN ? ENG.YES : IT.YES),
              onPressed: () {
                setState(() {
                Utility.clearPreference();
                });
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ), (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void updateCompany(int id) {
    setState(() {
      showLoader = true;
    });
    PutRequest request = PutRequest();
    request.getResponse(
        cmd: RequestCmd.setCompanyId,
        token: userModel!.authorization,
        body: json.encode({
          Constant.id : id
        }),
        responseCode: SET_COMPANY_DATA,
        companyId: userModel!.currentCompany?.id);
    request.setListener(this);
  }

  void getCompanyList() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.companyAll,
        token: userModel!.authorization,
        responseCode: COMPANY_DATA,
        companyId: currentCompanyId);
    request.setListener(this);
  }

  void getUpdatedCompanyList() {
    setState(() {
      showLoader = true;
    });
    GetRequest request = GetRequest();
    request.getResponse(
        cmd: RequestCmd.companyAll,
        token: userModel!.authorization,
        responseCode: GET_UPDATED_COMPANY_DATA,
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
    setState(() {
      showLoader = false;
    });
    if(responseCode == SET_COMPANY_DATA) {
      debugPrint("$TAG SET_COMPANY_DATA =======> $response");
      setState(() {
        selectedCompany = changedCompany;
        for(int i=0; i <companyList.length; i++) {
          if(changedCompany == companyList[i].name) {
            currentCompanyId = companyList[i].id;
            break;
          }
        }
        getUpdatedCompanyList();
      });
    } else if (responseCode == COMPANY_DATA) {
      setState(() {
        companyList.clear();
        for(int i=0; i<response[Constant.data].length; i++) {
          companyList.add(CurrentCompany.fromJson(response[Constant.data][i]));
          companyNameList.add(response[Constant.data][i]["name"]);
        }
        debugPrint("$TAG companyList ========> ${companyList.length}");
        debugPrint("$TAG companyNameList ========> ${companyNameList.length}");
        selectedCompany = userModel?.currentCompany?.name;
        currentCompanyId = userModel?.currentCompany?.id;
        showCompanyDropdown = true;
      });
    } else if (responseCode == GET_UPDATED_COMPANY_DATA) {
      setState(() {
        userModel?.currentCompany = CurrentCompany.fromJson(response["current_company"]);
        Utility.setStringSharedPreference(Constant.userObject, jsonEncode(userModel));
        selectedCompany = userModel?.currentCompany?.name;
        currentCompanyId = userModel?.currentCompany?.id;
      });
    }
  }
}