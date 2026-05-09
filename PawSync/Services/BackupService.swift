import Foundation
import SwiftUI
import SwiftData

struct BackupService {
    static func exportData(pets: [Pet], modelContext: ModelContainer) -> Data? {
        let export = pets.map { pet in
            return [
                "name": pet.name,
                "species": pet.species.rawValue,
                "breed": pet.breed,
                "dateOfBirth": ISO8601DateFormatter().string(from: pet.dateOfBirth),
                "gender": pet.gender.rawValue,
                "weight": pet.weight,
                "microchipID": pet.microchipID ?? "",
                "allergies": pet.allergies,
                "notes": pet.notes,
                "vaccinations": pet.vaccinations.map { [
                    "name": $0.name,
                    "dateAdministered": ISO8601DateFormatter().string(from: $0.dateAdministered),
                    "nextDueDate": $0.nextDueDate.map { ISO8601DateFormatter().string(from: $0) } ?? "",
                    "veterinarian": $0.veterinarian,
                    "clinic": $0.clinic,
                    "notes": $0.notes
                ] as [String: Any] },
                "medications": pet.medications.map { [
                    "name": $0.name,
                    "dosage": $0.dosage,
                    "frequency": $0.frequency.rawValue,
                    "isActive": $0.isActive,
                    "prescribedBy": $0.prescribedBy,
                    "purpose": $0.purpose,
                    "notes": $0.notes
                ] as [String: Any] },
                "weightEntries": pet.weightEntries.map { [
                    "date": ISO8601DateFormatter().string(from: $0.date),
                    "weight": $0.weight,
                    "notes": $0.notes
                ] as [String: Any] },
                "healthRecords": pet.healthRecords.map { [
                    "date": ISO8601DateFormatter().string(from: $0.date),
                    "type": $0.type.rawValue,
                    "title": $0.title,
                    "details": $0.details,
                    "veterinarian": $0.veterinarian,
                    "clinic": $0.clinic,
                    "cost": $0.cost ?? 0
                ] as [String: Any] },
                "vetVisits": pet.vetVisits.map { [
                    "date": ISO8601DateFormatter().string(from: $0.date),
                    "clinic": $0.clinic,
                    "veterinarian": $0.veterinarian,
                    "reason": $0.reason,
                    "diagnosis": $0.diagnosis,
                    "treatment": $0.treatment,
                    "notes": $0.notes
                ] as [String: Any] }
            ] as [String: Any]
        }

        return try? JSONSerialization.data(withJSONObject: export, options: .prettyPrinted)
    }

    static func exportCSV(weightEntries: [WeightEntry], petName: String) -> String {
        var csv = "Date,Weight (kg),Notes\n"
        let entries = weightEntries.sorted { $0.date > $1.date }
        for entry in entries {
            let dateStr = entry.date.formatted(date: .abbreviated, time: .omitted)
            let notes = entry.notes.replacingOccurrences(of: ",", with: ";")
            csv += "\(dateStr),\(entry.weight),\(notes)\n"
        }
        return csv
    }
}
