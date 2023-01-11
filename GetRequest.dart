import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:paciolo/network/ResponseListener.dart';
import 'package:paciolo/util/Constants.dart';

import '../util/Utility.dart';

class GetRequest {
  String TAG = "GetRequest";
  late ResponseListener mListener;

  Future<void> getResponse(
      {Key? key,
      required String cmd,
      required var token,
      var responseCode,
      var companyId}) async {
    String url = Constant.SERVER_URL + cmd;
    String basicAuth = 'Bearer $token';
    Map<String, String> headers;
    if (companyId != null) {
      headers = {
        "content-type": 'application/json',
        'Origin': Constant.ORIGIN_URL,
        'Authorization': basicAuth,
        'mobile-x-app': '1',
        'Company': companyId.toString(),
      };
    } else {
      headers = {
        "content-type": 'application/json',
        'Origin': Constant.ORIGIN_URL,
        'mobile-x-app': '1',
        'Authorization': basicAuth,
      };
    }

    debugPrint("${Utility.getDateTime()} $TAG body ==========> $url");
    debugPrint("${Utility.getDateTime()} $TAG headers ==========> $headers");
    final response = await http.get(Uri.parse(url), headers: headers);
    try {
      debugPrint("${Utility.getDateTime()} $TAG response statusCode ==========> ${response.statusCode}");
      debugPrint("${Utility.getDateTime()} $TAG response body ==========> ${response.body}");
      if (jsonDecode(response.body)["success"]) {
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
