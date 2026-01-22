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
        // UINavigationBar
        let appearance = UINavigationBarAppearance().do {
            $0.configureWithOpaqueBackground()  // 배경을 불투명하게
            $0.backgroundColor = .green.withAlphaComponent(0.2)          // 원하는 색상
            $0.shadowColor = .separator          // 하단 라인 (원하는 경우)

            // Title 스타일
            $0.titleTextAttributes = [
                .foregroundColor: UIColor.label,
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
            ]
        }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .systemBlue // 버튼 색상
        
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
    
//    private func setupTabs() {
//        let homeVC = HomeViewController()
////        let homeVC2 = CalendarViewController()
//        let homeVC3 = HomeViewController()
//        
//        let homeNav = UINavigationController(rootViewController: homeVC)
////        let calendarNav = UINavigationController(rootViewController: homeVC2)
//        let settingsNav = UINavigationController(rootViewController: homeVC3)
//        
//        homeNav.tabBarItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
//        calendarNav.tabBarItem = UITabBarItem(title: "캘린더", image: UIImage(systemName: "calendar"), tag: 1)
//        settingsNav.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gearshape"), tag: 2)
//        
//        viewControllers = [homeNav, calendarNav, settingsNav]
//    }
}
