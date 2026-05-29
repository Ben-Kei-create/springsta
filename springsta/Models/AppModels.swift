import Foundation

enum SpringTrack: String, Codable, CaseIterable, Equatable {
    case foundation = "foundation"
    case practice = "practice"

    var displayName: String {
        switch self {
        case .foundation: return "基礎"
        case .practice: return "実践"
        }
    }

    var badgeColor: String {
        switch self {
        case .foundation: return "2563EB"
        case .practice: return "0EA5E9"
        }
    }
}

enum QuizCategory: String, Codable, CaseIterable {
    case bootBasics = "boot-basics"
    case dependencyInjection = "dependency-injection"
    case webMvc = "web-mvc"
    case validation = "validation"
    case configuration = "configuration"
    case dataJpa = "data-jpa"
    case transactions = "transactions"
    case security = "security"
    case testing = "testing"
    case observability = "observability"
    case deployment = "deployment"
    case architecture = "architecture"
    case errorReading = "error-reading"

    var displayName: String {
        switch self {
        case .bootBasics: return "Spring Boot基礎"
        case .dependencyInjection: return "DI・Bean"
        case .webMvc: return "Web MVC"
        case .validation: return "入力検証"
        case .configuration: return "設定・プロファイル"
        case .dataJpa: return "Spring Data JPA"
        case .transactions: return "トランザクション"
        case .security: return "Spring Security"
        case .testing: return "テスト"
        case .observability: return "運用・監視"
        case .deployment: return "デプロイ"
        case .architecture: return "実践設計"
        case .errorReading: return "エラー読解"
        }
    }

    static func canonical(rawValue: String) -> QuizCategory? {
        if let category = QuizCategory(rawValue: rawValue) {
            return category
        }
        return nil
    }
}
