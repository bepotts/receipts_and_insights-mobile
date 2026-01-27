//
//  UserTests.swift
//  receipts_and_insights-mobileTests
//
//  Created by Brandon Potts on 1/26/26.
//

import Foundation
@testable import receipts_and_insights_mobile
import SwiftData
import Testing

/// Test suite for the User model.
/// Verifies that User instances are correctly initialized and computed properties work as expected.
struct UserTests {
    /// Tests that a User can be initialized with all required properties
    /// and that all properties are correctly assigned, including the automatic creation timestamp.
    @Test func userInitialization() async throws {
        let firstName = "John"
        let lastName = "Doe"
        let email = "john.doe@example.com"
        let password = "password123"

        let user = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )

        #expect(user.firstName == firstName)
        #expect(user.lastName == lastName)
        #expect(user.email == email)
        #expect(user.password == password)
        #expect(user.createdAt <= Date())
    }

    /// Tests that the fullName computed property correctly concatenates
    /// the firstName and lastName properties with a space between them.
    @Test func testFullName() async throws {
        let user = User(
            firstName: "Jane",
            lastName: "Smith",
            email: "jane.smith@example.com",
            password: "password"
        )

        #expect(user.fullName == "Jane Smith")
    }
}
