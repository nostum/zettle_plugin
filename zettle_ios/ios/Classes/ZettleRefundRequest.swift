
/// Represents a payment refund structure.
/// This struct encapsulates the details required for initiating a refund request.
public struct RefundRequest{
    var refundAmount: Double?
    var reference: String
    var receiptNumber: String?
    
    
    /// Creates a `RefundRequest` instance from a dictionary, throwing an error if the conversion fails.
    /// - Parameter dict: A dictionary containing refund request details.
    /// - Returns: A `RefundRequest` instance initialized with the provided dictionary.
    /// - Throws: An error of type `RefundRequestError` if the conversion fails.
    static func fromDict(_ dict: [String: Any]) throws -> RefundRequest {
        guard
              let reference = dict["reference"] as? String else {
            throw RefundRequestError.invalidInput
            
        }
        
        let amount = (dict["refundAmount"] != nil) ? dict["refundAmount"] as? Double : nil;
        let receiptNumber = (dict["receiptNumber"] != nil) ? dict["receiptNumber"] as? String : nil;
        
        
        return RefundRequest(refundAmount: amount, reference: reference, receiptNumber: receiptNumber);
    }
    
    /// Converts the `RefundRequest` instance to a dictionary.
    /// - Returns: A dictionary representation of the refund request.
    func toDict() -> [String: Any?]{
       return [
           "refundAmount": refundAmount,
           "reference": reference,
           "receiptNumber": receiptNumber,
       ]
   }
}

/// An enumeration representing errors that may occur during `RefundRequest` operations.
enum RefundRequestError: Error {
    case invalidInput
}
