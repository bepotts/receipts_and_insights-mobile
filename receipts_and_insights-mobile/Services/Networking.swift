//
//  Networking.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/25/26.
//

import Foundation

enum Networking {
    
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
