//
//  LinkListProvider+Mocks.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 17.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

final class LinkListProviderMock: LinkListProvider {
    
    var links: Result<[Link], HTTPRequestDecodeError>?
    var invokes = 0
    
    func links(callback: @escaping (Result<[Link], HTTPRequestDecodeError>) -> Void) -> Cancellable {
        invokes += 1
        links.map(callback)
        return .init()
    }
}
