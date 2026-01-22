//
//  Sets.swift
//  CardInfo
//
//  Created by 최민준(Minjun Choi) on 4/28/25.
//

import Foundation

public protocol Sets {}
extension Sets where Self: Any {
    
    @discardableResult
    public func `do`(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}

extension Sets where Self: AnyObject {
    
    @discardableResult
    public func `do`(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
    
    public func KFDSets(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}
