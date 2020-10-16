//
//  LinkViewModel+Mocks.swift
//  LinkValidatorTests
//
//  Created by Roman Voskovskyi on 17.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

struct LinkViewModelMock: LinkViewModel {
    func setIsFavorite(_ isFavorite: Bool) { }
    var title = ""
    var link = ""
    func subscribeEvents(_ callback: @escaping (LinkViewModelEvent) -> Void) {}
}
