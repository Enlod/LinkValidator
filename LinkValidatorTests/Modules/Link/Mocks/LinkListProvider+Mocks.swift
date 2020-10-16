//
//  LinkListProvider+Mocks.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 17.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

struct LinkListProviderMock: LinkListProvider {
    
    var links = Result<[Link], HTTPRequestDecodeError>.success([])
    
    func links(callback: @escaping (Result<[Link], HTTPRequestDecodeError>) -> Void) -> Cancellable {
        callback(links)
        return .init()
    }
}
