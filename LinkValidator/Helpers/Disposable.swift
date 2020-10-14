//
//  Disposable.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

final class Disposable {
    
    private let _cancellable: Cancellable
    
    init(_ cancellable: Cancellable) {
         _cancellable = cancellable
    }
    
    deinit {
        _cancellable.cancel()
    }
}
