import Foundation

struct CatchEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var species: String
    var weight: String
    var waterbody: String
    var lure: String
    var dateCreated: Date = Date()
}
