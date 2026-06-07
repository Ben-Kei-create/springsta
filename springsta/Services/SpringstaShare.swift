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

    static func answerHistoryCSV(_ records: [QuizAnswerRecord]) -> String {
        let formatter = ISO8601DateFormatter()
        var rows = ["id,answeredAt,level,category,quizId,tags,selectedChoiceId,correct,elapsedSeconds"]
        for record in records {
            let columns = [
                record.id.uuidString,
                formatter.string(from: record.answeredAt),
                record.level.rawValue,
                record.category,
                record.quizId,
                record.tags.joined(separator: ";"),
                record.selectedChoiceId,
                record.correct ? "1" : "0",
                record.elapsedSeconds.map(String.init) ?? ""
            ]
            rows.append(columns.map(csvField).joined(separator: ","))
        }
        return "\u{FEFF}" + rows.joined(separator: "\r\n")
    }

    static func writeAnswerHistoryCSVFile(_ records: [QuizAnswerRecord]) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("springsta-answer-history.csv")
        do {
            try answerHistoryCSV(records).write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    private static func csvField(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r") else {
            return value
        }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
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
