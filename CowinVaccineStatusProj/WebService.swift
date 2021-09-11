//
//  WebService.swift
//  CowinVaccineStatusProj
//
//  Created by Sandeep Kumar on 11/09/21.
//

import Foundation

struct Constants {
    static let baseURL = "https://cdn-api.co-vin.in/api"
    static let getOtpPath = "/v3/vaccination/generateOTP"
    static let confirmOtpPath = "/v3/vaccination/confirmOTP"
    static let vaccineStatusPath = "/v3/vaccination/status"
}

class WebService {
    static let shared = WebService()
    
    private init() {}
    
    func getOtp<T: Codable>(for emailAddress: String,
                            _ name: String,
                            _ mobileNumber: String,
                            expecting: T.Type,
                            completion: @escaping (Result<T,Error>)->Void) {
        let body = [
            "mobile_number": mobileNumber,
            "full_name": name,
            "email_id": emailAddress
        ]
        
        makeURLRequest(on: Constants.getOtpPath,
                       httpMethod: .POST,
                       httpBody: body,
                       token: nil,
                       completion: completion)
    }
    
    func getVaccinationStatus<T: Codable>(with txnId: String,
                                          otp: String,
                                          expecting: T.Type,
                                          completion: @escaping (Result<T,Error>)->Void) {
        verifyOtp(with: txnId,
                  otp: otp,
                  expecting: BearerTokenObj.self) { [weak self] res in
            switch res {
            case .success(let bearerTokenObj):
                self?.getVaccinationStatus(with: bearerTokenObj.token,
                                          expecting: T.self,
                                          completion: completion)
                break
            case .failure(let err):
                completion(.failure(err))
                return
            }
        }
    }
    
    private func verifyOtp<T: Codable>(with txnId:String,
                                       otp: String,
                                       expecting: T.Type,
                                       completion: @escaping (Result<T,Error>)->Void) {
        let body = [
            "otp": Utils.get256SHA(for: otp) ,
            "txnId": txnId,
        ]
        
        makeURLRequest(on: Constants.confirmOtpPath,
                       httpMethod: .POST,
                       httpBody: body,
                       token: nil,
                       completion: completion)
    }
    
    private func getVaccinationStatus<T: Codable>(with bearer: String,
                                                  expecting: T.Type,
                                                  completion: @escaping (Result<T,Error>)->Void){
        makeURLRequest(on: Constants.vaccineStatusPath,
                       httpMethod: .GET,
                       httpBody: nil,
                       token: bearer,
                       completion: completion)
    }
}

extension WebService {
    enum WebServiceError: Error {
        case invalidEntry
        case failedToParseResponse
        case failedToGetURL
        case failedToGetBearerToken
    }
    
    enum HttpMethod: String {
        case GET
        case POST
    }
    
    private func makeURLRequest<T:Decodable>(on path: String,
                                             httpMethod: HttpMethod,
                                             httpBody: [String:String]?,
                                             token:String?,
                                             completion: @escaping (Result<T, Error>)->Void) {
        guard let url = URL(string: Constants.baseURL + path) else {
            completion(.failure(WebServiceError.failedToGetURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let httpBody = httpBody {
            request.httpBody = try? JSONSerialization.data(withJSONObject: httpBody, options: .fragmentsAllowed)
        }
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, err in
            guard let data = data, err == nil else {
                completion(.failure(WebServiceError.invalidEntry))
                return
            }
            
            guard let decodedData = try? JSONDecoder().decode(T.self, from: data)
            else {
                completion(.failure(WebServiceError.failedToParseResponse))
                return
            }
            completion(.success(decodedData))
        }.resume()
    }
}
