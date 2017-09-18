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

enum DataResult {
    case success([VideoModel])
    case failure(String)
}

class ServiceManager {

    static let shared = ServiceManager()
    private init() { }
    
    func getData(from url: String, callback: @escaping ((DataResult)->Void)) {
        Alamofire.request(url).responseJSON { (response) in
            callback(self.handleDataResponse(response))
        }
    }
    
    private func handleDataResponse(_ response: DataResponse<Any>) -> DataResult {
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
}
