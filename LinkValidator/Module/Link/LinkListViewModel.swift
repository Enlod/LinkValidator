//
//  LinkListViewModel.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import Foundation

enum LinkListViewModelError: Error {
    case failedToLoadLinks
}

protocol LinkListViewModel {
    func requestLinks()
    func subscribeErrors(_ callback: @escaping (LinkListViewModelError) -> Void)
    func subscribeLinks(_ callback: @escaping ([LinkViewModel]) -> Void)
}

final class LinkListViewModelImpl: LinkListViewModel {
    
    typealias Error = LinkListViewModelError
    
    // MARK: - State
    
    private let _linkListProvider: LinkListProvider
    
    private var _requestLinks: Disposable?
    
    private var
    _errorsCallback: ((Error) -> Void)?,
    _linksCallback: (([LinkViewModel]) -> Void)?
    
    // MARK: - Init
    
    init(linkListProvider: LinkListProvider) {
        _linkListProvider = linkListProvider
    }
    
    // MARK: - LinkListViewModel
    
    func requestLinks() {
        if _requestLinks != nil { return }
        _requestLinks = .init(_linkListProvider.links { [weak self] linksResult in
            self?._handle(linksResult)
        })
    }
    
    func subscribeErrors(_ callback: @escaping (Error) -> Void) {
        _errorsCallback = callback
    }
    
    func subscribeLinks(_ callback: @escaping ([LinkViewModel]) -> Void) {
        _linksCallback = callback
    }
    
    // MARK: - Private
    
    private func _handle(_ linksResult: Result<[Link], HTTPRequest.Error>) {
        
        _requestLinks = nil
        
        switch linksResult {
            
        case .failure:
            DispatchQueue.main.async {
                self._errorsCallback?(.failedToLoadLinks)
            }
            
        case .success(let links):
            let linkViewModels = links.map { link in
                LinkViewModel(
                    link: link,
                    validator: LinkHTTPResponseCodeValidationRequest())
            }
            CFRunLoopPerformBlock(CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue) {
                self._linksCallback?(linkViewModels)
            }
        }
    }
}
