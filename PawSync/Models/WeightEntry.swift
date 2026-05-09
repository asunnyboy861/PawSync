import Foundation
import SwiftData

@Model
final class WeightEntry {
    var id: UUID
    var date: Date
    var weight: Double
    var notes: String
    var createdAt: Date

    var pet: Pet?

    init(date: Date = Date(), weight: Double, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.weight = weight
        self.notes = notes
        self.createdAt = Date()
    }
}
