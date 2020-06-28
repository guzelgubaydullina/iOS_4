//
//  NewsTableViewCell.swift
//  vk_GuzelGubaydullina
//
//  Created by Guzel Gubaidullina on 12.04.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class NewsTableViewCell: UITableViewCell {
    var news: VKNewsItem?
    
    @IBOutlet weak var authorImageView: RoundedImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newsTextLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        authorImageView.image = nil
        authorLabel.text = nil
        newsTextLabel.text = nil
    }
    
    func configure(with news: VKNewsItem) {
        self.news = news
        
        let avatarUrl = URL(string: news.authorAvatarUrl)!
        authorImageView.imageView.af.setImage(withURL: avatarUrl)
        authorImageView.setNeedsDisplay()
        
        authorLabel.text = news.authorName
        
        newsTextLabel.text = news.text
    }
}

