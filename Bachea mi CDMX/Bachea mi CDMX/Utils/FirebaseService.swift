//
//  FirebaseService.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 13/09/25.
//

import Foundation
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchMunicipalities(completion: @escaping (Result<[Municipality], Error>) -> Void) {
        db.collection("locations")//cambiar por toda la url de las collecciones
            .order(by: "reportCount", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success(Municipality.sampleData))
                    return
                }
                
                var municipalities: [Municipality] = []
                for (index, document) in documents.enumerated() {
                    let data = document.data()
                    
                    let municipality = Municipality(
                        name: data["name"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        reportCount: data["reportCount"] as? Int ?? 0,
                        lastReportDate: (data["lastReportDate"] as? Timestamp)?.dateValue() ?? Date(),
                        rank: index + 1
                    )
                    municipalities.append(municipality)
                }
                completion(.success(municipalities))
            }
    }
    
    func fetchMunicipalitiesByState(_ state: String, completion: @escaping (Result<[Municipality], Error>) -> Void) {
        db.collection("municipalities")
            .whereField("state", isEqualTo: state)
            .order(by: "reportCount", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                var municipalities: [Municipality] = []
                for (index, document) in documents.enumerated() {
                    let data = document.data()
                    
                    let municipality = Municipality(
                        name: data["name"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        reportCount: data["reportCount"] as? Int ?? 0,
                        lastReportDate: (data["lastReportDate"] as? Timestamp)?.dateValue() ?? Date(),
                        rank: index + 1
                    )
                    municipalities.append(municipality)
                }
                completion(.success(municipalities))
            }
    }
    
    func fetchGeneralStatistics(completion: @escaping (Result<GeneralStatistics, Error>) -> Void) {
        db.collection("statistics")
            .document("general")
            .getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = document?.data() else {
                    completion(.failure(FirebaseError.documentNotFound))
                    return
                }
                
                let statistics = GeneralStatistics(
                    totalReports: data["totalReports"] as? Int ?? 0,
                    totalMunicipalities: data["totalMunicipalities"] as? Int ?? 0,
                    averageReports: data["averageReports"] as? Double ?? 0.0,
                    leadingMunicipality: data["leadingMunicipality"] as? String ?? "",
                    leadingReport: data["leadingReports"] as? Int ?? 0
                )
                
                completion(.success(statistics))
            }
    }
    
    func listenToMunicipalities(completion: @escaping (Result<[Municipality], Error>) -> Void) -> ListenerRegistration {
        return db.collection("municipalities")
            .order(by: "reportCount", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                var municipalities: [Municipality] = []
                for (index, document) in documents.enumerated() {
                    let data = document.data()
                    
                    let municipality = Municipality(
                        name: data["name"] as? String ?? "",
                        state: data["state"] as? String ?? "",
                        reportCount: data["reportCount"] as? Int ?? 0,
                        lastReportDate: (data["lastReportDate"] as? Timestamp)?.dateValue() ?? Date(),
                        rank: index + 1
                    )
                    municipalities.append(municipality)
                }
                completion(.success(municipalities))
                
            }
    }
    
    func listenToStatitics(completion: @escaping (Result<GeneralStatistics, Error>) -> Void) -> ListenerRegistration {
        return db.collection("statistics")
            .document("general")
            .addSnapshotListener { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = document?.data() else {
                    completion(.failure(FirebaseError.documentNotFound))
                    return
                }
                
                let statistics = GeneralStatistics(
                    totalReports: data["totalReports"] as? Int ?? 0,
                    totalMunicipalities: data["totalMunicipalities"] as? Int ?? 0,
                    averageReports: data["averageReports"] as? Double ?? 0.0,
                    leadingMunicipality: data["leadingMunicipality"] as? String ?? "",
                    leadingReport: data["leadingReports"] as? Int ?? 0
                )
                
                completion(.success(statistics))
            }
    }
    
    
    // MARK: - User Management Methods
    
    func getUsers(uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            db.collection("users").document(uid).getDocument { [weak self] documentSnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    print("ERROR")
                }
                
                guard let document = documentSnapshot else {
                    completion(.success(false))
                    print("NOT DOCUMENT")
                    return
                }
                
                if document.exists {
                    completion(.success(true))
                    print("USER EXIST")
                } else {
                    completion(.success(false))
                }
            }
        }
    }
    
    /// Registra un nuevo usuario en Firestore
    func createUser(_ user: AppUser, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let userData = try Firestore.Encoder().encode(user)
            print("✅ Datos del usuario codificados correctamente")
            
            // Crear el documento del usuario
            db.collection("users")
                .document(user.uid)
                .setData(userData) { error in
                    if let error = error {
                        print("❌ Error creando documento de usuario: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        // Crear subcolección locations dentro del documento del usuario
                        self.createLocationsSubcollection(for: user.uid) { result in
                            switch result {
                            case .success:
                                completion(.success(()))
                            case .failure(let error):
                                print("❌ Error creando subcolección locations: \(error.localizedDescription)")
                                completion(.failure(error))
                            }
                        }
                    }
                }
        } catch {
            print("❌ Error codificando datos del usuario: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    /// Crea la subcolección locations para un usuario
    private func createLocationsSubcollection(for uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Crear un documento inicial en la subcolección locations
        let initialLocationData: [String: Any] = [
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date()),
            "isInitialDocument": true
        ]
        
        db.collection("users")
            .document(uid)
            .collection("locations")
            .document("initial")
            .setData(initialLocationData) { error in
                if let error = error {
                    print("❌ Error creando documento inicial en locations: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    /// Verifica si un usuario ya existe en Firestore
    func userExists(uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        db.collection("users")
            .document(uid)
            .getDocument { document, error in
                if let error = error {
                    print("❌ Error verificando usuario en Firestore: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    let exists = document?.exists ?? false
                    print("📊 Usuario \(exists ? "EXISTE" : "NO EXISTE") en Firestore")
                    completion(.success(exists))
                }
            }
    }
    
    /// Obtiene los datos de un usuario específico
    func getUser(uid: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        db.collection("users")
            .document(uid)
            .getDocument { document, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data() else {
                    completion(.failure(FirebaseError.documentNotFound))
                    return
                }
                
                do {
                    let user = try Firestore.Decoder().decode(AppUser.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    /// Actualiza los datos de un usuario existente
    func updateUser(_ user: AppUser, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let userData = try Firestore.Encoder().encode(user)
            db.collection("users")
                .document(user.uid)
                .updateData(userData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
}


enum FirebaseError: Error, LocalizedError {
    case documentNotFound
    case invalidData
    case userAlreadyExists
    case userCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .invalidData:
            return "Invalid data format"
        case .userAlreadyExists:
            return "User already exists"
        case .userCreationFailed:
            return "Failed to create user"
        }
    }
}
