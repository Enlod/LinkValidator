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
    func links(callback: @escaping (Result<[Link], HTTPRequest.DecodeError>) -> Void) -> Cancellable
}

final class TestAPILinkListRequest: HTTPRequest, LinkListProvider {
    
    private static let session = URLSession(configuration: .default)
    
    init() {
        super.init(urlSession: Self.session)
    }
    
    @discardableResult
    func links(callback: @escaping (Result<[Link], HTTPRequest.DecodeError>) -> Void) -> Cancellable {
        get("https://testaskback.herokuapp.com/index.php", callback)
    }
}
