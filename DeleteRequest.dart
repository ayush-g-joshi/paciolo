import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../util/Constants.dart';
import '../util/Utility.dart';
import 'ResponseListener.dart';

class DeleteRequest {
  String TAG = "DeleteRequest";
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

    debugPrint("${Utility.getDateTime()} $TAG url ==========> $url");
    debugPrint("${Utility.getDateTime()} $TAG body ==========> $body");
    debugPrint("${Utility.getDateTime()} $TAG headers ==========> $headers");
    final response = await http.delete(Uri.parse(url), headers: headers, body: body);
    try {
      debugPrint("${Utility.getDateTime()} $TAG Response headers ==========> ${response.headers}");
      debugPrint("${Utility.getDateTime()} $TAG Response statusCode ==========> ${response.statusCode}");
      debugPrint("${Utility.getDateTime()} $TAG Response body ==========> ${response.body}");
      if (jsonDecode(response.body)[Constant.STATUS]) {
        mListener.onSuccess(jsonDecode(response.body), responseCode);
      } else {
        mListener.onFailed(jsonDecode(response.body), response.statusCode);
      }
    } on FormatException catch (e) {
      debugPrint("${Utility.getDateTime()} $TAG Exception ==========> ${e.message}");
      mListener.onFailed(jsonDecode(response.body), response.statusCode);
    } on SocketException catch (e) {
      debugPrint("${Utility.getDateTime()} $TAG Exception ==========> ${e.message}");
      mListener.onFailed(jsonDecode(response.body), response.statusCode);
    } on HandshakeException catch (e) {
      debugPrint("${Utility.getDateTime()} $TAG Exception ==========> ${e.toString()}");
      mListener.onFailed(jsonDecode(response.body), response.statusCode);
    } on Exception catch (e) {
      debugPrint("${Utility.getDateTime()} $TAG Exception ==========> ${e.toString()}");
      mListener.onFailed(jsonDecode(response.body), response.statusCode);
    }
  }

  void setListener(ResponseListener listener) {
    mListener = listener;
  }
}