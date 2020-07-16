//
//  FriendPhotosNode.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 16.07.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import AsyncDisplayKit

class FriendPhotosNode: ASCellNode {
    let imageNode = ASNetworkImageNode()
    
    required init(with photo: VKPhoto) {
        super.init()
        imageNode.url = URL(string: photo.url)!
        self.addSubnode(self.imageNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var imageRatio: CGFloat = 0.5
        if imageNode.image != nil {
          imageRatio = (imageNode.image?.size.height)! / (imageNode.image?.size.width)!
        }
        
        let imagePlace = ASRatioLayoutSpec(ratio: imageRatio, child: imageNode)
        
        let stackLayout = ASStackLayoutSpec.horizontal()
        stackLayout.justifyContent = .start
        stackLayout.alignItems = .start
        stackLayout.style.flexShrink = 1.0
        stackLayout.children = [imagePlace]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets.zero, child: stackLayout)
    }
}
