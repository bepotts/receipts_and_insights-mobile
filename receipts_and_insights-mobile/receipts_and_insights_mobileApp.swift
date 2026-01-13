//
//  receipts_and_insights_mobileApp.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/13/26.
//

import SwiftUI
import SwiftData

@main
struct receipts_and_insights_mobileApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
