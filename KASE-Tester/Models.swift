//
//  Models.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 27/06/2025.
//

import Foundation

struct UserWallet: Codable {
    let address: String
    let publicKey: String
    let privateKey: String  // à crypter si possible
}
