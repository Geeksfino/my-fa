import UIKit
import FinClipChatKit

final class TabBarController: UITabBarController {
    
    private let coordinator: ChatKitCoordinator
    
    // Keep references to view controllers to handle navigation
    private var chatNav: UINavigationController?
    private var strategiesNav: UINavigationController?
    private var assetsNav: UINavigationController?
    
    init(coordinator: ChatKitCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }
    
    private func setupTabs() {
        // 1. Chat Tab
        let drawerContainer = DrawerContainerViewController(coordinator: coordinator)
        chatNav = UINavigationController(rootViewController: drawerContainer)
        // MainChatViewController manages its own header, so we hide the nav bar for this tab
        chatNav?.setNavigationBarHidden(true, animated: false)
        chatNav?.tabBarItem = UITabBarItem(
            title: LocalizationHelper.localized("tab.chat"),
            image: UIImage(systemName: "bubble.left.and.bubble.right"),
            selectedImage: UIImage(systemName: "bubble.left.and.bubble.right.fill")
        )
        
        // 2. Strategies Tab
        let strategiesVC = StrategiesViewController()
        strategiesVC.navigationDelegate = self
        strategiesNav = UINavigationController(rootViewController: strategiesVC)
        strategiesNav?.tabBarItem = UITabBarItem(
            title: LocalizationHelper.localized("tab.strategies"),
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            selectedImage: UIImage(systemName: "chart.line.uptrend.xyaxis.fill")
        )
        
        // 3. Assets Tab
        let assetsVC = AssetsViewController()
        assetsVC.navigationDelegate = self
        assetsNav = UINavigationController(rootViewController: assetsVC)
        assetsNav?.tabBarItem = UITabBarItem(
            title: LocalizationHelper.localized("tab.assets"),
            image: UIImage(systemName: "wallet.pass"),
            selectedImage: UIImage(systemName: "wallet.pass.fill")
        )
        
        viewControllers = [chatNav!, strategiesNav!, assetsNav!]
    }
    
    private func setupAppearance() {
        // Dark theme styling to match screenshots
        tabBar.barStyle = .black
        tabBar.isTranslucent = true
        tabBar.tintColor = UIColor(red: 0.46, green: 0.42, blue: 1.00, alpha: 1.00) // Purple-ish
        tabBar.unselectedItemTintColor = .gray
        
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(white: 0.1, alpha: 1.0) // Dark background
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - ChatNavigationDelegate
extension TabBarController: ChatNavigationDelegate {
    func navigateToChat(message: String?, context: [String : Any]?) {
        // Switch to chat tab
        selectedIndex = 0
        
        // Access the DrawerContainer to create a new conversation
        guard let nav = chatNav,
              let drawerContainer = nav.viewControllers.first as? DrawerContainerViewController else {
            return
        }
        
        // Close the drawer if open
        drawerContainer.toggleDrawer(open: false)
        
        // Create a new conversation session
        drawerContainer.createNewConversation(withMessage: message, context: context)
    }
}

