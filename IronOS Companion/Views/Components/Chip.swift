//
//  Chip.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI

struct Chip: View {
    // MARK: - Constants
    private let cornerRadius: CGFloat = 16
    private let horizontalPadding: CGFloat = 12
    private let verticalPadding: CGFloat = 6
    private let strokeWidth: CGFloat = 0.5
    private let backgroundOpacity: Double = 0.08
    
    // MARK: - Properties
    let text: String
    let color: Color
    var font: Font = .caption2
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: strokeWidth)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(color.opacity(backgroundOpacity))
                    )
            )
    }
}

#Preview {
    VStack {
        Chip(text: "Signal: Excellent", color: .green)
        Chip(text: "Signal: Good", color: .orange)
        Chip(text: "Signal: Poor", color: .red)
    }
    .padding()
} 