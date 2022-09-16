//
//  SunTimesManager.swift
//  sunRiseSet
//
//  Created by David Chester on 1/29/22.
//

import Foundation
import UIKit

protocol SunTimesManagerDelegate {
    // use the below delegate method to pass our CellModel from the getSunTimes method over to the MainVC
    func didUpdateTimes(sunTimesManager: SunTimesManager, sunTimesCellModel: CellModel)
    
    func didFailWithError(error: SunTimesError)
}

//MARK: SunTimesErrors
enum SunTimesError: String, Error {
    case invalidURL = "URL is invaild, unable to make API Call"
    case unableToComplere = "Unable to complete request, please check internet connection"
    case invalidData = "Data returned is invalid"

}

struct SunTimesManager {

    let sunTimeURL = "https://api.ipgeolocation.io/astronomy?apiKey=\(APIKey.shared.apiKey)"
    var delegate: SunTimesManagerDelegate?
    var sunTimesConverter = TimeConverter()
    var sunImages = SunImages()

    func sunTimesURLGenerator(lat: Double, long: Double){
        let urlString = "\(sunTimeURL)&lat=\(lat)&long=\(long)"
        print("url generated is \(urlString)")

        // calls the API and then the delegate methods
        resultGetSunTimes(with: urlString) { result in

            switch result {
            case .success(let sunData):
                let sunCellModel = convertDataToModel(from: sunData)

                DispatchQueue.main.async {
                    delegate?.didUpdateTimes(sunTimesManager: self, sunTimesCellModel: sunCellModel)

                }

            case .failure(let error):
                DispatchQueue.main.async {
                    delegate?.didFailWithError(error: error)
                }

            }
        }
    }

    // MARK: Result which will pull our suntimes down
    func resultGetSunTimes(with url: String, completion: @escaping (Result<SunData, SunTimesError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        let session = URLSession.shared

        let task = session.dataTask(with: url) { data, _, error in

            if let error = error {
                completion(.failure(.unableToComplere))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let allSunData = try decoder.decode(SunData.self, from: data)
                completion(.success(allSunData))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }

    // MARK: Convert our SunData from the API CAll into a CellModel to populate the cell
    private func convertDataToModel(from sunData: SunData) -> CellModel {
        var allSunData = [SunModel]()
        var allMoonData = [MoonModel]()

        let sunRiseTime = sunTimesConverter.convertToUsersTimeZone(time: sunData.sunrise)
        let sunSetTime = sunTimesConverter.convertToUsersTimeZone(time: sunData.sunset)
        let moonRiseTime = sunTimesConverter.convertToUsersTimeZone(time: sunData.moonrise)
        let moonSetTime =  sunTimesConverter.convertToUsersTimeZone(time: sunData.moonset)

        let dayLength = sunTimesConverter.convertDayLengthToHours(dayLength: sunData.dayLength) ?? "\(sunData.dayLength)"

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
    }

}

// MARK: Sun and Moon SF Symbols
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
