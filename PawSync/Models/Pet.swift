import Foundation
import SwiftData

@Model
final class Pet {
    var id: UUID
    var name: String
    var species: PetSpecies
    var breed: String
    var dateOfBirth: Date
    var gender: PetGender
    var weight: Double
    var photoData: Data?
    var microchipID: String?
    var allergies: [String]
    var notes: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var vaccinations: [Vaccination]
    @Relationship(deleteRule: .cascade) var medications: [Medication]
    @Relationship(deleteRule: .cascade) var weightEntries: [WeightEntry]
    @Relationship(deleteRule: .cascade) var healthRecords: [HealthRecord]
    @Relationship(deleteRule: .cascade) var vetVisits: [VetVisit]

    init(
        name: String,
        species: PetSpecies,
        breed: String,
        dateOfBirth: Date,
        gender: PetGender,
        weight: Double = 0,
        photoData: Data? = nil,
        microchipID: String? = nil,
        allergies: [String] = [],
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.species = species
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.weight = weight
        self.photoData = photoData
        self.microchipID = microchipID
        self.allergies = allergies
        self.notes = notes
        self.createdAt = Date()
        self.vaccinations = []
        self.medications = []
        self.weightEntries = []
        self.healthRecords = []
        self.vetVisits = []
    }

    var ageString: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: dateOfBirth, to: Date())
        let years = components.year ?? 0
        let months = components.month ?? 0
        if years > 0 {
            return months > 0 ? "\(years)y \(months)m" : "\(years)y"
        }
        return "\(months)m"
    }

    var ageInYears: Double {
        let interval = Date().timeIntervalSince(dateOfBirth)
        return interval / (365.25 * 24 * 3600)
    }

    var nextVaccination: Vaccination? {
        vaccinations
            .filter { $0.nextDueDate != nil && $0.nextDueDate! > Date() }
            .sorted { ($0.nextDueDate ?? .distantFuture) < ($1.nextDueDate ?? .distantFuture) }
            .first
    }

    var activeMedications: [Medication] {
        medications.filter { $0.isActive }
    }
}

enum PetSpecies: String, Codable, CaseIterable {
    case dog = "Dog"
    case cat = "Cat"
    case bird = "Bird"
    case rabbit = "Rabbit"
    case hamster = "Hamster"
    case fish = "Fish"
    case other = "Other"

    var icon: String {
        switch self {
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .bird: return "bird.fill"
        case .rabbit: return "hare.fill"
        case .hamster: return "hamster.fill"
        case .fish: return "fish.fill"
        case .other: return "pawprint.fill"
        }
    }
}

enum PetGender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case neutered = "Neutered Male"
    case spayed = "Spayed Female"
}
