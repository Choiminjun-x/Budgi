//
//  HomeView.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import UIKit

// MARK: ViewEventLogic

protocol HomeViewEventLogic {
    
}

// MARK: ViewDisplayLogic

protocol HomeViewDisplayLogic {
    
}

final class HomeView: UIView, HomeViewEventLogic, HomeViewDisplayLogic {
    
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
    
    static func create() -> HomeView {
        return HomeView()
    }
    
    // MARK: MakeViewLayout
    
    private func makeViewLayout() {
        self.backgroundColor = .brown
    }
    
    
    // MARK: MakeViewEvents
    
    private func makeEvents() {
        
    }
}
