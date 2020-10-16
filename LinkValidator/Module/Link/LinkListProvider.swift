//
//  LinkListProvider.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

protocol LinkListProvider {
    @discardableResult
    func links(callback: @escaping (Result<[Link], HTTPRequestDecodeError>) -> Void) -> Cancellable
}

final class TestAPILinkListRequest: HTTPRequestContainer, LinkListProvider {
    
    static let session = URLSession(configuration: .default)
    
    init() {
        super.init(httpRequest: HTTPRequestImpl(urlSession: Self.session))
    }
    
    @discardableResult
    func links(callback: @escaping (Result<[Link], HTTPRequestDecodeError>) -> Void) -> Cancellable {
        httpRequest.get("https://testaskback.herokuapp.com/index.php", callback)
    }
}
