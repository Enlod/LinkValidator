//
//  LinkViewModelTests.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 16.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import XCTest

final class LinkViewModelTests: XCTestCase {
    
    func testTitle() {
        let link = Link.mock(title: "some title")
        let linkViewModel = LinkViewModel.mock(link: link)
        
        XCTAssertEqual(link.title, linkViewModel.title)
    }
    
    func testEmptyTitle() {
        let link = Link.mock(title: "")
        let linkViewModel = LinkViewModel.mock(link: link)
        
        XCTAssertEqual(linkViewModel.title, LinkViewModel.emptyTitle)
    }
    
    func testNilTitle() {
        let link = Link.mock()
        let linkViewModel = LinkViewModel.mock(link: link)
        
        XCTAssertEqual(linkViewModel.title, LinkViewModel.emptyTitle)
    }
    
    func testLink() {
        let link = Link.mock(link: "some link")
        let linkViewModel = LinkViewModel.mock(link: link)
        
        XCTAssertEqual(link.link, linkViewModel.link)
    }
    
    func testUpdateFavoriteToSameValueShouldNotInvokeCallback() {
        [false, true].forEach { isFavorite in
            
            let linkViewModel = LinkViewModel.mock(
                link: .mock(isFavorite: isFavorite),
                didUpdateLink: { link in
                    XCTFail()
                })
            
            var incocations = 0
            linkViewModel.subscribeIsFavorite { _ in
                incocations += 1
                if incocations > 1 {
                    XCTFail()
                }
            }
            
            linkViewModel.setIsFavourite(isFavorite)
        }
    }
    
    func testUpdateIsFavorite() {
        [false, true].forEach { isFavorite in
            
            var callbackInvocations = 0
            var chageCallbackInvocations = 0
            
            let linkViewModel = LinkViewModel.mock(
                link: .mock(isFavorite: !isFavorite),
                didUpdateLink: { _link in
                    XCTAssertEqual(_link.isFavorite, isFavorite)
                    chageCallbackInvocations += 1
                })
            
            linkViewModel.setIsFavourite(isFavorite)
            
            linkViewModel.subscribeIsFavorite { _isFavorite in
                XCTAssertEqual(_isFavorite, isFavorite)
                callbackInvocations += 1
            }
            
            XCTAssertEqual(callbackInvocations, 1)
            XCTAssertEqual(chageCallbackInvocations, 1)
        }
    }
    
    func testReplayIsFavoriteInitialValue() {
        [false, true].forEach { isFavorite in
            
            let linkViewModel = LinkViewModel.mock(link: .mock(isFavorite: isFavorite))
            
            linkViewModel.subscribeIsFavorite { _isFavorite in
                XCTAssertEqual(isFavorite, _isFavorite)
            }
        }
    }
    
    func testValidationStatus() {
        var callbackInvocations = 0
        let values = [true, false, nil]
        
        values.forEach { isValid in
            
            let validator = LinkValidatorMock(isValid: isValid)
            let linkViewModel = LinkViewModel.mock(validator: validator)
            
            linkViewModel.subscribeValidationStatus { status in
                switch isValid {
                case nil:
                    XCTAssertEqual(status, .inProgress)
                case .some(let isValid):
                    XCTAssertEqual(status, .completed(isValid))
                }
                callbackInvocations += 1
            }
        }
        
        XCTAssertEqual(callbackInvocations, values.count)
    }
}

fileprivate extension LinkViewModel {
    static func mock(
        link: Link = .mock(),
        didUpdateLink: @escaping (Link) -> Void = { _ in },
        validator: LinkValidator = LinkValidatorMock()
    ) -> LinkViewModel {
        .init(
            link: link,
            didUpdateLink: didUpdateLink,
            validator: validator)
    }
}
