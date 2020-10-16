//
//  LinkListProviderTests.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 17.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import XCTest

final class LinkListProviderTests: XCTestCase {
    func test() {
        let expectation = self.expectation(description: "links request")
        
        TestAPILinkListRequest().links { links in
            switch links {
            case .failure: XCTFail()
            case .success: break
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
