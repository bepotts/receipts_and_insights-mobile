//
//  LandingPageView.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/25/26.
//

import os
import PhotosUI
import SwiftUI

struct LandingPageView: View {
    @EnvironmentObject private var userManager: UserManager
    @Environment(\.dismiss) private var dismiss
    @State private var showLoginView: Bool = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var isUploading: Bool = false
    @State private var uploadError: String?

    var body: some View {
        NavigationView {
            VStack {
                Text("This is the landing page view.")
                    .font(.title)
                    .padding()

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Upload Photo", systemImage: "photo.on.rectangle.angled")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isUploading || userManager.currentUser == nil)
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        await uploadSelectedPhoto(newItem)
                    }
                }

                if isUploading {
                    ProgressView("Uploading...")
                        .padding()
                }

                if let error = uploadError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }

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

    private func uploadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let sessionToken = userManager.currentUser?.session_token else {
            await MainActor.run { uploadError = "Not logged in" }
            return
        }

        await MainActor.run {
            isUploading = true
            uploadError = nil
        }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                try await Networking.uploadPhoto(imageData: data, sessionToken: sessionToken)
                Logger.networking.info("[LandingPageView] Photo uploaded successfully")
            } else {
                await MainActor.run { uploadError = "Could not load photo" }
            }
        } catch {
            Logger.networking.error("Error uploading photo: \(error.localizedDescription)")
            await MainActor.run { uploadError = error.localizedDescription }
        }

        await MainActor.run {
            isUploading = false
            selectedItem = nil
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
