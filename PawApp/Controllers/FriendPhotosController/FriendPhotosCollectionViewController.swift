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
import AsyncDisplayKit

class FriendPhotosCollectionViewController: ASDKViewController<ASCollectionNode> {
    var userId: Int = 1
    var photos = [VKPhoto]()
    
    let collectionNode: ASCollectionNode
    
    override init() {
        collectionNode = ASCollectionNode(frame: .zero,
                                          collectionViewLayout: UICollectionViewFlowLayout())
        super.init(node: collectionNode)
        collectionNode.backgroundColor = .systemBackground
        collectionNode.dataSource = self
        collectionNode.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData()
    }
    
    private func requestData() {
        VKService.instance.loadPhotos(userId: userId) { [weak self] result in
            switch result {
            case .success(let photos):
                guard let self = self else { return }
                self.photos = photos
                self.collectionNode.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension FriendPhotosCollectionViewController: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode,
                        constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
        let size = CGSize(width: (view.frame.size.width / 3) - 1,
                          height: (view.frame.size.width / 3) - 1)
        let range = ASSizeRange(min: size,
                                max: size)
        return range
    }
}

extension FriendPhotosCollectionViewController: ASCollectionDataSource {
    func collectionNode(_ collectionNode: ASCollectionNode,
                        numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode,
                        nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let photo = photos[indexPath.row]
        return {
            return FriendPhotosNode(with: photo)
        }
    }
}
