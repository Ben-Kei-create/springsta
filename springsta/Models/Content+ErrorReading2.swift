import Foundation

extension Quiz {
    static let errorReading2Quizzes: [Quiz] = (
        err2Security + err2JPA + err2Config + err2Architecture
    ).map { $0.contextualizedForPresentation() }

    // MARK: - Security エラー
    private static let err2Security: [Quiz] = [
        quiz(
            id: "boot3-error-403-csrf-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .errorReading,
            tags: ["403", "CSRF", "POST"],
            code: """
{
  "status": 403,
  "error": "Forbidden",
  "path": "/api/orders"
}

// Eclipseコンソール:
o.s.security.web.csrf.CsrfFilter:
  Invalid CSRF token found for http://localhost:8080/api/orders
""",
            question: "REST APIのPostmanテストで403が返り、コンソールにCSRFエラーが出た場合の原因と対処はどれか？",
            choices: [
                choice("a", "Spring SecurityのCSRF保護が有効でPOSTにトークンを要求している。REST APIならCSRFを無効化するか、X-CSRF-TOKENヘッダを付ける", correct: true,
                       explanation: "CSRFはブラウザセッション向けの保護です。JWTやStatelessなREST APIでは `csrf().disable()` が一般的です。"),
                choice("b", "Postmanには必ずBasic認証ヘッダが必要", misconception: "認証と認可の混同",
                       explanation: "このエラーはCSRFトークンの検証失敗で、認証の問題ではありません。"),
                choice("c", "403はリソースが存在しないことを意味する", misconception: "403と404のステータスコードを混同",
                       explanation: "403 Forbiddenは認可失敗、404 Not Foundはリソース未存在です。"),
                choice("d", "CORS設定でOriginを許可すれば自動でCSRFが通過する", misconception: "CORSとCSRFを混同",
                       explanation: "CORSとCSRFは別の概念です。CORSを許可してもCSRFトークン検証は別途行われます。")
            ],
            explanationRef: "explain-boot3-error-403-csrf-001",
            designIntent: "REST APIテストでのCSRF 403エラーを読んで原因と対処を導ける。"
        ),
        quiz(
            id: "boot3-error-401-bearer-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .errorReading,
            tags: ["401", "Bearer token", "JWT", "Authorization"],
            code: """
{
  "status": 401,
  "error": "Unauthorized",
  "message": "Full authentication is required to access this resource",
  "path": "/api/users/me"
}
""",
            question: "このエラーの直接原因と修正方法として正しいものはどれか？",
            choices: [
                choice("a", "リクエストに `Authorization: Bearer <token>` ヘッダが含まれていないか無効なトークン。正しいJWTを付与する", correct: true,
                       explanation: "`Full authentication is required` はSpring Securityが認証情報を検出できなかったことを意味します。JWTを正しく付けるか、エンドポイントの認可設定を見直します。"),
                choice("b", "ユーザーのパスワードが間違っている", misconception: "セッション認証とトークン認証を混同",
                       explanation: "このエラーはパスワード不一致ではなく、トークン（認証情報）の不在または無効が原因です。"),
                choice("c", "403 Forbiddenと同じ意味で権限が足りない", misconception: "401と403を混同",
                       explanation: "401はAuthenticationの問題（誰？）、403はAuthorization（権限あり？）の問題です。"),
                choice("d", "`/api/users/me` をSecurityFilterChainで `.permitAll()` にすれば問題が解決する", misconception: "認証なしでアクセスするアンチパターン",
                       explanation: "個人情報エンドポイントを認証不要にすべきではありません。正しいトークン付与が解決策です。")
            ],
            explanationRef: "explain-boot3-error-401-bearer-001",
            designIntent: "JWT認証における401エラーを読んでトークン付与の問題を特定できる。"
        ),
        quiz(
            id: "boot3-error-403-role-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .errorReading,
            tags: ["403", "@PreAuthorize", "ROLE_ADMIN", "hasRole"],
            code: """
{
  "status": 403,
  "error": "Forbidden",
  "path": "/api/admin/users"
}

// Eclipseコンソール:
o.s.s.access.AccessDeniedException:
  Access is denied

  at ...AdminController.listUsers(AdminController.java:23)
""",
            question: "認証済みユーザーが `/api/admin/users` で403になる理由として最も可能性が高いものはどれか？",
            choices: [
                choice("a", "ユーザーに `ROLE_ADMIN` 権限がなく、`@PreAuthorize(\"hasRole('ADMIN')\")` 等のチェックで拒否された", correct: true,
                       explanation: "認証は成功しているが認可で失敗しています。`AccessDeniedException` は権限不足を意味します。ユーザーのロール設定を確認します。"),
                choice("b", "CSRFトークンが付いていない", misconception: "CSRFエラーと権限エラーを混同",
                       explanation: "CSRFのエラーは `CsrfFilter` のログで出ます。このエラーは `AccessDeniedException` です。"),
                choice("c", "JWTの有効期限が切れている", misconception: "401のケースを403と混同",
                       explanation: "トークン無効は401 Unauthorizedで出ることが多いです。403は認証後の権限問題です。"),
                choice("d", "`/api/admin/users` というパスがControllerに存在しない", misconception: "404と403を混同",
                       explanation: "パスが存在しない場合は404 Not Foundです。403は到達後の認可失敗です。")
            ],
            explanationRef: "explain-boot3-error-403-role-001",
            designIntent: "認証済みユーザーの403エラーから権限（ロール）不足を特定できる。"
        ),
    ]

    // MARK: - JPA / DB エラー
    private static let err2JPA: [Quiz] = [
        quiz(
            id: "boot3-error-optimistic-lock-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["OptimisticLockingFailureException", "@Version", "楽観ロック"],
            code: """
org.springframework.orm.ObjectOptimisticLockingFailureException:
  Row was updated or deleted by another transaction
  (or unsaved-value mapping was incorrect):
  [com.example.demo.Product#42]

  at ...ProductService.update(ProductService.java:35)
""",
            question: "このエラーが発生する状況と対処として正しいものはどれか？",
            choices: [
                choice("a", "同一レコードへの並行更新が競合した。`@Version` フィールドのバージョン番号が変わっていたためロール失敗。リトライまたはユーザーへの再編集案内が適切", correct: true,
                       explanation: "`@Version` カラムを使った楽観的ロックが更新競合を検出しました。悲観ロック(`PESSIMISTIC_WRITE`)への切り替えか、`@Retryable` でのリトライが選択肢です。"),
                choice("b", "DBのロック待ちタイムアウトが発生した", misconception: "LockTimeoutExceptionと混同",
                       explanation: "ロック待ちタイムアウトは `LockTimeoutException` です。このエラーは楽観ロックの競合検出です。"),
                choice("c", "`@Entity` クラスにIDが設定されていない", misconception: "エンティティ定義エラーと混同",
                       explanation: "ID未設定なら起動時かクエリ時にエラーが出ます。このエラーは更新競合です。"),
                choice("d", "トランザクションの外で更新操作を実行した", misconception: "TransactionRequiredExceptionと混同",
                       explanation: "トランザクション外の更新は `TransactionRequiredException` です。")
            ],
            explanationRef: "explain-boot3-error-optimistic-lock-001",
            designIntent: "楽観ロック競合エラーを読んで@Versionと並行更新の問題を特定できる。"
        ),
        quiz(
            id: "boot3-error-no-session-proxy-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["could not initialize proxy", "Hibernate", "遅延ロード", "Eager"],
            code: """
org.hibernate.LazyInitializationException:
  could not initialize proxy [com.example.demo.User#15]
  - no Session

  at com.example.demo.OrderService.process(OrderService.java:48)
""",
            question: "「could not initialize proxy - no Session」が示す問題と修正として正しいものはどれか？",
            choices: [
                choice("a", "@ManyToOneなどのLAZY関連がHibernateセッションなしに初期化された。メソッドを`@Transactional`スコープ内に収めるか、Fetch Joinで取得する", correct: true,
                       explanation: "プロキシオブジェクトは Hibernate セッションが有効な間のみ初期化できます。セッション外での参照がこのエラーを引き起こします。"),
                choice("b", "Userクラスに`@Entity`がない", misconception: "エンティティ未定義エラーと混同",
                       explanation: "`@Entity`がなければ起動時かHQL実行時に異なるエラーが出ます。"),
                choice("c", "プロキシを解決するにはUserのすべての関連をEAGERにする", misconception: "EAGER fetchによる解決策を誤解",
                       explanation: "全関連をEAGERにするとN+1よりひどいパフォーマンス問題が起きます。`@Transactional`での管理かFetch Joinが正解です。"),
                choice("d", "`hibernate.enable_lazy_load_no_trans=true`で解決するのがベストプラクティス", misconception: "危険な回避策を推奨",
                       explanation: "このプロパティはセッションを乱用するアンチパターンです。根本解決は`@Transactional`でセッションを管理することです。")
            ],
            explanationRef: "explain-boot3-error-no-session-proxy-001",
            designIntent: "LAZYプロキシのセッション外初期化エラーを読んで@Transactionalとの関係を理解する。"
        ),
        quiz(
            id: "boot3-error-detached-entity-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["detached entity", "persist", "JPA", "@Transactional"],
            code: """
jakarta.persistence.PersistenceException:
  org.hibernate.PersistentObjectException:
    detached entity passed to persist:
    com.example.demo.Category

  at ...ProductService.create(ProductService.java:31)
""",
            question: "このエラーの原因として正しいものはどれか？",
            choices: [
                choice("a", "既存のIDを持つエンティティ（detached）を新規保存（persist）しようとした。`save()`（merge相当）を使うか、IDをnullにする", correct: true,
                       explanation: "`persist` は新規エンティティ向けです。IDを持つdetachedエンティティには `merge`（Spring Dataなら`save()`）を使います。"),
                choice("b", "Categoryクラスに`@Entity`アノテーションが付いていない", misconception: "エンティティ未定義エラーと混同",
                       explanation: "エンティティ未定義なら別のエラーが出ます。このエラーはentityの状態（detached vs new）の問題です。"),
                choice("c", "`@Transactional`の伝播属性がNEVERに設定されている", misconception: "トランザクション伝播と状態エラーを混同",
                       explanation: "伝播設定の問題ではなく、エンティティのライフサイクル状態の誤用です。"),
                choice("d", "Categoryとのリレーションシップが`CascadeType.PERSIST`に設定されていない", misconception: "Cascadeがあれば解決すると誤解",
                       explanation: "Cascadeは関連エンティティへの伝播設定です。根本的にはdetachedエンティティにpersistを呼んでいることが問題です。")
            ],
            explanationRef: "explain-boot3-error-detached-entity-001",
            designIntent: "detachedエンティティへのpersist操作エラーを読んでsave()との使い分けを理解する。"
        ),
        quiz(
            id: "boot3-error-schema-validation-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["SchemaManagementException", "validate", "Flyway", "DDL"],
            code: """
org.hibernate.tool.schema.spi.SchemaManagementException:
  Schema-validation: missing column [phone_number] in table [users]

  at ...AbstractSchemaValidator.validateTable(...)
""",
            question: "この `schema-validation` エラーの原因と対処として正しいものはどれか？",
            choices: [
                choice("a", "Entityに定義した`phone_number`カラムがDBテーブルに存在しない。FlywayマイグレーションかDDLでカラムを追加する", correct: true,
                       explanation: "`ddl-auto: validate`はEntityとDBスキーマの整合を検証します。Entityにフィールドを追加した後にマイグレーションを実行していないと発生します。"),
                choice("b", "`@Column(name=\"phone_number\")`の指定を削除する", misconception: "Entityを修正することで問題を隠蔽",
                       explanation: "カラムを必要としているのであればDBにカラムを追加するのが正解です。"),
                choice("c", "`ddl-auto: create-drop`に変更してアプリを再起動する", misconception: "本番環境でcreate-dropを使用するアンチパターン",
                       explanation: "本番でcreate-dropは全データが消えます。Flywayによるマイグレーションが正しいアプローチです。"),
                choice("d", "このエラーはデータ型の不一致を示している", misconception: "missing columnとtype mismatchを混同",
                       explanation: "「missing column」はカラムが存在しないことを示しています。型の不一致は別のメッセージで出ます。")
            ],
            explanationRef: "explain-boot3-error-schema-validation-001",
            designIntent: "スキーマ検証エラーからFlywayマイグレーションの必要性を読み取れる。"
        ),
        quiz(
            id: "boot3-error-connection-refused-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["Connection refused", "DataSource", "DB接続失敗"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Description:
Failed to configure a DataSource: 'url' attribute is not specified
and no embedded datasource could be configured.

Reason: Failed to determine a suitable driver class
""",
            question: "このエラーの原因として正しいものはどれか？",
            choices: [
                choice("a", "spring-boot-starter-data-jpaが依存にあるが`application.yml`にデータソースURLが設定されていない", correct: true,
                       explanation: "Spring BootはJPA依存があるときに自動でデータソースを設定しようとします。URLが未設定だとこのエラーが出ます。`spring.datasource.url`を設定するかH2などの組み込みDBを追加します。"),
                choice("b", "DBサーバーがダウンしている", misconception: "接続拒否エラーと設定エラーを混同",
                       explanation: "DBサーバーダウンの場合は`Connection refused`や`Unable to acquire JDBC Connection`が出ます。このエラーはURL未設定です。"),
                choice("c", "パスワードが間違っている", misconception: "認証エラーと設定エラーを混同",
                       explanation: "パスワード不一致の場合は`Access denied`等のエラーになります。"),
                choice("d", "`@SpringBootApplication`が複数ある", misconception: "起動クラスの重複と設定エラーを混同",
                       explanation: "複数の`@SpringBootApplication`は別の問題です。このエラーはデータソース設定の欠落です。")
            ],
            explanationRef: "explain-boot3-error-connection-refused-001",
            designIntent: "DataSource設定エラーを読んでapplication.ymlのDB設定漏れを特定できる。"
        ),
    ]

    // MARK: - 設定 / 起動 エラー
    private static let err2Config: [Quiz] = [
        quiz(
            id: "boot3-error-circular-dependency-001",
            level: .practice,
            objective: "boot3-foundation-di",
            category: .errorReading,
            tags: ["循環依存", "BeanCurrentlyInCreationException", "DI"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Description:
The dependencies of some of the beans in the application context
form a cycle:

orderService -> paymentService -> orderService
""",
            question: "循環依存エラーの解消方法として最も適切なものはどれか？",
            choices: [
                choice("a", "設計を見直してどちらかのクラスに第三のサービスを切り出し、循環を断つ", correct: true,
                       explanation: "循環依存はしばしば責務の混同を示します。共通処理を分離するか、イベント発行（ApplicationEventPublisher）で疎結合にする方法もあります。"),
                choice("b", "`@Lazy` を付けて遅延初期化すれば循環が解消される", misconception: "Lazyが根本解決と誤解",
                       explanation: "`@Lazy` は循環を一時的に回避できますが、設計の問題は残ります。Spring Boot 2.6以降はコンストラクタ注入の循環は起動時に検出されます。"),
                choice("c", "`spring.main.allow-circular-references=true`で許可すれば問題ない", misconception: "循環を許可することで解決するアンチパターン",
                       explanation: "この設定は一時的な回避策です。根本的な設計改善が必要です。"),
                choice("d", "`@Primary` を付けることで循環が解消される", misconception: "Bean優先度と循環依存を混同",
                       explanation: "`@Primary` は複数候補解決のためのアノテーションで、循環依存とは無関係です。")
            ],
            explanationRef: "explain-boot3-error-circular-dependency-001",
            designIntent: "循環依存エラーを読んで設計の問題を特定し解消できる。"
        ),
        quiz(
            id: "boot3-error-yaml-parse-001",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .errorReading,
            tags: ["YAML", "ParseException", "インデント", "application.yml"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Caused by: org.yaml.snakeyaml.scanner.ScannerException:
  mapping values are not allowed here
  in 'reader', line 5, column 15:
    server.port: 8080
                ^
""",
            question: "このYAML解析エラーの原因として最も可能性が高いものはどれか？",
            choices: [
                choice("a", "YAMLのインデントが間違っているかドット区切りキーをネスト構造と混在させた", correct: true,
                       explanation: "YAMLは`server.port: 8080`という書き方は有効ですが、インデント不整合や同じキーのネスト表記との混在が解析エラーを引き起こします。"),
                choice("b", "ポート番号8080が予約されているため使用禁止", misconception: "ポート番号の制限を誤解",
                       explanation: "8080は一般的な開発用ポートで使用制限はありません。エラーはYAML構文の問題です。"),
                choice("c", "`application.yml`はSpring Boot 3.xで廃止された", misconception: "設定ファイルフォーマットの廃止を誤解",
                       explanation: "`application.yml`はSpring Boot 3.xでも有効です。"),
                choice("d", "`server:`というキーはSpring Bootでは認識されない", misconception: "Spring Bootの設定キー名前空間を誤解",
                       explanation: "`server.port`はSpring Bootの標準設定キーです。")
            ],
            explanationRef: "explain-boot3-error-yaml-parse-001",
            designIntent: "YAML解析エラーからインデントと構文の問題を特定できる。"
        ),
        quiz(
            id: "boot3-error-missing-config-props-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["@ConfigurationProperties", "Binding", "BindException"],
            code: """
Caused by: org.springframework.boot.context.properties
  .bind.BindException:
  Failed to bind properties under 'app.mail'
  to com.example.MailProperties:

  Property: app.mail.max-retries
  Value: "five"
  Reason: failed to convert java.lang.String to java.lang.Integer
""",
            question: "このバインドエラーの原因と修正方法として正しいものはどれか？",
            choices: [
                choice("a", "`app.mail.max-retries`の値が文字列`\"five\"`で、`int`型フィールドに変換できない。設定値を数値の`5`に修正する", correct: true,
                       explanation: "`@ConfigurationProperties`は型変換を自動で行いますが、数値型への変換が不可能な文字列の場合`BindException`が発生します。"),
                choice("b", "`@ConfigurationProperties`クラスに`@Component`が必要", misconception: "Beanとバインドエラーを混同",
                       explanation: "バインド失敗はBean登録の問題ではなく値の型変換の問題です。"),
                choice("c", "`max-retries`はkebab-caseなので`maxRetries`に直す必要がある", misconception: "Relaxed Bindingを知らない",
                       explanation: "kebab-caseとcamelCaseはRelaxed Bindingで相互変換されます。値の型が問題です。"),
                choice("d", "`int`型は`@ConfigurationProperties`ではサポートされない", misconception: "型サポートを誤解",
                       explanation: "`int`、`long`、`boolean`などプリミティブ型も`@ConfigurationProperties`でサポートされます。")
            ],
            explanationRef: "explain-boot3-error-missing-config-props-001",
            designIntent: "ConfigurationPropertiesバインドエラーから型変換失敗を特定できる。"
        ),
        quiz(
            id: "boot3-error-async-uncaught-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .errorReading,
            tags: ["@Async", "例外処理", "AsyncUncaughtExceptionHandler"],
            code: """
// @Asyncメソッドで例外が発生したが呼び出し元には伝わらない
@Async
public void sendNotification(Long userId) {
    throw new RuntimeException("通知サービス接続失敗");
}

// 呼び出し元のログには何も出ない
""",
            question: "`@Async`メソッドの例外が呼び出し元に伝わらない理由として正しいものはどれか？",
            choices: [
                choice("a", "`@Async`は別スレッドで実行されるため、呼び出し元のスレッドに例外が伝播しない。`AsyncUncaughtExceptionHandler`を実装して例外を補足する", correct: true,
                       explanation: "void戻り値の`@Async`メソッドの例外はデフォルトで無視されます。`AsyncUncaughtExceptionHandler`かCompletableFutureを使って例外を処理します。"),
                choice("b", "RuntimeExceptionは`@Async`メソッドでは投げられない", misconception: "@Asyncと例外型の関係を誤解",
                       explanation: "RuntimeExceptionは投げられますが、呼び出し元スレッドに伝播しないだけです。"),
                choice("c", "`@Async`メソッドは例外を自動でログ出力してリトライする", misconception: "@Asyncが自動リトライすると誤解",
                       explanation: "`@Async`自体にはリトライ機能はありません。`@Retryable`との組み合わせが必要です。"),
                choice("d", "`@EnableAsync`を付けると全例外がコンソールに出力される", misconception: "@EnableAsyncの機能を誤解",
                       explanation: "`@EnableAsync`は非同期処理を有効化するだけです。例外ハンドリングは別途設定します。")
            ],
            explanationRef: "explain-boot3-error-async-uncaught-001",
            designIntent: "@Async例外の無音処理問題を理解しAsyncUncaughtExceptionHandlerの必要性を導ける。"
        ),
    ]

    // MARK: - アーキテクチャ / 設計 エラー
    private static let err2Architecture: [Quiz] = [
        quiz(
            id: "boot3-error-serialization-cycle-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .errorReading,
            tags: ["循環参照", "JSON", "Jackson", "StackOverflowError"],
            code: """
com.fasterxml.jackson.databind.JsonMappingException:
  Infinite recursion (StackOverflowError)
  (through reference chain:
    com.example.Order["customer"]->
    com.example.Customer["orders"]->
    com.example.Order["customer"]->...)
""",
            question: "JacksonのInfinite recursionエラーの原因と対処として正しいものはどれか？",
            choices: [
                choice("a", "OrderとCustomerが双方向関連でJSONシリアライズ時に無限ループ。`@JsonIgnore`、`@JsonManagedReference/@JsonBackReference`、またはDTOへの変換で解決する", correct: true,
                       explanation: "双方向の`@OneToMany`/`@ManyToOne`をEntityのままJSONシリアライズすると循環参照が起きます。DTOパターンが根本解決です。"),
                choice("b", "エンティティに`@Entity`アノテーションがない", misconception: "シリアライズエラーとエンティティ定義を混同",
                       explanation: "シリアライズはJacksonが担当しJPAとは独立しています。"),
                choice("c", "`@ManyToOne`はSpring Boot 3.xで廃止された", misconception: "リレーションシップアノテーションの廃止を誤解",
                       explanation: "`@ManyToOne`はSpring Boot 3.xでも有効です（jakartaパッケージ）。"),
                choice("d", "Jacksonのバージョンを上げれば自動で検出してループを止める", misconception: "バージョンアップが解決策と誤解",
                       explanation: "JacksonはデフォルトでInfinite recursionを検出して例外を出します。バージョン依存の問題ではありません。")
            ],
            explanationRef: "explain-boot3-error-serialization-cycle-001",
            designIntent: "双方向関連エンティティのJSONシリアライズ循環参照エラーを解決できる。"
        ),
        quiz(
            id: "boot3-error-no-handler-mapping-001",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .errorReading,
            tags: ["404", "NoHandlerFoundException", "パスマッピング"],
            code: """
{
  "status": 404,
  "error": "Not Found",
  "path": "/api/user/me"
}

// Controller定義:
@GetMapping("/users/me")
UserResponse getCurrentUser() { ... }
""",
            question: "404エラーが発生している原因として最も可能性が高いものはどれか？",
            choices: [
                choice("a", "エンドポイントは`/users/me`（複数形）だがリクエストは`/user/me`（単数形）にアクセスしている", correct: true,
                       explanation: "パスの`/user`と`/users`は別のエンドポイントです。スペルミスやパスの不一致が404の典型的な原因です。"),
                choice("b", "Spring BootではGETメソッドはデフォルトで無効", misconception: "GETメソッドのデフォルト設定を誤解",
                       explanation: "GETメソッドはSpring MVCで問題なく使えます。"),
                choice("c", "`UserResponse`型がJSONに変換できないため404が返る", misconception: "シリアライズエラーとパスミスマッチを混同",
                       explanation: "シリアライズエラーは500 Internal Server Errorで出ます。"),
                choice("d", "`@RequestMapping`クラスレベルがないと`@GetMapping`が動かない", misconception: "クラスレベルのマッピング必須と誤解",
                       explanation: "クラスレベルの`@RequestMapping`は省略可能です。メソッドの`@GetMapping`だけでも機能します。")
            ],
            explanationRef: "explain-boot3-error-no-handler-mapping-001",
            designIntent: "404エラーからパスの不一致（スペルミス・単複数）を特定できる。"
        ),
        quiz(
            id: "boot3-error-content-type-001",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["415", "Unsupported Media Type", "Content-Type", "application/json"],
            code: """
{
  "status": 415,
  "error": "Unsupported Media Type",
  "path": "/api/users"
}

// Eclipseコンソール:
o.s.web.servlet.DispatcherServlet:
  Resolved [HttpMediaTypeNotSupportedException:
  Content type 'text/plain;charset=UTF-8' not supported]
""",
            question: "415 Unsupported Media Typeエラーの原因と修正として正しいものはどれか？",
            choices: [
                choice("a", "リクエストのContent-TypeヘッダがControllerの期待する`application/json`と異なる。クライアントに`Content-Type: application/json`を設定させる", correct: true,
                       explanation: "`@RequestBody`を使うControllerはデフォルトでJSONを期待します。`text/plain`など異なるContent-Typeは415エラーになります。"),
                choice("b", "`@RequestBody`を`@RequestParam`に変更する必要がある", misconception: "アノテーション変更で対処するアンチパターン",
                       explanation: "JSONボディはDTOで受けるのが適切です。Content-TypeをJSONに設定するのが正しい修正です。"),
                choice("c", "ControllerにJacksonのimportが足りない", misconception: "importとシリアライズ設定を混同",
                       explanation: "JacksonはSpringが自動で使用します。import文は関係ありません。"),
                choice("d", "HTTPS環境でしかJSONは受け付けない", misconception: "プロトコルとContent-Typeを混同",
                       explanation: "JSONの受け付けはHTTP/HTTPSに関係なくContent-Typeで決まります。")
            ],
            explanationRef: "explain-boot3-error-content-type-001",
            designIntent: "415エラーからContent-Typeヘッダの不一致を特定し修正できる。"
        ),
        quiz(
            id: "boot3-error-method-security-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .errorReading,
            tags: ["@EnableMethodSecurity", "@PreAuthorize", "メソッドセキュリティ"],
            code: """
@Service
class UserService {
    @PreAuthorize("hasRole('ADMIN')")
    public List<User> findAll() { ... }
}

// テスト実行時のエラー:
java.lang.annotation.AnnotationFormatError:
  @PreAuthorize has no effect - did you forget
  @EnableMethodSecurity on @Configuration class?
""",
            question: "`@PreAuthorize`が機能しない理由として正しいものはどれか？",
            choices: [
                choice("a", "設定クラスに`@EnableMethodSecurity`が付いていないためメソッドレベルセキュリティが無効", correct: true,
                       explanation: "Spring Boot 3.xでは`@EnableMethodSecurity`で明示的に有効化します（旧：`@EnableGlobalMethodSecurity`）。有効化しなければ`@PreAuthorize`は無視されます。"),
                choice("b", "`@PreAuthorize`はControllerクラスにしか付けられない", misconception: "@PreAuthorizeの使用場所を誤解",
                       explanation: "`@PreAuthorize`はService層など任意のBeanメソッドに付けられます。"),
                choice("c", "`hasRole`の代わりに`hasAuthority`を使えば機能する", misconception: "役割vs権限の違いで動作が変わると誤解",
                       explanation: "`hasRole`vs`hasAuthority`の違いはプレフィックスの有無ですが、`@EnableMethodSecurity`なしでは両方機能しません。"),
                choice("d", "`@PreAuthorize`はSpring Boot 3.xで廃止された", misconception: "Spring Boot 3.xでの変更を誤解",
                       explanation: "`@PreAuthorize`は有効です。ただし有効化アノテーション名が`@EnableGlobalMethodSecurity`から`@EnableMethodSecurity`に変わりました。")
            ],
            explanationRef: "explain-boot3-error-method-security-001",
            designIntent: "@PreAuthorizeが無効な場合に@EnableMethodSecurityの欠落を特定できる。"
        ),
        quiz(
            id: "boot3-error-hikari-pool-exhaustion-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["HikariCP", "コネクション枯渇", "タイムアウト", "接続プール"],
            code: """
java.sql.SQLTransientConnectionException:
  HikariPool-1 - Connection is not available,
  request timed out after 30000ms.

  at com.zaxxer.hikari.pool.HikariPool.getConnection(HikariPool.java:...)
  at ...OrderRepository.findById(OrderRepository.java:...)
""",
            question: "HikariCPのコネクションプールが枯渇する主な原因として正しいものはどれか？",
            choices: [
                choice("a", "長時間実行のトランザクションやコネクションリークにより、プール内全コネクションが使用中になった", correct: true,
                       explanation: "トランザクションが長すぎる、クローズされないコネクション、または`maximum-pool-size`が小さすぎる場合に起きます。スレッドダンプでどのスレッドがコネクションを保持しているか確認します。"),
                choice("b", "`application.yml`にDBのURLが設定されていない", misconception: "URL未設定エラーとプール枯渇を混同",
                       explanation: "URL未設定なら起動時に別のエラーが出ます。このエラーはプール内コネクションが全て使用中です。"),
                choice("c", "DBサーバーがダウンしている", misconception: "DB接続拒否とプール枯渇を混同",
                       explanation: "DBダウンなら`Connection refused`が出ます。このエラーはプール内コネクションの枯渇です。"),
                choice("d", "`maximum-pool-size`をデフォルトの10から1に減らすと解決する", misconception: "コネクション数を減らして解決するアンチパターン",
                       explanation: "コネクション数を減らすと更に枯渇しやすくなります。根本原因（長トランザクション/リーク）の解消が必要です。")
            ],
            explanationRef: "explain-boot3-error-hikari-pool-exhaustion-001",
            designIntent: "HikariCPコネクション枯渇エラーを読んで長トランザクション/リークの問題を特定できる。"
        ),
    ]
}
