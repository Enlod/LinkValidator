//
//  HTTPRequestImpl.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 16.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

final class HTTPRequestImpl: HTTPRequest {

    // MARK: - State
    
    private let _urlSession: URLSession
    
    // MARK: - Init
    
    init(urlSession: URLSession) {
        _urlSession = urlSession
    }
    
    // MARK: - HTTPRequest
    
    @discardableResult
    func get(_ urlString: String, _ callback: @escaping (Result<HTTPRequestResponse, HTTPRequestError>) -> Void) -> Cancellable {
        
        guard let url = URL(string: urlString) else {
            callback(.failure(.mailformedURL))
            return Cancellable()
        }
        
        let task = _urlSession.dataTask(with: url) { data, response, error in
            
            if let error = error {
                callback(.failure(.underlying(error)))
                return
            }
            
            guard
                let data = data,
                let response = response as? HTTPURLResponse
            else {
                callback(.failure(.noResponse))
                return
            }
            
            callback(.success(.init(data: data, response: response)))
        }
        task.resume()
        
        return Cancellable(task.cancel)
    }
}
