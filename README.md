# Budgi

> RIBs 아키텍처 학습을 목적으로 만든 개인 가계부 iOS 앱 | Swift · UIKit · CocoaPods

---

## 1. 개요

RIBs(Router-Interactor-Builder)는 Uber가 설계한 모바일 아키텍처로, 비즈니스 로직을 트리 형태로 캡슐화한다.
이 프로젝트는 RIBs의 구성 요소(Builder / Component / Interactor / Router / View)를 직접 구현하며 아키텍처를 체득하는 것을 목표로 한다.

**주요 기능**

- 월별 캘린더 기반 수입/지출 내역 조회
- 거래 내역 추가 · 수정 · 삭제
- 카테고리 분류 및 월별 합계 요약

---

## 2. 기술 스택

| 항목 | 선택 |
|------|------|
| Language | Swift 5 |
| UI | UIKit (Programmatic, SnapKit) |
| Architecture | RIBs 0.9.x |
| Persistence | Core Data |
| Package Manager | CocoaPods |
| Minimum iOS | iOS 13+ |

---

## 3. 아키텍처: RIBs

> 각 화면(기능)은 독립적인 RIB 단위로 분리되며, 부모-자식 트리 구조로 연결된다.

### RIB 구성 요소

| 파일 | 역할 |
|------|------|
| `Builder` | RIB 조립. `Component`(의존성 컨테이너)를 받아 `Router`를 반환 |
| `Component` | 의존성 보관. 자식 RIB의 `Dependency` 프로토콜을 구현 |
| `Interactor` | 비즈니스 로직. View 이벤트 처리 → Router/Listener 호출 |
| `Router` | 화면 전환. 자식 RIB attach/detach 담당 |
| `ViewController` + `View` | UI 전용. 인터랙터 호출 및 상태 렌더링 |

### RIB 트리

```
AppRootRouter (LaunchRouter)
└── MainTabBarController
    ├── CalendarRouter
    │   ├── TransactionInputRouter   ← modal 표시
    │   └── TransactionDetailRouter  ← modal 표시
    └── SettingRouter
```

`SceneDelegate`에서 `AppRootBuilder.build()`를 호출해 트리를 초기화한다.

---

## 4. 프로젝트 구조

```
Budgi/
├── Application/          # AppDelegate, SceneDelegate
├── Pages/
│   ├── AppRoot/          # 루트 RIB, TabBar 관리
│   ├── Calender/         # 캘린더 화면 + 도메인 모델
│   ├── TransactionInput/ # 거래 추가/수정 + CoreDataManager
│   ├── TransactionDetail/# 거래 상세
│   └── Setting/          # 설정 화면
├── Utils/                # 공통 익스텐션 (Sets, UIButton, UICollectionView)
└── Resources/            # Assets, Colors, Icons
```

### 도메인 모델 (`Pages/Calender/Models/`)

| 모델 | 설명 |
|------|------|
| `CategoryType` | `.income` / `.expense` |
| `Category` | 이름 + `CategoryType` |
| `CalendarDay` | 날짜 + `[DayTransaction]` |
| `DayTransaction` | 캘린더 표시용 거래 데이터 |

### Core Data 스키마

Entity: `Transaction`

| 필드 | 타입 |
|------|------|
| `id` | UUID |
| `amount` | Double |
| `categoryId` | String |
| `date` | Date |
| `memo` | String |

---

## 5. 시작하기

```bash
# 저장소 클론
git clone https://github.com/{username}/Budgi.git
cd Budgi

# 의존성 설치
pod install

# 워크스페이스 열기 (반드시 .xcworkspace 사용)
open Budgi.xcworkspace
```

Xcode에서 시뮬레이터를 선택 후 `⌘R` 빌드.

---

## 6. 새 RIB 추가 흐름

```
1. Pages/FeatureName/ 폴더 생성
2. Builder / Interactor / Router / ViewController / View 파일 생성
3. 부모 Component에 빌더 의존성 추가
4. 부모 Builder에서 자식 Builder inject
5. 부모 Router에서 attach/detach 메서드 구현
```

---

## 7. 학습 포인트

- RIBs의 **Dependency Injection** 흐름 (Component → Builder → Interactor)
- 부모-자식 간 통신: 자식 → 부모는 `Listener` 프로토콜, 부모 → 자식은 직접 Router 호출
- `PresentableInteractor`를 통한 View ↔ Interactor 분리
- SnapKit을 활용한 완전 코드 기반 UI 구성
- Core Data CRUD를 `CoreDataManager` 싱글톤으로 캡슐화

---

## 8. 의존성

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| [RIBs](https://github.com/uber/RIBs) | ~> 0.9.1 | 아키텍처 프레임워크 |
| [SnapKit](https://github.com/SnapKit/SnapKit) | ~> 5.7.1 | 코드 기반 AutoLayout |
