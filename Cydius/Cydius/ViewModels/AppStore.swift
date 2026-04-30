struct CertificateRow: View {
    let cert: Certificate   // ← Changed from CydCertificate to Certificate
    let isSelected: Bool
    let onSelect: () -> Void
    
    var statusColor: Color {
        switch cert.status {
        case .safe: return .green
        case .revoked: return .red
        case .expired: return .orange
        }
    }
    
    var statusText: String {
        switch cert.status {
        case .safe: return "Valid"
        case .revoked: return "Revoked"
        case .expired: return "Expired"
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Text(cert.country)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(cert.name)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .font(.subheadline)
                    Text("Expires: \(cert.expiryDate, style: .date)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(statusText)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.15))
                        .cornerRadius(8)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
            }
            .padding(12)
            .background(isSelected ? Color.orange.opacity(0.1) : Color.white.opacity(0.06))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
}
