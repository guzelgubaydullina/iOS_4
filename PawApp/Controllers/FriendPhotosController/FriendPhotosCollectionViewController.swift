//
//  FriendsPhotosCollectionViewController.swift
//  vk_GuzelGubaydullina
//
//  Created by Guzel Gubaidullina on 01.04.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class FriendPhotosCollectionViewController: UICollectionViewController {
    var userId: Int = 1
    var photos = [VKPhoto]()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        requestData()
    }
    
    private func requestData() {
        VKService.instance.loadPhotos(userId: userId) { result in
            switch result {
            case .success(let photos):
                self.photos = photos
                self.collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendPhotosCollectionViewCell", for: indexPath) as! FriendPhotosCollectionViewCell
        
        let photo = photos[indexPath.row]
        let photoUrl = URL(string: photo.url)!
        cell.friendPhotoImageView.af.setImage(withURL: photoUrl)

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
        if segue.identifier == "segueShowFullSizePhotos" {
            guard let viewController = segue.destination as? FullSizePhotosController,
                let photosImageName = user?.photosImageName,
                let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else {
                    return
            }
            
            viewController.photosNames = photosImageName
            viewController.selectedPhotoIndex = selectedIndexPath.row
            
//            var user: User? = nil
//            if filteredUsers.isEmpty {
//                let sectionTitle = sectionTitles[selectedIndexPath.section]
//                user = userGroups[sectionTitle]?[selectedIndexPath.row]
//            } else {
//                user = filteredUsers[selectedIndexPath.row]
//            }
//            viewController.user = user!
        }
        */
    }
}

extension FriendPhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width / 3) - 1,
                      height: (view.frame.size.width / 3) - 1)
    }
}
