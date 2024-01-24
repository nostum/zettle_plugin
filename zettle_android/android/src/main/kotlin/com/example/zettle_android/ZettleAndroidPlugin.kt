package com.example.zettle_android

import androidx.annotation.NonNull
import androidx.lifecycle.ProcessLifecycleOwner
import android.content.Context
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.google.android.material.snackbar.Snackbar
import java.util.UUID

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.PluginRegistry
import androidx.core.app.ActivityCompat.startActivityForResult

import com.zettle.sdk.config
import com.zettle.sdk.core.auth.User
import com.zettle.sdk.ZettleSDK
import com.zettle.sdk.config
import com.zettle.sdk.ZettleSDKLifecycle
import com.zettle.sdk.features.show
import com.zettle.sdk.feature.cardreader.payment.TransactionReference
import com.zettle.sdk.feature.cardreader.payment.TippingStyle
import com.zettle.sdk.feature.cardreader.ui.CardReaderFeature
import com.zettle.sdk.feature.cardreader.ui.CardReaderAction
import com.zettle.sdk.feature.cardreader.ui.payment.CardPaymentResult
import com.zettle.sdk.feature.cardreader.ui.refunds.RefundResult
import com.zettle.sdk.feature.cardreader.ui.RetrieveResult
import com.zettle.sdk.ui.ZettleResult
import com.zettle.sdk.ui.zettleResult
import com.zettle.sdk.features.charge
import com.zettle.sdk.features.refund
import com.zettle.sdk.features.retrieve

/** ZettleAndroidPlugin */
class ZettleAndroidPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener  {
  private lateinit var channel : MethodChannel
  private lateinit var activity: Activity
  private var operations: MutableMap<String, ZettlePluginResponseWrapper> = mutableMapOf()
  private var sdkStarted: Boolean = false
  private var tippingStyle: TippingStyle = TippingStyle.None
  private var currentMethod: ZettleMethod? = null

  // Overrides the onAttachedToEngine method from FlutterPlugin to set up the MethodChannel.
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zettle_android")
    channel.setMethodCallHandler(this)
  }

  // Overrides the onAttachedToActivity method from ActivityAware to set up the current Activity.
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener(this)
  }

  // Overrides various lifecycle methods from ActivityAware.
  override fun onDetachedFromActivityForConfigChanges() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivity() {}

  // Overrides the onDetachedFromEngine method from FlutterPlugin to clean up the MethodChannel when detached from the Flutter engine.
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
  
  // Handles method calls from Flutter.
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val operation = ZettlePluginResponseWrapper(result)
    operation.response = ZettlePluginResponse(call.method)
    currentMethod = ZettleMethod.findByValue(call.method)
    operations.put(call.method, operation)

    try {
      when (currentMethod) {
        ZettleMethod.INITIALIZE -> initialize(call.arguments as Map<*, *>)
        ZettleMethod.SHOW_SETTINGS -> showSettings()
        ZettleMethod.LOGIN -> login()
        ZettleMethod.LOGOUT -> logout()
        ZettleMethod.REQUEST_PAYMENT -> requestPayment(call.arguments as Map<*, *>)
        ZettleMethod.REQUEST_REFUND -> requestRefund(call.arguments as Map<*, *>)
        ZettleMethod.RETRIEVE_PAYMENT -> retrievePayment(call.arguments as Map<*, *>)
        ZettleMethod.GET_PLATFORM_VERSION -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
        else -> sendResponse(success = false, errorMessage = "Method not implemented: ${call.method}")
      }
    } catch (e: Exception) {
      handleError(e)
    }
  }

  // Initializes the Zettle SDK with the provided configuration.
  private fun initialize(@NonNull args: Map<*, *>){
    val clientID = args.getSafe<String>("androidClientId")
    val redirectUrl = args.getSafe<String>("redirect")

    if(!sdkStarted) {
      sdkStarted = true
      val config = config(activity) {
          isDevMode = false
          auth {
              this.clientId = clientID as String
              this.redirectUrl = redirectUrl as String
          }
          logging {
              allowWhileRoaming = false
          }
          addFeature(CardReaderFeature)
      }

      val sdk = ZettleSDK.configure(config)
      ProcessLifecycleOwner.get().lifecycle.addObserver(ZettleSDKLifecycle())
      sdk.start()
    }
    sendResponse(response = mutableMapOf("initialized" to true))
  }

  // Starts the Zettle SDK settings activity.
  // This method is called when the SHOW_SETTINGS method is invoked.
  private fun showSettings() {
    val intent = Intent(activity, CustomSettingsActivity::class.java)
    activity.startActivity(intent)
    sendResponse()
  }


  // Initiates the login process
  // This method is called when the LOGIN method is invoked.
  private fun login() {
    ZettleSDK.instance?.login(activity)
    sendResponse()
  }

  // Logs out the user.
  // This method is called when the LOGOUT method is invoked.
  private fun logout() {
    ZettleSDK.instance?.logout()
    sendResponse()    
  }

  // Initiates a request for a payment.
  // This method is called when the REQUEST_PAYMENT method is invoked.
  private fun requestPayment(@NonNull args: Map<*, *>) {
    val amount = args.getSafe<Double>("amount")
    val enableTipping = args.getSafe<Boolean>("enableTipping")
    val enableInstallments = args.getSafe<Boolean>("enableInstalments")
    val internalUniqueTraceId = args.getSafe<String>("reference")
    val reference = TransactionReference.Builder(internalUniqueTraceId as String).build()


     val intent: Intent = CardReaderAction.Payment(
        reference = reference,
        amount = amount?.toLongValue() ?: 0,
        tippingStyle = tippingStyle,
        enableInstallments = enableInstallments as Boolean
      ).charge(activity)

    activity.startActivityForResult(intent, ZettleMethod.REQUEST_PAYMENT.code)
  }

  // Initiates a request for a refund
  // This method is called when the REQUEST_REFUND method is invoked.
  private fun requestRefund(@NonNull args: Map<*, *>) {
    val refundAmount = args.getSafe<Double>("refundAmount")
    val taxAmount = args.getSafe<Double>("taxAmount")
    val reference = args.getSafe<String>("reference")
    val receiptNumber = args.getSafe<String>("reference")
    val refundReference = TransactionReference.Builder(UUID.randomUUID().toString()).build()

    val intent: Intent = CardReaderAction.Refund(
      amount = refundAmount?.toLongValue() ?: 0,
      paymentReferenceId = reference as String,
      refundReference = refundReference,
      taxAmount = taxAmount?.toLong(),
      receiptNumber = receiptNumber
    ).refund(activity)

    activity.startActivityForResult(intent, ZettleMethod.REQUEST_REFUND.code)
  }

  // Retrieves information about a previous payment.
  // This method is called when the RETRIEVE_PAYMENT method is invoked.
  private fun retrievePayment(@NonNull args: Map<*, *>){
    val reference = args.getSafe<String>("reference")

    CardReaderAction.Transaction(reference as String).retrieve {
      when (it) {
        is ZettleResult.Completed<*> -> {
            val transaction: RetrieveResult.Completed = CardReaderAction.fromRetrieveTransactionResult(it)
            sendResponse(response = transaction.payload.toPaymentResultData())
        }
        is ZettleResult.Cancelled -> {
          sendResponse(response = mutableMapOf("status" to "canceled"))
        }
        is ZettleResult.Failed -> {
          sendResponse(response = mutableMapOf("status" to "failed","reason" to "${it.reason}" ))
        } else -> {
          sendResponse(response = mutableMapOf("status" to "failed"))
        }        
      }
    }
  }

  // Handles activity results.
  // Overrides the onActivityResult method to handle activity results.
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    when (requestCode) {
      ZettleMethod.REQUEST_PAYMENT.code -> handlePaymentResult(data)
      ZettleMethod.REQUEST_REFUND.code -> handleRefundResult(data)
      else -> {}
    }
    return true
  }

  //  Handles the result of a payment operation and sends the appropriate response to Flutter.
  //  @param data Payment result data.
  private fun handlePaymentResult(data: Intent?) {
    when(val result = data?.zettleResult()) {
      is ZettleResult.Completed<*> -> {
        val payment: CardPaymentResult.Completed = CardReaderAction.fromPaymentResult(result)
        sendResponse(response = payment.payload.toPaymentResultData())
      }
      is ZettleResult.Cancelled -> {
        sendResponse(response = mutableMapOf("status" to "canceled"))
      }
      is ZettleResult.Failed -> {
        sendResponse(response = mutableMapOf("status" to "failed"))
      } else -> {}
    }
  }

  // Handles the result of a refund operation and sends the appropriate response to Flutter.
  //
  // @param data Refund result data.
  private fun handleRefundResult(data: Intent?) {
    when(val result = data?.zettleResult()) {
      is ZettleResult.Completed<*> -> {
        val refund : RefundResult.Completed = CardReaderAction.fromRefundResult(result)
        sendResponse(response = refund.payload.toPaymentResultData())
      }
      is ZettleResult.Cancelled -> {
        sendResponse(response = mutableMapOf("status" to "canceled"))
      }
      is ZettleResult.Failed -> {
        sendResponse(response = mutableMapOf("status" to "failed","reason" to "${result.reason}" ))
      } else -> {
        sendResponse(response = mutableMapOf("status" to "failed"))
      }    
    }
  }

  
  // Gets the current operation based on the current method.
  private fun currentOperation(): ZettlePluginResponseWrapper? {
    return operations[currentMethod?.value]
  }

  
  //  Sends a response to Flutter.
  //
  //  @param success Indicates if the operation was successful.
  //  @param response Response data.
  //  @param errorMessage Error message in case of failure.
  private fun sendResponse(
    success: Boolean = true,
    response: MutableMap<String, Any?> = mutableMapOf(),
    errorMessage: String? = null
  ) {
    currentOperation()?.let {
        it.response.success = success
        it.response.errorMessage = errorMessage
        it.response.response = response
        it.flutterResult()
    }
  }
 
  // Handles errors and sends an error response to Flutter.
  //
  // @param exception The exception that occurred.
  private fun handleError(exception: Exception) {
    sendResponse(errorMessage = exception.message, success = false)
  }
}