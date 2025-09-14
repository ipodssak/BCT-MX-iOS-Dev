//
//  ComponentsRankingView.swift
//  Bachea mi CDMX
//
//  Created by Oscar Martinez Gonzalez on 13/09/25.
//

import SwiftUI

struct StatisticsCard: View {
    let statistics: GeneralStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadisticas Generales")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            
            HStack(spacing: 20) {
                VStack(alignment: .center, spacing: 4) {
                    Text("\(statistics.totalReports)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Total Reportes")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .center, spacing: 4) {
                    Text("\(statistics.totalMunicipalities)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                    Text("Alcaldias")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .center, spacing: 4) {
                    Text(String(format: "%.1f", statistics.averageReports))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("Promedio")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                }
                .frame(maxWidth: .infinity)
            }
            
            Text("\(statistics.leadingMunicipality) lidera con \(statistics.leadingReport) reportes")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(12)
    }
}

struct FilterChips: View {
    @Binding var selectedFilter: StateFilter
    let filters: [StateFilter]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filtrar por Estado:")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filters, id: \.self) { filter in
                        FilterChip(
                            title: filter.displayName,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(red: 0.2, green: 0.2, blue: 0.2))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(red: 0.7, green: 0.5, blue: 0.9) : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 1)
                )
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MunicipalityRow: View {
    let municipality: Municipality
    
    private var rankColor: Color {
        switch municipality.rank {
        case 1:
            return .yellow
        case 2:
            return Color(red: 0.8, green: 0.8, blue: 0.8)
        case 3:
            return .orange
        default:
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: municipality.lastReportDate)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 32, height: 32)
                
                Text("\(municipality.rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(municipality.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red:0.2, green: 0.2, blue: 0.2))
                Text(municipality.state)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red:0.6, green: 0.6, blue: 0.6))
                Text("Ultimo reporte: \(formattedDate)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red:0.6, green: 0.6, blue: 0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(municipality.reportCount)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.blue)
                Text("reportes")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
            }
        }
        .padding(16)
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(12)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.7, green: 0.5, blue: 0.9)))
            
            Text("Cargando datos...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
                .font(.system(size: 40))
            
            Text("Error al cargar los datos")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .multilineTextAlignment(.center)
            
            Button("Reintentar") {
                onRetry()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(red: 0.7, green: 0.5, blue: 0.9))
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .cornerRadius(12)
    }
}
