# STUDY_NOTES.md

> RIBs 아키텍처 학습 기록 | 이 프로젝트를 구현하며 체득한 핵심 개념 정리

---

## 1. RIBs Dependency Injection 흐름

> `Component → Builder → Interactor` 순서로 의존성이 전달된다.

RIBs의 DI는 각 RIB이 필요한 의존성을 `Dependency` 프로토콜로 선언하고, 부모 `Component`가 이를 충족시키는 방식으로 동작한다.

### 흐름 단계

| 단계 | 주체 | 역할 |
|------|------|------|
| 1 | `Dependency` 프로토콜 | "나는 이것이 필요하다" 선언 |
| 2 | 부모 `Component` | 해당 프로토콜 구현 → 값 제공 |
| 3 | `Builder` | `Component`를 받아 `Interactor`/`Router`에 주입 |
| 4 | `Interactor` | 실제 사용 |

### 이 프로젝트의 실제 흐름: `dateGenerator`

**1단계 — CalendarDependency: 필요한 것 선언**
```swift
// CalendarBuilder.swift
protocol CalendarDependency: Dependency {
    var dateGenerator: DateGenerator { get }
}
```

**2단계 — AppRootComponent: 부모가 의존성 충족**
```swift
// AppRootBuilder.swift
final class AppRootComponent: Component<AppRootDependency>, CalendarDependency, SettingDependency {
    let dateGenerator: DateGenerator = CalendarDateGenerator()
    //                                  ↑ 실제 구현체를 여기서 생성
}
```

**3단계 — CalendarBuilder: Component로부터 꺼내 Interactor에 전달**
```swift
// CalendarBuilder.swift
public func build(withListener listener: CalendarListener) -> ViewableRouting {
    let component = CalendarComponent(dependency: dependency)
    let interactor = CalendarInteractor(
        presenter: viewController,
        dateGenerator: dependency.dateGenerator  // ← 주입
    )
    ...
}
```

**4단계 — CalendarInteractor: 생성자 주입으로 수신**
```swift
// CalendarInteractor.swift
private let dateGenerator: DateGenerator

init(presenter: CalendarPresentable, dateGenerator: DateGenerator) {
    self.dateGenerator = dateGenerator
    super.init(presenter: presenter)
}
```

### 핵심 포인트
- 의존성의 **생성** 책임은 부모 `Component`에 있다.
- 자식 RIB은 어떻게 만들어졌는지 모른다 — 프로토콜(`DateGenerator`)만 안다.
- 이 구조 덕분에 테스트 시 Mock 구현체로 교체가 용이하다.

---

## 2. 부모-자식 RIB 간 통신

> 방향에 따라 사용하는 메커니즘이 다르다.

| 방향 | 메커니즘 | 이유 |
|------|---------|------|
| 자식 → 부모 | `Listener` 프로토콜 | 자식이 부모를 직접 참조하면 강한 결합 발생 |
| 부모 → 자식 | `Router`의 `attach/detach` | 부모가 자식의 생명주기를 관리 |

### 자식 → 부모: Listener 패턴

자식 RIB은 `Listener` 프로토콜을 통해 부모에게 이벤트를 전달한다. 자식은 부모가 누구인지 모른다.

```swift
// TransactionInputBuilder.swift — 자식이 필요한 콜백 정의
public protocol TransactionInputListener: AnyObject {
    func transactionInputDidClose()
    func transactionInputDidSave(savedDate: Date)
}
```

```swift
// CalendarInteractor.swift — 부모가 Listener를 직접 구현
extension CalendarInteractor: TransactionInputListener {

    func transactionInputDidClose() {
        self.router?.detachTransactionInput()  // 자식 RIB 해제
    }

    func transactionInputDidSave(savedDate: Date) {
        // 저장된 날짜의 데이터만 갱신
        let transactionsByDay = self.makeTransactionsByDay(for: [savedDate])
        self.presenter.presentUpdatedTransactions(transactionsByDay: transactionsByDay)
    }
}
```

```swift
// CalendarBuilder.swift — 빌드 시점에 listener 연결
let interactor = CalendarInteractor(...)
interactor.listener = listener  // ← 부모 Interactor가 주입됨
```

### 부모 → 자식: Router를 통한 attach/detach

부모 `Interactor`는 Router에게 명령하고, `Router`가 자식 RIB을 조립하고 화면에 표시한다.

```swift
// CalendarInteractor.swift — 인터랙터가 라우터에 위임
func didTapPlusButton(selectedDate: Date) {
    self.router?.attachTransactionInput(selectedDate: selectedDate)
}

func transactionInputDidClose() {
    self.router?.detachTransactionInput()
}
```

```swift
// CalendarRouter.swift — 라우터가 실제 화면 전환 수행
func attachTransactionInput(selectedDate: Date) {
    guard transactionInputRouting == nil else { return }  // 중복 attach 방지

    let transactionInput = transactionInputBuilder.build(
        withListener: interactor,  // 부모 interactor를 listener로 전달
        selectedDate: selectedDate
    )
    transactionInputRouting = transactionInput
    attachChild(transactionInput)  // RIBs 트리에 등록

    let navi = UINavigationController(rootViewController: transactionInput.viewControllable.uiviewController)
    navi.modalPresentationStyle = .fullScreen
    viewController.uiviewController.present(navi, animated: true)
}

func detachTransactionInput() {
    guard let routing = transactionInputRouting else { return }
    viewController.uiviewController.dismiss(animated: true)
    detachChild(routing)           // RIBs 트리에서 제거 → 메모리 해제
    self.transactionInputRouting = nil
}
```

### 핵심 포인트
- `attachChild` / `detachChild` 는 단순 화면 전환이 아니라 **RIBs 트리의 생명주기 관리**다.
- `detachChild` 를 빠뜨리면 메모리 누수 + 비활성 Interactor가 살아남는 버그가 발생한다.
- 자식 RIB이 닫힐 때 `dismiss` 와 `detachChild` 를 반드시 **둘 다** 호출해야 한다.

---

## 3. PresentableInteractor를 통한 View ↔ Interactor 분리

> `ViewController`는 UI 이벤트를 인터랙터에 전달하고, 인터랙터는 데이터를 `Presenter` 메서드로 밀어 넣는다. 둘은 서로의 구현을 모른다.

### 역할 분리 구조

```
View (이벤트 발생)
  └─ CalendarPresentableListener 프로토콜 (이벤트 전달)
       └─ CalendarInteractor (비즈니스 로직 처리)
            └─ CalendarPresentable 프로토콜 (결과 전달)
                 └─ CalendarViewController (UI 업데이트)
```

### View → Interactor: Listener 프로토콜

`ViewController`는 `listener`를 통해 인터랙터를 호출한다. `listener`의 실제 타입은 모른다.

```swift
// CalendarViewController.swift
protocol CalendarPresentableListener: AnyObject {
    func didTapPlusButton(selectedDate: Date)
    func didTapTransactionDetail(id: UUID)
    func didTapDeleteTransaction(id: UUID, date: Date)
}

final class CalendarViewController: UIViewController {
    var listener: CalendarPresentableListener?

    // View 이벤트 → listener 호출 (Combine 바인딩)
    override func viewDidLoad() {
        viewEventLogic.didTapPlusButton
            .sink { [weak self] selectedDate in
                self?.listener?.didTapPlusButton(selectedDate: selectedDate)
            }.store(in: &cancellables)
    }
}
```

### Interactor → View: Presentable 프로토콜

인터랙터는 `presenter`를 통해 View에 데이터를 전달한다. `presenter`의 실제 타입도 모른다.

```swift
// CalendarInteractor.swift
protocol CalendarPresentable: Presentable {
    func presentPageInfo(pageInfo: CalendarViewModel.PageInfo)
    func presentUpdatedTransactions(transactionsByDay: [Date: [DayTransaction]])
}

class CalendarInteractor: PresentableInteractor<CalendarPresentable> {

    func transactionInputDidSave(savedDate: Date) {
        let data = makeTransactionsByDay(for: [savedDate])
        self.presenter.presentUpdatedTransactions(transactionsByDay: data)
        //   ↑ 인터랙터는 View의 존재를 모른다. 프로토콜만 안다.
    }
}
```

### 핵심 포인트
- `PresentableInteractor<P>` 의 제네릭 `P` 가 바로 `Presentable` 프로토콜이다.
- Interactor는 `UIKit`을 `import`하지 않는다 — 완전한 UI 독립성.
- View ↔ Interactor 사이에 프로토콜 두 개(`PresentableListener`, `Presentable`)가 항상 존재한다.

---

## 4. SnapKit을 활용한 코드 기반 UI

> Storyboard/XIB 없이 코드로만 레이아웃을 구성한다. SnapKit은 AutoLayout DSL을 제공한다.

### `.do {}` 빌더 패턴

`Utils/Sets.swift`에 정의된 패턴으로, 프로퍼티 설정과 선언을 한 곳에 모은다.

```swift
// 선언과 설정을 분리하지 않아도 된다
private let titleLabel = UILabel().do {
    $0.font = .systemFont(ofSize: 16, weight: .semibold)
    $0.textColor = .label
    $0.textAlignment = .center
}
```

### SnapKit 레이아웃 예시

```swift
// addSubview 후 makeConstraints로 제약 설정
addSubview(titleLabel)
titleLabel.snp.makeConstraints {
    $0.top.equalTo(safeAreaLayoutGuide).offset(16)
    $0.leading.trailing.equalToSuperview().inset(20)
}

// 기존 제약 업데이트
titleLabel.snp.updateConstraints {
    $0.top.equalTo(safeAreaLayoutGuide).offset(32)
}

// 모든 제약 교체
titleLabel.snp.remakeConstraints {
    $0.center.equalToSuperview()
}
```

### View / ViewController 역할 분리

RIBs에서 View 레이어는 두 파일로 나뉜다.

| 파일 | 역할 |
|------|------|
| `*View.swift` | UI 요소 생성, 레이아웃, `DisplayLogic` / `EventLogic` 프로토콜 구현 |
| `*ViewController.swift` | `loadView()`에서 View 교체, Combine으로 이벤트/디스플레이 바인딩 |

```swift
// CalendarViewController.swift
override func loadView() {
    self.view = CalendarView.create()  // ViewController는 View를 직접 생성하지 않는다
}
```

---

## 5. Core Data CRUD — CoreDataManager 싱글톤

> NSPersistentContainer를 래핑한 싱글톤으로 CRUD를 캡슐화한다.

### 기본 구조

```swift
final class CoreDataManager {
    static let shared = CoreDataManager()

    private let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        self.container.viewContext  // 메인 스레드 context
    }
}
```

### Create — context에 등록 후 save

```swift
// TransactionInputInteractor.swift
func didTapSaveButton(amount: Int64, categoryId: String?, memo: String?) {
    // 1. NSManagedObject 생성 → context에 자동 등록
    let transaction = Transaction(context: CoreDataManager.shared.context)

    // 2. 프로퍼티 설정
    transaction.id = UUID()
    transaction.amount = amount
    transaction.date = self.selectedDate

    // 3. context → 영구 저장소에 반영
    CoreDataManager.shared.saveContext()
}
```

### Read — NSPredicate로 필터링

```swift
// CoreDataManager.swift
func fetchTransactions(for month: Date) -> [Transaction] {
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()

    // 월의 시작~끝 날짜 범위로 필터링
    request.predicate = NSPredicate(
        format: "date >= %@ AND date < %@",
        startOfMonth as NSDate,
        endOfMonth as NSDate
    )
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

    return try context.fetch(request)
}
```

### Delete — fetch 후 context.delete, save

```swift
func deleteTransaction(id: UUID) -> Bool {
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.fetchLimit = 1

    if let obj = try context.fetch(request).first {
        context.delete(obj)
        try context.save()
        return true
    }
    return false
}
```

### saveContext — 변경이 있을 때만 저장

```swift
func saveContext() {
    guard self.context.hasChanges else { return }  // 불필요한 save 방지
    try self.context.save()
}
```

### 핵심 포인트
- Core Data의 3단계: **생성(context 등록) → 수정(프로퍼티 변경) → 저장(save)**
- `viewContext`는 메인 스레드 전용이다. 백그라운드 작업이 필요하면 `performBackgroundTask` 사용.
- `NSPredicate`의 `%@`는 `NSObject` 타입이므로 `Date`는 반드시 `as NSDate`로 캐스팅해야 한다.

---

## 6. 정리: RIBs 전체 흐름 요약

```
SceneDelegate
  └─ AppRootBuilder.build()
       └─ AppRootComponent (EmptyDependency 충족)
            ├─ CalendarBuilder(dependency: component)
            │    └─ CalendarComponent (CalendarDependency 충족)
            │         ├─ TransactionInputBuilder(dependency: component)
            │         └─ TransactionDetailBuilder(dependency: component)
            └─ SettingBuilder(dependency: component)
```

**이벤트 하나의 전체 여정 (+ 버튼 탭 → 입력 화면 표시)**

```
1. CalendarView       — didTapPlusButton 이벤트 발행 (Combine Subject)
2. CalendarViewController — listener?.didTapPlusButton(selectedDate:) 호출
3. CalendarInteractor — router?.attachTransactionInput(selectedDate:) 호출
4. CalendarRouter     — TransactionInputBuilder.build() → attachChild() → present()
5. TransactionInputVC — 화면 표시
```

**입력 완료 후 역방향 흐름**

```
5. TransactionInputInteractor — listener?.transactionInputDidSave(savedDate:)
4. CalendarInteractor(=Listener) — router?.detachTransactionInput() + presenter.presentUpdatedTransactions()
3. CalendarRouter     — dismiss() + detachChild()
2. CalendarViewController — viewDisplayLogic.displayUpdatedTransactions() 호출
1. CalendarView       — UI 갱신
```
