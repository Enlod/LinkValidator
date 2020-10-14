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
    func links(callback: @escaping (Result<[Link], HTTPRequest.Error>) -> Void) -> Cancellable
}

final class TestAPILinkListRequest: HTTPRequest, LinkListProvider {
    @discardableResult
    func links(callback: @escaping (Result<[Link], HTTPRequest.Error>) -> Void) -> Cancellable {
        get("https://testaskback.herokuapp.com/index.php", callback)
    }
}
