//
//  FirebaseService.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 04.06.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseService {
    static let instance = FirebaseService()
    
    private let databaseReference: DatabaseReference! = Database.database().reference()
    private var userId: String = {
        return Auth.auth().currentUser?.uid ?? ""
    }()
    
    private init() {}
    
    func setValue(_ parent: String,
                  _ value: [String: Any]) {
        databaseReference.child(parent).child(userId).setValue(value)
    }
}
