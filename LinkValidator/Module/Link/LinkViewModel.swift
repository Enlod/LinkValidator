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
        case completed(Bool)
    }
    
    // MARK: - State
    
    
    private let _didUpdateLink: (Link) -> Void
    
    private var _link: Link {
        didSet {
            _didUpdateLink(_link)
        }
    }
    
    private var
    _validationRequest: Disposable?,
    _status = ValidationStatus.inProgress
    
    private var _isFavoriteCallback: ((Bool) -> Void)? {
        didSet {
            _notifyIsFaforiteSubscriber()
        }
    }
    
    private var _validationStatusCallback: ((ValidationStatus) -> Void)? {
        didSet {
            _notifyValidationStatusSubscriber()
        }
    }
    
    // MARK: - Init
    
    init(
        link: Link,
        didUpdateLink: @escaping (Link) -> Void,
        validator: LinkValidator) {
        
        _link = link
        _didUpdateLink = didUpdateLink
        
        _validationRequest = .init(validator.isValid(link) { [weak self] isValid in
            guard let self = self else { return }
            
            self._status = .completed(isValid)
            F.UI(self._notifyValidationStatusSubscriber)
        })
    }
    
    // MARK: - Input
    
    func setIsFavourite(_ isFavourite: Bool) {
        if _link.isFavorite == isFavourite {
            return
        }
        _link.isFavorite = isFavourite
        _notifyIsFaforiteSubscriber()
    }
    
    // MARK: - Output
    
    var title: String {
        _link.title ?? "Empty Title"
    }
    
    var link: String {
        _link.link
    }
    
    func subscribeIsFavorite(_ callback: @escaping (Bool) -> Void) {
        _isFavoriteCallback = callback
    }

    func subscribeValidationStatus(_ callback: @escaping (ValidationStatus) -> Void) {
        _validationStatusCallback = callback
    }
    
    // MARK: - Private
    
    private func _notifyIsFaforiteSubscriber() {
        _isFavoriteCallback?(_link.isFavorite)
    }

    private func _notifyValidationStatusSubscriber() {
        _validationStatusCallback?(self._status)
    }
}
