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
        let linkViewModel = LinkViewModelImpl.mock(link: link)
        
        XCTAssertEqual(link.title, linkViewModel.title)
    }
    
    func testEmptyTitle() {
        let link = Link.mock(title: "")
        let linkViewModel = LinkViewModelImpl.mock(link: link)
        
        XCTAssertEqual(linkViewModel.title, LinkViewModelImpl.emptyTitle)
    }
    
    func testNilTitle() {
        let link = Link.mock()
        let linkViewModel = LinkViewModelImpl.mock(link: link)
        
        XCTAssertEqual(linkViewModel.title, LinkViewModelImpl.emptyTitle)
    }
    
    func testLink() {
        let link = Link.mock(link: "some link")
        let linkViewModel = LinkViewModelImpl.mock(link: link)
        
        XCTAssertEqual(link.link, linkViewModel.link)
    }
    
    func testUpdateFavoriteToSameValueShouldNotInvokeCallback() {
        [false, true].forEach { isFavorite in
            
            let linkViewModel = LinkViewModelImpl.mock(
                link: .mock(isFavorite: isFavorite),
                didUpdateLink: { link in
                    XCTFail()
                })
            
            var incocations = 0
            linkViewModel.subscribeEvents { event in
                switch event {
                case .updatedValidationStatus: break
                case .updatedIsFavorite:
                    incocations += 1
                    if incocations > 1 {
                        XCTFail()
                    }
                }
            }
            
            linkViewModel.setIsFavorite(isFavorite)
        }
    }
    
    func testUpdateIsFavorite() {
        [false, true].forEach { isFavorite in
            
            var callbackInvocations = 0
            var chageCallbackInvocations = 0
            
            let linkViewModel = LinkViewModelImpl.mock(
                link: .mock(isFavorite: !isFavorite),
                didUpdateLink: { _link in
                    XCTAssertEqual(_link.isFavorite, isFavorite)
                    chageCallbackInvocations += 1
                })
            
            linkViewModel.setIsFavorite(isFavorite)
            
            linkViewModel.subscribeEvents { event in
                switch event {
                case .updatedValidationStatus: break
                case .updatedIsFavorite(let _isFavorite):
                    XCTAssertEqual(_isFavorite, isFavorite)
                    callbackInvocations += 1
                }
            }
            
            XCTAssertEqual(callbackInvocations, 1)
            XCTAssertEqual(chageCallbackInvocations, 1)
        }
    }
    
    func testReplayIsFavoriteInitialValue() {
        [false, true].forEach { isFavorite in
            
            let linkViewModel = LinkViewModelImpl.mock(link: .mock(isFavorite: isFavorite))
            
            linkViewModel.subscribeEvents { event in
                switch event {
                case .updatedValidationStatus: break
                case .updatedIsFavorite(let _isFavorite):
                    XCTAssertEqual(isFavorite, _isFavorite)
                }
            }
        }
    }
    
    func testValidationStatus() {
        var callbackInvocations = 0
        let values = [true, false, nil]
        
        values.forEach { isValid in
            
            let validator = LinkValidatorMock(isValid: isValid)
            let linkViewModel = LinkViewModelImpl.mock(validator: validator)
            
            linkViewModel.subscribeEvents { event in
                switch event {
                case .updatedIsFavorite: break
                case .updatedValidationStatus(let status):
                    callbackInvocations += 1
                    switch isValid {
                    case nil:
                        XCTAssertEqual(status, .inProgress)
                    case .some(let isValid):
                        XCTAssertEqual(status, .completed(isValid))
                    }
                }
            }
        }
        
        XCTAssertEqual(callbackInvocations, values.count)
    }
}

fileprivate extension LinkViewModelImpl {
    static func mock(
        link: Link = .mock(),
        didUpdateLink: @escaping (Link) -> Void = { _ in },
        validator: LinkValidator = LinkValidatorMock()
    ) -> LinkViewModelImpl {
        .init(
            link: link,
            didUpdateLink: didUpdateLink,
            validator: validator)
    }
}
