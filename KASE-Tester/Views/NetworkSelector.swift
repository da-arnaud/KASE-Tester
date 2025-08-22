//
//  NetworkSelector.swift
//  KASE-Tester
//
//  Created by Daniel Arnaud on 22/08/2025.
//

import SwiftUI

struct NetworkSelector: View {
    @Binding var selectedNetwork: WalletBridge.NetworkType
    var body: some View {
        VStack(spacing: 8) {
                    Text("Réseau Kaspa")
                        .font(.headline)
                        .foregroundColor(Color("foreground-solea-orange"))
                    
                    Picker("Réseau", selection: $selectedNetwork) {
                        Text("🧪 Testnet").tag(WalletBridge.NetworkType.testnet)
                        Text("🌐 Mainnet").tag(WalletBridge.NetworkType.mainnet)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color("foreground-solea-white").opacity(0.1))
                    .cornerRadius(8)
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
