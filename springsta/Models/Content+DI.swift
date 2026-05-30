import Foundation

// MARK: - DI・Bean 50問

extension Quiz {
    static let diQuizzes: [Quiz] = (diStereotype + diConstructor + diFieldVsConstructor
        + diSetter + diScope + diPrimaryQualifier + diBeanConfig + diComponentScan
        + diCircular).map { $0.contextualizedForPresentation() }

    // ─────────────────────────────────────────
    // Group 1: ステレオタイプアノテーション (8問)
    // ─────────────────────────────────────────
    private static let diStereotype: [Quiz] = [
        quiz(
            id: "boot3-di-stereotype-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Component", "@Service", "@Repository", "ステレオタイプ"],
            code: """
@Service
class OrderService {
    private final OrderRepository repo;
    OrderService(OrderRepository repo) { this.repo = repo; }
}
""",
            question: "`@Service` を付けることで得られる効果として正しいものはどれか？",
            choices: [
                choice("a", "Springにビジネスロジック層のBeanとして登録され、コンポーネントスキャンの対象になる", correct: true,
                       explanation: "`@Service` は `@Component` のメタアノテーションを持つ特化型で、Beanとして登録されます。`@Component` との実際の動作差はほぼなく、役割を明示する意味が主です。"),
                choice("b", "トランザクションが自動的に有効になる",
                       misconception: "@Transactionalと混同",
                       explanation: "トランザクションは `@Transactional` が必要です。`@Service` を付けただけでは自動的にトランザクション管理は行われません。"),
                choice("c", "メソッド呼び出しのたびにキャッシュが作成される",
                       misconception: "@Cacheableと混同",
                       explanation: "キャッシュは `@Cacheable` などの別アノテーションで制御します。"),
                choice("d", "クラスのインスタンスがリクエストのたびに生成される",
                       misconception: "デフォルトスコープをリクエストスコープと誤解",
                       explanation: "デフォルトスコープはシングルトンです。リクエストごとに生成するには `@RequestScope` が必要です。")
            ],
            explanationRef: "explain-boot3-di-stereotype-001",
            designIntent: "@Serviceの意味とBeanとしての登録を理解する。"
        ),
        quiz(
            id: "boot3-di-stereotype-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Repository", "DataAccessException", "例外変換"],
            code: """
@Repository
class UserRepository {
    public User findById(Long id) {
        // JDBCでDB検索
    }
}
""",
            question: "`@Repository` を付けることで `@Component` との差として得られる追加効果はどれか？",
            choices: [
                choice("a", "JDBC/JPAなどが投げるDB例外を `DataAccessException` 階層に変換する",
                       correct: true,
                       explanation: "`@Repository` はSpringのPersistenceExceptionTranslationPostProcessorと連携し、DB固有の例外を `DataAccessException` に統一します。サービス層はDB実装に依存しない例外を扱えます。"),
                choice("b", "SQLを自動生成してDBに接続する",
                       misconception: "Spring Data JpaRepositoryの機能と混同",
                       explanation: "SQL自動生成はSpring Data JPAの `JpaRepository` 継承が担います。`@Repository` アノテーションだけでは自動生成しません。"),
                choice("c", "クラスをXMLに自動シリアライズする",
                       misconception: "永続化とシリアライズを混同",
                       explanation: "@Repositoryはシリアライズとは無関係です。"),
                choice("d", "DB接続プールを自動的に設定する",
                       misconception: "コネクションプール設定をアノテーションで行えると誤解",
                       explanation: "接続プールはapplication.ymlの `spring.datasource.*` で設定します。")
            ],
            explanationRef: "explain-boot3-di-stereotype-002",
            designIntent: "@Repositoryの例外変換という独自効果を理解する。"
        ),
        quiz(
            id: "boot3-di-stereotype-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Controller", "@RestController", "@ResponseBody"],
            code: """
// A
@Controller
class PageController {
    @GetMapping("/home")
    String home() { return "home"; }
}

// B
@RestController
class ApiController {
    @GetMapping("/api/users")
    List<User> users() { return List.of(); }
}
""",
            question: "`@RestController` が `@Controller` と異なる点として正しいものはどれか？",
            choices: [
                choice("a", "`@ResponseBody` が暗黙的に全メソッドに付与され、戻り値がJSONなどに変換される",
                       correct: true,
                       explanation: "`@RestController` は `@Controller` + `@ResponseBody` の合成アノテーションです。AのControllerは戻り値をビュー名として扱いますが、BのRestControllerはJSONシリアライズします。"),
                choice("b", "URLマッピングを定義できる点が異なる",
                       misconception: "@RequestMappingの有無と混同",
                       explanation: "どちらも `@GetMapping` などのURLマッピングを使えます。"),
                choice("c", "@RestControllerはHTTPSのみ受け付ける",
                       misconception: "RESTとHTTPSを混同",
                       explanation: "プロトコルはサーバ設定で決まります。アノテーションとは無関係です。"),
                choice("d", "@RestControllerはGETリクエストのみ処理できる",
                       misconception: "RESTをGET専用と誤解",
                       explanation: "GET/POST/PUT/DELETEなどすべてのHTTPメソッドを扱えます。")
            ],
            explanationRef: "explain-boot3-di-stereotype-003",
            designIntent: "@RestControllerと@Controllerの合成関係を理解する。"
        ),
        quiz(
            id: "boot3-di-stereotype-004",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Component", "スキャン対象", "パッケージ"],
            code: """
// com.example.demo.DemoApplication.java
@SpringBootApplication
public class DemoApplication { ... }

// com.example.other.SomeService.java
@Component
public class SomeService { ... }
""",
            question: "`SomeService` がBeanとして登録されない場合の原因として最も可能性が高いものはどれか？",
            choices: [
                choice("a", "`DemoApplication` と `SomeService` がいるパッケージが異なり、コンポーネントスキャン対象外",
                       correct: true,
                       explanation: "`@SpringBootApplication` のスキャン範囲はデフォルトで起動クラスと同じパッケージ以下です。`com.example.other` は `com.example.demo` の配下でないためスキャンされません。`@ComponentScan(basePackages=\"com.example\")` などで範囲を広げます。"),
                choice("b", "`@Component` はインターフェースにしか使えない",
                       misconception: "@Componentの対象クラスを誤解",
                       explanation: "`@Component` は通常クラスに付けます。インターフェースへの付与はスキャンされません。"),
                choice("c", "`@Service` でないとスキャンされない",
                       misconception: "@Serviceでないと登録されないと誤解",
                       explanation: "`@Component`・`@Service`・`@Repository`・`@Controller` はどれもスキャン対象です。"),
                choice("d", "同じパッケージに2つのクラスがあると片方しか登録されない",
                       misconception: "Bean名の衝突と数の制限を混同",
                       explanation: "同じパッケージに複数のBeanを置くことは通常の使い方です。")
            ],
            explanationRef: "explain-boot3-di-stereotype-004",
            designIntent: "コンポーネントスキャンのパッケージ範囲を理解する。"
        ),
        quiz(
            id: "boot3-di-stereotype-005",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["Bean名", "@Component", "デフォルト命名"],
            code: """
@Component
public class UserEventListener { }
""",
            question: "このBeanのデフォルトBean名として正しいものはどれか？",
            choices: [
                choice("a", "`userEventListener`（先頭小文字のキャメルケース）",
                       correct: true,
                       explanation: "Springはクラス名の先頭を小文字にしたキャメルケースをBean名とします。`UserEventListener` → `userEventListener` です。`@Component(\"customName\")` で名前を変更できます。"),
                choice("b", "`UserEventListener`（クラス名そのまま）",
                       misconception: "大文字のままがBean名になると誤解",
                       explanation: "デフォルトは先頭小文字です。"),
                choice("c", "`user-event-listener`（ケバブケース）",
                       misconception: "application.ymlのプロパティ命名と混同",
                       explanation: "application.ymlではケバブケースが使われますが、Bean名はキャメルケースです。"),
                choice("d", "`com.example.demo.UserEventListener`（完全修飾名）",
                       misconception: "FQCNがBean名になると誤解",
                       explanation: "Bean名はデフォルトでシンプルなキャメルケースのクラス名です。")
            ],
            explanationRef: "explain-boot3-di-stereotype-005",
            designIntent: "Bean名のデフォルト命名規則を理解する。"
        ),
        quiz(
            id: "boot3-di-stereotype-006",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Component", "インターフェース", "スキャン"],
            code: """
@Component
public interface PaymentGateway {
    void pay(long amount);
}
""",
            question: "このコードの問題点として正しいものはどれか？",
            choices: [
                choice("a", "インターフェースは `@Component` でBean登録できない。実装クラスに付けるか `@Bean` で定義する",
                       correct: true,
                       explanation: "Springのコンポーネントスキャンはインターフェースをインスタンス化できないためBeanとして扱いません。`@Component` は具体クラスに付けます。実装クラス（例: `StripePaymentGateway`）に `@Component` を付けてください。"),
                choice("b", "インターフェースのメソッドに `@Override` が必要",
                       misconception: "Javaの文法要件と混同",
                       explanation: "`@Override` は実装クラスのメソッドに付けるもので、インターフェースのメソッドには不要です。"),
                choice("c", "`pay` メソッドが `void` だとBeanが生成されない",
                       misconception: "戻り型とBean生成を混同",
                       explanation: "メソッドの戻り型とBean生成は無関係です。"),
                choice("d", "問題なく動作する",
                       misconception: "インターフェースにも@Componentが使えると誤解",
                       explanation: "インターフェースは `@Component` スキャンの対象外です。")
            ],
            explanationRef: "explain-boot3-di-stereotype-006",
            designIntent: "@Componentはインターフェースに使えないことを理解する。"
        ),
        quiz(
            id: "boot3-di-stereotype-007",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Service", "@Repository", "責務分離", "レイヤー"],
            code: """
// 案A
@Service
class UserService {
    User findById(Long id) {
        // JDBCで直接SELECT
    }
}

// 案B
@Service
class UserService {
    private final UserRepository repo;
    User findById(Long id) { return repo.findById(id).orElseThrow(); }
}
@Repository
class UserRepository { ... }
""",
            question: "案Aより案Bが推奨される理由として最も正しいものはどれか？",
            choices: [
                choice("a", "永続化ロジックを `@Repository` に分離することでDB実装の切り替えやテストが容易になる",
                       correct: true,
                       explanation: "案AはServiceがDB実装詳細を知るため変更の影響範囲が広がります。案BはRepositoryが永続化を担い、Serviceはビジネスロジックのみになりテスタビリティが向上します。"),
                choice("b", "案Bの方がDBアクセス速度が速い",
                       misconception: "設計とパフォーマンスを混同",
                       explanation: "レイヤー分離はパフォーマンスではなく保守性・テスタビリティのためです。"),
                choice("c", "@ServiceはJDBCが使えないので分離が必須",
                       misconception: "アノテーションがDBアクセス方法を制限すると誤解",
                       explanation: "@Serviceが付いたクラスでJDBCを使うことは技術的には可能です。ただし推奨設計ではありません。"),
                choice("d", "案Aはコンパイルエラーになる",
                       misconception: "@ServiceクラスでのJDBC使用が文法エラーと誤解",
                       explanation: "コンパイルエラーにはなりません。設計上の問題です。")
            ],
            explanationRef: "explain-boot3-di-stereotype-007",
            designIntent: "ステレオタイプによる責務分離の意義を理解する。"
        ),
        quiz(
            id: "boot3-di-stereotype-008",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Component", "@Bean", "登録方法の違い"],
            code: """
// 方法A: @Component
@Component
class EmailSender { ... }

// 方法B: @Bean
@Configuration
class AppConfig {
    @Bean
    EmailSender emailSender() { return new EmailSender(); }
}
""",
            question: "`@Bean` を使う方法Bが方法Aより適切なケースはどれか？",
            choices: [
                choice("a", "サードパーティライブラリのクラスにソースコードがなく `@Component` を付けられないとき",
                       correct: true,
                       explanation: "自分でコードを変更できないクラス（例: `RestTemplate`・`ObjectMapper`）はソースに `@Component` が書けません。`@Bean` メソッドを使えばSpring管理Beanとして登録できます。"),
                choice("b", "クラスにフィールドが多いとき",
                       misconception: "フィールド数とBean登録方法を関連付けて誤解",
                       explanation: "フィールドの数はBean登録方法の選択基準ではありません。"),
                choice("c", "@Componentは1パッケージに1つしか使えないとき",
                       misconception: "@Componentの数に制限があると誤解",
                       explanation: "1パッケージに複数の@Componentを置くことは普通です。"),
                choice("d", "テスト環境でのみBeanを有効にしたいとき",
                       misconception: "@Beanが持つ環境分岐の役割を誤解",
                       explanation: "テスト限定は `@Profile(\"test\")` や `@ConditionalOnMissingBean` などで行います。")
            ],
            explanationRef: "explain-boot3-di-stereotype-008",
            designIntent: "@Componentと@Beanの使い分けを理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 2: コンストラクタインジェクション (7問)
    // ─────────────────────────────────────────
    private static let diConstructor: [Quiz] = [
        quiz(
            id: "boot3-di-constructor-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["コンストラクタインジェクション", "@Autowired", "省略"],
            code: """
@Service
class OrderService {
    private final OrderRepository repo;

    OrderService(OrderRepository repo) {
        this.repo = repo;
    }
}
""",
            question: "このコードでコンストラクタに `@Autowired` がないが問題はないか？",
            choices: [
                choice("a", "Spring 4.3以降はコンストラクタが1つであれば `@Autowired` を省略できるため問題ない",
                       correct: true,
                       explanation: "Spring 4.3からシングルコンストラクタの場合は自動でインジェクション対象とみなします。Spring Boot 2.x/3.xはこれに対応しているため省略が一般的です。"),
                choice("b", "@Autowiredがないためフィールドはnullになる",
                       misconception: "@Autowiredが必須と誤解",
                       explanation: "コンストラクタが1つの場合はSpringが自動認識します。"),
                choice("c", "コンストラクタインジェクションは非推奨で動作しない",
                       misconception: "コンストラクタインジェクションが古い方式と誤解",
                       explanation: "コンストラクタインジェクションはSpringが推奨する最も良い方法です。"),
                choice("d", "finalフィールドはインジェクションできない",
                       misconception: "finalとインジェクションの関係を誤解",
                       explanation: "コンストラクタでfinalフィールドを初期化するのは正しいパターンです。")
            ],
            explanationRef: "explain-boot3-di-constructor-001",
            designIntent: "Spring 4.3+での@Autowired省略ルールを理解する。"
        ),
        quiz(
            id: "boot3-di-constructor-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["コンストラクタインジェクション", "final", "不変性"],
            code: """
@Service
class PaymentService {
    // A: フィールドインジェクション
    @Autowired
    private PaymentGateway gateway;

    // B: コンストラクタインジェクション
    private final PaymentGateway gateway;
    PaymentService(PaymentGateway gateway) {
        this.gateway = gateway;
    }
}
""",
            question: "コンストラクタインジェクション（B）がフィールドインジェクション（A）より優れている点はどれか？",
            choices: [
                choice("a", "`final` で宣言でき、初期化後に依存が差し替えられないことを保証できる",
                       correct: true,
                       explanation: "`final` はコンストラクタインジェクションでのみ使えます。不変性が保証されると、テスト中に意図せず依存が変わることを防げます。また依存が明示的でコードが読みやすくなります。"),
                choice("b", "実行速度がフィールドインジェクションより速い",
                       misconception: "インジェクション方式とパフォーマンスを混同",
                       explanation: "起動時の処理に微差はありますが、業務上無視できる差です。"),
                choice("c", "@Autowiredを書かなくていいのでコード量が減る",
                       misconception: "@Autowiredの有無だけを見ている",
                       explanation: "コンストラクタを書く分コード量はむしろ増えます（Lombokで減らせますが）。優位点は不変性とテスタビリティです。"),
                choice("d", "SpringなしのユニットテストでもDIが自動で行われる",
                       misconception: "コンストラクタインジェクションのテストメリットを誤解",
                       explanation: "Springなしのテストでは自分でコンストラクタにモックを渡せる（newできる）というメリットがあります。DIが自動で行われるわけではありません。")
            ],
            explanationRef: "explain-boot3-di-constructor-002",
            designIntent: "コンストラクタインジェクションのfinalによる不変性保証を理解する。"
        ),
        quiz(
            id: "boot3-di-constructor-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["Lombok", "@RequiredArgsConstructor", "コンストラクタ自動生成"],
            code: """
@Service
@RequiredArgsConstructor
class UserService {
    private final UserRepository userRepo;
    private final EmailService emailService;
    private String appName; // finalなし
}
""",
            question: "Lombokの `@RequiredArgsConstructor` を付けた場合に自動生成されるコンストラクタはどれか？",
            choices: [
                choice("a", "`UserService(UserRepository userRepo, EmailService emailService)` — finalフィールドのみ引数に含まれる",
                       correct: true,
                       explanation: "`@RequiredArgsConstructor` は `final` フィールドと `@NonNull` フィールドのみを引数とするコンストラクタを生成します。`appName` は `final` でないため含まれません。"),
                choice("b", "全フィールド（appNameも含む）を引数とするコンストラクタ",
                       misconception: "@AllArgsConstructorと混同",
                       explanation: "全フィールドを含むのは `@AllArgsConstructor` です。"),
                choice("c", "引数なしのデフォルトコンストラクタ",
                       misconception: "@NoArgsConstructorと混同",
                       explanation: "引数なしは `@NoArgsConstructor` です。"),
                choice("d", "コンストラクタは生成されずフィールドインジェクションに切り替わる",
                       misconception: "Lombokがインジェクション方式を変えると誤解",
                       explanation: "LombokはJavaコードを生成するだけです。インジェクション方式はSpringが決定します。")
            ],
            explanationRef: "explain-boot3-di-constructor-003",
            designIntent: "@RequiredArgsConstructorがfinalフィールドのみ対象であることを理解する。"
        ),
        quiz(
            id: "boot3-di-constructor-004",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["コンストラクタ", "複数", "@Autowired", "選択"],
            code: """
@Service
class NotificationService {
    private final EmailSender email;
    private final SmsSender sms;

    NotificationService(EmailSender email) {
        this.email = email; this.sms = null;
    }

    @Autowired
    NotificationService(EmailSender email, SmsSender sms) {
        this.email = email; this.sms = sms;
    }
}
""",
            question: "コンストラクタが複数あるとき、Springはどのコンストラクタでインジェクションするか？",
            choices: [
                choice("a", "`@Autowired` が付いているコンストラクタ（引数2つの方）",
                       correct: true,
                       explanation: "複数コンストラクタがある場合は `@Autowired` が付いたものが選ばれます。`@Autowired` が複数に付いている場合はエラーになります。"),
                choice("b", "引数が最も少ないコンストラクタ",
                       misconception: "引数の少ない方が優先されると誤解",
                       explanation: "Springは引数の数ではなく `@Autowired` の有無で選択します。"),
                choice("c", "宣言順で最初のコンストラクタ",
                       misconception: "宣言順が優先されると誤解",
                       explanation: "宣言順ではなく `@Autowired` が基準です。"),
                choice("d", "コンストラクタが複数あると起動時エラーになる",
                       misconception: "複数コンストラクタが常にエラーと誤解",
                       explanation: "`@Autowired` で1つに絞れば正常に起動します。")
            ],
            explanationRef: "explain-boot3-di-constructor-004",
            designIntent: "複数コンストラクタ時の@Autowiredによる選択ルールを理解する。"
        ),
        quiz(
            id: "boot3-di-constructor-005",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["コンストラクタインジェクション", "テスト", "モック"],
            code: """
@Service
class ReportService {
    private final ReportRepository repo;
    ReportService(ReportRepository repo) { this.repo = repo; }

    String generate(Long id) { return repo.findById(id).toString(); }
}

// テストコード
class ReportServiceTest {
    @Test
    void test() {
        var mockRepo = Mockito.mock(ReportRepository.class);
        var service = new ReportService(mockRepo); // ←
        ...
    }
}
""",
            question: "コンストラクタインジェクションを使うと何がテストしやすくなるか？",
            choices: [
                choice("a", "`new ReportService(mockRepo)` のようにSpringコンテキストなしでモックを渡せる",
                       correct: true,
                       explanation: "コンストラクタインジェクションなら普通のJavaの `new` でモックを注入でき、`@SpringBootTest` などの重いコンテキストが不要です。テストが速くなりシンプルになります。"),
                choice("b", "テスト時にDBが自動でH2に切り替わる",
                       misconception: "インジェクション方式とDB設定を混同",
                       explanation: "DBの切り替えはプロファイルや `@DataJpaTest` の役割です。"),
                choice("c", "テスト実行中はシングルトンではなくプロトタイプになる",
                       misconception: "テスト環境でスコープが変わると誤解",
                       explanation: "Beanスコープはアノテーションで決まりインジェクション方式とは無関係です。"),
                choice("d", "Mockitoを使わなくてもモックが自動生成される",
                       misconception: "Springがモックを自動生成すると誤解",
                       explanation: "モック生成はMockitoや `@MockBean` などのフレームワークが担います。")
            ],
            explanationRef: "explain-boot3-di-constructor-005",
            designIntent: "コンストラクタインジェクションのSpringなしテストへの利点を理解する。"
        ),
        quiz(
            id: "boot3-di-constructor-006",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["コンストラクタインジェクション", "必須依存", "設計"],
            code: """
@Service
class InvoiceService {
    private final TaxCalculator tax;
    private final PdfGenerator pdf;

    InvoiceService(TaxCalculator tax, PdfGenerator pdf) {
        this.tax = tax;
        this.pdf = pdf;
    }
}
""",
            question: "このコードでコンストラクタに引数を列挙することの設計上のメリットはどれか？",
            choices: [
                choice("a", "このクラスが動作するために必要な依存が一目瞭然になり、依存関係が隠れない",
                       correct: true,
                       explanation: "コンストラクタを見るだけで「このServiceはTaxCalculatorとPdfGeneratorが必要」とわかります。フィールドインジェクションだとクラス全体を読まないと依存が見えません。"),
                choice("b", "コンストラクタの引数が多いほどパフォーマンスが上がる",
                       misconception: "引数の数とパフォーマンスを関連付ける誤解",
                       explanation: "パフォーマンスは引数の数とは無関係です。"),
                choice("c", "コンストラクタインジェクションはシングルトンのみ有効",
                       misconception: "スコープとインジェクション方式を混同",
                       explanation: "コンストラクタインジェクションはどのスコープでも使えます。"),
                choice("d", "コンストラクタが長くなりすぎると自動でセッタに切り替わる",
                       misconception: "Springが自動でインジェクション方式を切り替えると誤解",
                       explanation: "Springはコードを自動変換しません。インジェクション方式は開発者が選択します。")
            ],
            explanationRef: "explain-boot3-di-constructor-006",
            designIntent: "コンストラクタインジェクションが依存を明示する設計価値を理解する。"
        ),
        quiz(
            id: "boot3-di-constructor-007",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Autowired", "コンストラクタ", "required=false", "任意依存"],
            code: """
@Service
class AnalyticsService {
    private final EventTracker tracker;

    @Autowired(required = false)
    AnalyticsService(EventTracker tracker) {
        this.tracker = tracker;
    }
}
""",
            question: "`@Autowired(required = false)` を付けたとき、`EventTracker` のBeanが存在しない場合どうなるか？",
            choices: [
                choice("a", "引数に `null` が渡されてコンストラクタが呼ばれる",
                       correct: true,
                       explanation: "`required = false` にするとBeanが見つからなくても起動失敗せず `null` が渡されます。ただしその後 `tracker` を使うとNPEになるため `if (tracker != null)` などのnullチェックが必要です。"),
                choice("b", "BeanがないためApplicationContextが起動しない",
                       misconception: "required=falseの意味を理解していない",
                       explanation: "`required = false` の目的はBeanがなくても起動するようにすることです。"),
                choice("c", "Springがデフォルト実装を自動生成して注入する",
                       misconception: "Springがモックや空実装を作ると誤解",
                       explanation: "Springはデフォルト実装を自動生成しません。"),
                choice("d", "コンストラクタは呼ばれずBeanが生成されない",
                       misconception: "required=falseでBeanが生成されないと誤解",
                       explanation: "Beanは生成されます。ただし依存が満たせない場合に `null` が渡されます。")
            ],
            explanationRef: "explain-boot3-di-constructor-007",
            designIntent: "@Autowired(required=false)の動作を理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 3: フィールドインジェクション vs コンストラクタ (5問)
    // ─────────────────────────────────────────
    private static let diFieldVsConstructor: [Quiz] = [
        quiz(
            id: "boot3-di-field-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["フィールドインジェクション", "@Autowired", "非推奨"],
            code: """
@Service
class SearchService {
    @Autowired
    private SearchRepository repo; // フィールドインジェクション
}
""",
            question: "Springがフィールドインジェクションを非推奨としている主な理由はどれか？",
            choices: [
                choice("a", "Springコンテキストなしで `new SearchService()` すると `repo` が null になりテストしにくい",
                       correct: true,
                       explanation: "フィールドインジェクションはリフレクションで注入するため、Spring管理外（`new` 生成）では動きません。コンストラクタインジェクションなら `new SearchService(mockRepo)` でモックを渡せます。"),
                choice("b", "フィールドインジェクションはJava 17以降で廃止された",
                       misconception: "Java/Springのバージョンと混同",
                       explanation: "Java 17でもSpring Boot 3.xでもフィールドインジェクションは動作します。非推奨は設計上の理由です。"),
                choice("c", "フィールドインジェクションはシングルトンスコープで動かない",
                       misconception: "スコープとインジェクション方式を混同",
                       explanation: "フィールドインジェクションはシングルトンでも動きます。"),
                choice("d", "複数のフィールドに `@Autowired` をつけると起動エラーになる",
                       misconception: "複数フィールドへの@Autowiredに制限があると誤解",
                       explanation: "複数フィールドにそれぞれ `@Autowired` を付けることは動作します。")
            ],
            explanationRef: "explain-boot3-di-field-001",
            designIntent: "フィールドインジェクション非推奨の理由（テスタビリティ）を理解する。"
        ),
        quiz(
            id: "boot3-di-field-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["フィールドインジェクション", "final", "不変性"],
            code: """
@Service
class CartService {
    @Autowired
    private final CartRepository repo; // コンパイルエラー？
}
""",
            question: "このコードの `final` フィールドに `@Autowired` を使った場合の結果はどれか？",
            choices: [
                choice("a", "コンパイルエラーになる。`final` フィールドはフィールドインジェクションできない",
                       correct: true,
                       explanation: "`final` フィールドはJavaの仕様でコンストラクタでのみ初期化できます。フィールドインジェクション（リフレクション経由の後付け代入）では `final` に代入できずコンパイルエラーになります。"),
                choice("b", "Springがリフレクションで `final` を無視して代入する",
                       misconception: "Springが強制的にfinalを書き換えると誤解",
                       explanation: "`final` フィールドへのリフレクション書き込みは `IllegalAccessException` になります。"),
                choice("c", "コンパイルは通るが実行時に `null` になる",
                       misconception: "コンパイルは通ると誤解",
                       explanation: "コンパイル段階でエラーになります。"),
                choice("d", "`@Autowired` が付いていればfinalでも問題ない",
                       misconception: "@Autowiredがfinalの制約を解除すると誤解",
                       explanation: "@Autowiredはfinalの制約をなくしません。finalにはコンストラクタインジェクションを使います。")
            ],
            explanationRef: "explain-boot3-di-field-002",
            designIntent: "finalフィールドにフィールドインジェクションが使えないことを理解する。"
        ),
        quiz(
            id: "boot3-di-field-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["フィールドインジェクション", "循環依存", "検出"],
            code: """
@Service
class A {
    @Autowired B b;
}
@Service
class B {
    @Autowired A a;
}
""",
            question: "フィールドインジェクションで循環依存がある場合、Spring Boot 2.6以前はどうなるか？",
            choices: [
                choice("a", "起動時にエラーにならず実行時まで問題が潜伏することがある",
                       correct: true,
                       explanation: "フィールドインジェクションはBeanを先に生成してから注入するため、Spring Boot 2.6以前は循環依存を起動時に検出せずに動いてしまう場合がありました。2.6以降はデフォルトで循環依存を禁止し起動時エラーにします。"),
                choice("b", "常に起動時にBeanCreationExceptionが出る",
                       misconception: "バージョン関係なく常に起動時エラーと誤解",
                       explanation: "Spring Boot 2.5以前はフィールドインジェクションの循環依存を許容していました。"),
                choice("c", "循環依存があってもコンパイルエラーで事前に発見できる",
                       misconception: "コンパイル時に循環依存が検出されると誤解",
                       explanation: "循環依存はコンパイルエラーにはなりません。実行時（起動時）の問題です。"),
                choice("d", "自動的に一方の依存が解除される",
                       misconception: "Springが自動で循環を解消すると誤解",
                       explanation: "Springは循環依存を自動解消しません。設計で回避するか `@Lazy` で遅延させる必要があります。")
            ],
            explanationRef: "explain-boot3-di-field-003",
            designIntent: "フィールドインジェクションが循環依存を潜伏させやすいことを理解する。"
        ),
        quiz(
            id: "boot3-di-field-004",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@InjectMocks", "Mockito", "フィールドインジェクション"],
            code: """
class UserServiceTest {
    @Mock
    UserRepository repo;

    @InjectMocks
    UserService service;

    @BeforeEach
    void setup() { MockitoAnnotations.openMocks(this); }
}
""",
            question: "Mockitoの `@InjectMocks` を使う場合にフィールドインジェクションを使う理由はどれか？",
            choices: [
                choice("a", "`@InjectMocks` がフィールドインジェクションやコンストラクタインジェクションでモックを注入するため、テストコードでのみ許容される場面がある",
                       correct: true,
                       explanation: "`@InjectMocks` はMockitoがモックを注入する仕組みでコンストラクタ/セッタ/フィールドに対応します。テストコードでのみ使用し、本番コードのインジェクション方式は別途検討します。"),
                choice("b", "フィールドインジェクションはJUnit 5でのみ動作する",
                       misconception: "JUnitバージョンとインジェクション方式を混同",
                       explanation: "@InjectMocksはJUnit 4/5どちらでも使えます。"),
                choice("c", "@InjectMocksを使うとSpringコンテキストが不要になりテストが速くなる",
                       misconception: "部分的に正しいが主な理由ではない",
                       explanation: "Springコンテキスト不要で速いのはメリットですが、@InjectMocksを使う理由はモックの注入のためです。"),
                choice("d", "Mockitoはコンストラクタインジェクションに非対応",
                       misconception: "Mockitoがコンストラクタに対応しないと誤解",
                       explanation: "Mockitoはコンストラクタインジェクションにも対応します。")
            ],
            explanationRef: "explain-boot3-di-field-004",
            designIntent: "@InjectMocksとフィールドインジェクションの関係を理解する。"
        ),
        quiz(
            id: "boot3-di-field-005",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["インジェクション方式", "推奨", "まとめ"],
            code: """
// 方式A（フィールド）
@Autowired
private UserRepository repo;

// 方式B（セッタ）
@Autowired
public void setRepo(UserRepository repo) { this.repo = repo; }

// 方式C（コンストラクタ）
private final UserRepository repo;
UserService(UserRepository repo) { this.repo = repo; }
""",
            question: "Springが最も推奨するインジェクション方式はどれか？",
            choices: [
                choice("a", "方式C（コンストラクタインジェクション）",
                       correct: true,
                       explanation: "Spring公式ドキュメントはコンストラクタインジェクションを推奨しています。理由はfinalによる不変性保証・テスタビリティ・依存の明示性です。方式Aはテストしにくく方式Bは任意依存向けです。"),
                choice("b", "方式A（フィールドインジェクション）— 最もシンプルだから",
                       misconception: "シンプルさが最優先と考える",
                       explanation: "シンプルですが非推奨です。テストしにくくfinalが使えません。"),
                choice("c", "方式B（セッタインジェクション）— 後から変更できるから",
                       misconception: "再設定可能性を最優先と考える",
                       explanation: "セッタインジェクションは任意依存や後からの差し替えが必要な特殊ケースに向いています。通常はコンストラクタを使います。"),
                choice("d", "どれも同等で好みで選んでよい",
                       misconception: "インジェクション方式はすべて同等と誤解",
                       explanation: "Spring公式はコンストラクタを推奨しており、それぞれにトレードオフがあります。")
            ],
            explanationRef: "explain-boot3-di-field-005",
            designIntent: "3つのインジェクション方式の推奨順位を整理する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 4: セッタインジェクション (3問)
    // ─────────────────────────────────────────
    private static let diSetter: [Quiz] = [
        quiz(
            id: "boot3-di-setter-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["セッタインジェクション", "任意依存", "@Autowired"],
            code: """
@Service
class RecommendService {
    private RecommendEngine engine;

    @Autowired(required = false)
    public void setEngine(RecommendEngine engine) {
        this.engine = engine;
    }
}
""",
            question: "セッタインジェクションが適切なケースはどれか？",
            choices: [
                choice("a", "依存が任意（なくても動作できる）で後から差し替えが必要なケース",
                       correct: true,
                       explanation: "`required = false` と組み合わせたセッタインジェクションは、エンジンがないときも動作し、設定後に別のエンジンに差し替えも可能です。コンストラクタだと必須になります。"),
                choice("b", "シングルトンBeanの依存を毎リクエストごとに変えるケース",
                       misconception: "セッタでリクエストごとに注入できると誤解",
                       explanation: "シングルトンのセッタをリクエストごとに呼ぶことは通常行いません。スコープ付きBeanを使います。"),
                choice("c", "フィールドをfinalにしたいケース",
                       misconception: "セッタインジェクションでfinalが使えると誤解",
                       explanation: "セッタは初期化後に呼ばれるためfinalフィールドには使えません。"),
                choice("d", "コンストラクタより常に高速なケース",
                       misconception: "セッタの方が速いと誤解",
                       explanation: "起動時の差は無視できるレベルです。")
            ],
            explanationRef: "explain-boot3-di-setter-001",
            designIntent: "セッタインジェクションの適切なユースケースを理解する。"
        ),
        quiz(
            id: "boot3-di-setter-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["セッタインジェクション", "循環依存", "回避"],
            code: """
@Service
class A {
    private B b;
    @Autowired
    public void setB(B b) { this.b = b; }
}
@Service
class B {
    private A a;
    @Autowired
    public void setA(A a) { this.a = a; }
}
""",
            question: "セッタインジェクションで循環依存を組んだとき（Spring Boot 2.5以前）の挙動はどれか？",
            choices: [
                choice("a", "AとBを先に生成してからセッタで互いを注入するため起動できる",
                       correct: true,
                       explanation: "セッタインジェクションはインスタンス生成後にセッタを呼ぶ2段階のため、コンストラクタ循環依存のような生成不能には陥りません。ただし循環依存自体が設計の問題です。"),
                choice("b", "コンストラクタ循環依存と同様にBeanCreationExceptionになる",
                       misconception: "循環依存はすべて同じエラーと誤解",
                       explanation: "コンストラクタ循環依存とセッタ循環依存では起動時の挙動が異なります。"),
                choice("c", "一方のBeanだけが生成されもう一方はnullになる",
                       misconception: "片方が省略されると誤解",
                       explanation: "両方生成されますが、設計として循環依存は避けるべきです。"),
                choice("d", "SpringがAとBをマージして1つのBeanにする",
                       misconception: "Springが自動でBeanを統合すると誤解",
                       explanation: "Springはクラスをマージしません。")
            ],
            explanationRef: "explain-boot3-di-setter-002",
            designIntent: "セッタインジェクションが循環依存を起動時に回避できる理由を理解する。"
        ),
        quiz(
            id: "boot3-di-setter-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Autowired", "セッタ", "命名規則"],
            code: """
@Service
class MetricsService {
    private MeterRegistry registry;

    @Autowired
    public void initRegistry(MeterRegistry registry) {
        this.registry = registry;
    }
}
""",
            question: "このコードでセッタメソッドが `setRegistry` でなく `initRegistry` という名前でも問題はないか？",
            choices: [
                choice("a", "問題ない。`@Autowired` が付いていればメソッド名は何でもよい",
                       correct: true,
                       explanation: "Springのセッタインジェクションはメソッド名ではなく `@Autowired` で対象を決めます。`set` プレフィックスは慣例ですが必須ではありません。"),
                choice("b", "`set` で始まらないとBeanが注入されない",
                       misconception: "セッタインジェクションに命名規則の制約があると誤解",
                       explanation: "`@Autowired` さえあればメソッド名は自由です。"),
                choice("c", "`init` で始まるメソッドは `@PostConstruct` の対象になる",
                       misconception: "@PostConstructのメソッド命名と混同",
                       explanation: "`@PostConstruct` は `@PostConstruct` アノテーションで指定します。名前は関係ありません。"),
                choice("d", "コンパイルエラーになる",
                       misconception: "命名に文法制約があると誤解",
                       explanation: "Javaの文法はメソッド名を制約しません。")
            ],
            explanationRef: "explain-boot3-di-setter-003",
            designIntent: "セッタインジェクションのメソッド命名に制約がないことを理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 5: Beanスコープ (7問)
    // ─────────────────────────────────────────
    private static let diScope: [Quiz] = [
        quiz(
            id: "boot3-di-scope-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["スコープ", "シングルトン", "デフォルト"],
            code: """
@Service
class CounterService {
    private int count = 0;
    public void increment() { count++; }
    public int getCount() { return count; }
}
""",
            question: "このBeanにスコープ指定がない場合、複数のControllerから同時にインジェクションされたとき `count` はどうなるか？",
            choices: [
                choice("a", "全Controllerで同じインスタンスが共有されるため `count` は全体で累積する",
                       correct: true,
                       explanation: "デフォルトスコープはシングルトンです。1つのインスタンスがアプリ全体で共有されます。複数のControllerが同じ `count` を変更するためマルチスレッド環境では競合も起きます。"),
                choice("b", "Controllerごとに別インスタンスが生成されるため `count` はそれぞれ独立する",
                       misconception: "デフォルトがプロトタイプと誤解",
                       explanation: "デフォルトはシングルトンです。"),
                choice("c", "リクエストごとに新しいインスタンスが生成される",
                       misconception: "デフォルトがリクエストスコープと誤解",
                       explanation: "リクエストスコープは `@RequestScope` が必要です。"),
                choice("d", "スコープ指定なしはコンパイルエラー",
                       misconception: "スコープ指定が必須と誤解",
                       explanation: "スコープ省略はシングルトンになります。")
            ],
            explanationRef: "explain-boot3-di-scope-001",
            designIntent: "デフォルトスコープがシングルトンであることを理解する。"
        ),
        quiz(
            id: "boot3-di-scope-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Scope", "prototype", "毎回生成"],
            code: """
@Component
@Scope("prototype")
class RequestContext {
    private String userId;
    public void setUserId(String id) { this.userId = id; }
}
""",
            question: "`@Scope(\"prototype\")` の動作として正しいものはどれか？",
            choices: [
                choice("a", "`@Autowired` で注入するたびに新しいインスタンスが生成される",
                       correct: true,
                       explanation: "プロトタイプスコープはBeanの取得ごとに新しいインスタンスを返します。シングルトンBeanに1回注入された場合はその1インスタンスが保持されます（注意点あり）。"),
                choice("b", "リクエストごとに生成されHTTPリクエスト終了時に破棄される",
                       misconception: "@RequestScopeと混同",
                       explanation: "リクエストスコープは `@RequestScope` です。プロトタイプはSpringによる破棄ライフサイクルがありません。"),
                choice("c", "スレッドごとに1つのインスタンスが生成される",
                       misconception: "スレッドスコープと混同",
                       explanation: "スレッドスコープはカスタム実装が必要です。プロトタイプはDI取得ごとです。"),
                choice("d", "シングルトンBeanに注入すると毎リクエストで新しいインスタンスが自動で切り替わる",
                       misconception: "シングルトンへ注入した後もプロトタイプが機能すると誤解",
                       explanation: "シングルトンに1度注入されたプロトタイプは固定されます。毎回切り替えにはApplicationContextやProxyが必要です。")
            ],
            explanationRef: "explain-boot3-di-scope-002",
            designIntent: "プロトタイプスコープの生成タイミングを理解する。"
        ),
        quiz(
            id: "boot3-di-scope-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@RequestScope", "Webスコープ", "HTTPリクエスト"],
            code: """
@Component
@RequestScope
class RequestInfo {
    private String userAgent;
    // getter/setter
}
""",
            question: "`@RequestScope` のBeanのライフサイクルとして正しいものはどれか？",
            choices: [
                choice("a", "HTTPリクエストごとに生成され、レスポンスが返ると破棄される",
                       correct: true,
                       explanation: "`@RequestScope` は1HTTPリクエストに1インスタンスです。`request.setAttribute` に近い概念です。リクエスト間でデータが混在しません。"),
                choice("b", "アプリ起動時に生成されシャットダウン時に破棄される",
                       misconception: "シングルトンのライフサイクルと混同",
                       explanation: "それはシングルトンスコープです。"),
                choice("c", "セッションごとに生成されセッション終了時に破棄される",
                       misconception: "@SessionScopeと混同",
                       explanation: "セッションスコープは `@SessionScope` です。"),
                choice("d", "メソッド呼び出しごとに生成される",
                       misconception: "プロトタイプスコープと混同",
                       explanation: "メソッド呼び出しごとはプロトタイプに近い動作です。")
            ],
            explanationRef: "explain-boot3-di-scope-003",
            designIntent: "@RequestScopeのHTTPリクエスト単位のライフサイクルを理解する。"
        ),
        quiz(
            id: "boot3-di-scope-004",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["シングルトン", "プロトタイプ", "注入問題"],
            code: """
@Service // シングルトン
class OrderService {
    @Autowired
    private TemporaryCart cart; // プロトタイプBeanを注入
}

@Component
@Scope("prototype")
class TemporaryCart { ... }
""",
            question: "シングルトンBeanにプロトタイプBeanを `@Autowired` で注入した場合の問題はどれか？",
            choices: [
                choice("a", "`OrderService` は1度だけ生成されるため `cart` は常に同じインスタンスが使われ、プロトタイプの意味がなくなる",
                       correct: true,
                       explanation: "シングルトンへの注入は起動時の1回のみです。その後は同じ `cart` インスタンスが再利用されます。毎回新インスタンスが必要なら `ApplicationContext.getBean()` やScopedProxyを使います。"),
                choice("b", "プロトタイプBeanはシングルトンBeanに注入できないためエラーになる",
                       misconception: "スコープの組み合わせでエラーになると誤解",
                       explanation: "注入自体は成功します。ただし期待通りに動かない問題が起きます。"),
                choice("c", "リクエストのたびに `cart` のインスタンスが自動で切り替わる",
                       misconception: "プロトタイプが自動で都度生成されると誤解",
                       explanation: "自動切り替えにはScopedProxyモードが必要です。"),
                choice("d", "プロトタイプはWebアプリでしか使えない",
                       misconception: "プロトタイプスコープの適用範囲を誤解",
                       explanation: "プロトタイプはWebアプリ以外でも使えます。")
            ],
            explanationRef: "explain-boot3-di-scope-004",
            designIntent: "シングルトン×プロトタイプのスコープ混在問題を理解する。"
        ),
        quiz(
            id: "boot3-di-scope-005",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Scope", "proxyMode", "ScopedProxy"],
            code: """
@Component
@Scope(value = "prototype",
       proxyMode = ScopedProxyMode.TARGET_CLASS)
class TemporaryCart { ... }

@Service
class OrderService {
    @Autowired TemporaryCart cart;
    void addItem(Item item) { cart.add(item); }
}
""",
            question: "`proxyMode = ScopedProxyMode.TARGET_CLASS` を指定した場合の効果はどれか？",
            choices: [
                choice("a", "シングルトンBeanに注入されたプロキシを通じてメソッド呼び出しごとに実際のプロトタイプインスタンスが取得される",
                       correct: true,
                       explanation: "ScopedProxyはCGLIBでサブクラスを生成し、メソッド呼び出し時にスコープに合ったBeanを取得します。`addItem` を呼ぶたびに新しい `TemporaryCart` が使われます。"),
                choice("b", "プロキシを使うとシングルトンがプロトタイプに変換される",
                       misconception: "OrderServiceのスコープが変わると誤解",
                       explanation: "OrderServiceはシングルトンのままです。cartの取得方法が変わります。"),
                choice("c", "マルチスレッドの排他制御が自動で行われる",
                       misconception: "ScopedProxyがスレッドセーフを保証すると誤解",
                       explanation: "スレッドセーフはScopedProxyの機能ではありません。"),
                choice("d", "`TARGET_CLASS` は `@RequestScope` 専用の設定",
                       misconception: "proxyModeがRequestScope限定と誤解",
                       explanation: "proxyModeはprototype/request/sessionなど複数のスコープで使えます。")
            ],
            explanationRef: "explain-boot3-di-scope-005",
            designIntent: "ScopedProxyModeによるスコープ違いのBean注入解決策を理解する。"
        ),
        quiz(
            id: "boot3-di-scope-006",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["シングルトン", "スレッドセーフ", "状態"],
            code: """
@Service
class CounterService {
    private int count = 0; // 共有状態

    public void increment() { count++; }
    public int get() { return count; }
}
""",
            question: "シングルトンスコープのBeanにインスタンス変数 `count` を持たせた場合のリスクはどれか？",
            choices: [
                choice("a", "複数リクエストが同時に `increment()` を呼ぶと競合し、カウントが正確にならない（スレッド安全でない）",
                       correct: true,
                       explanation: "シングルトンは全リクエストで共有されます。`count++` はアトミックでないため並行アクセスで値が失われます。`AtomicInteger` や `synchronized` で対処します。"),
                choice("b", "シングルトンはフィールドを持てない",
                       misconception: "シングルトンにフィールドが使えないと誤解",
                       explanation: "フィールドは持てます。ただし変更可能な共有状態を持つのはリスクです。"),
                choice("c", "Spring Bootはシングルトンのフィールドを自動でスレッドセーフにする",
                       misconception: "フレームワークがスレッドセーフを保証すると誤解",
                       explanation: "Springはスレッドセーフを自動で保証しません。"),
                choice("d", "リクエストごとに `count` がリセットされる",
                       misconception: "シングルトンのフィールドがリクエストごとにリセットされると誤解",
                       explanation: "シングルトンはアプリ全体で1インスタンスです。フィールドは維持されます。")
            ],
            explanationRef: "explain-boot3-di-scope-006",
            designIntent: "シングルトンの可変状態が引き起こすスレッドセーフの問題を理解する。"
        ),
        quiz(
            id: "boot3-di-scope-007",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Scope", "種類", "一覧"],
            code: """
// どのスコープを選ぶべきか？
""",
            question: "Springのスコープとその説明の組み合わせとして正しいものはどれか？",
            choices: [
                choice("a", "singleton＝アプリに1つ、prototype＝取得ごとに新規、request＝1HTTPリクエストに1つ、session＝1HTTPセッションに1つ",
                       correct: true,
                       explanation: "これがSpringの主要スコープの正しい対応です。Webアプリでは request/session が使えます。デフォルトはsingleton です。"),
                choice("b", "singleton＝スレッドに1つ、prototype＝リクエストに1つ",
                       misconception: "singletonとrequestの意味を混同",
                       explanation: "singletonはアプリに1つ、requestは1HTTPリクエストに1つです。"),
                choice("c", "prototype＝セッションに1つ、request＝メソッド呼び出しに1つ",
                       misconception: "各スコープの意味をランダムに混同",
                       explanation: "正しくはprototype＝取得ごと新規、request＝1HTTPリクエストです。"),
                choice("d", "すべてのスコープはWebアプリでのみ使用可能",
                       misconception: "全スコープがWeb専用と誤解",
                       explanation: "singleton/prototypeはWeb以外でも使えます。request/sessionはWebコンテキストが必要です。")
            ],
            explanationRef: "explain-boot3-di-scope-007",
            designIntent: "主要Beanスコープの種類と説明を整理する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 6: @Primary / @Qualifier (6問)
    // ─────────────────────────────────────────
    private static let diPrimaryQualifier: [Quiz] = [
        quiz(
            id: "boot3-di-qualifier-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Primary", "複数Bean", "デフォルト選択"],
            code: """
interface NotificationSender {
    void send(String msg);
}

@Component @Primary
class EmailSender implements NotificationSender { ... }

@Component
class SmsSender implements NotificationSender { ... }

@Service
class AlertService {
    @Autowired NotificationSender sender; // どちらが選ばれる？
}
""",
            question: "`@Primary` がついている場合、`sender` に注入されるのはどちらか？",
            choices: [
                choice("a", "`EmailSender`（`@Primary` が付いているBeanが選ばれる）",
                       correct: true,
                       explanation: "`@Primary` はデフォルトの候補を明示します。同型のBeanが複数あるとき `@Qualifier` で明示しない限り `@Primary` のBeanが選ばれます。"),
                choice("b", "`SmsSender`（アルファベット順で後の方が優先）",
                       misconception: "アルファベット順でBeanが選ばれると誤解",
                       explanation: "Springはアルファベット順でBeanを選びません。"),
                choice("c", "2つあるためNoUniqueBeanDefinitionExceptionが出る",
                       misconception: "@Primaryがなければエラーと誤解",
                       explanation: "`@Primary` があるためエラーにならず EmailSender が選ばれます。"),
                choice("d", "先に定義したBeanが選ばれる",
                       misconception: "定義順で優先度が決まると誤解",
                       explanation: "定義順はBeanの選択基準ではありません。")
            ],
            explanationRef: "explain-boot3-di-qualifier-001",
            designIntent: "@Primaryが複数候補の中でデフォルトを決める仕組みを理解する。"
        ),
        quiz(
            id: "boot3-di-qualifier-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Qualifier", "Bean名指定", "明示選択"],
            code: """
@Component
class EmailSender implements NotificationSender { ... }

@Component
class SmsSender implements NotificationSender { ... }

@Service
class CriticalAlertService {
    @Autowired
    @Qualifier("smsSender")
    private NotificationSender sender;
}
""",
            question: "`@Qualifier(\"smsSender\")` の効果として正しいものはどれか？",
            choices: [
                choice("a", "Bean名が `smsSender` のBeanを明示的に選択して注入する",
                       correct: true,
                       explanation: "`@Qualifier` にはBean名を文字列で指定します。`SmsSender` クラスのデフォルトBean名は `smsSender`（先頭小文字）です。複数候補の中から特定のBeanを選ぶときに使います。"),
                choice("b", "`SmsSender` クラス名でなくインターフェース名で検索する",
                       misconception: "Qualifierがインターフェース名を使うと誤解",
                       explanation: "@QualifierはBean名（通常は実装クラスのキャメルケース）で指定します。"),
                choice("c", "`@Primary` と組み合わせると両方が無効になる",
                       misconception: "@Primaryと@Qualifierが打ち消し合うと誤解",
                       explanation: "`@Qualifier` は `@Primary` より優先します。明示的な指定が勝ちます。"),
                choice("d", "文字列なので大文字・小文字は区別されない",
                       misconception: "Bean名の大文字小文字が区別されないと誤解",
                       explanation: "Bean名は大文字・小文字を区別します。`SmsSender` と `smsSender` は別です。")
            ],
            explanationRef: "explain-boot3-di-qualifier-002",
            designIntent: "@QualifierでBean名による明示選択を理解する。"
        ),
        quiz(
            id: "boot3-di-qualifier-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Qualifier", "@Primary", "優先順位"],
            code: """
@Component @Primary
class EmailSender implements NotificationSender { ... }

@Component
class SmsSender implements NotificationSender { ... }

@Service
class BackupService {
    @Autowired
    @Qualifier("smsSender")
    private NotificationSender sender;
}
""",
            question: "`@Primary` が EmailSender にあっても `@Qualifier(\"smsSender\")` を指定した場合、どちらが注入されるか？",
            choices: [
                choice("a", "`SmsSender`（`@Qualifier` は `@Primary` より優先される）",
                       correct: true,
                       explanation: "`@Qualifier` による明示指定は `@Primary` によるデフォルト選択より優先されます。明示 > デフォルト というSpringの原則です。"),
                choice("b", "`EmailSender`（`@Primary` が常に最優先）",
                       misconception: "@Primaryが@Qualifierより優先されると誤解",
                       explanation: "@Qualifierによる明示指定が@Primaryを上回ります。"),
                choice("c", "2つの指定が競合してエラーになる",
                       misconception: "@Primaryと@Qualifierが矛盾するとエラーになると誤解",
                       explanation: "矛盾はなく、@Qualifierが優先されます。"),
                choice("d", "両方が注入され `List<NotificationSender>` になる",
                       misconception: "競合時に両方が注入されると誤解",
                       explanation: "1つの `NotificationSender` フィールドに2つは注入されません。")
            ],
            explanationRef: "explain-boot3-di-qualifier-003",
            designIntent: "@Qualifierが@Primaryより優先されることを理解する。"
        ),
        quiz(
            id: "boot3-di-qualifier-004",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Autowired", "required=false", "任意Bean"],
            code: """
@Service
class FeatureFlagService {
    @Autowired(required = false)
    private FeatureFlagProvider provider;

    public boolean isEnabled(String flag) {
        if (provider == null) return false;
        return provider.isEnabled(flag);
    }
}
""",
            question: "`FeatureFlagProvider` のBeanが存在しない場合、このコードはどう動作するか？",
            choices: [
                choice("a", "`provider` は `null` になり、`isEnabled` は常に `false` を返す",
                       correct: true,
                       explanation: "`required = false` にすると対応するBeanが見つからなくても起動失敗せず `null` が設定されます。nullチェックで安全に任意依存を扱えます。"),
                choice("b", "Beanがないため起動時にエラーになる",
                       misconception: "required=falseの効果を理解していない",
                       explanation: "`required = false` の目的がBeanがなくても起動できるようにすることです。"),
                choice("c", "Springがデフォルト実装を自動生成する",
                       misconception: "Springが空実装を提供すると誤解",
                       explanation: "Springはデフォルト実装を生成しません。"),
                choice("d", "`provider` は空のプロキシになり、メソッド呼び出しはすべてno-opになる",
                       misconception: "Springが自動でnullセーフなプロキシを生成すると誤解",
                       explanation: "プロキシは自動生成されません。nullになります。")
            ],
            explanationRef: "explain-boot3-di-qualifier-004",
            designIntent: "@Autowired(required=false)で任意依存を安全に扱う方法を理解する。"
        ),
        quiz(
            id: "boot3-di-qualifier-005",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["List注入", "全Bean取得", "@Autowired"],
            code: """
@Service
class NotificationDispatcher {
    @Autowired
    private List<NotificationSender> senders;

    public void dispatch(String msg) {
        senders.forEach(s -> s.send(msg));
    }
}
""",
            question: "`List<NotificationSender>` に `@Autowired` した場合の動作はどれか？",
            choices: [
                choice("a", "`NotificationSender` を実装したすべてのBeanがリストとして注入される",
                       correct: true,
                       explanation: "Springは同じ型のすべてのBeanをリストに収めて注入します。`EmailSender` と `SmsSender` の両方が入ります。全Senderにブロードキャストするパターンによく使われます。"),
                choice("b", "`@Primary` のBeanだけが1つ入ったリストになる",
                       misconception: "@PrimaryのBeanだけが選ばれると誤解",
                       explanation: "List注入は型に一致するすべてのBeanを集めます。"),
                choice("c", "リストは型推論できないため起動エラーになる",
                       misconception: "ジェネリクスのList注入が非対応と誤解",
                       explanation: "SpringはList<T>の型パラメータを認識して注入します。"),
                choice("d", "注入順は定義順とは無関係でランダムになる",
                       misconception: "注入順がランダムと誤解",
                       explanation: "順序はBeanの定義やスキャン順に依存します。`@Order` アノテーションで制御できます。")
            ],
            explanationRef: "explain-boot3-di-qualifier-005",
            designIntent: "List<T>への@Autowiredで同型の全Beanを収集できることを理解する。"
        ),
        quiz(
            id: "boot3-di-qualifier-006",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Bean", "Bean名", "@Qualifier"],
            code: """
@Configuration
class DataSourceConfig {
    @Bean("primaryDs")
    DataSource primaryDataSource() { ... }

    @Bean("secondaryDs")
    DataSource secondaryDataSource() { ... }
}

@Repository
class UserRepository {
    @Autowired
    @Qualifier("secondaryDs")
    private DataSource dataSource;
}
""",
            question: "`@Bean(\"primaryDs\")` で命名したBeanを `@Qualifier` で指定する場合の書き方として正しいものはどれか？",
            choices: [
                choice("a", "`@Qualifier(\"primaryDs\")` — `@Bean` の名前をそのまま文字列で指定する",
                       correct: true,
                       explanation: "`@Bean(\"primaryDs\")` で登録したBean名が `primaryDs` になります。`@Qualifier` にはその名前を指定します。クラス名由来のBean名とは異なります。"),
                choice("b", "`@Qualifier(\"PrimaryDs\")` — 先頭を大文字にする",
                       misconception: "@BeanのBean名が先頭大文字になると誤解",
                       explanation: "`@Bean(\"primaryDs\")` と指定した名前がそのままBean名です。大文字小文字はそのままです。"),
                choice("c", "`@Qualifier(\"dataSourceConfig.primaryDataSource\")` — FQMNで指定する",
                       misconception: "メソッド名のFQMNが使われると誤解",
                       explanation: "Bean名は `@Bean` に渡した文字列です。メソッド名（名前未指定時）は `primaryDataSource` になります。"),
                choice("d", "`@Bean` で名前を付けると `@Qualifier` では選択できない",
                       misconception: "@Bean命名と@Qualifierが非対応と誤解",
                       explanation: "`@Bean` で付けた名前は `@Qualifier` でそのまま使えます。")
            ],
            explanationRef: "explain-boot3-di-qualifier-006",
            designIntent: "@BeanとBean名および@Qualifierの連携を理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 7: @Bean / @Configuration (6問)
    // ─────────────────────────────────────────
    private static let diBeanConfig: [Quiz] = [
        quiz(
            id: "boot3-di-beanconfig-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Configuration", "@Bean", "ファクトリメソッド"],
            code: """
@Configuration
class AppConfig {
    @Bean
    ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.enable(SerializationFeature.INDENT_OUTPUT);
        return mapper;
    }
}
""",
            question: "この `@Bean` メソッドの役割として正しいものはどれか？",
            choices: [
                choice("a", "カスタム設定を施した `ObjectMapper` をSpring管理のBeanとして登録する",
                       correct: true,
                       explanation: "`@Bean` メソッドはSpringが返り値をBeanとして管理します。`ObjectMapper` はサードパーティクラスなので `@Component` を付けられず、`@Bean` で登録するのが正しいパターンです。"),
                choice("b", "このメソッドはHTTPリクエストのたびに呼ばれる",
                       misconception: "@BeanメソッドがリクエストごとにCallされると誤解",
                       explanation: "`@Bean` メソッドは起動時（または取得時）に1度だけ呼ばれBeanが生成されます。"),
                choice("c", "`@Configuration` がなくても `@Bean` だけで機能する",
                       misconception: "@Configurationが不要と誤解",
                       explanation: "`@Bean` は `@Configuration` か `@Component` クラス内で使います。両者の動作に差があります（後述）。"),
                choice("d", "このBeanはシリアライズにのみ使われSpringが他の用途には使わない",
                       misconception: "@Beanで登録したBeanの用途が限定されると誤解",
                       explanation: "登録されたBeanは他のクラスへの注入など通常どおり使えます。")
            ],
            explanationRef: "explain-boot3-di-beanconfig-001",
            designIntent: "@BeanによるサードパーティクラスのBean登録を理解する。"
        ),
        quiz(
            id: "boot3-di-beanconfig-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Configuration", "CGLIB", "シングルトン保証"],
            code: """
@Configuration
class AppConfig {
    @Bean
    ServiceA serviceA() { return new ServiceA(serviceB()); }

    @Bean
    ServiceB serviceB() { return new ServiceB(); }
}
""",
            question: "`serviceA()` 内で `serviceB()` を直接呼び出しているが、`ServiceB` は何インスタンス生成されるか？",
            choices: [
                choice("a", "1つ（`@Configuration` はCGLIBでプロキシ化され、`@Bean` メソッドはシングルトンが返る）",
                       correct: true,
                       explanation: "`@Configuration` クラスはCGLIBによってサブクラス化されます。`serviceB()` の2回目以降の呼び出しはSpringのBeanキャッシュから返すため、同じインスタンスが使われます。"),
                choice("b", "2つ（`serviceB()` を直接呼んでいるためnewが2回走る）",
                       misconception: "通常のJavaメソッド呼び出しと同じと誤解",
                       explanation: "@ConfigurationクラスではCGLIBにより@Beanメソッドの直接呼び出しがインターセプトされます。"),
                choice("c", "0個（`@Bean` メソッドは `new` を自動的にBeanの参照に書き換える）",
                       misconception: "newが自動変換されると誤解",
                       explanation: "newが書き換えられるのではなく、メソッド呼び出しが横取りされてキャッシュから返します。"),
                choice("d", "毎回の呼び出しごとに新しいインスタンスが生成される",
                       misconception: "@BeanメソッドがJavaメソッドと全く同じと誤解",
                       explanation: "@ConfigurationクラスのCGLIBプロキシがシングルトン性を保証します。")
            ],
            explanationRef: "explain-boot3-di-beanconfig-002",
            designIntent: "@ConfigurationのCGLIBプロキシによるシングルトン保証を理解する。"
        ),
        quiz(
            id: "boot3-di-beanconfig-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Bean", "@Component", "liteモード", "差異"],
            code: """
// パターンA
@Configuration
class ConfigA {
    @Bean ServiceA a() { return new ServiceA(b()); }
    @Bean ServiceB b() { return new ServiceB(); }
}

// パターンB
@Component
class ConfigB {
    @Bean ServiceA a() { return new ServiceA(b()); }
    @Bean ServiceB b() { return new ServiceB(); }
}
""",
            question: "`@Component` 内の `@Bean`（liteモード）と `@Configuration` 内の `@Bean` の最大の違いはどれか？",
            choices: [
                choice("a", "liteモードはCGLIBプロキシが作られないため、`@Bean` メソッドの直接呼び出しは通常のJavaメソッドとして扱われ新しいインスタンスが生成される",
                       correct: true,
                       explanation: "`@Component` 内の `@Bean` はliteモードと呼ばれCGLIBサブクラスが作られません。`a()` 内で `b()` を呼ぶと毎回 `new ServiceB()` が実行され、Beanとは異なるインスタンスが作られます。"),
                choice("b", "liteモードはBeanが作られない",
                       misconception: "@Component内の@BeanはBeanにならないと誤解",
                       explanation: "liteモードでもBeanは作られます。ただしシングルトン保証の挙動が異なります。"),
                choice("c", "どちらも同じ動作でCGLIBプロキシが作られる",
                       misconception: "@ConfigurationとComponentの動作が同一と誤解",
                       explanation: "@ConfigurationのみCGLIBプロキシが作られます。"),
                choice("d", "`@Component` 内の `@Bean` はXMLでしか設定できない",
                       misconception: "liteモードをXML設定と混同",
                       explanation: "liteモードはJavaアノテーションの話です。XMLとは無関係です。")
            ],
            explanationRef: "explain-boot3-di-beanconfig-003",
            designIntent: "@ConfigurationのCGLIBモードとliteモードの動作差を理解する。"
        ),
        quiz(
            id: "boot3-di-beanconfig-004",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Bean", "メソッド名", "Bean名"],
            code: """
@Configuration
class Config {
    @Bean
    RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
""",
            question: "このBeanのBean名はどれか？",
            choices: [
                choice("a", "`restTemplate`（`@Bean` に名前を指定しない場合はメソッド名がBean名になる）",
                       correct: true,
                       explanation: "`@Bean` の名前を省略するとメソッド名がBean名になります。`@Qualifier(\"restTemplate\")` で注入先を指定できます。`@Bean(\"myRestTemplate\")` のように明示もできます。"),
                choice("b", "`RestTemplate`（クラス名がBean名になる）",
                       misconception: "クラス名がBean名と誤解",
                       explanation: "@Bean登録ではメソッド名がBean名です。クラス名ではありません。"),
                choice("c", "`config.restTemplate`（クラス名.メソッド名の組み合わせ）",
                       misconception: "FQMNがBean名になると誤解",
                       explanation: "Bean名はシンプルなメソッド名です。"),
                choice("d", "ランダムなUUIDが割り当てられる",
                       misconception: "Bean名が自動でランダム生成されると誤解",
                       explanation: "Bean名はランダムではありません。")
            ],
            explanationRef: "explain-boot3-di-beanconfig-004",
            designIntent: "@BeanのデフォルトBean名がメソッド名であることを理解する。"
        ),
        quiz(
            id: "boot3-di-beanconfig-005",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Bean", "引数", "他Bean参照"],
            code: """
@Configuration
class Config {
    @Bean
    OrderService orderService(OrderRepository repo,
                              EmailSender sender) {
        return new OrderService(repo, sender);
    }
}
""",
            question: "`@Bean` メソッドの引数 `repo` と `sender` はどのように解決されるか？",
            choices: [
                choice("a", "Springが同型のBeanをApplicationContextから探して引数として渡す",
                       correct: true,
                       explanation: "`@Bean` メソッドの引数はSpringが自動的にBeanを解決します。`@Autowired` と同様の仕組みです。`OrderRepository` と `EmailSender` のBeanが存在していれば自動で注入されます。"),
                choice("b", "引数はすべてnullで渡されるため自分でnullチェックが必要",
                       misconception: "@BeanメソッドにDIが効かないと誤解",
                       explanation: "@BeanメソッドにはSpringがDIします。"),
                choice("c", "@Autowiredを引数に付けないと解決されない",
                       misconception: "@Beanメソッド引数に@Autowiredが必要と誤解",
                       explanation: "@BeanメソッドはデフォルトでDI対象です。@Autowiredは不要です。"),
                choice("d", "引数を取る@Beanメソッドはコンパイルエラーになる",
                       misconception: "@Beanメソッドに引数が使えないと誤解",
                       explanation: "@Beanメソッドに引数を持たせることは正式な使い方です。")
            ],
            explanationRef: "explain-boot3-di-beanconfig-005",
            designIntent: "@Beanメソッドの引数にSpringが自動DI解決することを理解する。"
        ),
        quiz(
            id: "boot3-di-beanconfig-006",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@ConditionalOnMissingBean", "@Bean", "条件付き登録"],
            code: """
@Configuration
class DefaultConfig {
    @Bean
    @ConditionalOnMissingBean(CacheManager.class)
    CacheManager cacheManager() {
        return new SimpleCacheManager();
    }
}
""",
            question: "`@ConditionalOnMissingBean(CacheManager.class)` の動作として正しいものはどれか？",
            choices: [
                choice("a", "`CacheManager` のBeanが他で定義されていない場合のみ `SimpleCacheManager` を登録する",
                       correct: true,
                       explanation: "Spring Bootの自動設定が多用するパターンです。ユーザーが独自の `CacheManager` を定義していればそちらが使われ、何もなければデフォルトが登録されます。"),
                choice("b", "`CacheManager` がnullのときにだけ呼ばれる",
                       misconception: "実行時のnullチェックと混同",
                       explanation: "Beanの存在はアプリケーションコンテキスト構築時に確認されます。実行時のnullチェックではありません。"),
                choice("c", "テスト環境でのみ有効になる",
                       misconception: "ConditionalOnMissingBeanがテスト専用と誤解",
                       explanation: "本番/テスト関係なく、BeanがApplicationContextに存在するかどうかで判断します。"),
                choice("d", "このアノテーションはSpring Boot 3.xで廃止された",
                       misconception: "バージョンによる廃止を誤解",
                       explanation: "@ConditionalOnMissingBeanはSpring Boot 3.xでも現役です。")
            ],
            explanationRef: "explain-boot3-di-beanconfig-006",
            designIntent: "@ConditionalOnMissingBeanによるデフォルトBean提供パターンを理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 8: コンポーネントスキャン (4問)
    // ─────────────────────────────────────────
    private static let diComponentScan: [Quiz] = [
        quiz(
            id: "boot3-di-scan-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@ComponentScan", "@SpringBootApplication", "スキャン範囲"],
            code: """
// com.example.app.Application.java
@SpringBootApplication
public class Application { ... }

// com.example.app.service.UserService.java (✓ スキャンされる)
// com.example.infra.EmailSender.java      (? スキャンされる？)
""",
            question: "`com.example.infra.EmailSender` が `@Component` を付けていてもスキャンされない場合の原因と対処はどれか？",
            choices: [
                choice("a", "スキャン範囲外のパッケージにあるため `@ComponentScan(basePackages=\"com.example\")` などで範囲を広げる",
                       correct: true,
                       explanation: "`@SpringBootApplication` のデフォルトスキャン範囲は起動クラスと同パッケージ以下です。`com.example.infra` は `com.example.app` の下でないためスキャン外です。"),
                choice("b", "`infra` という名前のパッケージは禁止されている",
                       misconception: "パッケージ名に制限があると誤解",
                       explanation: "パッケージ名に制限はありません。スキャン範囲の問題です。"),
                choice("c", "`@SpringBootApplication` と同じパッケージにクラスを移動するしか解決策がない",
                       misconception: "クラス移動が唯一の解決策と誤解",
                       explanation: "`@ComponentScan` のbasePackagesを変更する方法もあります。"),
                choice("d", "クラスパスに含まれていないためスキャンされない",
                       misconception: "クラスパスとスキャン範囲を混同",
                       explanation: "クラスパスには含まれていてもスキャン範囲外なら検出されません。")
            ],
            explanationRef: "explain-boot3-di-scan-001",
            designIntent: "@ComponentScanのデフォルト範囲と拡張方法を理解する。"
        ),
        quiz(
            id: "boot3-di-scan-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@ComponentScan", "excludeFilters", "除外"],
            code: """
@SpringBootApplication
@ComponentScan(
    excludeFilters = @ComponentScan.Filter(
        type = FilterType.ANNOTATION,
        classes = DevOnly.class
    )
)
public class Application { ... }
""",
            question: "この `excludeFilters` 設定の効果はどれか？",
            choices: [
                choice("a", "`@DevOnly` アノテーションが付いたクラスをコンポーネントスキャンから除外する",
                       correct: true,
                       explanation: "`ANNOTATION` フィルタは指定したアノテーションが付いたクラスをスキャン対象から外します。開発専用BeanをProduction起動時に除外するパターンです。"),
                choice("b", "`@DevOnly` のクラスをすべて削除する",
                       misconception: "除外がクラスの削除を意味すると誤解",
                       explanation: "クラスはクラスパスに残りますが、Beanとして登録されないだけです。"),
                choice("c", "`DevOnly` という名前のパッケージをスキャンしない",
                       misconception: "クラス名とパッケージ名を混同",
                       explanation: "FilterType.ANNOTATIONはアノテーションによるフィルタです。パッケージ名ではありません。"),
                choice("d", "`@DevOnly` が付いたBeanをシングルトンからプロトタイプに変更する",
                       misconception: "除外フィルタがスコープを変えると誤解",
                       explanation: "excludeFiltersはBeanの登録自体を止めます。スコープは変えません。")
            ],
            explanationRef: "explain-boot3-di-scan-002",
            designIntent: "excludeFiltersでアノテーションによるBean除外を理解する。"
        ),
        quiz(
            id: "boot3-di-scan-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Import", "設定クラス", "手動インポート"],
            code: """
@Configuration
@Import(SecurityConfig.class)
class AppConfig { }

@Configuration
class SecurityConfig {
    @Bean SecurityFilterChain securityChain(...) { ... }
}
""",
            question: "`@Import(SecurityConfig.class)` の用途として正しいものはどれか？",
            choices: [
                choice("a", "コンポーネントスキャン対象外の `@Configuration` クラスを明示的に読み込む",
                       correct: true,
                       explanation: "`@Import` はスキャン対象外のConfigurationクラスやBeanを手動でApplicationContextに取り込みます。モジュール分割やテスト時の部分的な設定読み込みに使います。"),
                choice("b", "Javaのimport文と同じでクラス参照を解決する",
                       misconception: "Javaのimportと混同",
                       explanation: "`@Import` はSpringのBean登録に関するアノテーションです。Javaのimport文とは別物です。"),
                choice("c", "`SecurityConfig` のメソッドをすべて `AppConfig` にコピーする",
                       misconception: "クラスのマージと誤解",
                       explanation: "クラスはマージされません。ApplicationContextに両方が存在します。"),
                choice("d", "`@Import` は `@SpringBootApplication` が自動で行うため不要",
                       misconception: "@SpringBootApplicationが@Importを代替すると誤解",
                       explanation: "@SpringBootApplicationはコンポーネントスキャンを行いますが、スキャン範囲外のクラスは@Importで明示する必要があります。")
            ],
            explanationRef: "explain-boot3-di-scan-003",
            designIntent: "@Importによる設定クラスの明示的取り込みを理解する。"
        ),
        quiz(
            id: "boot3-di-scan-004",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@PostConstruct", "@PreDestroy", "ライフサイクル"],
            code: """
@Component
class DatabaseInitializer {
    @PostConstruct
    void init() {
        System.out.println("Bean生成後に初期化");
    }

    @PreDestroy
    void cleanup() {
        System.out.println("Bean破棄前にクリーンアップ");
    }
}
""",
            question: "`@PostConstruct` と `@PreDestroy` の呼ばれるタイミングとして正しいものはどれか？",
            choices: [
                choice("a", "`@PostConstruct`＝DI完了後・`@PreDestroy`＝ApplicationContext停止時（シングルトンのみ）",
                       correct: true,
                       explanation: "`@PostConstruct` はコンストラクタ実行・DI完了後に呼ばれ初期化処理に使います。`@PreDestroy` はアプリ終了時のリソース解放に使います。プロトタイプBeanには`@PreDestroy`は呼ばれません。"),
                choice("b", "`@PostConstruct`＝リクエストのたびに・`@PreDestroy`＝リクエスト完了後に",
                       misconception: "リクエストスコープのライフサイクルと混同",
                       explanation: "シングルトンBeanの@PostConstructは起動時の1回のみです。"),
                choice("c", "どちらもプロトタイプBeanにのみ有効",
                       misconception: "シングルトンには効かないと誤解",
                       explanation: "シングルトンでも有効です。ただし@PreDestroyはプロトタイプには呼ばれません。"),
                choice("d", "`@PostConstruct` はコンストラクタより前に呼ばれる",
                       misconception: "@PostConstructの呼び出し順を誤解",
                       explanation: "コンストラクタ → DI → @PostConstruct の順です。")
            ],
            explanationRef: "explain-boot3-di-scan-004",
            designIntent: "@PostConstruct/@PreDestroyのBeanライフサイクルでの位置を理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 9: 循環依存 (4問)
    // ─────────────────────────────────────────
    private static let diCircular: [Quiz] = [
        quiz(
            id: "boot3-di-circular-001",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["循環依存", "BeanCurrentlyInCreationException", "起動エラー"],
            code: """
@Service
class A {
    private final B b;
    A(B b) { this.b = b; }
}

@Service
class B {
    private final A a;
    B(A a) { this.a = a; }
}
""",
            question: "このコードを起動した場合に発生するエラーはどれか？",
            choices: [
                choice("a", "`BeanCurrentlyInCreationException` — コンストラクタ循環依存は起動時に検出されエラーになる",
                       correct: true,
                       explanation: "コンストラクタインジェクションで循環依存があると、AはBが必要・BはAが必要という状況でどちらも生成できず起動失敗します。Spring Boot 2.6以降はデフォルトで循環依存を禁止しこのエラーを出します。"),
                choice("b", "スタックオーバーフローが無限ループで発生する",
                       misconception: "実行時の無限再帰エラーと混同",
                       explanation: "コンストラクタ循環依存は起動時（Bean生成時）に検出されます。実行時の無限ループとは異なります。"),
                choice("c", "片方のBeanだけ生成されもう一方はスキップされる",
                       misconception: "Springが循環を解消するために片方を省略すると誤解",
                       explanation: "Springは依存グラフを解析し循環を検出するとエラーにします。"),
                choice("d", "エラーなく起動し実行時に問題が起きる",
                       misconception: "コンストラクタ循環依存が起動時に検出されないと誤解",
                       explanation: "コンストラクタ循環依存はSpring Boot 2.6以降起動時エラーです（2.5以前も同様）。")
            ],
            explanationRef: "explain-boot3-di-circular-001",
            designIntent: "コンストラクタ循環依存がBeanCurrentlyInCreationExceptionになることを理解する。"
        ),
        quiz(
            id: "boot3-di-circular-002",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["循環依存", "設計", "回避"],
            code: """
// 問題: AとBが互いに依存している
@Service class A { A(B b){} }
@Service class B { B(A a){} }

// 解決案: 共通ロジックをCに抽出
@Service class A { A(C c){} }
@Service class B { B(C c){} }
@Service class C { /* 共通処理 */ }
""",
            question: "循環依存の最も設計的に正しい解決策はどれか？",
            choices: [
                choice("a", "AとBが共通して必要とするロジックを新クラスCに抽出し、AとBともCに依存させる",
                       correct: true,
                       explanation: "循環依存は通常、クラスの責務分割が不十分なサインです。共通処理を別クラスに切り出すと循環が解消されます。これが最も根本的な解決策です。"),
                choice("b", "`spring.main.allow-circular-references=true` で許可する",
                       misconception: "設定で許可すれば解決と考える",
                       explanation: "許可することは応急措置であり、設計の問題は残ります。Spring Boot 2.6以降はデフォルト禁止にしており非推奨です。"),
                choice("c", "どちらかのBeanを `@Lazy` にして遅延初期化で回避する",
                       misconception: "@Lazyが正式な解決策と考える",
                       explanation: "`@Lazy` は応急措置です。設計上の循環は残ります。"),
                choice("d", "フィールドインジェクションに変更して起動エラーを回避する",
                       misconception: "インジェクション方式を変えれば循環が解消すると考える",
                       explanation: "フィールドインジェクションなら起動は通りますが設計問題は残ります（Spring Boot 2.6以降は設定変更が必要です）。")
            ],
            explanationRef: "explain-boot3-di-circular-002",
            designIntent: "循環依存の根本的解決（クラス抽出）を理解する。"
        ),
        quiz(
            id: "boot3-di-circular-003",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["@Lazy", "循環依存", "遅延初期化"],
            code: """
@Service
class A {
    private final B b;
    A(@Lazy B b) { this.b = b; }
}
@Service
class B {
    private final A a;
    B(A a) { this.a = a; }
}
""",
            question: "`@Lazy` を使って循環依存を解消したときの動作として正しいものはどれか？",
            choices: [
                choice("a", "起動時にBのプロキシがAに注入され、Bが最初に使われるとき実際のBが生成される",
                       correct: true,
                       explanation: "`@Lazy` は遅延プロキシを先に注入します。Aの生成時にBの生成を遅らせることで循環を回避します。ただし応急措置であり設計の見直しが推奨されます。"),
                choice("b", "`@Lazy` を付けるとBは永遠に生成されない",
                       misconception: "@Lazyがオプション的でBeanが作られないと誤解",
                       explanation: "@Lazyは遅延で、不生成ではありません。最初のアクセス時に生成されます。"),
                choice("c", "Aの生成後にBが生成され、その後AのbフィールドにBが代入される",
                       misconception: "セッタインジェクションの仕組みと混同",
                       explanation: "@Lazyはプロキシを使います。代入のタイミングとは異なります。"),
                choice("d", "`@Lazy` を付けるとコンストラクタインジェクションがフィールドインジェクションに変換される",
                       misconception: "@LazyがDI方式を変えると誤解",
                       explanation: "@LazyはDI方式を変えません。プロキシで遅延させるだけです。")
            ],
            explanationRef: "explain-boot3-di-circular-003",
            designIntent: "@Lazyによる循環依存回避のプロキシ遅延の仕組みを理解する。"
        ),
        quiz(
            id: "boot3-di-circular-004",
            level: .foundation,
            objective: "boot3-foundation-di",
            category: .dependencyInjection,
            tags: ["循環依存", "Spring Boot 2.6", "設定"],
            code: """
# application.yml
spring:
  main:
    allow-circular-references: true
""",
            question: "Spring Boot 2.6以降でこの設定を `true` にしたときの意味と注意点はどれか？",
            choices: [
                choice("a", "デフォルトで禁止された循環依存を許可する。ただし設計問題は残るため根本解決を推奨",
                       correct: true,
                       explanation: "Spring Boot 2.6以降で循環依存はデフォルト禁止です。`allow-circular-references: true` で以前の動作に戻せますが、循環依存が残ることで保守性が下がります。移行期の応急措置として使います。"),
                choice("b", "すべてのBeanをプロトタイプにする",
                       misconception: "circular-referencesがスコープに影響すると誤解",
                       explanation: "Beanスコープには影響しません。"),
                choice("c", "アプリのパフォーマンスが向上する",
                       misconception: "循環依存許可がパフォーマンス改善と誤解",
                       explanation: "パフォーマンスとは無関係です。"),
                choice("d", "フィールドインジェクションが自動でコンストラクタインジェクションに変換される",
                       misconception: "インジェクション方式が変換されると誤解",
                       explanation: "インジェクション方式は変換されません。")
            ],
            explanationRef: "explain-boot3-di-circular-004",
            designIntent: "Spring Boot 2.6以降の循環依存禁止と許可設定の意味を理解する。"
        ),
    ]
}
