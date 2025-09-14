//
//  ProfileView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 14/09/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack(spacing: 30) {
                    ScrollView {
                        headerProfileView()
                        
                        profileCard()
                        
                        donationView()
                        
                        ShakeSettingsView()
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct headerProfileView: View {
    var body: some View {
        HStack {
            Text("Perfil")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

struct profileCard: View {
    @StateObject private var authManager = FirebaseAuthManager()
    
    var body: some View {
        VStack(spacing: 16) {
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
                        .foregroundColor(.black)
                    
                    Text(authManager.user?.email ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                            Text("Cerrar Sesíon")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                    .padding(20)
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(20)
    }
}

struct donationView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("¡Ayuda a mejorar nuestra ciudad!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            Text("Tu donación contribuye directamente a mejorar los desarrollos que eficienten la reapacioón de nuestra ciudad")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            Button(action: {
                print("Donando....")
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.white)
                    Text("¡Quiero donar!")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.yellow)
                .cornerRadius(8)
            }
            
            Text("¡Gracias por ayudar a hacer nuestra ciudad un mejor lugar para todos!")
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("0 donaciones realizadas")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.3))
            .cornerRadius(16)
        }
        .padding(20)
        .background(Color.blue)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

struct ShakeSettingsView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sensibilidad al Shake")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text("Configuración actual: \(viewModel.shakeSensitivity.title)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            VStack(spacing: 20) {
                ForEach(ShakeSensitivity.allCases, id: \.self) { sensitivity in
                    Button(action: {
                        viewModel.updateShakeSensitivity(sensitivity)
                    }) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color(sensitivity.color))
                                .frame(width: 20, height: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sensitivity.title)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Text(sensitivity.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            if viewModel.shakeSensitivity == sensitivity {
                                Image(systemName: "checkmark")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(viewModel.shakeSensitivity == sensitivity ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("Sacude tu dispositivo para reportar automáticamente")
                    .font(.subheadline)
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

struct Profile_Previous: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
