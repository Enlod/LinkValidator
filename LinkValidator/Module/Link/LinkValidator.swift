//
//  LinkValidationRequest.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

protocol LinkValidator {
    @discardableResult
    func isValid(_ link: Link, _ callback: @escaping (Bool) -> Void) -> Cancellable
}

final class LinkHTTPResponseCodeValidationRequest: HTTPRequestContainer, LinkValidator {
    
    static let successCodes = 200..<400
    static let session =
        URLSession(
            configuration: .default,
            delegate: SkipCertificateValidationURLSessionDelegate(),
            delegateQueue: nil)
    
    @discardableResult
    func isValid(_ link: Link, _ callback: @escaping (Bool) -> Void) -> Cancellable {
        httpRequest.get(link.link) { response in
            
            let result: Bool
            
            switch response {
                
            case .failure:
                result = false
                
            case .success(let response):
                result = Self.successCodes.contains(response.response.statusCode)
            }
            
            callback(result)
        }
    }
}

fileprivate final class SkipCertificateValidationURLSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}
