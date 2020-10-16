//
//  LinkValidator+Mocks.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 16.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

struct LinkValidatorMock: LinkValidator {
    
    var isValid: Bool?
    
    func isValid(_ link: Link, _ callback: @escaping (Bool) -> Void) -> Cancellable {
        isValid.map(callback)
        return .init()
    }
}
