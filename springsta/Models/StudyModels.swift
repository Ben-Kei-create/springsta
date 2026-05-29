import Foundation

enum SpringBootVersion: String, Codable, CaseIterable, Identifiable {
    case boot3 = "boot3"

    var id: String { rawValue }

    var displayName: String {
        "Spring Boot 3.x"
    }

    func examCode(for level: SpringTrack) -> String {
        switch level {
        case .foundation: return "Spring Boot 3.x 基礎"
        case .practice: return "Spring Boot 3.x 実践"
        }
    }
}

enum QuizDifficulty: String, Codable, CaseIterable {
    case foundation
    case standard
    case tricky
    case exam

    var displayName: String {
        switch self {
        case .foundation: return "基礎"
        case .standard: return "標準"
        case .tricky: return "実務注意"
        case .exam: return "総合"
        }
    }
}

enum QuizReviewStatus: String, Codable {
    case draft
    case verified
    case needsReview

    var displayName: String {
        switch self {
        case .draft: return "下書き"
        case .verified: return "確認済み"
        case .needsReview: return "要確認"
        }
    }
}

struct ExamObjective: Identifiable, Hashable {
    let id: String
    let version: SpringBootVersion
    let level: SpringTrack
    let category: QuizCategory
    let title: String
    let priority: Int
}

enum ExamObjectiveCatalog {
    static let all: [ExamObjective] = [
        ExamObjective(
            id: "boot3-foundation-starter",
            version: .boot3,
            level: .foundation,
            category: .bootBasics,
            title: "スターター、起動クラス、自動設定",
            priority: 1
        ),
        ExamObjective(
            id: "boot3-foundation-di",
            version: .boot3,
            level: .foundation,
            category: .dependencyInjection,
            title: "Bean定義、コンストラクタインジェクション、スコープ",
            priority: 1
        ),
        ExamObjective(
            id: "boot3-foundation-web",
            version: .boot3,
            level: .foundation,
            category: .webMvc,
            title: "Controller、RequestMapping、JSONレスポンス",
            priority: 1
        ),
        ExamObjective(
            id: "boot3-foundation-config",
            version: .boot3,
            level: .foundation,
            category: .configuration,
            title: "application.yml、プロファイル、ConfigurationProperties",
            priority: 1
        ),
        ExamObjective(
            id: "boot3-foundation-data",
            version: .boot3,
            level: .foundation,
            category: .dataJpa,
            title: "Repository、Entity、クエリメソッド",
            priority: 2
        ),
        ExamObjective(
            id: "boot3-foundation-test",
            version: .boot3,
            level: .foundation,
            category: .testing,
            title: "Spring Boot Testとスライステスト",
            priority: 2
        ),
        ExamObjective(
            id: "boot3-practice-layered",
            version: .boot3,
            level: .practice,
            category: .architecture,
            title: "Controller → Service → Repositoryの責務分離",
            priority: 1
        ),
        ExamObjective(
            id: "boot3-practice-transaction",
            version: .boot3,
            level: .practice,
            category: .transactions,
            title: "トランザクション境界とロールバック",
            priority: 1
        ),
        ExamObjective(
            id: "boot3-practice-security",
            version: .boot3,
            level: .practice,
            category: .security,
            title: "SecurityFilterChain、認可、CSRF",
            priority: 1
        ),
        ExamObjective(
            id: "boot3-practice-validation",
            version: .boot3,
            level: .practice,
            category: .validation,
            title: "DTOバリデーションとエラーハンドリング",
            priority: 1
        ),
        ExamObjective(
            id: "boot3-practice-observability",
            version: .boot3,
            level: .practice,
            category: .observability,
            title: "Actuator、ヘルスチェック、メトリクス",
            priority: 2
        ),
        ExamObjective(
            id: "boot3-practice-deployment",
            version: .boot3,
            level: .practice,
            category: .deployment,
            title: "外部化設定、環境変数、コンテナ起動",
            priority: 2
        ),
    ]

    static func objectives(for version: SpringBootVersion, level: SpringTrack) -> [ExamObjective] {
        let exact = all
            .filter { $0.version == version && $0.level == level }
            .sorted { lhs, rhs in
                if lhs.priority == rhs.priority { return lhs.title < rhs.title }
                return lhs.priority < rhs.priority
            }

        if !exact.isEmpty {
            return exact
        }

        return all
            .filter { $0.version == .boot3 && $0.level == level }
            .sorted { lhs, rhs in
                if lhs.priority == rhs.priority { return lhs.title < rhs.title }
                return lhs.priority < rhs.priority
            }
    }
}

enum QuizPracticeMode: String, Codable, CaseIterable, Identifiable {
    case single
    case daily
    case weak
    case mistakes
    case unattempted
    case mockExam
    case bookmarks

    var id: String { rawValue }

    static let homeModes: [QuizPracticeMode] = [
        .daily,
        .weak,
        .mistakes,
        .unattempted,
        .mockExam
    ]

    var displayName: String {
        switch self {
        case .single: return "1問練習"
        case .daily: return "デイリー"
        case .weak: return "弱点克服"
        case .mistakes: return "間違い復習"
        case .unattempted: return "未学習"
        case .mockExam: return "総合演習"
        case .bookmarks: return "ブックマーク"
        }
    }

    var title: String {
        displayName
    }

    var subtitle: String {
        switch self {
        case .single:
            return "選んだ1問を確認"
        case .daily:
            return "今日のSpring Boot演習"
        case .weak:
            return "苦手タグを重点確認"
        case .mistakes:
            return "間違えた問題を再確認"
        case .unattempted:
            return "未学習の範囲を進める"
        case .mockExam:
            return "基礎から実践まで通し演習"
        case .bookmarks:
            return "保存した問題だけ復習"
        }
    }

    var icon: String {
        switch self {
        case .single:
            return "1.circle.fill"
        case .daily:
            return "calendar.badge.clock"
        case .weak:
            return "target"
        case .mistakes:
            return "arrow.counterclockwise"
        case .unattempted:
            return "tray.full"
        case .mockExam:
            return "list.bullet.clipboard"
        case .bookmarks:
            return "bookmark.fill"
        }
    }

    var limit: Int {
        switch self {
        case .single: return 1
        case .daily: return 10
        case .weak, .mistakes, .unattempted, .bookmarks: return 12
        case .mockExam: return 30
        }
    }
}

struct QuizSession: Identifiable {
    let id = UUID()
    let mode: QuizPracticeMode
    let level: SpringTrack
    let version: SpringBootVersion
    let quizzes: [Quiz]
    var customTitle: String? = nil
    var mockExamVariant: MockExamVariant? = nil

    var title: String {
        customTitle ?? mode.displayName
    }

    static func single(_ quiz: Quiz) -> QuizSession {
        QuizSession(mode: .single, level: quiz.level, version: quiz.examVersion, quizzes: [quiz])
    }

    static func bookmarks(_ quizzes: [Quiz], level: SpringTrack, version: SpringBootVersion) -> QuizSession {
        QuizSession(
            mode: .bookmarks,
            level: level,
            version: version,
            quizzes: quizzes,
            customTitle: "ブックマーク"
        )
    }
}

struct QuizAnswerRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let quizId: String
    let level: SpringTrack
    let category: String
    let tags: [String]
    let selectedChoiceId: String
    let correct: Bool
    let answeredAt: Date
    let elapsedSeconds: Int?

    init(
        id: UUID = UUID(),
        quizId: String,
        level: SpringTrack,
        category: String,
        tags: [String],
        selectedChoiceId: String,
        correct: Bool,
        answeredAt: Date = Date(),
        elapsedSeconds: Int? = nil
    ) {
        self.id = id
        self.quizId = quizId
        self.level = level
        self.category = category
        self.tags = tags
        self.selectedChoiceId = selectedChoiceId
        self.correct = correct
        self.answeredAt = answeredAt
        self.elapsedSeconds = elapsedSeconds
    }
}

struct QuizAttemptStats {
    let attempts: Int
    let correct: Int
    let latest: QuizAnswerRecord?

    static let empty = QuizAttemptStats(attempts: 0, correct: 0, latest: nil)

    var accuracy: Double {
        guard attempts > 0 else { return 0 }
        return Double(correct) / Double(attempts)
    }

    var isAnswered: Bool { attempts > 0 }
    var isMastered: Bool { attempts >= 2 && accuracy >= 0.8 && latest?.correct == true }
    var needsReview: Bool { attempts > 0 && latest?.correct == false }
}

struct WeakTagSummary: Identifiable, Hashable {
    let tag: String
    let attempts: Int
    let misses: Int

    var id: String { tag }

    var missRate: Double {
        guard attempts > 0 else { return 0 }
        return Double(misses) / Double(attempts)
    }

    var missRatePercent: Int {
        Int((missRate * 100).rounded())
    }
}

struct ObjectiveProgressSummary: Identifiable, Hashable {
    let objective: ExamObjective
    let attempts: Int
    let correct: Int

    var id: String { objective.id }
    var misses: Int { attempts - correct }

    var accuracy: Double {
        guard attempts > 0 else { return 0 }
        return Double(correct) / Double(attempts)
    }

    var accuracyPercent: Int {
        Int((accuracy * 100).rounded())
    }

    var displayTitle: String {
        objective.title
    }
}
