//
//  VideoModel.swift
//  SpoutTest
//
//  Created by Asquare on 9/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import SwiftyJSON

class VideoModel {
    var id: Int?
    var name: String?
    var backgroundImage: String?
    var streamUrl: String?
    var offlineUrl: String?
    
    init(json: JSON) {
        id              = json["id"].int
        name            = json["name"].string
        backgroundImage = json["background_image_url"].string
        streamUrl       = json["stream_url"].string
        offlineUrl      = json["offline_url"].string
    }

}
