//
//  VKService.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 13.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation
import Alamofire

class VKService {
    static let instance = VKService()
    
    private let baseUrl = "https://api.vk.com/method/"
    private let apiVersion = "5.103"
    private let accessToken = VKSession.instance.accessToken
    private lazy var commonParameters = [
        "access_token": accessToken,
        "v": apiVersion
    ]
    
    private init() {}
    
    func loadFriends(handler: @escaping (Result<[VKUser], Error>) -> Void) {
        let apiMethod = "friends.get"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "fields": "photo_200_orig, online"
        ]
        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseData(completionHandler: { responseData in
                guard let data = responseData.data else {
                    handler(.failure(VKAPIError.error("Data error")))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let requestResponse = try decoder.decode(VKUserRequestResponse.self,
                                                             from: data)
                    RealmService.instance.deleteObjects(VKUser.self)
                    RealmService.instance.saveObjects(requestResponse.response.items)
                    handler(.success(requestResponse.response.items))
                } catch {
                    handler(.failure(error))
                }
            })
    }
    
    func loadPhotos(userId: Int,
                    handler: @escaping (Result<[VKPhoto], Error>) -> Void) {
        let apiMethod = "photos.getAll"
        let apiEndpoint = baseUrl + apiMethod
        var requestParameters = commonParameters + [
            "owner_id": String(userId),
            "extended": "0",
            "photo_sizes": "0",
            "count": "30"
        ]
        requestParameters["v"] = "5.00"
        
        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseData(completionHandler: { responseData in
                guard let data = responseData.data else {
                    handler(.failure(VKAPIError.error("Data error")))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let requestResponse = try
                        decoder.decode(VKPhotoRequestResponse.self, from: data)
                    handler(.success(requestResponse.response.items))
                } catch {
                    handler(.failure(error))
                }
            })
    }
    
    func loadGroups(handler: @escaping (Result<[VKGroup], Error>) -> Void) {
        let apiMethod = "groups.get"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "extended": "1"
        ]
        
        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseData(completionHandler: { responseData in
                guard let data = responseData.data else {
                    handler(.failure(VKAPIError.error("Data error")))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let requestResponse = try
                        decoder.decode(VKGroupRequestResponse.self, from: data)
                    RealmService.instance.deleteObjects(VKGroup.self)
                    RealmService.instance.saveObjects(requestResponse.response.items)
                    handler(.success(requestResponse.response.items))
                } catch {
                    handler(.failure(error))
                }
            })
    }
    
    func searchGroups(searchQuery: String,
                      handler: @escaping (Result<[VKGroup], Error>) -> Void) {
        let apiMethod = "groups.search"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "q": searchQuery
        ]
        
        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseData(completionHandler: { responseData in
                guard let data = responseData.data else {
                    handler(.failure(VKAPIError.error("Data error")))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let requestResponse = try
                        decoder.decode(VKGroupRequestResponse.self, from: data)
                    handler(.success(requestResponse.response.items))
                } catch {
                    handler(.failure(error))
                }
            })
    }
}
