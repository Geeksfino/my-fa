import UIKit
import FinClipChatKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

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
    guard url.scheme == "myfa" else { return }
    guard url.host == "trade" else { return }
    
    // Present trade confirmation
    let tradeVC = TradeConfirmationViewController(url: url)
    window?.rootViewController?.present(tradeVC, animated: true)
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
