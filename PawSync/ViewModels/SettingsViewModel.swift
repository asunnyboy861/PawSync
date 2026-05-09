import SwiftUI

@Observable
final class SettingsViewModel {
    var apiKey = ""
    var baseURL = "https://api.openai.com/v1/chat/completions"
    var modelID = "gpt-4o-mini"
    var isTestingConnection = false
    var connectionTestResult: ConnectionTestResult?
    var savedProfiles: [SavedAIProfile] = []
    var selectedPreset: AIPreset? = AIConfiguration.presets.first
    var isApiKeyVisible = true
    var newProfileName = ""
    var showProfileSheet = false
    var showDeleteConfirmation = false
    var profileToDelete: SavedAIProfile?

    var activeProfileId: String? {
        AIProfileManager.shared.getActiveProfileId()
    }

    enum ConnectionTestResult {
        case success
        case failure(String)
    }

    var aiConfiguration: AIConfiguration {
        AIConfiguration(apiKey: apiKey, baseURL: baseURL, modelID: modelID)
    }

    func testConnection() async {
        isTestingConnection = true
        connectionTestResult = nil
        let config = AIConfiguration(apiKey: apiKey, baseURL: baseURL, modelID: modelID)
        let service = OpenAIService(configuration: config)
        do {
            let response = try await service.testConnection()
            if response.contains("OK") {
                connectionTestResult = .success
            } else {
                connectionTestResult = .failure("Unexpected response: \(response)")
            }
        } catch {
            connectionTestResult = .failure(error.localizedDescription)
        }
        isTestingConnection = false
    }

    func saveCurrentAsProfile(name: String) {
        let profile = SavedAIProfile(name: name, apiKey: apiKey, baseURL: baseURL, modelID: modelID)
        AIProfileManager.shared.addProfile(profile)
        AIProfileManager.shared.setActiveProfileId(profile.id)
        loadSavedProfiles()
        resetInputFields()
    }

    func activateProfile(_ profile: SavedAIProfile) {
        apiKey = profile.apiKey
        baseURL = profile.baseURL
        modelID = profile.modelID
        AIProfileManager.shared.setActiveProfileId(profile.id)
    }

    func resetInputFields() {
        apiKey = ""
        selectedPreset = AIConfiguration.presets.first
        baseURL = selectedPreset?.baseURL ?? "https://api.openai.com/v1/chat/completions"
        modelID = selectedPreset?.modelID ?? "gpt-4o-mini"
        connectionTestResult = nil
        isApiKeyVisible = true
    }

    func loadSavedProfiles() {
        savedProfiles = AIProfileManager.shared.loadProfiles()
    }
}
