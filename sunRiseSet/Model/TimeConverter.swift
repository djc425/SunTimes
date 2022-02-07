//
//  TimeConverter.swift
//  sunRiseSet
//
//  Created by David Chester on 2/1/22.
//

import Foundation

struct TimeConverter {
    
    func convertToUsersTimeZone(time: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: time) {
            print(date)
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            print(displayFormatter.string(from: date))
            return displayFormatter.string(from: date)
        } else {
            print("nodate")
        }
        return nil
    }
    
    func convertDayLengthToHours(dayLength: Int) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .short
        print(formatter.string(from: TimeInterval(dayLength))!)
        let dayLengthFormatted = formatter.string(from: TimeInterval(dayLength))!
        return dayLengthFormatted
    }
    
}
