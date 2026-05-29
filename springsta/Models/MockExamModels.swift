import Foundation

enum MockExamVariant: String, Codable, CaseIterable, Identifiable {
    case small
    case full

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .small: return "20分演習"
        case .full: return "総合演習"
        }
    }

    var shortTitle: String {
        switch self {
        case .small: return "20分"
        case .full: return "総合"
        }
    }
}

struct MockExamSpec: Hashable {
    let version: SpringBootVersion
    let level: SpringTrack
    let officialQuestionCount: Int
    let officialDurationSeconds: Int
    let passingScorePercent: Int
    let smallDurationSeconds: Int = 20 * 60

    var examCode: String {
        version.examCode(for: level)
    }

    var secondsPerQuestion: Double {
        Double(officialDurationSeconds) / Double(officialQuestionCount)
    }

    func questionCount(for variant: MockExamVariant) -> Int {
        switch variant {
        case .small:
            return max(1, min(officialQuestionCount, Int((Double(smallDurationSeconds) / secondsPerQuestion).rounded(.down))))
        case .full:
            return officialQuestionCount
        }
    }

    func durationSeconds(for variant: MockExamVariant, questionCount: Int) -> Int {
        switch variant {
        case .small:
            return smallDurationSeconds
        case .full:
            return durationSeconds(for: questionCount)
        }
    }

    func durationSeconds(for questionCount: Int) -> Int {
        max(60, Int((Double(questionCount) * secondsPerQuestion).rounded()))
    }

    func durationText(for variant: MockExamVariant, questionCount: Int) -> String {
        let minutes = durationSeconds(for: variant, questionCount: questionCount) / 60
        return "\(minutes)分"
    }

    static func official(version: SpringBootVersion, level: SpringTrack) -> MockExamSpec {
        MockExamSpec(
            version: version,
            level: level,
            officialQuestionCount: level == .foundation ? 24 : 30,
            officialDurationSeconds: (level == .foundation ? 45 : 60) * 60,
            passingScorePercent: 70
        )
    }
}

struct MockExamAttempt: Codable, Identifiable, Equatable {
    let id: UUID
    let version: SpringBootVersion
    let level: SpringTrack
    let variant: MockExamVariant
    let startedAt: Date
    let completedAt: Date
    let timeLimitSeconds: Int
    let elapsedSeconds: Int
    let questionCount: Int
    let correctCount: Int
    let passingScorePercent: Int
    let answers: [MockExamAnswer]

    init(
        id: UUID = UUID(),
        version: SpringBootVersion,
        level: SpringTrack,
        variant: MockExamVariant,
        startedAt: Date,
        completedAt: Date,
        timeLimitSeconds: Int,
        elapsedSeconds: Int,
        questionCount: Int,
        correctCount: Int,
        passingScorePercent: Int,
        answers: [MockExamAnswer]
    ) {
        self.id = id
        self.version = version
        self.level = level
        self.variant = variant
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.timeLimitSeconds = timeLimitSeconds
        self.elapsedSeconds = elapsedSeconds
        self.questionCount = questionCount
        self.correctCount = correctCount
        self.passingScorePercent = passingScorePercent
        self.answers = answers
    }

    var scorePercent: Int {
        guard questionCount > 0 else { return 0 }
        return Int((Double(correctCount) / Double(questionCount) * 100).rounded())
    }

    var isPassing: Bool {
        scorePercent >= passingScorePercent
    }
}

struct MockExamAnswer: Codable, Identifiable, Equatable {
    var id: String { quizId }

    let quizId: String
    let category: String
    let tags: [String]
    let selectedChoiceId: String?
    let correctChoiceId: String
    let correct: Bool
    let elapsedSeconds: Int?
}
