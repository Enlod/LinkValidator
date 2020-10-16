//
//  LinkIsFavoriteRepositoryTests.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 16.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import XCTest

final class LinkIsFavoriteRepositoryTests: XCTestCase {
    
    func test() {
        
        let links = (0..<100).map { Link.stub(index: $0, isFavorite: Bool.random()) }
        
        let repository = LinkIsFavoriteRepositoryImpl()
        links.forEach(repository.handleUpdated)
        
        var newLinks = (0..<120).map { Link.stub(index: $0, isFavorite: false) }
        repository.setIsFavorite(forNew: &newLinks)
        
        newLinks.enumerated().forEach { index, link in
            var isFavorite = false
            if index < links.count {
                isFavorite = links[index].isFavorite
            }
            XCTAssertEqual(link.isFavorite, isFavorite)
        }
    }
}

fileprivate extension Link {
    static func stub(index: Int, isFavorite: Bool) -> Link {
        .init(
            title: nil,
            link: index.description,
            isFavorite: isFavorite)
    }
}
