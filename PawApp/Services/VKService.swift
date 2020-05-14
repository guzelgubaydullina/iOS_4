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
    private let accessToken = Session.instance.accessToken
    private lazy var commonParameters = [
        "access_token": accessToken,
        "v": apiVersion
    ]
    
    private init() {}
    
    func loadFriends(handler: @escaping (Result<[String: Any]?, Error>) -> Void) {
        let apiMethod = "friends.get"
        let apiEndpoint = baseUrl + apiMethod
        AF.request(apiEndpoint,
                   method: .get,
                   parameters: commonParameters)
            .validate()
            .responseJSON { response in
            switch response.result {
            case .success(let result):
                if let result = result as? [String: Any] {
                    handler(.success(result))
                } else {
                    handler(.failure(VKAPIError.error("Data error")))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func loadPhotos(handler: @escaping (Result<[String: Any]?, Error>) -> Void) {
        let apiMethod = "photos.getAll"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "extended": "1",
            "count": "200"
        ]

        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseJSON { response in
            switch response.result {
            case .success(let result):
                if let result = result as? [String: Any] {
                    handler(.success(result))
                } else {
                    handler(.failure(VKAPIError.error("Data error")))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func loadGroups(handler: @escaping (Result<[String: Any]?, Error>) -> Void) {
        let apiMethod = "groups.get"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "extended": "1",
            "count": "1000"
        ]

        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseJSON { response in
            switch response.result {
            case .success(let result):
                if let result = result as? [String: Any] {
                    handler(.success(result))
                } else {
                    handler(.failure(VKAPIError.error("Data error")))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func searchGroups(searchQuery: String,
                      handler: @escaping (Result<[String: Any]?, Error>) -> Void) {
        let apiMethod = "groups.search"
        let apiEndpoint = baseUrl + apiMethod
        let requestParameters = commonParameters + [
            "q": searchQuery
        ]

        AF.request(apiEndpoint,
                   method: .get,
                   parameters: requestParameters)
            .validate()
            .responseJSON { response in
            switch response.result {
            case .success(let result):
                if let result = result as? [String: Any] {
                    handler(.success(result))
                } else {
                    handler(.failure(VKAPIError.error("Data error")))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
