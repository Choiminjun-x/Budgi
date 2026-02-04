//
//  Category.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 2/3/26.
//

import Foundation

struct Category: Hashable {
    enum Kind { case expense, income }
    
    let id: String
    let name: String
    let type: Kind
    
    init(id: String, type: Kind) {
        self.id = id
        self.type = type
        self.name = CategoryType.getCategoryType(for: id).rawValue
    }
}
