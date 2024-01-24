

/// Represents a payment request structure.
/// This struct encapsulates the details required for initiating a payment request.
public struct PaymentRequest{
    var amount: Double
    var reference: String
    var enableTipping: Bool = true
    var enableInstalments: Bool = true
    
    /// Creates a `PaymentRequest` instance from a dictionary, throwing an error if the conversion fails.
    /// - Parameter dict: A dictionary containing payment request details.
    /// - Returns: A `PaymentRequest` instance initialized with the provided dictionary.
    /// - Throws: An error of type `PaymentRequestError` if the conversion fails.
    static func fromDict(_ dict: [String: Any]) throws -> PaymentRequest {
        guard let amount = dict["amount"] as? Double,
              let reference = dict["reference"] as? String else {
                throw PaymentRequestError.invalidInput
        }
        let enableTipping = dict["enableTipping"] as? Bool ?? true
        let enableInstalments = dict["enableInstalments"] as? Bool ?? true
        
        return PaymentRequest(amount: amount, reference: reference, enableTipping: enableTipping, enableInstalments: enableInstalments)
    }
    
    /// Converts the `PaymentRequest` instance to a dictionary.
    /// - Returns: A dictionary representation of the payment request.
     func toDict() -> [String: Any?]{
        return [
            "amount": amount,
            "reference": reference,
            "enableTipping": enableTipping,
            "enableInstalments": enableInstalments
        
        ]
    }
}

/// An enumeration representing errors that may occur during `PaymentRequest` operations.
enum PaymentRequestError: Error {
    case invalidInput
}

