import Foundation

/// 基礎(foundation)トラックのレッスンを「教科書の章」として並べるための表示用メタデータ。
/// レッスン本体は複製せず、既存の Lesson ID を章ごとに束ねるだけ。
struct LessonChapter: Identifiable, Hashable {
    let number: Int
    let title: String
    let lessonIds: [String]

    var id: Int { number }

    var displayTitle: String {
        "第\(number)章 \(title)"
    }
}

extension LessonChapter {
    static let textbookPath: [LessonChapter] = [
        LessonChapter(
            number: 1,
            title: "Java基礎の復習",
            lessonIds: [
                "lesson-java-class-instance",
                "lesson-java-methods",
                "lesson-java-static",
                "lesson-java-interface",
                "lesson-java-list-map",
                "lesson-java-exceptions",
                "lesson-java-annotations"
            ]
        ),
        LessonChapter(
            number: 2,
            title: "Spring Bootの全体像",
            lessonIds: [
                "lesson-java-spring-boot-overview",
                "lesson-spring-foundation-overview",
                "lesson-boot-application-basics",
                "lesson-dependency-injection",
                "lesson-configuration-profiles"
            ]
        ),
        LessonChapter(
            number: 3,
            title: "ControllerとURL",
            lessonIds: [
                "lesson-java-controller-overview",
                "lesson-spring-controller-minimum",
                "lesson-spring-getmapping-url",
                "lesson-spring-request-param",
                "lesson-spring-path-variable",
                "lesson-rest-controller"
            ]
        ),
        LessonChapter(
            number: 4,
            title: "画面表示とThymeleaf",
            lessonIds: [
                "lesson-spring-model-thymeleaf"
            ]
        ),
        LessonChapter(
            number: 5,
            title: "フォーム送信とPOST",
            lessonIds: [
                "lesson-spring-form-post"
            ]
        ),
        LessonChapter(
            number: 6,
            title: "Service / Repository / Entity",
            lessonIds: [
                "lesson-java-service-repository-overview",
                "lesson-spring-service-layer",
                "lesson-spring-repository-layer",
                "lesson-spring-entity-basics"
            ]
        ),
        LessonChapter(
            number: 7,
            title: "JPAとDB操作",
            lessonIds: [
                "lesson-spring-jpa-fetch"
            ]
        ),
        LessonChapter(
            number: 8,
            title: "Validation",
            lessonIds: [
                "lesson-spring-validation-basics"
            ]
        ),
        LessonChapter(
            number: 9,
            title: "エラーの読み方",
            lessonIds: [
                "lesson-spring-error-reading-basics"
            ]
        ),
        LessonChapter(
            number: 10,
            title: "テスト入門",
            lessonIds: [
                "lesson-spring-mockmvc-basics"
            ]
        ),
        LessonChapter(
            number: 11,
            title: "小さなCRUDアプリの流れ",
            lessonIds: [
                "lesson-spring-crud-flow"
            ]
        )
    ]
}
