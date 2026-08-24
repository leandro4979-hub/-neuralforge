import Foundation

/// Utilities for redacting sensitive information.
public enum Redaction {
    /// Redacts sensitive strings by replacing them with asterisks.
    public static func redact(_ string: String) -> String {
        // Common patterns to redact
        let patterns = [
            "password",
            "token",
            "api_key",
            "apikey",
            "secret",
            "private_key",
            "auth",
            "bearer",
            "access_token",
            "refresh_token"
        ]

        var result = string
        for pattern in patterns {
            result = result.replacingOccurrences(
                of: pattern,
                with: String(repeating: "*", count: pattern.count),
                options: [.caseInsensitive, .regularExpression]
            )
        }
        return result
    }

    /// Redacts a dictionary by replacing sensitive keys and values.
    public static func redact(_ dictionary: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in dictionary {
            let redactedKey = redact(key)
            let redactedValue: Any
            switch value {
            case let string as String:
                redactedValue = redact(string)
            case let dict as [String: Any]:
                redactedValue = redact(dict)
            case let array as [Any]:
                redactedValue = redact(array)
            default:
                redactedValue = value
            }
            result[redactedKey] = redactedValue
        }
        return result
    }

    /// Redacts an array by replacing sensitive strings.
    public static func redact(_ array: [Any]) -> [Any] {
        array.map { element in
            switch element {
            case let string as String:
                return redact(string)
            case let dict as [String: Any]:
                return redact(dict)
            case let arr as [Any]:
                return redact(arr)
            default:
                return element
            }
        }
    }
}
