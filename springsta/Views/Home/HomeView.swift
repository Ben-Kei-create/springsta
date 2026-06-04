import StoreKit
import SwiftUI

struct HomeView: View {
    @State private var activeSession: QuizSession?
    @State private var progress = ProgressStore.shared
    @State private var purchase = PurchaseManager.shared
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var showEmptySessionAlert = false
    @State private var emptySessionMessage = ""
    @State private var expandedMetric: HomeMetric = .accuracy
    @AppStorage("selectedSpringBootVersion") private var selectedSpringBootVersionRaw = SpringBootVersion.boot3.rawValue
    @AppStorage("selectedSpringTrack") private var selectedLevelRaw = SpringTrack.foundation.rawValue

    private var selectedVersion: SpringBootVersion {
        .boot3
    }

    private var selectedLevel: SpringTrack {
        SpringTrack(rawValue: selectedLevelRaw) ?? .foundation
    }

    private var reviewQueueQuizzes: [Quiz] {
        var seen = Set<String>()
        return progress.reviewQueueQuizIds.compactMap { id in
            guard seen.insert(id).inserted else { return nil }
            return QuestionBank.quiz(id: id)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            headerSection

                            ForEach(visibleSectionOrder, id: \.self) { sectionId in
                                sectionContent(for: sectionId)
                                    .padding(.vertical, 2)
                                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                            }

                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                        }
                        .padding(.bottom, Spacing.lg)
                    }

                    if !purchase.effectiveIsPremium {
                        AdBannerView()
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .sheet(item: $activeSession) { session in
            QuizSheetView(session: session)
        }
        .sheet(isPresented: $showPaywall) {
            PremiumPaywallView()
        }
        .alert("開始できません", isPresented: $showEmptySessionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(emptySessionMessage)
        }
        .onAppear {
            selectedSpringBootVersionRaw = SpringBootVersion.boot3.rawValue
        }
    }

    // MARK: Header

    private var headerSection: some View {
        HStack(alignment: .center, spacing: Spacing.sm) {
            Text("Springsta")
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundStyle(Color.jbText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: Spacing.xs)

            HomeTimestampToggle()
                .layoutPriority(1)
                .offset(y: -1)

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("home-settings")
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    // MARK: Command center

    private var commandCenter: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(alignment: .top, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedLevel.displayName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.jbText)
                    Text("\(selectedVersion.displayName) / \(selectedLevel.displayName)トラック")
                        .font(.system(size: 11, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbAccent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                        .allowsTightening(true)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.jbAccent.opacity(0.12)))
                        .layoutPriority(1)
                }

                Spacer()

                TodayStudyCounterView(
                    answered: progress.todayAnswered,
                    dailyGoal: progress.dailyGoal
                )
            }

            levelPicker

            HStack(spacing: Spacing.sm) {
                CommandMetric(
                    title: "正答率",
                    value: progress.answerAttemptCount(level: selectedLevel) > 0 ? "\(progress.levelAccuracyPercent(selectedLevel))%" : "—",
                    icon: "chart.line.uptrend.xyaxis",
                    color: accuracyColor,
                    isSelected: expandedMetric == .accuracy,
                    onTap: { toggleMetric(.accuracy) }
                )
                CommandMetric(
                    title: "連続",
                    value: "\(progress.streakDays)日",
                    icon: "flame.fill",
                    color: Color.jbWarning,
                    isSelected: expandedMetric == .streak,
                    onTap: { toggleMetric(.streak) }
                )
                CommandMetric(
                    title: "解答済み",
                    value: "\(progress.answeredCount(level: selectedLevel))問",
                    icon: "checkmark.seal.fill",
                    color: Color.jbSuccess,
                    isSelected: expandedMetric == .answered,
                    onTap: { toggleMetric(.answered) }
                )
            }

            MetricDetailTray(
                title: expandedMetric.detailTitle,
                items: metricDetails(for: expandedMetric)
            )
            .id(expandedMetric)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.18), value: expandedMetric)
        }
        .padding(Spacing.sm)
        .jbCard()
        .padding(.horizontal, Spacing.md)
    }

    private var reviewQueueSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SectionHeader(
                icon: "arrow.counterclockwise",
                title: "復習",
                tint: Color.jbWarning,
                subtitle: "\(reviewQueueQuizzes.count)問"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(reviewQueueQuizzes) { quiz in
                        ReviewQueueCard(quiz: quiz, onTap: { activeSession = QuizSession.single(quiz) })
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 2)
            }
        }
    }

    private var levelPicker: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(SpringTrack.allCases, id: \.self) { level in
                Button(action: {
                    if purchase.canAccess(level: level) {
                        withAnimation(.jbSpring) { selectedLevelRaw = level.rawValue }
                    } else {
                        showPaywall = true
                    }
                }) {
                    Text(level.displayName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(selectedLevel == level ? .white : Color.jbSubtext)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.sm)
                                .fill(selectedLevel == level ? Color.jbAccent : Color.jbBackground)
                        )
                }
                .buttonStyle(.jbScaled)
                .sensoryFeedback(.selection, trigger: selectedLevelRaw)
                .accessibilityIdentifier("home-level-\(level.rawValue)")
            }
        }
    }

    // MARK: Practice modes

    private var practiceModesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SectionHeader(icon: "play.fill", title: "練習を開始", tint: Color.jbAccent)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(QuizPracticeMode.homeModes) { mode in
                        PracticeModeCard(
                            mode: mode,
                            isPrimary: mode == .daily,
                            onTap: { start(mode) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 2)
            }
        }
    }

    private func start(_ mode: QuizPracticeMode) {
        if mode == .mockExam && !purchase.canAccessMockExam {
            showPaywall = true
            return
        }
        if let session = QuestionBank.makeSession(
            mode: mode,
            version: selectedVersion,
            level: selectedLevel,
            progress: progress
        ) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            activeSession = session
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            emptySessionMessage = "\(selectedLevel.displayName) の問題がまだありません。"
            showEmptySessionAlert = true
        }
    }

    private func toggleMetric(_ metric: HomeMetric) {
        withAnimation(.jbFast) {
            expandedMetric = metric
        }
    }

    private func metricDetails(for metric: HomeMetric) -> [MetricDetailItem] {
        let levelRecords = progress.answerHistory.filter { $0.level == selectedLevel }
        let levelCorrect = levelRecords.filter(\.correct).count
        let levelQuizCount = QuestionBank.quizzes(version: selectedVersion, level: selectedLevel).count
        let weakestObjective = progress.weakestObjective(version: selectedVersion, level: selectedLevel)
        let weakestObjectiveText = weakestObjective.map { summary in
            let rawTitle = summary.displayTitle
            let title = rawTitle.count > 8 ? String(rawTitle.prefix(8)) + "..." : rawTitle
            return "\(title) \(summary.accuracyPercent)%"
        } ?? "—"

        switch metric {
        case .accuracy:
            return [
                MetricDetailItem(label: "総回答数", value: "\(progress.totalAnswered)回"),
                MetricDetailItem(label: "総正解数", value: "\(progress.totalCorrect)回"),
                MetricDetailItem(label: selectedLevel.displayName, value: "\(levelCorrect)/\(levelRecords.count)"),
                MetricDetailItem(
                    label: "弱点範囲",
                    value: weakestObjectiveText
                )
            ]
        case .streak:
            return [
                MetricDetailItem(label: "今日", value: "\(progress.todayAnswered)/\(progress.dailyGoal)問"),
                MetricDetailItem(label: "復習", value: "\(reviewQueueQuizzes.count)問"),
                MetricDetailItem(label: "完了レッスン", value: "\(progress.completedLessons.count)件")
            ]
        case .answered:
            return [
                MetricDetailItem(label: "このトラック", value: "\(progress.answeredCount(level: selectedLevel))/\(levelQuizCount)問"),
                MetricDetailItem(label: "全体", value: "\(progress.answeredCount())問"),
                MetricDetailItem(label: "保存", value: "\(progress.bookmarkedQuizIds.count)問")
            ]
        }
    }

    // MARK: Home sections

    private var visibleSectionOrder: [HomeSectionID] {
        HomeSectionID.fixedOrder
    }

    @ViewBuilder
    private func sectionContent(for id: HomeSectionID) -> some View {
        switch id {
        case .commandCenter:
            commandCenter
        case .categoryProgress:
            categoryProgressSection
        case .heatmap:
            ActivityHeatmapView(
                counts: progress.recentDailyCounts(days: ProgressStore.historyWindowDays)
            )
        case .practiceModes:
            practiceModesSection
        case .levelSection:
            LevelSectionView(
                level: selectedLevel,
                version: selectedVersion,
                quizzes: QuestionBank.quizzes(version: selectedVersion, level: selectedLevel),
                onSelect: { activeSession = QuizSession.single($0) },
                onStartSession: { activeSession = $0 }
            )
            .id(selectedLevel)
            .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
    }

    private struct CategoryStat {
        let category: QuizCategory
        let answered: Int
        let total: Int
        var progress: Double { total > 0 ? min(1.0, Double(answered) / Double(total)) : 0 }
    }

    private func computeCategoryStats() -> [CategoryStat] {
        let allQuizzes = QuestionBank.quizzes(version: selectedVersion, level: selectedLevel)
        let byCategory = Dictionary(grouping: allQuizzes) { $0.category }
        var answeredByCategory: [String: Set<String>] = [:]
        for record in progress.answerHistory where record.level == selectedLevel {
            answeredByCategory[record.category, default: []].insert(record.quizId)
        }
        return QuizCategory.allCases.compactMap { cat in
            guard let quizzes = byCategory[cat], !quizzes.isEmpty else { return nil }
            let answered = answeredByCategory[cat.rawValue]?.count ?? 0
            return CategoryStat(category: cat, answered: answered, total: quizzes.count)
        }
    }

    private var categoryProgressSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            SectionHeader(icon: "square.grid.2x2", title: "カテゴリ別進捗", tint: Color.jbAccent,
                          subtitle: "タップで即練習")
            let stats = computeCategoryStats()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(stats, id: \.category.rawValue) { stat in
                        CategoryProgressChip(stat: stat, onTap: { startCategorySession(stat) })
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 2)
            }
        }
    }

    private func startCategorySession(_ stat: CategoryStat) {
        let pool = QuestionBank.quizzes(version: selectedVersion, level: selectedLevel)
            .filter { $0.canonicalCategory == stat.category }
        guard !pool.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        activeSession = QuizSession(
            mode: .daily,
            level: selectedLevel,
            version: selectedVersion,
            quizzes: pool.shuffled().prefix(min(10, pool.count)).map { $0 },
            customTitle: "\(stat.category.displayName) 練習"
        )
    }

    private var accuracyColor: Color {
        guard progress.answerAttemptCount(level: selectedLevel) > 0 else { return Color.jbSubtext }
        let p = progress.levelAccuracyPercent(selectedLevel)
        if p >= 70 { return Color.jbSuccess }
        if p >= 40 { return Color.jbWarning }
        return Color.jbError
    }
}

// MARK: - SectionHeader

/// ホーム画面内の各セクションに共通スタイルのヘッダーを提供する。
/// アイコン・タイトル・サブテキストを一行で表示し、
/// 視覚的な一貫性とアクセシビリティを両立する。
private struct SectionHeader: View {
    let icon: String
    let title: String
    let tint: Color
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint)
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.jbText)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - CategoryProgressChip

private struct CategoryProgressChip: View {
    let stat: HomeView.CategoryStat
    let onTap: () -> Void

    private var progressColor: Color {
        if stat.progress >= 0.8 { return Color.jbSuccess }
        if stat.progress >= 0.4 { return Color.jbAccent }
        return Color.jbSubtext
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 3) {
                    Text(stat.category.displayName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.jbText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer(minLength: 0)
                    Image(systemName: "play.fill")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(progressColor.opacity(0.7))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.jbBorder)
                            .frame(height: 3)
                        Capsule()
                            .fill(progressColor)
                            .frame(width: geo.size.width * stat.progress, height: 3)
                            .animation(.jbSmooth, value: stat.progress)
                    }
                }
                .frame(height: 3)

                Text("\(stat.answered)/\(stat.total)問")
                    .font(.system(size: 10).monospacedDigit())
                    .foregroundStyle(Color.jbSubtext)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(width: 108)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(stat.progress > 0 ? progressColor.opacity(0.45) : Color.jbBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(JBScaledButtonStyle(scaleAmount: 0.95))
    }
}

// MARK: - HomeSectionID

enum HomeSectionID: String, CaseIterable, Hashable {
    case commandCenter
    case categoryProgress
    case heatmap
    case practiceModes
    case levelSection

    static let fixedOrder: [HomeSectionID] = [
        .commandCenter,
        .categoryProgress,
        .heatmap,
        .practiceModes,
        .levelSection
    ]

    var displayTitle: String {
        switch self {
        case .commandCenter: return "ステータス"
        case .categoryProgress: return "カテゴリ別進捗"
        case .heatmap: return "学習マップ"
        case .practiceModes: return "練習を開始"
        case .levelSection: return "問題リスト"
        }
    }
}

// MARK: - HomeMetric

private enum HomeMetric: String, Identifiable {
    case accuracy
    case streak
    case answered

    var id: String { rawValue }

    var detailTitle: String {
        switch self {
        case .accuracy: return "回答の内訳"
        case .streak: return "今日の状態"
        case .answered: return "進捗の内訳"
        }
    }
}

private struct MetricDetailItem: Identifiable {
    let label: String
    let value: String

    var id: String { label }
}

// MARK: - HomeTimestampToggle

private struct HomeTimestampToggle: View {
    @AppStorage("homeTimestampVisible") private var isTimestampVisible = true
    @AppStorage("examDateTimestamp") private var examDateTimestamp: Double = 0

    private var examDate: Date? {
        examDateTimestamp > 0 ? Date(timeIntervalSince1970: examDateTimestamp) : nil
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let isExamToday = Self.isSameDay(examDate, timeline.date)
            let hasExam = examDate != nil && (examDate! > timeline.date) && !isExamToday
            let displayText: String = {
                if isExamToday { return "今日の目標日です！" }
                if hasExam { return Self.countdown(from: timeline.date, to: examDate!) }
                return Self.timestamp(timeline.date)
            }()
            Button(action: {
                withAnimation(.jbFast) {
                    isTimestampVisible.toggle()
                }
            }) {
                Group {
                    if isTimestampVisible {
                        Text(displayText)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .foregroundStyle(isExamToday ? Color.jbError : (hasExam ? Color.jbError : Color.jbSubtext))
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                    } else {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
                .frame(height: 22)
                .frame(
                    minWidth: isTimestampVisible ? 126 : 22,
                    maxWidth: isTimestampVisible ? 170 : 22,
                    alignment: .trailing
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isTimestampVisible ? "日時を隠す" : "日時を表示")
        }
    }

    private static func timestamp(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        return String(
            format: "%04d年%02d月%02d日 %02d:%02d:%02d",
            parts.year ?? 0,
            parts.month ?? 0,
            parts.day ?? 0,
            parts.hour ?? 0,
            parts.minute ?? 0,
            parts.second ?? 0
        )
    }

    private static func isSameDay(_ a: Date?, _ b: Date) -> Bool {
        guard let a else { return false }
        return Calendar.current.isDate(a, inSameDayAs: b)
    }

    private static func countdown(_ now: Date = Date(), to exam: Date) -> String {
        countdown(from: now, to: exam)
    }

    private static func countdown(from now: Date, to exam: Date) -> String {
        let diff = max(0, exam.timeIntervalSince(now))
        let days = Int(diff) / 86400
        let hours = (Int(diff) % 86400) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let seconds = Int(diff) % 60
        return String(format: "目標日まで %d日 %02d:%02d:%02d", days, hours, minutes, seconds)
    }
}

// MARK: - TodayStudyCounterView

private struct TodayStudyCounterView: View {
    let answered: Int
    let dailyGoal: Int

    private var reachedGoal: Bool { answered >= dailyGoal }
    private var ringProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(1.0, Double(answered) / Double(dailyGoal))
    }
    private var activeColor: Color { reachedGoal ? Color.jbSuccess : Color.jbAccent }

    private let ringSize: CGFloat = 54
    private let lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            // トラック（背景リング）
            Circle()
                .stroke(Color.jbBorder, lineWidth: lineWidth)
                .frame(width: ringSize, height: ringSize)

            // 進捗リング
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    activeColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.jbSmooth, value: ringProgress)

            // 中央のテキスト
            VStack(spacing: 0) {
                Text("\(answered)")
                    .font(.system(size: 16, weight: .bold).monospacedDigit())
                    .foregroundStyle(activeColor)
                Text("/\(dailyGoal)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
            }
        }
        .accessibilityLabel("今日の達成: \(answered)問 / 目標\(dailyGoal)問")
        .accessibilityValue(reachedGoal ? "達成済み" : "\(Int(ringProgress * 100))%")
    }
}

// MARK: - MetricDetailTray

private struct MetricDetailTray: View {
    let title: String
    let items: [MetricDetailItem]

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.jbSubtext)
                .frame(width: 64, alignment: .leading)

            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.value)
                        .font(.system(size: 13, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.jbText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(item.label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.jbSubtext)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 7)
        .jbCard(radius: Radius.sm, fill: Color.jbBackground)
    }
}

// MARK: - CommandMetric

private struct CommandMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(isSelected ? color : color.opacity(0.7))
                Text(value)
                    .font(.system(size: 16, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.jbText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.jbSubtext)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(isSelected ? color.opacity(0.1) : Color.jbBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(isSelected ? color.opacity(0.8) : Color.jbBorder, lineWidth: isSelected ? 1.5 : 1)
                    )
            )
            .animation(.jbFast, value: isSelected)
        }
        .buttonStyle(.jbScaled)
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - PracticeModeCard

private struct PracticeModeCard: View {
    let mode: QuizPracticeMode
    let isPrimary: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: mode.icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isPrimary ? .white : Color.jbAccent)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle().fill(isPrimary ? Color.white.opacity(0.18) : Color.jbAccent.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(isPrimary ? .white : Color.jbText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(mode.subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(isPrimary ? .white.opacity(0.76) : Color.jbSubtext)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: Spacing.xs)

                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isPrimary ? .white.opacity(0.8) : Color.jbSubtext)
            }
            .padding(Spacing.sm)
            .frame(width: 200, height: 74, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(isPrimary ? Color.jbAccent : Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(isPrimary ? Color.jbAccent : Color.jbBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.jbScaled)
        .accessibilityIdentifier("home-practice-\(mode.rawValue)")
    }
}

// MARK: - LevelSectionView

struct LevelSectionView: View {
    let level: SpringTrack
    let version: SpringBootVersion
    let quizzes: [Quiz]
    let onSelect: (Quiz) -> Void
    let onStartSession: (QuizSession) -> Void

    private let previewCount = 5

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(quizzes.prefix(previewCount)) { quiz in
                        QuizCardView(quiz: quiz, onTap: { onSelect(quiz) })
                    }
                    NavigationLink {
                        AllQuizzesView(
                            level: level,
                            version: version,
                            onSelect: onSelect,
                            onStartSession: onStartSession
                        )
                    } label: {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.jbAccent)
                            Text("すべて見る")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.jbAccent)
                        }
                        .frame(width: 80, height: 118)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.md)
                                .fill(Color.jbCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.md)
                                        .stroke(Color.jbAccent.opacity(0.35), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - QuizCardView

struct QuizCardView: View {
    let quiz: Quiz
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text(quiz.categoryDisplayName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.jbAccent)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.jbSubtext)
                }

                Text(quiz.question)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.jbText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                HStack(spacing: 4) {
                    ForEach(quiz.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.jbSubtext)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.jbBackground))
                    }
                }
            }
            .padding(Spacing.md)
            .frame(width: 210, height: 118)
            .jbCard()
        }
        .buttonStyle(.jbScaled)
    }
}

// MARK: - ReviewQueueCard

private struct ReviewQueueCard: View {
    let quiz: Quiz
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.jbWarning)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.jbWarning.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(quiz.categoryDisplayName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.jbWarning)
                        .lineLimit(1)
                    Text(quiz.question)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.jbText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.jbSubtext)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, 7)
            .frame(width: 176, height: 50)
            .background(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.jbWarning.opacity(0.32), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.jbScaled)
    }
}

// MARK: - QuizSheetView

struct QuizSheetView: View {
    @State private var session: QuizSession
    @State private var currentQuiz: Quiz
    @State private var quizVM: QuizViewModel
    @State private var currentIndex: Int
    @State private var scoredQuizIds: Set<String> = []
    @State private var correctCount = 0
    @State private var showSessionResult = false
    @State private var activeExplanation: Explanation?
    @State private var glossaryRoot: GlossaryRoot? = nil
    @State private var glossaryPath: [String] = []
    @State private var consecutiveCorrect = 0
    @State private var showStreakBanner = false
    @AppStorage("codeZoom") private var codeZoom: Double = CodeZoom.default
    @Environment(\.dismiss) private var dismiss

    private struct GlossaryRoot: Identifiable, Hashable {
        let id: String
    }

    init(quiz: Quiz) {
        self.init(session: QuizSession.single(quiz))
    }

    init(session: QuizSession) {
        let firstQuiz = session.quizzes.first ?? Quiz.samples.first!
        self._session = State(initialValue: session)
        self._currentQuiz = State(initialValue: firstQuiz)
        self._quizVM = State(wrappedValue: QuizViewModel(quiz: firstQuiz))
        self._currentIndex = State(initialValue: 0)
    }

    var body: some View {
        Group {
            if session.mode == .mockExam {
                MockExamView(session: session)
            } else {
                NavigationStack {
                    if showSessionResult {
                        QuizSessionResultView(
                            session: session,
                            correctCount: correctCount,
                            onClose: { dismiss() }
                        )
                    } else {
                        QuizView(
                            vm: quizVM,
                            codeZoom: codeZoom,
                            isLastQuiz: isLastQuiz,
                            onShowExplanation: {
                                activeExplanation = Explanation.sample(for: currentQuiz.explanationRef)
                            },
                            onNextQuiz: { goToNextQuiz() },
                            nextButtonTitle: isLastQuiz ? "完了" : "次の問題"
                        )
                        .id(currentQuiz.id)
                        .navigationTitle(session.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("閉じる") { dismiss() }
                                    .foregroundStyle(Color.jbSubtext)
                            }
                            ToolbarItem(placement: .principal) {
                                VStack(spacing: 1) {
                                    Text(session.title)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.jbText)
                                    Text("\(currentIndex + 1) / \(session.quizzes.count) ・ \(currentQuiz.categoryDisplayName)")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(Color.jbSubtext)
                                }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                LevelBadgeView(
                                    level: currentQuiz.level,
                                    zoomPercent: CodeZoom.percent(codeZoom),
                                    onTap: { codeZoom = CodeZoom.next(after: codeZoom) }
                                )
                            }
                        }
                        .sensoryFeedback(.selection, trigger: codeZoom)
                    }
                }
            }
        }
        .environment(\.openURL, OpenURLAction { url in
            if let id = GlossaryTerm.parse(url: url) {
                glossaryRoot = GlossaryRoot(id: id)
                return .handled
            }
            return .systemAction
        })
        .sheet(item: $glossaryRoot, onDismiss: { glossaryPath.removeAll() }) { root in
            glossarySheet(rootId: root.id)
        }
        .fullScreenCover(item: $activeExplanation) { explanation in
            ExplanationView(explanation: explanation, level: currentQuiz.level, onDismiss: { activeExplanation = nil })
        }
        .onChange(of: quizVM.isAnswered) { _, isAnswered in
            guard isAnswered, session.mode != .mockExam else { return }
            updateStreak(correct: quizVM.isCorrect)
        }
        .overlay(alignment: .top) {
            if showStreakBanner {
                QuizStreakBanner(count: consecutiveCorrect)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showStreakBanner)
    }

    private func updateStreak(correct: Bool) {
        if correct {
            consecutiveCorrect += 1
            let milestones = [3, 5, 7, 10]
            if milestones.contains(consecutiveCorrect) {
                showStreakBanner = true
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(1.8))
                    showStreakBanner = false
                }
            }
        } else {
            consecutiveCorrect = 0
        }
    }

    @ViewBuilder
    private func glossarySheet(rootId: String) -> some View {
        if let term = GlossaryTerm.lookup(rootId) {
            let origin = GlossaryDetailView.Origin(
                icon: "pencil.and.list.clipboard",
                label: currentQuiz.categoryDisplayName,
                action: { glossaryRoot = nil }
            )
            NavigationStack(path: $glossaryPath) {
                GlossaryDetailView(term: term, origin: origin)
                    .navigationDestination(for: String.self) { id in
                        if let next = GlossaryTerm.lookup(id) {
                            GlossaryDetailView(term: next, origin: origin)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("閉じる") { glossaryRoot = nil }
                                .foregroundStyle(Color.jbSubtext)
                        }
                    }
            }
            .environment(\.openURL, OpenURLAction { url in
                if let id = GlossaryTerm.parse(url: url) {
                    glossaryPath.append(id)
                    return .handled
                }
                return .systemAction
            })
        }
    }

    private var isLastQuiz: Bool {
        currentIndex >= session.quizzes.count - 1
    }

    private func goToNextQuiz() {
        captureCurrentScore()
        guard !isLastQuiz else {
            // MockExamView は内部で結果を管理するため、ここには到達しない。
            // それ以外で複数問セッションが終わったときは結果画面を表示する。
            // 単問チャレンジ（quizzes.count == 1）はそのまま閉じる。
            if session.quizzes.count > 1 {
                withAnimation(.jbSmooth) {
                    showSessionResult = true
                }
            } else {
                dismiss()
            }
            return
        }
        let nextIndex = currentIndex + 1
        let next = session.quizzes[nextIndex]
        currentIndex = nextIndex
        currentQuiz = next
        quizVM = QuizViewModel(quiz: next)
    }

    private func captureCurrentScore() {
        guard !scoredQuizIds.contains(currentQuiz.id), quizVM.isAnswered else { return }
        scoredQuizIds.insert(currentQuiz.id)
        if quizVM.isCorrect {
            correctCount += 1
        }
    }
}

// MARK: - QuizSessionResultView

private struct QuizSessionResultView: View {
    let session: QuizSession
    let correctCount: Int
    let onClose: () -> Void

    private var totalCount: Int { max(session.quizzes.count, 1) }
    private var scorePercent: Int {
        Int((Double(correctCount) / Double(totalCount) * 100).rounded())
    }
    private var isPassing: Bool { scorePercent >= 70 }

    var body: some View {
        ZStack {
            Color.jbBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Spacing.lg) {
                Spacer(minLength: Spacing.lg)

                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Image(systemName: isPassing ? "checkmark.seal.fill" : "chart.bar.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
                        Spacer()
                        LevelBadgeView(level: session.level)
                    }

                    Text(isPassing ? "理解度チェックをクリア" : "もう少しでクリア")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.jbText)

                    Text("\(session.version.examCode(for: session.level)) の目安として 70% 以上をクリアラインにしています。")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.jbSubtext)
                        .lineSpacing(4)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(scorePercent)")
                            .font(.system(size: 54, weight: .heavy).monospacedDigit())
                            .foregroundStyle(isPassing ? Color.jbSuccess : Color.jbWarning)
                        Text("%")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.jbSubtext)
                    }

                    HStack(spacing: Spacing.sm) {
                        ResultMetric(title: "正解", value: "\(correctCount)問", color: Color.jbSuccess)
                        ResultMetric(title: "出題", value: "\(session.quizzes.count)問", color: Color.jbAccent)
                        ResultMetric(title: "基準", value: "70%", color: Color.jbWarning)
                    }
                }
                .padding(Spacing.lg)
                .jbCard(
                    radius: Radius.xl,
                    border: isPassing ? Color.jbSuccess.opacity(0.35) : Color.jbWarning.opacity(0.35),
                    borderWidth: 1.5
                )

                ShareLink(
                    item: SpringstaShare.practiceResult(
                        level: session.level,
                        version: session.version,
                        title: session.title,
                        correctCount: correctCount,
                        totalCount: session.quizzes.count,
                        scorePercent: scorePercent
                    )
                ) {
                    Label("結果を共有", systemImage: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.jbText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .jbCard()
                }
                .buttonStyle(.plain)

                Button(action: onClose) {
                    HStack {
                        Text("閉じる")
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(isPassing ? Color.jbSuccess : Color.jbAccent)
                    )
                }

                Spacer(minLength: Spacing.xl)
            }
            .padding(Spacing.md)
        }
        .navigationBarBackButtonHidden(true)
    }
}

private struct ResultMetric: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold).monospacedDigit())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
        }
        .padding(Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .jbCard(radius: Radius.sm, fill: Color.jbBackground)
    }
}

// MARK: - AdBannerView

struct AdBannerView: View {
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "megaphone.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.jbSubtext)
            Text("広告スペース（テスト用）")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.jbSubtext)
            Spacer()
            Text("AD")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.jbSubtext.opacity(0.5)))
        }
        .padding(.horizontal, Spacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Color.jbCard)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.jbBorder),
            alignment: .top
        )
    }
}

// MARK: - QuizStreakBanner

private struct QuizStreakBanner: View {
    let count: Int

    private var message: String {
        switch count {
        case 10...: return "🔥 \(count)問連続正解！完璧！"
        case 7...: return "🔥 \(count)問連続正解！"
        case 5...: return "🔥 \(count)問連続正解！"
        default:   return "🔥 \(count)問連続正解！"
        }
    }

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Color.jbText)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(Color.jbWarning.opacity(0.14))
                    .overlay(Capsule().stroke(Color.jbWarning.opacity(0.5), lineWidth: 1.5))
            )
            .shadow(color: Color.jbWarning.opacity(0.12), radius: 8, y: 4)
    }
}
