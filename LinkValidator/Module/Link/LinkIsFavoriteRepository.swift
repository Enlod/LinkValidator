//
//  LinkIsFavoriteRepository.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

protocol LinkIsFavoriteRepository {
    func setIsFavorite(forNew links: inout [Link])
    func handleUpdated(_ link: Link)
}

final class LinkIsFavoriteRepositoryImpl: LinkIsFavoriteRepository {
    
    // MARK - State
    
    private var _favoriteLinks = Set<String>()
    
    // MARK - LinkIsFavoriteRepository
    
    func setIsFavorite(forNew links: inout [Link]) {
        links.enumerated().forEach { index, link in
            if _favoriteLinks.contains(link.link) == false {
                return
            }
            var link = link
            link.isFavorite = true
            links[index] = link
        }
    }
    
    func handleUpdated(_ link: Link) {
        if link.isFavorite {
            _favoriteLinks.insert(link.link)
        }
        else {
            _favoriteLinks.remove(link.link)
        }
    }
}
