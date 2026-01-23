//
//  SettingView.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import UIKit

// MARK: ViewEventLogic

protocol SettingViewEventLogic {
    
}

// MARK: ViewDisplayLogic

protocol SettingViewDisplayLogic {
    
}

final class SettingView: UIView, SettingViewEventLogic, SettingViewDisplayLogic {
    
    // MARK: instantiate
    
    required init() {
        super.init(frame: .zero)
        
        self.makeViewLayout()
        self.makeEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        print(type(of: self), #function)
    }
    
    static func create() -> SettingView {
        return SettingView()
    }
    
    // MARK: MakeViewLayout
    
    private func makeViewLayout() {
        self.backgroundColor = .white
    }
    
    
    // MARK: MakeViewEvents
    
    private func makeEvents() {
        
    }
}
