//
//  Util.swift
//  CowinVaccineStatusProj
//
//  Created by Sandeep Kumar on 11/09/21.
//

import Foundation
import CryptoKit

class Utils {
    static func get256SHA(for string: String) -> String {
        let inputData = Data(string.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
