//
//  VKPhoto.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 17.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation
import RealmSwift

struct VKPhotoRequestResponse: Codable {
    let response: VKPhotoResponse
}

struct VKPhotoResponse: Codable {
    let items: [VKPhoto]
}

class VKPhoto: Object, Codable {
    override var description: String {
        return String(format: "%ld (%@)", photoId, url)
    }
    
    @objc dynamic var photoId: Int
    @objc dynamic var url: String
}

extension VKPhoto {
    enum CodingKeys: String, CodingKey {
        case photoId = "id"
        case url = "photo_604"
    }
}
