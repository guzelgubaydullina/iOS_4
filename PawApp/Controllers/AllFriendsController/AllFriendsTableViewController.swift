//
//  AllFriendsController.swift
//  vk_GuzelGubaydullina
//
//  Created by Guzel Gubaidullina on 31.03.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import UIKit
import RealmSwift

class AllFriendsTableViewController: UITableViewController {
    private var imageService: ImageService!
    
    private var filteredUsers = [VKUser]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var userGroups = [String: [VKUser]]() {
        didSet {
            users = userGroups.flatMap { $0.value }.sorted { $0.lastName < $1.lastName }
            tableView.reloadData()
        }
    }
    private var users = [VKUser]()
    private var sectionTitles = [String]()
    private var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageService = ImageService(container: tableView)
        
        requestData()
        tableView.tableFooterView = UIView()
    }
    
    private func requestData() {
        VKService.instance.loadFriends { result in
            switch result {
            case .success:
                self.fetchCachedData()
            case .failure(let error):
                self.fetchCachedData()
                print(error)
            }
        }
    }
    
    private func fetchCachedData() {
        guard let users = RealmService.instance.fetchObjects(VKUser.self) else {
            return
        }
        self.users = users
        self.configureUserGroups(with: users)
        self.configureRealmNotifications()
    }
    
    private func configureRealmNotifications() {
        guard let realm = try? Realm() else { return }
        token = realm.objects(VKUser.self).observe({ [weak self] changes in
            switch changes {
            case .initial:
                self?.tableView.reloadData()
            case .update(_,
                         deletions: let deletions,
                         insertions: let insertions,
                         modifications: let modifications):
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                self?.tableView.endUpdates()
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    private func configureUserGroups(with users: [VKUser]) {
        for user in users {
            let userKey = String(user.lastName.prefix(1))
            if var userGroup = userGroups[userKey] {
                userGroup.append(user)
                userGroups[userKey] = userGroup
            } else {
                userGroups[userKey] = [user]
            }
        }
        sectionTitles = [String](userGroups.keys)
        sectionTitles = sectionTitles.sorted { $0 < $1 }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        var user: VKUser? = nil
        if filteredUsers.isEmpty {
            let sectionTitle = sectionTitles[indexPath.section]
            user = userGroups[sectionTitle]?[indexPath.row]
        } else {
            user = filteredUsers[indexPath.row]
        }
        let viewController = FriendPhotosCollectionViewController()
        viewController.userId = user!.userId
        navigationController?.pushViewController(viewController,
                                                 animated: true)
    }

    // MARK: - UITableViewDataSource
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return filteredUsers.isEmpty ? sectionTitles : nil
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredUsers.isEmpty ? sectionTitles[section] : nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if filteredUsers.isEmpty {
            let sectionTitle = sectionTitles[section]
            return SectionHeaderView(sectionTitle: sectionTitle)
        } else {
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return filteredUsers.isEmpty ? sectionTitles.count : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredUsers.isEmpty {
            let sectionTitle = sectionTitles[section]
            return userGroups[sectionTitle]?.count ?? 0
        } else {
            return filteredUsers.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllFriendsTableViewCell",
                                                 for: indexPath) as! AllFriendsTableViewCell
        var user: VKUser? = nil
        if filteredUsers.isEmpty {
            let sectionTitle = sectionTitles[indexPath.section]
            user = userGroups[sectionTitle]?[indexPath.row]
        } else {
            user = filteredUsers[indexPath.row]
        }
        cell.friendNameLabel.text = String(format: "%@ %@", user!.firstName, user!.lastName)
        cell.friendProfilePhotoImageView.imageView.image = imageService.photo(atIndexpath: indexPath,
                                                                              byUrl: user!.avatarUrl ?? "")
        cell.friendProfilePhotoImageView.setNeedsDisplay()
        return cell
    }
}

extension AllFriendsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            clearSearch(searchBar)
            return
        }
        filteredUsers = users.filter { $0.lastName.lowercased().contains(searchText.lowercased()) ||
            $0.firstName.lowercased().contains(searchText.lowercased()) }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSearch(searchBar)
    }
    
    private func clearSearch(_ searchBar: UISearchBar) {
        searchBar.text = nil
        view.endEditing(true)
        filteredUsers = [VKUser]()
    }
}
