//
//  AllGroupsTableViewController.swift
//  vk_GuzelGubaydullina
//
//  Created by Guzel Gubaidullina on 01.04.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class AllGroupsTableViewController: UITableViewController {
    private var groups = [VKGroup]()
    private var filteredGroups = [VKGroup]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()
        navigationItem.rightBarButtonItem = nil
        tableView.tableFooterView = UIView()
    }
    
    private func requestData() {
        VKService.instance.loadGroups { result in
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
        guard let groups = RealmService.instance.fetchObjects(VKGroup.self) else {
            return
        }
        self.groups = groups
        self.tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroups.isEmpty ? groups.count : filteredGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllGroupsTableViewCell", for: indexPath) as! AllGroupsTableViewCell
        let group = filteredGroups.isEmpty ? groups[indexPath.row] : filteredGroups[indexPath.row]
        let avatarUrl = URL(string: group.avatarUrl)!
        cell.allGroupsNameLabel.text = group.groupName
        cell.allGroupsPhotoImageView.imageView.af.setImage(withURL: avatarUrl)
        cell.allGroupsPhotoImageView.setNeedsDisplay()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
    @IBAction func addGroups(segue: UIStoryboardSegue) {
        if segue.identifier == "addGroups" {
            let otherGroupsTableViewController = segue.source as! OtherGroupsTableViewController

            if let indexPath = otherGroupsTableViewController.tableView.indexPathForSelectedRow {
                let otherGroups = otherGroupsTableViewController.filteredGroups.isEmpty ? otherGroupsTableViewController.groups : otherGroupsTableViewController.filteredGroups
                let group = otherGroups[indexPath.row]
                if !groups.contains(group) {
                    groups.append(group)
                    tableView.reloadData()
                }
            }
        }
    }
    */
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return filteredGroups.isEmpty ? true : false
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            groups.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension AllGroupsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            clearSearch(searchBar)
            return
        }
        filteredGroups = groups.filter { $0.groupName.contains(searchText) }
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
        filteredGroups = [VKGroup]()
    }
}
