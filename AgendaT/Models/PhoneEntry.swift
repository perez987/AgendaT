import Foundation

struct PhoneEntry: Identifiable, Codable, Equatable, Hashable {
    var id: Int
    var name: String
    var phone1: String
    var phone2: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case phone1 = "Phone1"
        case phone2 = "Phone2"
    }
    
    // Format phone number for display (e.g., "123456789" -> "123 456 789")
    static func formatPhoneNumber(_ phone: String) -> String {
        guard !phone.isEmpty else { return phone }
        
        // Remove any non-numeric characters
        let digits = phone.filter { $0.isNumber }
        
        // If less than 4 digits, return as is
        guard digits.count >= 4 else { return digits }
        
        // Format in groups of 3: "XXX XXX XXX"
        var formatted = ""
        for (index, digit) in digits.enumerated() {
            if index > 0 && index % 3 == 0 {
                formatted.append(" ")
            }
            formatted.append(digit)
        }
        return formatted
    }
    
    // Validate phone number (must be numeric and have reasonable length)
    static func validatePhoneNumber(_ phone: String) -> Bool {
        // Allow empty phone numbers (Phone2 can be optional)
        if phone.isEmpty {
            return true
        }
        
        // Remove whitespace and check if all characters are digits
        let digits = phone.filter { $0.isNumber }

			// Phone number should contain only digits and whitespace, and be between 4 and 10 digits
		return digits.count >= 4 && digits.count <= 10 && phone.allSatisfy({ $0.isNumber || $0.isWhitespace })

    }
}
