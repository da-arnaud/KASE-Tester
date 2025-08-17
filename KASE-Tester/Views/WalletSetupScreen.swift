//
//  WalletSetupScreen.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 27/06/2025.
//

import SwiftUI

struct WalletSetupScreen: View {
    @State private var seedPhrase: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var onWalletImported: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Import Wallet")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color("foreground-solea-white"))

            TextEditor(text: $seedPhrase)
                .frame(height: 100)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("foreground-solea-orange"), lineWidth: 2))
                .background(Color("background-solea-blue"))
                .foregroundColor(Color("background-solea-blue"))

            SecureField("Password", text: $password)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("foreground-solea-orange"), lineWidth: 2))
                .foregroundColor(Color("foreground-solea-white"))

            Button(action: importWallet) {
                Text("Import Wallet")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("foreground-solea-orange"))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .background(Color("background-solea-blue").ignoresSafeArea())
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Info"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func importWallet() {
        guard !seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            alertMessage = "Please enter both the seed and password."
            showingAlert = true
            return
        }

        // Appel à la librairie C via la fonction Swift
        guard let wallet = WalletBridge.recoverWallet(from: seedPhrase, passphrase: password) else {
            alertMessage = "Failed to recover wallet. Please check your seed phrase."
            showingAlert = true
            return
        }

        do {
            try WalletStorage.save(wallet)
            onWalletImported()
        } catch {
            alertMessage = "Failed to save wallet: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}


//
