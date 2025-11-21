//
//  LocalizationHelper.swift
//  MyFA
//
//  Helper for managing localization in the demo app
//

import Foundation
import UIKit

/// Helper class for managing localization
class LocalizationHelper {
    
    // MARK: - Language Management
    
    private static let languageKey = "AppLanguage"
    
    /// Available languages
    enum Language: String, CaseIterable {
        case english = "en"
        case chinese = "zh-Hans"
        
        var displayName: String {
            switch self {
            case .english: return "English"
            case .chinese: return "简体中文"
            }
        }
        
        var code: String {
            return self.rawValue
        }
    }
    
    /// Get the current app language
    static var currentLanguage: Language {
        get {
            if let code = UserDefaults.standard.string(forKey: languageKey),
               let language = Language(rawValue: code) {
                return language
            }
            
            // Default to system language
            let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
            if systemLang.hasPrefix("zh") {
                return .chinese
            }
            return .english
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// Set app language
    static func setLanguage(_ language: Language) {
        currentLanguage = language
        
        // Post notification for language change
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    // MARK: - Localization
    
    /// Get localized string for key
    static func localized(_ key: String) -> String {
        let language = currentLanguage.code
        
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(key, bundle: bundle, comment: "")
        }
        
        return NSLocalizedString(key, comment: "")
    }
    
    /// Get localized string with format arguments
    static func localized(_ key: String, _ arguments: CVarArg...) -> String {
        let format = localized(key)
        return String(format: format, arguments: arguments)
    }
}
