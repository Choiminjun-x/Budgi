//
//  CalendarDateGenerator.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import Foundation

struct CalendarDay {
    let date: Date
    let isInCurrentMonth: Bool
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

protocol DateGenerator {
    // generate - Network, DB 요청 X
    func generateMonthDays(for date: Date) -> [CalendarDay]
}

final class CalendarDateGenerator: DateGenerator {
    
    private let calendar = Calendar.current
   
    func generateMonthDays(for date: Date) -> [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        var days: [CalendarDay] = []
        
        // 이전 달의 일부 날짜 채우기
        let previousDaysCount = (firstWeekday - calendar.firstWeekday + 7) % 7
        for i in stride(from: previousDaysCount, to: 0, by: -1) {
            if let date = calendar.date(byAdding: .day, value: -i, to: monthInterval.start) {
                days.append(CalendarDay(date: date, isInCurrentMonth: false))
            }
        }
        
        // 이번 달 날짜 채우기
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(CalendarDay(date: currentDate, isInCurrentMonth: true))
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        let rowCount = Int(ceil(Double(days.count) / 7.0))
        let targetCount: Int?
        if rowCount <= 4 {
            targetCount = nil
        } else if rowCount <= 5 {
            targetCount = 35
        } else {
            targetCount = 42
        }
        
        // 다음 달의 일부 날짜 채우기 (5행/6행 맞추기 위해, 4행이면 채우지 않음)
        if let targetCount {
            while days.count < targetCount {
                days.append(CalendarDay(date: currentDate, isInCurrentMonth: false))
                if let next = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = next
                } else {
                    break
                }
            }
        }
        
        return days
    }
}
