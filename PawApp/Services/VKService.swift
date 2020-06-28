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
    private static let groupsQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    static let instance = VKService()
    
    private let baseUrl = "https://api.vk.com/method/"
    private let apiVersion = "5.111"
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
        let requestOperation = BlockOperation {
            let apiMethod = "groups.get"
            let apiEndpoint = self.baseUrl + apiMethod
            let requestParameters = self.commonParameters + [
                "extended": "1"
            ]
            
            let responseOperation = BlockOperation {
                AF.request(apiEndpoint,
                           method: .get,
                           parameters: requestParameters)
                    .validate()
                    .responseData(completionHandler: { responseData in
                        let parsingOperation = BlockOperation {
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
                        }
                        VKService.groupsQueue.addOperation(parsingOperation)
                    })
            }
            VKService.groupsQueue.addOperation(responseOperation)
        }
        VKService.groupsQueue.addOperation(requestOperation)
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
    
    func loadNews(handler: @escaping (Result<[VKNewsItem], Error>) -> Void) {
        let apiMethod = "newsfeed.get"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "filters": "post"
        ]
        
        DispatchQueue.global(qos: .background).async {
            AF.request(apiEndpoint,
                       method: .get,
                       parameters: requestParameters)
                .validate()
                .responseData(completionHandler: { responseData in
                    DispatchQueue.global(qos: .background).async {
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
                            handler(.success(items))
                        } catch {
                            handler(.failure(error))
                        }
                    }
                })
        }
    }
}
