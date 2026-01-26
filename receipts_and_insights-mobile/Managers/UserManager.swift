//
//  UserManager.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/26/26.
//

import Foundation
import Combine
import SwiftUI

/// ObservableObject that manages the current user state throughout the application.
/// This allows the user to be accessed from any view via the environment.
@MainActor
class UserManager: ObservableObject {
    @Published var currentUser: User?
    
    /// Sets the current user after successful login/sign-up
    func setUser(_ user: User) {
        currentUser = user
    }
    
    /// Clears the current user (for logout)
    func clearUser() {
        currentUser = nil
    }
    
    /// Checks if a user is currently logged in
    var isLoggedIn: Bool {
        currentUser != nil
    }
}
