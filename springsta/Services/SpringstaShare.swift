import Foundation

enum SpringstaShare {
    static let appInviteText: String = """
SpringstaでSpring Boot 3.xを学習中。
単一コードの動きから、Controller→Service→Repositoryを跨ぐ値の流れまで練習できます。
\(AppConfig.appStoreURL.absoluteString)
"""

    static func practiceResult(
        level: SpringTrack,
        version: SpringBootVersion,
        title: String,
        correctCount: Int,
        totalCount: Int,
        scorePercent: Int
    ) -> String {
        """
Springstaで\(level.displayName)トラックを学習。
\(version.examCode(for: level)) / \(title)
結果: \(correctCount)/\(totalCount)問 正解（\(scorePercent)%）
"""
    }

    static func mockExamResult(
        level: SpringTrack,
        version: SpringBootVersion,
        variant: MockExamVariant,
        correctCount: Int,
        totalCount: Int,
        scorePercent: Int,
        isPassing: Bool
    ) -> String {
        """
Springstaで\(level.displayName)の\(variant.displayName)を実施。
\(version.examCode(for: level))
結果: \(correctCount)/\(totalCount)問 正解（\(scorePercent)%）
\(isPassing ? "理解度チェックをクリア" : "理解度チェックまであと少し")
"""
    }
}
