# Quick Fix Guide - Critical Issues

This guide provides ready-to-use code fixes for the critical Apple App Store compliance issues.

---

## Fix #1: Replace Hardcoded Localhost URL

### Current Code (App/App/AppConfig.swift):
```swift
struct AppConfig {
  static let defaultAgentId = UUID(uuidString: "E1E72B3D-845D-4F5D-B6CA-5550F2643E6B")!
  static let defaultServerURL = URL(string: "http://127.0.0.1:3000/agent")!
  static let defaultAgentName = "My Agent"
  static let defaultUserId = "demo-user"
}
```

### Option A: Use Build Configuration (Recommended)
```swift
struct AppConfig {
  static let defaultAgentId = UUID(uuidString: "E1E72B3D-845D-4F5D-B6CA-5550F2643E6B")!
  
  static var defaultServerURL: URL {
    #if DEBUG
    return URL(string: "http://127.0.0.1:3000/agent")!
    #else
    return URL(string: "https://your-production-api.example.com/agent")!
    #endif
  }
  
  static let defaultAgentName = "My Agent"
  static let defaultUserId = "demo-user"
}
```

### Option B: Use Environment Variables
```swift
struct AppConfig {
  static let defaultAgentId = UUID(uuidString: "E1E72B3D-845D-4F5D-B6CA-5550F2643E6B")!
  
  static var defaultServerURL: URL {
    // Check for environment override first
    if let urlString = ProcessInfo.processInfo.environment["SERVER_URL"],
       let url = URL(string: urlString) {
      return url
    }
    
    // Fall back to default based on build configuration
    #if DEBUG
    return URL(string: "http://127.0.0.1:3000/agent")!
    #else
    guard let url = URL(string: "https://your-production-api.example.com/agent") else {
      fatalError("Invalid production server URL")
    }
    return url
    #endif
  }
  
  static let defaultAgentName = "My Agent"
  static let defaultUserId = "demo-user"
}
```

### Option C: Use Configuration File (Most Flexible)
1. Create `Config.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>ServerURL</key>
    <string>https://your-production-api.example.com/agent</string>
    <key>AgentId</key>
    <string>E1E72B3D-845D-4F5D-B6CA-5550F2643E6B</string>
</dict>
</plist>
```

2. Update AppConfig.swift:
```swift
struct AppConfig {
  private static let config: [String: Any] = {
    guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
          let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
      return [:]
    }
    return dict
  }()
  
  static var defaultAgentId: UUID {
    guard let idString = config["AgentId"] as? String,
          let uuid = UUID(uuidString: idString) else {
      return UUID(uuidString: "E1E72B3D-845D-4F5D-B6CA-5550F2643E6B")!
    }
    return uuid
  }
  
  static var defaultServerURL: URL {
    guard let urlString = config["ServerURL"] as? String,
          let url = URL(string: urlString) else {
      #if DEBUG
      return URL(string: "http://127.0.0.1:3000/agent")!
      #else
      fatalError("No valid server URL configured")
      #endif
    }
    return url
  }
  
  static let defaultAgentName = "My Agent"
  static let defaultUserId = "demo-user"
}
```

---

## Fix #2: Add App Transport Security Exception

### Add to App/App/Info.plist (before final `</dict>`):

**For Development Builds Only:**
```xml
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
      <key>localhost</key>
      <dict>
        <key>NSExceptionAllowsInsecureHTTPLoads</key>
        <true/>
      </dict>
    </dict>
  </dict>
```

**⚠️ IMPORTANT:** For production builds, remove this or use separate Info.plist files per configuration.

To use separate Info.plist files:
1. Create `Info-Debug.plist` (with ATS exception)
2. Create `Info-Release.plist` (without ATS exception)
3. Update project.yml to use different plists per configuration

---

## Fix #3: Update Privacy Descriptions

### Replace in App/App/Info.plist:

**Old:**
```xml
<key>NSCalendarsUsageDescription</key>
<string>Calendar access lets us suggest upcoming events in chat.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access lets us share your current location in chat.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is needed for press-to-talk conversations.</string>
```

**New:**
```xml
<key>NSCalendarsUsageDescription</key>
<string>MyFA Demo accesses your calendar to help you discuss upcoming events with your AI financial assistant. Calendar event information is sent to our chat service to provide context-aware recommendations. Your calendar data is only used during active conversations and is not stored permanently. This is a demonstration app for showcasing AI chat capabilities.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>MyFA Demo accesses your location to provide location-based context in chat conversations with your AI financial assistant. Your location is only shared when you explicitly choose to attach it to a message. Location data is sent to our chat service for the duration of the conversation and is not stored permanently. This is a demonstration app for showcasing AI chat capabilities.</string>

<!-- ONLY include if microphone is actually used, otherwise DELETE this entire block -->
<key>NSMicrophoneUsageDescription</key>
<string>MyFA Demo uses your microphone for voice conversations with your AI financial assistant. Voice data is processed in real-time by our chat service and is not recorded or stored. This is a demonstration app for showcasing AI chat capabilities.</string>
```

**Action Required:** 
- Review the code to confirm if microphone is actually used
- If NOT used, DELETE the NSMicrophoneUsageDescription key entirely
- If it is used, ensure the description accurately reflects the implementation

---

## Fix #4: Add Trading Simulation Disclaimers

### A. Update App Display Name

**In project.yml:**
```yaml
INFOPLIST_KEY_CFBundleDisplayName: MyFA Demo
```

Or directly in Info.plist:
```xml
<key>CFBundleDisplayName</key>
<string>MyFA Demo</string>
```

### B. Add Disclaimer to Trade Confirmation Screen

**In App/ViewControllers/TradeConfirmationViewController.swift:**

Add this to the `setupUI()` method, after the card is created:

```swift
private func setupUI() {
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    
    let card = UIView()
    card.backgroundColor = .secondarySystemGroupedBackground
    card.layer.cornerRadius = 16
    card.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(card)
    
    // ADD THIS DISCLAIMER BANNER
    let disclaimerBanner = UIView()
    disclaimerBanner.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
    disclaimerBanner.layer.cornerRadius = 8
    disclaimerBanner.translatesAutoresizingMaskIntoConstraints = false
    card.addSubview(disclaimerBanner)
    
    let disclaimerLabel = UILabel()
    disclaimerLabel.text = "⚠️ SIMULATION ONLY - No Real Money"
    disclaimerLabel.textColor = .systemOrange
    disclaimerLabel.font = .systemFont(ofSize: 12, weight: .bold)
    disclaimerLabel.textAlignment = .center
    disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
    disclaimerBanner.addSubview(disclaimerLabel)
    
    let titleLabel = UILabel()
    titleLabel.text = LocalizationHelper.localized("trade.confirm.title")
    titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    card.addSubview(titleLabel)
    
    // ... rest of existing code ...
    
    NSLayoutConstraint.activate([
        card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        card.widthAnchor.constraint(equalToConstant: 300),
        
        // ADD THESE CONSTRAINTS
        disclaimerBanner.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
        disclaimerBanner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
        disclaimerBanner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
        disclaimerBanner.heightAnchor.constraint(equalToConstant: 32),
        
        disclaimerLabel.centerXAnchor.constraint(equalTo: disclaimerBanner.centerXAnchor),
        disclaimerLabel.centerYAnchor.constraint(equalTo: disclaimerBanner.centerYAnchor),
        
        // UPDATE THIS (was: constant: 24)
        titleLabel.topAnchor.constraint(equalTo: disclaimerBanner.bottomAnchor, constant: 12),
        titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
        titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        
        // ... rest of constraints ...
    ])
}
```

### C. Add First-Run Disclaimer

**Create new file: App/ViewControllers/DisclaimerViewController.swift:**
```swift
import UIKit

class DisclaimerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        let iconLabel = UILabel()
        iconLabel.text = "⚠️"
        iconLabel.font = .systemFont(ofSize: 60)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = "Important: Demo Application"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let messageLabel = UILabel()
        messageLabel.text = """
        MyFA is a DEMONSTRATION APPLICATION showcasing AI chat capabilities for financial assistance.
        
        • All trades are SIMULATED
        • No real money is involved
        • Market data is MOCK data
        • For educational purposes only
        
        This app does NOT provide actual financial services, trading, or investment management.
        """
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(messageLabel)
        
        let agreeButton = UIButton(type: .system)
        agreeButton.setTitle("I Understand", for: .normal)
        agreeButton.backgroundColor = .systemBlue
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        agreeButton.layer.cornerRadius = 12
        agreeButton.translatesAutoresizingMaskIntoConstraints = false
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        container.addSubview(agreeButton)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            iconLabel.topAnchor.constraint(equalTo: container.topAnchor),
            iconLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            agreeButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 32),
            agreeButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            agreeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            agreeButton.heightAnchor.constraint(equalToConstant: 50),
            agreeButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    @objc private func agreeTapped() {
        UserDefaults.standard.set(true, forKey: "HasSeenDisclaimer")
        dismiss(animated: true)
    }
}
```

**Update SceneDelegate.swift to show disclaimer on first run:**
```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    let window = UIWindow(windowScene: windowScene)
    
    let config = NeuronKitConfig.default(serverURL: AppConfig.defaultServerURL)
        .withUserId(AppConfig.defaultUserId)
    let coordinator = ChatKitCoordinator(config: config)
    
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
    
    if let urlContext = connectionOptions.urlContexts.first {
        handleURL(urlContext.url)
    }
}
```

---

## Fix #5: Improve Deep Link Security

### Update App/App/SceneDelegate.swift:

**Replace the `handleURL()` method:**
```swift
private var lastTradeRequestTime: Date?
private let tradeRequestCooldown: TimeInterval = 2.0 // 2 seconds between trades

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
                title: "Too Fast",
                message: "Please wait a moment before initiating another trade."
            )
            return
        }
    }
    
    // Validate URL parameters
    guard validateTradeURL(url) else {
        presentError(
            title: "Invalid Trade Request",
            message: "The trade link is invalid or malformed. Please try again."
        )
        return
    }
    
    // Update rate limit
    lastTradeRequestTime = Date()
    
    // Show confirmation dialog
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
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    window?.rootViewController?.present(alert, animated: true)
}
```

---

## Testing Your Fixes

After implementing these fixes:

1. **Test on Real Device:**
   ```bash
   # Build and install on connected iPhone
   xcodebuild -workspace MyFA.xcworkspace -scheme MyFA -destination 'platform=iOS,name=Your iPhone' build
   ```

2. **Test Server Connection:**
   - Launch app on device
   - Verify it connects to server (not localhost)
   - Check error handling if server is unavailable

3. **Test Privacy Permissions:**
   - Deny each permission and verify app handles gracefully
   - Grant permissions and verify they work correctly

4. **Test Trading:**
   - Verify disclaimer is visible
   - Test external deep link: Open Safari and navigate to a test URL
   - Verify rate limiting works (try multiple trades quickly)

5. **Test Disclaimer:**
   - Delete app and reinstall
   - Verify disclaimer shows on first launch
   - Verify it doesn't show on subsequent launches

---

## Build Configuration Tips

### Create Separate Configurations:

In Xcode:
1. Project Settings → Info → Configurations
2. Duplicate "Debug" → Name it "Development"
3. Duplicate "Release" → Name it "Production"

In each configuration:
- Set different Info.plist files
- Set different preprocessor macros
- Set different bundle identifiers (optional)

---

## Next Steps

1. ✅ Implement Fix #1 (Localhost URL) - CRITICAL
2. ✅ Implement Fix #4 (Disclaimers) - CRITICAL
3. ✅ Implement Fix #3 (Privacy) - CRITICAL
4. ✅ Implement Fix #2 (ATS) - CRITICAL
5. ✅ Implement Fix #5 (Security) - Recommended
6. ✅ Test everything on real device
7. ✅ Prepare App Store assets
8. ✅ Submit for review

---

**Need more help?** See the full compliance document: `APPLE_APP_STORE_COMPLIANCE.md`
