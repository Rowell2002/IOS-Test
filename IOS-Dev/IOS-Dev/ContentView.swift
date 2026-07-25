//
//  ContentView.swift
//  IOS-Dev
//
//  Created by Chethana Rowell on 2026-06-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var isLoading = true
    
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
        .animation(.easeInOut(duration: 0.5), value: isLoading)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
