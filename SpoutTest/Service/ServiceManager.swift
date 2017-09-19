//
//  ServiceManager.swift
//  SpoutTest
//
//  Created by Asquare on 9/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum JsonResult {
    case success([VideoModel])
    case failure(String)
}

enum DataResult {
    case success(Data)
    case failure(String)
}

let kSavedVideos = "SavedVideosKey"

class ServiceManager {

    static let shared = ServiceManager()
    private init() { }
    
    func getData(from url: String, callback: @escaping ((JsonResult)->Void)) {
        Alamofire.request(url).responseJSON { (response) in
            callback(self.handleJsonDataResponse(response))
        }
    }
    
    func downloadVideo(from url: String,
                       downloadingProgress: ((Progress)->Void)? = nil,
                       completion: @escaping ((DataResult)->Void)) -> DataRequest {
        let request = Alamofire.request(url)
        request.downloadProgress { (progress) in
            downloadingProgress?(progress)
        }
        
        request.responseData { (responseData) in
            completion(self.handleDataResponse(responseData))
        }

        return request
    }
    
    private func handleJsonDataResponse(_ response: DataResponse<Any>) -> JsonResult {
        guard let data = response.result.value,
            let jsonArray = JSON(data).array else {
            return .failure("Cannot load data")
        }

        var arrayModel = [VideoModel]()
        for model in jsonArray {
            arrayModel.safeAppend(VideoModel(json: model))
        }
        
        return .success(arrayModel)
    }
    
    private func handleDataResponse(_ response: DataResponse<Data>) -> DataResult {
        guard let data = response.result.value else {
                return .failure("Cannot download video")
        }
        return .success(data)
    }
}
