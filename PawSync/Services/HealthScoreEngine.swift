import Foundation

struct HealthScore {
    let total: Int
    let grade: ScoreGrade
    let vaccination: Double
    let preventiveCare: Double
    let medicationAdherence: Double
    let weightStability: Double
    let insights: [String]

    enum ScoreGrade: String {
        case excellent = "Excellent"
        case great = "Great"
        case good = "Good"
        case fair = "Fair"
        case needsAttention = "Needs Attention"

        var emoji: String {
            switch self {
            case .excellent: return "trophy"
            case .great: return "star.fill"
            case .good: return "hand.thumbsup.fill"
            case .fair: return "exclamationmark.triangle.fill"
            case .needsAttention: return "stethoscope"
            }
        }

        var color: Color {
            switch self {
            case .excellent: return .green
            case .great: return PawSyncTheme.accent
            case .good: return .blue
            case .fair: return .orange
            case .needsAttention: return .red
            }
        }
    }
}

import SwiftUI

struct HealthScoreEngine {

    static func calculate(for pet: Pet) -> HealthScore {
        var insights: [String] = []

        let vax = vaccinationScore(pet: pet, insights: &insights)
        let care = preventiveCareScore(pet: pet, insights: &insights)
        let meds = medicationScore(pet: pet, insights: &insights)
        let weight = weightScore(pet: pet, insights: &insights)

        let weighted = vax * 0.30
            + care * 0.25
            + meds * 0.25
            + weight * 0.20

        let total = min(100, max(0, Int(round(weighted * 100))))

        let grade: HealthScore.ScoreGrade
        switch total {
        case 90...100: grade = .excellent
        case 75..<90:  grade = .great
        case 60..<75:  grade = .good
        case 40..<60:  grade = .fair
        default:       grade = .needsAttention
        }

        return HealthScore(
            total: total,
            grade: grade,
            vaccination: vax,
            preventiveCare: care,
            medicationAdherence: meds,
            weightStability: weight,
            insights: insights
        )
    }

    private static func vaccinationScore(pet: Pet, insights: inout [String]) -> Double {
        let coreNames: Set<String>
        switch pet.species {
        case .dog:
            coreNames = ["Rabies", "DHPP (Distemper/Parvo Combo)", "Leptospirosis"]
        case .cat:
            coreNames = ["Rabies", "FVRCP (3-in-1 Cat Shot)", "FeLV (Feline Leukemia)"]
        default:
            coreNames = ["Rabies"]
        }

        let vaccinations = pet.vaccinations
        guard !coreNames.isEmpty else { return 0.5 }

        var currentCount = 0
        var missingNames: [String] = []

        for coreName in coreNames {
            let matching = vaccinations.filter { $0.name == coreName }
            if let latest = matching.sorted(by: { $0.dateAdministered > $1.dateAdministered }).first {
                if let nextDue = latest.nextDueDate, nextDue > Date() {
                    currentCount += 1
                } else if latest.nextDueDate == nil {
                    currentCount += 1
                } else {
                    missingNames.append(coreName.components(separatedBy: " (").first ?? coreName)
                }
            } else {
                missingNames.append(coreName.components(separatedBy: " (").first ?? coreName)
            }
        }

        if !missingNames.isEmpty {
            insights.append("Overdue/missing vaccines: \(missingNames.joined(separator: ", ")). Schedule with your vet.")
        }

        let nonCoreCount = vaccinations.filter { !coreNames.contains($0.name) }.count
        let bonus = min(0.1, Double(nonCoreCount) * 0.03)

        return min(1.0, Double(currentCount) / Double(coreNames.count) + bonus)
    }

    private static func preventiveCareScore(pet: Pet, insights: inout [String]) -> Double {
        let ageYears = pet.ageInYears
        let visits = pet.vetVisits.sorted { $0.date > $1.date }

        let expectedPerYear: Double
        if ageYears < 1 {
            expectedPerYear = 4
        } else if ageYears < 7 {
            expectedPerYear = 1
        } else {
            expectedPerYear = 2
        }

        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let recentVisits = visits.filter { $0.date >= oneYearAgo }.count

        if recentVisits == 0 {
            if ageYears >= 7 {
                insights.append("No vet visits in the past year. Senior pets need checkups every 6 months.")
            } else {
                insights.append("No vet visit recorded in the past year. Annual wellness exams catch problems early.")
            }
        }

        let ratio = Double(recentVisits) / expectedPerYear
        return min(1.0, ratio)
    }

    private static func medicationScore(pet: Pet, insights: inout [String]) -> Double {
        let activeMeds = pet.medications.filter { $0.isActive }

        if activeMeds.isEmpty { return 0.85 }

        var score = 1.0
        var overdueRefills: [String] = []

        for med in activeMeds {
            if med.timeOfDay.isEmpty {
                score -= 0.1
            }

            if let refillDate = med.refillDate, refillDate <= Date() {
                overdueRefills.append(med.name)
                score -= 0.2
            }
        }

        if !overdueRefills.isEmpty {
            insights.append("Overdue refills: \(overdueRefills.joined(separator: ", ")). Don't miss doses!")
        }

        return max(0, score)
    }

    private static func weightScore(pet: Pet, insights: inout [String]) -> Double {
        let entries = pet.weightEntries.sorted { $0.date > $1.date }

        guard entries.count >= 2 else {
            if entries.isEmpty {
                insights.append("Start tracking \(pet.name)'s weight regularly to monitor health trends.")
            }
            return 0.6
        }

        let recentWeights = entries.prefix(10).map(\.weight)
        let mean = recentWeights.reduce(0, +) / Double(recentWeights.count)
        guard mean > 0 else { return 0.5 }

        let variance = recentWeights.map { pow($0 - mean, 2) }.reduce(0, +) / Double(recentWeights.count)
        let cv = sqrt(variance) / mean

        if cv > 0.10 {
            insights.append("\(pet.name)'s weight has been fluctuating significantly. Discuss with your vet.")
        }

        if cv < 0.03 { return 1.0 }
        if cv < 0.05 { return 0.9 }
        if cv < 0.08 { return 0.7 }
        if cv < 0.10 { return 0.5 }
        return 0.3
    }
}
