//
//  BreatheAnimationApp.swift
//  BreatheAnimation
//
//  Created by Balaji on 25/07/22.
//

import SwiftUI
import RevenueCat

@main
struct BreatheAnimationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_efRMFHGqntNGOZSNefHbKwdyQlr")
    }
}
