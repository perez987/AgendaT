import Foundation

/// Provides localization support with automatic macOS language detection
/// Supports English, Spanish, and French with English as fallback
class LocalizationManager {
    static let shared = LocalizationManager()
    
    /// Supported language codes
    private let supportedLanguages = ["en", "es", "fr"]
    
    /// Current language code (e.g., "en", "es", "fr")
    private(set) var currentLanguageCode: String
    
    private init() {
        // Detect system language
        let preferredLanguages = Locale.preferredLanguages
        var detectedLanguage = "en" // Default fallback
        
        // Find first supported language from system preferences
        for language in preferredLanguages {
            let languageCode = String(language.prefix(2))
            if supportedLanguages.contains(languageCode) {
                detectedLanguage = languageCode
                break
            }
        }
        
        self.currentLanguageCode = detectedLanguage
    }
    
    /// Get localized string for the given key
    /// - Parameter key: The localization key
    /// - Returns: Localized string, or the key itself if not found
    func localizedString(_ key: String) -> String {
        // Try to get bundle for current language
        if let bundlePath = Bundle.main.path(forResource: currentLanguageCode, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            let localized = bundle.localizedString(forKey: key, value: nil, table: nil)
            if localized != key {
                return localized
            }
        }
        
        // Fallback to English
        if currentLanguageCode != "en",
           let bundlePath = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        
        // Return key if all else fails
        return key
    }
}

/// Global function for convenient localization access
func localized(_ key: String) -> String {
    return LocalizationManager.shared.localizedString(key)
}
