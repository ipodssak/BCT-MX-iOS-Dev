//
//  MainAppView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import SwiftUI
import FirebaseAuth

struct MainAppView: View {
    @StateObject private var coordinator = AppNavigationCoordinator()
    
    var body: some View {
        ZStack {
            // Vista de carga
            if coordinator.currentView == .loading {
                AppLoadingView()
            }
            
            // Vista de login
            if coordinator.currentView == .login {
                LoginView()
                    .environmentObject(coordinator.authManager)
            }
            
            // Vista de permisos de ubicación
            if coordinator.currentView == .locationPermission {
                LocationPermissionView(
                    onPermissionGranted: {
                        coordinator.onLocationPermissionGranted()
                    },
                    onSkip: {
                        coordinator.onLocationPermissionSkipped()
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            }
            
            // Vista principal del Home
            if coordinator.currentView == .home {
                HomeView()
                    .environmentObject(coordinator.authManager)
                    .environmentObject(coordinator)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentView)
        .onAppear {
            // Verificar estado inicial
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if coordinator.currentView == .loading {
                    if Auth.auth().currentUser != nil {
                        coordinator.handleSuccessfulLogin()
                    } else {
                        coordinator.currentView = .login
                    }
                }
            }
        }
    }
}

struct AppLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.92, blue: 0.90)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo o icono de la app
                ZStack {
                    Circle()
                        .fill(Color(red: 0.6, green: 0.3, blue: 0.8))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("B")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 16) {
                    Text("BacheaMiCiudad")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.6))
                    
                    Text("Mejorando tu ciudad, un bache a la vez")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Indicador de carga
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.6, green: 0.3, blue: 0.8)))
                    .scaleEffect(1.2)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    MainAppView()
}
