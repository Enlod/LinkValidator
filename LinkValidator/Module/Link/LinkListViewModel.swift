//
//  LinkListViewModel.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

enum LinkListViewModelError: LocalizedError {
    case failedToLoadLinks
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadLinks: return "Failed to load links"
        }
    }
}

enum LinkListViewModelEvent {
    case updatedIsRefreshing(Bool)
    case updatedLinks([LinkViewModel])
    case error(LinkListViewModelError)
}

protocol LinkListViewModel {
    func requestLinks()
    func subscribeEvents(_ callback: @escaping (LinkListViewModelEvent) -> Void)
}

final class LinkListViewModelImpl: LinkListViewModel {
    
    typealias Error = LinkListViewModelError
    typealias Event = LinkListViewModelEvent
    
    // MARK: - State
    
    private let
    _linkListProvider: LinkListProvider,
    _linkIsFavoriteRepository: LinkIsFavoriteRepository,
    _linkViewModelFactory: LinkViewModelFactory,
    _lock = NSRecursiveLock()
    
    private var _links: Result<[LinkViewModel], LinkListViewModelError>? {
        didSet {
            _notifyUpdatedLinksAndError()
        }
    }
    
    private var
    _requestLinks: Disposable?,
    _eventsCallback: ((Event) -> Void)?
    
    // MARK: - Init
    
    init(
        linkListProvider: LinkListProvider,
        linkIsFavoriteRepository: LinkIsFavoriteRepository,
        linkViewModelFactory: @escaping LinkViewModelFactory) {
        
        _linkListProvider = linkListProvider
        _linkIsFavoriteRepository = linkIsFavoriteRepository
        _linkViewModelFactory = linkViewModelFactory
    }
    
    // MARK: - LinkListViewModel
    
    func requestLinks() {
        if _requestLinks != nil { return }
        _notifyUpdatedIsRefreshing(true)
        _requestLinks = .init(_linkListProvider.links { [weak self] linksResult in
            self?._handle(linksResult)
        })
    }
    
    func subscribeEvents(_ callback: @escaping (LinkListViewModelEvent) -> Void) {
        _eventsCallback = callback
        _notifyUpdatedIsRefreshing(_requestLinks != nil)
        _notifyUpdatedLinksAndError()
    }
    
    // MARK: - Private
    
    private func _handle(_ linksResult: Result<[Link], HTTPRequestDecodeError>) {
        
        _lock.lock(); defer { _lock.unlock() }
        
        let links: Result<[LinkViewModel], LinkListViewModelError>
        
        switch linksResult {
        case .failure:
            links = .failure(.failedToLoadLinks)
            
        case .success(var _links):
            _linkIsFavoriteRepository.setIsFavorite(forNew: &_links)
            links = .success(_links.map(_makeViewModel))
        }
        
        self._requestLinks = nil
        
        F.UI {
            self._notifyUpdatedIsRefreshing(false)
            self._links = links
        }
    }
    
    private func _makeViewModel(for link: Link) -> LinkViewModel {
        _linkViewModelFactory(link, _linkIsFavoriteRepository)
    }
    
    private func _notifyUpdatedIsRefreshing(_ isRefreshing: Bool) {
        _eventsCallback?(.updatedIsRefreshing(isRefreshing))
    }
    
    private func _notifyUpdatedLinksAndError() {
        var links = [LinkViewModel]()
        
        switch _links {
        case nil: break
        case .failure(let error):
            _eventsCallback?(.error(error))
        case .success(let _links):
            links = _links
        }
        
        _eventsCallback?(.updatedLinks(links))
    }
}
