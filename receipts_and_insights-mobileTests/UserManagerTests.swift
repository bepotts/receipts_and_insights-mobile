//
//  UserManagerTests.swift
//  receipts_and_insights-mobileTests
//
//  Created by Brandon Potts on 1/26/26.
//

import Foundation
@testable import receipts_and_insights_mobile
import SwiftData
import Testing

/// Test suite for the UserManager class.
/// Verifies that user state management works correctly, including setting, clearing, and checking login status.
struct UserManagerTests {
    /// Tests that UserManager is initialized with no current user
    /// and that isLoggedIn returns false initially.
    @Test func initialState() async throws {
        let userManager = await UserManager()

        #expect(await userManager.currentUser == nil)
        #expect(await userManager.isLoggedIn == false)
    }

    /// Tests that setUser correctly sets the current user
    /// and updates the isLoggedIn status to true.
    @Test func testSetUser() async throws {
        let userManager = await UserManager()
        let testUser = User(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            session_token: "test_token"
        )

        await userManager.setUser(testUser)

        #expect(await userManager.currentUser?.email == testUser.email)
        #expect(await userManager.currentUser?.firstName == testUser.firstName)
        #expect(await userManager.currentUser?.lastName == testUser.lastName)
        #expect(await userManager.isLoggedIn == true)
    }

    /// Tests that clearUser removes the current user
    /// and updates the isLoggedIn status to false.
    @Test func testClearUser() async throws {
        let userManager = await UserManager()
        let testUser = User(
            firstName: "Jane",
            lastName: "Smith",
            email: "jane.smith@example.com",
            session_token: "test_token"
        )

        await userManager.setUser(testUser)
        #expect(await userManager.isLoggedIn == true)

        await userManager.clearUser()

        #expect(await userManager.currentUser == nil)
        #expect(await userManager.isLoggedIn == false)
    }

    /// Tests that isLoggedIn correctly reflects the user state
    /// when transitioning between logged in and logged out states.
    @Test func testIsLoggedIn() async throws {
        let userManager = await UserManager()
        let testUser = User(
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            session_token: "test_token"
        )

        #expect(await userManager.isLoggedIn == false)

        await userManager.setUser(testUser)
        #expect(await userManager.isLoggedIn == true)

        await userManager.clearUser()
        #expect(await userManager.isLoggedIn == false)
    }
}
