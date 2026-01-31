//
//  Networking.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/25/26.
//

import Foundation
import os

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

    /// Payload structure for user sign-in requests.
    /// Encodes user login credentials to be sent to the server as JSON.
    struct SignInPayload: Encodable {
        let email: String
        let password: String
    }

    /// Payload structure for sign-out requests.
    /// Encodes the session token to be sent to the server as JSON.
    struct SignOutPayload: Encodable {
        let sessionToken: String

        enum CodingKeys: String, CodingKey {
            case sessionToken = "session_token"
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
    /// - Returns: A `User` object containing the created user's information and session token
    ///
    /// - Throws: `URLError` if the URL is invalid or the request fails.
    ///           `NSError` with server error message if the server returns a non-2xx status code.
    ///
    /// - Note: The function logs the server address and response details for debugging purposes.
    static func userSignUp(firstName: String, lastName: String, email: String, password: String) async throws -> User {
        let signUpRoute = RouteURLs.signUpRoute
        Logger.networking.info("[signUp] serverAddress: \(signUpRoute)")

        guard let url = URL(string: "\(signUpRoute)") else {
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
        Logger.networking.info("[signUp] Response status: \(httpResponse.statusCode)")
        Logger.networking.info("[signUp] Response body: \(responseBody)")

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorDict["error"] as? String
            {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            throw URLError(.badServerResponse)
        }

        // Parse the response to extract user data and session token
        if let userDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let sessionToken = userDict["session_token"] as? String ?? userDict["sessionToken"] as? String ?? ""

            // Create and return user object
            return User(firstName: firstName, lastName: lastName, email: email, session_token: sessionToken)
        }

        // If response doesn't contain user data, throw an error
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server response does not contain user data"])
    }

    /// Sends a sign-in request to the server to authenticate a user.
    ///
    /// This function makes an HTTP POST request to the sign-in route configured in AppConfig.
    /// The user credentials are encoded as JSON and sent in the request body.
    ///
    /// - Parameters:
    ///   - email: The user's email address
    ///   - password: The user's password (plain text)
    ///
    /// - Returns: A `User` object containing the authenticated user's information
    ///
    /// - Throws: `URLError` if the URL is invalid or the request fails.
    ///           `NetworkError.unauthorized` if the server returns 401.
    ///           `NSError` with server error message if the server returns another non-2xx status code.
    ///
    /// - Note: The function logs the server address and response details for debugging purposes.
    static func userLogin(email: String, password: String) async throws -> User {
        let loginRoute = RouteURLs.loginRoute
        Logger.networking.info("[signIn] loginRouteAddress: \(loginRoute)")

        guard let url = URL(string: "\(loginRoute)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = SignInPayload(email: email, password: password)
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let responseBody = String(data: data, encoding: .utf8) ?? "<unable to decode>"
        Logger.networking.info("[signIn] Response status: \(httpResponse.statusCode)")
        Logger.networking.info("[signIn] Response body: \(responseBody)")

        if httpResponse.statusCode == 401 {
            throw NetworkError.unauthorized
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorDict["error"] as? String
            {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            throw URLError(.badServerResponse)
        }

        // Parse the response to extract user data and session token
        // Assuming the server returns user data in the response
        if let userDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let firstName = userDict["first_name"] as? String ?? userDict["firstName"] as? String ?? ""
            let lastName = userDict["last_name"] as? String ?? userDict["lastName"] as? String ?? ""
            let userEmail = userDict["email"] as? String ?? email
            let sessionToken = userDict["session_token"] as? String ?? userDict["sessionToken"] as? String ?? ""

            // Create and return user object
            return User(firstName: firstName, lastName: lastName, email: userEmail, session_token: sessionToken)
        }

        // If response doesn't contain user data, throw an error
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Server response does not contain user data"])
    }

    /// Sends a sign-out request to the server with the user's session token.
    ///
    /// - Parameter sessionToken: The user's session token to invalidate.
    /// - Throws: `URLError` if the URL is invalid or the request fails.
    ///           `NSError` with server error message if the server returns a non-2xx status code.
    static func signOut(sessionToken: String) async throws {
        let signOutRoute = RouteURLs.signOutRoute
        Logger.networking.info("[signOut] serverAddress: \(signOutRoute)")

        guard let url = URL(string: signOutRoute) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = SignOutPayload(sessionToken: sessionToken)
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let responseBody = String(data: data, encoding: .utf8) ?? "<unable to decode>"
        Logger.networking.info("[signOut] Response status: \(httpResponse.statusCode)")
        Logger.networking.info("[signOut] Response body: \(responseBody)")

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorDict["error"] as? String
            {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            throw URLError(.badServerResponse)
        }
    }

    /// Uploads a photo to the server.
    ///
    /// - Parameters:
    ///   - imageData: The image data to upload.
    ///   - sessionToken: The user's session token for authentication.
    ///
    /// - Throws: `URLError` if the URL is invalid or the request fails.
    ///           `NSError` with server error message if the server returns a non-2xx status code.
    static func uploadPhoto(imageData: Data, sessionToken: String) async throws {
        let photoUploadRoute = RouteURLs.photoUploadRoute
        Logger.networking.info("[uploadPhoto] serverAddress: \(photoUploadRoute)")

        guard let url = URL(string: photoUploadRoute) else {
            throw URLError(.badURL)
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(sessionToken, forHTTPHeaderField: "Authorization")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"receipt.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let responseBody = String(data: data, encoding: .utf8) ?? "<unable to decode>"
        Logger.networking.info("[uploadPhoto] Response status: \(httpResponse.statusCode)")
        Logger.networking.info("[uploadPhoto] Response body: \(responseBody)")

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorDict["error"] as? String
            {
                throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            throw URLError(.badServerResponse)
        }
    }
}
