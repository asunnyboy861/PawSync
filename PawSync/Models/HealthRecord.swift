import Foundation
import SwiftData

@Model
final class HealthRecord {
    var id: UUID
    var date: Date
    var type: RecordType
    var title: String
    var details: String
    var veterinarian: String
    var clinic: String
    var cost: Double?
    var documentData: Data?
    var createdAt: Date

    var pet: Pet?

    init(
        date: Date,
        type: RecordType,
        title: String,
        details: String = "",
        veterinarian: String = "",
        clinic: String = "",
        cost: Double? = nil,
        documentData: Data? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.title = title
        self.details = details
        self.veterinarian = veterinarian
        self.clinic = clinic
        self.cost = cost
        self.documentData = documentData
        self.createdAt = Date()
    }
}

enum RecordType: String, Codable, CaseIterable {
    case checkup = "Checkup"
    case illness = "Illness"
    case injury = "Injury"
    case surgery = "Surgery"
    case dental = "Dental"
    case lab = "Lab Work"
    case imaging = "Imaging"
    case other = "Other"

    var icon: String {
        switch self {
        case .checkup: return "stethoscope"
        case .illness: return "cross.case.fill"
        case .injury: return "bandage.fill"
        case .surgery: return "scissors"
        case .dental: return "mouth.fill"
        case .lab: return "flask.fill"
        case .imaging: return "xray"
        case .other: return "doc.text.fill"
        }
    }

    var color: String {
        switch self {
        case .checkup: return "green"
        case .illness: return "orange"
        case .injury: return "red"
        case .surgery: return "purple"
        case .dental: return "blue"
        case .lab: return "teal"
        case .imaging: return "indigo"
        case .other: return "gray"
        }
    }
}
