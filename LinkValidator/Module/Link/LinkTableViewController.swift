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
    
    private var _links = [LinkViewModel]()
    
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

        _viewModel.subscribeRefreshing { [weak self] refreshing in
            self?._handle(refreshing)
        }
        
        _viewModel.subscribeLinks { [weak self] linksResult in
            self?._handle(linksResult)
        }
        
        _viewModel.requestLinks()
    }
    
    private func _handle(_ refreshing: Bool) {
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
    
    private func _handle(_ linksResult: Result<[LinkViewModel], LinkListViewModelError>) {
        
        var links = [LinkViewModel]()
        
        switch linksResult {
        case .failure(let error):
            let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel))
            alert.addAction(.init(title: "Retry", style: .default) { [weak self] _ in
                self?._viewModel.requestLinks()
            })
            present(alert, animated: true)
            
        case .success(let _links):
            links = _links
        }
        
        _links = links
        _refreshButton.isHidden = !links.isEmpty
        tableView.reloadData()
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
