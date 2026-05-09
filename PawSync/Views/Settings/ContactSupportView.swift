import SwiftUI

struct ContactSupportView: View {
    @State private var selectedSubject: SupportSubject = .general
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var submitResult: SubmitResult?
    @State private var showSuccessAlert = false

    private let feedbackURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"

    enum SupportSubject: String, CaseIterable {
        case general = "General"
        case featureSuggestion = "Feature Suggestion"
        case bugReport = "Bug Report"
        case usageQuestion = "Usage Question"
        case performanceIssue = "Performance Issue"
        case uiImprovement = "UI Improvement"
        case other = "Other"

        var icon: String {
            switch self {
            case .general: return "message.fill"
            case .featureSuggestion: return "lightbulb.fill"
            case .bugReport: return "ladybug.fill"
            case .usageQuestion: return "questionmark.circle.fill"
            case .performanceIssue: return "gauge.with.dots.needle.67percent"
            case .uiImprovement: return "paintbrush.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }

    enum SubmitResult: Equatable {
        case success
        case failure(String)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                subjectSection

                if selectedSubject == .other {
                    customSubjectField
                }

                nameField
                emailField
                messageField
                submitButton
            }
            .padding()
        }
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thank You!", isPresented: $showSuccessAlert) {
            Button("OK") {
                if submitResult != nil {
                    resetForm()
                }
            }
        } message: {
            Text(submitResult == .success ? "Your feedback has been submitted successfully. We'll get back to you soon!" : "Something went wrong. Please try again later.")
        }
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Subject")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(SupportSubject.allCases, id: \.self) { subject in
                    SubjectChip(
                        subject: subject,
                        isSelected: selectedSubject == subject
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedSubject = subject
                        }
                        Haptics.selection()
                    }
                }
            }
        }
    }

    private var customSubjectField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Custom Subject")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("Enter your subject", text: $customSubject)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Name")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("your@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
        }
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Message")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }

    private var submitButton: some View {
        Button {
            Task { await submitFeedback() }
        } label: {
            if isSubmitting {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else {
                Text("Submit Feedback")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
        }
        .background(PawSyncTheme.accentGradient)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: PawSyncTheme.accent.opacity(0.3), radius: 8, y: 4)
        .disabled(isSubmitting || !isFormValid)
        .buttonStyle(BounceButtonStyle())
    }

    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !message.isEmpty &&
        (selectedSubject != .other || !customSubject.isEmpty)
    }

    private var subjectValue: String {
        if selectedSubject == .other {
            return customSubject
        }
        return selectedSubject.rawValue
    }

    private func submitFeedback() async {
        isSubmitting = true

        let body: [String: String] = [
            "name": name,
            "email": email,
            "subject": subjectValue,
            "message": message,
            "app_name": "PawSync"
        ]

        do {
            guard let url = URL(string: feedbackURL) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                submitResult = .success
                Haptics.success()
            } else {
                submitResult = .failure("Server error")
            }
        } catch {
            submitResult = .failure(error.localizedDescription)
        }

        isSubmitting = false
        showSuccessAlert = true
    }

    private func resetForm() {
        selectedSubject = .general
        customSubject = ""
        name = ""
        email = ""
        message = ""
        submitResult = nil
    }
}

struct SubjectChip: View {
    let subject: ContactSupportView.SupportSubject
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: subject.icon)
                    .font(.caption2)
                Text(subject.rawValue)
                    .font(.caption.weight(isSelected ? .semibold : .regular))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? PawSyncTheme.accent.opacity(0.12) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? PawSyncTheme.accent : Color.clear, lineWidth: 1.5)
                    )
            )
            .foregroundStyle(isSelected ? PawSyncTheme.accent : .primary)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
