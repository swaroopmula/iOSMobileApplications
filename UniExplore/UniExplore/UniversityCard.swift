import SwiftUI

struct UniversityCard: View {
    let university: University
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(university.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(isExpanded ? nil : 2)
                    
                    Text(university.domains.first ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.blue)
                }
            }
            
            if isExpanded {
                Divider()
                
                // Location Info
                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading) {
                        Text(university.country)
                            .font(.subheadline)
                        if let state = university.stateProvince {
                            Text(state)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Country Flag
                    Text(university.alphaTwoCode
                        .unicodeScalars
                        .map { String(UnicodeScalar(127397 + $0.value)!) }
                        .joined())
                        .font(.title2)
                }
                
                // Domains
                VStack(alignment: .leading, spacing: 4) {
                    Text("Domains")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(university.domains, id: \.self) { domain in
                        Text("• \(domain)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Website Links
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(university.webPages, id: \.self) { website in
                        Link(destination: URL(string: website) ?? URL(string: "https://www.google.com")!) {
                            HStack {
                                Image(systemName: "globe")
                                Text("Visit Website")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
} 