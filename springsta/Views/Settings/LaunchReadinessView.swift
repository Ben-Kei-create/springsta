#if DEBUG
import SwiftUI

struct LaunchReadinessView: View {
    private var snapshot: LaunchReadinessSnapshot {
        LaunchReadinessSnapshot()
    }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    summaryCard
                    contentMetrics
                    coverageCard
                    checklist
                    appStoreChecklist
                    marketingCopyCard
                }
                .padding(Spacing.md)
            }
        }
        .navigationTitle("販売準備")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        let ready = snapshot.isReadyForStoreReview
        return VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: ready ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(ready ? Color.jbSuccess : Color.jbWarning)
                Spacer()
                Text(ready ? "READY" : "CHECK")
                    .font(.system(size: 12, weight: .heavy).monospaced())
                    .foregroundStyle(ready ? Color.jbSuccess : Color.jbWarning)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill((ready ? Color.jbSuccess : Color.jbWarning).opacity(0.14)))
            }

            Text(ready ? "教材品質はリリース水準です" : "販売前に確認したい項目があります")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.jbText)

            Text("App Store審査に出す前の内部チェックです。通常リリースではこの画面は表示されません。")
                .font(.system(size: 13))
                .foregroundStyle(Color.jbSubtext)
                .lineSpacing(4)
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(ready ? Color.jbSuccess.opacity(0.35) : Color.jbWarning.opacity(0.35), lineWidth: 1)
                )
        )
    }

    private var contentMetrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
            LaunchReadinessMetric(title: "基礎通常", value: "\(snapshot.foundationPracticeCount)問", tint: Color.jbAccent)
            LaunchReadinessMetric(title: "実践通常", value: "\(snapshot.practicePracticeCount)問", tint: Color.jbAccent)
            LaunchReadinessMetric(title: "基礎演習候補", value: "\(snapshot.foundationExerciseCount)問", tint: snapshot.foundationExerciseCount >= 5 ? Color.jbSuccess : Color.jbWarning)
            LaunchReadinessMetric(title: "実践演習候補", value: "\(snapshot.practiceExerciseCount)問", tint: snapshot.practiceExerciseCount >= 5 ? Color.jbSuccess : Color.jbWarning)
            LaunchReadinessMetric(title: "用語", value: "\(snapshot.glossaryCount)件", tint: Color.jbSuccess)
            LaunchReadinessMetric(title: "レッスン", value: "\(snapshot.lessonCount)件", tint: Color.jbSuccess)
        }
    }

    private var checklist: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("リリース前チェック")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.jbText)
                .padding(.horizontal, Spacing.xs)

            VStack(spacing: 0) {
                LaunchReadinessCheckRow(
                    title: "汎用解説・紐付け",
                    detail: "汎用、欠落、重複ref、未使用解説",
                    value: "\(snapshot.explanationIssueCount)件",
                    isPassing: snapshot.explanationIssueCount == 0
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "内容品質監査",
                    detail: "重複コード、重複設計意図、重複選択肢など",
                    value: "\(snapshot.contentQualityIssueCount)件",
                    isPassing: snapshot.contentQualityIssueCount == 0
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "問題データ検証",
                    detail: "ID、正答数、カテゴリ、関連問題リンク",
                    value: "\(snapshot.validationIssueCount)件",
                    isPassing: snapshot.validationIssueCount == 0
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "出題範囲カバレッジ",
                    detail: "バージョン / トラックごとの学習範囲に通常問題があるか",
                    value: "\(snapshot.coverageIssueCount)件",
                    isPassing: snapshot.coverageIssueCount == 0
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "総合演習候補",
                    detail: "基礎 / 実践 それぞれ5問以上を目安",
                    value: "\(min(snapshot.foundationExerciseCount, snapshot.practiceExerciseCount))/5",
                    isPassing: snapshot.foundationExerciseCount >= 5 && snapshot.practiceExerciseCount >= 5
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(Color.jbBorder, lineWidth: 1)
            )
        }
    }

    private var coverageCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("出題範囲カバレッジ")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.jbText)
                Spacer()
                Text(snapshot.coverageIssueCount == 0 ? "ALL COVERED" : "\(snapshot.coverageIssueCount) OPEN")
                    .font(.system(size: 10, weight: .heavy).monospaced())
                    .foregroundStyle(snapshot.coverageIssueCount == 0 ? Color.jbSuccess : Color.jbWarning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill((snapshot.coverageIssueCount == 0 ? Color.jbSuccess : Color.jbWarning).opacity(0.12))
                    )
            }

            VStack(spacing: 0) {
                ForEach(Array(snapshot.coverageGroups.enumerated()), id: \.element.id) { index, group in
                    LaunchCoverageGroupRow(group: group)
                    if index < snapshot.coverageGroups.count - 1 {
                        Divider().background(Color.jbBorder).padding(.leading, Spacing.md)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(Color.jbBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - App Store submission checklist

    private var appStoreChecklist: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("App Store 申請チェック")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.jbText)
                .padding(.horizontal, Spacing.xs)

            VStack(spacing: 0) {
                LaunchReadinessCheckRow(
                    title: "PrivacyInfo.xcprivacy",
                    detail: "UserDefaults 使用理由 CA92.1 を宣言",
                    value: snapshot.hasPrivacyManifest ? "OK" : "MISSING",
                    isPassing: snapshot.hasPrivacyManifest
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "プライバシーポリシーURL",
                    detail: AppConfig.privacyPolicyURL.absoluteString,
                    value: snapshot.hasPrivacyPolicyURL ? "設定済" : "要設定",
                    isPassing: snapshot.hasPrivacyPolicyURL
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "サポートURL",
                    detail: AppConfig.supportURL.absoluteString,
                    value: snapshot.hasSupportURL ? "設定済" : "要設定",
                    isPassing: snapshot.hasSupportURL
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "App Store ID",
                    detail: "AppConfig.appStoreID をアップロード後に更新",
                    value: snapshot.hasRealAppStoreID ? "設定済" : "未設定",
                    isPassing: snapshot.hasRealAppStoreID
                )
                Divider().background(Color.jbBorder).padding(.horizontal, Spacing.md)
                LaunchReadinessCheckRow(
                    title: "AppIcon 画像",
                    detail: "1024×1024 png（アルファなし）が必須",
                    value: snapshot.hasAppIconImages ? "OK" : "要確認",
                    isPassing: snapshot.hasAppIconImages
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(Color.jbBorder, lineWidth: 1)
            )
        }
    }

    private var marketingCopyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("広告で押す軸")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.jbText)

            VStack(alignment: .leading, spacing: Spacing.sm) {
                LaunchCopyLine(icon: "curlybraces", text: "コードの流れを追って理解するSpring Boot学習")
                LaunchCopyLine(icon: "checklist.checked", text: "基礎 / 実践対応、通常練習と実務想定演習")
                LaunchCopyLine(icon: "doc.text.magnifyingglass", text: "汎用解説ではなく、各問題ごとの追跡解説")
                LaunchCopyLine(icon: "flag", text: "問題報告とフィードバック導線で品質改善を回せる")
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
    }
}

private struct LaunchReadinessSnapshot {
    let foundationPracticeCount: Int
    let practicePracticeCount: Int
    let foundationExerciseCount: Int
    let practiceExerciseCount: Int
    let glossaryCount: Int
    let lessonCount: Int
    let explanationIssueCount: Int
    let contentQualityIssueCount: Int
    let validationIssueCount: Int
    let coverageGroups: [LaunchReadinessCoverageGroup]

    // MARK: App Store submission readiness

    /// `PrivacyInfo.xcprivacy` exists in the app bundle (added to Xcode target).
    let hasPrivacyManifest: Bool
    /// `AppConfig.privacyPolicyURL` is a non-placeholder URL (not GitHub Pages stub).
    let hasPrivacyPolicyURL: Bool
    /// `AppConfig.supportURL` is a non-placeholder URL.
    let hasSupportURL: Bool
    /// `AppConfig.appStoreID` has been updated from the default placeholder "0000000000".
    let hasRealAppStoreID: Bool
    /// The AppIcon asset set contains image files (not just the JSON stub).
    let hasAppIconImages: Bool

    init() {
        let explanationReport = QuestionBank.explanationAuditReport()
        foundationPracticeCount = QuestionBank.quizzes(version: .boot3, level: .foundation).count
        practicePracticeCount = QuestionBank.quizzes(version: .boot3, level: .practice).count
        foundationExerciseCount = QuestionBank.mockExamEligibleCount(version: .boot3, level: .foundation)
        practiceExerciseCount = QuestionBank.mockExamEligibleCount(version: .boot3, level: .practice)
        glossaryCount = GlossaryTerm.samples.count
        lessonCount = Lesson.samples.count
        explanationIssueCount = explanationReport.needsAttentionCount
        contentQualityIssueCount = QuestionBank.contentQualityIssues().count
        validationIssueCount = QuestionBank.validationIssues().count
        coverageGroups = SpringBootVersion.allCases.flatMap { version in
            SpringTrack.allCases.compactMap { level in
                let objectives = QuestionBank.coverage(version: version, level: level)
                guard !objectives.isEmpty else { return nil }
                let items = objectives.map {
                    LaunchReadinessObjectiveCoverage(
                        objective: $0.objective,
                        count: $0.count
                    )
                }
                return LaunchReadinessCoverageGroup(
                    version: version,
                    level: level,
                    practiceCount: QuestionBank.quizzes(version: version, level: level).count,
                    objectives: items
                )
            }
        }

        // App Store submission checks
        hasPrivacyManifest = Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy") != nil
        hasPrivacyPolicyURL = AppConfig.privacyPolicyURL.host != nil
        hasSupportURL = AppConfig.supportURL.host != nil
        hasRealAppStoreID = AppConfig.appStoreID != "0000000000"
        // Check whether the AppIcon asset set carries real PNG images (not just Contents.json)
        hasAppIconImages = {
            let fm = FileManager.default
            guard let resourceURL = Bundle.main.resourceURL else { return false }
            let iconPath = resourceURL.appendingPathComponent("Assets.car")
            if fm.fileExists(atPath: iconPath.path) { return true }
            // Fallback: look for any .png named "AppIcon" in the bundle
            let pngs = (try? fm.contentsOfDirectory(atPath: resourceURL.path)) ?? []
            return pngs.contains { $0.hasPrefix("AppIcon") && $0.hasSuffix(".png") }
        }()
    }

    var isReadyForStoreReview: Bool {
        explanationIssueCount == 0 &&
        contentQualityIssueCount == 0 &&
        validationIssueCount == 0 &&
        coverageIssueCount == 0 &&
        foundationPracticeCount >= 5 &&
        practicePracticeCount >= 5 &&
        foundationExerciseCount >= 5 &&
        practiceExerciseCount >= 5 &&
        hasPrivacyManifest &&
        hasPrivacyPolicyURL &&
        hasSupportURL &&
        hasRealAppStoreID &&
        hasAppIconImages
    }

    var coverageIssueCount: Int {
        coverageGroups.reduce(0) { $0 + $1.uncoveredCount }
    }
}

private struct LaunchReadinessCoverageGroup: Identifiable {
    let version: SpringBootVersion
    let level: SpringTrack
    let practiceCount: Int
    let objectives: [LaunchReadinessObjectiveCoverage]

    var id: String {
        "\(version.rawValue)-\(level.rawValue)"
    }

    var title: String {
        "\(version.displayName) / \(level.displayName)"
    }

    var coveredCount: Int {
        objectives.filter { $0.count > 0 }.count
    }

    var totalObjectiveCount: Int {
        objectives.count
    }

    var uncoveredCount: Int {
        totalObjectiveCount - coveredCount
    }

    var minimumCount: Int {
        objectives.map(\.count).min() ?? 0
    }

    var progress: Double {
        guard totalObjectiveCount > 0 else { return 0 }
        return Double(coveredCount) / Double(totalObjectiveCount)
    }

    var uncoveredTitles: String {
        objectives
            .filter { $0.count == 0 }
            .map { $0.objective.title }
            .prefix(2)
            .joined(separator: "、")
    }
}

private struct LaunchReadinessObjectiveCoverage: Identifiable {
    let objective: ExamObjective
    let count: Int

    var id: String {
        objective.id
    }
}

private struct LaunchReadinessMetric: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold).monospacedDigit())
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.jbSubtext)
                .lineLimit(1)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.md)
                .fill(Color.jbCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(Color.jbBorder, lineWidth: 1)
                )
        )
    }
}

private struct LaunchCoverageGroupRow: View {
    let group: LaunchReadinessCoverageGroup

    private var isPassing: Bool {
        group.uncoveredCount == 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.jbText)
                    Text("\(group.practiceCount)問 / 最少 \(group.minimumCount)問")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.jbSubtext)
                }

                Spacer(minLength: Spacing.sm)

                Text("\(group.coveredCount)/\(group.totalObjectiveCount)")
                    .font(.system(size: 14, weight: .bold).monospacedDigit())
                    .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
            }

            ProgressView(value: group.progress)
                .tint(isPassing ? Color.jbSuccess : Color.jbWarning)
                .scaleEffect(x: 1, y: 1.2)

            if !isPassing {
                Text("未カバー: \(group.uncoveredTitles)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbWarning)
                    .lineLimit(2)
            }
        }
        .padding(Spacing.md)
        .background(Color.jbCard)
    }
}

private struct LaunchReadinessCheckRow: View {
    let title: String
    let detail: String
    let value: String
    let isPassing: Bool

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: isPassing ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.jbText)
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.jbSubtext)
                    .lineLimit(2)
            }

            Spacer(minLength: Spacing.sm)

            Text(value)
                .font(.system(size: 13, weight: .bold).monospacedDigit())
                .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
        .background(Color.jbCard)
    }
}

private struct LaunchCopyLine: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.jbAccent)
                .frame(width: 22)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color.jbText)
                .lineSpacing(3)
        }
    }
}

#Preview {
    NavigationStack {
        LaunchReadinessView()
    }
}
#endif
