//
//  LinkViewModel.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

final class LinkViewModel {
    
    enum ValidationStatus {
        case inProgress
        case completed(Link.IsValid)
    }
    
    // MARK: - State
    
    private let _link: Link
    
    private var _status = ValidationStatus.inProgress
    private var _validationStatusCallback: ((ValidationStatus) -> Void)? {
        didSet {
            _notifyValidationStatusSubscribers()
        }
    }
    
    // MARK: - Init
    
    init(link: Link, validator: LinkValidator) {
        _link = link
        
        validator.isValid(link.link) { [weak self] isValid in
            guard let self = self else { return }
            self._status = .completed(isValid)
            self._notifyValidationStatusSubscribers()
        }
    }
    
    // MARK: - Output
    
    var title: String {
        _link.title ?? "Empty Title"
    }
    
    var link: String {
        _link.link
    }
    
    func subscribeValidationStatus(_ callback: @escaping (ValidationStatus) -> Void) {
        _validationStatusCallback = callback
    }
    
    // MARK: - Private
    
    private func _notifyValidationStatusSubscribers() {
        guard let validationStatusCallback = _validationStatusCallback else { return }
        
        let notify = {
            validationStatusCallback(self._status)
        }
        
        if Thread.isMainThread {
            notify()
        }
        else {
            DispatchQueue.main.async(execute: notify)
        }
    }
}
