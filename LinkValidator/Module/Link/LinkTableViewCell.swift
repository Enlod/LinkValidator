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
    
    private let _validationActivityIndicator = F.scope(UIActivityIndicatorView()) {
        $0.color = .systemBlue
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private lazy var _validationActivityIndicatorZeroWidthContraint = _validationActivityIndicator.widthAnchor.constraint(equalToConstant: 0)
    
    private let _linkLabel = F.scope(UILabel()) {
        $0.font = $0.font.withSize(UIFont.smallSystemFontSize)
        $0.numberOfLines = 0
    }
    
    private lazy var _linkLabelLeftContraint = _linkLabel.leftAnchor.constraint(equalTo: _validationActivityIndicator.rightAnchor)
    
    private lazy var _isFavoriteSwitch = F.scope(UISwitch()) {
        let scale: CGFloat = 0.7
        $0.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
        $0.onTintColor = .systemYellow
        $0.addTarget(self, action: #selector(self._switchFavoriteAction), for: .valueChanged)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private var
    _initialConfigurationCompleted = false,
    _viewModel: LinkViewModel?
    
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
        _initialConfigurationCompleted = false
        
        _viewModel = viewModel
        _linkLabel.text = viewModel.link
        
        viewModel.subscribeEvents { [weak self] event in
            self?._handle(event)
        }
        _initialConfigurationCompleted = true
    }
    
    // MARK: - Private
    
    private func _handle(_ event: LinkViewModelEvent) {
        switch event {
        case .updatedIsFavorite(let isFavorite):
            _isFavoriteSwitch.isOn = isFavorite
        case .updatedValidationStatus(let validationStatus):
            _handle(validationStatus)
        }
    }
    
    private func _handle(_ validationStatus: LinkViewModelValidationStatus) {
        
        var isInProgress = false
        let linkColor: UIColor
        var isValid: Bool?
        
        switch validationStatus {
        case .inProgress:
            isInProgress = true
            
        case .completed(let _isValid):
            isValid = _isValid
        }
        
        switch isValid {
        case nil:
            linkColor = .black
        case .some(let isValid):
            linkColor = isValid ? .systemGreen : .systemRed
        }
        
        isInProgress
            ? _validationActivityIndicator.startAnimating()
            : _validationActivityIndicator.stopAnimating()
        
        let update = {
            self._validationActivityIndicatorZeroWidthContraint.isActive = !isInProgress
            self._linkLabelLeftContraint.constant = isInProgress ? .spacing : 0
            self._linkLabel.textColor = linkColor
            self.contentView.layoutIfNeeded()
        }
        
        if !_initialConfigurationCompleted || window == nil {
            update()
        }
        else {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0, options: .curveEaseInOut,
                animations: update)
        }
    }
    
    private func _makeLayout() {
        
        [_validationActivityIndicator, _linkLabel, _isFavoriteSwitch].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            _validationActivityIndicator.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: .spacing * 2),
            _validationActivityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            _linkLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .spacing),
            _linkLabelLeftContraint,
            _linkLabel.rightAnchor.constraint(equalTo: _isFavoriteSwitch.leftAnchor, constant: -.spacing * 2),
            _linkLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -.spacing),
            
            _isFavoriteSwitch.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant:  -.spacing),
            _isFavoriteSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    @objc private func _switchFavoriteAction() {
        _viewModel?.setIsFavorite(_isFavoriteSwitch.isOn)
    }
}

fileprivate extension CGFloat {
    static let spacing: CGFloat = 8
}
