//
//  MainTabView.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 27/06/2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ConversationsListView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Chats")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(Color("foreground-solea-orange"))
    }
}

#Preview {
    MainTabView()
}
