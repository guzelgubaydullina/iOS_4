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
    
    private var items = [VKNewsItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageService = ImageService(container: tableView)
        
        requestData()
        tableView.tableFooterView = UIView()
    }
    
    private func requestData() {
        VKService.instance.loadNews { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.items = items
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsModel = items[indexPath.row]
        let avatarUrl = URL(string: newsModel.authorAvatarUrl)!
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        cell.authorImageView.image = imageService.photo(atIndexpath: indexPath,
                                                        byUrl: newsModel.authorAvatarUrl)
        cell.configure(with: newsModel)
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
