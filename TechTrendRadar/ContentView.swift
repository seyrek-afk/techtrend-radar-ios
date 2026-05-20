import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CategoriesView()
                .tabItem {
                    Label("Kategoriler", systemImage: "square.grid.2x2.fill")
                }

            TrendsView()
                .tabItem {
                    Label("Trendler", systemImage: "chart.line.uptrend.xyaxis")
                }

            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
        }
        .tint(.accent)
        .background(Color.bgBase)
    }
}
