//
//  NewsTableViewController.swift
//  vk_GuzelGubaydullina
//
//  Created by Guzel Gubaidullina on 12.04.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    private var imageService: ImageService!
    private var startFrom: String?
    private var isLoading: Bool = false
    
    private var items = [VKNewsItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageService = ImageService(container: tableView)
        
        requestData()
        configureViewController()
        tableView.prefetchDataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func configureViewController() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(actionHandleRefreshControl(_:)),
                                 for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func requestData() {
        isLoading = true
        VKService.instance.loadNews(startFrom: startFrom) { [weak self] result, nextFrom in
            guard let self = self else {
                return
            }
            self.startFrom = nextFrom
            self.tableView.refreshControl?.endRefreshing()
            switch result {
            case .success(let items):
                self.items.append(contentsOf: items)
                self.tableView.reloadData()
                self.isLoading = false
            case .failure(let error):
                print(error)
                self.isLoading = false
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsModel = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        if cell.delegate == nil {
            cell.delegate = self
        }
        cell.authorImageView.image = imageService.photo(atIndexpath: indexPath,
                                                        byUrl: newsModel.authorAvatarUrl)
        cell.configure(with: newsModel)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func actionHandleRefreshControl(_ sender: UIRefreshControl) {
        startFrom = nil
        tableView.refreshControl?.beginRefreshing()
        requestData()
    }
}

extension NewsTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard   let indexPath = indexPaths.first,
                indexPath.row > (items.count - 3),
                !isLoading else {
            return
        }
        requestData()
    }
}

extension NewsTableViewController: NewsTableViewCellDelegate {
    func newsTableViewCell(_ cell: NewsTableViewCell, needReload: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath],
                             with: .automatic)
        tableView.endUpdates()
    }
}
