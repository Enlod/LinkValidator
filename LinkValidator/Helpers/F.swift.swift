//
//  F.swift.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

enum F {
    static func scope<Value>(_ value: Value, _ action: (inout Value) -> Void) -> Value {
        var value = value
        action(&value)
        return value
    }
    
    static func UI(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        }
        else {
            DispatchQueue.main.async(execute: action)
        }
    }
}
