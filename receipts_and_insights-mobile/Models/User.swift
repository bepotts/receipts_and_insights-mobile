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
    
    @Transient
    var password: String = ""
    
    var createdAt: Date
    
    init(firstName: String, lastName: String, email: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.createdAt = Date()
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
