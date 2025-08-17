//
//  Extensions.swift
//  KASE-Tester
//
//  Created by Daniel Arnaud on 17/08/2025.
//

import Foundation

extension Data {
    var hexString: String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
