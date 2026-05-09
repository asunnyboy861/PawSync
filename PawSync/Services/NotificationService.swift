import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }

    func scheduleMedicationReminder(for medication: Medication, petName: String) {
        guard medication.isActive else { return }

        for (index, time) in medication.timeOfDay.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "\(petName) needs \(medication.name) (\(medication.dosage))"
            if medication.withFood {
                content.body += " — give with food"
            }
            content.sound = .default
            content.categoryIdentifier = "MEDICATION"

            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.hour = calendar.component(.hour, from: time)
            dateComponents.minute = calendar.component(.minute, from: time)

            let trigger: UNNotificationTrigger
            switch medication.frequency {
            case .daily, .twiceDaily, .threeTimesDaily:
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            case .weekly:
                dateComponents.weekday = calendar.component(.weekday, from: medication.startDate)
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            default:
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            }

            let request = UNNotificationRequest(
                identifier: "med-\(medication.id.uuidString)-\(index)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }

        if let refillDate = medication.refillDate, refillDate > Date() {
            scheduleRefillReminder(for: medication, petName: petName)
        }
    }

    func cancelMedicationReminders(for medication: Medication) {
        let identifiers = medication.timeOfDay.indices.map { "med-\(medication.id.uuidString)-\($0)" }
            + ["med-refill-\(medication.id.uuidString)", "med-refill-early-\(medication.id.uuidString)"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func scheduleRefillReminder(for medication: Medication, petName: String) {
        guard let refillDate = medication.refillDate else { return }

        if let threeDaysBefore = Calendar.current.date(byAdding: .day, value: -3, to: refillDate),
           threeDaysBefore > Date() {
            scheduleOneTimeNotification(
                id: "med-refill-early-\(medication.id.uuidString)",
                title: "Refill Needed Soon",
                body: "\(petName)'s \(medication.name) refill is due in 3 days.",
                date: threeDaysBefore
            )
        }

        scheduleOneTimeNotification(
            id: "med-refill-\(medication.id.uuidString)",
            title: "Refill Due Today",
            body: "\(petName)'s \(medication.name) needs a refill today.",
            date: refillDate
        )
    }

    func scheduleVaccinationReminder(for vaccination: Vaccination, petName: String) {
        guard let dueDate = vaccination.nextDueDate else { return }

        if let twoWeeksBefore = Calendar.current.date(byAdding: .day, value: -14, to: dueDate),
           twoWeeksBefore > Date() {
            scheduleOneTimeNotification(
                id: "vax-early-\(vaccination.id.uuidString)",
                title: "Upcoming Vaccination",
                body: "\(petName)'s \(vaccination.name) vaccination is due in 2 weeks.",
                date: twoWeeksBefore
            )
        }

        if let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: dueDate),
           oneDayBefore > Date() {
            scheduleOneTimeNotification(
                id: "vax-tomorrow-\(vaccination.id.uuidString)",
                title: "Vaccination Tomorrow",
                body: "\(petName)'s \(vaccination.name) vaccination is due tomorrow.",
                date: oneDayBefore
            )
        }

        scheduleOneTimeNotification(
            id: "vax-due-\(vaccination.id.uuidString)",
            title: "Vaccination Due Today",
            body: "\(petName)'s \(vaccination.name) vaccination is due today!",
            date: dueDate
        )
    }

    func cancelVaccinationReminders(for vaccination: Vaccination) {
        let identifiers = [
            "vax-early-\(vaccination.id.uuidString)",
            "vax-tomorrow-\(vaccination.id.uuidString)",
            "vax-due-\(vaccination.id.uuidString)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func scheduleVetFollowUpReminder(for visit: VetVisit, petName: String) {
        guard let followUpDate = visit.followUpDate, followUpDate > Date() else { return }

        if let oneWeekBefore = Calendar.current.date(byAdding: .day, value: -7, to: followUpDate),
           oneWeekBefore > Date() {
            scheduleOneTimeNotification(
                id: "vet-week-\(visit.id.uuidString)",
                title: "Vet Follow-Up in 1 Week",
                body: "\(petName) has a follow-up in 1 week.",
                date: oneWeekBefore
            )
        }

        if let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: followUpDate),
           oneDayBefore > Date() {
            scheduleOneTimeNotification(
                id: "vet-tomorrow-\(visit.id.uuidString)",
                title: "Vet Follow-Up Tomorrow",
                body: "\(petName)'s follow-up is tomorrow.",
                date: oneDayBefore
            )
        }

        scheduleOneTimeNotification(
            id: "vet-due-\(visit.id.uuidString)",
            title: "Vet Follow-Up Today",
            body: "\(petName)'s follow-up appointment is today!",
            date: followUpDate
        )
    }

    func cancelVetReminders(for visit: VetVisit) {
        let identifiers = [
            "vet-week-\(visit.id.uuidString)",
            "vet-tomorrow-\(visit.id.uuidString)",
            "vet-due-\(visit.id.uuidString)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func rescheduleAllReminders(pets: [Pet]) {
        for pet in pets {
            for vax in pet.vaccinations {
                cancelVaccinationReminders(for: vax)
                if vax.nextDueDate != nil && !vax.isDue {
                    scheduleVaccinationReminder(for: vax, petName: pet.name)
                }
            }

            for med in pet.medications where med.isActive {
                cancelMedicationReminders(for: med)
                scheduleMedicationReminder(for: med, petName: pet.name)
            }

            for visit in pet.vetVisits where visit.hasFollowUp {
                cancelVetReminders(for: visit)
                scheduleVetFollowUpReminder(for: visit, petName: pet.name)
            }
        }
    }

    private func scheduleOneTimeNotification(id: String, title: String, body: String, date: Date) {
        guard date > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var components = Calendar.current.dateComponents(
            [.year, .month, .day], from: date
        )
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
