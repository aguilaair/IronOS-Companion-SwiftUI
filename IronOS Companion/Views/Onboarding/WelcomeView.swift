//
//  WelcomeView.swift
//  IronOS Companion
//
//  Created by Eduardo Moreno Adanez on 5/28/25.
//
// Claude Sonnet 3.7 added MARKs and comments

import SwiftUI

/// A view that displays the welcome onboarding experience for new users.
/// This view presents a series of pages introducing the app's features
/// and guides users to the device discovery process.
struct WelcomeView: View {
    // MARK: - Properties
    @State private var currentPage = 0
    @State private var showDeviceList = false
    
    // MARK: - Constants
    private let pages = [
        WelcomePage(
            title: "Welcome to IronOS Companion",
            description: "Your smart companion for managing your soldering iron settings and monitoring its performance.",
            imageType: .asset("icon"),
            backgroundColor: .blue
        ),
        WelcomePage(
            title: "Real-time Monitoring",
            description: "Monitor temperature, power levels, and other vital statistics in real-time.",
            imageType: .system("chart.line.uptrend.xyaxis"),
            backgroundColor: .green
        ),
        WelcomePage(
            title: "Easy Configuration",
            description: "Customize your soldering iron settings with an intuitive interface.",
            imageType: .system("slider.horizontal.3"),
            backgroundColor: .orange
        )
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack {
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            WelcomePageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            showDeviceList = true
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(pages[currentPage].backgroundColor)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationDestination(isPresented: $showDeviceList) {
                DiscoveredDevicesView()
                  
            }
        }
    }
}

/// Represents the type of image to be displayed in a welcome page.
enum WelcomePageImageType {
    /// A system SF Symbol image
    case system(String)
    /// An image from the asset catalog
    case asset(String)
}

/// Represents a single page in the welcome onboarding experience.
struct WelcomePage {
    let title: String
    let description: String
    let imageType: WelcomePageImageType
    let backgroundColor: Color
}

/// A view that displays a single welcome page with its content.
struct WelcomePageView: View {
    // MARK: - Properties
    let page: WelcomePage
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 30) {
            Group {
                switch page.imageType {
                case .system(let name):
                    ZStack {
                        AnimatedBlob(color: page.backgroundColor.opacity(0.2))
                            .frame(width: 220, height: 220)
                        
                        Image(systemName: name)
                            .font(.system(size: 100))
                            .foregroundColor(page.backgroundColor)
                    }
                case .asset(let name):
                    ZStack {
                        AnimatedBlob(color: page.backgroundColor.opacity(0.2))
                            .frame(width: 220, height: 220)
                        
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    }
                }
            }
            .padding()
            
            VStack(spacing: 10) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
