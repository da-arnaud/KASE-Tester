//
//  MainTabView.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 27/06/2025.
//

import SwiftUI

struct MainTabView: View {
    @Binding var userWallet: UserWallet? 
    var body: some View {
        TabView {
            ActionsView(userWallet: $userWallet)
                .tabItem {
                    Image(systemName: "play.circle")
                    Text("Actions")
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
