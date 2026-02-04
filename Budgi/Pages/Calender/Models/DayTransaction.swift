//
//  DayTransaction.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 2/3/26.
//

import Foundation

struct DayTransaction: Equatable {
    let id: UUID
    let amount: Int64
    let categoryId: String?
    let memo: String?
}
