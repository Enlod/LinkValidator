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
        
        let linkListViewModel =
            LinkListViewModelImpl(
                linkListProvider: TestAPILinkListRequest(),
                linkIsFavoriteRepository: LinkIsFavoriteRepositoryImpl(),
                linkViewModelFactory: _linkViewModel)
        
        return LinkTableViewController(viewModel: linkListViewModel)
    }
    
    private static func _linkViewModel(link: Link, isFavoriteUpdateHandler: LinkIsFavoriteUpdateHandler) -> LinkViewModel {
        
        let validator = LinkHTTPResponseCodeValidationRequest(
            httpRequest: HTTPRequestImpl(
                urlSession: LinkHTTPResponseCodeValidationRequest.session))
        
        return LinkViewModelImpl(
            link: link,
            isFavoriteUpdateHandler: isFavoriteUpdateHandler,
            validator: validator)
    }
}
