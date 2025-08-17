//
//  Models.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 27/06/2025.
//

import Foundation

struct UserWallet: Codable {
    let address: String
    let privateKey: Data
    let publicKey: Data
    let mnemonic: String
}

// MARK: - Enum pour les types de crypto
enum CryptoType: String, CaseIterable {
    case kas = "KAS"
    case eth = "ETH"
}
