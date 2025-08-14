//
//  WalletViewer.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 29/06/2025.
//
import SwiftUI

struct WalletViewer: View {
    let jsonText: String

    @State private var balance: String?
    @State private var address: String?
    @State private var fetchError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("🔐 Wallet JSON")
                    .font(.headline)

                Text(jsonText)
                    .font(.system(size: 12, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                if let address = address {
                    Text("📬 Address: \(address)")
                        .font(.subheadline)
                        .padding(.top)
                }

                if let balance = balance {
                    Text("💰 Balance: \(balance) KAS")
                        .font(.title3)
                        .bold()
                        .padding(.top, 4)
                } else if let error = fetchError {
                    Text("⚠️ Error fetching balance: \(error)")
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
            .padding()
            .onAppear {
                extractAndFetchBalance()
            }
        }
    }

    private func extractAndFetchBalance() {
        guard let data = jsonText.data(using: .utf8),
              let wallet = try? JSONDecoder().decode(UserWallet.self, from: data) else {
            self.fetchError = "Invalid wallet JSON"
            return
        }

        self.address = wallet.address
        fetchKaspaBalance(for: wallet.address)
    }

    private func fetchKaspaBalance(for address: String) {
        guard let url = URL(string: "https://api.kaspa.org/addresses/\(address)") else {
            self.fetchError = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.fetchError = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self.fetchError = "No data received"
                    return
                }
                
                // 💡 Affiche le contenu brut pour débogage
                            if let raw = String(data: data, encoding: .utf8) {
                                print("📦 Raw response: \(raw)")
                            } else {
                                print("📦 Raw data (non UTF8): \(data)")
                            }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let balanceDict = (json["balance"] as? [String: Any])?["aggregated"] as? [String: Any],
                       let rawBalance = balanceDict["balance"] as? String {
                        // Convert sompes (1 KAS = 100,000,000 sompes)
                        if let sompes = UInt64(rawBalance) {
                            let kas = Double(sompes) / 100_000_000
                            self.balance = String(format: "%.4f", kas)
                        } else {
                            self.fetchError = "Invalid balance format"
                        }
                    } else {
                        self.fetchError = "Unexpected JSON structure"
                    }
                } catch {
                    self.fetchError = error.localizedDescription
                }
            }
        }.resume()
    }
}



