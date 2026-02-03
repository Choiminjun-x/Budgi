//
//  MainTabBarController.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import UIKit
import SnapKit

protocol AppRootPresentableListener: AnyObject {
}


class MainTabBarController: UITabBarController, AppRootViewControllable, AppRootPresentable {
    
    var listener: AppRootPresentableListener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.makeViewLayout()
    }
    
    // MARK: MakeViewLayout
    
    private func makeViewLayout() {
        // UITabBar
        UIView().do {
            $0.backgroundColor = .separator
            
            self.tabBar.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(2.0 / UIScreen.main.scale)
            }
        }
        
        self.tabBar.tintColor = .systemBlue
        self.tabBar.unselectedItemTintColor = .gray
        self.tabBar.backgroundColor = .systemBackground
    }
    
    func setViewControllers(_ viewControllers: [UIViewController]) {
        super.setViewControllers(viewControllers, animated: false)
    }
}
