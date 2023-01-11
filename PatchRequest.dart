import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:paciolo/util/Constants.dart';

import '../util/Utility.dart';
import 'ResponseListener.dart';

class PatchRequest {
  String TAG = "PatchRequest";
  late ResponseListener mListener;

  Future<void> getResponse({Key? key,
    required String cmd,
    required var token,
    required var body,
    var responseCode,
    var customHeader}) async {
    String url = Constant.SERVER_URL + cmd;
    String basicAuth = 'Bearer $token';
    Map<String, String> headers;
    if(customHeader != null) {
      headers = {
        "content-type": 'application/json',
        'Origin': Constant.ORIGIN_URL,
        'Authorization': basicAuth,
        'mobile-x-app': '1',
        'Company': customHeader,
      };
    } else {
      headers = {
        "content-type": 'application/json',
        'Origin': Constant.ORIGIN_URL,
        'mobile-x-app': '1',
        'Authorization': basicAuth,
      };
    }

    debugPrint("${Utility.getDateTime()} $TAG url ==========> $url");
    debugPrint("${Utility.getDateTime()} $TAG basicAuth ==========> $basicAuth");
    debugPrint("${Utility.getDateTime()} $TAG body ==========> $body");

    final response = await http.patch(Uri.parse(url), headers: headers, body: body);
    try {
      debugPrint("${Utility.getDateTime()} $TAG response headers ==========> ${response.headers}");
      debugPrint("${Utility.getDateTime()} $TAG response statusCode ==========> ${response.statusCode}");
      debugPrint("${Utility.getDateTime()} $TAG response body ==========> ${response.body}");
      if (jsonDecode(response.body)[Constant.STATUS]) {
        mListener.onSuccess(jsonDecode(response.body), responseCode);
      } else {
        mListener.onFailed(jsonDecode(response.body), response.statusCode);
      }
    } on FormatException catch (e) {
      debugPrint("${Utility.getDateTime()} $TAG Exception =========> ${e.message}");
      mListener.onFailed(jsonDecode(response.body), response.statusCode);
    } on SocketException catch (e) {
      debugPrint("${Utility.getDateTime()} $TAG Exception =========> ${e.message}");
      mListener.onFailed(jsonDecode(response.body), response.statusCode);
    } on HandshakeException catch (e) {
      debugPrint("${Utility.getDateTime()} $TAG Exception ==========> ${e.toString()}");
      mListener.onFailed(jsonDecode(response.body), response.statusCode);
    } on Exception catch (e) {
      debugPrint("${Utility.getDateTime()} $TAG Exception =========> ${e.toString()}");
      mListener.onFailed(jsonDecode(response.body), response.statusCode);
    }
  }

  void setListener(ResponseListener listener) {
    mListener = listener;
  }
}