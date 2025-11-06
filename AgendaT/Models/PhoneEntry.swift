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
}
