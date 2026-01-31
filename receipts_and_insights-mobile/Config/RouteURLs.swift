//
//  RouteURLs.swift
//  receipts_and_insights-mobile
//
//  Created by Brandon Potts on 1/19/26.
//

import Foundation

enum RouteURLs {
    private static func requiredRoute(for key: String) -> String {
        guard let route = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("\(key) not found in Info.plist. Please ensure the xcconfig file is properly configured and the Info.plist contains the \(key) key.")
        }

        guard !route.isEmpty else {
            fatalError("\(key) is empty. Please set the \(key) value in your xcconfig file (Debug.xcconfig or Release.xcconfig).")
        }

        return route
    }

    static var signUpRoute: String { requiredRoute(for: "SIGN_UP_ROUTE") }

    static var loginRoute: String { requiredRoute(for: "LOGIN_ROUTE") }

    static var signOutRoute: String { requiredRoute(for: "SIGN_OUT_ROUTE") }

    static var photoUploadRoute: String { requiredRoute(for: "PHOTO_UPLOAD_ROUTE") }
}
