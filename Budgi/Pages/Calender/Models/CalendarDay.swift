//
//  CalendarDay.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 2/3/26.
//

import Foundation

struct CalendarDay {
    let date: Date
    let isInCurrentMonth: Bool
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
