//
//  Session.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 01.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation

class Session {
    static let instance = Session()
    
    var accessToken: String = ""
    var userId: Int = 0
    
    private init() {}
}

