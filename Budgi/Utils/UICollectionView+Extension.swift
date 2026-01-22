//
//  UICollectionView+Extension.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 7/30/25.
//

import UIKit

extension UICollectionView {
    
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}
