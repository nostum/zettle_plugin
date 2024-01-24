

/// Represents the general plugin response structure.
public struct ZettlePluginResponse {
    var methodName: String
    var success: Bool
    var response: [String: Any?]?
    var errorMessage: String?
    
    
    /// Converts the `ZettlePluginResponse` instance to a dictionary.
    /// - Returns: A dictionary representation of the plugin response.
    func toDict() -> [String: Any?]{
        return [
            "methodName": methodName,
            "success": success,
            "response": response,
            "errorMessage": errorMessage
        ]
    }
}
