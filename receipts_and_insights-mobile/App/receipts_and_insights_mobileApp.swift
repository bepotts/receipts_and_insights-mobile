//
//  receipts_and_insights_mobileApp.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/13/26.
//

import SwiftData
import SwiftUI

@main
struct receipts_and_insights_mobileApp: App {
    @StateObject private var userManager = UserManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(userManager)
    }
}
