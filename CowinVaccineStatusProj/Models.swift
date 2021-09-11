//
//  Models.swift
//  CowinVaccineStatusProj
//
//  Created by Sandeep Kumar on 11/09/21.
//

import Foundation

struct BearerTokenObj: Codable {
    let token:String
}

struct VaccineStatusResult: Codable {
    let vaccination_status: Int
}

struct GetOtpResult: Codable {
    let txnId: String?
    let errorCode: String?
    let error: String?
}
