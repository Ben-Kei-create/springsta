import StoreKit
import SwiftUI

struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchase = PurchaseManager.shared
    @State private var trialSession: QuizSession?

    private let freeFeatures: [(icon: String, title: String)] = [
        ("checkmark.circle.fill", "基礎トラック全問（200問以上）"),
        ("checkmark.circle.fill", "カテゴリ別進捗・ヒートマップ"),
        ("checkmark.circle.fill", "コード全画面・ファイル横断トレース"),
        ("checkmark.circle.fill", "ブックマーク・復習キュー"),
    ]

    private let premiumFeatures: [(icon: String, color: Color, title: String, body: String)] = [
        ("star.fill",           Color.jbAccent,     "実践トラック",  "設計・Security・運用まで300問以上"),
        ("graduationcap.fill",  Color.jbAccentDeep, "総合演習",      "実務想定・時間制限・採点付きMock"),
        ("chart.bar.fill",      Color.jbAccentAlt,  "実践統計",      "正答率・弱点分野を詳細に可視化"),
        ("icloud.fill",         Color.jbSuccess,    "クラウド同期",  "複数デバイス間で進捗を共有"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.jbBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        heroSection
                        trialSection
                        comparisonSection
                        purchaseSection
                        footerNote
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.jbSubtext)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("購入エラー", isPresented: .constant(purchase.purchaseError != nil)) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchase.purchaseError ?? "")
        }
        .onChange(of: purchase.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
        .sheet(item: $trialSession) { session in
            QuizSheetView(session: session)
        }
    }

    // MARK: Trial

    private var trialSection: some View {
        Button(action: startTrial) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.jbAccent.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.jbAccent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("実践トラックを1問だけ試す")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.jbText)
                    Text("購入前に問題の難易度と形式を体験できます")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.jbSubtext)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.jbAccent)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(Color.jbCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md)
                            .stroke(Color.jbAccent.opacity(0.45), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(JBScaledButtonStyle())
    }

    private func startTrial() {
        let pool = QuestionBank.quizzes(version: .boot3, level: .practice)
            .filter { !$0.code.isEmpty || $0.codeTabs?.isEmpty == false }
        guard let quiz = pool.shuffled().prefix(5).randomElement() ?? pool.first else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        trialSession = QuizSession(
            mode: .single,
            level: .practice,
            version: .boot3,
            quizzes: [quiz],
            customTitle: "実践トレイル"
        )
    }

    // MARK: Hero

    private var heroSection: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(Color.jbAccent.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "crown.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
            }
            .padding(.top, Spacing.md)

            Text("Springsta プレミアム")
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(Color.jbText)

            Text("実践トラックと総合演習を解放")
                .font(.system(size: 15))
                .foregroundStyle(Color.jbSubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Comparison

    private var comparisonSection: some View {
        VStack(spacing: Spacing.sm) {
            // Free tier
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Label("無料で使える機能", systemImage: "gift")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.jbSubtext)
                    .padding(.bottom, 2)

                ForEach(freeFeatures, id: \.title) { f in
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: f.icon)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.jbSuccess.opacity(0.7))
                            .frame(width: 20)
                        Text(f.title)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.jbSubtext)
                    }
                }
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

            HStack(spacing: Spacing.sm) {
                VStack { Divider().background(Color.jbBorder) }
                Image(systemName: "crown.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.jbAccent)
                Text("プレミアムで解放")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.jbAccent)
                VStack { Divider().background(Color.jbBorder) }
            }
            .padding(.vertical, 2)

            // Premium features
            VStack(spacing: Spacing.xs) {
                ForEach(premiumFeatures, id: \.title) { f in
                    HStack(spacing: Spacing.md) {
                        Image(systemName: f.icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(f.color)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(f.color.opacity(0.12)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(f.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.jbText)
                            Text(f.body)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.jbSubtext)
                        }

                        Spacer()

                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.jbAccent)
                    }
                    .padding(Spacing.sm)
                    .jbCard()
                }
            }
        }
    }

    // MARK: Purchase

    private var purchaseSection: some View {
        VStack(spacing: Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(purchase.product?.displayPrice ?? "¥900")
                    .font(.system(size: 36, weight: .heavy).monospacedDigit())
                    .foregroundStyle(Color.jbAccent)
                Text("買い切り")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.jbSubtext)
            }

            Button(action: {
                Task { await purchase.purchase() }
            }) {
                Group {
                    if purchase.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("購入する")
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .fill(Color.jbAccent)
                )
            }
            .buttonStyle(.plain)
            .disabled(purchase.isLoading)

            Button(action: {
                Task { await purchase.restorePurchases() }
            }) {
                Text("購入を復元する")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.jbSubtext)
                    .frame(height: 40)
            }
            .buttonStyle(.plain)
            .disabled(purchase.isLoading)
        }
        .padding(.top, Spacing.xs)
    }

    // MARK: Footer

    private var footerNote: some View {
        Text("購入は一度だけ。買い切り価格で永久にご利用いただけます。\nApp Store のアカウント規約が適用されます。")
            .font(.system(size: 11))
            .foregroundStyle(Color.jbSubtext.opacity(0.7))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
    }
}
