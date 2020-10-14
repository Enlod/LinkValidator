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
        tableView.refreshControl = refreshControl
    }
    
    private func _connectViewModel() {
        
        _viewModel.subscribeErrors { error in
            print(error)
        }
        
        _viewModel.subscribeLinks { [weak self] links in
            self?._handle(links)
        }
        
        _viewModel.requestLinks()
    }
    
    private func _handle(_ links: [LinkViewModel]) {
        _links = links
        tableView.refreshControl?.endRefreshing()
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
