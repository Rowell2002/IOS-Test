//
//  ContentView.swift
//  IOS-Dev
//
//  Created by Chethana Rowell on 2026-06-07.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeScreen()
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
