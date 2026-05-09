import Foundation
import SwiftData

@Model
final class VetVisit {
    var id: UUID
    var date: Date
    var clinic: String
    var veterinarian: String
    var reason: String
    var diagnosis: String
    var treatment: String
    var followUpDate: Date?
    var cost: Double?
    var notes: String
    var receiptData: Data?
    var createdAt: Date

    var pet: Pet?

    init(
        date: Date,
        clinic: String = "",
        veterinarian: String = "",
        reason: String = "",
        diagnosis: String = "",
        treatment: String = "",
        followUpDate: Date? = nil,
        cost: Double? = nil,
        notes: String = "",
        receiptData: Data? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.clinic = clinic
        self.veterinarian = veterinarian
        self.reason = reason
        self.diagnosis = diagnosis
        self.treatment = treatment
        self.followUpDate = followUpDate
        self.cost = cost
        self.notes = notes
        self.receiptData = receiptData
        self.createdAt = Date()
    }

    var hasFollowUp: Bool {
        guard let followUp = followUpDate else { return false }
        return followUp > Date()
    }
}
