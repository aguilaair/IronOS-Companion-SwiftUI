import SwiftUI

struct Chip: View {
    let text: String
    let color: Color
    var font: Font = .caption2
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 0.5)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color.opacity(0.08))
                    )
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        Chip(text: "Signal: Excellent", color: .green)
        Chip(text: "Signal: Good", color: .orange)
        Chip(text: "Signal: Poor", color: .red)
    }
    .padding()
} 