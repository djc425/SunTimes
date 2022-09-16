//
//  SunData.swift
//  sunRiseSet
//
//  Created by David Chester on 1/29/22.
//

import Foundation

struct SunData: Decodable {
    let date: String
    let sunrise: String
    let sunset: String
    let dayLength: String
    let moonrise: String
    let moonset: String
}


