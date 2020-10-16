//
//  LinkValidatorTests.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 16.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import XCTest

final class LinkValidatorTests: XCTestCase {
    
    func test() {
        
        XCTAssertEqual(LinkHTTPResponseCodeValidationRequest.successCodes, 200..<400)
        
        typealias Response = Result<HTTPRequestResponse, HTTPRequestError>
        
        let success = { (statusCode: Int) in
            Response.success(.mock(response: .mock(statusCode: statusCode)))
        }
        
        let cases: [(response: Response, isValid: Bool)] = [
            (.failure(.mailformedURL), false),
            (.failure(.noResponse), false),
            (.failure(.underlying(NSError())), false),
            (success(0), false),
            (success(199), false),
            (success(200), true),
            (success(257), true),
            (success(342), true),
            (success(399), true),
            (success(399), true),
            (success(400), false),
            (success(500), false),
            (success(Int.max), false),
        ]
        
        cases.forEach { `case` in
            var request = HTTPRequestMock()
            request.response = `case`.response
            
            var callbackInvocations = 0
            let validator = LinkHTTPResponseCodeValidationRequest(httpRequest: request)
            validator.isValid(.mock()) { isValid in
                XCTAssertEqual(`case`.isValid, isValid)
                callbackInvocations += 1
            }
            XCTAssertEqual(callbackInvocations, 1)
        }
    }
}
