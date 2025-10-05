//
//  LocationPermissionCoordinator.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import SwiftUI
import CoreLocation

class LocationPermissionCoordinator: ObservableObject {
    @Published var showLocationPermission = false
    @Published var hasLocationPermission = false
    
    func checkLocationPermission() {
        let status = CLLocationManager().authorizationStatus
        hasLocationPermission = status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    func requestLocationPermission() {
        showLocationPermission = true
    }
    
    func onPermissionGranted() {
        hasLocationPermission = true
        showLocationPermission = false
        // Aquí puedes navegar a la siguiente pantalla o realizar otras acciones
        print("✅ Permisos de ubicación concedidos")
    }
    
    func onSkipPermission() {
        showLocationPermission = false
        // Continuar sin permisos de ubicación
        print("⏭️ Usuario decidió configurar más tarde")
    }
}

// Ejemplo de uso en una vista principal
struct MainView: View {
    @StateObject private var locationCoordinator = LocationPermissionCoordinator()
    @StateObject private var authManager = FirebaseAuthManager()
    
    var body: some View {
        Group {
            if authManager.isSignedIn {
                // Vista principal de la app
                HomeView()
                    .onAppear {
                        locationCoordinator.checkLocationPermission()
                        if !locationCoordinator.hasLocationPermission {
                            // Mostrar permisos de ubicación después del login
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                locationCoordinator.requestLocationPermission()
                            }
                        }
                    }
            } else {
                // Vista de login
                LoginView()
            }
        }
        .sheet(isPresented: $locationCoordinator.showLocationPermission) {
            LocationPermissionView(
                onPermissionGranted: {
                    locationCoordinator.onPermissionGranted()
                },
                onSkip: {
                    locationCoordinator.onSkipPermission()
                }
            )
        }
    }
}
