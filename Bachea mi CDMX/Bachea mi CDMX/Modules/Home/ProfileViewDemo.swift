//
//  HomeView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileViewDemo: View {
    @StateObject private var authManager = FirebaseAuthManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    AsyncImage(url: URL(string: authManager.user?.photoURL?.absoluteString ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    
                    VStack(spacing: 8) {
                        Text(authManager.user?.displayName ?? "Usuario")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(authManager.user?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("¡Bienvenido a Bachea tu Ciudad!")
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Has iniciado sesion exitosamente con Google")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        FeatureCard(
                            icon: "star.fill",
                            title: "Favoritos",
                            description: "Gestiona tus elementos favoritos"
                        )
                        
                        FeatureCard(
                            icon: "gear",
                            title: "Configuracion",
                            description: "Personaliza tu experiencia"
                        )
                        
                        FeatureCard(
                            icon: "bell.fill",
                            title: "Notificaciones",
                            description: "Mantente informado"
                        )
                        
                        FeatureCard(
                            icon: "person.2.fill",
                            title: "Perfil",
                            description: "Gestiona tu informacion"
                        )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    authManager.signOut()
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Cerrar sesion")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProfileDemo_Previous: PreviewProvider {
    static var previews: some View {
        ProfileViewDemo()
    }
}
