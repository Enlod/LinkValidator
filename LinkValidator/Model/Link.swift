//
//  Link.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 14.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

struct Link: Codable {
    let title: String?
    let link: String
}

extension Link {
    enum IsValid {
        case notDetermined
        case determined(Bool)
        
        func map<Result>(
            determined: (Bool) -> Result,
            notDetermined: @autoclosure () -> Result
        ) -> Result
        {
            switch self {
                
            case .determined(let isValid):
                return determined(isValid)
                
            case .notDetermined:
                return notDetermined()
            }
        }
    }
}
