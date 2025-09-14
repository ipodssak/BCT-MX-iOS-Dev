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
}

enum FirebaseError: Error, LocalizedError {
    case documentNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
