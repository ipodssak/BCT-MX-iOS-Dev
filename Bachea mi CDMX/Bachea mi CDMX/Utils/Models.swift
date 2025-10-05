//
//  Models.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 13/09/25.
//

import Foundation
import FirebaseFirestore

struct Municipality: Identifiable, Codable {
    let id = UUID()
    let name: String
    let state: String
    let reportCount: Int
    let lastReportDate: Date
    let rank: Int
    
    init(name: String, state: String, reportCount: Int, lastReportDate: Date, rank: Int) {
        self.name = name
        self.state = state
        self.reportCount = reportCount
        self.lastReportDate = lastReportDate
        self.rank = rank
    }
}

struct GeneralStatistics: Codable {
    let totalReports: Int
    let totalMunicipalities: Int
    let averageReports: Double
    let leadingMunicipality: String
    let leadingReport: Int
}

enum StateFilter: String, CaseIterable {
    case all = "Todos"
    case cdmx = "Ciudad de México"
    case edomex = "Edomex"
    case morelos = "Morelos"
    
    var displayName: String {
        return self.rawValue
    }
}

// Sample Data
extension Municipality {
    static let sampleData: [Municipality] = [
        Municipality(name: "Naucalpan de Juarez", state: "Estado de México", reportCount: 170, lastReportDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 8)) ?? Date(), rank: 1),
        
        Municipality(name: "Miguel Hidalgo", state: "Ciudad de México", reportCount: 170, lastReportDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 12)) ?? Date(), rank: 2),
        
        Municipality(name: "San Buenaventura", state: "Estado de México", reportCount: 170, lastReportDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 11)) ?? Date(), rank: 3),
    ]
}

extension GeneralStatistics {
    static let sampleData = GeneralStatistics(totalReports: 346, totalMunicipalities: 16, averageReports: 21.6, leadingMunicipality: "Naucalpan de Juarez", leadingReport: 170)
}

// MARK: - User Model for Firestore
struct AppUser: Codable {
    let authProvider: String
    let email: String
    let lastUpdated: Timestamp
    let name: String
    let profileImageUrl: String
    let registrationDate: Timestamp
    let totalDonations: Int
    let totalLocations: Int
    let totalReports: Int
    let uid: String
    
    init(authProvider: String, email: String, name: String, profileImageUrl: String, uid: String) {
        self.authProvider = authProvider
        self.email = email
        self.name = name
        self.profileImageUrl = profileImageUrl
        self.uid = uid
        self.lastUpdated = Timestamp(date: Date())
        self.registrationDate = Timestamp(date: Date())
        self.totalDonations = 0
        self.totalLocations = 0
        self.totalReports = 0
    }
    
    // Método para actualizar la fecha de última actualización
    func withUpdatedTimestamp() -> AppUser {
        var updatedUser = self
        updatedUser = AppUser(authProvider: authProvider, email: email, name: name, profileImageUrl: profileImageUrl, uid: uid)
        return updatedUser
    }
}
