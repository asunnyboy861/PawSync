import Foundation
import SwiftData

@Model
final class Vaccination {
    var id: UUID
    var name: String
    var dateAdministered: Date
    var nextDueDate: Date?
    var batchNumber: String
    var veterinarian: String
    var clinic: String
    var notes: String
    var createdAt: Date

    var pet: Pet?

    init(
        name: String,
        dateAdministered: Date,
        nextDueDate: Date? = nil,
        batchNumber: String = "",
        veterinarian: String = "",
        clinic: String = "",
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.dateAdministered = dateAdministered
        self.nextDueDate = nextDueDate
        self.batchNumber = batchNumber
        self.veterinarian = veterinarian
        self.clinic = clinic
        self.notes = notes
        self.createdAt = Date()
    }

    var isDue: Bool {
        guard let nextDue = nextDueDate else { return false }
        return nextDue <= Date()
    }

    var isDueSoon: Bool {
        guard let nextDue = nextDueDate else { return false }
        let twoWeeksFromNow = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        return nextDue <= twoWeeksFromNow && nextDue > Date()
    }
}

struct VaccinationTemplate {
    let name: String
    let species: PetSpecies
    let isCore: Bool
    let initialAgeMonths: Int
    let boosterIntervalMonths: Int?
    let description: String

    static let dogVaccinations: [VaccinationTemplate] = [
        VaccinationTemplate(name: "Rabies", species: .dog, isCore: true, initialAgeMonths: 3, boosterIntervalMonths: 12, description: "Required by law. First shot at 12-16 weeks, booster within 1 year, then every 1-3 years."),
        VaccinationTemplate(name: "DHPP (Distemper/Parvo Combo)", species: .dog, isCore: true, initialAgeMonths: 2, boosterIntervalMonths: 36, description: "Protects against distemper, hepatitis, parainfluenza, and parvo. Puppies need 3+ rounds, then booster every 3 years."),
        VaccinationTemplate(name: "Leptospirosis", species: .dog, isCore: true, initialAgeMonths: 3, boosterIntervalMonths: 12, description: "Core vaccine since 2024. Bacterial infection from contaminated water. Two shots 2-4 weeks apart, then yearly booster."),
        VaccinationTemplate(name: "Bordetella (Kennel Cough)", species: .dog, isCore: false, initialAgeMonths: 2, boosterIntervalMonths: 12, description: "Required by most boarding facilities and groomers. Yearly booster."),
        VaccinationTemplate(name: "Canine Influenza", species: .dog, isCore: false, initialAgeMonths: 2, boosterIntervalMonths: 12, description: "Protects against dog flu strains H3N2 and H3N8. Two shots 2-4 weeks apart, then yearly."),
        VaccinationTemplate(name: "Lyme Disease", species: .dog, isCore: false, initialAgeMonths: 3, boosterIntervalMonths: 12, description: "Important in Northeast US and Upper Midwest. Two shots 2-4 weeks apart, then yearly.")
    ]

    static let catVaccinations: [VaccinationTemplate] = [
        VaccinationTemplate(name: "Rabies", species: .cat, isCore: true, initialAgeMonths: 3, boosterIntervalMonths: 12, description: "Required by law for cats in 34 US states. One shot at 12-16 weeks, booster every 1-3 years."),
        VaccinationTemplate(name: "FVRCP (3-in-1 Cat Shot)", species: .cat, isCore: true, initialAgeMonths: 2, boosterIntervalMonths: 36, description: "Protects against feline herpes, calicivirus, and panleukopenia. Kitten series, then booster every 3 years."),
        VaccinationTemplate(name: "FeLV (Feline Leukemia)", species: .cat, isCore: true, initialAgeMonths: 2, boosterIntervalMonths: 12, description: "Must-have for all kittens under 1 year. Two shots 3-4 weeks apart.")
    ]

    static func templates(for species: PetSpecies) -> [VaccinationTemplate] {
        switch species {
        case .dog: return dogVaccinations
        case .cat: return catVaccinations
        default: return []
        }
    }
}
