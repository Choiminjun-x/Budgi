//
//  CalendarDateGenerator.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import Foundation

protocol DateGenerator {
    // generate - Network, DB 요청 X
    func generateMonthDays(for date: Date) -> [CalendarDay]
}

final class CalendarDateGenerator: DateGenerator {
    
    private let calendar = Calendar.current
    
    func generateMonthDays(for date: Date) -> [CalendarDay] {
        /// 해당 날짜(date)의 월 전체 범위 (1일~말일)를 구함
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        var days: [CalendarDay] = []
        
        /// 이전 달 날짜 채우기 (월 시작 요일에 맞추기 위해 앞쪽 공백 채움)
        let previousDaysCount = (firstWeekday - calendar.firstWeekday + 7) % 7
        for i in stride(from: previousDaysCount, to: 0, by: -1) {
            if let date = calendar.date(byAdding: .day, value: -i, to: monthInterval.start) {
                days.append(CalendarDay(date: date, isInCurrentMonth: false))
            }
        }
        
        /// 이번 달 날짜 채우기
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(CalendarDay(date: currentDate, isInCurrentMonth: true))
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        /// 행 수 계산: 1주 = 7일 → 총 날짜 수에 따라 4~6줄 중 결정
        let rowCount = Int(ceil(Double(days.count) / 7.0))
        
        /// 4행은 그대로, 그 이상은 주 * 7
        let targetCount: Int?
        if rowCount <= 4 {
            targetCount = nil // 4줄이면 padding 불필요
        } else {
            targetCount = rowCount * 7
        }
        
        /// 다음 달의 일부 날짜 채우기 (5행/6행 맞추기 위해, 4행이면 채우지 않음)
        if let targetCount {
            while days.count < targetCount {
                days.append(CalendarDay(date: currentDate, isInCurrentMonth: false))
                if let next = calendar.date(byAdding: .day, value: 1, to: currentDate) { // 날짜를 하루씩 증가시키며 순회
                    currentDate = next
                } else {
                    break
                }
            }
        }
        
        return days
    }
}
