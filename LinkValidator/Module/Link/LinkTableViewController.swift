//
//  LinkTableViewController.swift
//  LinkValidator
//
//  Created by Roman Voskovskyi on 14.10.2020.
//  Copyright © 2020 Enlod. All rights reserved.
//

import UIKit

final class LinkTableViewController: UITableViewController {

    typealias Cell = LinkTableViewCell
    
    // MARK: - State
    
    private let _viewModel: LinkListViewModel
    
    private lazy var _refreshButton = F.scope(UIButton()) {
        $0.setTitle("Refresh", for: .normal)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.addTarget(self, action: #selector(self._refreshAction), for: .touchUpInside)
        
        view.addSubview($0)
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            $0.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            $0.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private var _links = [LinkViewModel]() {
        didSet {
            _refreshButton.isHidden = _links.isEmpty == false
            tableView.reloadData()
        }
    }
    
    // MARK: - Init
    
    init(viewModel: LinkListViewModel) {
        _viewModel = viewModel
        
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _configureTableView()
        _connectViewModel()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        _links.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        _links[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let link = _links[indexPath.section]
        
        let cell: Cell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: link)
        cell.selectionStyle = .none
        
        return cell
    }
    
    // MARK: - Private
    
    private func _configureTableView() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self._refreshAction), for: .valueChanged)
        refreshControl.tintColor = .systemBlue
        tableView.refreshControl = refreshControl
    }
    
    private func _connectViewModel() {

        _viewModel.subscribeEvents { [weak self] event in
            self?._handle(event)
        }
        
        _viewModel.requestLinks()
    }
    
    private func _handle(_ event: LinkListViewModelEvent) {
        switch event {
        case .error(let error):
            _show(error)
        case .updatedIsRefreshing(let isRefreshing):
            _update(isRefreshing)
        case .updatedLinks(let links):
            _links = links
        }
    }
    
    private func _update(_ refreshing: Bool) {
        guard let refreshControl = tableView.refreshControl else { return }
        
        if refreshing {
            let minContentOffset = -refreshControl.frame.height
            if tableView.contentOffset.y > minContentOffset {
                tableView.setContentOffset(.init(x: 0, y: minContentOffset), animated: true)
            }
            refreshControl.beginRefreshing()
        }
        else {
            refreshControl.endRefreshing()
        }
    }
    
    private func _show(_ error: LinkListViewModelError) {
       let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func _refreshAction() {
        _viewModel.requestLinks()
    }
}

fileprivate extension UITableView {
    func dequeueReusableCell<Cell: UITableViewCell>(for indexPath: IndexPath) -> Cell {
        let cellID = String(describing: Cell.self)
        register(Cell.self, forCellReuseIdentifier: cellID)
        return dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! Cell
    }
}
