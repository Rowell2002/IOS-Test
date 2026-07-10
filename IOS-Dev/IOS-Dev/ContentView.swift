//
//  ContentView.swift
//  IOS-Dev
//
//  Created by Chethana Rowell on 2026-06-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        if authManager.currentUser != nil {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
