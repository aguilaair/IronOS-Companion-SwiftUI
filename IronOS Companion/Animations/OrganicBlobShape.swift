//
//  OrganicBlobShape.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//

import SwiftUI


// This is a Claude Sonnet 3.7 generated function.
// Prompt: "Create a SwiftUI shape that looks like a blob with a smooth, organic movement."
struct OrganicBlobShape: Shape {
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        let radius = min(width, height) / 2
        
        var path = Path()
        let points = 12 // Increased number of points for smoother shape
        let angleStep = (2 * .pi) / Double(points)
        
        // Generate control points for the blob
        var controlPoints: [CGPoint] = []
        for i in 0..<points {
            let angle = Double(i) * angleStep
            // Create more organic movement by using multiple sine waves
            let distance = radius * (
                0.8 + // Base size
                0.15 * sin(angle * 3 + phase) + // First wave
                0.05 * sin(angle * 5 - phase * 1.5) + // Second wave
                0.1 * sin(phase * 2) // Overall pulsing
            )
            let x = center.x + cos(angle) * distance
            let y = center.y + sin(angle) * distance
            controlPoints.append(CGPoint(x: x, y: y))
        }
        
        // Create the blob path using cubic curves
        path.move(to: controlPoints[0])
        for i in 0..<points {
            let current = controlPoints[i]
            let next = controlPoints[(i + 1) % points]
            let nextNext = controlPoints[(i + 2) % points]
            
            // Adjust control points for smoother curves
            let control1 = CGPoint(
                x: current.x + (next.x - current.x) * 0.5,
                y: current.y + (next.y - current.y) * 0.5
            )
            
            let control2 = CGPoint(
                x: next.x - (nextNext.x - current.x) * 0.5,
                y: next.y - (nextNext.y - current.y) * 0.5
            )
            
            path.addCurve(to: next, control1: control1, control2: control2)
        }
        
        return path
    }
}

struct AnimatedBlob: View {
    @State private var phase: Double = 0
    let color: Color
    
    var body: some View {
        OrganicBlobShape(phase: phase)
            .fill(color)
            .blur(radius: 20)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    phase = .pi
                }
            }
    }
} 