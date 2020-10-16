//
//  Link+Mocks.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 16.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

extension Link {
    static func mock(
        title: String? = nil,
        link: String = "",
        isFavorite: Bool = false
    ) -> Link {
        .init(
            title: title,
            link: link,
            isFavorite: isFavorite)
    }
}
