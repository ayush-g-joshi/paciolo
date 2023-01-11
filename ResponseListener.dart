
abstract class ResponseListener {
  void onSuccess(var response, var responseCode);
  void onFailed(var response, var statusCode);
}