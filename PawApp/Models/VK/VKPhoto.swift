//
//  VKPhoto.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 17.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation

struct VKPhotoRequestResponse: Codable {
    let response: VKPhotoResponse
}

struct VKPhotoResponse: Codable {
    let items: [VKPhoto]
}

struct VKPhoto: Codable {
    var photoId: Int
    var url: String
}

extension VKPhoto: CustomStringConvertible {
    var description: String {
        return String(format: "%ld (%@)", photoId, url)
    }
}

extension VKPhoto {
    enum CodingKeys: String, CodingKey {
        case photoId = "id"
        case url = "photo_604"
    }
}
