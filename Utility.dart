import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {

  static String TAG = "Utility";

  // shared preference starts here
  static Future<void> setStringSharedPreference(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<void> setIntSharedPreference(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  static Future<void> setBoolSharedPreference(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static Future<String?> getStringSharedPreference(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<int?> getIntSharedPreference(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<bool?> getBoolSharedPreference(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> removePreference(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static Future<void> clearPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
  // shared preference end here

  // you have to add "fluttertoast" library to used this function
  // flutter toast starts here
  static void showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green.shade500,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showWarningToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.yellow.shade500,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
  // flutter toast end here

  // check internet connection
  static Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  // check valid email
  static bool emailValidation(var email) {
    var valid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return valid.hasMatch(email);
  }

  // date format from . to /
  static String formatDate(String dateToFormat) {
    var formatted = DateFormat("dd.MM.yyyy").parse(dateToFormat).toString();
    DateTime date = DateTime.parse(formatted);
    return DateFormat("dd/MM/yyyy").format(date).toString();
  }

  static String formatInvoiceDocInfoDate(String dateToFormat) {
    // 2022-08-23T22:00:00.000Z
    var formatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(dateToFormat).toString();
    debugPrint("$TAG Format Invoice Doc Info Date formatted ======> $formatted");
    DateTime date = DateTime.parse(formatted);
    var finalDate = DateFormat("dd/MM/yyyy").format(date).toString();

    debugPrint("$TAG date =====> $date");
    debugPrint("$TAG final date =====> $finalDate");

    return DateFormat("dd/MM/yyyy").format(date).toString();
  }

  static String getFormattedDate() {
    var formatted = DateFormat("dd/MM/yyyy").format(DateTime.now()).toString();
    return formatted;
  }

  static String getFormattedDateFromDateTime(DateTime dateTime) {
    var formatted = DateFormat("dd/MM/yyyy").format(dateTime).toString();
    return formatted;
  }

  static DateTime getDateTimeFromStringDate(String dateToConvert) {
    DateTime dateTime = DateFormat("dd/MM/yyyy").parse(dateToConvert);
    debugPrint("$TAG getDateTimeFromStringDate day =====> ${dateTime.day}");
    debugPrint("$TAG getDateTimeFromStringDate month =====> ${dateTime.month}");
    debugPrint("$TAG getDateTimeFromStringDate year =====> ${dateTime.year}");
    return dateTime;
  }


  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    int diff = (from.difference(to).inHours / 24).round();
    debugPrint("$TAG daysBetween diff ======> $diff");
    return (from.difference(to).inHours / 24).round();
  }

  static String getDateTime() {
    // 2022-08-23T22:00:00.000Z
    var formatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(DateTime.now()).toString();
    return formatted;
  }

}