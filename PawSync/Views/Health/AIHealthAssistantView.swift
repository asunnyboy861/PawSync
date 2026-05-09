import SwiftUI

struct AIHealthAssistantView: View {
    let pet: Pet
    @Environment(PurchaseManager.self) private var purchaseManager
    @State private var symptomText = ""
    @State private var aiResponse = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var conversationHistory: [ChatMessage] = []
    @State private var showingPaywall = false

    struct ChatMessage: Identifiable {
        let id = UUID()
        let content: String
        let isUser: Bool
        let timestamp = Date()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if conversationHistory.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(conversationHistory) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: conversationHistory.count) { _, _ in
                            if let lastMessage = conversationHistory.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                if isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(PawSyncTheme.accent)
                        Text("Analyzing...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }

                inputBar
            }
            .navigationTitle("AI Health Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if conversationHistory.count > 1 {
                        Button("Clear") {
                            conversationHistory.removeAll()
                            aiResponse = ""
                        }
                        .font(.caption)
                    }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [PawSyncTheme.accent.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                Image(systemName: "brain.head.profile.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(PawSyncTheme.accent)
            }

            VStack(spacing: 8) {
                Text("AI Health Assistant")
                    .font(.title3.weight(.bold))
                Text("Describe your pet's symptoms or ask health questions.\nAlways consult your vet for medical concerns.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Try asking:")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                ForEach(sampleQuestions, id: \.self) { question in
                    Button {
                        symptomText = question
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkle")
                                .font(.caption2)
                                .foregroundStyle(PawSyncTheme.accent)
                            Text(question)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(PawSyncTheme.accent.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var sampleQuestions: [String] {
        [
            "My \(pet.species.rawValue) is scratching a lot, what could it be?",
            "What vaccines does my \(pet.species.rawValue) need?",
            "My pet hasn't been eating well for 2 days",
            "Is it normal for \(pet.species.rawValue)s to vomit occasionally?"
        ]
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 12) {
                TextField("Describe symptoms or ask a question...", text: $symptomText, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Button {
                    Task { await sendQuery() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(symptomText.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : PawSyncTheme.accent)
                }
                .disabled(symptomText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private func sendQuery() async {
        guard purchaseManager.isPremium else {
            showingPaywall = true
            return
        }

        let query = symptomText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }

        let userMessage = ChatMessage(content: query, isUser: true)
        conversationHistory.append(userMessage)
        symptomText = ""
        isLoading = true
        errorMessage = nil

        let config = AIConfiguration.loadFromStorage()
        guard config.isConfigured else {
            let errorMessage = ChatMessage(
                content: "AI is not configured. Please set up your AI provider in Settings > AI Configuration.",
                isUser: false
            )
            conversationHistory.append(errorMessage)
            isLoading = false
            return
        }

        let service = OpenAIService(configuration: config)

        let petContext = """
        Pet: \(pet.name), \(pet.species.rawValue), \(pet.breed), \(pet.ageString), \(pet.gender.rawValue)
        Weight: \(String(format: "%.1f", pet.weight)) kg
        Allergies: \(pet.allergies.isEmpty ? "None" : pet.allergies.joined(separator: ", "))
        Active medications: \(pet.activeMedications.map(\.name).joined(separator: ", "))
        Recent vaccinations: \(pet.vaccinations.prefix(3).map(\.name).joined(separator: ", "))
        """

        let systemPrompt = """
        You are a veterinary health assistant for the PawSync app. The user's pet information:
        \(petContext)

        Provide helpful, balanced advice. Always:
        1. Acknowledge the concern
        2. Provide possible explanations (not diagnoses)
        3. Suggest when to see a vet
        4. Mention any relevant preventive care
        5. Remind that this is not a substitute for professional veterinary care

        Keep responses concise but thorough. Use bullet points for multiple items.
        """

        do {
            let response = try await service.completeWithSystemPrompt(systemPrompt, userPrompt: query)
            let aiMessage = ChatMessage(content: response, isUser: false)
            conversationHistory.append(aiMessage)
        } catch {
            let errorMsg = ChatMessage(
                content: "Sorry, I couldn't process your request: \(error.localizedDescription)",
                isUser: false
            )
            conversationHistory.append(errorMsg)
        }

        isLoading = false
    }
}

struct ChatBubble: View {
    let message: AIHealthAssistantView.ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isUser {
                ZStack {
                    Circle()
                        .fill(PawSyncTheme.accent.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(systemName: "brain.head.profile.fill")
                        .font(.caption2)
                        .foregroundStyle(PawSyncTheme.accent)
                }
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.subheadline)
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        message.isUser
                        ? PawSyncTheme.accent
                        : Color(.systemGray6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            if message.isUser {
                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)
            }
        }
    }
}
