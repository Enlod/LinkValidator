//
//  Link.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 14.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

struct Link: Codable, Equatable {
    let title: String?
    let link: String
    var isFavorite = false
    
    enum CodingKeys: String, CodingKey {
        case title, link
    }
}
