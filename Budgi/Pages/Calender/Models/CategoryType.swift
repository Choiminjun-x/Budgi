//
//  CategoryType.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 2/3/26.
//

import Foundation

enum CategoryType: String {
    /// 지출
    case 식비 = "식비"
    case 교통 = "교통"
    case 취미 = "취미"
    case 쇼핑 = "쇼핑"
    case 생활 = "생활"
    case 의료 = "의료"
    case 기타 = "기타"
    /// 수입
    case 급여 = "급여"
    case 보너스 = "보너스"
    case 용돈 = "용돈"
    case 미분류 = "미분류"
    
    static func getCategoryType(for id: String?) -> CategoryType {
        guard let id = id else { return .미분류 }
        switch id {
        case "food": return .식비
        case "transport": return .교통
        case "hobby": return .취미
        case "shopping": return .쇼핑
        case "life": return .생활
        case "health": return .의료
        case "etc_exp": return .기타
        case "salary": return .급여
        case "bonus": return .보너스
        case "gift": return .용돈
        case "etc_inc": return .기타
        case "uncat": return .미분류
        default: return .기타
        }
    }
}
