import iZettleSDK



/// A service for handling zettle payment-related operations.
public struct PaymentService{
    
    var viewController: UIViewController;
    
    
    
    //    * =========================== SERVICE ACTIONS  =============================== * //
    /// Retrieve payment information within a reference
    /// - Parameters:
    ///   - paymentReference: A dictionary containing the payment "reference" .
    ///   - completion: A closure to be called upon completion of the payment retrieval.
    ///                 The closure takes a dictionary parameter, which include payment-related information.
    public func retrievePayment(paymentReference: Dictionary<String, Any>, completion: @escaping ([String: Any?]) -> Void){
        
        // Validate payment reference
        guard let reference = paymentReference["reference"] as? String else {
            completion(self.paymentErrorResponse())
            return
        }
            
        // Get payment info
        retrievePaymentInfo(paymentReference: reference) { result in
            switch result {
                case .success(let payment):
                    print("Payment information retrieved correctly")
                    completion(self.paymentSuccessResponse(payment: payment!, referenceId: reference, convertAmount: true))
                case .failure(let error):
                    print("Payment failed with error: \(error)")
                completion(self.paymentErrorResponse(errorMessage: error.localizedDescription))
            }
        }
    }
    
    
    private func retrievePaymentInfo(paymentReference: String, completion: @escaping (Result<iZettleSDKPaymentInfo?, Error>) ->  Void) {
        
        iZettleSDK.shared().retrievePaymentInfo(for: paymentReference, presentFrom: viewController) { payment, error in
                        if let error = error {
                            completion(.failure(error))
                        }else{
                            completion(.success(payment))
                        }
        }
        
    }
    
    
    /// Request to create a payment
    /// - Parameters:
    ///   - requestPayment: A dictionary containing payment request details.
    ///   - completion: A closure to be called upon completion of the payment creation.
    ///                 The closure takes a dictionary parameter, which include payment-related information.
    public func requestPayment(requestPayment: Dictionary<String, Any>, completion: @escaping ([String:Any?]) -> Void) {
        
        // Validate request payment
        let args = (try? PaymentRequest.fromDict(requestPayment)) ?? nil
        if(args == nil){return completion(self.paymentErrorResponse(errorMessage: "Invalid parameters"))}
        
        // Create payment
        charge(requestPayment: args! ) { result in
            switch result {
            case .success(let payment):
                print("Payment successful")
                completion(self.paymentSuccessResponse(payment: payment!, referenceId: args!.reference))

            case .failure(let error):
                print("Payment failed with error: \(error)")
                completion(self.paymentErrorResponse(errorMessage: error.localizedDescription))
                
                
            }
        }
    }
    
    private func charge(requestPayment: PaymentRequest, completion: @escaping (Result<iZettleSDKPaymentInfo?, Error>) -> Void ){
        let amount = NSDecimalNumber(value: requestPayment.amount)
        iZettleSDK.shared().charge(amount: amount, enableTipping: requestPayment.enableTipping, reference: requestPayment.reference, presentFrom: viewController) { payment, error in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.success(payment))
            }
        }
    }
    
    /// Request to create a payment refund
    /// - Parameters:
    ///   - requestRefund: A dictionary containing payment refund details.
    ///   - completion: A closure to be called upon completion of the refund process.
    ///                 The closure takes a dictionary parameter, which include payment-related information.
    public func refundPayment(requestRefund: Dictionary<String, Any>, completion: @escaping ([String: Any?]) -> Void){
        // Validate request payment
        let args = (try? RefundRequest.fromDict(requestRefund)) ?? nil
        if(args == nil){return completion(self.paymentErrorResponse())}
        
        refund(requestRefund: args!) { result in
            switch result {
            case .success(let payment):
                print("Refund successful")
                completion(self.paymentSuccessResponse(payment: payment!, referenceId: args!.reference));
            case .failure(let error):
                print("Refund Payment failed with error: \(error)")
                completion(self.paymentErrorResponse(errorMessage: error.localizedDescription))
            }
        }
        
    }
    
    private func refund(requestRefund: RefundRequest, completion: @escaping (Result<iZettleSDKPaymentInfo?, Error>) -> Void ){
        let amount = (requestRefund.refundAmount != nil) ? NSDecimalNumber(value: requestRefund.refundAmount!) : nil
        
        
        iZettleSDK.shared().refund(amount: amount, ofPayment: requestRefund.reference, withRefundReference: requestRefund.receiptNumber, presentFrom: viewController) { payment, error in
            if let error = error {
                completion(.failure(error))
            }else{
                completion(.success(payment))
            }
        }
        
    }
    
    //    * =========================== SERVICE RESPONSES  =============================== * //
    
    /// Generates a default payment error response.
    /// - Returns: A dictionary containing information about the payment error response.
    private func paymentErrorResponse(errorMessage: String? = nil) -> [String: Any?]{
        return [
            "status" : "failed",
            "reason": errorMessage
        ]
    }
    
    /// Generates a payment success response.
    /// - Parameters:
    ///   - payment: An `iZettleSDKPaymentInfo` object containing details about the successful payment.
    ///   - referenceId: A string representing a reference ID associated with the payment.
    /// - Returns: A dictionary containing information about the successful payment response.
    private func paymentSuccessResponse(payment: iZettleSDKPaymentInfo, referenceId: String, convertAmount: Bool? = false) -> [String: Any?]{
        let paymentDictionary = payment.dictionary;
        
        
        
        return [
            "status": "completed",
            "amount": convertAmount ?? false ? payment.amount.doubleValue/100 : payment.amount.doubleValue,
            "gratuityAmount": payment.gratuityAmount,
            "cardType": paymentDictionary["cardType"] ?? payment.cardBrand,
            "cardPaymentEntryMode": paymentDictionary["cardPaymentEntryMode"] ?? payment.entryMode,
            "cardholderVerificationMethod": nil,
            "tsi": payment.tsi,
            "tvr": payment.tvr,
            "applicationIdentifier": paymentDictionary["applicationIdentifier"] ?? payment.aid,
            "cardIssuingBank": nil,
            "maskedPan": payment.obfuscatedPan,
            "panHash": paymentDictionary["cardHash"] ?? payment.panHash,
            "applicationName": payment.applicationName,
            "authorizationCode": payment.authorizationCode,
            "installmentAmount": payment.installmentAmount,
            "nrOfInstallments": payment.numberOfInstallments,
            "mxFiid": payment.mxFIID,
            "mxCardType": payment.mxCardType,
            "reference": referenceId,
            
        ]
    }
    
}
