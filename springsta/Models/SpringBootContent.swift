import Foundation

extension Quiz {
    static let samples: [Quiz] = {
        let all = foundationQuizzes + practiceQuizzes + boot3PlatformQuizzes + errorReadingQuizzes
            + Quiz.diQuizzes + Quiz.webMvcQuizzes + Quiz.jpaQuizzes + Quiz.configurationQuizzes
            + Quiz.testingQuizzes + Quiz.transactionQuizzes + Quiz.securityQuizzes
            + Quiz.observabilityQuizzes + Quiz.deploymentQuizzes + Quiz.architectureQuizzes
            + Quiz.errorReading2Quizzes
        var seenIds = Set<String>()
        return all
            .filter { seenIds.insert($0.id).inserted }
            .map { $0.contextualizedForPresentation() }
    }()

    static let mockExamOnlySamples: [Quiz] = []

    private static let foundationQuizzes: [Quiz] = [
        quiz(
            id: "boot3-foundation-autoconfig-001",
            level: .foundation,
            objective: "boot3-foundation-starter",
            category: .bootBasics,
            tags: ["自動設定", "starter", "条件付きBean"],
            code: """
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.SpringApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
""",
            question: "`@SpringBootApplication` に含まれる主な役割として正しいものはどれか？",
            choices: [
                choice("a", "`@Configuration`、コンポーネントスキャン、自動設定をまとめて有効にする", correct: true, explanation: "`@SpringBootApplication` は `@SpringBootConfiguration`、`@ComponentScan`、`@EnableAutoConfiguration` を含む合成アノテーションです。"),
                choice("b", "すべてのBeanを必ずシングルトンではなくプロトタイプにする", misconception: "Beanスコープを変更するものと誤解", explanation: "既定スコープはシングルトンですが、`@SpringBootApplication` が一律でスコープを変えるわけではありません。"),
                choice("c", "HTTPエンドポイントを自動で全公開する", misconception: "起動クラスだけでAPIが作られると誤解", explanation: "ControllerなどのBeanが必要です。起動クラスだけでは業務APIは公開されません。"),
                choice("d", "データベースのテーブルを必ず本番環境に作成する", misconception: "JPA設定と起動アノテーションを混同", explanation: "DDL生成はJPAや接続設定に依存します。起動アノテーション単独の効果ではありません。")
            ],
            explanationRef: "explain-boot3-foundation-autoconfig-001",
            designIntent: "Spring Bootアプリの起点と自動設定の役割を理解する。"
        ),
        quiz(
            id: "boot3-foundation-starter-web-001",
            level: .foundation,
            objective: "boot3-foundation-starter",
            category: .bootBasics,
            tags: ["starter", "組み込みサーバ", "Web"],
            code: """
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
}
""",
            question: "`spring-boot-starter-web` を追加したとき、代表的に含まれるものはどれか？",
            choices: [
                choice("a", "Spring MVCと組み込みTomcat", correct: true, explanation: "WebスターターはSpring MVC、Jackson、組み込みTomcatなどWebアプリに必要な依存関係をまとめます。"),
                choice("b", "Spring BatchとQuartzだけ", misconception: "別スターターの用途を混同", explanation: "バッチ処理は別のスターターで扱います。Webスターターの中心はHTTP/MVCです。"),
                choice("c", "PostgreSQL JDBCドライバを必ず含む", misconception: "DBドライバまで含まれると誤解", explanation: "DBドライバは利用するDBに応じて個別に追加します。"),
                choice("d", "Spring Securityのログイン画面を必ず有効にする", misconception: "Securityスターターと混同", explanation: "Securityの既定ログインはSecurityスターターを入れたときの挙動です。")
            ],
            explanationRef: "explain-boot3-foundation-starter-web-001",
            designIntent: "スターターが依存関係を束ねる仕組みと、含まれる範囲を見極める。"
        ),
        quiz(
            id: "boot3-foundation-restcontroller-001",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@RestController", "JSON", "HandlerMapping"],
            code: """
@RestController
class HelloController {
    @GetMapping("/hello")
    Message hello() {
        return new Message("Spring");
    }
}

record Message(String text) {}
""",
            question: "`GET /hello` のレスポンスとして最も適切なものはどれか？",
            choices: [
                choice("a", "`{\"text\":\"Spring\"}` のようなJSON", correct: true, explanation: "`@RestController` は戻り値をビュー名ではなくレスポンスボディとして扱い、JacksonがJSONへ変換します。"),
                choice("b", "`hello.html` テンプレート", misconception: "ControllerとRestControllerを混同", explanation: "ビューを返したい場合は通常 `@Controller` とテンプレートエンジンを使います。"),
                choice("c", "`Message` クラス名だけの文字列", misconception: "オブジェクトが自動でクラス名になると誤解", explanation: "HTTPメッセージコンバータがオブジェクトのプロパティをJSONへ変換します。"),
                choice("d", "404 Not Found", misconception: "recordを返せないと誤解", explanation: "recordもJacksonでシリアライズできます。マッピングも `/hello` に登録されています。")
            ],
            explanationRef: "explain-boot3-foundation-restcontroller-001",
            designIntent: "RestControllerの戻り値がJSONレスポンスになる流れを理解する。"
        ),
        quiz(
            id: "boot3-foundation-constructor-injection-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["DI", "コンストラクタインジェクション", "Bean"],
            code: """
@Service
class OrderService {
    private final OrderRepository repository;

    OrderService(OrderRepository repository) {
        this.repository = repository;
    }
}
""",
            question: "このコードの依存注入について正しい説明はどれか？",
            choices: [
                choice("a", "コンストラクタが1つなら `@Autowired` を省略して注入できる", correct: true, explanation: "Springは単一コンストラクタを使って依存Beanを注入できます。明示的な `@Autowired` は不要です。"),
                choice("b", "`final` フィールドにはSpringが値を入れられない", misconception: "finalとコンストラクタ注入を混同", explanation: "コンストラクタで値を受け取るため、`final` フィールドと相性が良い書き方です。"),
                choice("c", "`new OrderService()` をControllerで毎回呼ぶ必要がある", misconception: "DIコンテナの役割を見落としている", explanation: "Beanとして管理されるため、利用側もSpringから注入してもらいます。"),
                choice("d", "フィールドインジェクションだけがテストしやすい", misconception: "テスト容易性を逆に理解", explanation: "コンストラクタ注入は依存関係が明示され、テスト時にも差し替えやすいです。")
            ],
            explanationRef: "explain-boot3-foundation-constructor-injection-001",
            designIntent: "Springの基本的な依存注入と推奨されるコンストラクタ注入を確認する。"
        ),
        quiz(
            id: "boot3-foundation-bean-ambiguity-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["Bean", "@Qualifier", "@Primary"],
            code: """
interface MailSender {}

@Component
class SmtpMailSender implements MailSender {}

@Component
class SesMailSender implements MailSender {}

@Service
class NoticeService {
    NoticeService(MailSender sender) {}
}
""",
            question: "この構成で `NoticeService` を作るときに起きやすい問題はどれか？",
            choices: [
                choice("a", "`MailSender` 候補が複数あるため、どれを注入するか決められない", correct: true, explanation: "同じ型のBean候補が複数ある場合、`@Qualifier` や `@Primary` などで解決します。"),
                choice("b", "interfaceはBeanとして注入できない", misconception: "実装Beanの型解決を見落としている", explanation: "実装クラスのBeanはインターフェース型として注入できます。問題は候補が複数ある点です。"),
                choice("c", "ServiceからComponentを参照できない", misconception: "ステレオタイプの上下関係を誤解", explanation: "`@Service` も `@Component` の特殊化です。依存注入の対象にできます。"),
                choice("d", "コンストラクタ引数には必ず `@Autowired` が必要", misconception: "単一コンストラクタの省略規則を知らない", explanation: "単一コンストラクタでは `@Autowired` を省略できます。")
            ],
            explanationRef: "explain-boot3-foundation-bean-ambiguity-001",
            designIntent: "複数Bean候補の解決方法を理解する。"
        ),
        quiz(
            id: "boot3-foundation-configuration-properties-001",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["ConfigurationProperties", "外部化設定", "record"],
            code: """
@ConfigurationProperties(prefix = "app.mail")
public record MailProperties(
    String from,
    int retryCount
) {}

app:
  mail:
    from: noreply@example.com
    retry-count: 3
""",
            question: "`retry-count` はどのプロパティへ束縛されるか？",
            choices: [
                choice("a", "`retryCount`", correct: true, explanation: "Spring BootのBinderはkebab-caseとcamelCaseを緩やかに対応付けます。"),
                choice("b", "`retry-count` というフィールド名", misconception: "言語側の識別子と設定キーを混同", explanation: "コード側のプロパティ名は `retryCount` です。設定キーではkebab-caseがよく使われます。"),
                choice("c", "束縛されず常に0になる", misconception: "緩やかな名前解決を知らない", explanation: "`retry-count` は `retryCount` として解決されます。"),
                choice("d", "`from` に上書きされる", misconception: "prefix配下の個別キーを見落としている", explanation: "`from` と `retry-count` は別プロパティです。")
            ],
            explanationRef: "explain-boot3-foundation-configuration-properties-001",
            designIntent: "外部化設定の命名規則と型安全な設定クラスを理解する。"
        ),
        quiz(
            id: "boot3-foundation-profile-001",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["profile", "application.yml", "環境差分"],
            code: """
spring:
  profiles:
    active: dev
---
spring:
  config:
    activate:
      on-profile: dev
app:
  message: local
""",
            question: "この設定で有効になる `app.message` の値はどれか？",
            choices: [
                choice("a", "`local`", correct: true, explanation: "`dev` プロファイルが有効なので、`on-profile: dev` のドキュメントが読み込まれます。"),
                choice("b", "`prod`", misconception: "別プロファイルが自動で有効になると誤解", explanation: "明示されている有効プロファイルは `dev` です。"),
                choice("c", "値は設定されない", misconception: "YAMLの区切りを無視", explanation: "`---` で分かれたドキュメントのうち、条件に合うものが適用されます。"),
                choice("d", "起動時に必ずエラーになる", misconception: "profile指定自体が禁止だと誤解", explanation: "この形のプロファイル別設定はSpring Bootで一般的に使われます。")
            ],
            explanationRef: "explain-boot3-foundation-profile-001",
            designIntent: "プロファイル別設定の読み込み条件を確認する。"
        ),
        quiz(
            id: "boot3-foundation-validation-001",
            level: .foundation,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["Validation", "@Valid", "DTO"],
            code: """
record CreateUserRequest(
    @NotBlank String name,
    @Email String email
) {}

@PostMapping("/users")
UserResponse create(@Valid @RequestBody CreateUserRequest request) {
    return service.create(request);
}
""",
            question: "`name` が空文字のリクエストを送った場合の基本的な挙動はどれか？",
            choices: [
                choice("a", "Controllerメソッドに入る前にバリデーションエラーになる", correct: true, explanation: "`@Valid` によりリクエストボディのDTOが検証され、制約違反ならメソッド本体の前にエラーになります。"),
                choice("b", "`@NotBlank` はレスポンス専用なので無視される", misconception: "Bean Validationの対象を誤解", explanation: "リクエストDTOにもBean Validationを適用できます。"),
                choice("c", "空文字は自動的にnullへ変換される", misconception: "型変換と検証を混同", explanation: "`@NotBlank` はnullだけでなく空白文字も拒否します。"),
                choice("d", "Serviceで手動チェックしない限り必ず保存される", misconception: "Controller層の検証を見落としている", explanation: "`@Valid` があるため、Serviceへ渡る前に検証できます。")
            ],
            explanationRef: "explain-boot3-foundation-validation-001",
            designIntent: "DTOバリデーションの発火点とController手前で止まる流れを理解する。"
        ),
        quiz(
            id: "boot3-foundation-repository-query-001",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["Spring Data JPA", "Repository", "クエリメソッド"],
            code: """
interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
""",
            question: "`findByEmail` について正しい説明はどれか？",
            choices: [
                choice("a", "メソッド名から `email` 条件のクエリが組み立てられる", correct: true, explanation: "Spring Data JPAはリポジトリメソッド名を解析してクエリを生成できます。"),
                choice("b", "必ずSQLを文字列で書かなければ動かない", misconception: "クエリメソッドを知らない", explanation: "単純な条件ならメソッド名だけで表現できます。複雑な場合は `@Query` も使えます。"),
                choice("c", "`Optional` は戻り値に使えない", misconception: "Optional戻り値のサポートを見落としている", explanation: "0件の可能性がある検索結果に `Optional` を使えます。"),
                choice("d", "RepositoryはControllerからしか呼べない", misconception: "層の責務を混同", explanation: "通常はServiceからRepositoryを呼び出し、ControllerはServiceへ委譲します。")
            ],
            explanationRef: "explain-boot3-foundation-repository-query-001",
            designIntent: "Spring Data JPAのクエリメソッドとOptional戻り値を押さえる。"
        ),
        quiz(
            id: "boot3-foundation-actuator-health-001",
            level: .foundation,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["Actuator", "health", "運用"],
            code: """
management:
  endpoints:
    web:
      exposure:
        include: health,info
""",
            question: "この設定でWeb公開されるActuatorエンドポイントとして正しいものはどれか？",
            choices: [
                choice("a", "`/actuator/health` と `/actuator/info`", correct: true, explanation: "`include` に指定したWebエンドポイントが公開対象になります。"),
                choice("b", "すべてのActuatorエンドポイント", misconception: "include指定を全公開と誤解", explanation: "`*` を指定しない限り全公開ではありません。"),
                choice("c", "`/health` だけ", misconception: "Actuatorのベースパスを見落としている", explanation: "既定では `/actuator` 配下に公開されます。"),
                choice("d", "何も公開されない", misconception: "Actuator設定の役割を見落としている", explanation: "Actuator依存関係がある前提では、指定エンドポイントがWeb公開されます。")
            ],
            explanationRef: "explain-boot3-foundation-actuator-health-001",
            designIntent: "Actuatorの公開範囲を設定から読み取る。"
        ),
        quiz(
            id: "boot3-foundation-webmvctest-001",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@WebMvcTest", "MockMvc", "slice test"],
            code: """
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired MockMvc mvc;
    @MockBean UserService service;
}
""",
            question: "`@WebMvcTest` の特徴として正しいものはどれか？",
            choices: [
                choice("a", "MVC層を中心に読み込み、Serviceなどは必要に応じてモックする", correct: true, explanation: "`@WebMvcTest` はController周辺に絞ったスライステストです。Serviceを本物で全部起動する用途ではありません。"),
                choice("b", "本番と同じ全Beanを必ず起動する", misconception: "スライステストと統合テストを混同", explanation: "全体起動は `@SpringBootTest` が代表的です。"),
                choice("c", "HTTPサーバを必ず実ポートで起動する", misconception: "MockMvcの役割を誤解", explanation: "MockMvcでサーブレット層をテストでき、実ポート起動は不要です。"),
                choice("d", "Controllerは読み込まれない", misconception: "指定クラスの意味を逆に理解", explanation: "`UserController.class` を対象にMVCテストを構成します。")
            ],
            explanationRef: "explain-boot3-foundation-webmvctest-001",
            designIntent: "Spring Bootのテストスライスを使い分ける基礎を確認する。"
        )
    ]

    private static let practiceQuizzes: [Quiz] = [
        quiz(
            id: "boot3-practice-layered-trace-001",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .architecture,
            tags: ["Controller", "Service", "Repository", "実行トレース"],
            code: layeredTraceCombinedCode,
            codeTabs: layeredTraceTabs,
            question: "`GET /orders/42` を処理するとき、呼び出し順として正しいものはどれか？",
            choices: [
                choice("a", "Controller → Service → Repository → Service → Controller", correct: true, explanation: "HTTPリクエストはControllerで受け、業務判断をServiceへ委譲し、永続化アクセスをRepositoryへ委譲して戻ります。"),
                choice("b", "Repository → Service → Controller", misconception: "外部リクエストの入口を誤解", explanation: "RepositoryはHTTPリクエストの入口ではありません。Controllerから流れが始まります。"),
                choice("c", "Controller → Repository → Service", misconception: "ControllerがRepositoryを直接呼ぶ設計と混同", explanation: "このコードではControllerはServiceだけに依存しています。"),
                choice("d", "Service → Controller → Repository", misconception: "DIで注入された側が先に動くと誤解", explanation: "Bean生成順とリクエスト時の呼び出し順は別です。")
            ],
            explanationRef: "explain-boot3-practice-layered-trace-001",
            designIntent: "マルチファイルのController→Service→Repository実行トレースを可視化する。"
        ),
        quiz(
            id: "boot3-practice-transaction-rollback-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Transactional", "rollback", "RuntimeException"],
            code: """
@Service
class PaymentService {
    @Transactional
    void pay(Long orderId) {
        repository.markPaid(orderId);
        throw new IllegalStateException("gateway error");
    }
}
""",
            question: "既定設定で `IllegalStateException` が投げられた場合、トランザクションはどうなるか？",
            choices: [
                choice("a", "ロールバックされる", correct: true, explanation: "Springの宣言的トランザクションは、既定でRuntimeExceptionやErrorでロールバックします。"),
                choice("b", "必ずコミットされる", misconception: "例外発生時の既定ロールバックを見落としている", explanation: "未捕捉のRuntimeExceptionが境界外へ出ると既定ではロールバック対象です。"),
                choice("c", "checked exceptionだけがロールバックされる", misconception: "既定ルールを逆に理解", explanation: "checked exceptionは既定ではロールバック対象ではありません。必要なら `rollbackFor` を指定します。"),
                choice("d", "`@Transactional` はRepositoryにしか書けないため無効", misconception: "Service層の境界設計を誤解", explanation: "Serviceメソッドにトランザクション境界を置くのは一般的です。")
            ],
            explanationRef: "explain-boot3-practice-transaction-rollback-001",
            designIntent: "Springの既定ロールバック条件を理解する。"
        ),
        quiz(
            id: "boot3-practice-transaction-self-invocation-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Transactional", "proxy", "self invocation"],
            code: """
@Service
class ReportService {
    void run() {
        saveReport();
    }

    @Transactional
    void saveReport() {
        repository.save(new Report());
    }
}
""",
            question: "同じクラス内の `run()` から `saveReport()` を直接呼ぶ場合の注意点はどれか？",
            choices: [
                choice("a", "プロキシを経由しないため、`@Transactional` が期待通り効かないことがある", correct: true, explanation: "Spring AOPのプロキシ方式では、自己呼び出しはプロキシを通らず、アドバイスが適用されません。"),
                choice("b", "必ず2つのトランザクションが作られる", misconception: "アノテーションが常に発火すると誤解", explanation: "直接呼び出しではプロキシを経由しない点が問題です。"),
                choice("c", "`@Transactional` はprivateメソッドにだけ効く", misconception: "メソッド可視性とプロキシ適用を誤解", explanation: "privateメソッドは通常プロキシから呼べないため適しません。"),
                choice("d", "Repositoryを呼ぶだけならトランザクションは不要で常に安全", misconception: "永続化操作の境界を軽視", explanation: "複数操作の整合性や遅延ロードなど、境界設計は重要です。")
            ],
            explanationRef: "explain-boot3-practice-transaction-self-invocation-001",
            designIntent: "Spring AOPプロキシと自己呼び出しの落とし穴を押さえる。"
        ),
        quiz(
            id: "boot3-practice-security-chain-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["SecurityFilterChain", "authorizeHttpRequests", "permitAll"],
            code: """
@Bean
SecurityFilterChain security(HttpSecurity http) throws Exception {
    return http
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/actuator/health").permitAll()
            .anyRequest().authenticated()
        )
        .build();
}
""",
            question: "`/actuator/health` への未認証アクセスはどう扱われるか？",
            choices: [
                choice("a", "許可される", correct: true, explanation: "より具体的な `requestMatchers(\"/actuator/health\").permitAll()` が先に評価されます。"),
                choice("b", "`anyRequest().authenticated()` により必ず拒否される", misconception: "マッチャの評価順を見落としている", explanation: "先にマッチしたルールが適用されるため、healthはpermitAllです。"),
                choice("c", "CSRFトークンがないためGETでも必ず403", misconception: "CSRF対象メソッドを混同", explanation: "CSRFは主に状態変更リクエストで問題になります。GETのhealth確認とは別です。"),
                choice("d", "SecurityFilterChainはBeanにしても無視される", misconception: "コードベース設定を知らない", explanation: "Spring SecurityではBeanとしてSecurityFilterChainを定義する構成が一般的です。")
            ],
            explanationRef: "explain-boot3-practice-security-chain-001",
            designIntent: "SecurityFilterChainの認可ルールと評価順を確認する。"
        ),
        quiz(
            id: "boot3-practice-validation-advice-001",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@ControllerAdvice", "MethodArgumentNotValidException", "エラー応答"],
            code: """
@RestControllerAdvice
class ApiExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ErrorResponse> handle(MethodArgumentNotValidException ex) {
        return ResponseEntity.badRequest().body(ErrorResponse.from(ex));
    }
}
""",
            question: "このクラスの役割として最も適切なものはどれか？",
            choices: [
                choice("a", "Controllerで発生したバリデーション例外を共通の400レスポンスへ整形する", correct: true, explanation: "`@RestControllerAdvice` は複数Controllerにまたがる例外ハンドリングを定義できます。"),
                choice("b", "RepositoryのSQLを自動で最適化する", misconception: "例外ハンドラと永続化を混同", explanation: "このクラスはHTTPエラー応答の整形に関わります。"),
                choice("c", "全リクエストを認証済みにする", misconception: "Security設定と混同", explanation: "認証・認可はSecurityFilterChainなどで扱います。"),
                choice("d", "DTOの制約をすべて無効化する", misconception: "例外を握りつぶすだけだと誤解", explanation: "検証は実行され、失敗した結果をエラーレスポンスへ変換します。")
            ],
            explanationRef: "explain-boot3-practice-validation-advice-001",
            designIntent: "バリデーション失敗時のエラーハンドリング責務を理解する。"
        ),
        quiz(
            id: "boot3-practice-jpa-n-plus-one-001",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["JPA", "N+1", "fetch join"],
            code: """
@Entity
class Order {
    @ManyToOne(fetch = FetchType.LAZY)
    private Customer customer;
}

List<Order> orders = orderRepository.findAll();
orders.forEach(order -> order.getCustomer().getName());
""",
            question: "このコードで起こりやすい性能問題はどれか？",
            choices: [
                choice("a", "Order取得後にCustomer参照ごとの追加SQLが発生するN+1問題", correct: true, explanation: "LAZY関連をループ内で参照すると、件数分の追加SQLが出ることがあります。fetch joinやEntityGraphなどを検討します。"),
                choice("b", "LAZYなのでCustomerは絶対に取得されず常にnull", misconception: "遅延ロードの意味を誤解", explanation: "遅延ロードは必要になったタイミングで取得する仕組みです。"),
                choice("c", "findAllは必ず1件だけ返す", misconception: "Repositoryメソッドの意味を誤解", explanation: "`findAll()` は複数件を返します。"),
                choice("d", "`@ManyToOne` はSpring Boot 3.xでは使えない", misconception: "Jakarta移行とJPA機能を混同", explanation: "Spring Boot 3ではパッケージはjakarta系ですが、JPAの関連マッピングは使えます。")
            ],
            explanationRef: "explain-boot3-practice-jpa-n-plus-one-001",
            designIntent: "JPAの遅延ロードとN+1問題を実務視点で理解する。"
        ),
        quiz(
            id: "boot3-practice-config-precedence-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["外部化設定", "環境変数", "優先順位"],
            code: """
# application.yml
app:
  timeout: 3s

# environment
APP_TIMEOUT=10s
""",
            question: "環境変数が有効な実行環境で `app.timeout` は通常どちらが優先されるか？",
            choices: [
                choice("a", "`APP_TIMEOUT=10s`", correct: true, explanation: "Spring Bootの外部化設定では、環境変数など外部から与えた値がjar内の設定より優先される場面が一般的です。"),
                choice("b", "`application.yml` の `3s`", misconception: "jar内設定が常に最優先と誤解", explanation: "環境ごとの差し替えを可能にするため、外部設定の優先順位が高く扱われます。"),
                choice("c", "両方が連結され `3s10s` になる", misconception: "プロパティの上書きと結合を混同", explanation: "同じキーは基本的に優先順位で片方の値が選ばれます。"),
                choice("d", "同じキーがあると必ず起動失敗", misconception: "設定上書きをエラーと誤解", explanation: "同じ設定キーが複数ソースにあることは普通にあります。")
            ],
            explanationRef: "explain-boot3-practice-config-precedence-001",
            designIntent: "本番運用で重要な外部化設定の優先順位を押さえる。"
        ),
        quiz(
            id: "boot3-practice-springboottest-001",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@SpringBootTest", "RANDOM_PORT", "統合テスト"],
            code: """
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserApiTest {
    @LocalServerPort int port;
}
""",
            question: "`RANDOM_PORT` を指定する主な理由はどれか？",
            choices: [
                choice("a", "実HTTPサーバを空きポートで起動し、ポート衝突を避ける", correct: true, explanation: "統合テストで実サーバを立ち上げつつ、固定ポート競合を避けられます。"),
                choice("b", "Controllerを一切読み込まない", misconception: "統合テストとスライステストを混同", explanation: "`@SpringBootTest` はアプリケーションコンテキストを広く起動します。"),
                choice("c", "DB接続を必ず本番DBに固定する", misconception: "テスト環境設定を誤解", explanation: "DBはプロファイルやTestcontainersなどで別途制御します。"),
                choice("d", "ランダムなHTTPメソッドを選んで実行する", misconception: "ポートとメソッドを混同", explanation: "ランダムなのは待受ポートです。")
            ],
            explanationRef: "explain-boot3-practice-springboottest-001",
            designIntent: "統合テスト時のWeb環境設定を理解する。"
        )
    ]

    private static let boot3PlatformQuizzes: [Quiz] = [
        quiz(
            id: "boot3-foundation-jakarta-validation-001",
            level: .foundation,
            version: .boot3,
            objective: "boot3-foundation-starter",
            category: .bootBasics,
            tags: ["Spring Boot 3.x", "jakarta", "validation"],
            code: """
import jakarta.validation.Valid;

@RestController
class UserController {
    ResponseEntity<Void> create(@Valid @RequestBody UserRequest request) {
        return ResponseEntity.ok().build();
    }
}
""",
            question: "Spring Boot 3.x前提のこのControllerで、`@Valid` のimportとして正しい考え方はどれか？",
            choices: [
                choice("a", "`jakarta.validation.Valid` を使う", correct: true, explanation: "Spring Boot 3.xはSpring Framework 6とJakarta EE 9以降を前提にするため、Validation APIはjakarta名前空間です。"),
                choice("b", "`javax.validation.Valid` を新規コードの標準として使う", misconception: "旧来の名前空間と混同", explanation: "Spring Boot 3.x前提ではjakarta名前空間を使います。"),
                choice("c", "`@Valid` はControllerでは使えない", misconception: "Controller境界の検証を見落としている", explanation: "DTOをControllerで受け取るときに `@Valid` を付けるのは典型的です。"),
                choice("d", "`org.springframework.validation.Valid` を使う", misconception: "Spring専用アノテーションだと誤解", explanation: "`@Valid` はJakarta Validationのアノテーションです。")
            ],
            explanationRef: "explain-boot3-foundation-jakarta-validation-001",
            designIntent: "Spring Boot 3.x前提でJakarta Validationの名前空間を理解する。"
        )
    ]

    static func quiz(
        id: String,
        level: SpringTrack,
        version: SpringBootVersion = .boot3,
        objective: String,
        category: QuizCategory,
        tags: [String],
        code: String,
        codeTabs: [CodeFile]? = nil,
        question: String,
        choices: [Choice],
        explanationRef: String,
        designIntent: String
    ) -> Quiz {
        Quiz(
            id: id,
            level: level,
            examVersion: version,
            examObjectiveId: objective,
            difficulty: level == .foundation ? .foundation : .standard,
            estimatedSeconds: level == .foundation ? 75 : 120,
            isMultipleSelect: false,
            validatedByCompiler: false,
            reviewStatus: .verified,
            variantGroupId: nil,
            isMockExamOnly: false,
            category: category.rawValue,
            tags: tags,
            code: code,
            codeTabs: codeTabs,
            question: question,
            choices: choices,
            explanationRef: explanationRef,
            designIntent: designIntent
        )
    }

    static func choice(
        _ id: String,
        _ text: String,
        correct: Bool = false,
        misconception: String? = nil,
        explanation: String
    ) -> Choice {
        Choice(id: id, text: text, correct: correct, misconception: misconception, explanation: explanation)
    }

    // MARK: - エラー読解クイズ

    private static let errorReadingQuizzes: [Quiz] = [

        // ── 基礎 ──────────────────────────────────────────

        quiz(
            id: "boot3-error-port-in-use-001",
            level: .foundation,
            objective: "boot3-foundation-starter",
            category: .errorReading,
            tags: ["起動失敗", "ポート競合", "application.yml"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Description:

Web server failed to start. Port 8080 was already in use.

Action:

Identify and stop the process that's listening on port 8080
or configure this application to listen on another port.
""",
            question: "このエラーの直接原因として正しいものはどれか？",
            choices: [
                choice("a", "別のプロセスがすでに8080番ポートを使用している", correct: true,
                       explanation: "「Port 8080 was already in use」がそのままの意味です。Eclipse再起動後に前の実行が残っていたり、Tomcatが二重起動していることが多いです。`application.yml` で `server.port: 9090` などに変更するか、既存プロセスを終了します。"),
                choice("b", "`@SpringBootApplication` が重複している", misconception: "起動アノテーションとポートを混同",
                       explanation: "アノテーションの重複とポート競合は別の問題です。エラーメッセージに port という単語がある場合はポートを疑います。"),
                choice("c", "JDBCドライバが見つからない", misconception: "DB接続エラーと混同",
                       explanation: "JDBCエラーは `Failed to configure a DataSource` などで始まります。今回はWebサーバの起動失敗です。"),
                choice("d", "`application.yml` の構文が壊れている", misconception: "設定ファイルエラーと混同",
                       explanation: "YAMLの構文エラーは `Caused by: org.yaml.snakeyaml.scanner.ScannerException` が出ます。")
            ],
            explanationRef: "explain-boot3-error-port-in-use-001",
            designIntent: "最も頻出の起動エラーをコンソールから即座に読み取る。"
        ),

        quiz(
            id: "boot3-error-no-bean-found-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .errorReading,
            tags: ["UnsatisfiedDependencyException", "Bean未検出", "@Component"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Description:

Parameter 0 of constructor in
  com.example.demo.UserService required a bean of type
  'com.example.demo.UserRepository' that could not be found.

Action:

Consider defining a bean of type 'com.example.demo.UserRepository'
in your configuration.
""",
            question: "このエラーを解消する最も直接的な対処として正しいものはどれか？",
            choices: [
                choice("a", "`UserRepository` インターフェースに `@Repository` を付けるか、`JpaRepository` を継承させる", correct: true,
                       explanation: "`required a bean of type 'UserRepository' that could not be found` はSpringがそのBeanを管理していないことを意味します。`@Repository` や `JpaRepository` 継承でBeanとして登録します。"),
                choice("b", "`UserService` を `static` クラスに変更する", misconception: "staticとBeanライフサイクルを混同",
                       explanation: "staticにしてもDIの問題は解決しません。Beanとして登録することが必要です。"),
                choice("c", "`application.yml` に `spring.jpa.enabled=false` を追加する", misconception: "機能無効化で回避しようとする誤り",
                       explanation: "JPAを無効化しても依存性の未解決は解決しません。"),
                choice("d", "`UserService` のコンストラクタ引数を0個にする", misconception: "引数なしにすれば動くと誤解",
                       explanation: "依存が必要なのに引数を消すとサービスが機能しなくなります。")
            ],
            explanationRef: "explain-boot3-error-no-bean-found-001",
            designIntent: "DI失敗の定番エラーを読んで@Componentまたは継承で解決できるようにする。"
        ),

        quiz(
            id: "boot3-error-no-unique-bean-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .errorReading,
            tags: ["NoUniqueBeanDefinitionException", "Bean競合", "@Primary", "@Qualifier"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Description:

Parameter 0 of constructor in com.example.demo.OrderService
required a single bean, but 2 were found:
  - jpaMemberRepository: defined in file [...JpaMemberRepository.class]
  - mockMemberRepository: defined in file [...MockMemberRepository.class]

Action:

Consider marking one of the beans as @Primary, updating the
consumer to accept multiple beans, or using @Qualifier to identify
the bean that should be consumed.
""",
            question: "このエラーが示す問題と推奨される対処の組み合わせとして正しいものはどれか？",
            choices: [
                choice("a", "同一インターフェースにBean候補が2つあるため `@Primary` または `@Qualifier` で1つに絞る", correct: true,
                       explanation: "`required a single bean, but 2 were found` がそのままの意味です。エラーメッセージ内の「Action」に解決策まで書かれています。本番用とモック用が両方Beanになっている典型パターンです。"),
                choice("b", "Beanが1つも見つからないため `@Component` を追加する", misconception: "Bean未検出エラーと混同",
                       explanation: "このエラーは多すぎる（2つ）が問題です。Bean未検出は `could not be found` というメッセージになります。"),
                choice("c", "`OrderService` のコンストラクタを `@Autowired` なしにする", misconception: "DIを外せば解決すると誤解",
                       explanation: "DIを外すと依存が解決されず、null参照になります。"),
                choice("d", "`spring.main.allow-bean-definition-overriding=true` で強制的に片方を上書きする", misconception: "上書き許可で解決できると思い込む",
                       explanation: "Bean上書きは定義の順序依存で意図しない動作になりやすく、推奨されません。")
            ],
            explanationRef: "explain-boot3-error-no-unique-bean-001",
            designIntent: "Beanの競合エラーを読んで@Primary/@Qualifierによる解決策を導ける。"
        ),

        quiz(
            id: "boot3-error-placeholder-001",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .errorReading,
            tags: ["Could not resolve placeholder", "application.yml", "@Value"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Description:

Could not resolve placeholder 'app.api-key' in value
"${app.api-key}"

Action:

Ensure that 'app.api-key' is defined in your configuration.
""",
            question: "このエラーが起きる典型的な原因はどれか？",
            choices: [
                choice("a", "`application.yml` に `app.api-key` キーが定義されていないか、プロパティ名のタイポがある", correct: true,
                       explanation: "`@Value(\"${app.api-key}\")` でSpringが値を注入しようとしたが、対応するキーがどのプロパティソースにも見つからない状態です。YAMLのインデントやケバブケース表記も確認します。"),
                choice("b", "APIキーが短すぎてセキュリティ検証に失敗した", misconception: "Spring Securityの検証ロジックと混同",
                       explanation: "このエラーはSpringがプロパティを解決できなかった段階で起きます。値の内容は関係ありません。"),
                choice("c", "`@Component` を付け忘れた", misconception: "Bean未登録エラーと混同",
                       explanation: "placeholder解決失敗はプロパティファイルの問題です。Beanの登録とは別です。"),
                choice("d", "`application.yml` の代わりに `application.properties` が必要", misconception: "ファイル形式を変えれば解決すると誤解",
                       explanation: "SpringはYAMLもpropertiesも読みます。どちらでもキーが存在しなければ同じエラーになります。")
            ],
            explanationRef: "explain-boot3-error-placeholder-001",
            designIntent: "設定値の未定義エラーを読んでapplication.ymlのキー確認へ導ける。"
        ),

        quiz(
            id: "boot3-error-null-di-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .errorReading,
            tags: ["NullPointerException", "フィールドインジェクション", "new演算子"],
            code: """
java.lang.NullPointerException: Cannot invoke
  "com.example.demo.UserRepository.findById(Long)"
  because "this.userRepository" is null

  at com.example.demo.UserService.findUser(UserService.java:18)
  at com.example.demo.UserController.getUser(UserController.java:25)
""",
            question: "スタックトレースからこのNullPointerExceptionの最も可能性が高い原因はどれか？",
            choices: [
                choice("a", "`UserService` を `new UserService()` で生成したためDIが機能せず `userRepository` が null", correct: true,
                       explanation: "SpringのDIはSpringが管理するBeanにしか働きません。`new` で自前生成したインスタンスのフィールドにはインジェクションされず null のままになります。Controllerで `new UserService()` していないか確認します。"),
                choice("b", "`UserRepository` に `@Repository` がない", misconception: "Bean未登録を原因と見誤る",
                       explanation: "Beanが未登録なら起動時に `UnsatisfiedDependencyException` が出て起動失敗します。起動後のNPEとは別問題です。"),
                choice("c", "`findById` の引数が null で渡された", misconception: "引数nullとフィールドnullを混同",
                       explanation: "エラーメッセージは `this.userRepository` が null と言っています。引数の問題ではありません。"),
                choice("d", "Spring Boot 3.xではフィールドインジェクションがデフォルトで無効", misconception: "バージョン変更でDI方式が廃止されたと誤解",
                       explanation: "フィールドインジェクション自体は3.xでも動きます。ただし `new` での生成はどのバージョンでもDIが効きません。")
            ],
            explanationRef: "explain-boot3-error-null-di-001",
            designIntent: "起動後NPEからDI未適用（new生成）を読み取れる。"
        ),

        // ── 実践 ──────────────────────────────────────────

        quiz(
            id: "boot3-error-lazy-init-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["LazyInitializationException", "@Transactional", "遅延ロード"],
            code: """
org.hibernate.LazyInitializationException:
  failed to lazily initialize a collection of role:
  com.example.demo.Order.items,
  could not initialize proxy - no Session

  at org.hibernate.proxy.AbstractLazyInitializer.initialize(...)
  at com.example.demo.OrderService.getOrderItems(OrderService.java:34)
""",
            question: "このエラーの直接原因と修正方法の組み合わせとして正しいものはどれか？",
            choices: [
                choice("a", "Hibernateセッションが閉じた後で遅延ロードを試みている。`getOrderItems()` に `@Transactional` を付けてセッションを維持する", correct: true,
                       explanation: "LAZY関連はHibernateセッション内でのみ初期化できます。セッションが閉じた後（トランザクション外）でアクセスするとこのエラーが出ます。メソッドに `@Transactional` を付けるとセッションが維持されます。"),
                choice("b", "`Order` クラスに `@Entity` がないためDBから取得できない", misconception: "エンティティ定義エラーと混同",
                       explanation: "@Entityがなければ起動時かクエリ実行時にエラーが出ます。LazyInitializationExceptionはエンティティは取得できているが関連の初期化に失敗しています。"),
                choice("c", "`Order.items` の型を `List` から `Set` に変更する", misconception: "コレクション型を変えれば解決すると誤解",
                       explanation: "コレクション型はセッション有無の問題と無関係です。"),
                choice("d", "`spring.jpa.open-in-view=true` を設定する", misconception: "quick fixとして有効に見えるが設計上の問題",
                       explanation: "open-in-view は応急措置として動くことがありますが、ビュー層にDBセッションを開放するアンチパターンです。正しくは `@Transactional` でサービス層でセッションを管理します。")
            ],
            explanationRef: "explain-boot3-error-lazy-init-001",
            designIntent: "LazyInitializationExceptionから@Transactionalの必要性を逆引きできる。"
        ),

        quiz(
            id: "boot3-error-data-integrity-001",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["DataIntegrityViolationException", "Unique制約", "DB制約"],
            code: """
org.springframework.dao.DataIntegrityViolationException:
  could not execute statement
  [ERROR: duplicate key value violates unique constraint "users_email_key"
   Detail: Key (email)=(test@example.com) already exists.]

  at ...UserService.register(UserService.java:42)
  at ...UserController.registerUser(UserController.java:31)
""",
            question: "このエラーから読み取れる状況と対処として正しいものはどれか？",
            choices: [
                choice("a", "DBのemail列にUNIQUE制約があり、同じメールアドレスが重複登録された。保存前にメールアドレスの存在確認を行う", correct: true,
                       explanation: "`duplicate key value violates unique constraint` とDetailの `(email)=(...) already exists` から明確です。`UserRepository.existsByEmail()` などで事前チェックし、重複時は業務エラーとして400を返す設計が一般的です。"),
                choice("b", "`@Email` アノテーションがDTOに付いていない", misconception: "バリデーションエラーと制約違反を混同",
                       explanation: "バリデーション失敗は `MethodArgumentNotValidException` (HTTP 400)です。このエラーはDBレベルで起きた制約違反です。"),
                choice("c", "HibernateがSQLを生成できないというエラー", misconception: "SQL生成失敗と混同",
                       explanation: "SQL生成の問題であれば `HibernateException` や `SQLGrammarException` が出ます。このエラーはSQLは実行されたがDBが拒否した結果です。"),
                choice("d", "`@Id` に `@GeneratedValue` が付いていない", misconception: "主キー生成の問題と混同",
                       explanation: "主キーの生成問題ではなくemail列のUNIQUE制約の問題です。エラーの `users_email_key` という制約名が手がかりです。")
            ],
            explanationRef: "explain-boot3-error-data-integrity-001",
            designIntent: "DB制約違反エラーを読んでサービス層での事前チェックに結びつける。"
        ),

        quiz(
            id: "boot3-error-method-not-allowed-001",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["405", "HttpRequestMethodNotSupportedException", "RequestMapping"],
            code: """
{
  "timestamp": "2024-08-01T10:23:45.123+00:00",
  "status": 405,
  "error": "Method Not Allowed",
  "path": "/api/users/42"
}

// Eclipseコンソール:
o.s.web.servlet.DispatcherServlet:
  Completed 405 METHOD_NOT_ALLOWED

jakarta.servlet.ServletException:
  Request method 'POST' not supported
""",
            question: "HTTP 405 Method Not Allowed のエラーが出た場合の最も可能性が高い原因はどれか？",
            choices: [
                choice("a", "エンドポイント `/api/users/42` は `GET` のみ受け付けるが、クライアントが `POST` でリクエストした", correct: true,
                       explanation: "`Request method 'POST' not supported` がそのままの意味です。Controllerの `@GetMapping` に対して `POST` を送るとこうなります。ControllerのアノテーションとクライアントのHTTPメソッドを合わせます。"),
                choice("b", "ユーザーID 42 がDBに存在しない", misconception: "404 Not Foundと混同",
                       explanation: "リソースが存在しない場合は404です。405はリソースはあるがHTTPメソッドが違う場合です。"),
                choice("c", "Spring Securityが認証されていないリクエストを拒否した", misconception: "401/403と混同",
                       explanation: "認証・認可の失敗は401 Unauthorized または 403 Forbidden です。405はHTTPメソッドの不一致です。"),
                choice("d", "`application.yml` の `server.port` 設定が誤っている", misconception: "ポート設定エラーと混同",
                       explanation: "ポート設定の問題は接続自体が失敗します。405は接続には成功しているがメソッドが合っていない状態です。")
            ],
            explanationRef: "explain-boot3-error-method-not-allowed-001",
            designIntent: "HTTPステータスコードとエラー文からリクエストの問題を特定できる。"
        ),

        quiz(
            id: "boot3-error-validation-400-001",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .errorReading,
            tags: ["400", "MethodArgumentNotValidException", "@Valid", "バリデーション"],
            code: """
{
  "timestamp": "2024-08-01T11:05:22.456+00:00",
  "status": 400,
  "error": "Bad Request",
  "path": "/api/users"
}

// Eclipseコンソール:
o.s.w.s.m.m.a.MethodArgumentNotValidException:
  Validation failed for argument [0] in
  public ResponseEntity createUser(UserRequest):
  [Field error in object 'userRequest' on field 'email':
   rejected value [null]; codes [...NotBlank...];
   default message [空白は許可されていません]]
""",
            question: "このエラーが発生している原因として正しいものはどれか？",
            choices: [
                choice("a", "リクエストJSONに `email` フィールドが含まれていないか null で、DTOに `@NotBlank` 等の制約がある", correct: true,
                       explanation: "`Field error on field 'email': rejected value [null]` と `NotBlank` が証拠です。Controllerの引数に `@Valid` が付いており、DTOの `email` が null 不可なのにリクエストで渡されなかった状態です。"),
                choice("b", "DBのemailカラムがNULL不可のためINSERTが失敗した", misconception: "DB制約違反と混同",
                       explanation: "DB制約違反は `DataIntegrityViolationException` です。このエラーはDBに到達する前のバリデーション段階で止まっています。"),
                choice("c", "`UserRequest` クラスに `@RequestBody` アノテーションがない", misconception: "バインディング失敗と混同",
                       explanation: "`@RequestBody` がなければ `HttpMessageNotReadableException` が出ます。このエラーはバインディング後のバリデーション失敗です。"),
                choice("d", "Spring Security が POST リクエストの CSRF トークンを検証した", misconception: "CSRFエラーと混同",
                       explanation: "CSRFエラーは403 Forbiddenです。このエラーは400 Bad Requestでバリデーション失敗です。")
            ],
            explanationRef: "explain-boot3-error-validation-400-001",
            designIntent: "バリデーション失敗のエラーログからDTOのフィールドとリクエストの不一致を特定できる。"
        ),

        quiz(
            id: "boot3-error-transaction-required-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["TransactionRequiredException", "@Transactional", "書き込み操作"],
            code: """
jakarta.persistence.TransactionRequiredException:
  Executing an update/delete query

  at org.hibernate.query.sqm.internal.QuerySqmImpl
    .verifyUpdateOrDeleteType(QuerySqmImpl.java:...)
  at com.example.demo.UserRepository
    .deactivateUser(UserRepository.java:12)
  at com.example.demo.UserService
    .deactivate(UserService.java:27)
""",
            question: "このエラーが発生する理由と修正方法として正しいものはどれか？",
            choices: [
                choice("a", "UPDATE/DELETE クエリをトランザクション外で実行しようとした。`deactivate()` メソッドに `@Transactional` を付ける", correct: true,
                       explanation: "`Executing an update/delete query` と `TransactionRequiredException` がセットです。Hibernateは書き込み操作にトランザクションを必須とします。Repositoryのカスタムクエリを呼ぶサービスメソッドに `@Transactional` を付けます。"),
                choice("b", "`@Query` アノテーションに `@Modifying` が付いていない", misconception: "部分的に正しいが根本原因ではない",
                       explanation: "`@Modifying` も必要ですが、エラーメッセージの根本は `TransactionRequiredException` です。`@Transactional` なしでは `@Modifying` があっても同じエラーが出ます。"),
                choice("c", "DB接続プールの上限に達してコネクションが取得できない", misconception: "コネクションプール枯渇と混同",
                       explanation: "プール枯渇は `Unable to acquire JDBC Connection` などが出ます。このエラーはトランザクション管理の問題です。"),
                choice("d", "`UserRepository` に `@Repository` が付いていない", misconception: "Bean未登録と混同",
                       explanation: "Bean未登録なら起動時に失敗します。このエラーは実行時にトランザクションが存在しないというエラーです。")
            ],
            explanationRef: "explain-boot3-error-transaction-required-001",
            designIntent: "書き込みクエリに@Transactionalが必要なことをエラーから逆引きできる。"
        ),
    ]

    static let layeredTraceCombinedCode = """
// OrderController.java
@RestController
@RequestMapping("/orders")
class OrderController {
    private final OrderService service;

    @GetMapping("/{id}")
    OrderResponse show(@PathVariable Long id) {
        return service.find(id);
    }
}

// OrderService.java
@Service
class OrderService {
    private final OrderRepository repository;

    @Transactional(readOnly = true)
    OrderResponse find(Long id) {
        Order order = repository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        return OrderResponse.from(order);
    }
}

// OrderRepository.java
interface OrderRepository extends JpaRepository<Order, Long> {}
"""

    static let layeredTraceTabs: [CodeFile] = [
        CodeFile(
            filename: "OrderController.java",
            code: """
@RestController
@RequestMapping("/orders")
class OrderController {
    private final OrderService service;

    @GetMapping("/{id}")
    OrderResponse show(@PathVariable Long id) {
        return service.find(id);
    }
}
"""
        ),
        CodeFile(
            filename: "OrderService.java",
            code: """
@Service
class OrderService {
    private final OrderRepository repository;

    @Transactional(readOnly = true)
    OrderResponse find(Long id) {
        Order order = repository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND));
        return OrderResponse.from(order);
    }
}
"""
        ),
        CodeFile(
            filename: "OrderRepository.java",
            code: """
interface OrderRepository extends JpaRepository<Order, Long> {}
"""
        )
    ]
}

extension Lesson {
    static let samples: [Lesson] = [
        bootApplicationBasics,
        dependencyInjection,
        restController,
        configurationProfiles,
        persistenceTransactions,
        layeredArchitecture,
        testingObservability
    ]

    private static let sampleIndex: [String: Lesson] =
        Dictionary(uniqueKeysWithValues: samples.map { ($0.id, $0) })

    static func sample(for id: String) -> Lesson? {
        sampleIndex[id]
    }

    private static let bootApplicationBasics = Lesson(
        id: "lesson-boot-application-basics",
        level: .foundation,
        category: QuizCategory.bootBasics.rawValue,
        title: "Spring Bootアプリの起動と自動設定",
        summary: "起動クラス、スターター、自動設定の関係を押さえる",
        estimatedMinutes: 7,
        sections: [
            Section(
                id: "s1",
                heading: "Spring Bootの入口",
                body: "`@SpringBootApplication` は、設定クラス、コンポーネントスキャン、自動設定をまとめて有効にします。起動時は `SpringApplication.run(...)` がアプリケーションコンテキストを作り、必要な[Bean](springsta://term/bean)を登録します。",
                code: """
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
""",
                highlightLines: [1, 4],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "スターターは依存関係のセット",
                body: "`spring-boot-starter-web` を入れると、Spring MVC、Jackson、組み込みTomcatなどWeb APIに必要な依存がまとめて入ります。スターターは「機能を直接実装する魔法」ではなく、よく使う依存関係の束です。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "何が有効になるかは依存関係と自動設定条件で決まります。")
            )
        ],
        keyPoints: [
            "`@SpringBootApplication` は起動設定の合成アノテーション",
            "スターターは関連依存のセット",
            "自動設定は条件に合うBeanを補助的に登録する"
        ],
        relatedQuizIds: ["boot3-foundation-autoconfig-001", "boot3-foundation-starter-web-001"]
    )

    private static let dependencyInjection = Lesson(
        id: "lesson-dependency-injection",
        level: .foundation,
        category: QuizCategory.dependencyInjection.rawValue,
        title: "DIとBeanの基本",
        summary: "ServiceやRepositoryをSpringに管理させ、依存関係をコンストラクタで受け取る",
        estimatedMinutes: 8,
        sections: [
            Section(
                id: "s1",
                heading: "Beanとして管理する",
                body: "`@Service`、`@Repository`、`@Component` が付いたクラスはコンポーネントスキャンで見つかり、[ApplicationContext](springsta://term/application-context)に[Bean](springsta://term/bean)として登録されます。",
                code: """
@Service
class OrderService {
    private final OrderRepository repository;

    OrderService(OrderRepository repository) {
        this.repository = repository;
    }
}
""",
                highlightLines: [1, 5],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "複数候補は明示する",
                body: "同じ型のBeanが複数あると、Springはどれを注入するべきか判断できません。`@Qualifier` や `@Primary` で意図を明示します。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .warning, text: "候補が複数ある時の曖昧さは、起動時エラーとして表面化します。")
            )
        ],
        keyPoints: [
            "BeanはSpringコンテナが生成・保持するオブジェクト",
            "コンストラクタ注入は依存関係が明確",
            "複数候補はQualifierかPrimaryで解決する"
        ],
        relatedQuizIds: ["boot3-foundation-constructor-injection-001", "boot3-foundation-bean-ambiguity-001"]
    )

    private static let restController = Lesson(
        id: "lesson-rest-controller",
        level: .foundation,
        category: QuizCategory.webMvc.rawValue,
        title: "REST ControllerとDTO",
        summary: "HTTPリクエストを受け、DTOをJSONとして返す基本形",
        estimatedMinutes: 8,
        sections: [
            Section(
                id: "s1",
                heading: "RestControllerはレスポンスボディを返す",
                body: "`@RestController` の戻り値はビュー名ではなくレスポンスボディとして扱われます。recordやDTOはJacksonによりJSONへ変換されます。",
                code: """
@RestController
class HelloController {
    @GetMapping("/hello")
    Message hello() {
        return new Message("Spring");
    }
}

record Message(String text) {}
""",
                highlightLines: [1, 3, 5],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "入力はDTOで受けて検証する",
                body: "リクエストボディはDTOで受け、`@Valid` とBean Validationで境界チェックします。Serviceへ渡る前に不正入力を止めると、業務ロジックが読みやすくなります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "Controllerは薄く、入力変換とHTTP応答の責務に寄せるのが基本です。")
            )
        ],
        keyPoints: [
            "`@RestController` はJSON API向け",
            "`@RequestBody` とDTOで入力を受ける",
            "`@Valid` でController境界の検証を行う"
        ],
        relatedQuizIds: ["boot3-foundation-restcontroller-001", "boot3-foundation-validation-001"]
    )

    private static let configurationProfiles = Lesson(
        id: "lesson-configuration-profiles",
        level: .foundation,
        category: QuizCategory.configuration.rawValue,
        title: "設定とプロファイル",
        summary: "application.yml、環境変数、プロファイルで環境差分を扱う",
        estimatedMinutes: 7,
        sections: [
            Section(
                id: "s1",
                heading: "設定は外に出す",
                body: "URL、タイムアウト、機能フラグなどはコードに直書きせず、外部化設定として扱います。`@ConfigurationProperties` を使うと型安全に設定を受け取れます。",
                code: """
@ConfigurationProperties(prefix = "app.mail")
public record MailProperties(String from, int retryCount) {}
""",
                highlightLines: [1, 2],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "プロファイルで環境を分ける",
                body: "開発、検証、本番で違う設定は[プロファイル](springsta://term/profile)で切り替えます。環境変数はコンテナ実行時の差し替えにも向いています。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .warning, text: "秘密情報はリポジトリへ入れず、環境変数やシークレット管理へ逃がします。")
            )
        ],
        keyPoints: [
            "設定はコードから分離する",
            "ConfigurationPropertiesで型安全に束縛する",
            "プロファイルと環境変数で実行環境ごとに切り替える"
        ],
        relatedQuizIds: ["boot3-foundation-configuration-properties-001", "boot3-foundation-profile-001", "boot3-practice-config-precedence-001"]
    )

    private static let persistenceTransactions = Lesson(
        id: "lesson-persistence-transactions",
        level: .practice,
        category: QuizCategory.transactions.rawValue,
        title: "Repositoryとトランザクション",
        summary: "永続化アクセスをRepositoryへ閉じ込め、Serviceにトランザクション境界を置く",
        estimatedMinutes: 10,
        sections: [
            Section(
                id: "s1",
                heading: "Repositoryはデータアクセス担当",
                body: "Spring Data JPAのRepositoryはEntityの保存や検索を担当します。Controllerから直接呼ぶより、Serviceを挟んで業務ルールとトランザクション境界をまとめます。",
                code: """
interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}
""",
                highlightLines: [1, 2],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "Serviceに境界を置く",
                body: "`@Transactional` は複数のRepository操作をひとまとまりに扱うための境界です。既定ではRuntimeExceptionでロールバックされます。",
                code: """
@Transactional
void pay(Long orderId) {
    repository.markPaid(orderId);
    gateway.charge(orderId);
}
""",
                highlightLines: [1],
                callout: Callout(kind: .exam, text: "自己呼び出しはプロキシを通らないため、トランザクションが効かない落とし穴があります。")
            )
        ],
        keyPoints: [
            "Repositoryは永続化アクセスの窓口",
            "Serviceは業務処理とトランザクション境界を持つ",
            "RuntimeExceptionは既定でロールバック対象"
        ],
        relatedQuizIds: ["boot3-foundation-repository-query-001", "boot3-practice-transaction-rollback-001", "boot3-practice-transaction-self-invocation-001"]
    )

    private static let layeredArchitecture = Lesson(
        id: "lesson-layered-architecture",
        level: .practice,
        category: QuizCategory.architecture.rawValue,
        title: "Controller → Service → Repositoryをまたぐ実行トレース",
        summary: "マルチファイルでHTTPリクエストの流れを追う",
        estimatedMinutes: 9,
        sections: [
            Section(
                id: "s1",
                heading: "入口はController",
                body: "HTTPリクエストはControllerで受けます。ControllerはHTTP表現に集中し、業務判断をServiceへ渡します。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "Serviceが業務の中心",
                body: "ServiceはRepositoryを呼び、EntityをDTOへ変換し、トランザクション境界を持ちます。Repositoryは永続化の詳細に閉じ込めます。",
                code: Quiz.layeredTraceCombinedCode,
                highlightLines: [7, 19, 20],
                callout: Callout(kind: .tip, text: "Springstaではこの流れをステップ実行で可視化します。")
            )
        ],
        keyPoints: [
            "ControllerはHTTP境界",
            "Serviceは業務判断とトランザクション境界",
            "Repositoryはデータアクセス"
        ],
        relatedQuizIds: ["boot3-practice-layered-trace-001"]
    )

    private static let testingObservability = Lesson(
        id: "lesson-testing-observability",
        level: .practice,
        category: QuizCategory.testing.rawValue,
        title: "テストと運用監視",
        summary: "スライステスト、統合テスト、Actuatorを使い分ける",
        estimatedMinutes: 8,
        sections: [
            Section(
                id: "s1",
                heading: "テストは目的で選ぶ",
                body: "Controllerだけを素早く確かめたいなら `@WebMvcTest`、アプリ全体を起動して確認したいなら `@SpringBootTest` を使います。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "Actuatorで運用状態を見る",
                body: "[Actuator](springsta://term/actuator) はヘルスチェックやメトリクスなど、運用に必要なエンドポイントを提供します。公開範囲は必要最小限にします。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .warning, text: "本番でActuatorを広く公開する場合は認証・ネットワーク制限を必ず設計します。")
            )
        ],
        keyPoints: [
            "@WebMvcTestはMVCスライス",
            "@SpringBootTestは統合テスト向け",
            "Actuatorは公開範囲を絞る"
        ],
        relatedQuizIds: ["boot3-foundation-webmvctest-001", "boot3-practice-springboottest-001", "boot3-foundation-actuator-health-001"]
    )
}

extension GlossaryTerm {
    static let samples: [GlossaryTerm] = [
        term(
            id: "bean",
            term: "Bean",
            aliases: ["Spring Bean", "管理オブジェクト"],
            summary: "Springコンテナが生成・管理するオブジェクト。",
            body: "BeanはSpringのApplicationContextに登録されるオブジェクトです。`@Service` や `@Repository` などで検出され、必要な場所へ依存注入されます。",
            related: ["application-context", "dependency-injection"],
            lessons: ["lesson-dependency-injection"],
            quizzes: ["boot3-foundation-constructor-injection-001"]
        ),
        term(
            id: "application-context",
            term: "ApplicationContext",
            aliases: ["Springコンテナ", "DIコンテナ"],
            summary: "Beanを生成・保持し、依存関係を解決するSpringの中心。",
            body: "ApplicationContextはBean定義を読み込み、オブジェクトを生成し、依存関係をつなぎます。Spring Boot起動時に作られ、アプリ全体の土台になります。",
            related: ["bean", "auto-configuration"],
            lessons: ["lesson-boot-application-basics"],
            quizzes: ["boot3-foundation-autoconfig-001"]
        ),
        term(
            id: "auto-configuration",
            term: "自動設定",
            aliases: ["Auto Configuration", "EnableAutoConfiguration"],
            summary: "依存関係や既存Beanを見て、必要な設定をSpring Bootが補う仕組み。",
            body: "自動設定は、クラスパスや既存Beanなどの条件を見て、よく使うBeanを補助的に登録します。手動設定がある場合はそれを尊重する設計が多くなっています。",
            related: ["starter", "bean"],
            lessons: ["lesson-boot-application-basics"],
            quizzes: ["boot3-foundation-autoconfig-001"]
        ),
        term(
            id: "starter",
            term: "スターター",
            aliases: ["Spring Boot Starter"],
            summary: "用途別の依存関係をまとめたSpring Bootの依存パッケージ。",
            body: "`spring-boot-starter-web` のように、WebやJPAなど用途ごとに必要な依存をまとめます。スターターを入れることで関連する自動設定も働きやすくなります。",
            related: ["auto-configuration"],
            lessons: ["lesson-boot-application-basics"],
            quizzes: ["boot3-foundation-starter-web-001"]
        ),
        term(
            id: "dependency-injection",
            term: "依存注入",
            aliases: ["DI", "Dependency Injection"],
            summary: "必要な依存オブジェクトを自分でnewせず、外から受け取る設計。",
            body: "依存注入では、利用クラスが依存オブジェクトを直接生成せず、コンストラクタなどで受け取ります。SpringはBean同士の依存関係を解決して注入します。",
            related: ["bean", "application-context"],
            lessons: ["lesson-dependency-injection"],
            quizzes: ["boot3-foundation-constructor-injection-001", "boot3-foundation-bean-ambiguity-001"]
        ),
        term(
            id: "rest-controller",
            term: "RestController",
            aliases: ["@RestController", "REST API"],
            summary: "戻り値をHTTPレスポンスボディとして返すController。",
            body: "`@RestController` は `@Controller` と `@ResponseBody` を合わせたような役割です。DTOやrecordを返すとJSONへ変換されます。",
            related: ["dto", "validation"],
            lessons: ["lesson-rest-controller"],
            quizzes: ["boot3-foundation-restcontroller-001"]
        ),
        term(
            id: "dto",
            term: "DTO",
            aliases: ["Data Transfer Object", "Request DTO", "Response DTO"],
            summary: "API境界で入出力データを表すオブジェクト。",
            body: "DTOはControllerの入力や出力に使うデータ形です。Entityをそのまま外へ出さず、APIで必要な項目だけを表現できます。",
            related: ["rest-controller", "validation"],
            lessons: ["lesson-rest-controller"],
            quizzes: ["boot3-foundation-validation-001"]
        ),
        term(
            id: "validation",
            term: "Bean Validation",
            aliases: ["@Valid", "Jakarta Validation", "入力検証"],
            summary: "DTOやプロパティに制約を付け、入力を検証する仕組み。",
            body: "`@NotBlank` や `@Email` などの制約をDTOへ付け、Controller引数に `@Valid` を付けるとリクエスト入力を検証できます。",
            related: ["dto", "controller-advice"],
            lessons: ["lesson-rest-controller"],
            quizzes: ["boot3-foundation-validation-001", "boot3-practice-validation-advice-001"]
        ),
        term(
            id: "controller-advice",
            term: "ControllerAdvice",
            aliases: ["@RestControllerAdvice", "共通例外ハンドラ"],
            summary: "複数Controllerにまたがる例外処理をまとめる仕組み。",
            body: "`@RestControllerAdvice` と `@ExceptionHandler` を使うと、バリデーションエラーなどを共通形式のレスポンスへ変換できます。",
            related: ["validation", "rest-controller"],
            lessons: ["lesson-rest-controller"],
            quizzes: ["boot3-practice-validation-advice-001"]
        ),
        term(
            id: "configuration-properties",
            term: "ConfigurationProperties",
            aliases: ["@ConfigurationProperties", "型安全な設定"],
            summary: "設定値を型付きオブジェクトへ束縛する仕組み。",
            body: "`@ConfigurationProperties(prefix = \"app\")` のように設定クラスを作ると、YAMLや環境変数の値を型安全に受け取れます。",
            related: ["profile", "externalized-configuration"],
            lessons: ["lesson-configuration-profiles"],
            quizzes: ["boot3-foundation-configuration-properties-001"]
        ),
        term(
            id: "profile",
            term: "プロファイル",
            aliases: ["Spring Profile", "dev", "prod"],
            summary: "環境ごとに有効化するBeanや設定を切り替える仕組み。",
            body: "プロファイルを使うと、開発・検証・本番などの設定差分を分けられます。`spring.config.activate.on-profile` でプロファイル別YAMLを定義できます。",
            related: ["externalized-configuration"],
            lessons: ["lesson-configuration-profiles"],
            quizzes: ["boot3-foundation-profile-001"]
        ),
        term(
            id: "externalized-configuration",
            term: "外部化設定",
            aliases: ["Externalized Configuration", "環境変数"],
            summary: "コード外から設定値を与え、環境ごとに差し替える考え方。",
            body: "外部化設定により、同じビルド成果物を環境変数や設定ファイルで切り替えて動かせます。コンテナ運用では特に重要です。",
            related: ["profile", "configuration-properties"],
            lessons: ["lesson-configuration-profiles"],
            quizzes: ["boot3-practice-config-precedence-001"]
        ),
        term(
            id: "repository",
            term: "Repository",
            aliases: ["Spring Data Repository", "JpaRepository"],
            summary: "Entityの保存や検索を担当するデータアクセス層。",
            body: "Repositoryは永続化アクセスを抽象化します。Spring Data JPAではメソッド名からクエリを生成するクエリメソッドも使えます。",
            related: ["transaction", "jpa"],
            lessons: ["lesson-persistence-transactions"],
            quizzes: ["boot3-foundation-repository-query-001"]
        ),
        term(
            id: "transaction",
            term: "トランザクション",
            aliases: ["@Transactional", "rollback"],
            summary: "複数のDB操作をひとまとまりとして成功または失敗させる境界。",
            body: "`@Transactional` はメソッド実行をトランザクション境界で包みます。既定ではRuntimeExceptionでロールバックされます。",
            related: ["repository", "proxy"],
            lessons: ["lesson-persistence-transactions"],
            quizzes: ["boot3-practice-transaction-rollback-001", "boot3-practice-transaction-self-invocation-001"]
        ),
        term(
            id: "proxy",
            term: "プロキシ",
            aliases: ["Spring AOP Proxy", "AOP"],
            summary: "対象オブジェクトの前後に横断的な処理を差し込むための代理オブジェクト。",
            body: "Springのトランザクションなどはプロキシ経由で適用されます。同じクラス内の自己呼び出しはプロキシを通らないため注意が必要です。",
            related: ["transaction"],
            lessons: ["lesson-persistence-transactions"],
            quizzes: ["boot3-practice-transaction-self-invocation-001"]
        ),
        term(
            id: "security-filter-chain",
            term: "SecurityFilterChain",
            aliases: ["Spring Security", "認可ルール"],
            summary: "HTTPリクエストに対する認証・認可などのSecurityフィルタ設定。",
            body: "SecurityFilterChainでは、URLごとのpermitAllやauthenticatedなどを設定します。ルールの順序と具体性が重要です。",
            related: ["actuator"],
            lessons: [],
            quizzes: ["boot3-practice-security-chain-001"]
        ),
        term(
            id: "actuator",
            term: "Actuator",
            aliases: ["Spring Boot Actuator", "health", "metrics"],
            summary: "ヘルスチェックやメトリクスなど運用向けエンドポイントを提供する機能。",
            body: "Actuatorは `/actuator/health` などの運用エンドポイントを提供します。本番では公開範囲と認証設計を慎重に決めます。",
            related: ["security-filter-chain"],
            lessons: ["lesson-testing-observability"],
            quizzes: ["boot3-foundation-actuator-health-001"]
        ),
        term(
            id: "slice-test",
            term: "スライステスト",
            aliases: ["@WebMvcTest", "Test Slice"],
            summary: "Controllerなど特定の層に絞って起動する軽量なテスト。",
            body: "`@WebMvcTest` はMVC層に絞ってテストし、Serviceなどはモック化します。全体起動より速く、Controllerの入出力確認に向いています。",
            related: ["rest-controller"],
            lessons: ["lesson-testing-observability"],
            quizzes: ["boot3-foundation-webmvctest-001"]
        ),
        term(
            id: "jakarta-migration",
            term: "Jakarta名前空間",
            aliases: ["jakarta.validation", "Spring Boot 3"],
            summary: "Spring Boot 3.xで使うJakarta EE系APIの名前空間。",
            body: "Spring Boot 3.xはSpring Framework 6とJakarta EE 9以降を前提にするため、ValidationやServletなどのAPIは `jakarta.*` 名前空間を使います。",
            related: ["validation"],
            lessons: [],
            quizzes: ["boot3-foundation-jakarta-validation-001"]
        )
    ]

    static func lookup(_ id: String) -> GlossaryTerm? {
        samples.first { $0.id == id }
    }

    private static func term(
        id: String,
        term: String,
        aliases: [String],
        summary: String,
        body: String,
        related: [String],
        lessons: [String],
        quizzes: [String]
    ) -> GlossaryTerm {
        GlossaryTerm(
            id: id,
            term: term,
            aliases: aliases,
            summary: summary,
            body: body,
            relatedTermIds: related,
            relatedLessonIds: lessons,
            relatedQuizIds: quizzes
        )
    }
}

extension Explanation {
    static func sample(for ref: String) -> Explanation? {
        if let explanation = authoredSamples[ref] {
            return explanation
        }

        guard let quiz = quizByExplanationRef[ref] else {
            return nil
        }

        return quickTrace(for: quiz, ref: ref)
    }

    static let authoredSampleIds: Set<String> = Set(authoredSamples.keys)

    static let allSampleIds: [String] = authoredSamples.keys.sorted()

    static func isAuthored(ref: String) -> Bool {
        authoredSamples[ref] != nil
    }

    static func traceStatus(for ref: String) -> ExplanationTraceStatus {
        if authoredSamples[ref] != nil {
            return .authored
        }
        if quizExplanationRefSet.contains(ref) {
            return .placeholder
        }
        return .missing
    }

    private static let quizExplanationRefSet: Set<String> =
        Set(Quiz.samples.map(\.explanationRef))

    private static let quizByExplanationRef: [String: Quiz] =
        Dictionary(Quiz.samples.map { ($0.explanationRef, $0) }, uniquingKeysWith: { first, _ in first })

    private static let authoredSamples: [String: Explanation] = [
        layeredTraceExplanation.id: layeredTraceExplanation
    ]

    private static let layeredTraceExplanation = Explanation(
        id: "explain-boot3-practice-layered-trace-001",
        initialCode: Quiz.layeredTraceCombinedCode,
        codeTabs: Quiz.layeredTraceTabs,
        steps: [
            Step(
                index: 0,
                narration: "`GET /orders/42` はまず `OrderController.show` に到達します。ControllerはHTTPの入口としてパス変数 `id = 42` を受け取ります。",
                highlightLines: [7, 8, 9],
                variables: [Variable(name: "id", type: "Long", value: "42", scope: "OrderController.show")],
                callStack: [CallStackFrame(method: "OrderController.show", line: 8)],
                heap: [],
                predict: PredictPrompt(
                    question: "次に呼ばれる層はどれ？",
                    choices: ["Service", "Repository", "Entity"],
                    answerIndex: 0,
                    hint: "Controllerは業務処理を直接持たない設計です。",
                    afterExplanation: "正解です。Controllerは `service.find(id)` へ委譲します。"
                )
            ),
            Step(
                index: 1,
                narration: "`OrderService.find` に入り、読み取り専用トランザクション境界の中でRepositoryを呼びます。ここが業務処理の中心です。",
                highlightLines: [18, 19, 20],
                variables: [Variable(name: "id", type: "Long", value: "42", scope: "OrderService.find")],
                callStack: [
                    CallStackFrame(method: "OrderService.find", line: 19),
                    CallStackFrame(method: "OrderController.show", line: 9)
                ],
                heap: [],
                predict: nil
            ),
            Step(
                index: 2,
                narration: "`repository.findById(id)` がDBアクセスを担当します。Repositoryは永続化の詳細を隠し、`Optional<Order>` として結果を返します。",
                highlightLines: [20, 27],
                variables: [Variable(name: "result", type: "Optional<Order>", value: "Optional[Order#42]", scope: "OrderRepository.findById")],
                callStack: [
                    CallStackFrame(method: "OrderRepository.findById", line: 27),
                    CallStackFrame(method: "OrderService.find", line: 20),
                    CallStackFrame(method: "OrderController.show", line: 9)
                ],
                heap: [HeapObject(id: "order-42", type: "Order", fields: ["id": "42", "status": "PAID"])],
                predict: nil
            ),
            Step(
                index: 3,
                narration: "Orderが見つかったため `orElseThrow` は例外を投げず、Serviceで `OrderResponse` へ変換してControllerへ戻します。",
                highlightLines: [20, 21, 22],
                variables: [Variable(name: "response", type: "OrderResponse", value: "OrderResponse(id=42, status=PAID)", scope: "OrderService.find")],
                callStack: [
                    CallStackFrame(method: "OrderService.find", line: 22),
                    CallStackFrame(method: "OrderController.show", line: 9)
                ],
                heap: [HeapObject(id: "order-42", type: "Order", fields: ["id": "42", "status": "PAID"])],
                predict: PredictPrompt(
                    question: "Orderが見つからなかった場合に起きることは？",
                    choices: ["404相当の例外", "空のJSONを返す", "Controllerを再実行する"],
                    answerIndex: 0,
                    hint: "`orElseThrow` の中身を見ます。",
                    afterExplanation: "`ResponseStatusException(HttpStatus.NOT_FOUND)` が投げられ、HTTP 404として扱えます。"
                )
            ),
            Step(
                index: 4,
                narration: "ControllerはServiceから受け取ったDTOをそのまま返します。Spring MVCがHTTPレスポンスボディへ変換し、JSONとしてクライアントへ返します。",
                highlightLines: [8, 9],
                variables: [Variable(name: "body", type: "JSON", value: "{\"id\":42,\"status\":\"PAID\"}", scope: "HTTP response")],
                callStack: [CallStackFrame(method: "OrderController.show", line: 9)],
                heap: [],
                predict: nil
            )
        ]
    )

    private static func quickTrace(for quiz: Quiz, ref: String) -> Explanation {
        let lines = quiz.code.components(separatedBy: .newlines)
        let focusLine = bestFocusLine(in: lines)
        let correctChoice = quiz.choices.first { $0.correct }

        return Explanation(
            id: ref,
            initialCode: quiz.code,
            codeTabs: quiz.codeTabs,
            steps: [
                Step(
                    index: 0,
                    narration: "この問題では \(quiz.categoryDisplayName) の観点で、コードや設定のどの行がSpring Bootの動きに効くかを確認します。",
                    highlightLines: [focusLine],
                    variables: [],
                    callStack: [CallStackFrame(method: quiz.categoryDisplayName, line: focusLine)],
                    heap: [],
                    predict: nil
                ),
                Step(
                    index: 1,
                    narration: correctChoice?.explanation ?? quiz.designIntent,
                    highlightLines: [focusLine],
                    variables: [
                        Variable(
                            name: "answer",
                            type: "Choice",
                            value: correctChoice?.text ?? "未設定",
                            scope: "quiz"
                        )
                    ],
                    callStack: [CallStackFrame(method: "decision", line: focusLine)],
                    heap: [],
                    predict: PredictPrompt(
                        question: quiz.question,
                        choices: quiz.choices.map(\.text),
                        answerIndex: max(quiz.choices.firstIndex(where: { $0.correct }) ?? 0, 0),
                        hint: quiz.tags.joined(separator: " / "),
                        afterExplanation: correctChoice?.explanation ?? quiz.designIntent
                    )
                ),
                Step(
                    index: 2,
                    narration: "誤答は、Spring Bootの自動設定、DI、MVC、トランザクションなどの責務を混同したものです。どの層の仕事かに分けると判断しやすくなります。",
                    highlightLines: [focusLine],
                    variables: [],
                    callStack: [],
                    heap: [],
                    predict: nil
                )
            ]
        )
    }

    private static func bestFocusLine(in lines: [String]) -> Int {
        let keywords = [
            "@SpringBootApplication",
            "@RestController",
            "@Service",
            "@Transactional",
            "@ConfigurationProperties",
            "@WebMvcTest",
            "SecurityFilterChain",
            "management:",
            "dependencies",
            "interface"
        ]

        if let index = lines.firstIndex(where: { line in
            keywords.contains { line.contains($0) }
        }) {
            return index + 1
        }

        return 1
    }
}
