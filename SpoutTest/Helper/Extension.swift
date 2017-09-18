//
//  Extension.swift
//  SpoutTest
//
//  Created by Asquare on 9/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit

extension Array {
    mutating func safeAppend(_ element: Element?) {
        if let element = element {
            self.append(element)
        }
    }
}
