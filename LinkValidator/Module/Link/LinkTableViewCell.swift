//
//  LinkTableViewCell.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 15.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import UIKit

final class LinkTableViewCell: UITableViewCell {
    
    // MARK: - State
    
    private let _linkLabel = UILabel()
    private let _validationActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _makeLayout()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Input
    
    func configure(with viewModel: LinkViewModel) {
        
        _linkLabel.text = viewModel.link
        
        viewModel.subscribeValidationStatus { [weak self] validationStatus in
            self?._handle(validationStatus)
        }
    }
    
    // MARK: - Private
    
    private func _handle(_ validationStatus: LinkViewModel.ValidationStatus) {
        
        var isInProgress = false
        var isValid = Link.IsValid.notDetermined
        
        switch validationStatus {
        case .inProgress:
            isInProgress = true
            
        case .completed(let _isValid):
            isValid = _isValid
        }
        
        isInProgress
            ? _validationActivityIndicatorView.startAnimating()
            : _validationActivityIndicatorView.stopAnimating()
        
        _linkLabel.textColor = isValid.map(
            determined: { $0 ? .systemGreen : .systemRed },
            notDetermined: .black)
    }
    
    private func _makeLayout() {
        
        _validationActivityIndicatorView.color = .blue
        
        [_linkLabel, _validationActivityIndicatorView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            _linkLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .spacing),
            _linkLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .spacing * 2),
            _linkLabel.rightAnchor.constraint(equalTo: _validationActivityIndicatorView.leftAnchor, constant: -.spacing),
            _linkLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.spacing),
            
            _validationActivityIndicatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -.spacing * 2),
            _validationActivityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

fileprivate extension CGFloat {
    static let spacing: CGFloat = 8
}
