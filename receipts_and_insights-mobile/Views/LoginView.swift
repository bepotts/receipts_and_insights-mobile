//
//  LoginView.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/28/26.
//

import SwiftData
import SwiftUI

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var userManager: UserManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var showLandingPage: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView

                    // Form Fields
                    formFieldsView

                    // Error Message
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }

                    // Sign Up Button
                    signUpButton

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showLandingPage) {
            LandingPageView()
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Sign in with your email and password")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.subheadline)
                .fontWeight(.medium)

            TextField("Enter your email", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.subheadline)
                .fontWeight(.medium)

            SecureField("Enter your password", text: $password)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(.password)
        }
    }

    private var formFieldsView: some View {
        VStack(spacing: 16) {
            // Email
            emailField

            // Password
            passwordField
        }
        .padding(.horizontal, 24)
    }

    private var signUpButton: some View {
        Button(action: {
            Task {
                await signInUser()
            }
        }) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            } else {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
        .background(Color.blue)
        .cornerRadius(12)
        .disabled(isLoading)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private func signInUser() async {
        // Reset error state
        showError = false
        errorMessage = ""
        isLoading = true

        defer {
            isLoading = false
        }

        // Validate inputs
        guard !email.isEmpty else {
            showError(message: "Please enter your email")
            return
        }

        guard isValidEmail(email) else {
            showError(message: "Please enter a valid email address")
            return
        }

        guard !password.isEmpty else {
            showError(message: "Please enter a password")
            return
        }

        guard password.count >= 8 else {
            showError(message: "Password must be at least 8 characters")
            return
        }

        // Make HTTP POST request to sign in
        do {
            let user = try await Networking.signIn(email: email, password: password)

            // Save to SwiftData
            modelContext.insert(user)

            // Set the user in UserManager so it can be accessed throughout the app
            userManager.setUser(user)

            // Navigate to landing page on success
            showLandingPage = true

        } catch {
            showError(message: "Failed to sign in: \(error.localizedDescription)")
        }
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    LoginView()
        .modelContainer(for: User.self, inMemory: true)
        .environmentObject(UserManager())
}
