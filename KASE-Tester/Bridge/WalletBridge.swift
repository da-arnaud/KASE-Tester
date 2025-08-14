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

func recoverWallet(from mnemonic: String, passphrase: String = "") -> UserWallet? {
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

    let pubKey = Data(bytes: &wallet.pub_key, count: 33).hexEncodedString()
    let privKey = Data(bytes: &wallet.priv_key, count: 32).hexEncodedString()
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
    return UserWallet(address: finalAddress, publicKey: pubKey, privateKey: privKey)
}
