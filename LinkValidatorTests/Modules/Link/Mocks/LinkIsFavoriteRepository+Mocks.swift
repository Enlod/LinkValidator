//
//  LinkIsFavoriteRepository+Mocks.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 17.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

struct LinkIsFavoriteRepositoryMock: LinkIsFavoriteRepository {
    
    var setIsFavorite: (([Link]) -> Void)?
    var handleUpdated: ((Link) -> Void)?
    
    func setIsFavorite(forNew links: inout [Link]) {
        setIsFavorite?(links)
    }
    
    func handleUpdated(_ link: Link) {
        handleUpdated?(link)
    }
}
