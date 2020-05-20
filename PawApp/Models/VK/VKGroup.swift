//
//  VKGroup.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 17.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation

struct VKGroupRequestResponse: Codable {
    let response: VKGroupResponse
}

struct VKGroupResponse: Codable {
    let items: [VKGroup]
}

struct VKGroup: Codable {
    var groupId: Int
    var groupName: String
    var avatarUrl: String
}

extension VKGroup: CustomStringConvertible {
    var description: String {
        return String(format: "%@ (%ld)", groupName, groupId)
    }
}

extension VKGroup {
    enum CodingKeys: String, CodingKey {
        case groupId = "id"
        case groupName = "name"
        case avatarUrl = "photo_200"
    }
}
