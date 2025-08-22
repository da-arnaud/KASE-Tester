//
//  ActionsView.swift
//  KASE-Tester
//
//  Created by Daniel Arnaud on 15/08/2025.
//

import SwiftUI

struct ActionsView: View {
    @Binding var userWallet: UserWallet? // Ajout du binding
    @State private var selectedNetwork: WalletBridge.NetworkType = .testnet
    
    @State private var kasAmount = ""
    @State private var kasAddress = ""
    @State private var ethAmount = ""
    @State private var ethAddress = ""
    @State private var walletBalance: Double = 0.0
    
    // States pour les sheets
    @State private var showKasImport = false
    @State private var showEthImport = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                
                if let wallet = userWallet {
                                   WalletInfoSection(wallet: wallet, balance: walletBalance)
                                       .onAppear {
                                           loadBalance()
                                       }
                               }
                
                // Section KAS
                NetworkSelector(selectedNetwork: $selectedNetwork)
                CryptoActionSection(
                    title: "KAS",
                    amount: $kasAmount,
                    address: $kasAddress,
                    onCreateWallet: { createKasWallet() },
                    onImportWallet: { showKasImport = true },
                    onDeleteWallet: { deleteKasWallet() },
                    onSendTransaction: { sendKasTransaction() }
                )
                
                // Séparateur
                Rectangle()
                    .fill(Color("foreground-solea-white"))
                    .frame(height: 1)
                    .padding(.horizontal)
                
                // Section ETH
                CryptoActionSection(
                    title: "ETH",
                    amount: $ethAmount,
                    address: $ethAddress,
                    onCreateWallet: { createEthWallet() },
                    onImportWallet: { showEthImport = true },
                    onDeleteWallet: { deleteEthWallet() },
                    onSendTransaction: { sendEthTransaction() }
                )
                
                Spacer()
            }
            .padding()
        }
        .background(Color("background-solea-blue"))
        .navigationTitle("Actions")
        .navigationBarTitleDisplayMode(.large)
        .background(Color("background-solea-blue"))
        .navigationTitle("Actions")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showKasImport) {
            ImportWalletSheet(cryptoType: .kas,  isPresented: $showKasImport)
        }
        .sheet(isPresented: $showEthImport) {
            ImportWalletSheet(cryptoType: .eth,  isPresented: $showKasImport)
        }

    }
    
    // MARK: - KAS Actions
    private func createKasWallet() {
        print("🔑 Créer Wallet KAS")
        // Créer le wallet via le bridge C
            let result = WalletBridge.createWallet()
            
            if result.success, let wallet = result.wallet {
                print("✅ Wallet créé!")
                print("📍 Adresse: \(wallet.address)")
                print("🔑 Clé publique: \(wallet.publicKey.hexString)")
                print("🔑 Clé privée: \(wallet.privateKey.hexString)")
                
                // Créer le UserWallet pour sauvegarde
                let userWallet = UserWallet(
                    address: wallet.address,
                    privateKey: wallet.privateKey,
                    publicKey: wallet.publicKey,
                    mnemonic: wallet.mnemonic // Nouveau champ !
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
                
            } else {
                print("❌ Erreur création wallet: \(result.error ?? "Inconnue")")
            }
    }
    
    
    private func deleteKasWallet() {
        print("🗑️ Supprimer Wallet KAS")
        // TODO: Implémenter
    }
    
    
    private func loadBalance() {
            guard let wallet = userWallet else { return }
            
            let result = WalletBridge.getBalance(for: wallet)
            if result.success {
                walletBalance = result.balance
            }
        }
        
        private func sendKasTransaction() {
            guard let wallet = userWallet else {
                print("❌ Aucun wallet actif")
                return
            }
            
            guard let amount = Double(kasAmount), amount > 0 else {
                print("❌ Montant invalide")
                return
            }
            
            guard !kasAddress.isEmpty else {
                print("❌ Adresse de destination manquante")
                return
            }
            
            print("💸 Création transaction KAS:")
            print("   De: \(wallet.address)")
            print("   Vers: \(kasAddress)")
            print("   Montant: \(amount) KAS")
            
            let result = WalletBridge.createTransaction(
                from: wallet,
                to: kasAddress,
                amount: amount
            )
            
            if result.success {
                print("✅ Transaction créée! ID: \(result.transactionId ?? "unknown")")
                // Recharger le solde
                loadBalance()
                // Vider les champs
                kasAmount = ""
                kasAddress = ""
            } else {
                print("❌ Erreur transaction: \(result.error ?? "Inconnue")")
            }
        }
    
    // MARK: - ETH Actions
    private func createEthWallet() {
        print("🔑 Créer Wallet ETH")
        // TODO: Implémenter avec WalletBridge
    }
    
    private func importEthWallet() {
        print("📥 Importer Wallet ETH")
        // TODO: Implémenter avec WalletBridge
    }
    
    private func deleteEthWallet() {
        print("🗑️ Supprimer Wallet ETH")
        // TODO: Implémenter
    }
    
    private func sendEthTransaction() {
        print("💸 Transaction ETH - Montant: \(ethAmount), Adresse: \(ethAddress)")
        // TODO: Implémenter transaction ETH
    }
}

// MARK: - Component réutilisable
struct CryptoActionSection: View {
    let title: String
    @Binding var amount: String
    @Binding var address: String
    let onCreateWallet: () -> Void
    let onImportWallet: () -> Void
    let onDeleteWallet: () -> Void
    let onSendTransaction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Titre
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("foreground-solea-orange"))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Boutons Wallet
            HStack(spacing: 15) {
                // Bouton Supprimer
                Button(action: onDeleteWallet) {
                    Text("Supprimer")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("foreground-solea-white"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
                
                // Bouton Importer
                Button(action: onImportWallet) {
                    Text("Importer Wallet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("foreground-solea-white"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color("foreground-solea-orange"))
                        .cornerRadius(8)
                }
                
                // Bouton Créer
                Button(action: onCreateWallet) {
                    Text("Créer Wallet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("foreground-solea-white"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color("foreground-solea-orange"))
                        .cornerRadius(8)
                }
            }
            
            // Champ Montant
            TextField("Entrez montant", text: $amount)
                .textFieldStyle(SoleaTextFieldStyle())
                .keyboardType(.decimalPad)
            
            // Champ Adresse
            TextField("Entrez adresse", text: $address)
                .textFieldStyle(SoleaTextFieldStyle())
            
            // Bouton Transaction
            Button(action: onSendTransaction) {
                Text("Lancer Transaction")
                    .font(.system(size: 18, weight: .semibold))
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
            .disabled(amount.isEmpty || address.isEmpty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color("background-solea-blue").opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color("foreground-solea-orange").opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Nouveau composant pour afficher les infos du wallet
struct WalletInfoSection: View {
    let wallet: UserWallet
    let balance: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Wallet Actif")
                .font(.headline)
                .foregroundColor(Color("foreground-solea-orange"))
            
            Text(wallet.address)
                .font(.caption)
                .foregroundColor(Color("foreground-solea-white"))
                .lineLimit(1)
                .truncationMode(.middle)
            
            Text("Solde: \(String(format: "%.8f", balance)) KAS")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color("foreground-solea-white"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("foreground-solea-orange").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("foreground-solea-orange").opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Style TextField personnalisé
struct SoleaTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("foreground-solea-white").opacity(0.1))
            .foregroundColor(Color("foreground-solea-white"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("foreground-solea-orange").opacity(0.5), lineWidth: 1)
            )
    }
}

