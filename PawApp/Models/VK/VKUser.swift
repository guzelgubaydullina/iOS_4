//
//  VKUser.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 17.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation

struct VKUserRequestResponse: Codable {
    let response: VKUserResponse
}

struct VKUserResponse: Codable {
    let items: [VKUser]
}

struct VKUser: Codable {
    var userId: Int
    var firstName: String
    var lastName: String
    var avatarUrl: String
    var isOnline: Int
}

extension VKUser: CustomStringConvertible {
    var description: String {
        return String(format: "%@ %@ (%ld)", firstName, lastName, userId)
    }
}

extension VKUser {
    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarUrl = "photo_200_orig"
        case isOnline = "online"
    }
}

