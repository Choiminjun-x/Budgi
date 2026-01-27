//
//  CalendarView.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import UIKit
import Combine
import SnapKit

// MARK: - Models

struct DayTransaction: Equatable {
    let id: UUID
    let amount: Int64
    let categoryId: String?
}


// MARK: - EventLogic

protocol CalendarViewEventLogic where Self: NSObject {
    var requestPreviousMonthInfo: PassthroughSubject<Date, Never> { get }
    var requestNextMonthInfo: PassthroughSubject<Date, Never> { get }
    
    var didTapPlusButton: PassthroughSubject<Date, Never> { get }
    var didTapDeleteTransaction: PassthroughSubject<(UUID, Date), Never> { get }
}

// MARK: - DisplayLogic

protocol CalendarViewDisplayLogic where Self: NSObject {
    func displayPageInfo(_ model: CalendarViewModel.PageInfo)
    func displayPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date, transactionsByDay: [Date: [DayTransaction]])
    func displayNextMonthInfo(newDays: [CalendarDay], newMonth: Date, transactionsByDay: [Date: [DayTransaction]])
    func displayUpdatedTransactions(_ transactionsByDay: [Date: [DayTransaction]])
    
    var displayNaviTitle: PassthroughSubject<String, Never> { get }
}

// MARK: - ViewModel

enum CalendarViewModel {
    struct PageInfo {
        var months: [[CalendarDay]]
        var monthBases: [Date]
        var transactionsByDay: [Date: [DayTransaction]]
    }
}

final class CalendarView: UIView, CalendarViewEventLogic, CalendarViewDisplayLogic {
    
    private let weekHeader = WeekHeaderView()
    private var calendarCollectionView: UICollectionView!
    
    private var separateLine: UIView!
    
    private var summaryScrollView: UIScrollView!
    private var summaryContainerView: UIView!
    private var summaryDayLabel: UILabel!
    private var summaryList: UIStackView!
    
    private var plusButton: UIButton!
    
    private var months: [[CalendarDay]] = []
    private var monthBases: [Date] = [] // 각 섹션에 해당하는 월의 첫날들
    private var transactionsByDay: [Date: [DayTransaction]] = [:]
    
    var centerSectionIndex: Int = 500
    
    var currentPage: Int = 2
    var selectedIndexPath: IndexPath?
    private var selectedDate: Date?
    
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: EventLogic
    
    var requestPreviousMonthInfo: PassthroughSubject<Date, Never> = .init()
    var requestNextMonthInfo: PassthroughSubject<Date, Never> = .init()
    
    var didTapPlusButton: PassthroughSubject<Date, Never> = .init()
    var didTapDeleteTransaction: PassthroughSubject<(UUID, Date), Never> = .init()
    
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
                $0.leading.trailing.equalToSuperview()
                // 6행 기준: 높이 = (width * 6/7)
                $0.height.equalTo(self.snp.width).multipliedBy(6.0/7.0)
            }
        }
        
        self.separateLine = UIView().do {
            $0.backgroundColor = .separator
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.calendarCollectionView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(2.0 / UIScreen.main.scale)
            }
        }
        
        self.summaryScrollView = UIScrollView().do { scrollView in
            self.addSubview(scrollView)
            scrollView.snp.makeConstraints {
                $0.top.equalTo(self.separateLine.snp.bottom)
                $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
                $0.leading.trailing.equalToSuperview()
            }

            self.summaryContainerView = UIView().do { container in
                scrollView.addSubview(container)
                container.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                    $0.width.equalToSuperview()
                    $0.height.equalToSuperview().priority(.low)
                }
                
                self.summaryDayLabel = UILabel().do {
                    $0.textColor = .gray
                    $0.numberOfLines = 1
                    $0.font = .systemFont(ofSize: 15, weight: .bold)
                    $0.setContentHuggingPriority(.required, for: .vertical)
                    $0.setContentCompressionResistancePriority(.required, for: .vertical)
                    
                    container.addSubview($0)
                    $0.snp.makeConstraints {
                        $0.top.equalToSuperview().inset(12)
                        $0.leading.trailing.equalToSuperview().inset(16)
                    }
                }
                
                self.summaryList = UIStackView().do { mainStack in
                    mainStack.axis = .vertical
                    mainStack.spacing = 6
                    mainStack.isLayoutMarginsRelativeArrangement = true
                    mainStack.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 20, right: 16)

                    container.addSubview(mainStack)
                    mainStack.snp.makeConstraints {
                        $0.top.equalTo(self.summaryDayLabel.snp.bottom)
                        $0.leading.trailing.bottom.equalToSuperview()
                    }
                }
            }
        }
        
        self.plusButton = UIButton().do {
            $0.setImage(UIImage(systemName: "plus"), for: .normal)
            $0.tintColor = .white
            $0.backgroundColor = .systemBlue
            $0.layer.cornerRadius = 28 // 원형 (56x56 크기 기준)
            
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(20)
                $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(30) // 탭바 위 30
                $0.height.width.equalTo(56)
            }
        }
    }
    
    private func makeCalendarLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            let containerWidth = environment.container.effectiveContentSize.width
            let itemLength = floor(containerWidth / 7) // 55
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
        self.plusButton.do {
            $0.tapPublisher.sink {
                self.didTapPlusButton.send(self.resolveSelectedDate())
            }.store(in: &cancellables)
        }
    }
    
    
    // MARK: displayPageInfo
    
    func displayPageInfo(_ model: CalendarViewModel.PageInfo) {
        self.monthBases.append(contentsOf: model.monthBases)
        self.months.append(contentsOf: model.months)
        self.transactionsByDay = model.transactionsByDay
        
        self.calendarCollectionView.collectionViewLayout.invalidateLayout()
        self.calendarCollectionView.reloadData()
        
        DispatchQueue.main.async {
             let centerIndex = 2
             let indexPath = IndexPath(item: 0, section: centerIndex)
             self.calendarCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
             self.updateMonthTitle(forPageIndex: centerIndex)
             
             // 초기 선택/요약: 오늘 날짜를 선택 상태로 표시하고 목록 업데이트
             if self.months.indices.contains(centerIndex),
                let todayIndex = self.months[centerIndex].firstIndex(where: { $0.isToday }) {
                 let todayPath = IndexPath(item: todayIndex, section: centerIndex)
                 self.selectedIndexPath = todayPath
                 self.selectedDate = Calendar.current.startOfDay(for: self.months[centerIndex][todayIndex].date)
                 self.calendarCollectionView.layoutIfNeeded()
                 if let cell = self.calendarCollectionView.cellForItem(at: todayPath) as? DateCell {
                     cell.displaySelectedStyle(true)
                 } else {
                     self.calendarCollectionView.reloadItems(at: [todayPath])
                 }
                 
                 // 내역 업데이트
                 let todayDate = self.months[centerIndex][todayIndex].date
                 self.updateSummaryDayTitle(currentDate: todayDate)
                 self.reloadSummaryList(for: todayDate)
             }
         }
    }
    
    func displayPreviousMonthInfo(newDays: [CalendarDay], newMonth: Date, transactionsByDay: [Date: [DayTransaction]]) {
        self.months.insert(newDays, at: 0)
        self.monthBases.insert(newMonth, at: 0)
        self.transactionsByDay.merge(transactionsByDay) { current, new in
            current + new
        }
        
        let pageWidth = self.calendarCollectionView.bounds.width
        guard pageWidth > 0 else { return }
        
        let previousOffset = self.calendarCollectionView.contentOffset
        self.calendarCollectionView.isUserInteractionEnabled = false
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        UIView.performWithoutAnimation {
            self.calendarCollectionView.performBatchUpdates({
                self.calendarCollectionView.insertSections(IndexSet(integer: 0))
            }, completion: { _ in
                // 레이아웃 확정 후 오프셋 보정 -> scrollToItem은 점프감 때문에 offest 조정
                self.calendarCollectionView.layoutIfNeeded()
                let newOffset = CGPoint(x: previousOffset.x + pageWidth, y: previousOffset.y)
                self.calendarCollectionView.setContentOffset(newOffset, animated: false)
                
                self.currentPage += 1
                self.updateMonthTitle(forPageIndex: self.currentPage)
                // 섹션 인덱스가 시프트 되었으므로, 선택된 날짜 기준으로 선택 인덱스 재매핑
                self.remapSelectionIndexPath()
                
                self.calendarCollectionView.isUserInteractionEnabled = true
                CATransaction.commit()
            })
        }
    }

    func displayNextMonthInfo(newDays: [CalendarDay], newMonth: Date, transactionsByDay: [Date: [DayTransaction]]) {
        let insertIndex = self.months.count
        self.months.append(newDays)
        self.monthBases.append(newMonth)
        self.transactionsByDay.merge(transactionsByDay) { current, new in
            current + new
        }
        
        self.calendarCollectionView.performBatchUpdates {
            self.calendarCollectionView.insertSections(IndexSet(integer: insertIndex))
        }
    }

    func displayUpdatedTransactions(_ transactionsByDay: [Date: [DayTransaction]]) {
        self.transactionsByDay.merge(transactionsByDay) { _, new in
            new
        }
        self.calendarCollectionView.reloadData()
        // 선택된 날짜 또는 오늘 날짜에 대한 요약 갱신
        self.reloadSummaryList(for: self.resolveSelectedDate())
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
    
    func updateSummaryDayTitle(currentDate: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        self.summaryDayLabel.text = formatter.string(from: currentDate)
    }

    private func resolveSelectedDate() -> Date {
        if let selectedIndexPath = self.selectedIndexPath,
           self.months.indices.contains(selectedIndexPath.section),
           self.months[selectedIndexPath.section].indices.contains(selectedIndexPath.item) {
            return self.months[selectedIndexPath.section][selectedIndexPath.item].date
        }
        return Date()
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
        let day = self.months[indexPath.section][indexPath.item]
        let dateKey = Calendar.current.startOfDay(for: day.date)
        let amounts = (self.transactionsByDay[dateKey] ?? []).map { $0.amount }
        cell.displayCellInfo(cellModel: .init(
            day: day,
            amounts: amounts)
        )
        
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
        
            // 일 지출 내역 요약 날짜 세팅
            let currentDate = self.months[indexPath.section][indexPath.item].date
            self.updateSummaryDayTitle(currentDate: currentDate)
            self.reloadSummaryList(for: currentDate)
        }
        
        // 새로운 선택 위치/날짜 저장
        self.selectedIndexPath = indexPath
        self.selectedDate = Calendar.current.startOfDay(for: self.months[indexPath.section][indexPath.item].date)
    }
}

// MARK: - Summary List Rendering

extension CalendarView {
    private func indexPath(for date: Date) -> IndexPath? {
        let key = Calendar.current.startOfDay(for: date)
        for (section, days) in self.months.enumerated() {
            if let item = days.firstIndex(where: { Calendar.current.startOfDay(for: $0.date) == key }) {
                return IndexPath(item: item, section: section)
            }
        }
        return nil
    }

    private func remapSelectionIndexPath() {
        guard let selectedDate else { return }
        let newPath = self.indexPath(for: selectedDate)
        guard let newPath else { return }

        let oldPath = self.selectedIndexPath
        self.selectedIndexPath = newPath

        if let old = oldPath, old != newPath {
            if let oldCell = self.calendarCollectionView.cellForItem(at: old) as? DateCell {
                oldCell.displaySelectedStyle(false)
            } else {
                self.calendarCollectionView.reloadItems(at: [old])
            }
        }
        if let newCell = self.calendarCollectionView.cellForItem(at: newPath) as? DateCell {
            newCell.displaySelectedStyle(true)
        } else {
            self.calendarCollectionView.reloadItems(at: [newPath])
        }
    }
    
    private func reloadSummaryList(for date: Date) {
        self.summaryList.arrangedSubviews.forEach { view in
            self.summaryList.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let key = Calendar.current.startOfDay(for: date)
        let items = self.transactionsByDay[key] ?? []
        guard !items.isEmpty else { return }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        for item in items {
            let row = SummaryRowView()
            let text = formatter.string(from: NSNumber(value: abs(item.amount))) ?? "0"
            let signColor: UIColor = item.amount < 0 ? .systemBlue : .systemRed
            let name = self.categoryName(for: item.categoryId)
            row.configure(category: name,
                          amountText: (item.amount < 0 ? "-" : "+") + text,
                          tint: signColor)
            // 내역 삭제
            row.onTapDelete = { [weak self] in
                guard let self else { return }
                self.didTapDeleteTransaction.send((item.id, date))
            }
            self.summaryList.addArrangedSubview(row)
        }
        
        // Spacer
        UIView().do {
            $0.setContentHuggingPriority(.defaultLow, for: .vertical)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            self.summaryList.addArrangedSubview($0)
        }
    }

    private func categoryName(for id: String?) -> String {
        guard let id = id else { return "미분류" }
        switch id {
        case "food": return "식비"
        case "transport": return "교통"
        case "hobby": return "취미"
        case "shopping": return "쇼핑"
        case "life": return "생활"
        case "health": return "의료"
        case "etc_exp": return "기타"
        case "salary": return "급여"
        case "bonus": return "보너스"
        case "gift": return "용돈"
        case "etc_inc": return "기타"
        case "uncat": return "미분류"
        default: return id
        }
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
