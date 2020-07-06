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
            case .success(let friends):
                print(friends)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func actionPhotosRequest(_ sender: UIButton) {
        VKService.instance.loadPhotos(userId: 30676891) { result in
            switch result {
            case .success(let photos):
                print(photos)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func actionGroupsRequest(_ sender: UIButton) {
        VKService.instance.loadGroups().get { groups in
            print(groups)
        }.catch { error in
            print(error)
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
