//
//  ImportWalletSheet.swift
//  KASE-Tester
//
//  Created by Daniel Arnaud on 16/08/2025.
//

import SwiftUI

struct ImportWalletSheet: View {
    let cryptoType: CryptoType
    @Binding var isPresented: Bool
    
    @State private var seedPhrase = ""
    @State private var password = ""
    @State private var isImporting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color("foreground-solea-orange"))
                        
                        Text("Importer Wallet \(cryptoType.rawValue)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("foreground-solea-white"))
                    }
                    .padding(.top)
                    
                    // Formulaire
                    VStack(spacing: 20) {
                        // Seed Phrase
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phrase de récupération (Seed)")
                                .font(.headline)
                                .foregroundColor(Color("foreground-solea-white"))
                            
                            TextEditor(text: $seedPhrase)
                                .frame(minHeight: 120)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color("foreground-solea-white").opacity(0.1))
                                .foregroundColor(Color("foreground-solea-white"))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("foreground-solea-orange").opacity(0.5), lineWidth: 1)
                                )
                                .overlay(
                                    Group {
                                        if seedPhrase.isEmpty {
                                            Text("Entrez votre phrase de récupération de 12 ou 24 mots...")
                                                .foregroundColor(Color("foreground-solea-white").opacity(0.6))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .allowsHitTesting(false)
                                        }
                                    },
                                    alignment: .topLeading
                                )
                        }
                        
                        // Mot de passe
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mot de passe (optionnel)")
                                .font(.headline)
                                .foregroundColor(Color("foreground-solea-white"))
                            
                            SecureField("Entrez le mot de passe", text: $password)
                                .textFieldStyle(SoleaTextFieldStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Boutons d'action
                    VStack(spacing: 15) {
                        // Bouton Importer
                        Button(action: importWallet) {
                            HStack {
                                if isImporting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color("foreground-solea-white")))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                
                                Text(isImporting ? "Import en cours..." : "Importer Wallet")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(Color("foreground-solea-white"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color("foreground-solea-orange"),
                                        Color("foreground-solea-orange").opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isImporting)
                        
                        // Bouton Annuler
                        Button(action: { isPresented = false }) {
                            Text("Annuler")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("foreground-solea-orange"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color("foreground-solea-white").opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("foreground-solea-orange").opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .background(Color("background-solea-blue"))
            .navigationBarHidden(true)
        }
        .alert("Résultat Import", isPresented: $showAlert) {
            Button("OK") {
                if !alertMessage.contains("Erreur") {
                    isPresented = false
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func importWallet() {
        isImporting = true
        
        // Nettoyage de la seed phrase
        let cleanSeed = seedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Appel vers WalletBridge
                let result = WalletBridge.importWallet(
                    seedPhrase: cleanSeed,
                    password: password.isEmpty ? nil : password,
                    cryptoType: cryptoType
                )
                
                DispatchQueue.main.async {
                    isImporting = false
                    
                    if result.success, let wallet = result.wallet {
                        //SAVE WALLET
                        // Créer le UserWallet pour sauvegarde
                        let userWallet = UserWallet(
                            address: wallet.address,
                            privateKey: wallet.privateKey,
                            publicKey: wallet.publicKey,
                            mnemonic: seedPhrase // Nouveau champ !
                        )
                        
                        // Sauvegarder
                        do {
                            try WalletStorage.save(userWallet)
                            print("💾 Wallet sauvegardé avec succès")
                            
                            // TODO: Optionnel - Afficher la phrase mnémonique à l'utilisateur
                            print("📝 Phrase de récupération: \(wallet.mnemonic)")
                            print("⚠️  IMPORTANT: Notez cette phrase dans un endroit sûr!")
                            
                        } catch {
                            print("❌ Erreur sauvegarde: \(error)")
                        }
                        
                        // END SAVE WALLET
                            alertMessage = "✅ Wallet \(cryptoType.rawValue) importé avec succès!\n\nAdresse: \(wallet.address)"
                        } else {
                            alertMessage = "❌ Erreur lors de l'import:\n\(result.error ?? "Erreur inconnue")"
                        }
                    
                    showAlert = true
                }
            } 
            /*catch {
                DispatchQueue.main.async {
                    isImporting = false
                    alertMessage = "❌ Erreur lors de l'import:\n\(error.localizedDescription)"
                    showAlert = true
                }
            }*/
        }
    }
}


#Preview {
    ImportWalletSheet(
        cryptoType: .kas,
        isPresented: .constant(true)
    )
}
