//
//  SunTimesManager.swift
//  sunRiseSet
//
//  Created by David Chester on 1/29/22.
//

import Foundation
import UIKit

protocol SunTimesManagerDelegate {
    func didUpdateTimes(sunManager: SunTimesManager, sunTimes: CellModel)
    
    func didFailWithError(error: Error)
}

struct SunTimesManager {

    let sunTimeURL = "https://api.ipgeolocation.io/astronomy?apiKey=\(K.shared.apiKey)"
    
    var delegate: SunTimesManagerDelegate?
    
    var sunTimesConverter = TimeConverter()
    
    var sunImages = SunImages()

    func sunTimesURLGenerator(lat: Double, long: Double){
        let urlString = "\(sunTimeURL)&lat=\(lat)&long=\(long)"
        print("url generated is \(urlString)")
        getSunTimes(with: urlString)
    }
    
    func getSunTimes(with url: String){
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)

            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)

                }
                if let safeData = data {
                    if let allSunData = self.parseJson(sunTimesData: safeData) {
                       self.delegate?.didUpdateTimes(sunManager: self, sunTimes: allSunData)
                    }
                }
            }
            task.resume()
        }
    }
   
    
    func parseJson(sunTimesData: Data) -> CellModel? {
        let decoder = JSONDecoder()
        var allSunData = [SunModel]()
        var allMoonData = [MoonModel]()
        do {
            let decoder = try decoder.decode(SunData.self, from: sunTimesData)
            
            let sunRiseTime = sunTimesConverter.convertToUsersTimeZone(time: decoder.sunrise)
            let sunSetTime = sunTimesConverter.convertToUsersTimeZone(time: decoder.sunset)
            let moonRiseTime = sunTimesConverter.convertToUsersTimeZone(time: decoder.moonrise)
            let moonSetTime =  sunTimesConverter.convertToUsersTimeZone(time: decoder.moonset)

            let dayLength = sunTimesConverter.convertDayLengthToHours(dayLength: decoder.day_length) ?? "\(decoder.day_length)"

            let sunRiseData = SunModel(time: sunRiseTime, dayLength: dayLength, image: sunImages.sunRiseImage())
            let sunSetData = SunModel(time: sunSetTime, dayLength: dayLength, image: sunImages.sunSetImage())
            let moonRiseData = MoonModel(time: moonRiseTime, dayLength: dayLength, image: sunImages.moonRiseImage())
            let moonSetData = MoonModel(time: moonSetTime, dayLength: dayLength, image: sunImages.moonSetImage())

            allSunData.append(sunRiseData)
            allSunData.append(sunSetData)
            allMoonData.append(moonRiseData)
            allMoonData.append(moonSetData)

            let allData = CellModel(sun: allSunData, moon: allMoonData)

            return allData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

struct SunImages {
    
    func sunRiseImage() -> UIImage {
        if #available(iOS 15, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.orange, .yellow])

            guard let sunRiseImage = UIImage(systemName: "sunrise.fill", withConfiguration: config) else {
                fatalError("unable to get sunrise image")
            }
            return sunRiseImage
        } else {
            guard let sunRiseImage = UIImage(systemName: "sunrise.fill") else {
                fatalError("unable to get sunrise image")
            }
            return sunRiseImage
        }
        
    }
    
    func sunSetImage() -> UIImage {
        
        if #available(iOS 15, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.yellow, .orange])

            guard let sunSetImage = UIImage(systemName: "sunset.fill", withConfiguration: config) else {
                fatalError("unable to get sunrise image")
            }
            return sunSetImage
        } else {
            guard let sunSetImage = UIImage(systemName: "sunset.fill") else {
                fatalError("unable tog et sunset image")
            }
            return sunSetImage
        }
    }

    func moonRiseImage() -> UIImage {
        if #available(iOS 15, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.blue, .purple])

            guard let sunSetImage = UIImage(systemName: "moon.stars.fill", withConfiguration: config) else {
                fatalError("unable to get sunrise image")
            }
            return sunSetImage
        } else {
            guard let sunSetImage = UIImage(systemName: "moon.stars.fill") else {
                fatalError("unable to get sunset image")
            }
            return sunSetImage
        }
    }

    func moonSetImage() -> UIImage {
        if #available(iOS 15, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.purple, .blue])

            guard let sunSetImage = UIImage(systemName: "moon.zzz.fill", withConfiguration: config) else {
                fatalError("unable to get sunrise image")
            }
            return sunSetImage
        } else {
            guard let sunSetImage = UIImage(systemName: "moon.zzz.fill") else {
                fatalError("unable tog et sunset image")
            }
            return sunSetImage
        }
    }
    
   
}
