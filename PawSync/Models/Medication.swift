import Foundation
import SwiftData

@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: String
    var frequency: MedicationFrequency
    var startDate: Date
    var endDate: Date?
    var timeOfDay: [Date]
    var withFood: Bool
    var prescribedBy: String
    var purpose: String
    var notes: String
    var isActive: Bool
    var refillDate: Date?
    var barcode: String?
    var createdAt: Date

    var pet: Pet?

    init(
        name: String,
        dosage: String,
        frequency: MedicationFrequency = .daily,
        startDate: Date = Date(),
        endDate: Date? = nil,
        timeOfDay: [Date] = [],
        withFood: Bool = false,
        prescribedBy: String = "",
        purpose: String = "",
        notes: String = "",
        refillDate: Date? = nil,
        barcode: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.timeOfDay = timeOfDay
        self.withFood = withFood
        self.prescribedBy = prescribedBy
        self.purpose = purpose
        self.notes = notes
        self.isActive = true
        self.refillDate = refillDate
        self.barcode = barcode
        self.createdAt = Date()
    }

    var needsRefill: Bool {
        guard let refillDate else { return false }
        let oneWeekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return refillDate <= oneWeekFromNow
    }
}

enum MedicationFrequency: String, Codable, CaseIterable {
    case asNeeded = "As Needed"
    case daily = "Daily"
    case twiceDaily = "Twice Daily"
    case threeTimesDaily = "Three Times Daily"
    case weekly = "Weekly"
    case biweekly = "Every 2 Weeks"
    case monthly = "Monthly"
    case quarterly = "Every 3 Months"
}
