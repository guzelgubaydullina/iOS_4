//
//  VKNews.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 24.06.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation

struct VKNewsRequestResponse: Codable {
    let response: VKNewsResponse
}

struct VKNewsResponse: Codable {
    let items: [VKNewsItem]
    let profiles: [VKUser]
    let groups: [VKGroup]
    let nextFrom: String
    
    func source(userId: Int) -> VKUser? {
        let filteredProfiles = profiles.filter { $0.userId == userId }
        return filteredProfiles.first
    }
    
    func source(groupId: Int) -> VKGroup? {
        let filteredGroups = groups.filter { $0.groupId == -1*groupId }
        return filteredGroups.first
    }
}

extension VKNewsResponse {
    enum CodingKeys: String, CodingKey {
        case items = "items"
        case profiles = "profiles"
        case groups = "groups"
        case nextFrom = "next_from"
    }
}


struct VKNewsItem: Codable {
    let text: String
    let sourceId: Int
    
    var authorName: String {
        if let profile = sourceProfile {
            return profile.fullName
        } else if let group = sourceGroup {
            return group.groupName
        } else {
            return ""
        }
    }
    var authorAvatarUrl: String {
        if let profile = sourceProfile {
            return profile.avatarUrl100 ?? ""
        } else if let group = sourceGroup {
            return group.avatarUrl
        } else {
            return ""
        }
    }
    
    var sourceProfile: VKUser?
    var sourceGroup: VKGroup?
}

extension VKNewsItem {
    enum CodingKeys: String, CodingKey {
        case text = "text"
        case sourceId = "source_id"
    }
}
