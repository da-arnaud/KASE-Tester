//
//  WalletStorage.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 27/06/2025.
//

import Foundation

class WalletStorage {
    private static let fileName = "wallet.json"
    
    static func save(_ wallet: UserWallet) throws {
        let data = try JSONEncoder().encode(wallet)
        let url = try getWalletFileURL()
        try data.write(to: url)
    }

    static func load() throws -> UserWallet {
        let url = try getWalletFileURL()
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(UserWallet.self, from: data)
    }

    static func walletExists() -> Bool {
        guard let url = try? getWalletFileURL() else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    static func delete() throws {
        let url = try getWalletFileURL()
        try FileManager.default.removeItem(at: url)
    }

    private static func getWalletFileURL() throws -> URL {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "WalletStorage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot access document directory"])
        }
        return docs.appendingPathComponent(fileName)
    }
}

