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

protocol LinkListViewModel {
    func requestLinks()
    func subscribeRefreshing(_ callback: @escaping (Bool) -> Void)
    func subscribeLinks(_ callback: @escaping (Result<[LinkViewModel], LinkListViewModelError>) -> Void)
}

final class LinkListViewModelImpl: LinkListViewModel {
    
    typealias Error = LinkListViewModelError
    
    // MARK: - State
    
    private let
    _linkListProvider: LinkListProvider,
    _linkIsFavoriteRepository: LinkIsFavoriteRepository,
    _lock = NSRecursiveLock()
    
    private var
    _requestLinks: Disposable?,
    _refreshingCallback: ((Bool) -> Void)?,
    _linksCallback: ((Result<[LinkViewModel], LinkListViewModelError>) -> Void)?
    
    // MARK: - Init
    
    init(
        linkListProvider: LinkListProvider,
        linkIsFavoriteRepository: LinkIsFavoriteRepository) {
        
        _linkListProvider = linkListProvider
        _linkIsFavoriteRepository = linkIsFavoriteRepository
    }
    
    // MARK: - LinkListViewModel
    
    func requestLinks() {
        if _requestLinks != nil { return }
        _refreshingCallback?(true)
        _requestLinks = .init(_linkListProvider.links { [weak self] linksResult in
            self?._handle(linksResult)
        })
    }
    
    func subscribeRefreshing(_ callback: @escaping (Bool) -> Void) {
        _refreshingCallback = callback
    }
    
    func subscribeLinks(_ callback: @escaping (Result<[LinkViewModel], LinkListViewModelError>) -> Void) {
        _linksCallback = callback
    }
    
    // MARK: - Private
    
    private func _handle(_ linksResult: Result<[Link], HTTPRequest.DecodeError>) {
        
        _lock.lock(); defer { _lock.unlock() }
        
        _requestLinks = nil
        F.UI {
            self._refreshingCallback?(false)
        }
        
        let result: Result<[LinkViewModel], LinkListViewModelError>
        
        switch linksResult {
            
        case .failure:
            result = .failure(.failedToLoadLinks)
            
        case .success(let links):
            result = .success(_linkIsFavoriteRepository.setIsFavorite(forNew: links).map(_makeViewModel))
        }
        
        F.UI {
            self._linksCallback?(result)
        }
    }
    
    private func _makeViewModel(for link: Link) -> LinkViewModel {
        
        LinkViewModel(
            link: link,
            didUpdateLink: { [weak self] link in
                self?._linkIsFavoriteRepository.handleUpdated(link)
            },
            validator: LinkHTTPResponseCodeValidationRequest())
    }
}
