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
    func isValid(_ link: String, _ callback: @escaping (Link.IsValid) -> Void) -> Cancellable
}

final class LinkHTTPResponseCodeValidationRequest: HTTPRequest, LinkValidator {
    
    private static let successCodes = 200..<300
    
    private var _sessionDelegate: URLSessionDelegate?
    
    init() {
        let sessionDelegate = SkipCertificateValidationURLSessionDelegate()
        super.init(urlSession: .init(configuration: .default, delegate: sessionDelegate, delegateQueue: nil))
        _sessionDelegate = sessionDelegate
    }
    
    @discardableResult
    func isValid(_ link: String, _ callback: @escaping (Link.IsValid) -> Void) -> Cancellable {
        get(link) { response in
            
            switch response {
                
            case .failure(let error):
                callback(error.isValidLink)
                
            case .success(let httpResponse):
                callback(.determined(
                    Self.successCodes.contains(httpResponse.response.statusCode)))
            }
        }
    }
}

fileprivate extension HTTPRequest.Error {
    var isValidLink: Link.IsValid {
        switch self {
        case .mailformedURL:
            return .determined(false)
            
        case .noResponse,
             .underlying,
             .unexpectedServerResponse:
            return .notDetermined
        }
    }
}

fileprivate final class SkipCertificateValidationURLSessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}
