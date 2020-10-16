//
//  HTTPRequest+Mocks.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 16.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

struct HTTPRequestMock: HTTPRequest {
    
    var response: Result<HTTPRequestResponse, HTTPRequestError> = .failure(.noResponse)
    
    func get(_ urlString: String, _ callback: @escaping (Result<HTTPRequestResponse, HTTPRequestError>) -> Void) -> Cancellable {
        callback(response)
        return .init()
    }
}

extension HTTPRequestResponse {
    static func mock(
        data: Data = .init(),
        response: HTTPURLResponse = .mock()
    ) -> HTTPRequestResponse {
        .init(
            data: data,
            response: response)
    }
}

extension HTTPURLResponse {
    static func mock(
        statusCode: Int = 0
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "blank")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
    }
}
