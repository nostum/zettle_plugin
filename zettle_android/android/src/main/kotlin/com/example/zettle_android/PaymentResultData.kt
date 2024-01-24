package com.example.zettle_android

import com.zettle.sdk.feature.cardreader.payment.Transaction
import com.zettle.sdk.feature.cardreader.payment.refunds.RefundPayload
import com.zettle.sdk.feature.cardreader.payment.refunds.CardPaymentPayload
import java.text.SimpleDateFormat
import java.util.TimeZone


// Converts [Transaction.ResultPayload] to a map containing payment result data.
//
// @return Mutable map with payment result data.
fun Transaction.ResultPayload.toPaymentResultData(): MutableMap<String, Any?> = mutableMapOf(
    "status" to "completed",
    "transactionId" to transactionId,
    "amount" to amount.toDoubleValue(),
    "gratuityAmount" to gratuityAmount,
    "cardType" to cardType,
    "cardPaymentEntryMode" to cardPaymentEntryMode,
    "cardholderVerificationMethod" to cardholderVerificationMethod,
    "tsi" to tsi,
    "tvr" to tvr,
    "applicationIdentifier" to applicationIdentifier,
    "cardIssuingBank" to cardIssuingBank,
    "maskedPan" to maskedPan,
    "panHash" to panHash,
    "applicationName" to applicationName,
    "authorizationCode" to authorizationCode,
    "installmentAmount" to installmentAmount.toString(),
    "nrOfInstallments" to nrOfInstallments.toString(),
    "mxFiid" to mxFiid,
    "mxCardType" to mxCardType,
    "reference" to reference?.id,
)


// Converts [RefundPayload] to a map containing payment result data for a refund.
//
// @return Mutable map with refund payment result data.
fun RefundPayload.toPaymentResultData(): MutableMap<String, Any?> = mutableMapOf(
    "status" to "completed",
    "originalAmount" to originalAmount.toDoubleValue(),
    "refundedAmount" to refundedAmount.toDoubleValue(),
    "cardType" to cardType,
    "maskedPan" to maskedPan,
    "cardPaymentUUID" to transactionId,
)

// Converts [CardPaymentPayload] to a map containing payment result data for a card payment.
//
// @return Mutable map with card payment result data.
fun CardPaymentPayload.toPaymentResultData(): MutableMap<String, Any?> {
    val formatter = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
    formatter.timeZone = TimeZone.getTimeZone("UTC")

    return mutableMapOf(
        "status" to "completed",
        "amount" to amount.toDoubleValue(),
        "applicationName" to applicationName,
        "cardLastDigits" to cardLastDigits,
        "cardPaymentEntryMode" to cardPaymentEntryMode,
        "cardType" to cardType,
        "currency" to "${currency}",
        "date" to formatter.format(date),
        "isRefundable" to isRefundable,
        "reference" to referenceId,
        "referenceNumber" to referenceNumber,
        "transactionId" to transactionId
    )
}