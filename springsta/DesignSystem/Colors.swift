import SwiftUI
import UIKit

extension Color {

    // MARK: - Background / Surface

    /// ページ背景
    static let jbBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "061524") : UIColor(hex: "F4F8FF")
    })

    /// カード背景
    static let jbCard = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "0B1F35") : UIColor(hex: "FFFFFF")
    })

    /// カード内ネストコンテナ
    static let jbSurface = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "102A45") : UIColor(hex: "EAF3FF")
    })

    /// 区切り線・枠線
    static let jbBorder = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "1D456B") : UIColor(hex: "C7DAF4")
    })

    // MARK: - Text

    static let jbText = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "EAF4FF") : UIColor(hex: "10233F")
    })

    static let jbSubtext = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "8EABC7") : UIColor(hex: "5F708A")
    })

    // MARK: - Accent / Semantic  (ライト/ダーク共通)

    static let jbAccent = Color(hex: "2563EB")
    static let jbAccentAlt = Color(hex: "0EA5E9")
    static let jbAccentDeep = Color(hex: "1E3A8A")
    static let jbAccentSoft = Color(hex: "60A5FA")
    static let jbSuccess = Color(hex: "16A34A")
    static let jbWarning = Color(hex: "0F766E")
    static let jbError = Color(hex: "DC2626")

    // MARK: - Syntax (コードブロックは常にダーク背景なので固定)

    static let jbSyntaxKeyword = Color(hex: "93C5FD")
    static let jbSyntaxString = Color(hex: "A7F3D0")
    static let jbSyntaxType = Color(hex: "67E8F9")
    static let jbSyntaxMethod = Color(hex: "C4B5FD")
    static let jbSyntaxComment = Color(hex: "8EA7C2")
    static let jbSyntaxNumber = Color(hex: "7DD3FC")

    // MARK: - Hex initializer

    init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}

private extension UIColor {
    convenience init(hex: String) {
        let h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
