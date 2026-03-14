import SwiftUI

struct SymptomBadge: View {
    let symptomType: SymptomType
    let isSelected: Bool
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 6) {
                Image(systemName: symptomType.icon)
                    .font(.system(size: 14))
                Text(symptomType.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? symptomType.color.opacity(0.2) : Color.gray.opacity(0.08))
            .foregroundColor(isSelected ? symptomType.color : .secondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? symptomType.color : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
