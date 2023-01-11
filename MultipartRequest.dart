import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../util/Constants.dart';
import 'ResponseListener.dart';

class MultipartRequest {

  String TAG = "MultipartRequest";
  late ResponseListener mListener;

  Future<void> getResponse(
      {Key? key,
        required String cmd,
        required var token,
        var body,
        var responseCode,
        var companyId}) async {
    String url = Constant.SERVER_URL + cmd;
    String basicAuth = 'Bearer $token';
    Map<String, String> headers;
    if (companyId != null) {
      headers = {
        "content-type": 'multipart/form-data;',
        'Origin': Constant.ORIGIN_URL,
        'Authorization': basicAuth,
        'mobile-x-app': '1',
        'Company': companyId.toString(),
      };
    } else {
      headers = {
        "content-type": 'multipart/form-data',
        'Origin': Constant.ORIGIN_URL,
        'mobile-x-app': '1',
        'Authorization': basicAuth,
      };
    }

    debugPrint("post postRequest url ==========> $url");
    debugPrint("post postRequest body ==========> $body");
    debugPrint("post postRequest headers ==========> $headers");

    var request =  http.MultipartRequest("POST", Uri.parse(url));
    request.headers.addAll(headers);
    request.fields.addAll(body);
    var response = await request.send();

    var finalResponse = await http.Response.fromStream(response);
    debugPrint("post postResponse headers ==========> ${finalResponse.headers}");
    debugPrint("post postResponse statusCode ==========> ${finalResponse.statusCode}");
    debugPrint("post postResponse body ==========> ${finalResponse.body}");
    try {

      if (jsonDecode(finalResponse.body)[Constant.STATUS]) {
        mListener.onSuccess(jsonDecode(finalResponse.body), responseCode);
      } else {
        mListener.onFailed(jsonDecode(finalResponse.body), response.statusCode);
      }
    } on FormatException catch (e) {
      debugPrint("$TAG Exception ${e.message}");
      mListener.onFailed(jsonDecode(finalResponse.body), finalResponse.statusCode);
    } on SocketException catch (e) {
      debugPrint("$TAG Exception ${e.message}");
      mListener.onFailed(jsonDecode(finalResponse.body), response.statusCode);
    } on Exception catch (e) {
      debugPrint("$TAG Exception ${e.toString()}");
      mListener.onFailed(jsonDecode(finalResponse.body), response.statusCode);
    }
  }

  void setListener(ResponseListener listener) {
    mListener = listener;
  }

}