//
//  HTTPRequest.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 14.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

class HTTPRequest {
    
    enum DecodeError: Swift.Error {
        case unexpectedServerResponse
        case underlying(Error)
    }
    
    enum Error: Swift.Error {
        case mailformedURL
        case noResponse
        case unexpectedServerResponse
        case underlying(Swift.Error)
    }
    
    struct Response {
        let data: Data
        let response: HTTPURLResponse
    }
    
    // MARK: - State
    
    private let _urlSession: URLSession
    
    // MARK: - Init
    
    init(urlSession: URLSession) {
        _urlSession = urlSession
    }
    
    // MARK: - Input
    
    @discardableResult
    func get<Value: Decodable>(_ urlString: String, _ callback: @escaping (Result<[Value], DecodeError>) -> Void) -> Cancellable {
        get(urlString) { response in
            
            let result: Result<[Value], DecodeError>
            
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
    
    @discardableResult
    func get(_ urlString: String, _ callback: @escaping (Result<Response, Error>) -> Void) -> Cancellable {
        
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
            
            callback(.success(Response(data: data, response: response)))
        }
        task.resume()
        
        return Cancellable(task.cancel)
    }
}
