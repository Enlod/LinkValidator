//
//  HTTPRequest.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 14.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

enum HTTPRequestError: Swift.Error {
    case mailformedURL
    case noResponse
    case underlying(Swift.Error)
}

struct HTTPRequestResponse {
    let data: Data
    let response: HTTPURLResponse
}

protocol HTTPRequest {
     @discardableResult
     func get(_ urlString: String, _ callback: @escaping (Result<HTTPRequestResponse, HTTPRequestError>) -> Void) -> Cancellable
}

enum HTTPRequestDecodeError: Swift.Error {
    case unexpectedServerResponse
    case underlying(HTTPRequestError)
}

extension HTTPRequest {
    @discardableResult
    func get<Value: Decodable>(_ urlString: String, _ callback: @escaping (Result<[Value], HTTPRequestDecodeError>) -> Void) -> Cancellable {
        get(urlString) { response in
            
            let result: Result<[Value], HTTPRequestDecodeError>
            
            switch response {
                
            case .failure(let error):
                result = .failure(.underlying(error))
                
            case .success(let response):
                
                do {
                    let values = try JSONDecoder().decode([Value].self, from: response.data)
                    result = .success(values)
                }
                catch {
                    result = .failure(.unexpectedServerResponse)
                }
            }
            
            callback(result)
        }
    }
}
