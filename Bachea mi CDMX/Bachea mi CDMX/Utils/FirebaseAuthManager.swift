//
//  FirebaseAuthManager.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 12/09/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore

class FirebaseAuthManager: ObservableObject {
    @Published var isSignedIn = false
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var loginCompleted = false
    
    private let firebaseService = FirebaseService.shared
    
    init() {
        setupAuthStateListener()
    }
    
    // Configura listener para cambios de estado de autenticacion
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener {[weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isSignedIn = user != nil
            }
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            isLoading = false
            errorMessage = "No se pudo obtener la vista principal"
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) {[weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Error al iniciar sesion: \(error.localizedDescription)"
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    self?.errorMessage = "Error al obtener el token de Google"
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { authResult, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self?.errorMessage = "Error al autenticar con Firebase: \(error.localizedDescription)"
                        } else {
                            self?.isSignedIn = true
                            self?.user = authResult?.user
                            self?.loginCompleted = true
                            
                            if let user = authResult?.user {
                                self?.checkUserExist(user: user)
                            } else {
                                print("❌ No se pudo obtener el usuario autenticado")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Cerrar sesion
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            isSignedIn = false
            user = nil
            loginCompleted = false
        } catch {
            errorMessage = "Error al cerrar sesion: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Firestore User Registration
    
    /// Comprobacion de documentos
    private func checkUserExist(user: User) {
        firebaseService.getUsers(uid: user.uid) { response in
            switch response {
            case .success(let result):
                if result {
                    self.updateUserTimestamp(user: user)
                } else {
                    self.createNewUserInFirestore(user: user)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    /// Registra un usuario en Firestore después del login exitoso
    private func registerUserInFirestore(user: User) {
        createNewUserInFirestore(user: user)
    }
    
    /// Crea un nuevo usuario en Firestore
    private func createNewUserInFirestore(user: User) {
        // Obtener información adicional del usuario de Google
        let displayName = user.displayName ?? "Usuario"
        let email = user.email ?? ""
        let photoURL = user.photoURL?.absoluteString ?? ""
        
        let appUser = AppUser(
            authProvider: "google",
            email: email,
            name: displayName,
            profileImageUrl: photoURL,
            uid: user.uid
        )
        
        firebaseService.createUser(appUser) { [weak self] result in
            switch result {
            case .success:
                print("🎉 Usuario registrado exitosamente en Firestore")
            case .failure(let error):
                print("❌ Error registrando usuario en Firestore: \(error.localizedDescription)")
                self?.errorMessage = "Error al registrar usuario: \(error.localizedDescription)"
            }
        }
    }
    
    /// Método de prueba para verificar conexión con Firestore
    private func testFirestoreConnection() {
        print("🧪 Probando conexión con Firestore...")
        let db = Firestore.firestore()
        
        // Test simple: escribir un documento de prueba
        db.collection("test").document("connection").setData([
            "timestamp": Timestamp(date: Date()),
            "test": "connection"
        ]) { error in
            if let error = error {
                print("❌ Error en test de conexión Firestore: \(error.localizedDescription)")
            } else {
                print("✅ Test de conexión Firestore exitoso")
            }
        }
    }
    
    /// Actualiza el timestamp de último acceso para usuarios existentes
    private func updateUserTimestamp(user: User) {
        firebaseService.getUser(uid: user.uid) { [weak self] result in
            switch result {
            case .success(let appUser):
                let updatedUser = appUser.withUpdatedTimestamp()
                self?.firebaseService.updateUser(updatedUser) { updateResult in
                    switch updateResult {
                    case .success:
                        print("Timestamp de usuario actualizado")
                    case .failure(let error):
                        print("Error actualizando timestamp: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error obteniendo usuario para actualizar timestamp: \(error.localizedDescription)")
            }
        }
    }
}
