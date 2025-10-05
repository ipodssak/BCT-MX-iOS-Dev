//
//  Bachea_mi_CDMXApp.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

@main
struct Bachea_mi_CDMXApp: App {
    // Integrar el AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
