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

    let sunTimeURL = "https://api.ipgeolocation.io/astronomy?apiKey=\(APIKey.shared.apiKey)"
    
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
                    if let allSunData = self.decodeSunTimeData(sunTimesData: safeData) {
                       self.delegate?.didUpdateTimes(sunManager: self, sunTimes: allSunData)
                    }
                }
            }
            task.resume()
        }
    }
   
    
    func decodeSunTimeData(sunTimesData: Data) -> CellModel? {
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

            let sunRiseData = SunModel(time: sunRiseTime, image: sunImages.sunRiseImage())
            let sunSetData = SunModel(time: sunSetTime,image: sunImages.sunSetImage())
            let moonRiseData = MoonModel(time: moonRiseTime, image: sunImages.moonRiseImage())
            let moonSetData = MoonModel(time: moonSetTime, image: sunImages.moonSetImage())

            allSunData.append(sunRiseData)
            allSunData.append(sunSetData)
            allMoonData.append(moonRiseData)
            allMoonData.append(moonSetData)

            let allData = CellModel(sun: allSunData, moon: allMoonData, dayLength: dayLength)

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

            guard let sunRiseImage = UIImage(systemName: K.shared.sunRiseImage, withConfiguration: config) else {
                fatalError("unable to get sunrise image")
            }
            return sunRiseImage
        } else {
            guard let sunRiseImage = UIImage(systemName: K.shared.sunRiseImage) else {
                fatalError("unable to get sunrise image")
            }
            return sunRiseImage
        }
        
    }
    
    func sunSetImage() -> UIImage {
        
        if #available(iOS 15, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.yellow, .orange])

            guard let sunSetImage = UIImage(systemName: K.shared.sunSetImage, withConfiguration: config) else {
                fatalError("unable to get sunrise image")
            }
            return sunSetImage
        } else {
            guard let sunSetImage = UIImage(systemName: K.shared.sunSetImage) else {
                fatalError("unable tog et sunset image")
            }
            return sunSetImage
        }
    }

    func moonRiseImage() -> UIImage {
        if #available(iOS 15, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.blue, .purple])

            guard let sunSetImage = UIImage(systemName: K.shared.moonRiseImage, withConfiguration: config) else {
                fatalError("unable to get sunrise image")
            }
            return sunSetImage
        } else {
            guard let sunSetImage = UIImage(systemName: K.shared.moonRiseImage) else {
                fatalError("unable to get sunset image")
            }
            return sunSetImage
        }
    }

    func moonSetImage() -> UIImage {
        if #available(iOS 15, *) {
            let config = UIImage.SymbolConfiguration(paletteColors: [.purple, .blue])

            guard let sunSetImage = UIImage(systemName: K.shared.moonSetImage, withConfiguration: config) else {
                fatalError("unable to get sunrise image")
            }
            return sunSetImage
        } else {
            guard let sunSetImage = UIImage(systemName: K.shared.moonSetImage) else {
                fatalError("unable tog et sunset image")
            }
            return sunSetImage
        }
    }
    
   
}
