//
//  LinkViewModel.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

enum LinkViewModelValidationStatus: Equatable {
    case inProgress
    case completed(Bool)
}

enum LinkViewModelEvent {
    case updatedIsFavorite(Bool)
    case updatedValidationStatus(LinkViewModelValidationStatus)
}

protocol LinkViewModel {
    func setIsFavorite(_ isFavorite: Bool)
    
    var title: String { get }
    var link: String { get }
    func subscribeEvents(_ callback: @escaping (LinkViewModelEvent) -> Void)
}

final class LinkViewModelImpl: LinkViewModel {
    
    typealias Error = LinkViewModelValidationStatus
    typealias Event = LinkViewModelEvent
    typealias ValidationStatus = LinkViewModelValidationStatus
    
    static var emptyTitle: String { "Empty Title" }
    
    // MARK: - State
    
    private let _didUpdateLink: (Link) -> Void
    
    private var _link: Link {
        didSet {
            _didUpdateLink(_link)
        }
    }
    
    private var _status = ValidationStatus.inProgress {
        didSet {
            _notifyUpdatedValidationStatus()
        }
    }
    
    private var
    _validationRequest: Disposable?,
    _eventsCallback: ((Event) -> Void)?
    
    // MARK: - Init
    
    init(
        link: Link,
        didUpdateLink: @escaping (Link) -> Void,
        validator: LinkValidator) {
        
        _link = link
        _didUpdateLink = didUpdateLink
        
        _validationRequest = .init(validator.isValid(link) { [weak self] isValid in
            guard let self = self else { return }
            F.UI {
                self._status = .completed(isValid)
            }
        })
    }
    
    // MARK: - LinkViewModel
    
    func setIsFavorite(_ isFavorite: Bool) {
        if _link.isFavorite == isFavorite {
            return
        }
        _link.isFavorite = isFavorite
        _notifyUpdatedIsFavorite()
    }
    
    var title: String {
        if let title = _link.title,
            title.isEmpty == false {
            return title
        }
        return Self.emptyTitle
    }
    
    var link: String {
        _link.link
    }
    
    func subscribeEvents(_ callback: @escaping (LinkViewModelEvent) -> Void) {
        _eventsCallback = callback
        _notifyUpdatedIsFavorite()
        _notifyUpdatedValidationStatus()
    }
    
    // MARK: - Private
    
    private func _notifyUpdatedIsFavorite() {
        _eventsCallback?(.updatedIsFavorite(_link.isFavorite))
    }
    
    private func _notifyUpdatedValidationStatus() {
        _eventsCallback?(.updatedValidationStatus(_status))
    }
}
