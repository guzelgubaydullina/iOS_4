//
//  VKSession.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 01.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation

class VKSession {
    static let instance = VKSession()
    
    var accessToken: String = ""
    var userId: String = ""
    
    private init() {}
    
    func toDictionary() -> [String: Any] {
        return [
            "accessToken": accessToken,
            "userId": userId
        ]
    }
}

