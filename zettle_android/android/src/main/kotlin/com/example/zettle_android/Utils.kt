package com.example.zettle_android

import io.flutter.plugin.common.MethodChannel.Result
import androidx.annotation.NonNull

// Enum class representing different Zettle methods
enum class ZettleMethod(val value: String, val code: Int) {
  INITIALIZE("initialize", 0),
  SHOW_SETTINGS("showSettings", 1),
  LOGIN("login", 2),
  LOGOUT("logout", 3),
  REQUEST_PAYMENT("requestPayment", 4),
  REQUEST_REFUND("requestRefund", 5),
  RETRIEVE_PAYMENT("retrievePayment", 6),
  GET_PLATFORM_VERSION("getPlatformVersion", 7);

  companion object {
    fun findByCode(value: Int) = values().find { it.code == value }
    fun findByValue(value: String) = values().find { it.value == value }
  }
}

// Wrapper class for Zettle plugin responses
class ZettlePluginResponseWrapper(@NonNull var methodResult: Result) {
  lateinit var response: ZettlePluginResponse
  fun flutterResult() {
    methodResult.success(response.toMap())
  }
}

// Class representing Zettle plugin response
class ZettlePluginResponse(@NonNull var methodName: String) {
  var success: Boolean = false
  var errorMessage: String? = null
  var response: MutableMap<String, Any?> = mutableMapOf()
  fun toMap(): Map<String, Any?> {
    return mapOf(
      "methodName" to methodName,
      "success" to success,
      "response" to response,
      "errorMessage" to errorMessage
    )
  }
}

// Extension function for safer retrieval of values from a map
inline fun <reified T> Map<*, *>.getSafe(key: String): T? {
    return this[key] as? T
}

// Extension function to convert a currency value represented as Double to Long.
// The Zettle SDK represents currency amounts in Long values where $1.0 equals 100.
//
// @return Converted Long value.
fun Double.toLongValue(): Long = (this * 100).toLong()

// Extension function to convert a currency value represented as Long to Double.
//
// @return Converted Double value.
fun Long.toDoubleValue(): Double = (this.toDouble() / 100)

