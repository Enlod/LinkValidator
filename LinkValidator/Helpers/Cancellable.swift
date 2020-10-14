//
//  Cancellable.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

final class Cancellable {
    
    private var _action: (() -> Void)?
    
    init(_ action: (() -> Void)? = nil) {
        _action = action
    }
    
    func cancel() {
        guard let action = _action else { return }
        _action = nil
        action()
    }
}
