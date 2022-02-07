//
//  SunData.swift
//  sunRiseSet
//
//  Created by David Chester on 1/29/22.
//

import Foundation

struct SunData: Decodable {
    let results: Results
}

struct Results: Codable {
    let sunrise: String
    let sunset: String
    let day_length: Int
}
