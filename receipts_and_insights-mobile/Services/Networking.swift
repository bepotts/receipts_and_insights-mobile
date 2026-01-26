//
//  Networking.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/25/26.
//

import Foundation

/// Networking enum that handles all HTTP network requests for the application.
/// Provides static methods for making API calls to the backend server.
enum Networking {
    
    /// Payload structure for user sign-up requests.
    /// Encodes user registration data to be sent to the server as JSON.
    struct SignUpPayload: Encodable {
        let firstName: String
        let lastName: String
        let email: String
        let password: String
        
        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case email
            case password
        }
    }
    
    /// Sends a sign-up request to the server to create a new user account.
    ///
    /// This function makes an HTTP POST request to the login route configured in AppConfig.
    /// The user data is encoded as JSON and sent in the request body.
    ///
    /// - Parameters:
    ///   - firstName: The user's first name
    ///   - lastName: The user's last name
    ///   - email: The user's email address
    ///   - password: The user's password (plain text)
    ///
    /// - Throws: `URLError` if the URL is invalid or the request fails.
    ///           `NSError` with server error message if the server returns a non-2xx status code.
    ///
    /// - Note: The function logs the server address and response details for debugging purposes.
    static func signUp(firstName: String, lastName: String, email: String, password: String) async throws {
        let serverAddress = AppConfig.loginRoute
        print("[signUp] serverAddress: \(serverAddress)")
        
        guard let url = URL(string: "\(serverAddress)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = SignUpPayload(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        let responseBody = String(data: data, encoding: .utf8) ?? "<unable to decode>"
        print("[signUp] Response status: \(httpResponse.statusCode)")
        print("[signUp] Response body: \(responseBody)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorDict["error"] as? String {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            throw URLError(.badServerResponse)
        }
    }
}
