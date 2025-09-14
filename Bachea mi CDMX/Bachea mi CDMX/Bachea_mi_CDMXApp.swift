//
//  Bachea_mi_CDMXApp.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore

@main
struct Bachea_mi_CDMXApp: App {
    
    init() {
        FirebaseApp.configure()
        
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            fatalError("GoogleService-Info.plist no encontrado o CLIENT_ID faltante")
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        
        Firestore.firestore().settings = settings
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
