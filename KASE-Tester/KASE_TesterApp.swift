//
//  KASE_TesterApp.swift
//  KASE-Tester
//
//  Created by Daniel Arnaud on 14/08/2025.
//

import SwiftUI

@main
struct KASE_TesterApp: App {
    @State private var userWallet: UserWallet? = try? WalletStorage.load()
    @State private var showingWalletSetup = !WalletStorage.walletExists()

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView(userWallet: $userWallet)
                    //.opacity(userWallet != nil ? 1 : 0.2)
                    //.disabled(userWallet == nil)
                    /*.onAppear {
                        if let loaded = try? WalletStorage.load() {
                            userWallet = loaded
                            showingWalletSetup = false
                        }
                    }*/

                //if showingWalletSetup {
                //    Color.black.opacity(0.5).ignoresSafeArea()
                //}
            }
            /*.sheet(isPresented: $showingWalletSetup, onDismiss: {
                userWallet = try? WalletStorage.load()
            }) {
                WalletSetupScreen(onWalletImported: {
                    showingWalletSetup = false
                    userWallet = try? WalletStorage.load()
                })
            }*/
        }
    }
}
