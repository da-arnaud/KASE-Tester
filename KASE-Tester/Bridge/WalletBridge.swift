//
//  WalletBridge.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 28/06/2025.
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        map { String(format: "%02x", $0) }.joined()
    }
}

struct ImportResult {
    let success: Bool
    let wallet: UserWallet?
    let error: String?
}


struct TransactionResult {
        let success: Bool
        let transactionId: String?
        let error: String?
    }

struct WalletBridge {
    
    static func importWallet(seedPhrase: String, password: String?, cryptoType: CryptoType) -> ImportResult {
        let words = seedPhrase.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        guard words.count == 12 || words.count == 24 else {
            return ImportResult(success: false, wallet: nil, error: "La seed phrase doit contenir 12 ou 24 mots")
        }
        
        // TODO: Remplacer par votre vraie implémentation KASE
        switch cryptoType {
        case .kas:
            // Utiliser la fonction existante recoverWallet
                    if let wallet = recoverWallet(from: seedPhrase, passphrase: password ?? "") {
                        return ImportResult(success: true, wallet: wallet, error: nil)
                    } else {
                        return ImportResult(success: false, wallet: nil, error: "Échec de la récupération du wallet Kaspa. Vérifiez votre phrase de récupération.")
                    }
        case .eth:
            // Appel vers vos fonctions KASE pour Ethereum
            return ImportResult(success: false, wallet: nil, error: "Import Ethereum non encore implémenté")
        }
    }
    
    // Dans WalletBridge.swift
    static func createWallet() -> (success: Bool, wallet: UserWallet?, error: String?) {
        var wallet = kase_wallet_t()
        let result = kase_generate_wallet(&wallet)
        
        if result == KASE_OK {
            let userWallet = UserWallet(
                address: withUnsafeBytes(of: wallet.kaspa_address) { bytes in
                                String(cString: bytes.bindMemory(to: CChar.self).baseAddress!)
                            },
                privateKey: withUnsafeBytes(of: wallet.priv_key) { bytes in
                                Data(bytes)
                            },
                publicKey: withUnsafeBytes(of: wallet.pub_key) { bytes in
                                Data(bytes)
                            },
                mnemonic: withUnsafeBytes(of: wallet.mnemonic) { bytes in
                    String(cString: bytes.bindMemory(to: CChar.self).baseAddress!)
                }
            )
            return (true, userWallet, nil)
        } else {
            return (false, nil, "Erreur création wallet: \(result)")
        }
    }
    
    static func recoverWallet(from mnemonic: String, passphrase: String = "") -> UserWallet? {
        var wallet = kase_wallet_t()
        
        guard let mnemonic_c = mnemonic.cString(using: .utf8),
              let passphrase_c = passphrase.cString(using: .utf8) else {
            return nil
        }
        
        let result = kase_recover_wallet_from_seed(mnemonic_c, passphrase_c, &wallet)
        
        let rawAddressBytes = Data(bytes: &wallet.kaspa_address, count: 128)
        
        //print("kasia_address raw bytes: \(rawAddressBytes.hexEncodedString())")
        //print("Last byte in kaspa_address: \(wallet.kaspa_address.127)")
        
        guard result == KASE_OK else {
            print("Recovery failed with code \(result)")
            return nil
        }
        
        let pubKey = Data(bytes: &wallet.pub_key, count: 33)
        let privKey = Data(bytes: &wallet.priv_key, count: 32)
        //let address = String(cString: &wallet.kaspa_address.0)
        
        let addressData = Data(bytes: &wallet.kaspa_address, count: 128)
        
        var address: String? = nil
        if let endIndex = addressData.firstIndex(of: 0) {
            let truncated = addressData.prefix(upTo: endIndex)
            address = String(data: truncated, encoding: .utf8)
        }
        
        guard let finalAddress = address else {
            print("Failed to decode Kaspa address from wallet.")
            return nil
        }
        return UserWallet(address: finalAddress, privateKey: privKey, publicKey: pubKey,  mnemonic: mnemonic)
    }
    
    static func getBalance(for wallet: UserWallet) -> (success: Bool, balance: Double, error: String?) {
            let address = wallet.address
            var balance: UInt64 = 0
            
            let result = kase_get_balance(address, &balance)
            
            if result == KASE_OK {
                let kasBalance = kase_sompi_to_kas(balance)
                return (true, kasBalance, nil)
            } else {
                return (false, 0.0, "Erreur récupération solde")
            }
        }
        
        static func createTransaction(from wallet: UserWallet,
                                    to destinationAddress: String,
                                    amount: Double) -> TransactionResult {
            
            let amountSompi = kase_kas_to_sompi(amount)
            var result = kase_transaction_result_t()
            
            let status = kase_create_transaction(
                wallet.address,
                destinationAddress,
                amountSompi,
                wallet.privateKey.withUnsafeBytes { $0.bindMemory(to: UInt8.self).baseAddress! },
                &result
            )
            
            if result.success != 0 {
                let txId = String(cString: &result.transaction_id.0)
                return TransactionResult(success: true, transactionId: txId, error: nil)
            } else {
                let error = String(cString: &result.error.0)
                return TransactionResult(success: false, transactionId: nil, error: error)
            }
        }
}
