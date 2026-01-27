//
//  LoginView.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/19/26.
//

import SwiftUI
import SwiftData
import CryptoKit

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var userManager: UserManager
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConfirmation: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false
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
                    
                    // Success Message
                    if showSuccess {
                        Text("Account created successfully!")
                            .font(.caption)
                            .foregroundColor(.green)
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
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Sign up to get started")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
    
    private var firstNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("First Name")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("Enter your first name", text: $firstName)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(.givenName)
                .autocapitalization(.words)
        }
    }
    
    private var lastNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last Name")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("Enter your last name", text: $lastName)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(.familyName)
                .autocapitalization(.words)
        }
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
                .textContentType(.newPassword)
        }
    }
    
    private var passwordConfirmationField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Confirm Password")
                .font(.subheadline)
                .fontWeight(.medium)
            
            SecureField("Confirm your password", text: $passwordConfirmation)
                .textFieldStyle(CustomTextFieldStyle())
                .textContentType(.newPassword)
        }
    }
    
    private var formFieldsView: some View {
        VStack(spacing: 16) {
            // First Name
            firstNameField
            
            // Last Name
            lastNameField
            
            // Email
            emailField
            
            // Password
            passwordField
            
            // Password Confirmation
            passwordConfirmationField
        }
        .padding(.horizontal, 24)
    }
    
    private var signUpButton: some View {
        Button(action: {
            Task {
                await signUp()
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
    
    private func signUp() async {
        // Reset error state
        showError = false
        errorMessage = ""
        showSuccess = false
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        // Validate inputs
        guard !firstName.isEmpty else {
            showError(message: "Please enter your first name")
            return
        }
        
        guard !lastName.isEmpty else {
            showError(message: "Please enter your last name")
            return
        }
        
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
        
        guard password == passwordConfirmation else {
            showError(message: "Passwords do not match")
            return
        }
        
        // Make HTTP POST request
        do {
            try await Networking.signUp(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: password
            )
            
            // Hash the password for local storage
            let hashedPassword = hashPassword(password)
            
            // Create new user
            let newUser = User(
                firstName: firstName,
                lastName: lastName,
                email: email,
                password: hashedPassword
            )
            
            // Save to SwiftData (password won't be persisted due to @Transient)
            modelContext.insert(newUser)
            
            // Set the user in UserManager so it can be accessed throughout the app
            userManager.setUser(newUser)
            
            // Navigate to landing page
            showLandingPage = true
            
        } catch {
            showError(message: "Failed to create account: \(error.localizedDescription)")
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
    
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

#Preview {
    LoginView()
        .modelContainer(for: User.self, inMemory: true)
        .environmentObject(UserManager())
}
