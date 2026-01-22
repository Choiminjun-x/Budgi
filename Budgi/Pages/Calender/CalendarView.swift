//
//  CalendarView.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import UIKit
import Combine
import SnapKit


// MARK: - EventLogic

protocol CalendarViewEventLogic where Self: NSObject {
    var requestPreviousMonthInfo: PassthroughSubject<Date, Never> { get }
    var requestNextMonthInfo: PassthroughSubject<Date, Never> { get }
    
}

// MARK: - DisplayLogic

protocol CalendarViewDisplayLogic where Self: NSObject {
    func displayPageInfo(_ model: CalendarViewModel.PageInfo)
    func displayPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date )
    func displayNextMonthInfo(newDays: [CalendarDay], newMonth: Date)
    
    var displayNaviTitle: PassthroughSubject<String, Never> { get }
}

// MARK: - ViewModel

enum CalendarViewModel {
    struct PageInfo {
        var months: [[CalendarDay]]
        var monthBases: [Date]
    }
}

final class CalendarView: UIView, CalendarViewEventLogic, CalendarViewDisplayLogic {
    
    private var calendarCollectionView: UICollectionView!
    private let weekHeader = WeekHeaderView()
    
    private var months: [[CalendarDay]] = []
    private var monthBases: [Date] = [] // 각 섹션에 해당하는 월의 첫날들
    
    var centerSectionIndex: Int = 500
    
    var currentPage: Int = 2
    var selectedIndexPath: IndexPath?
    
    var requestPreviousMonthInfo: PassthroughSubject<Date, Never> = .init()
    var requestNextMonthInfo: PassthroughSubject<Date, Never> = .init()
    
    var displayNaviTitle: PassthroughSubject<String, Never> = .init()
    
    
    // MARK: instantiate
    
    init() {
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
    
    static func create() -> CalendarView {
        return CalendarView()
    }
    
    
    // MARK: MakeViewLayout
    
    private func makeViewLayout() {
        self.backgroundColor = .white
        
        self.weekHeader.do {
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(4)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(24)
            }
        }
        
        let layout = self.makeCalendarLayout()
        self.calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).do {
            $0.backgroundColor = .clear
            $0.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
            $0.delegate = self
            $0.dataSource = self
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.weekHeader.snp.bottom).offset(4)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
    private func makeCalendarLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            let containerWidth = environment.container.effectiveContentSize.width
            let itemLength = floor(containerWidth / 7)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 7.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let rowGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(itemLength)
            )
            let rowGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowGroupSize, subitem: item, count: 7)
            
            let daysCount = self?.months.indices.contains(sectionIndex) == true ? self?.months[sectionIndex].count : 42
            let resolvedCount = daysCount ?? 42
            let rowCount: Int
            if resolvedCount <= 28 {
                rowCount = 4
            } else if resolvedCount <= 35 {
                rowCount = 5
            } else {
                rowCount = 6
            }
            let monthGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(itemLength * CGFloat(rowCount))
            )
            let monthGroup = NSCollectionLayoutGroup.vertical(layoutSize: monthGroupSize, subitem: rowGroup, count: rowCount)
            
            let section = NSCollectionLayoutSection(group: monthGroup)
            
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        return layout
    }
    
    
    // MARK: makeViewEvents
    
    private func makeEvents() {
        
    }
    
    
    // MARK: displayPageInfo
    
    func displayPageInfo(_ model: CalendarViewModel.PageInfo) {
        self.monthBases.append(contentsOf: model.monthBases)
        self.months.append(contentsOf: model.months)
        
        self.calendarCollectionView.collectionViewLayout.invalidateLayout()
        self.calendarCollectionView.reloadData() {
            let centerIndex = 2 // 📌 현재월 = 중간 (offset: 0) → section index 2
            let indexPath = IndexPath(item: 0, section: centerIndex)
            self.calendarCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            
            self.updateMonthTitle(forPageIndex: centerIndex)
        }
    }
    
    func displayPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date) {
        self.months.insert(newDays, at: 0)
        self.monthBases.insert(newMonth, at: 0)
        
        self.calendarCollectionView.performBatchUpdates {
            self.calendarCollectionView.insertSections(IndexSet(integer: 0))
        } completion: { _ in
            // 📌 삽입으로 인해 기존 페이지가 section + 1로 밀렸으므로 → +1 위치로 이동
            DispatchQueue.main.async {
                let correctedIndexPath = IndexPath(item: 0, section: self.currentPage + 1)
                self.calendarCollectionView.scrollToItem(at: correctedIndexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
    
    func displayNextMonthInfo(newDays: [CalendarDay], newMonth: Date) {
        let insertIndex = self.months.count
        self.months.append(newDays)
        self.monthBases.append(newMonth)
        
        self.calendarCollectionView.performBatchUpdates {
            self.calendarCollectionView.insertSections(IndexSet(integer: insertIndex))
        }
    }
    
    func updateMonthTitle(forPageIndex pageIndex: Int) {
        guard self.months.indices.contains(pageIndex),
              let currentDate = self.months[pageIndex].first(where: { $0.isInCurrentMonth })?.date else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        
        let monthText = formatter.string(from: currentDate)
        self.displayNaviTitle.send(monthText)
    }
}

extension CalendarView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.months[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        cell.displayCellInfo(with: self.months[indexPath.section][indexPath.item])
        
        // 셀 선택 상태 반영
        let isSelected = (indexPath == self.selectedIndexPath)
        cell.displaySelectedStyle(isSelected)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 이전 선택 셀 해제
        if let previousIndexPath = self.selectedIndexPath {
            if let previousCell = collectionView.cellForItem(at: previousIndexPath) as? DateCell {
                previousCell.displaySelectedStyle(false)
            } else {
                collectionView.reloadItems(at: [previousIndexPath]) // 화면 밖에 있을 경우
            }
        }
        
        // 현재 선택 셀 표시
        if let currentCell = collectionView.cellForItem(at: indexPath) as? DateCell {
            currentCell.displaySelectedStyle(true)
        }
        
        // 새로운 선택 위치 저장
        self.selectedIndexPath = indexPath
    }
}

extension CalendarView: UIScrollViewDelegate {
    
    func currentPageIndex() -> Int {
        let pageWidth = calendarCollectionView.bounds.width
        guard pageWidth > 0 else { return 0 }
        return Int((calendarCollectionView.contentOffset.x + pageWidth / 2) / pageWidth)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentPage = self.currentPageIndex()
        
        // ✅ 실제 보이는 페이지에 따라 제목 업데이트
        self.updateMonthTitle(forPageIndex: currentPage)
        
        // 🔁 안전한 조건에서만 확장
        if currentPage <= 1 {
            guard let firstMonth = monthBases.first,
                  let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: firstMonth) else { return }
            
            self.requestPreviousMonthInfo.send(newMonth)
        } else if currentPage >= months.count - 2 {
            guard let lastMonth = self.monthBases.last,
                  let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: lastMonth) else { return }
            
            self.requestNextMonthInfo.send(newMonth)
        }
    }
}
