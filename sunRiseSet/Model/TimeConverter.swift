//
//  TimeConverter.swift
//  sunRiseSet
//
//  Created by David Chester on 2/1/22.
//

import Foundation

struct TimeConverter {

    // TODO: We may not need this?
    func convertToUsersTimeZone(time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "H:mm"
        if let date = formatter.date(from: time) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "h:mm a"
            return displayFormatter.string(from: date)
        } else {
            return "\(time)"
        }

    }

    // TODO: Convert from the string we're given to hours and minutes
    func convertDayLengthToHours(dayLength: String) -> String? {
        var dayLengthFormatted = dayLength.replacingOccurrences(of: ":", with: " hours ")
        dayLengthFormatted.append(contentsOf: " minutes")

        return dayLengthFormatted
    }
    
}
