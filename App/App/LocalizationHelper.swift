//
//  LocalizationHelper.swift
//  MyFA
//
//  Helper for managing localization in the demo app
//

import Foundation

/// Helper class for managing localization
/// Uses NSLocalizedString with fallback to embedded strings
class LocalizationHelper {
    
    // Embedded localization strings as fallback (for cases where Localizable.strings might not be loaded)
    private static let localizedStrings: [String: [String: String]] = [
        "en": [
            "app.title": "MyFA",
            "app.welcome": "Connected! Send a message to start chatting.",
            "app.error": "Error",
            "app.ok": "OK",
            "app.cancel": "Cancel",
            "status.connecting": "Connecting...",
            "status.reconnecting": "Reconnecting...",
            "status.connected": "Connected",
            "status.disconnected": "Disconnected",
            "composer.tools": "Tools",
            "composer.search.placeholder": "Search",
            "tool.expedia": "Expedia",
            "tool.booking": "Booking.com",
            "tool.coursera": "Coursera",
            "tool.expedia.description": "Search and book flights, hotels, and vacation packages",
            "tool.booking.description": "Find and book hotels, apartments, and accommodations worldwide",
            "tool.coursera.description": "Search and enroll in online courses from top universities and companies",
            "settings.language": "Language",
            "settings.language.en": "English",
            "settings.language.zhHans": "简体中文",
            "settings.language.zhHant": "繁體中文",
            "settings.language.change": "Change Language",
            "settings.language.restart": "Language Changed",
            "settings.language.restartMessage": "Please restart the app to apply the new language setting.",
            "settings.language.restartButton": "OK",
            "conversation.list.header.title": "MyFA",
            "conversation.list.pin": "Pin conversation: %@",
            "tab.chat": "Chat",
            "tab.strategies": "Strategies",
            "tab.assets": "Assets",
            "strategies.title": "Strategy Marketplace",
            "strategies.subtitle": "Discover quality investment strategies",
            "strategies.take.to.chat": "Take to Chat",
            "strategies.follow": "Follow",
            "strategies.annual.return": "Annual Return",
            "strategies.max.drawdown": "Max Drawdown",
            "strategies.sharpe.ratio": "Sharpe Ratio",
            "strategies.win.rate": "Win Rate",
            "strategies.followers": "Followers",
            "strategies.recent.followers": "Recently added %d followers in 7 days",
            "assets.title": "Assets",
            "assets.subtitle": "View your investment portfolio",
            "assets.journey.title": "Start Your Investment Journey",
            "assets.journey.subtitle": "AI-guided account opening, takes about 5-8 minutes\nSupports interruption, progress auto-saved",
            "assets.opening.title": "Account Opening Process",
            "assets.opening.step1": "Identity Verification",
            "assets.opening.step2": "Live Verification",
            "assets.opening.step3": "Risk Assessment",
            "assets.start.opening": "Start Account Opening",
            "assets.has.account": "Already have a securities account? Login now",
        ],
        "zh-Hans": [
            "app.title": "MyFA",
            "app.welcome": "已连接！发送消息开始聊天。",
            "app.error": "错误",
            "app.ok": "确定",
            "app.cancel": "取消",
            "status.connecting": "连接中...",
            "status.reconnecting": "重新连接中...",
            "status.connected": "已连接",
            "status.disconnected": "已断开连接",
            "composer.tools": "工具",
            "composer.search.placeholder": "搜索",
            "tool.expedia": "Expedia",
            "tool.booking": "Booking.com",
            "tool.coursera": "Coursera",
            "tool.expedia.description": "搜索和预订航班、酒店和度假套餐",
            "tool.booking.description": "查找和预订全球酒店、公寓和住宿",
            "tool.coursera.description": "搜索和注册来自顶尖大学和公司的在线课程",
            "settings.language": "语言",
            "settings.language.en": "English",
            "settings.language.zhHans": "简体中文",
            "settings.language.zhHant": "繁體中文",
            "settings.language.change": "更改语言",
            "settings.language.restart": "语言已更改",
            "settings.language.restartMessage": "请重启应用以应用新的语言设置。",
            "settings.language.restartButton": "确定",
            "conversation.list.header.title": "MyFA",
            "conversation.list.pin": "置顶对话：%@",
            "tab.chat": "对话",
            "tab.strategies": "策略",
            "tab.assets": "资产",
            "strategies.title": "策略广场",
            "strategies.subtitle": "发现优质投资策略",
            "strategies.take.to.chat": "拿来聊",
            "strategies.follow": "跟投",
            "strategies.annual.return": "年化收益",
            "strategies.max.drawdown": "最大回撤",
            "strategies.sharpe.ratio": "夏普比率",
            "strategies.win.rate": "胜率",
            "strategies.followers": "跟随人数",
            "strategies.recent.followers": "最近 7 天 %d 人新增",
            "assets.title": "资产",
            "assets.subtitle": "查看您的投资组合",
            "assets.journey.title": "开始你的投资之旅",
            "assets.journey.subtitle": "开户由AI智能引导，全程约5-8分钟\n支持随时中断，进度自动保存",
            "assets.opening.title": "开户流程",
            "assets.opening.step1": "身份验证",
            "assets.opening.step2": "实人见证",
            "assets.opening.step3": "风险评估",
            "assets.start.opening": "开始开户",
            "assets.has.account": "已有证券账户？立即登录",
        ]
    ]
    
    /// Get localized string for key using NSLocalizedString with fallback
    /// - Parameter key: The localization key
    /// - Returns: Localized string or the key if not found
    static func localized(_ key: String) -> String {
        // First try NSLocalizedString (uses Localizable.strings files)
        let localized = NSLocalizedString(key, comment: "")
        
        // If NSLocalizedString returns the key itself (meaning not found), use fallback
        if localized == key {
            return fallbackLocalized(key)
        }
        
        return localized
    }
    
    /// Get localized string with format arguments
    /// - Parameters:
    ///   - key: The localization key
    ///   - arguments: Format arguments
    /// - Returns: Formatted localized string
    static func localized(_ key: String, arguments: CVarArg...) -> String {
        let format = NSLocalizedString(key, comment: "")
        
        // If format is the same as key, try fallback
        if format == key {
            let fallbackFormat = fallbackLocalized(key)
            return String(format: fallbackFormat, arguments: arguments)
        }
        
        return String(format: format, arguments: arguments)
    }
    
    /// Fallback to embedded strings if NSLocalizedString doesn't find the key
    private static func fallbackLocalized(_ key: String) -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Map language codes to our supported languages
        let mappedCode: String
        if languageCode.hasPrefix("zh") {
            if Locale.current.language.region?.identifier == "HK" || 
               Locale.current.language.region?.identifier == "TW" ||
               Locale.current.language.region?.identifier == "MO" {
                mappedCode = "zh-Hant"
            } else {
                mappedCode = "zh-Hans"
            }
        } else {
            mappedCode = "en"
        }
        
        if let strings = localizedStrings[mappedCode],
           let value = strings[key] {
            return value
        }
        
        // Fallback to English
        if let strings = localizedStrings["en"],
           let value = strings[key] {
            return value
        }
        
        return key
    }
}
