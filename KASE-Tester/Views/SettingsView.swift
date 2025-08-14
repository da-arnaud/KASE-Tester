//
//  SettingsView.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 27/06/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var walletJSON: String? = nil
    @State private var loadError: String? = nil
    @State private var isShowingViewer = false

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Erase conversations on background", isOn: .constant(false))
                    .toggleStyle(SwitchToggleStyle(tint: Color("foreground-solea-orange")))

                Button("Load Wallet") {
                    do {
                        let wallet = try WalletStorage.load()
                        let jsonData = try JSONEncoder().encode(wallet)
                        walletJSON = String(data: jsonData, encoding: .utf8)
                        isShowingViewer = true
                    } catch {
                        loadError = error.localizedDescription
                        isShowingViewer = true
                    }
                }
            }
            .navigationTitle("Settings")
            .background(Color("background-solea-blue").ignoresSafeArea())
            .navigationDestination(isPresented: $isShowingViewer) {
                WalletViewer(jsonText: walletJSON ?? loadError ?? "No data")
            }
        }
    }
}

#Preview {
    SettingsView()
}
