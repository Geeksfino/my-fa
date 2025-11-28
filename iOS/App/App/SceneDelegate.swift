import UIKit
import FinClipChatKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private var lastTradeRequestTime: Date?
  private let tradeRequestCooldown: TimeInterval = 2.0 // 2 seconds between trades

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let window = UIWindow(windowScene: windowScene)
    
    // Initialize ChatKitCoordinator
    let config = NeuronKitConfig.default(serverURL: AppConfig.defaultServerURL)
        .withUserId(AppConfig.defaultUserId)
    let coordinator = ChatKitCoordinator(config: config)
    
    // Set TabBarController as root
    let tabBarController = TabBarController(coordinator: coordinator)
    window.rootViewController = tabBarController
    window.makeKeyAndVisible()

    self.window = window
    
    // Show disclaimer on first run
    if !UserDefaults.standard.bool(forKey: "HasSeenDisclaimer") {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let disclaimer = DisclaimerViewController()
            disclaimer.modalPresentationStyle = .fullScreen
            tabBarController.present(disclaimer, animated: true)
        }
    }
    
    // Handle URL if app launched via URL
    if let urlContext = connectionOptions.urlContexts.first {
        handleURL(urlContext.url)
    }
  }
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    handleURL(url)
  }
  
  private func handleURL(_ url: URL) {
    // Basic validation
    guard url.scheme == "myfa" else {
      print("Invalid URL scheme: \(url.scheme ?? "none")")
      return
    }
    
    guard url.host == "trade" else {
      print("Invalid URL host: \(url.host ?? "none")")
      return
    }
    
    // Rate limiting
    if let lastTime = lastTradeRequestTime {
      let timeSinceLastRequest = Date().timeIntervalSince(lastTime)
      if timeSinceLastRequest < tradeRequestCooldown {
        presentError(
          title: LocalizationHelper.localized("error.trade.too.fast.title"),
          message: LocalizationHelper.localized("error.trade.too.fast.message")
        )
        return
      }
    }
    
    // Validate URL parameters
    guard validateTradeURL(url) else {
      presentError(
        title: LocalizationHelper.localized("error.trade.invalid.title"),
        message: LocalizationHelper.localized("error.trade.invalid.message")
      )
      return
    }
    
    // Update rate limit
    lastTradeRequestTime = Date()
    
    // Present trade confirmation
    let tradeVC = TradeConfirmationViewController(url: url)
    window?.rootViewController?.present(tradeVC, animated: true)
  }
  
  private func validateTradeURL(_ url: URL) -> Bool {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems else {
      return false
    }
    
    // Validate required parameters
    guard let assetId = queryItems.first(where: { $0.name == "assetId" })?.value,
          !assetId.isEmpty else {
      return false
    }
    
    guard let symbol = queryItems.first(where: { $0.name == "symbol" })?.value,
          !symbol.isEmpty else {
      return false
    }
    
    guard let typeString = queryItems.first(where: { $0.name == "type" })?.value,
          ["buy", "sell"].contains(typeString) else {
      return false
    }
    
    guard let quantityString = queryItems.first(where: { $0.name == "quantity" })?.value,
          let quantity = Double(quantityString),
          quantity > 0,
          quantity < 1000000 else { // Reasonable limit
      return false
    }
    
    return true
  }
  
  private func presentError(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: LocalizationHelper.localized("app.ok"), style: .default))
    window?.rootViewController?.present(alert, animated: true)
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
  }
}