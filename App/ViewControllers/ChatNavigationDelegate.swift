import UIKit

/// Protocol for handling navigation to the chat tab with specific context
protocol ChatNavigationDelegate: AnyObject {
    /// Switch to the chat tab and optionally start a specific conversation or action
    /// - Parameters:
    ///   - message: Initial message to send (optional)
    ///   - context: Context data dictionary (optional)
    func navigateToChat(message: String?, context: [String: Any]?)
}

