//
//  ContentView.swift
//  IOS-Dev
//
//  Created by Chethana Rowell on 2026-06-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @AppStorage("appTheme") private var appTheme = "dark"
    @State private var isLoading = true
    
    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }
    
    var body: some View {
        ZStack {
            if authManager.currentUser != nil {
                MainTabView()
            } else {
                LoginView()
            }
            
            if isLoading {
                SplashView(isFinished: $isLoading)
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
                    .zIndex(1)
            }
        }
        .preferredColorScheme(colorScheme)
        .animation(.easeInOut(duration: 0.5), value: isLoading)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
