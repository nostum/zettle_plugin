class ZettlePluginResponse {
  ZettlePluginResponse.fromMap(Map<dynamic, dynamic> response)
      : methodName = response['methodName'],
        success = response['success'],
        response = response['response'],
        errorMessage = response['errorMessage'];

  String methodName;
  String? errorMessage;
  bool success;
  Map<dynamic, dynamic>? response;

  @override
  String toString() {
    return 'Method: $methodName, success: $success, response: $response, errorMessage: $errorMessage';
  }
}
