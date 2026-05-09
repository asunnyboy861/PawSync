import Foundation

struct SavedAIProfile: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var apiKey: String
    var baseURL: String
    var modelID: String
    var createdAt: Date
    var lastUsedAt: Date?

    init(name: String, apiKey: String, baseURL: String, modelID: String) {
        self.id = UUID().uuidString
        self.name = name
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.modelID = modelID
        self.createdAt = Date()
        self.lastUsedAt = nil
    }

    var maskedApiKey: String {
        guard apiKey.count > 4 else { return "****" }
        return String(repeating: "*", count: apiKey.count - 4) + String(apiKey.suffix(4))
    }

    var providerDisplayName: String {
        if baseURL.contains("api.openai.com") { return "OpenAI" }
        if baseURL.contains("generativelanguage.googleapis.com") { return "Gemini" }
        if baseURL.contains("api.anthropic.com") { return "Claude" }
        if baseURL.contains("api.deepseek.com") { return "DeepSeek" }
        return "Custom"
    }
}

enum AIProfileStorageKey {
    static let profiles = "saved_ai_profiles"
    static let activeProfileId = "active_ai_profile_id"
}

final class AIProfileManager {
    static let shared = AIProfileManager()
    private init() {}

    func loadProfiles() -> [SavedAIProfile] {
        guard let data = UserDefaults.standard.data(forKey: AIProfileStorageKey.profiles),
              let profiles = try? JSONDecoder().decode([SavedAIProfile].self, from: data) else { return [] }
        return profiles
    }

    func saveProfiles(_ profiles: [SavedAIProfile]) {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: AIProfileStorageKey.profiles)
        }
    }

    func getActiveProfileId() -> String? {
        UserDefaults.standard.string(forKey: AIProfileStorageKey.activeProfileId)
    }

    func setActiveProfileId(_ id: String?) {
        UserDefaults.standard.set(id, forKey: AIProfileStorageKey.activeProfileId)
    }

    func addProfile(_ profile: SavedAIProfile) {
        var profiles = loadProfiles()
        profiles.append(profile)
        saveProfiles(profiles)
    }

    func updateProfile(_ profile: SavedAIProfile) {
        var profiles = loadProfiles()
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            saveProfiles(profiles)
        }
    }

    func deleteProfile(withId id: String) {
        var profiles = loadProfiles()
        profiles.removeAll { $0.id == id }
        saveProfiles(profiles)
        if getActiveProfileId() == id { setActiveProfileId(nil) }
    }

    func getProfile(withId id: String) -> SavedAIProfile? {
        loadProfiles().first { $0.id == id }
    }

    func getActiveProfile() -> SavedAIProfile? {
        guard let activeId = getActiveProfileId() else { return nil }
        return getProfile(withId: activeId)
    }
}
