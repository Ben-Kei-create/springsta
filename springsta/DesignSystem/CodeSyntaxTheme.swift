import SwiftUI

struct CodeSyntaxPalette {
    let keyword: Color
    let string: Color
    let type: Color
    let method: Color
    let comment: Color
    let number: Color
    let plain: Color

    var swatches: [Color] {
        [keyword, type, method, string, number]
    }
}

enum CodeSyntaxTheme: String, CaseIterable, Identifiable {
    case classic
    case ocean
    case forest

    var id: String { rawValue }

    static let storageKey = "codeSyntaxTheme"

    static func value(for rawValue: String) -> CodeSyntaxTheme {
        CodeSyntaxTheme(rawValue: rawValue) ?? .classic
    }

    var displayName: String {
        switch self {
        case .classic: return "標準"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        }
    }

    var palette: CodeSyntaxPalette {
        switch self {
        case .classic:
            return CodeSyntaxPalette(
                keyword: .jbSyntaxKeyword,
                string: .jbSyntaxString,
                type: .jbSyntaxType,
                method: .jbSyntaxMethod,
                comment: .jbSyntaxComment,
                number: .jbSyntaxNumber,
                plain: Color(hex: "D7E7F8")
            )
        case .ocean:
            return CodeSyntaxPalette(
                keyword: Color(hex: "7DD3FC"),
                string: Color(hex: "BAE6FD"),
                type: Color(hex: "5EEAD4"),
                method: Color(hex: "93C5FD"),
                comment: Color(hex: "7F9CB8"),
                number: Color(hex: "C4B5FD"),
                plain: Color(hex: "D7E7F8")
            )
        case .forest:
            return CodeSyntaxPalette(
                keyword: Color(hex: "86EFAC"),
                string: Color(hex: "A7F3D0"),
                type: Color(hex: "67E8F9"),
                method: Color(hex: "BFDBFE"),
                comment: Color(hex: "8EABC7"),
                number: Color(hex: "DDD6FE"),
                plain: Color(hex: "D7E7F8")
            )
        }
    }
}
