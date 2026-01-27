//
//  Logs.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/26/26.
//

import os

extension Logger {
    static let notes: Logger = .init(subsystem: AppStrings.bundle, category: "notes")

    static let users: Logger = .init(subsystem: AppStrings.bundle, category: "users")

    static let networking: Logger = .init(subsystem: AppStrings.bundle, category: "networking")
}
