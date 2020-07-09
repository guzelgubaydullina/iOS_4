//
//  VKService.swift
//  PawApp
//
//  Created by Guzel Gubaidullina on 13.05.2020.
//  Copyright © 2020 Guzel Gubaidullina. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class VKService {
    static let instance = VKService()
    
    private let baseUrl = "https://api.vk.com/method/"
    private let apiVersion = "5.111"
    private let accessToken = VKSession.instance.accessToken
    private lazy var commonParameters = [
        "access_token": accessToken,
        "v": apiVersion
    ]
    
    private let networkingQueue = DispatchQueue(label: "com.gubaydullina.vk-GuzelGubaydullina.networkingQueue",
                                                qos: .background,
                                                attributes: .concurrent)
    
    private init() {}
    
    func loadFriends(handler: @escaping (Swift.Result<[VKUser], Error>) -> Void) {
        let apiMethod = "friends.get"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "fields": "photo_200_orig, online"
        ]
        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseData(queue: networkingQueue,
                          completionHandler: { responseData in
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
                    DispatchQueue.main.async {
                        handler(.success(requestResponse.response.items))
                    }
                } catch {
                    DispatchQueue.main.async {
                        handler(.failure(error))
                    }
                }
            })
    }
    
    func loadPhotos(userId: Int,
                    handler: @escaping (Swift.Result<[VKPhoto], Error>) -> Void) {
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
            .responseData(queue: networkingQueue,
                          completionHandler: { responseData in
                guard let data = responseData.data else {
                    handler(.failure(VKAPIError.error("Data error")))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let requestResponse = try
                        decoder.decode(VKPhotoRequestResponse.self, from: data)
                    DispatchQueue.main.async {
                        handler(.success(requestResponse.response.items))
                    }
                } catch {
                    DispatchQueue.main.async {
                        handler(.failure(error))
                    }
                }
            })
    }
    
    func loadGroups() -> Promise<[VKGroup]> {
        let apiMethod = "groups.get"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "extended": "1"
        ]
        
        let promise = Promise<[VKGroup]> { resolver in
            AF.request(apiEndpoint,
                       method: .get,
                       parameters: requestParameters)
                .validate()
                .responseData(queue: networkingQueue,
                              completionHandler: { responseData in
                    guard let data = responseData.data else {
                        resolver.reject(VKAPIError.error("Data error"))
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let requestResponse = try decoder.decode(VKGroupRequestResponse.self, from: data)
                        resolver.fulfill(requestResponse.response.items)
                    } catch {
                        resolver.reject(error)
                    }
                })
        }
        return promise
    }
    
    func searchGroups(searchQuery: String,
                      handler: @escaping (Swift.Result<[VKGroup], Error>) -> Void) {
        let apiMethod = "groups.search"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "q": searchQuery
        ]
        
        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseData(queue: networkingQueue,
                          completionHandler: { responseData in
                guard let data = responseData.data else {
                    handler(.failure(VKAPIError.error("Data error")))
                    return
                }
                let decoder = JSONDecoder()
                do {
                    let requestResponse = try
                        decoder.decode(VKGroupRequestResponse.self, from: data)
                    DispatchQueue.main.async {
                        handler(.success(requestResponse.response.items))
                    }
                } catch {
                    DispatchQueue.main.async {
                        handler(.failure(error))
                    }
                }
            })
    }
    
    func loadNews(handler: @escaping (Swift.Result<[VKNewsItem], Error>) -> Void) {
        let apiMethod = "newsfeed.get"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "filters": "post"
        ]
        
        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseData(queue: networkingQueue,
                          completionHandler: { responseData in
                            guard let data = responseData.data else {
                                handler(.failure(VKAPIError.error("Data error")))
                                return
                            }
                            let decoder = JSONDecoder()
                            do {
                                let requestResponse = try
                                    decoder.decode(VKNewsRequestResponse.self, from: data)
                                let response = requestResponse.response
                                var items = response.items
                                for (index, item) in items.enumerated() {
                                    var item = item
                                    if item.sourceId < 0 {
                                        item.sourceGroup = response.source(groupId: item.sourceId)
                                    } else {
                                        item.sourceProfile = response.source(userId: item.sourceId)
                                    }
                                    items[index] = item
                                }
                                DispatchQueue.main.async {
                                    handler(.success(items))
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    handler(.failure(error))
                                }
                            }
            })
    }
}
