import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab: Hashable {
        case home
        case stats
        case map
        case settings
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeScreen()
                }
                .tag(Tab.home)
                .toolbar(.hidden, for: .tabBar)
                
                NavigationStack {
                    StatsView()
                }
                .tag(Tab.stats)
                .toolbar(.hidden, for: .tabBar)
                
                NavigationStack {
                    MapView()
                }
                .tag(Tab.map)
                .toolbar(.hidden, for: .tabBar)
                
                NavigationStack {
                    SettingsView()
                }
                .tag(Tab.settings)
                .toolbar(.hidden, for: .tabBar)
            }
            .safeAreaInset(edge: .bottom) {
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTabView.Tab
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.12))
            
            HStack {
                tabButton(for: .home, title: "Home", iconName: "house.fill")
                Spacer()
                tabButton(for: .stats, title: "Stats", iconName: "chart.bar.fill")
                Spacer()
                tabButton(for: .map, title: "Map", iconName: "map.fill")
                Spacer()
                tabButton(for: .settings, title: "Settings", iconName: "gearshape.fill")
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(Color(red: 10/255, green: 14/255, blue: 23/255))
        }
    }
    
    private func tabButton(for tab: MainTabView.Tab, title: String, iconName: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 6) {
                if selectedTab == tab {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 22)
                        .background(
                            Capsule()
                                .fill(Color(red: 26/255, green: 77/255, blue: 46/255))
                        )
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 22)
                }
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(selectedTab == tab ? Color(red: 52/255, green: 199/255, blue: 89/255) : .gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainTabView()
}
