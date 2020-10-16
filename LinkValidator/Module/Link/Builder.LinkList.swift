//
//  Builder.LinkList.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 17.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import UIKit

extension Module {
    
    static func linkList() -> UIViewController {
        
        let linkListProvider = TestAPILinkListRequest(
            httpRequest: HTTPRequestImpl(
                urlSession: TestAPILinkListRequest.session))
        
        let linkListViewModel =
            LinkListViewModelImpl(
                linkListProvider: linkListProvider,
                linkIsFavoriteRepository: LinkIsFavoriteRepositoryImpl(),
                linkViewModelFactory: _linkViewModel)
        
        return LinkTableViewController(viewModel: linkListViewModel)
    }
    
    private static func _linkViewModel(link: Link, didChange: @escaping (Link) -> Void) -> LinkViewModel {
        
        let validator = LinkHTTPResponseCodeValidationRequest(
            httpRequest: HTTPRequestImpl(
                urlSession: LinkHTTPResponseCodeValidationRequest.session))
        
        return LinkViewModelImpl(
            link: link,
            didUpdateLink: didChange,
            validator: validator)
    }
}
