//
//  LinkIsFavoriteRepository.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

protocol LinkIsFavoriteRepository {
    func setIsFavorite(forNew links: [Link]) -> [Link]
    func handleUpdated(_ link: Link)
}

final class LinkIsFavoriteRepositoryImpl: LinkIsFavoriteRepository {
    
    // MARK - State
    
    private var _favoriteLinks = Set<String>()
    
    // MARK - LinkIsFavoriteRepository
    
    func setIsFavorite(forNew links: [Link]) -> [Link] {
        
        links.map { link in
            var link = link
            if _favoriteLinks.contains(link.link) {
                link.isFavorite = true
            }
            return link
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
