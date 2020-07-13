//
//  NewsTableViewCell.swift
//  vk_GuzelGubaydullina
//
//  Created by Guzel Gubaidullina on 12.04.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import UIKit

protocol NewsTableViewCellDelegate: AnyObject {
    func newsTableViewCell(_ cell: NewsTableViewCell,
                           needReload: Bool)
}

class NewsTableViewCell: UITableViewCell {
    weak var delegate: NewsTableViewCellDelegate?
    
    private var showFull: Bool = false {
        didSet {
            guard let newsTextLabelHeightConstraint = newsTextLabelHeightConstraint else {
                return
            }
            newsTextLabelHeightConstraint.isActive = !showFull
        }
    }
    var news: VKNewsItem?
    
    @IBOutlet weak var authorImageView: RoundedImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newsTextLabel: UILabel!
    @IBOutlet weak var newsTextLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showMoreButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let showMoreButtonTitle = showFull ? "Меньше..." : "Больше..."
        showMoreButton.setTitle(showMoreButtonTitle,
                                for: .normal)
        authorImageView.image = nil
        authorLabel.text = nil
        newsTextLabel.text = nil
    }
    
    func configure(with news: VKNewsItem) {
        self.news = news
        authorLabel.text = news.authorName
        newsTextLabel.text = news.text
    }
    
    @IBAction func actionShowFullButtonTapped(_ sender: UIButton) {
        showFull = !showFull
        delegate?.newsTableViewCell(self,
                                    needReload: true)
    }
}

