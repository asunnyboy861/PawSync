import Foundation
import SwiftUI

struct PDFExportService {
    static func generateHealthReport(for pet: Pet) -> Data? {
        let score = HealthScoreEngine.calculate(for: pet)

        let renderer = ImageRenderer(content:
            HealthReportPDF(pet: pet, score: score)
                .frame(width: 612, height: 792)
        )

        renderer.scale = 2.0
        return renderer.uiImage?.pngData()
    }
}

struct HealthReportPDF: View {
    let pet: Pet
    let score: HealthScore

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PawSync Health Report")
                        .font(.title.weight(.bold))
                        .foregroundStyle(PawSyncTheme.accent)
                    Text(pet.name)
                        .font(.title2)
                    Text("\(pet.breed) · \(pet.ageString) · \(pet.gender.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Health Score")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(score.total)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(PawSyncTheme.accent)
                    Text(score.grade.rawValue)
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding(.bottom, 10)

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Vaccinations")
                    .font(.headline)
                ForEach(pet.vaccinations.sorted(by: { $0.dateAdministered > $1.dateAdministered })) { vax in
                    HStack {
                        Text(vax.name)
                            .font(.subheadline)
                        Spacer()
                        Text(vax.dateAdministered.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let nextDue = vax.nextDueDate {
                            Text("Next: \(nextDue.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(vax.isDue ? .red : .secondary)
                        }
                    }
                }
                if pet.vaccinations.isEmpty {
                    Text("No vaccinations recorded")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Active Medications")
                    .font(.headline)
                ForEach(pet.activeMedications) { med in
                    HStack {
                        Text(med.name)
                            .font(.subheadline)
                        Text("(\(med.dosage))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(med.frequency.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if pet.activeMedications.isEmpty {
                    Text("No active medications")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("Weight History")
                    .font(.headline)
                let recentWeights = pet.weightEntries.sorted { $0.date > $1.date }.prefix(5)
                ForEach(recentWeights) { entry in
                    HStack {
                        Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "%.1f kg", entry.weight))
                            .font(.subheadline.weight(.semibold))
                    }
                }
                if pet.weightEntries.isEmpty {
                    Text("No weight entries recorded")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if !score.insights.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Health Insights")
                        .font(.headline)
                    ForEach(score.insights, id: \.self) { insight in
                        Text("• \(insight)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            HStack {
                Text("Generated by PawSync on \(Date().formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("This report is for informational purposes only. Always consult your veterinarian.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(40)
    }
}
