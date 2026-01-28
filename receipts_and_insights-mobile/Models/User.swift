//
//  User.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/19/26.
//

import Foundation
import SwiftData

@Model
final class User {
    var firstName: String
    var lastName: String
    var email: String
    var session_token: String

    init(firstName: String, lastName: String, email: String, session_token: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.session_token = session_token
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
