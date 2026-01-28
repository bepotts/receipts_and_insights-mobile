//
//  RouteURLs.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/19/26.
//

import Foundation

enum RouteURLs {

    static var signUpRoute: String {
        guard let createUserRoute = Bundle.main.object(forInfoDictionaryKey: "CREATE_USER_ROUTE") as? String else {
            fatalError("CREATE_USER_ROUTE not found in Info.plist. Please ensure the xcconfig file is properly configured and the Info.plist contains the CREATE_USER_ROUTE key.")
        }

        guard !createUserRoute.isEmpty else {
            fatalError("CREATE_USER_ROUTE is empty. Please set the CREATE_USER_ROUTE value in your xcconfig file (Debug.xcconfig or Release.xcconfig).")
        }

        return createUserRoute
    }

    static var loginRoute: String {
        guard let loginRoute = Bundle.main.object(forInfoDictionaryKey: "LOGIN_ROUTE") as? String else {
            fatalError("LOGIN_ROUTE not found in Info.plist. Please ensure the xcconfig file is properly configured and the Info.plist contains the CREATE_USER_ROUTE key.")
        }

        guard !loginRoute.isEmpty else {
            fatalError("LOGIN_ROUTE is empty. Please set the LOGIN_ROUTE value in your xcconfig file (Debug.xcconfig or Release.xcconfig).")
        }

        return loginRoute
    }
}
