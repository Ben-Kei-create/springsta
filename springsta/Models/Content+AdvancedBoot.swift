import Foundation

extension Quiz {
    static let advancedBootQuizzes: [Quiz] = (
        advAot + advNative + advAutoConfig + advActuatorCustom + advPerformanceTuning + advConditional
    ).map { $0.contextualizedForPresentation() }

    // MARK: - Group 1: AOT (Ahead-of-Time) コンパイル (5問)
    private static let advAot: [Quiz] = [
        quiz(
            id: "boot3-adv-aot-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["AOT", "Ahead-of-Time", "Spring Boot 3", "ビルド最適化"],
            code: """
// Spring Boot 3 では AOT 処理がビルドフェーズで実行される
// build/generated/aotSources に生成コードが出力される
./mvnw spring-boot:process-aot
""",
            question: "Spring Boot 3 における AOT（Ahead-of-Time）コンパイルの主な目的として正しいものはどれか？",
            choices: [
                choice("a", "ビルド時に Bean 定義・プロキシ・リフレクションヒントを事前生成し、実行時の動的処理を削減してネイティブイメージや起動時間の改善に貢献する", correct: true, explanation: "AOT 処理はビルドフェーズで Spring コンテキストを解析し、通常は実行時に行う自動設定・BeanFactory 構築などをソースコードやヒントとして出力します。GraalVM ネイティブイメージとの組み合わせで効果が最大化されます。"),
                choice("b", "実行時に JIT コンパイラを完全に無効化し、インタープリタのみで動作させる", misconception: "AOT と JIT の関係を混同", explanation: "AOT はビルド時の事前処理であり、JVM 上での JIT を無効化するものではありません。GraalVM ネイティブイメージでは JIT は存在しませんが、それは AOT 処理の直接目的ではありません。"),
                choice("c", "すべての @Bean メソッドを static メソッドに自動変換してスレッドセーフを保証する", misconception: "AOT の生成物を誤解", explanation: "AOT は Bean 定義登録コードを生成しますが、@Bean メソッドを static に変換するわけではありません。"),
                choice("d", "application.properties の値をバイナリ形式にコンパイルして I/O を削減する", misconception: "AOT の対象範囲を誤解", explanation: "AOT 処理は Bean 定義やプロキシ生成が中心であり、プロパティファイルのバイナリ変換は行いません。")
            ],
            explanationRef: "explain-boot3-adv-aot-001",
            designIntent: "AOT コンパイルの概念とメリットをネイティブイメージとの関係で理解する。"
        ),
        quiz(
            id: "boot3-adv-aot-002",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["@ImportRuntimeHints", "RuntimeHints", "AOT", "リフレクション"],
            code: """
@ImportRuntimeHints(MyRuntimeHints.class)
@Configuration
public class AppConfig {
    // ...
}

class MyRuntimeHints implements RuntimeHintsRegistrar {
    @Override
    public void registerHints(RuntimeHints hints, ClassLoader classLoader) {
        hints.reflection()
             .registerType(MyDto.class, MemberCategory.INVOKE_PUBLIC_METHODS);
    }
}
""",
            question: "`@ImportRuntimeHints` の役割として正しいものはどれか？",
            choices: [
                choice("a", "`RuntimeHintsRegistrar` 実装クラスを指定して AOT 処理時にリフレクション・リソース・プロキシなどのヒントを登録し、ネイティブイメージで必要な情報を伝える", correct: true, explanation: "@ImportRuntimeHints は RuntimeHintsRegistrar を AOT 処理に組み込むためのアノテーションです。GraalVM ネイティブイメージではリフレクション対象を事前宣言する必要があり、このメカニズムで指定します。"),
                choice("b", "実行時のパフォーマンスヒントを JIT コンパイラに伝えてホットメソッドを最適化する", misconception: "AOT ヒントと JIT 最適化を混同", explanation: "RuntimeHints は JIT へのヒントではなく、AOT・ネイティブビルド時に必要なメタデータを登録するための仕組みです。"),
                choice("c", "Spring が自動で検出できないデータソース設定を補完してコネクションプールを構成する", misconception: "ヒントの対象を誤解", explanation: "RuntimeHints はリフレクション・リソース・シリアライゼーション等の宣言に使います。データソース設定とは無関係です。"),
                choice("d", "条件付き Bean 登録において @Conditional の代替として使用できる", misconception: "RuntimeHints と条件設定を混同", explanation: "RuntimeHints は Bean の条件登録には関係しません。@Conditional 系アノテーションが Bean 登録条件を担います。")
            ],
            explanationRef: "explain-boot3-adv-aot-002",
            designIntent: "@ImportRuntimeHints によるネイティブイメージ対応のヒント登録パターンを理解する。"
        ),
        quiz(
            id: "boot3-adv-aot-003",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["RuntimeHintsRegistrar", "リフレクション", "AOT", "ネイティブイメージ"],
            code: """
class SecurityHints implements RuntimeHintsRegistrar {
    @Override
    public void registerHints(RuntimeHints hints, ClassLoader classLoader) {
        hints.reflection()
             .registerType(UserDetails.class,
                 MemberCategory.INVOKE_PUBLIC_CONSTRUCTORS,
                 MemberCategory.INVOKE_PUBLIC_METHODS);
        hints.resources()
             .registerPattern("security/*.xml");
    }
}
""",
            question: "`RuntimeHintsRegistrar` でリフレクションヒントを登録する必要がある状況として最も適切なものはどれか？",
            choices: [
                choice("a", "GraalVM ネイティブイメージでコンパイルする際、実行時にリフレクションでアクセスされるクラスを事前宣言する必要があるとき", correct: true, explanation: "GraalVM ネイティブイメージはクローズドワールド前提でビルドされるため、リフレクションで使うクラス・メンバは事前に宣言が必要です。RuntimeHintsRegistrar でこの情報を提供します。"),
                choice("b", "JVM 上で起動する通常の Spring Boot アプリのパフォーマンスを向上させたいとき", misconception: "通常 JVM 起動でも必須と誤解", explanation: "通常の JVM 動作ではリフレクションヒントは必須ではありません。主にネイティブイメージビルド時に必要です。"),
                choice("c", "@Autowired によるフィールドインジェクションを強制的に有効化したいとき", misconception: "インジェクション設定と混同", explanation: "RuntimeHintsRegistrar はインジェクション方式の設定には関係しません。"),
                choice("d", "Spring Security のパスワードエンコーダを Bean として登録したいとき", misconception: "Bean 登録と RuntimeHints を混同", explanation: "Bean 登録は @Bean や @Component で行います。RuntimeHintsRegistrar は AOT/ネイティブビルドのメタデータ提供が目的です。")
            ],
            explanationRef: "explain-boot3-adv-aot-003",
            designIntent: "ネイティブイメージにおけるリフレクションヒント登録の必要性を理解する。"
        ),
        quiz(
            id: "boot3-adv-aot-004",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["AOT", "プロキシ生成", "ビルド時", "CGLIB"],
            code: """
// AOT 処理前（実行時に動的生成）
@Configuration
public class AppConfig {
    @Bean
    public ServiceA serviceA() { return new ServiceA(serviceB()); }

    @Bean
    public ServiceB serviceB() { return new ServiceB(); }
}

// AOT 処理後：build/generated/aotSources に
// AppConfig__BeanDefinitions.java などが生成される
""",
            question: "AOT 処理においてプロキシ生成をビルド時に行う利点として正しいものはどれか？",
            choices: [
                choice("a", "CGLIB などの動的プロキシ生成が実行時に不要になり、GraalVM ネイティブイメージでの動作互換性が高まり起動時間も短縮できる", correct: true, explanation: "AOT 処理はビルド時に @Configuration クラスの Bean 登録コードや AOP プロキシを静的コードとして出力します。これによりネイティブイメージ環境でも動的クラス生成なしで動作できます。"),
                choice("b", "ビルド時にプロキシを生成することで、実行時の Bean 数が自動的に半分以下になる", misconception: "AOT の効果を誇張", explanation: "AOT は Bean 数を削減するのではなく、同等の Bean 構成を静的コードで表現することが目的です。"),
                choice("c", "AOT によるプロキシ生成を有効にすると @Transactional が自動で不要になる", misconception: "AOT と @Transactional の関係を混同", explanation: "@Transactional は AOT 後も有効で、AOT はそのプロキシを静的に生成するだけです。機能自体は変わりません。"),
                choice("d", "ビルド時プロキシ生成は Spring Boot 2 以前でもデフォルトで有効だった", misconception: "AOT の導入バージョンを誤解", explanation: "AOT 処理による事前プロキシ生成は Spring Boot 3 / Spring Framework 6 で本格導入されました。")
            ],
            explanationRef: "explain-boot3-adv-aot-004",
            designIntent: "AOT によるビルド時プロキシ生成のメリットとネイティブイメージとの関係を理解する。"
        ),
        quiz(
            id: "boot3-adv-aot-005",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["spring-boot:process-aot", "Maven", "AOT", "ビルドゴール"],
            code: """
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
</plugin>

<!-- AOT ソース生成 -->
./mvnw spring-boot:process-aot

<!-- ネイティブイメージビルド -->
./mvnw -Pnative native:compile
""",
            question: "`spring-boot:process-aot` Maven ゴールの実行結果として正しいものはどれか？",
            choices: [
                choice("a", "`target/spring-aot/main/sources` 配下に Bean 登録コード・プロキシクラス・RuntimeHints が生成され、続くネイティブコンパイルで利用される", correct: true, explanation: "process-aot ゴールは Spring Boot アプリの AOT 処理を実行し、静的な Bean 定義コードやリフレクションヒントを生成します。native:compile ゴールはこの出力を使ってネイティブバイナリを生成します。"),
                choice("b", "実行すると本番用 Fat JAR が直接生成され、`package` フェーズが不要になる", misconception: "process-aot と package の役割を混同", explanation: "process-aot はソース生成のみで、JAR や実行バイナリを直接生成しません。"),
                choice("c", "process-aot を実行すると Spring Context が完全に起動し、すべての Bean が本番と同じ状態で初期化される", misconception: "AOT 処理時の Context 起動を誤解", explanation: "AOT 処理では限定的なコンテキストが起動して Bean 定義を解析しますが、本番起動とは異なります。外部リソース接続などは通常スキップされます。"),
                choice("d", "process-aot は Gradle 専用のゴールで Maven では使用できない", misconception: "ビルドツールの対応状況を誤解", explanation: "process-aot は Maven プラグインでも提供されています。Gradle の場合は processAot タスクが相当します。")
            ],
            explanationRef: "explain-boot3-adv-aot-005",
            designIntent: "spring-boot:process-aot ゴールの役割とネイティブビルドフローにおける位置付けを理解する。"
        ),
    ]

    // MARK: - Group 2: GraalVM ネイティブイメージ (5問)
    private static let advNative: [Quiz] = [
        quiz(
            id: "boot3-adv-native-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["GraalVM", "native-maven-plugin", "spring-boot-starter-native", "ネイティブイメージ"],
            code: """
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>

<plugin>
    <groupId>org.graalvm.buildtools</groupId>
    <artifactId>native-maven-plugin</artifactId>
</plugin>
""",
            question: "GraalVM ネイティブイメージをビルドするための設定として正しいものはどれか？",
            choices: [
                choice("a", "`native-maven-plugin`（GraalVM Buildtools）を追加し、`-Pnative native:compile` でネイティブバイナリを生成する。Spring Boot 3 では AOT 処理が自動で連携する", correct: true, explanation: "Spring Boot 3 では spring-boot-starter に AOT サポートが統合されており、native-maven-plugin と組み合わせることでネイティブイメージが生成できます。spring-boot-starter-native という別スターターは不要です。"),
                choice("b", "`spring-boot-starter-native` という専用スターターを追加するだけでネイティブビルドが自動化される", misconception: "専用スターターが必要と誤解", explanation: "Spring Boot 3 では spring-boot-starter-native は存在せず、native-maven-plugin と AOT 処理の組み合わせが正しい方法です。"),
                choice("c", "GraalVM JDK をインストールしなくても OpenJDK だけでネイティブバイナリが生成できる", misconception: "ネイティブビルドの要件を誤解", explanation: "ネイティブバイナリの生成には GraalVM（または Liberica NIK 等の互換実装）が必要です。ただし spring-boot:build-image を使えばローカルに GraalVM がなくても Buildpack 経由でビルドできます。"),
                choice("d", "ネイティブイメージは JVM 上で動作するため、通常の Java バイトコードとまったく同じ実行モデルになる", misconception: "ネイティブイメージの実行モデルを誤解", explanation: "ネイティブイメージは AOT コンパイルされたネイティブバイナリであり、JVM 上では動作しません。実行モデルが異なります。")
            ],
            explanationRef: "explain-boot3-adv-native-001",
            designIntent: "GraalVM ネイティブイメージビルドの設定方法と必要コンポーネントを理解する。"
        ),
        quiz(
            id: "boot3-adv-native-002",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["GraalVM", "制限事項", "動的クラスロード", "リフレクション"],
            code: """
// JVM では問題なく動くが、ネイティブイメージでは失敗する例
Class<?> clazz = Class.forName(className); // 動的クラスロード
Method method = clazz.getDeclaredMethod(methodName); // リフレクション
method.invoke(instance, args);
""",
            question: "GraalVM ネイティブイメージでの制限として正しいものはどれか？",
            choices: [
                choice("a", "動的クラスロード（`Class.forName`）やリフレクションは原則禁止で、使用する場合は事前にヒントを登録しなければならない", correct: true, explanation: "ネイティブイメージはクローズドワールド前提のため、ビルド時に未知のクラスを実行時に動的ロードできません。RuntimeHintsRegistrar や reflect-config.json でリフレクション対象を事前宣言する必要があります。"),
                choice("b", "スレッドの生成が完全に禁止されており、シングルスレッドのみで動作する", misconception: "スレッドに関する制限を誤解", explanation: "ネイティブイメージでもスレッドは使用できます。Java 21 の仮想スレッドも GraalVM でサポートが進んでいます。"),
                choice("c", "HTTP 通信ができないため Web アプリケーションには適用できない", misconception: "ネイティブイメージの用途を誤解", explanation: "ネイティブイメージでも HTTP 通信や Web アプリケーションは問題なく動作します。実際に Spring Boot の Web アプリがネイティブ化される事例は多くあります。"),
                choice("d", "JVM 版と比べてメモリ消費が必ず増加する", misconception: "ネイティブイメージのメモリ特性を誤解", explanation: "ネイティブイメージは一般的に JVM より起動時メモリが低く、コンテナ環境での利点の一つです。ただしアプリ特性によって異なります。")
            ],
            explanationRef: "explain-boot3-adv-native-002",
            designIntent: "GraalVM ネイティブイメージの主な制限事項とその回避策を理解する。"
        ),
        quiz(
            id: "boot3-adv-native-003",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["GraalVM", "ビルド時間", "起動時間", "トレードオフ"],
            code: """
# JVM 版
./mvnw package          # ~30秒
java -jar app.jar       # 起動: ~2〜5秒

# ネイティブ版
./mvnw -Pnative native:compile  # ~3〜10分
./target/app            # 起動: ~0.05〜0.2秒
""",
            question: "GraalVM ネイティブイメージにおけるビルド時間と起動時間のトレードオフとして正しいものはどれか？",
            choices: [
                choice("a", "ネイティブビルドは JVM ビルドより大幅に時間がかかるが、起動時間は劇的に短縮される。サーバーレス・短命コンテナ環境で効果が大きい", correct: true, explanation: "AOT コンパイルによりビルド時間は数分〜十数分かかりますが、起動時間はミリ秒単位になります。CI/CD で都度ビルドする際のコストと、スケールアウト速度のトレードオフを考慮して採用を判断します。"),
                choice("b", "ネイティブビルドと JVM ビルドはビルド時間・起動時間ともに同等で差はほとんどない", misconception: "両者のビルド特性を誤解", explanation: "ネイティブビルドは JVM ビルドより大幅に時間がかかります。これが採用を検討する際の主要な考慮点の一つです。"),
                choice("c", "ネイティブイメージは起動後のスループット（RPS）が JVM より常に高い", misconception: "起動時間とスループットを混同", explanation: "ネイティブイメージは起動が速いですが、JIT 最適化がないため長時間稼働時のスループットは JVM に劣る場合があります。"),
                choice("d", "ビルド時間が長いため、ネイティブイメージはローカル開発での Hot Reload に最適化されている", misconception: "ネイティブイメージの用途を誤解", explanation: "ネイティブイメージはビルド時間が長いためローカル開発での Hot Reload には不向きです。開発時は通常 JVM で動作させ、本番デプロイ時にネイティブビルドするのが一般的です。")
            ],
            explanationRef: "explain-boot3-adv-native-003",
            designIntent: "ネイティブイメージのビルド・起動トレードオフと適切なユースケースを理解する。"
        ),
        quiz(
            id: "boot3-adv-native-004",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["spring.aot.enabled", "AOT", "プロパティ", "ランタイム"],
            code: """
# application.properties
spring.aot.enabled=true

# または環境変数
SPRING_AOT_ENABLED=true
""",
            question: "`spring.aot.enabled=true` プロパティの効果として正しいものはどれか？",
            choices: [
                choice("a", "JVM 上で起動する際に AOT 処理で生成した静的 Bean 登録コードを使用するモードを有効にし、起動時間の短縮や動作の検証に使える", correct: true, explanation: "spring.aot.enabled=true は JVM 起動時に AOT 生成コードを優先利用するモードです。ネイティブイメージ本番前の動作検証や、JVM 上でも起動を高速化したい場合に有効です。"),
                choice("b", "このプロパティを設定すると自動的にネイティブバイナリのコンパイルが開始される", misconception: "AOT 有効化とネイティブコンパイルを混同", explanation: "spring.aot.enabled は AOT 生成コードを使った起動モードの切り替えです。ネイティブコンパイルは別途 native:compile ゴールで行います。"),
                choice("c", "spring.aot.enabled は開発プロファイルのみで有効で、本番では自動的に無視される", misconception: "プロファイルとの関係を誤解", explanation: "spring.aot.enabled はプロファイルに関係なく動作します。ネイティブイメージでは自動的に true として扱われます。"),
                choice("d", "このプロパティは Gradle 専用で Maven プロジェクトでは認識されない", misconception: "プロパティのビルドツール依存を誤解", explanation: "spring.aot.enabled はアプリケーションプロパティであり、Maven/Gradle どちらのプロジェクトでも使用できます。")
            ],
            explanationRef: "explain-boot3-adv-native-004",
            designIntent: "spring.aot.enabled の動作モードと検証・最適化での活用を理解する。"
        ),
        quiz(
            id: "boot3-adv-native-005",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["@NativeImageTest", "Testcontainers", "ネイティブテスト", "統合テスト"],
            code: """
@NativeImageTest
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class NativeAppIntegrationTest {

    @Autowired
    TestRestTemplate restTemplate;

    @Test
    void healthEndpointShouldReturnUp() {
        var response = restTemplate.getForObject("/actuator/health", String.class);
        assertThat(response).contains("UP");
    }
}
""",
            question: "`@NativeImageTest` を使ったテストの特徴として正しいものはどれか？",
            choices: [
                choice("a", "事前にビルドしたネイティブバイナリを起動してテストを実行するため、JVM 上のテストでは発見できないネイティブ固有の問題（リフレクション漏れ等）を検出できる", correct: true, explanation: "@NativeImageTest は生成されたネイティブイメージを起動してテストします。JVM 上のテストではリフレクションエラーが出ない場合でも、ネイティブ実行で初めて発覚する問題を事前に検出できます。"),
                choice("b", "@NativeImageTest は JVM 上でネイティブイメージをエミュレートするため、GraalVM がなくても実行できる", misconception: "ネイティブイメージのエミュレーションを誤解", explanation: "@NativeImageTest は実際のネイティブバイナリを使用します。事前に native:compile でビルドが必要で、GraalVM が必要です。"),
                choice("c", "@NativeImageTest を付けると自動的に Testcontainers が起動してデータベースが用意される", misconception: "@NativeImageTest と Testcontainers を混同", explanation: "Testcontainers の起動は @NativeImageTest とは独立しています。Testcontainers を組み合わせることはできますが、自動起動はしません。"),
                choice("d", "@NativeImageTest は @WebMvcTest の別名で、MockMvc を使ったスライステストになる", misconception: "テストアノテーションの役割を混同", explanation: "@NativeImageTest はネイティブバイナリを起動する統合テスト用アノテーションで、@WebMvcTest とは異なります。")
            ],
            explanationRef: "explain-boot3-adv-native-005",
            designIntent: "@NativeImageTest でネイティブイメージ固有の問題を CI で検出する手法を理解する。"
        ),
    ]

    // MARK: - Group 3: カスタム自動設定 (5問)
    private static let advAutoConfig: [Quiz] = [
        quiz(
            id: "boot3-adv-autoconfig-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["AutoConfiguration.imports", "自動設定", "META-INF", "スターター"],
            code: """
// META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports
com.example.MyLibraryAutoConfiguration
com.example.AnotherAutoConfiguration
""",
            question: "`META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` ファイルの役割として正しいものはどれか？",
            choices: [
                choice("a", "Spring Boot 3 でカスタム自動設定クラスを登録するためのファイルで、このファイルに記述されたクラスが自動設定候補として読み込まれる", correct: true, explanation: "Spring Boot 2 では spring.factories に登録していましたが、Boot 3 では AutoConfiguration.imports ファイルが推奨方式です。ライブラリのスターター JAR にこのファイルを含めることで、依存追加だけで自動設定が有効になります。"),
                choice("b", "このファイルはアプリ側の src/main/resources に必ず置く必要があり、ライブラリ JAR 内では認識されない", misconception: "ファイルの配置場所を誤解", explanation: "このファイルはライブラリの JAR 内（META-INF/spring/ 配下）に含めることが目的です。アプリ側からライブラリを依存に追加するだけで自動設定が機能します。"),
                choice("c", "Spring Boot 2 から引き続き `spring.factories` のみが公式サポートされ、imports ファイルは非推奨", misconception: "Spring Boot 3 での変更を見落としている", explanation: "Spring Boot 3 では imports ファイルが推奨方式です。spring.factories の EnableAutoConfiguration エントリは非推奨になりました。"),
                choice("d", "imports ファイルには Java インポート文（import com.example.Foo;）を記述する", misconception: "ファイル形式を Java ソースと混同", explanation: "imports ファイルにはクラスの完全修飾名を1行ずつ記述します。Java ソースのインポート文とは異なります。")
            ],
            explanationRef: "explain-boot3-adv-autoconfig-001",
            designIntent: "Spring Boot 3 のカスタム自動設定登録方法の変更点を理解する。"
        ),
        quiz(
            id: "boot3-adv-autoconfig-002",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["@AutoConfiguration", "@Configuration", "自動設定", "違い"],
            code: """
// Spring Boot 3 推奨: @AutoConfiguration
@AutoConfiguration
public class MyLibraryAutoConfiguration {
    @Bean
    @ConditionalOnMissingBean
    public MyService myService() {
        return new MyService();
    }
}

// アプリ側: @Configuration
@Configuration
public class AppConfig {
    // ...
}
""",
            question: "`@AutoConfiguration` と `@Configuration` の主な違いとして正しいものはどれか？",
            choices: [
                choice("a", "`@AutoConfiguration` はライブラリのスターター向けで、コンポーネントスキャンの対象外となり AutoConfiguration.imports 経由でのみ読み込まれる。`@Configuration` はアプリ側でスキャンされる通常の設定クラスに使う", correct: true, explanation: "@AutoConfiguration はコンポーネントスキャンで誤検出されないよう設計されており、AutoConfiguration.imports ファイルへの登録が必要です。アプリ開発者は @Configuration を使い、ライブラリ開発者が @AutoConfiguration を使います。"),
                choice("b", "@AutoConfiguration を付けると Bean の生成が非同期になり、アプリ起動を並列化できる", misconception: "@AutoConfiguration の非同期起動を誤解", explanation: "@AutoConfiguration は Bean 生成の非同期化とは関係ありません。"),
                choice("c", "@AutoConfiguration は @Configuration の完全な上位互換であり、アプリ側でも @Configuration の代わりに常に使うべき", misconception: "使い分けを誤解", explanation: "@AutoConfiguration はライブラリ用で、アプリ側の設定には @Configuration を使うのが適切です。"),
                choice("d", "@AutoConfiguration が付いたクラスは @Conditional 系アノテーションを使用できない", misconception: "@AutoConfiguration と条件設定の制約を誤解", explanation: "@AutoConfiguration クラスでも @ConditionalOnMissingBean 等の条件アノテーションは通常通り使用できます。")
            ],
            explanationRef: "explain-boot3-adv-autoconfig-002",
            designIntent: "@AutoConfiguration の位置付けとライブラリスターター設計での使い分けを理解する。"
        ),
        quiz(
            id: "boot3-adv-autoconfig-003",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["@ConditionalOnMissingBean", "スターター設計", "上書き可能", "ライブラリ"],
            code: """
@AutoConfiguration
public class CacheAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean(CacheManager.class)
    public CacheManager defaultCacheManager() {
        return new SimpleCacheManager();
    }
}
""",
            question: "ライブラリのスターターで `@ConditionalOnMissingBean` を使う主な理由として正しいものはどれか？",
            choices: [
                choice("a", "アプリ側で同じ型の Bean が定義されていれば自動設定の Bean を登録しないことで、ライブラリのデフォルト実装をアプリ側から安全に上書きできるようにするため", correct: true, explanation: "@ConditionalOnMissingBean はライブラリスターターのベストプラクティスです。アプリ開発者が独自の CacheManager を定義すれば自動設定が干渉しません。これにより「デフォルトは提供するが上書き可能」という設計が実現できます。"),
                choice("b", "Bean の生成を遅延させてアプリの起動時間を短縮するための最適化手段として使用する", misconception: "@Lazy と @ConditionalOnMissingBean を混同", explanation: "起動遅延は @Lazy の役割です。@ConditionalOnMissingBean は Bean の存在チェックが目的です。"),
                choice("c", "@ConditionalOnMissingBean を使うと同じ型の Bean が複数登録されることを防ぎ、必ず唯一の Bean が保証される", misconception: "Bean の唯一性保証と条件付き登録を混同", explanation: "@ConditionalOnMissingBean は Bean の唯一性を保証するわけではありません。アプリ側で複数 Bean を登録した場合には他の仕組みが必要です。"),
                choice("d", "テスト時に @MockBean で置き換えるためには @ConditionalOnMissingBean が必須である", misconception: "@MockBean の動作条件を誤解", explanation: "@MockBean は @ConditionalOnMissingBean とは独立して動作します。")
            ],
            explanationRef: "explain-boot3-adv-autoconfig-003",
            designIntent: "@ConditionalOnMissingBean によるスターター設計の「デフォルト提供・上書き可能」パターンを理解する。"
        ),
        quiz(
            id: "boot3-adv-autoconfig-004",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["@AutoConfigureBefore", "@AutoConfigureAfter", "自動設定", "順序"],
            code: """
@AutoConfiguration(after = DataSourceAutoConfiguration.class)
@ConditionalOnBean(DataSource.class)
public class JpaAutoConfiguration {
    // DataSource が設定された後に JPA を設定する
}

@AutoConfiguration(before = SecurityAutoConfiguration.class)
public class OAuth2AutoConfiguration {
    // Security より先に OAuth2 設定を準備する
}
""",
            question: "`@AutoConfigureBefore` / `@AutoConfigureAfter`（Spring Boot 3 では `@AutoConfiguration(before/after)`）を使う目的として正しいものはどれか？",
            choices: [
                choice("a", "自動設定クラス間の依存関係を明示して読み込み順序を制御し、前提となる Bean が生成された後に後続の自動設定が適用されるようにする", correct: true, explanation: "自動設定クラスは通常コンポーネントスキャンの順序に依存しますが、@AutoConfigureAfter/@AutoConfigureBefore で明示的に順序を指定できます。例えば JPA 自動設定は DataSource 自動設定より後である必要があります。"),
                choice("b", "指定した自動設定クラスを完全に無効化して、自分のクラスだけが有効になるようにする", misconception: "順序制御と無効化を混同", explanation: "@AutoConfigureBefore/After は順序の指定であり、他のクラスを無効化しません。"),
                choice("c", "Spring Boot 2 では利用可能だったが Spring Boot 3 で削除されたため現在は使用できない", misconception: "Spring Boot 3 での変更を誤解", explanation: "Spring Boot 3 では @AutoConfiguration アノテーションの before/after 属性として統合されました。機能は引き続き利用可能です。"),
                choice("d", "テスト時のみ自動設定の順序を変更するためのアノテーションで、本番起動では無視される", misconception: "テスト専用と誤解", explanation: "このアノテーションは本番/テスト問わず自動設定の順序制御に使われます。")
            ],
            explanationRef: "explain-boot3-adv-autoconfig-004",
            designIntent: "自動設定の依存順序を明示的に制御する方法を理解する。"
        ),
        quiz(
            id: "boot3-adv-autoconfig-005",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .bootBasics,
            tags: ["spring-boot-autoconfigure-processor", "アノテーションプロセッサ", "メタデータ", "IDE補完"],
            code: """
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-autoconfigure-processor</artifactId>
    <optional>true</optional>
</dependency>
""",
            question: "`spring-boot-autoconfigure-processor` アノテーションプロセッサの主な役割として正しいものはどれか？",
            choices: [
                choice("a", "ビルド時に自動設定クラスのメタデータ（spring-autoconfigure-metadata.properties）を生成し、起動時の自動設定条件チェックを高速化する", correct: true, explanation: "このプロセッサは @ConditionalOn* の条件をビルド時に解析してメタデータファイルを生成します。起動時には条件を満たさない自動設定クラスを早期に除外でき、Spring Context の起動が高速化されます。"),
                choice("b", "application.properties のキーに対してコンパイル時型チェックを行い、間違ったプロパティ名をエラーにする", misconception: "autoconfigure-processor と configuration-processor を混同", explanation: "プロパティキーのコンパイル時チェックは spring-boot-configuration-processor の役割です。autoconfigure-processor は自動設定クラスのメタデータ生成が目的です。"),
                choice("c", "このプロセッサは必須依存であり、なければビルドが失敗する", misconception: "optional 依存の意味を誤解", explanation: "optional=true の通り、このプロセッサがなくてもビルドは成功します。ただし起動時の最適化効果が得られなくなります。"),
                choice("d", "このプロセッサを追加すると @AutoConfiguration アノテーションが自動的に付与される", misconception: "プロセッサの動作を誤解", explanation: "アノテーションプロセッサはアノテーションを自動付与するものではありません。既存のアノテーションからメタデータを生成します。")
            ],
            explanationRef: "explain-boot3-adv-autoconfig-005",
            designIntent: "自動設定プロセッサによる起動最適化の仕組みを理解する。"
        ),
    ]

    // MARK: - Group 4: カスタム Actuator 拡張 (5問)
    private static let advActuatorCustom: [Quiz] = [
        quiz(
            id: "boot3-adv-actuatorcustom-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .observability,
            tags: ["@Endpoint", "@ReadOperation", "@WriteOperation", "@DeleteOperation", "Actuator"],
            code: """
@Component
@Endpoint(id = "featureFlags")
public class FeatureFlagsEndpoint {

    private final Map<String, Boolean> flags = new ConcurrentHashMap<>();

    @ReadOperation
    public Map<String, Boolean> flags() {
        return Collections.unmodifiableMap(flags);
    }

    @WriteOperation
    public void setFlag(@Selector String name, boolean enabled) {
        flags.put(name, enabled);
    }

    @DeleteOperation
    public void removeFlag(@Selector String name) {
        flags.remove(name);
    }
}
""",
            question: "`@Endpoint` を使ったカスタム Actuator エンドポイントの説明として正しいものはどれか？",
            choices: [
                choice("a", "`@ReadOperation` は GET、`@WriteOperation` は POST/PUT、`@DeleteOperation` は DELETE に対応し、`id` 属性で `/actuator/{id}` のパスが決まる", correct: true, explanation: "@Endpoint はテクノロジー非依存のエンドポイント定義であり、HTTP と JMX 両方で公開できます。@ReadOperation が GET、@WriteOperation が POST、@DeleteOperation が DELETE に対応します。id 属性がエンドポイントのパス名になります。"),
                choice("b", "@Endpoint は HTTP のみをサポートし、JMX 経由での公開はできない", misconception: "@Endpoint の公開手段を誤解", explanation: "@Endpoint はテクノロジー非依存で、HTTP と JMX の両方で公開されます。HTTP のみにしたい場合は @WebEndpoint を使います。"),
                choice("c", "@WriteOperation は HTTP GET メソッドにのみバインドされる", misconception: "オペレーションと HTTP メソッドのマッピングを誤解", explanation: "@WriteOperation は HTTP POST（またはコンテキストによっては PUT）にマッピングされます。GET は @ReadOperation です。"),
                choice("d", "カスタム @Endpoint を作成した場合、management.endpoints.web.exposure.include に必ず '*' を指定しないと動作しない", misconception: "公開設定の要件を誤解", explanation: "カスタムエンドポイントも include に id を指定するか '*' で全公開にすることで利用可能です。ただし '*' が必須というわけではなく、id を個別指定でも動作します。")
            ],
            explanationRef: "explain-boot3-adv-actuatorcustom-001",
            designIntent: "@Endpoint/@ReadOperation/@WriteOperation/@DeleteOperation によるカスタムエンドポイント設計を理解する。"
        ),
        quiz(
            id: "boot3-adv-actuatorcustom-002",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .observability,
            tags: ["HealthIndicator", "CompositeHealth", "コンポーネント詳細", "Actuator"],
            code: """
@Component
public class ExternalServiceHealthIndicator implements HealthIndicator {

    private final ExternalServiceClient client;

    @Override
    public Health health() {
        try {
            client.ping();
            return Health.up()
                         .withDetail("url", client.getUrl())
                         .withDetail("responseMs", client.lastResponseMs())
                         .build();
        } catch (Exception e) {
            return Health.down()
                         .withDetail("error", e.getMessage())
                         .build();
        }
    }
}
""",
            question: "カスタム `HealthIndicator` で `withDetail()` を使う利点として正しいものはどれか？",
            choices: [
                choice("a", "`/actuator/health` レスポンスの詳細セクションに診断情報（URL、応答時間、エラー内容等）を含められ、障害発生時のトラブルシューティングが容易になる", correct: true, explanation: "withDetail() で追加した情報は show-details: always（または認可済みユーザー向け）の設定時に health レスポンスの details に表示されます。外部サービスの接続先 URL や応答時間を記録することで、障害時の原因特定が速くなります。"),
                choice("b", "withDetail() を呼ぶと自動的にアラートが送信され、監視システムに通知が届く", misconception: "詳細情報追加とアラート送信を混同", explanation: "withDetail() はレスポンスに情報を追加するだけで、アラート送信機能はありません。監視ツールとの連携は別途設定が必要です。"),
                choice("c", "withDetail() で追加したキーは必ず application.properties で事前定義しておく必要がある", misconception: "動的な詳細情報追加の仕組みを誤解", explanation: "withDetail() のキーは任意の文字列で、事前定義は不要です。"),
                choice("d", "カスタム HealthIndicator は DOWN を返すと JVM が自動停止する", misconception: "ヘルスチェック結果とプロセス終了を混同", explanation: "DOWN は /actuator/health のレスポンスが DOWN になるだけで、JVM プロセスは停止しません。Kubernetes がこの情報を受け取りポッド再起動を判断することはあります。")
            ],
            explanationRef: "explain-boot3-adv-actuatorcustom-002",
            designIntent: "HealthIndicator での詳細情報付与とトラブルシューティングへの活用を理解する。"
        ),
        quiz(
            id: "boot3-adv-actuatorcustom-003",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .observability,
            tags: ["InfoContributor", "/actuator/info", "ビルド情報", "Actuator"],
            code: """
@Component
public class AppInfoContributor implements InfoContributor {

    private final BuildProperties buildProperties;

    @Override
    public void contribute(Info.Builder builder) {
        builder.withDetail("build", Map.of(
            "version", buildProperties.getVersion(),
            "artifact", buildProperties.getArtifact(),
            "time", buildProperties.getTime()
        ));
    }
}
""",
            question: "`InfoContributor` を実装する主な目的として正しいものはどれか？",
            choices: [
                choice("a", "`/actuator/info` エンドポイントのレスポンスにカスタム情報（ビルドバージョン、環境情報等）を追加し、デプロイされたアプリのバージョン確認やデバッグに活用する", correct: true, explanation: "InfoContributor は /actuator/info のコンテンツを拡張します。BuildProperties を注入することでビルド時のバージョン・タイムスタンプ等を自動取得できます。CI/CD 環境でデプロイされたバージョンをリアルタイム確認するのに便利です。"),
                choice("b", "InfoContributor はヘルスチェックの代替であり、実装すると /actuator/health が不要になる", misconception: "InfoContributor と HealthIndicator の役割を混同", explanation: "InfoContributor は /actuator/info 向けの情報提供であり、/actuator/health とは独立しています。ヘルスチェックの代替にはなりません。"),
                choice("c", "InfoContributor を実装するとアプリ起動時にコンソールに情報が自動出力される", misconception: "InfoContributor の動作タイミングを誤解", explanation: "InfoContributor は /actuator/info への HTTP リクエスト時に呼び出されます。起動時の自動出力ではありません。"),
                choice("d", "InfoContributor は Spring Security の認証情報を提供するために使用する", misconception: "セキュリティ関連コンポーネントと混同", explanation: "InfoContributor はアプリケーション情報の提供が目的で、Security 認証とは無関係です。")
            ],
            explanationRef: "explain-boot3-adv-actuatorcustom-003",
            designIntent: "InfoContributor による /actuator/info カスタマイズとデプロイ追跡への活用を理解する。"
        ),
        quiz(
            id: "boot3-adv-actuatorcustom-004",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .observability,
            tags: ["@EndpointWebExtension", "HTTP固有", "Actuator", "Web拡張"],
            code: """
@Component
@EndpointWebExtension(endpoint = FeatureFlagsEndpoint.class)
public class FeatureFlagsWebEndpointExtension {

    private final FeatureFlagsEndpoint delegate;

    @ReadOperation
    public WebEndpointResponse<Map<String, Boolean>> flags() {
        Map<String, Boolean> flags = delegate.flags();
        return new WebEndpointResponse<>(flags, flags.isEmpty() ? 204 : 200);
    }
}
""",
            question: "`@EndpointWebExtension` を使う場面として正しいものはどれか？",
            choices: [
                choice("a", "既存の `@Endpoint` に HTTP 固有の動作（レスポンスステータスコードの制御、HTTPヘッダーの付与等）を追加したいとき", correct: true, explanation: "@EndpointWebExtension は @Endpoint の HTTP Web 向け拡張を定義します。WebEndpointResponse を返すことで HTTP ステータスコードを制御できます。@Endpoint 本体は JMX と HTTP の両方に対してテクノロジー非依存に定義し、HTTP 固有の振る舞いは Extension で追加します。"),
                choice("b", "@EndpointWebExtension は新しいエンドポイントを一から作成するためのアノテーションで @Endpoint の代わりに使う", misconception: "@Endpoint と @EndpointWebExtension の関係を逆に理解", explanation: "@EndpointWebExtension は既存の @Endpoint を拡張するものです。@Endpoint なしに単独では使えません。"),
                choice("c", "@EndpointWebExtension を使うと元の @Endpoint が自動的に無効化される", misconception: "拡張と元エンドポイントの関係を誤解", explanation: "@EndpointWebExtension は @Endpoint を無効化しません。HTTP アクセス時の動作を上書きするものです。"),
                choice("d", "@EndpointWebExtension は Spring MVC でのみ動作し、WebFlux（Reactive）環境では使用できない", misconception: "Spring MVC 専用と誤解", explanation: "@EndpointWebExtension は Spring MVC と WebFlux の両方で使用できます。")
            ],
            explanationRef: "explain-boot3-adv-actuatorcustom-004",
            designIntent: "@EndpointWebExtension で HTTP 固有の振る舞いを追加する設計パターンを理解する。"
        ),
        quiz(
            id: "boot3-adv-actuatorcustom-005",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .observability,
            tags: ["Micrometer", "MeterRegistry", "カスタムメトリクス", "Actuator"],
            code: """
@Component
public class OrderMetrics {

    private final Counter orderCounter;
    private final Timer orderTimer;

    public OrderMetrics(MeterRegistry registry) {
        this.orderCounter = Counter.builder("orders.placed")
            .tag("region", "ap-northeast-1")
            .description("注文件数")
            .register(registry);
        this.orderTimer = Timer.builder("orders.processing.time")
            .description("注文処理時間")
            .register(registry);
    }

    public void recordOrder(Runnable orderProcess) {
        orderCounter.increment();
        orderTimer.record(orderProcess);
    }
}
""",
            question: "Micrometer の `MeterRegistry` を使ったカスタムメトリクスの説明として正しいものはどれか？",
            choices: [
                choice("a", "`MeterRegistry` を注入することでカスタム Counter・Timer・Gauge 等を定義でき、Prometheus や Datadog 等のバックエンドに対してコードを変更せず同じメトリクスを送れる", correct: true, explanation: "Micrometer はメトリクスのファサードであり、MeterRegistry 実装を差し替えることでバックエンドを切り替えられます。spring-boot-starter-actuator に含まれ、spring-boot-starter-actuator + micrometer-registry-prometheus を追加するだけで /actuator/prometheus が有効になります。"),
                choice("b", "MeterRegistry はスレッドセーフではないため、カウンターをインクリメントする前に synchronized ブロックが必要", misconception: "MeterRegistry のスレッドセーフ性を誤解", explanation: "Micrometer の Counter や Timer はスレッドセーフに設計されています。synchronized は不要です。"),
                choice("c", "カスタムメトリクスは application.properties に定義しなければ /actuator/metrics に表示されない", misconception: "プロパティ定義の必要性を誤解", explanation: "MeterRegistry に登録したメトリクスは自動的に /actuator/metrics に表示されます。事前のプロパティ定義は不要です。"),
                choice("d", "Counter と Timer は同じ型であり、使い分ける必要はない", misconception: "Micrometer のメータ種別を誤解", explanation: "Counter は累積カウント、Timer は時間計測と件数の両方を保持します。用途に応じて使い分けます。")
            ],
            explanationRef: "explain-boot3-adv-actuatorcustom-005",
            designIntent: "Micrometer による カスタムメトリクス定義とバックエンド非依存の設計を理解する。"
        ),
    ]

    // MARK: - Group 5: JVM/Boot パフォーマンスチューニング (5問)
    private static let advPerformanceTuning: [Quiz] = [
        quiz(
            id: "boot3-adv-performance-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["lazy-initialization", "起動時間", "トレードオフ", "パフォーマンス"],
            code: """
# application.properties
spring.main.lazy-initialization=true
""",
            question: "`spring.main.lazy-initialization=true` のトレードオフとして正しいものはどれか？",
            choices: [
                choice("a", "起動時間は短縮されるが、Bean が初めてアクセスされたときに初期化されるため、初回リクエストのレイテンシが増加し、起動直後の設定ミスが発見しにくくなる", correct: true, explanation: "遅延初期化は起動時に全 Bean を生成しないため起動が速くなります。ただし初回アクセス時の応答が遅れます。また、本来起動時に検出される Bean の設定エラーが実行時まで顕在化しない問題があるため、本番環境では慎重に使う必要があります。"),
                choice("b", "lazy-initialization=true にすると @Singleton Bean がすべてプロトタイプスコープに切り替わる", misconception: "遅延初期化とスコープ変更を混同", explanation: "遅延初期化はスコープを変更しません。シングルトン Bean は依然としてシングルトンですが、最初に参照されるまで生成されません。"),
                choice("c", "lazy-initialization を有効にすると @Transactional が正常に動作しなくなる", misconception: "遅延初期化と AOP の互換性を誤解", explanation: "@Transactional は遅延初期化と問題なく組み合わせられます。Bean 初期化時にプロキシが正常に生成されます。"),
                choice("d", "この設定は開発環境でのみ有効で、本番環境では自動的に false に戻る", misconception: "環境依存の動作を誤解", explanation: "spring.main.lazy-initialization は環境に依存せず設定値通りに動作します。本番で無効化したい場合はプロファイル別設定で明示的に false にする必要があります。")
            ],
            explanationRef: "explain-boot3-adv-performance-001",
            designIntent: "遅延初期化の起動短縮効果と初回レイテンシ・エラー検出遅れのトレードオフを理解する。"
        ),
        quiz(
            id: "boot3-adv-performance-002",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["仮想スレッド", "Virtual Threads", "Java 21", "spring.threads.virtual.enabled"],
            code: """
# application.properties (Spring Boot 3.2+, Java 21)
spring.threads.virtual.enabled=true
""",
            question: "`spring.threads.virtual.enabled=true` を設定する前提条件と効果として正しいものはどれか？",
            choices: [
                choice("a", "Java 21 以上が必要で、有効にすると Tomcat・スケジューラ等のスレッドプールが仮想スレッドに切り替わり、スレッドブロッキング I/O が多い環境でスループット向上が期待できる", correct: true, explanation: "仮想スレッド（Project Loom）は Java 21 で正式導入されました。spring.threads.virtual.enabled=true で Spring Boot の主要なスレッドプールが仮想スレッドに切り替わります。従来のプラットフォームスレッドに比べて大量の同時接続を少ないリソースで処理できます。"),
                choice("b", "仮想スレッドは Java 11 以降であれば利用可能で、Spring Boot 2.x でも同じプロパティで有効化できる", misconception: "仮想スレッドの導入バージョンを誤解", explanation: "仮想スレッドは Java 21 の正式機能です。Java 19・20 ではプレビュー機能として存在しましたが、Spring Boot 3.2 以降で正式サポートされました。"),
                choice("c", "仮想スレッドを有効にすると WebFlux (Reactive) と同等のノンブロッキング I/O モデルに切り替わる", misconception: "仮想スレッドと Reactive の動作モデルを混同", explanation: "仮想スレッドはブロッキング API をそのまま使いつつ高いスループットを実現します。WebFlux のようなコールバック/Mono・Flux ベースのプログラミングモデルとは異なります。"),
                choice("d", "仮想スレッドを有効にすると synchronized ブロックが自動的に ReentrantLock に変換される", misconception: "仮想スレッドの自動変換を誤解", explanation: "仮想スレッドは synchronized ブロックでスレッドピンニングが起きる場合があります（Java 21 では改善中）。自動変換はされません。")
            ],
            explanationRef: "explain-boot3-adv-performance-002",
            designIntent: "仮想スレッドの前提条件と Spring Boot での有効化による効果を理解する。"
        ),
        quiz(
            id: "boot3-adv-performance-003",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["ZGC", "JVM フラグ", "低レイテンシ", "GC"],
            code: """
# Dockerfile / kubernetes deployment
java -XX:+UseZGC -XX:+ZGenerational -jar app.jar

# または JVM_OPTS 環境変数
JVM_OPTS="-XX:+UseZGC -XX:MaxRAMPercentage=75"
""",
            question: "`-XX:+UseZGC` フラグの特徴として正しいものはどれか？",
            choices: [
                choice("a", "ZGC はほぼ全フェーズをアプリスレッドと並行して実行する低レイテンシ GC であり、ヒープサイズに関わらず GC ポーズをミリ秒以下に抑えることを目的としている", correct: true, explanation: "ZGC（Z Garbage Collector）は Java 15 で本番対応した低レイテンシ GC です。Stop-The-World ポーズをミリ秒以下に保つ設計で、大ヒープ・レイテンシ敏感なサービスに適しています。Java 21 では ZGenerational モードが推奨です。"),
                choice("b", "-XX:+UseZGC を使うとアプリのヒープ使用量が自動的に半分になる", misconception: "GC 選択とメモリ削減効果を混同", explanation: "ZGC は GC ポーズを短縮しますが、ヒープ使用量そのものを削減する機能はありません。"),
                choice("c", "ZGC は G1GC よりスループットが常に高く、全てのユースケースで G1GC を置き換えるべき", misconception: "ZGC と G1GC の特性を誤解", explanation: "ZGC は低レイテンシに最適化されており、スループットでは G1GC が勝る場合もあります。ユースケース（低レイテンシ優先か高スループット優先か）に応じて選択します。"),
                choice("d", "-XX:+UseZGC は Spring Boot 専用フラグで、他の Java アプリには適用できない", misconception: "JVM フラグの適用範囲を誤解", explanation: "-XX:+UseZGC は JVM の標準フラグであり、Spring Boot に限らず任意の Java アプリで使用できます。")
            ],
            explanationRef: "explain-boot3-adv-performance-003",
            designIntent: "ZGC の低レイテンシ特性と適切なユースケースを理解する。"
        ),
        quiz(
            id: "boot3-adv-performance-004",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["build-image", "レイヤーJAR", "Buildpack", "キャッシュ"],
            code: """
# レイヤー JAR + Buildpack でイメージビルド
./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=myapp:latest

# レイヤー構成確認
java -Djarmode=layertools -jar target/app.jar list
# layers:
#   dependencies
#   spring-boot-loader
#   snapshot-dependencies
#   application
""",
            question: "`spring-boot:build-image` とレイヤー JAR の組み合わせが Docker キャッシュに有効な理由として正しいものはどれか？",
            choices: [
                choice("a", "依存ライブラリ層・スプリングローダー層・アプリコード層が分割されることで、コード変更時に変更のない依存ライブラリ層のキャッシュが再利用され、イメージプッシュ時の転送量とビルド時間が削減される", correct: true, explanation: "レイヤー JAR は dependencies（変わらない）とアプリケーションコード（よく変わる）を別レイヤーに分けます。Buildpack もこの構造を活用してレイヤーキャッシュを最大化します。CI/CD でのビルド時間とレジストリへのデータ転送量が削減されます。"),
                choice("b", "レイヤー JAR を使うと依存ライブラリが自動的にネットワーク経由で最新バージョンに更新される", misconception: "レイヤー分割と依存管理を混同", explanation: "レイヤー JAR は Docker キャッシュの最適化のためのもので、依存バージョンの自動更新機能はありません。"),
                choice("c", "spring-boot:build-image は必ずローカルの Docker デーモンを使用するため、CI 環境では使用できない", misconception: "CI 環境での利用可否を誤解", explanation: "CI 環境でも Docker デーモン（または remote Docker）が利用可能であれば build-image を使用できます。"),
                choice("d", "レイヤーが増えると Docker イメージのセキュリティスキャン対象が減り、脆弱性が発見されにくくなる", misconception: "レイヤー分割とセキュリティスキャンを混同", explanation: "レイヤー分割はキャッシュ効率化のためであり、セキュリティスキャン対象の増減とは関係しません。")
            ],
            explanationRef: "explain-boot3-adv-performance-004",
            designIntent: "レイヤー JAR と Buildpack によるイメージビルドキャッシュ最適化を理解する。"
        ),
        quiz(
            id: "boot3-adv-performance-005",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["AppCDS", "Class Data Sharing", "起動時間", "JVM最適化"],
            code: """
# Step 1: アーカイブ作成用の起動（クラスリスト収集）
java -XX:ArchiveClassesAtExit=app-cds.jsa \
     -Dspring.context.exit=onRefresh \
     -jar app.jar

# Step 2: CDS アーカイブを使って通常起動
java -XX:SharedArchiveFile=app-cds.jsa -jar app.jar
""",
            question: "Class Data Sharing（AppCDS）を Spring Boot アプリに適用する主な目的として正しいものはどれか？",
            choices: [
                choice("a", "よく使用されるクラスのロード・解析済みデータをアーカイブファイルに保存し、次回起動時にクラスロードフェーズを短縮して JVM の起動時間を削減する", correct: true, explanation: "AppCDS は JVM のクラスデータ（バイトコード解析結果等）をファイルにシリアライズし、次回起動時にメモリマップして再利用します。Spring Boot アプリでは大量クラスのロード時間が削減され、起動時間が 30〜50% 短縮される事例があります。Spring Boot 3.3 以降は CDS サポートが強化されています。"),
                choice("b", "AppCDS はアーカイブに含めたクラスを変更不可にロックし、本番環境でのコード改ざん防止に使用する", misconception: "CDS のセキュリティ効果を誤解", explanation: "CDS はセキュリティ機能ではなく、クラスロードの高速化が目的です。クラスをロックする機能はありません。"),
                choice("c", "AppCDS を有効にすると JIT コンパイルが無効になり、ネイティブイメージと同等の実行速度になる", misconception: "CDS とネイティブイメージの効果を混同", explanation: "CDS は起動フェーズのクラスロードを高速化するものですが、JIT コンパイルは引き続き有効で実行時は通常の JVM として動作します。"),
                choice("d", "AppCDS アーカイブは一度作成すれば JAR を更新しても再作成不要で自動同期される", misconception: "CDS アーカイブの更新要件を誤解", explanation: "JAR や JDK バージョンが変わった場合はアーカイブを再作成する必要があります。古いアーカイブは無視されて通常起動にフォールバックします。")
            ],
            explanationRef: "explain-boot3-adv-performance-005",
            designIntent: "AppCDS による JVM 起動時間短縮の仕組みと Spring Boot への適用方法を理解する。"
        ),
    ]

    // MARK: - Group 6: 高度な条件付き設定 (5問)
    private static let advConditional: [Quiz] = [
        quiz(
            id: "boot3-adv-conditional-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["@ConditionalOnExpression", "SpEL", "条件付きBean", "高度条件"],
            code: """
@Configuration
@ConditionalOnExpression(
    "${feature.cache.enabled:false} && '${app.tier}'.equals('premium')"
)
public class PremiumCacheConfig {
    @Bean
    public CacheManager premiumCacheManager() {
        return new RedisCacheManager(...);
    }
}
""",
            question: "`@ConditionalOnExpression` の特徴として正しいものはどれか？",
            choices: [
                choice("a", "SpEL（Spring Expression Language）で複数のプロパティ値や条件を組み合わせた複合条件を表現でき、@ConditionalOnProperty では難しい論理演算（AND/OR）が可能", correct: true, explanation: "@ConditionalOnExpression は SpEL 式で条件を評価します。複数プロパティの AND/OR 組み合わせや、プロパティ値の比較など柔軟な条件が書けます。ただし SpEL の可読性と複雑さのトレードオフを考慮して使用します。"),
                choice("b", "@ConditionalOnExpression は @ConditionalOnProperty の完全な上位互換で、@ConditionalOnProperty は非推奨になった", misconception: "@ConditionalOnProperty の非推奨を誤解", explanation: "@ConditionalOnProperty は単純なプロパティ条件に使いやすく引き続き推奨されます。@ConditionalOnExpression は複雑な条件が必要な場合に使います。"),
                choice("c", "SpEL 式の評価はアプリ起動後にリアルタイムで再評価されるため、プロパティ変更が即座に反映される", misconception: "条件評価のタイミングを誤解", explanation: "@ConditionalOnExpression はアプリ起動時（Bean 登録フェーズ）に1回評価されます。実行時の動的再評価はしません。"),
                choice("d", "@ConditionalOnExpression は XML 設定でのみ使用可能で、Java 設定では動作しない", misconception: "アノテーションの使用環境を誤解", explanation: "@ConditionalOnExpression は Java 設定（@Configuration クラス）でも XML でも使用できます。")
            ],
            explanationRef: "explain-boot3-adv-conditional-001",
            designIntent: "@ConditionalOnExpression による SpEL を使った複合条件設定を理解する。"
        ),
        quiz(
            id: "boot3-adv-conditional-002",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["@ConditionalOnResource", "リソース存在確認", "条件付き設定", "クラスパス"],
            code: """
@Configuration
@ConditionalOnResource(resources = "classpath:custom-security.xml")
public class CustomSecurityConfig {
    // custom-security.xml が classpath にある場合のみ有効
}

@Configuration
@ConditionalOnResource(resources = "file:/etc/app/config.properties")
public class ExternalConfigOverride {
    // 外部ファイルが存在する場合のみ有効
}
""",
            question: "`@ConditionalOnResource` が有効なユースケースとして正しいものはどれか？",
            choices: [
                choice("a", "特定のファイル（設定ファイル・プラグインファイル等）がクラスパスまたはファイルシステムに存在する場合のみ Bean を登録し、ファイルの有無で動作を切り替えられる", correct: true, explanation: "@ConditionalOnResource は classpath: や file: プレフィックスでリソースの存在を確認します。環境によって設定ファイルが置かれる場所が異なるマルチ環境デプロイや、オプショナルなプラグイン設定ファイルの存在確認に有効です。"),
                choice("b", "@ConditionalOnResource はデータベース接続のリソース（コネクション）が確保できる場合のみ Bean を登録する", misconception: "リソースの意味を DB コネクションと混同", explanation: "ここでの「リソース」は Spring の Resource 抽象（ファイル・クラスパスリソース）を指します。DB コネクションとは無関係です。"),
                choice("c", "@ConditionalOnResource で指定したリソースの内容をパースして Bean の設定値に自動マッピングする", misconception: "存在確認とコンテンツ解析を混同", explanation: "@ConditionalOnResource はリソースの存在確認のみです。内容のパース・マッピングは別の仕組み（@PropertySource 等）が担います。"),
                choice("d", "@ConditionalOnResource は @ConditionalOnClass と同じであり、クラスの存在確認に使う", misconception: "@ConditionalOnResource と @ConditionalOnClass を混同", explanation: "@ConditionalOnClass は JVM のクラスパス上のクラスの存在確認です。@ConditionalOnResource はファイル・リソースの存在確認であり、別物です。")
            ],
            explanationRef: "explain-boot3-adv-conditional-002",
            designIntent: "@ConditionalOnResource によるファイル存在ベースの条件付き設定を理解する。"
        ),
        quiz(
            id: "boot3-adv-conditional-003",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["@ConditionalOnSingleCandidate", "プライマリBean", "自動設定", "Bean競合"],
            code: """
@AutoConfiguration
public class CacheManagerAutoConfiguration {

    @Bean
    @ConditionalOnSingleCandidate(CacheManager.class)
    public CacheStatisticsReporter cacheStatisticsReporter(CacheManager cacheManager) {
        // CacheManager が唯一の候補である場合のみレポーターを自動設定
        return new DefaultCacheStatisticsReporter(cacheManager);
    }
}
""",
            question: "`@ConditionalOnSingleCandidate` を使う場面として正しいものはどれか？",
            choices: [
                choice("a", "指定型の Bean がコンテキストに1つだけ（またはプライマリ指定された1つが）存在する場合のみ Bean を登録し、複数候補があると曖昧になる処理の自動設定に適している", correct: true, explanation: "@ConditionalOnSingleCandidate は指定型の Bean が単一候補（または @Primary 付き）の場合のみ有効です。自動設定ライブラリで「どの Bean を使えばよいか明確な場合のみ追加設定を適用する」パターンに使います。"),
                choice("b", "@ConditionalOnSingleCandidate は Bean がコンテキストに1つも登録されていない場合のみ有効になる", misconception: "@ConditionalOnMissingBean と混同", explanation: "@ConditionalOnMissingBean が Bean の不在条件です。@ConditionalOnSingleCandidate は単一候補の存在を条件とします。"),
                choice("c", "@ConditionalOnSingleCandidate を使うと自動的に @Primary アノテーションが付与される", misconception: "条件チェックと@Primary付与を混同", explanation: "@ConditionalOnSingleCandidate は @Primary を付与しません。既存の @Primary Bean の存在を確認するための条件アノテーションです。"),
                choice("d", "@ConditionalOnSingleCandidate は Spring Boot の自動設定専用であり、アプリ側の @Configuration では使用できない", misconception: "使用場所の制約を誤解", explanation: "@ConditionalOnSingleCandidate はアプリ側の @Configuration でも使用できます。ただし自動設定ライブラリでの用途が一般的です。")
            ],
            explanationRef: "explain-boot3-adv-conditional-003",
            designIntent: "@ConditionalOnSingleCandidate による単一 Bean 前提の自動設定パターンを理解する。"
        ),
        quiz(
            id: "boot3-adv-conditional-004",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["Condition", "プログラマティック条件", "ConditionContext", "カスタム条件"],
            code: """
public class OnKubernetesCondition implements Condition {

    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        Environment env = context.getEnvironment();
        // KUBERNETES_SERVICE_HOST 環境変数が存在するかで Kubernetes 上かを判定
        return env.containsProperty("KUBERNETES_SERVICE_HOST");
    }
}

@Configuration
@Conditional(OnKubernetesCondition.class)
public class KubernetesConfig {
    @Bean
    public HealthIndicator kubernetesHealthIndicator() { ... }
}
""",
            question: "`Condition` インターフェースを直接実装するプログラマティック条件の説明として正しいものはどれか？",
            choices: [
                choice("a", "`ConditionContext` から Environment・BeanFactory・ClassLoader 等にアクセスでき、@ConditionalOn* 系アノテーションでは表現できない複雑なロジック（OS情報・環境変数の組み合わせ等）を条件に使える", correct: true, explanation: "Condition インターフェースの matches() メソッドは ConditionContext を受け取り、実行時環境の詳細な検査が可能です。組み込みの @ConditionalOn* では難しい複雑な判定ロジックをコードで表現できます。また @Conditional({A.class, B.class}) で複数条件の AND 合成もできます。"),
                choice("b", "Condition インターフェースは Spring Framework 6 で削除され、@ConditionalOnExpression で全置換された", misconception: "Condition インターフェースの廃止を誤解", explanation: "Condition インターフェースは Spring Framework 6 でも使用可能です。@ConditionalOnExpression とは用途が異なります。"),
                choice("c", "Condition の matches() はアプリ起動後も定期的に再評価されるため、動的な設定変更に使える", misconception: "条件評価のタイミングを誤解", explanation: "matches() は Bean 登録フェーズに1回評価されます。動的再評価はしません。動的設定変更には Spring Cloud Config 等が必要です。"),
                choice("d", "Condition クラスは必ず @Component として登録しなければ @Conditional で参照できない", misconception: "Condition の登録方法を誤解", explanation: "Condition 実装クラスは @Component として登録する必要はありません。@Conditional アノテーションにクラスを直接渡し、Spring が内部でインスタンス化します。")
            ],
            explanationRef: "explain-boot3-adv-conditional-004",
            designIntent: "Condition インターフェースによるプログラマティック条件の柔軟性と実装パターンを理解する。"
        ),
        quiz(
            id: "boot3-adv-conditional-005",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .architecture,
            tags: ["@Profile", "@Conditional", "組み合わせ", "環境別設定"],
            code: """
// パターン1: @Profile + @ConditionalOnProperty の組み合わせ
@Configuration
@Profile("production")
@ConditionalOnProperty(name = "feature.advanced-metrics", havingValue = "true")
public class ProductionMetricsConfig {
    // 本番 & フラグ ON の場合のみ有効
}

// パターン2: @Profile は @Conditional の特殊化
// @Profile("dev") は以下と等価
@Conditional(ProfileCondition.class) // spring.profiles.active に "dev" が含まれるか
public class DevToolsConfig {}
""",
            question: "`@Profile` と `@Conditional` 系アノテーションを組み合わせるパターンの説明として正しいものはどれか？",
            choices: [
                choice("a", "@Profile と @ConditionalOnProperty を同じクラスに付けると両方の条件を AND で評価し、複数の @Conditional 系アノテーションはすべて満たした場合にのみ Bean が登録される", correct: true, explanation: "複数の @Conditional/@Profile を組み合わせると AND 評価になります。@Profile 自体も内部的には @Conditional の実装であり、ProfileCondition が matches() を評価します。これにより「本番環境かつ特定フラグが ON」のような細かい条件設定が可能です。"),
                choice("b", "@Profile と @Conditional を同時に使うとコンパイルエラーになる", misconception: "アノテーションの組み合わせ制約を誤解", explanation: "@Profile と @Conditional は問題なく組み合わせられます。複数アノテーションの AND 評価として機能します。"),
                choice("c", "@Profile(\"production\") は @Conditional の代わりに使うことができず、常に @ConditionalOnExpression で書き直す必要がある", misconception: "@Profile の機能を過小評価", explanation: "@Profile はプロファイルベースの条件設定に適した専用アノテーションです。@ConditionalOnExpression で書き直す必要はありません。"),
                choice("d", "複数の @Conditional アノテーションを重ねると OR 評価になり、どれか1つを満たせば Bean が登録される", misconception: "AND と OR の評価を逆に理解", explanation: "複数の @Conditional アノテーションはデフォルトで AND 評価です。OR 評価が必要な場合は AnyNestedCondition を継承したカスタム条件クラスを作成します。")
            ],
            explanationRef: "explain-boot3-adv-conditional-005",
            designIntent: "@Profile と @Conditional の組み合わせパターンと AND 評価の仕組みを理解する。"
        ),
    ]
}
