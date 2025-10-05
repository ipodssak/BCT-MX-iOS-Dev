//
//  AppDelegate.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configurar Firebase PRIMERO
        FirebaseApp.configure()
        
        // Configurar Firestore DESPUÉS de Firebase
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        
        // Configurar Google Sign-In
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            fatalError("GoogleService-Info.plist no encontrado o CLIENT_ID faltante")
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        
        return true
    }
    
    // Manejar URLs para Google Sign-In
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // Métodos adicionales requeridos por UIApplicationDelegate
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Opcional: código para cuando la app se vuelve activa
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Opcional: código para cuando la app va a ser inactiva
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Opcional: código para cuando la app entra en background
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Opcional: código para cuando la app va a entrar en foreground
    }
}
