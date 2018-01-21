//
//  DateExtension.swift
//  KG-Interview-Test
//
//  Created by Dave Gumba on 2018-01-19.
//  Copyright © 2018 Dave's Organization. All rights reserved.
//

import Foundation

extension Date {
    
    var previousDay: Date {
        let newDate = Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
        return newDate
    }
    var nextDay: Date {
        let newDate = Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
        return newDate
    }
}
