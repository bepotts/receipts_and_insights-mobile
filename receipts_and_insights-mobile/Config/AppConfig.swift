//
//  AppConfig.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/19/26.
//

import Foundation

struct AppConfig {
    static var serverAddress: String {
        guard let serverAddress = Bundle.main.object(forInfoDictionaryKey: "SERVER_ADDRESS") as? String else {
            fatalError("SERVER_ADDRESS not found in Info.plist. Please ensure the xcconfig file is properly configured and the Info.plist contains the SERVER_ADDRESS key.")
        }
        
        guard !serverAddress.isEmpty else {
            fatalError("SERVER_ADDRESS is empty. Please set the SERVER_ADDRESS value in your xcconfig file (Debug.xcconfig or Release.xcconfig).")
        }
        
        return serverAddress
    }
}
