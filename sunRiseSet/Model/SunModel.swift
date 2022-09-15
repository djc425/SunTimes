//
//  SunModel.swift
//  sunRiseSet
//
//  Created by David Chester on 1/30/22.
//

import Foundation
import UIKit

struct CellModel {
    var sun: [SunModel]
    var moon: [MoonModel]
}

struct SunModel {
    var time: String
    var dayLength: String
    var image: UIImage
}

struct MoonModel {
    var time : String
    var dayLength: String
    var image: UIImage
}

