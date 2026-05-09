import Foundation

final class OpenAIService {
    private let configuration: AIConfiguration

    init(configuration: AIConfiguration) {
        self.configuration = configuration
    }

    struct CompletionResponse: Codable {
        let choices: [Choice]
        struct Choice: Codable { let message: Message }
        struct Message: Codable { let content: String }
    }

    func complete(prompt: String) async throws -> String {
        guard configuration.isValidBaseURL,
              let url = URL(string: configuration.baseURL) else {
            throw OpenAIError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": configuration.modelID,
            "messages": [
                ["role": "system", "content": "You are a veterinary health assistant for the PawSync pet health app. Provide helpful, accurate pet health advice. Always remind users to consult their veterinarian for medical concerns. Respond with valid JSON when structured data is requested."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 4096
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let session = URLSession(configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 60
        session.configuration.timeoutIntervalForResource = 120

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw OpenAIError.invalidResponse(statusCode: statusCode)
        }

        let decoded = try JSONDecoder().decode(CompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw OpenAIError.noContent
        }
        return content
    }

    func completeWithSystemPrompt(_ systemPrompt: String, userPrompt: String) async throws -> String {
        guard configuration.isValidBaseURL,
              let url = URL(string: configuration.baseURL) else {
            throw OpenAIError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": configuration.modelID,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "temperature": 0.7,
            "max_tokens": 4096
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let session = URLSession(configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 60
        session.configuration.timeoutIntervalForResource = 120

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw OpenAIError.invalidResponse(statusCode: statusCode)
        }

        let decoded = try JSONDecoder().decode(CompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw OpenAIError.noContent
        }
        return content
    }

    func testConnection() async throws -> String {
        guard configuration.isValidBaseURL,
              let url = URL(string: configuration.baseURL) else {
            throw OpenAIError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": configuration.modelID,
            "messages": [["role": "user", "content": "Reply with exactly: OK"]],
            "max_tokens": 10
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let session = URLSession(configuration: .ephemeral)
        session.configuration.timeoutIntervalForRequest = 15
        session.configuration.timeoutIntervalForResource = 30

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw OpenAIError.invalidResponse(statusCode: statusCode)
        }

        let decoded = try JSONDecoder().decode(CompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw OpenAIError.noContent
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    enum OpenAIError: LocalizedError {
        case invalidBaseURL
        case invalidResponse(statusCode: Int)
        case noContent
        case timeout

        var errorDescription: String? {
            switch self {
            case .invalidBaseURL: "Invalid API URL. Please check your configuration."
            case .invalidResponse(let statusCode): "API request failed (status \(statusCode)). Check your API key and endpoint."
            case .noContent: "No content in AI response. Please try again."
            case .timeout: "Request timed out. Check your network and API endpoint."
            }
        }
    }
}
