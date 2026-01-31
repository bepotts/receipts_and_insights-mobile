//
//  LandingPageView.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/25/26.
//

import os
import SwiftUI

struct LandingPageView: View {
    @EnvironmentObject private var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @State private var showLoginView: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("This is the landing page view.")
                    .font(.title)
                    .padding()

                if let user = userManager.currentUser {
                    VStack(spacing: 8) {
                        Text("Welcome, \(user.fullName)!")
                            .font(.headline)

                        Text("Email: \(user.email)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                    .navigationDestination(isPresented: $showLoginView) {
                        LoginView()
                    }
                }
            }
        }
    }

    private func logout() {
        Task {
            if let sessionToken = userManager.currentUser?.session_token {
                do {
                    try await Networking.signOut(sessionToken: sessionToken)
                } catch {
                    Logger.networking.error("Error during logout: \(error.localizedDescription)")
                }
            }
            await MainActor.run {
                userManager.clearUser()
                showLoginView = true
            }
        }
    }
}

#Preview {
    let userManager = UserManager()
    let sampleUser = User(firstName: "John", lastName: "Doe", email: "john@example.com", session_token: "test_token")
    userManager.setUser(sampleUser)

    return LandingPageView()
        .environmentObject(userManager)
}
