//
//  GestifyApp.swift
//  Gestify
//
//  Created by Ni Komang Ayu Juliana on 13/09/26.
//

import SwiftUI
import TipKit

@main
struct GestifyApp: App {
    @StateObject private var settings = AppSettings()

    init() {
        try? Tips.resetDatastore() 
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)  
        }
    }
}
