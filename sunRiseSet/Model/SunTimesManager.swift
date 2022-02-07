//
//  SunTimesManager.swift
//  sunRiseSet
//
//  Created by David Chester on 1/29/22.
//

import Foundation
//import CoreText
import UIKit

protocol SunTimesManagerDelegate {
    func didUpdateTimes(sunManager: SunTimesManager, sunTimes: [SunModel])
    
    func didFailWithError(error: Error)
}

struct SunTimesManager {
    let sunTimeURL = "https://api.sunrise-sunset.org/json?"
    
    var delegate: SunTimesManagerDelegate?
    
    var sunTimesConverter = TimeConverter()
    
  var sunImages = SunImages()
    
    
    func sunTimesURLGenerator(lat: Double, long: Double, date: String){
        let urlString = "\(sunTimeURL)&lat=\(lat)&lng=\(long)&date=\(date)&formatted=0"
        print(urlString)
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
//print(allSunData)
                    }
                    
                }
            }
            
            task.resume()
        }
    }
   
    
    func parseJson(sunTimesData: Data) -> [SunModel]? {
        let decoder = JSONDecoder()
        var allSunData = [SunModel]()
        do {
            let decoder = try decoder.decode(SunData.self, from: sunTimesData)
            
            guard let sunRiseTime = sunTimesConverter.convertToUsersTimeZone(time: decoder.results.sunrise) else {
                fatalError("the sunrise time don't work")
            }
            guard let sunSetTime = sunTimesConverter.convertToUsersTimeZone(time: decoder.results.sunset) else {
                fatalError("the sunset time don't work")
            }
            guard let dayLength = sunTimesConverter.convertDayLengthToHours(dayLength: decoder.results.day_length) else {
                fatalError("could not convert day length")
            }
            

        
            let sunRiseData = SunModel(sunTime: sunRiseTime, dayLength: dayLength, sunImage:
                                        sunImages.sunRiseImage())
            let sunSetData = SunModel(sunTime: sunSetTime, dayLength: dayLength, sunImage: sunImages.sunSetImage())
            
            allSunData.append(sunRiseData)
            allSunData.append(sunSetData)
            
           // print(allSunData)
            
            return allSunData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

struct SunImages{
    
    func sunRiseImage() -> UIImage {
        let config = UIImage.SymbolConfiguration(paletteColors: [.orange, .yellow])

        guard let sunRiseImage = UIImage(systemName: "sunrise.fill", withConfiguration: config) else {
            fatalError("unable to get sunrise image")
        }
        return sunRiseImage
    }
    
    func sunSetImage() -> UIImage {
        let config = UIImage.SymbolConfiguration(paletteColors: [.yellow, .orange])

        guard let sunSetImage = UIImage(systemName: "sunset.fill", withConfiguration: config) else {
            fatalError("unable to get sunrise image")
        }
        return sunSetImage
    }
   
}
