//
//  LinkListViewModelTests.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 16.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import XCTest

final class LinkListViewModelTests: XCTestCase {
    
    func testReplayInitialValues() {
        let viewModel = LinkListViewModelImpl.stub()
        viewModel.subscribeEvents { event in
            switch event {
            case .error: XCTFail()
            case .updatedIsRefreshing(let isRefresing):
                XCTAssertFalse(isRefresing)
            case .updatedLinks(let links):
                XCTAssertTrue(links.isEmpty)
            }
        }
    }
    
    func testIsRefresing() {
        var values = [Bool]()
        let listProvider = LinkListProviderMock()
        listProvider.links = .success([])
        let viewModel = LinkListViewModelImpl.stub(listProvider: listProvider)
        viewModel.subscribeEvents { event in
            switch event {
            case .error, .updatedLinks: break
            case .updatedIsRefreshing(let isRefresing):
                values.append(isRefresing)
            }
        }
        viewModel.requestLinks()
        XCTAssertEqual(values, [false, true, false])
    }
    
    func testNotCallingLinksProviderTwice() {
        let listProvider = LinkListProviderMock()
        let viewModel = LinkListViewModelImpl.stub(listProvider: listProvider)
        viewModel.requestLinks()
        viewModel.requestLinks()
        XCTAssertEqual(listProvider.invokes, 1)
    }
    
    func testNotCallingLinksProviderBeforeViewRequested() {
        let listProvider = LinkListProviderMock()
        let viewModel = LinkListViewModelImpl.stub(listProvider: listProvider)
        XCTAssertEqual(listProvider.invokes, 0)
        viewModel.requestLinks()
        XCTAssertEqual(listProvider.invokes, 1)
    }
    
    func testError() {
        var invocations = 0
        let listProvider = LinkListProviderMock()
        listProvider.links = .failure(.unexpectedServerResponse)
        let viewModel = LinkListViewModelImpl.stub(listProvider: listProvider)
        viewModel.subscribeEvents { event in
            switch event {
            case .updatedIsRefreshing, .updatedLinks: break
            case .error:
                invocations += 1
            }
        }
        viewModel.requestLinks()
        XCTAssertEqual(invocations, 1)
    }
    
    func testLinks() {
        var invocations = 0
        let links = (0..<10).map { _ in Link.mock() }
        
        let listProvider = LinkListProviderMock()
        listProvider.links = .success(links)
        
        let viewModel = LinkListViewModelImpl.stub(listProvider: listProvider)
        viewModel.subscribeEvents { event in
            switch event {
            case .error: XCTFail()
            case .updatedIsRefreshing: break
            case .updatedLinks(let _links):
                switch invocations {
                case 0: XCTAssertTrue(_links.isEmpty)
                case 1: XCTAssertEqual(_links.count, links.count)
                default: XCTFail()
                }
                invocations += 1
            }
        }
        viewModel.requestLinks()
    }
    
    func testIsFavoriteRepositoryInvoked() {
        let links = (0..<10).map { _ in Link.mock() }
        
        let listProvider = LinkListProviderMock()
        listProvider.links = .success(links)
        
        var setIsFavoriteInvocations = 0
        let linkIsFavoriteRepository = LinkIsFavoriteRepositoryMock()
        linkIsFavoriteRepository.setIsFavorite = { links in
            setIsFavoriteInvocations += 1
        }
        
        let viewModel = LinkListViewModelImpl.stub(
            listProvider: listProvider,
            linkIsFavoriteRepository: linkIsFavoriteRepository)
        viewModel.requestLinks()
        
        XCTAssertEqual(setIsFavoriteInvocations, 1)
    }
}

fileprivate extension LinkListViewModelImpl {
    static func stub(
        listProvider: LinkListProvider = LinkListProviderMock(),
        linkIsFavoriteRepository: LinkIsFavoriteRepository = LinkIsFavoriteRepositoryMock()
    ) -> LinkListViewModelImpl {
        .init(
            linkListProvider: listProvider,
            linkIsFavoriteRepository: linkIsFavoriteRepository,
            linkViewModelFactory: { _, _ in
                LinkViewModelMock()
            })
    }
}
