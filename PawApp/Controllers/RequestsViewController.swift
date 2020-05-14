//
//  RequestsViewController.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 14.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController {
    @IBOutlet weak var searchGroupsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func actionFriendsRequest(_ sender: UIButton) {
        VKService.instance.loadFriends { result in
            switch result {
            case .success(let friendsData):
                guard let friendsData = friendsData else {
                    return
                }
                print(friendsData)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func actionPhotosRequest(_ sender: UIButton) {
        VKService.instance.loadPhotos { result in
            switch result {
            case .success(let photosData):
                guard let photosData = photosData else {
                    return
                }
                print(photosData)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func actionGroupsRequest(_ sender: UIButton) {
        VKService.instance.loadGroups { result in
            switch result {
            case .success(let groupsData):
                guard let groupsData = groupsData else {
                    return
                }
                print(groupsData)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func actionGroupsSearchRequest(_ sender: UIButton) {
        guard let searchQuery = searchGroupsTextField.text,
            !searchQuery.isEmpty else {
            return
        }
        
        VKService.instance.searchGroups(searchQuery: searchQuery) { result in
            switch result {
            case .success(let searchResultsData):
                guard let searchResultsData = searchResultsData else {
                    return
                }
                print(searchResultsData)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension RequestsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
