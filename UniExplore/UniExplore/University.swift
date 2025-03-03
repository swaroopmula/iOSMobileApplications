import Foundation

struct University: Codable, Identifiable {
    let name: String
    let domains: [String]
    let webPages: [String]
    let country: String
    let alphaTwoCode: String
    let stateProvince: String?
    
    // Create a unique ID based on name since there's no ID in the JSON
    var id: String { name }
    
    enum CodingKeys: String, CodingKey {
        case name
        case domains
        case webPages = "web_pages"
        case country
        case alphaTwoCode = "alpha_two_code"
        case stateProvince = "state-province"
    }
} 