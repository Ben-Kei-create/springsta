import Foundation

extension Quiz {
    static let configurationQuizzes: [Quiz] = (cfgProperties + cfgProfiles + cfgConfigProps
        + cfgExternalize + cfgConditional + cfgActuator)
        .map { $0.contextualizedForPresentation() }

    // MARK: - Group 1: application.yml / application.properties (6問)
    private static let cfgProperties: [Quiz] = [
        quiz(
            id: "boot3-cfg-props-001",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["application.yml", "application.properties", "設定ファイル"],
            code: """
# application.yml の例
server:
  port: 9090
  servlet:
    context-path: /api

spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mydb
    username: user
    password: secret
""",
            question: "`application.yml` と `application.properties` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "YAMLは階層構造を視覚的に表現できるが、どちらを使っても同じ設定が可能", correct: true,
                       explanation: "YAMLは`server.port=9090`をインデントで階層表現します。機能的には同等ですが、YAMLは複雑な設定が読みやすい利点があります。"),
                choice("b", "`application.yml` はSpring Boot 3.xで必須になり、propertiesは非推奨", misconception: "YAMLが必須化されたと誤解",
                       explanation: "どちらも引き続きサポートされています。非推奨ではありません。"),
                choice("c", "`application.properties` の方が読み込みが速いため本番では必ずpropertiesを使う", misconception: "パフォーマンス差があると誤解",
                       explanation: "起動時の設定ファイル読み込みはどちらも無視できるほど軽微です。使い分けはチームの好みや可読性による設計判断です。"),
                choice("d", "YAMLはリスト形式の値を設定できないため配列はpropertiesのみ対応", misconception: "YAMLがリストを表現できないと誤解",
                       explanation: "YAMLはリストを `- item` 記法でネイティブに表現できます。propertiesより柔軟なリスト表記が可能です。")
            ],
            explanationRef: "explain-boot3-cfg-props-001",
            designIntent: "設定ファイル形式の選択と等価性を理解する。"
        ),
        quiz(
            id: "boot3-cfg-props-002",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@Value", "プレースホルダー", "デフォルト値"],
            code: """
@Component
public class AppConfig {

    @Value("${app.timeout:30}")
    private int timeout;

    @Value("${app.name}")
    private String appName;
}
""",
            question: "`@Value(\"${app.timeout:30}\")` のコロン以降の意味として正しいのはどれか？",
            choices: [
                choice("a", "`app.timeout` が設定されていない場合のデフォルト値として `30` が使われる", correct: true,
                       explanation: "`${key:default}` はSpELのフォールバック記法です。プロパティが未定義の場合に指定した値を使います。"),
                choice("b", "`app.timeout` の最大値を30に制限する", misconception: "コロン以降がバリデーション条件と誤解",
                       explanation: "@Valueはプレースホルダー解決のみを行います。値の制限には@Validatedと組み合わせた@Maxなどが必要です。"),
                choice("c", "環境変数 `APP_TIMEOUT` が30以上の場合のみ有効になる", misconception: "コロンが条件式と誤解",
                       explanation: "コロンはSpELのデフォルト値構文です。条件式ではありません。"),
                choice("d", "`app.timeout` を `30` ミリ秒に変換するキャスト指定", misconception: "コロンが型変換を行うと誤解",
                       explanation: "型変換はSpringが自動で行います（String → int）。コロン以降はデフォルト値の指定です。")
            ],
            explanationRef: "explain-boot3-cfg-props-002",
            designIntent: "@Valueのデフォルト値記法を理解する。"
        ),
        quiz(
            id: "boot3-cfg-props-003",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@Value", "環境変数", "SpEL"],
            code: """
@Value("${DATABASE_URL:jdbc:h2:mem:testdb}")
private String databaseUrl;

@Value("#{systemProperties['user.home']}")
private String userHome;
""",
            question: "`${}` と `#{}` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "`${}` はプロパティ・環境変数の値を展開し、`#{}` はSpEL（Spring Expression Language）で式を評価する", correct: true,
                       explanation: "`${key}` は設定プロパティの文字列展開です。`#{expr}` はSpELで、systemPropertiesへのアクセスやメソッド呼び出し、計算式が書けます。"),
                choice("b", "`${}` はYAMLのみで動作し、`#{}` はpropertiesのみ有効", misconception: "構文が設定ファイル種別に依存すると誤解",
                       explanation: "どちらの構文も設定ファイル形式に依存しません。@Valueの文字列内で両方使えます。"),
                choice("c", "`#{}` は廃止予定でSpring Boot 3.xでは使用を避けるべき", misconception: "SpELが廃止予定と誤解",
                       explanation: "SpELはSpring Boot 3.xでも現役です。@ConditionalなどでもSpELが使われています。"),
                choice("d", "`${}` を使うと起動時にプロパティが見つからなくても警告なしで空文字になる", misconception: "デフォルト値なし時の挙動を誤解",
                       explanation: "デフォルト値（:value）なしで該当キーが見つからない場合、BeanCreationExceptionが発生します。")
            ],
            explanationRef: "explain-boot3-cfg-props-003",
            designIntent: "プロパティ展開とSpELの区別を理解する。"
        ),
        quiz(
            id: "boot3-cfg-props-004",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["設定の優先順位", "環境変数", "コマンドライン引数"],
            code: """
# application.yml
server:
  port: 8080

# 環境変数
SERVER_PORT=9090

# コマンドライン
java -jar app.jar --server.port=7070
""",
            question: "Spring Bootの設定優先順位として正しいのはどれか？",
            choices: [
                choice("a", "コマンドライン引数 > 環境変数 > application.yml の順に優先される", correct: true,
                       explanation: "外部から注入された値ほど優先されます。コマンドライン引数が最優先で、次に環境変数、その後にYAML/propertiesファイルです。"),
                choice("b", "application.yml が最も優先されコマンドライン引数で上書きされることはない", misconception: "設定ファイルが最優先と誤解",
                       explanation: "設定ファイルは最も低優先です。環境変数・コマンドライン引数で上書きできることがSpring Bootの外部化設定の仕組みです。"),
                choice("c", "環境変数はDocker環境でのみ有効で、ローカル実行では無視される", misconception: "環境変数がDockerのみと誤解",
                       explanation: "環境変数はOS問わず有効です。ローカル実行でも`export SERVER_PORT=9090`などで設定できます。"),
                choice("d", "同じキーを複数箇所に書くとBeanCreationExceptionが発生する", misconception: "設定の重複がエラーになると誤解",
                       explanation: "複数箇所での定義はエラーになりません。優先度の高い方の値が採用されます。")
            ],
            explanationRef: "explain-boot3-cfg-props-004",
            designIntent: "Spring Bootの設定優先順位を理解する。"
        ),
        quiz(
            id: "boot3-cfg-props-005",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["Relaxed Binding", "環境変数", "大文字小文字"],
            code: """
# application.yml
app:
  api-key: my-secret-key

# 環境変数で上書き
APP_API_KEY=prod-key
""",
            question: "Spring BootのRelaxed Bindingについて正しいのはどれか？",
            choices: [
                choice("a", "`app.api-key`、`APP_API_KEY`、`app.apiKey` は同じプロパティとして扱われる", correct: true,
                       explanation: "Spring BootはRelaxed Bindingにより、ケバブケース・スネークケース・キャメルケース・大文字スネークケースを同一キーとして解決します。環境変数との統合を容易にします。"),
                choice("b", "環境変数はキャメルケースのみ受け付けるため `APP_API_KEY` は無効", misconception: "環境変数の命名制限を誤解",
                       explanation: "環境変数はアンダースコア区切りの大文字（APP_API_KEY）がRelaxed Bindingで解決されます。"),
                choice("c", "Relaxed Bindingを使うには`@EnableRelaxedBinding`が必要", misconception: "Relaxed Bindingが手動有効化と誤解",
                       explanation: "Relaxed BindingはSpring Boot標準機能で、設定なしで動作します。"),
                choice("d", "`app.api-key` と `app.apiKey` は別のプロパティとして管理される", misconception: "命名規則の変形が別キーになると誤解",
                       explanation: "Relaxed Bindingにより同一キーとして扱われます。ただし`@ConfigurationProperties`での使用が推奨で、`@Value`では完全一致が推奨されます。")
            ],
            explanationRef: "explain-boot3-cfg-props-005",
            designIntent: "Relaxed Bindingの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-cfg-props-006",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["Secrets管理", "Vault", "環境変数セキュリティ"],
            code: """
# 危険な例
spring:
  datasource:
    password: my-db-password123  # ← ソースコードにシークレット

# 安全な例
spring:
  datasource:
    password: ${DB_PASSWORD}  # ← 環境変数から注入
""",
            question: "本番環境のDB接続パスワードの管理として最も適切なのはどれか？",
            choices: [
                choice("a", "環境変数またはHashiCorp VaultなどのSecrets Managerを使い、ソースコードにパスワードを含めない", correct: true,
                       explanation: "パスワードなどシークレット情報はソースコードに含めず、環境変数・Vault・AWS Secrets Manager等で管理します。Gitに流れても問題ない設定のみをYAMLに書くのが原則です。"),
                choice("b", "`application.yml` をGitの`.gitignore`に追加すれば本番パスワードを書いても安全", misconception: "gitignoreで全ての漏洩リスクがなくなると誤解",
                       explanation: ".gitignoreはGitへのコミットを防ぐだけで、ファイルが共有サーバや他の経路で流出するリスクはあります。"),
                choice("c", "パスワードを`@Value`でフィールドに注入すれば自動的に暗号化される", misconception: "@Valueに暗号化機能があると誤解",
                       explanation: "@Valueはプレースホルダー解決のみです。暗号化にはJasypt等の外部ライブラリや専用Secrets管理が必要です。"),
                choice("d", "Spring Boot標準の`@Encrypted`アノテーションで設定値を暗号化する", misconception: "存在しないアノテーションを知識として誤学習",
                       explanation: "`@Encrypted` というSpring Boot標準アノテーションは存在しません。")
            ],
            explanationRef: "explain-boot3-cfg-props-006",
            designIntent: "シークレット管理のベストプラクティスを理解する。"
        ),
    ]

    // MARK: - Group 2: プロファイル (6問)
    private static let cfgProfiles: [Quiz] = [
        quiz(
            id: "boot3-cfg-profile-001",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@Profile", "プロファイル", "環境分岐"],
            code: """
@Component
@Profile("dev")
public class DevDataInitializer implements CommandLineRunner {
    @Override
    public void run(String... args) {
        // 開発用データ投入
    }
}
""",
            question: "`@Profile(\"dev\")` が付いたBeanが有効になる条件として正しいのはどれか？",
            choices: [
                choice("a", "`spring.profiles.active=dev` または `--spring.profiles.active=dev` でdevプロファイルが有効なとき", correct: true,
                       explanation: "@ProfileはSpringのアクティブプロファイルと照合します。devが有効な場合のみBeanが生成されます。"),
                choice("b", "`application-dev.yml` が存在するだけで自動的に有効になる", misconception: "プロファイルファイルの存在がアクティブ化すると誤解",
                       explanation: "プロファイルの有効化は明示的な設定（`spring.profiles.active`）が必要です。ファイルが存在するだけでは有効になりません。"),
                choice("c", "`@Profile(\"dev\")` のBeanはどのプロファイルが有効でも常にロードされるが、dev時のみ動作する", misconception: "Beanは常にロードされると誤解",
                       explanation: "@Profileが一致しないBeanはコンテナにロードされません。条件不一致のBeanは無視されます。"),
                choice("d", "プロファイルは1度に1つしか有効にできない", misconception: "複数プロファイルの同時有効化ができないと誤解",
                       explanation: "`spring.profiles.active=dev,local` のようにカンマ区切りで複数プロファイルを同時に有効化できます。")
            ],
            explanationRef: "explain-boot3-cfg-profile-001",
            designIntent: "@Profileの有効化条件を理解する。"
        ),
        quiz(
            id: "boot3-cfg-profile-002",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["application-{profile}.yml", "プロファイル設定ファイル"],
            code: """
# ファイル構成
src/main/resources/
  application.yml          # 共通設定
  application-dev.yml      # 開発環境専用
  application-prod.yml     # 本番環境専用
""",
            question: "`spring.profiles.active=prod` の場合、設定の読み込み方として正しいのはどれか？",
            choices: [
                choice("a", "`application.yml` が読み込まれた後、`application-prod.yml` の設定で上書きされる", correct: true,
                       explanation: "共通設定（`application.yml`）が先に読まれ、アクティブプロファイルに対応するファイルが後から適用されて上書きします。共通+環境固有のオーバーレイ設計です。"),
                choice("b", "`application-prod.yml` だけが読み込まれ、`application.yml` は無視される", misconception: "プロファイルファイルだけが使われると誤解",
                       explanation: "`application.yml` は必ず読み込まれます。プロファイルファイルは追加・上書きとして機能します。"),
                choice("c", "`application-dev.yml` も同時に読み込まれ、設定がマージされる", misconception: "全プロファイルファイルが常に読まれると誤解",
                       explanation: "アクティブでないプロファイルのファイル（dev.yml）は読み込まれません。"),
                choice("d", "プロファイルファイルはdockerコンテナ内でのみ有効", misconception: "プロファイルファイルの適用環境を誤解",
                       explanation: "プロファイルファイルはDockerに限らず、任意の実行環境で使用できます。")
            ],
            explanationRef: "explain-boot3-cfg-profile-002",
            designIntent: "プロファイルファイルのオーバーレイ挙動を理解する。"
        ),
        quiz(
            id: "boot3-cfg-profile-003",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["spring.profiles.default", "プロファイル未指定"],
            code: """
# application.yml
spring:
  profiles:
    default: local
""",
            question: "`spring.profiles.default=local` の設定をした場合の挙動として正しいのはどれか？",
            choices: [
                choice("a", "プロファイルを何も指定せずに起動した場合、`local` プロファイルが自動で有効になる", correct: true,
                       explanation: "`spring.profiles.default` はアクティブプロファイルが何も指定されていない場合のフォールバックです。CI環境などでの誤起動防止に便利です。"),
                choice("b", "`--spring.profiles.active=prod` で起動してもlocalプロファイルが優先される", misconception: "default設定がactiveより優先すると誤解",
                       explanation: "明示的に`spring.profiles.active`が指定された場合、`spring.profiles.default`は無視されます。"),
                choice("c", "`spring.profiles.default` を設定するとすべての環境でlocalプロファイルが有効になる", misconception: "defaultがactiveと同じ効果を持つと誤解",
                       explanation: "defaultはフォールバック専用です。activeが指定された場合は適用されません。"),
                choice("d", "`spring.profiles.default` の設定はSpring Boot 3.xで廃止された", misconception: "廃止されたという誤情報",
                       explanation: "この設定は引き続き有効です。廃止されていません。")
            ],
            explanationRef: "explain-boot3-cfg-profile-003",
            designIntent: "プロファイルのデフォルト設定を理解する。"
        ),
        quiz(
            id: "boot3-cfg-profile-004",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@Profile", "否定プロファイル", "!"],
            code: """
@Component
@Profile("!prod")
public class SwaggerConfig {
    // Swagger UIの設定（本番で無効にしたい）
}
""",
            question: "`@Profile(\"!prod\")` の意味として正しいのはどれか？",
            choices: [
                choice("a", "`prod` プロファイルが有効でない場合にこのBeanが有効になる", correct: true,
                       explanation: "プロファイル名の前に `!` を付けると「そのプロファイルでない場合」という否定条件になります。本番除外など環境の特定Beanを制御するのに使います。"),
                choice("b", "`prod` と `!prod` の両方が有効なプロファイルに一致する", misconception: "!がOR条件になると誤解",
                       explanation: "`!prod` は「prodでない」という否定です。prodが有効な場合にはこのBeanはロードされません。"),
                choice("c", "`!prod` という名前のプロファイルが必要で、`spring.profiles.active=!prod` と設定する", misconception: "!を文字通りプロファイル名と解釈",
                       explanation: "`!` はプロファイル条件の否定演算子です。`!prod` というプロファイル名ではありません。"),
                choice("d", "否定プロファイルはSpring Boot 3.0以降のみで使用可能", misconception: "バージョン依存の誤解",
                       explanation: "否定プロファイルはSpring Frameworkの古いバージョンから使用可能です。")
            ],
            explanationRef: "explain-boot3-cfg-profile-004",
            designIntent: "プロファイルの否定条件を理解する。"
        ),
        quiz(
            id: "boot3-cfg-profile-005",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["spring.config.activate.on-profile", "YAML多段"],
            code: """
# application.yml（1ファイルに複数プロファイルを定義）
spring:
  datasource:
    url: jdbc:h2:mem:testdb

---
spring:
  config:
    activate:
      on-profile: prod
  datasource:
    url: jdbc:postgresql://prod-db:5432/mydb
""",
            question: "1つのYAMLファイルに `---` で区切って複数プロファイルを定義する方法について正しいのはどれか？",
            choices: [
                choice("a", "`---` でドキュメントを分割し、`spring.config.activate.on-profile` でプロファイルを条件付けできる", correct: true,
                       explanation: "YAMLの`---`はドキュメント区切り記法です。Spring Bootはこれを利用して1ファイルに複数プロファイル設定を記述できます。"),
                choice("b", "`---` はYAMLのコメント記法でSpring Bootには影響しない", misconception: "---の意味を誤解",
                       explanation: "`---` はYAMLのドキュメント区切りで、Spring Bootはこれを複数ドキュメントとして処理します。"),
                choice("c", "Spring Boot 3.xでは `---` によるドキュメント区切りが廃止され、必ず別ファイルに分ける必要がある", misconception: "廃止されたという誤情報",
                       explanation: "`---` によるマルチドキュメントYAMLはSpring Boot 3.xでも引き続きサポートされています。"),
                choice("d", "マルチドキュメントYAMLでは先頭ドキュメントのみが読み込まれ、後ろは無視される", misconception: "後続ドキュメントが無視されると誤解",
                       explanation: "Spring Bootは全ドキュメントを読み込み、アクティブプロファイルに応じた設定を適用します。")
            ],
            explanationRef: "explain-boot3-cfg-profile-005",
            designIntent: "マルチドキュメントYAMLによるプロファイル管理を理解する。"
        ),
        quiz(
            id: "boot3-cfg-profile-006",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["テスト", "@ActiveProfiles", "@SpringBootTest"],
            code: """
@SpringBootTest
@ActiveProfiles("test")
class UserServiceTest {
    // テスト
}
""",
            question: "`@ActiveProfiles(\"test\")` を `@SpringBootTest` と組み合わせる目的として正しいのはどれか？",
            choices: [
                choice("a", "テスト時にのみ有効な設定（`application-test.yml` や `@Profile(\"test\")` のBean）を適用するため", correct: true,
                       explanation: "@ActiveProfilesはテストコンテキストのアクティブプロファイルを指定します。テスト用DBやモックBeanをプロファイルで切り替えるのに使います。"),
                choice("b", "`@ActiveProfiles` はCIサーバでのみ有効で、ローカル開発では機能しない", misconception: "環境依存と誤解",
                       explanation: "@ActiveProfilesは実行環境に依存しません。ローカルでも同様に動作します。"),
                choice("c", "`@ActiveProfiles(\"test\")` を使うとモックが自動生成されHTTPリクエストが不要になる", misconception: "プロファイルがモックを自動生成すると誤解",
                       explanation: "モックの生成は@MockBeanや@Mockitoが担います。@ActiveProfilesはプロファイル指定のみです。"),
                choice("d", "`test` プロファイルはSpring Bootが自動認識するため `@ActiveProfiles` は不要", misconception: "testプロファイルが自動有効化されると誤解",
                       explanation: "`test` は特別扱いされません。`@ActiveProfiles` での明示的な指定が必要です。ただし `src/test/resources/application.yml` は自動で使われます。")
            ],
            explanationRef: "explain-boot3-cfg-profile-006",
            designIntent: "テストでのプロファイル活用を理解する。"
        ),
    ]

    // MARK: - Group 3: @ConfigurationProperties (5問)
    private static let cfgConfigProps: [Quiz] = [
        quiz(
            id: "boot3-cfg-configprops-001",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@ConfigurationProperties", "prefix", "型安全"],
            code: """
@ConfigurationProperties(prefix = "app.mail")
@Component
public class MailProperties {
    private String host;
    private int port = 25;
    private boolean ssl;
    // getter/setter
}

# application.yml
app:
  mail:
    host: smtp.example.com
    port: 587
    ssl: true
""",
            question: "`@ConfigurationProperties` を `@Value` より推奨する理由として正しいのはどれか？",
            choices: [
                choice("a", "関連する設定をクラスにまとめてバインドでき、型安全・IDEのオートコンプリート・バリデーション対応が容易", correct: true,
                       explanation: "@ConfigurationPropertiesは設定グループをPOJOにバインドします。@Valueの分散した文字列キーに比べて管理しやすく、@Validatedで制約も付けられます。"),
                choice("b", "`@ConfigurationProperties` は環境変数からは読み込めず、YAMLのみ対応", misconception: "対応ソースの誤解",
                       explanation: "@ConfigurationPropertiesも環境変数・コマンドライン引数・YAMLなど全てのソースから読み込みます。"),
                choice("c", "`@ConfigurationProperties` を使うとプロパティ変更時に自動でBeanが再作成される", misconception: "ホットリロードが自動化されると誤解",
                       explanation: "実行時のホットリロードは@RefreshScope（Spring Cloud Config等）が必要です。@ConfigurationPropertiesだけでは再作成されません。"),
                choice("d", "`@ConfigurationProperties` はシングルトンBeanにのみ適用可能", misconception: "スコープの制限を誤解",
                       explanation: "@ConfigurationPropertiesはスコープに関係なく使えます。ただし通常はシングルトンで使います。")
            ],
            explanationRef: "explain-boot3-cfg-configprops-001",
            designIntent: "@ConfigurationPropertiesの利点を理解する。"
        ),
        quiz(
            id: "boot3-cfg-configprops-002",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@EnableConfigurationProperties", "@ConfigurationPropertiesScan"],
            code: """
// パターンA
@SpringBootApplication
@EnableConfigurationProperties(MailProperties.class)
public class App {}

// パターンB
@SpringBootApplication
@ConfigurationPropertiesScan
public class App {}

// パターンC
@ConfigurationProperties(prefix = "app.mail")
@Component
public class MailProperties {}
""",
            question: "`@ConfigurationProperties` クラスをBeanとして登録する方法として正しくないのはどれか？",
            choices: [
                choice("a", "`@ConfigurationProperties` クラスに `@Autowired` を付けるだけで自動登録される", correct: true,
                       explanation: "@AutowiredはフィールドインジェクションのアノテーションでBeanを定義しません。@Component・@EnableConfigurationProperties・@ConfigurationPropertiesScanのいずれかが必要です。"),
                choice("b", "`@Component` を付ける", misconception: "@Componentが無効と誤解",
                       explanation: "@Componentは有効なBean登録方法です。コンポーネントスキャンの対象になります。"),
                choice("c", "`@EnableConfigurationProperties(MailProperties.class)` を使う", misconception: "@EnableConfigurationPropertiesが無効と誤解",
                       explanation: "@EnableConfigurationPropertiesは明示的に対象クラスを指定してBean登録します。有効な方法です。"),
                choice("d", "`@ConfigurationPropertiesScan` を使う", misconception: "@ConfigurationPropertiesScanが無効と誤解",
                       explanation: "@ConfigurationPropertiesScanは@ConfigurationPropertiesを持つクラスを自動スキャンします。有効な方法です。")
            ],
            explanationRef: "explain-boot3-cfg-configprops-002",
            designIntent: "@ConfigurationPropertiesのBean登録方法を理解する。"
        ),
        quiz(
            id: "boot3-cfg-configprops-003",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@Validated", "@NotNull", "@Min", "バリデーション"],
            code: """
@ConfigurationProperties(prefix = "app.server")
@Validated
@Component
public class ServerProperties {

    @NotBlank
    private String host;

    @Min(1) @Max(65535)
    private int port;

    @NotNull
    private Duration timeout;
}
""",
            question: "`@Validated` を `@ConfigurationProperties` と組み合わせた場合の挙動として正しいのはどれか？",
            choices: [
                choice("a", "Spring起動時にバリデーションが実行され、制約違反があれば起動に失敗する", correct: true,
                       explanation: "@Validatedを付けるとSpringがBean生成時（起動時）にBean Validationを実行します。設定ミスを早期検出できます。"),
                choice("b", "バリデーションはAPIリクエスト時のみ実行され、起動時には何も検証されない", misconception: "@ValidatedがWeb層専用と誤解",
                       explanation: "@ConfigurationPropertiesの@Validatedは起動時に評価されます。Webリクエストとは無関係です。"),
                choice("c", "`Duration` 型はバリデーション対象外になり `@NotNull` は無視される", misconception: "Duration型がバリデーション非対応と誤解",
                       explanation: "Duration型も@NotNullなど存在チェックのバリデーションが適用されます。"),
                choice("d", "`@Validated` を付けると `@ConfigurationProperties` が認識されなくなる", misconception: "混在不可と誤解",
                       explanation: "@Validatedと@ConfigurationPropertiesは共存できます。むしろ設定の安全性向上のための組み合わせです。")
            ],
            explanationRef: "explain-boot3-cfg-configprops-003",
            designIntent: "設定値のバリデーションを理解する。"
        ),
        quiz(
            id: "boot3-cfg-configprops-004",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["record", "@ConfigurationProperties", "イミュータブル"],
            code: """
@ConfigurationProperties(prefix = "app.feature")
public record FeatureProperties(
    boolean enabled,
    int maxRetry,
    Duration timeout
) {}
""",
            question: "`record` を `@ConfigurationProperties` に使う場合の特徴として正しいのはどれか？",
            choices: [
                choice("a", "recordはイミュータブルなため設定値が起動後に変更されず、@Componentなしでも@EnableConfigurationPropertiesで登録できる", correct: true,
                       explanation: "Spring Boot 2.6以降でrecordの@ConfigurationPropertiesサポートが改善されました。getter/setterが不要でイミュータブルな設定クラスを簡潔に書けます。"),
                choice("b", "recordにはsetterがないためSpringが値をバインドできず起動エラーになる", misconception: "recordへのバインドが不可と誤解",
                       explanation: "Spring Bootはrecordのコンストラクタを通じて設定値をバインドします。setterは不要です。"),
                choice("c", "`record` を使うと `@Validated` が使えなくなる", misconception: "recordとバリデーションの非互換性を誤解",
                       explanation: "recordでも@Validatedによる起動時バリデーションが使えます。フィールドへのアノテーションはコンパクトコンストラクタで指定します。"),
                choice("d", "recordを使うとプロファイルによる設定の上書きができなくなる", misconception: "recordが設定の柔軟性を失わせると誤解",
                       explanation: "プロファイルによる設定上書きはrecordかクラスかに関係なく動作します。")
            ],
            explanationRef: "explain-boot3-cfg-configprops-004",
            designIntent: "recordを使ったイミュータブルな設定クラスを理解する。"
        ),
        quiz(
            id: "boot3-cfg-configprops-005",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["追加メタデータ", "spring-configuration-metadata", "IDE補完"],
            code: """
// build.gradle
annotationProcessor 'org.springframework.boot:spring-boot-configuration-processor'
""",
            question: "`spring-boot-configuration-processor` の役割として正しいのはどれか？",
            choices: [
                choice("a", "@ConfigurationPropertiesクラスのメタデータを生成し、IDEがapplication.ymlでオートコンプリートできるようになる", correct: true,
                       explanation: "アノテーションプロセッサがコンパイル時にメタデータ（`spring-configuration-metadata.json`）を生成します。IntelliJやVSCodeがYAMLのキー補完に使用します。"),
                choice("b", "このプロセッサがないと@ConfigurationPropertiesが動作しない", misconception: "プロセッサが実行必須と誤解",
                       explanation: "configuration-processorはIDE補完用です。アプリの動作には不要です。"),
                choice("c", "このプロセッサはランタイムに含まれ起動時のバインドを高速化する", misconception: "ランタイムの役割を誤解",
                       explanation: "annotationProcessorはコンパイル時のみです。最終的なJARには含まれません。"),
                choice("d", "このプロセッサを使うと設定値の変更が即座にアプリに反映される", misconception: "ホットリロードと誤解",
                       explanation: "ホットリロードは別の仕組み（devtools等）です。このプロセッサはIDEのメタデータ生成専用です。")
            ],
            explanationRef: "explain-boot3-cfg-configprops-005",
            designIntent: "設定プロセッサの役割を理解する。"
        ),
    ]

    // MARK: - Group 4: 外部化設定 (5問)
    private static let cfgExternalize: [Quiz] = [
        quiz(
            id: "boot3-cfg-ext-001",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["環境変数", "Docker", "Kubernetes"],
            code: """
# Dockerでの環境変数注入
docker run -e SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/prod \\
           -e SPRING_DATASOURCE_PASSWORD=securepass \\
           myapp:latest
""",
            question: "DockerでSpring Bootアプリに環境変数を渡す場合の命名規則として正しいのはどれか？",
            choices: [
                choice("a", "`spring.datasource.url` は `SPRING_DATASOURCE_URL`（ドットをアンダースコア、大文字）に変換してRelaxed Bindingで解決される", correct: true,
                       explanation: "環境変数はRelaxed Bindingにより`SPRING_DATASOURCE_URL` → `spring.datasource.url`として解決されます。Dockerや12-factor appとの相性が良い設計です。"),
                choice("b", "環境変数はYAMLのキーと完全に大文字小文字一致する必要があり、`SPRING_DATASOURCE_URL` は無効", misconception: "Relaxed Bindingを知らない",
                       explanation: "Relaxed Bindingにより大文字スネークケースと小文字ドット区切りは同一キーとして処理されます。"),
                choice("c", "`-e SPRING_DATASOURCE_URL=...` はSpring Cloud Configが必要で、標準Spring Bootでは使えない", misconception: "Spring Cloud Configが必要と誤解",
                       explanation: "Spring Cloud Configは不要です。標準Spring Bootの環境変数サポートで動作します。"),
                choice("d", "Dockerコンテナ内では `application.yml` が無視される", misconception: "コンテナで設定ファイルが無視されると誤解",
                       explanation: "JARに含まれる `application.yml` は常に読み込まれます。環境変数はその設定を上書きします。")
            ],
            explanationRef: "explain-boot3-cfg-ext-001",
            designIntent: "コンテナ環境での設定外部化を理解する。"
        ),
        quiz(
            id: "boot3-cfg-ext-002",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["spring.config.location", "外部設定ファイル", "JARの外"],
            code: """
# JARの外の設定ファイルを参照
java -jar app.jar \\
  --spring.config.location=file:/etc/myapp/application.yml
""",
            question: "`spring.config.location` を使う場面として適切なのはどれか？",
            choices: [
                choice("a", "JARに含まれない外部設定ファイルを使う場合（サーバ上の固定パスやボリュームマウント）", correct: true,
                       explanation: "`spring.config.location` でJAR外のファイルを指定できます。本番サーバのロールに応じた設定ファイルや、KubernetesのConfigMapマウントに使います。"),
                choice("b", "`spring.config.location` を指定すると `application.yml` が完全に無効になり外部ファイルのみ使われる", misconception: "location指定でJAR内ファイルが無効になると誤解",
                       explanation: "デフォルトの設定場所に追加する場合は `spring.config.additional-location` を使います。`location` だけを指定するとデフォルト場所を置き換えます。"),
                choice("c", "`spring.config.location` はtest環境のみで有効", misconception: "環境限定と誤解",
                       explanation: "任意の環境で使用できます。本番環境での外部設定ファイル指定に特に有用です。"),
                choice("d", "`spring.config.location` にHTTP URLを指定してリモートから設定を取得できる", misconception: "HTTPリモート取得をサポートすると誤解",
                       explanation: "標準では `classpath:`・`file:` のみです。HTTPリモートにはSpring Cloud Configが必要です。")
            ],
            explanationRef: "explain-boot3-cfg-ext-002",
            designIntent: "JARの外の設定ファイル使用方法を理解する。"
        ),
        quiz(
            id: "boot3-cfg-ext-003",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["Spring Cloud Config", "集中設定", "マイクロサービス"],
            code: """
# bootstrap.yml（Spring Cloud Config使用時）
spring:
  application:
    name: user-service
  config:
    import: "configserver:http://config-server:8888"
""",
            question: "Spring Cloud Config Serverを使う主なメリットとして正しいのはどれか？",
            choices: [
                choice("a", "複数サービスの設定をGitリポジトリで一元管理でき、再デプロイなしに設定を変更できる", correct: true,
                       explanation: "Spring Cloud Configは集中型の設定管理サーバです。設定をGitで管理し、バージョン管理・監査・動的リフレッシュが可能になります。マイクロサービスで特に有効です。"),
                choice("b", "Spring Cloud ConfigはSpring Boot 3.xでは不要で、標準の`application.yml`で全て解決できる", misconception: "Spring Cloud Configが不要になったと誤解",
                       explanation: "Spring Cloud Configは現役です。複数サービスの集中設定管理のニーズは標準機能では解決できません。"),
                choice("c", "Spring Cloud Config Serverを使うとapplication.ymlが自動暗号化される", misconception: "自動暗号化があると誤解",
                       explanation: "暗号化にはSpring Cloud Configの`encrypt/decrypt`機能を別途有効化する必要があります。自動ではありません。"),
                choice("d", "Spring Cloud Configを使うと全サービスが同じ設定を強制使用させられる", misconception: "設定が統一強制されると誤解",
                       explanation: "サービスごとに設定ファイルを分けられます（`{service-name}.yml`）。共通設定と個別設定の組み合わせが可能です。")
            ],
            explanationRef: "explain-boot3-cfg-ext-003",
            designIntent: "Spring Cloud Configの役割を理解する。"
        ),
        quiz(
            id: "boot3-cfg-ext-004",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@RefreshScope", "動的リフレッシュ", "Actuator"],
            code: """
@RestController
@RefreshScope
public class FeatureController {

    @Value("${feature.newUi:false}")
    private boolean newUiEnabled;

    @GetMapping("/feature")
    public Map<String, Boolean> features() {
        return Map.of("newUi", newUiEnabled);
    }
}
""",
            question: "`@RefreshScope` を使った場合の動作として正しいのはどれか？",
            choices: [
                choice("a", "Actuatorの `/actuator/refresh` エンドポイントを呼ぶとBeanが再生成され、新しい設定値が反映される", correct: true,
                       explanation: "@RefreshScopeを付けたBeanはリフレッシュ時に破棄・再生成されます。設定変更を再デプロイなしに適用できます。Spring Cloud Configとセットで使うのが一般的です。"),
                choice("b", "@RefreshScopeを付けると設定ファイルの変更を毎分自動でポーリングする", misconception: "自動ポーリングが有効になると誤解",
                       explanation: "自動ポーリングは別途設定が必要です。@RefreshScope自体はリフレッシュトリガーを待つだけです。"),
                choice("c", "@RefreshScopeはシングルトンBeanに使えないため、Controllerには適用できない", misconception: "適用可能スコープの誤解",
                       explanation: "@RefreshScopeは任意のBeanに適用できます。Controllerへの使用も一般的です。"),
                choice("d", "@RefreshScopeを使うとBean生成のパフォーマンスが恒常的に低下する", misconception: "パフォーマンスへの誤った影響",
                       explanation: "@RefreshScopeのオーバーヘッドはリフレッシュ時のみです。通常時のパフォーマンスへの影響はほぼありません。")
            ],
            explanationRef: "explain-boot3-cfg-ext-004",
            designIntent: "動的設定リフレッシュの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-cfg-ext-005",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["12-factor", "設定原則", "外部化設定"],
            code: """
// 悪い例：ハードコード
private static final String API_URL = "https://internal-api.example.com";

// 良い例：外部化
@Value("${external.api.url}")
private String apiUrl;
""",
            question: "12-factor appの「設定」原則で求めていることとして最も正確なのはどれか？",
            choices: [
                choice("a", "環境によって変わる設定（DB接続情報、APIキー等）はコードから分離して環境変数で管理する", correct: true,
                       explanation: "12-factor appの第3原則「設定」は、「コードベースは環境間で変わらず、設定が環境間で変わる」を守るため、設定を環境変数で管理することを求めています。"),
                choice("b", "全ての設定をデータベーステーブルで管理し、アプリ起動時に読み込む", misconception: "DBでの設定管理が12-factorの原則と誤解",
                       explanation: "12-factor appは環境変数を推奨しています。DBへの依存はアプリの起動複雑度を増加させます。"),
                choice("c", "設定ファイルは必ずJAR内に含め、環境変数は使用しない", misconception: "設定の内包化が正しいと誤解",
                       explanation: "12-factor appはこの逆を求めています。設定はコードと分離し、外部から注入します。"),
                choice("d", "12-factor appはSpring Bootアプリにのみ適用される設計指針", misconception: "12-factor appがSpring Boot専用と誤解",
                       explanation: "12-factor appは言語・フレームワーク非依存の一般的なWebアプリ開発手法論です。")
            ],
            explanationRef: "explain-boot3-cfg-ext-005",
            designIntent: "12-factor appの設定原則を理解する。"
        ),
    ]

    // MARK: - Group 5: 条件付きBean (4問)
    private static let cfgConditional: [Quiz] = [
        quiz(
            id: "boot3-cfg-cond-001",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@ConditionalOnProperty", "有効化切替"],
            code: """
@Bean
@ConditionalOnProperty(
    name = "feature.payment.stripe",
    havingValue = "true",
    matchIfMissing = false
)
public StripePaymentService stripePaymentService() {
    return new StripePaymentService();
}
""",
            question: "`@ConditionalOnProperty` の `matchIfMissing = false` の意味として正しいのはどれか？",
            choices: [
                choice("a", "プロパティが定義されていない場合はこのBeanを生成しない", correct: true,
                       explanation: "`matchIfMissing = false` がデフォルト値で、プロパティが存在しない場合はBean生成条件を満たさないとみなします。`true` にするとプロパティ未定義時もBeanが生成されます。"),
                choice("b", "プロパティが `false` の値を持つ場合にBeanを生成しない", misconception: "matchIfMissingがfalse値への反応と誤解",
                       explanation: "`matchIfMissing` はプロパティの「存在有無」のフォールバック動作を制御します。プロパティの値（true/false）とは別の概念です。"),
                choice("c", "`havingValue` で指定した値と一致しない場合にBeanを生成する", misconception: "havingValueの条件を逆に理解",
                       explanation: "`havingValue` と一致した場合にBeanが生成されます。一致しない場合はスキップです。"),
                choice("d", "このアノテーションはSpring Boot 3.x以降では廃止されている", misconception: "廃止されたという誤情報",
                       explanation: "@ConditionalOnPropertyはSpring Boot 3.xでも現役です。フィーチャーフラグの実装によく使います。")
            ],
            explanationRef: "explain-boot3-cfg-cond-001",
            designIntent: "@ConditionalOnPropertyの細かい挙動を理解する。"
        ),
        quiz(
            id: "boot3-cfg-cond-002",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@ConditionalOnMissingBean", "自動設定", "カスタム"],
            code: """
@Configuration
@ConditionalOnClass(StripeClient.class)
public class StripeAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public StripeClient stripeClient() {
        return new StripeClient();
    }
}
""",
            question: "`@ConditionalOnMissingBean` の動作として正しいのはどれか？",
            choices: [
                choice("a", "同じ型のBeanが他で定義されていなければこのBeanを生成し、ユーザー定義Beanがあれば自動設定が上書きされない", correct: true,
                       explanation: "@ConditionalOnMissingBeanはSpring Bootの自動設定の核心です。ユーザーがカスタムBeanを定義した場合、自動設定は適用されません。"),
                choice("b", "`@ConditionalOnMissingBean` はBeanが何もない場合にエラーを出す", misconception: "MissingBeanがエラー通知と誤解",
                       explanation: "MissingBeanはBeanがなければ生成する、という条件です。エラーではありません。"),
                choice("c", "自動設定クラスは `@ConditionalOnMissingBean` なしでも常にユーザー定義Beanより後に評価される", misconception: "自動設定の評価順が自動保証されると誤解",
                       explanation: "@ConditionalOnMissingBeanなしでは同型のBeanが2つ定義されてしまいます。自動設定の「上書き許可」にはこのアノテーションが必要です。"),
                choice("d", "`@ConditionalOnClass(StripeClient.class)` はStripeClientのBeanが存在するかを確認する", misconception: "@ConditionalOnClassと@ConditionalOnBeanを混同",
                       explanation: "@ConditionalOnClassはクラスパスにクラスが存在するかを確認します。Beanの存在確認は@ConditionalOnBeanです。")
            ],
            explanationRef: "explain-boot3-cfg-cond-002",
            designIntent: "@ConditionalOnMissingBeanの自動設定における役割を理解する。"
        ),
        quiz(
            id: "boot3-cfg-cond-003",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["@ConditionalOnWebApplication", "@ConditionalOnClass", "自動設定"],
            code: """
@Bean
@ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET)
public FilterRegistrationBean<MyFilter> myFilter() {
    // ...
}
""",
            question: "`@ConditionalOnWebApplication(type = Type.SERVLET)` の意味として正しいのはどれか？",
            choices: [
                choice("a", "サーブレットベース（Spring MVC）のWebアプリケーションの場合のみこのBeanを生成する", correct: true,
                       explanation: "Spring Boot 3.xはサーブレット型（Spring MVC）とリアクティブ型（Spring WebFlux）をサポートします。このConditionでサーブレット環境のみに限定できます。"),
                choice("b", "このBeanはHTTPリクエストのSERVLETメソッドでのみ有効になる", misconception: "WebApplication.TypeをHTTPメソッドと混同",
                       explanation: "Type.SERVLETはSpringのWebフレームワーク種別（サーブレット vs リアクティブ）です。HTTPメソッドとは無関係です。"),
                choice("c", "WebFluxを使っている場合でもサーブレット型のBeanは常に生成される", misconception: "Conditionが効かないと誤解",
                       explanation: "WebFlux環境ではType.SERVLETの条件が満たされずBeanはスキップされます。"),
                choice("d", "`@ConditionalOnWebApplication` はテスト環境では常にtrueになる", misconception: "テスト環境での挙動を誤解",
                       explanation: "テスト環境でもWebアプリケーションコンテキストかどうかで判断されます。@WebMvcTestではWebアプリとして扱われます。")
            ],
            explanationRef: "explain-boot3-cfg-cond-003",
            designIntent: "Webアプリタイプの条件指定を理解する。"
        ),
        quiz(
            id: "boot3-cfg-cond-004",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .configuration,
            tags: ["カスタム@Conditional", "Condition", "ビジネスロジック条件"],
            code: """
public class OnBusinessHoursCondition implements Condition {
    @Override
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {
        int hour = LocalTime.now().getHour();
        return hour >= 9 && hour < 18;
    }
}

@Bean
@Conditional(OnBusinessHoursCondition.class)
public ScheduledTaskService scheduledTaskService() { ... }
""",
            question: "カスタム `Condition` を実装する場面として適切なのはどれか？",
            choices: [
                choice("a", "プロパティ・クラスパス・プロファイルなど既存の@Conditionalで表現できない独自の条件が必要な場合", correct: true,
                       explanation: "Conditionインターフェースを実装することで任意の条件（時刻、OSタイプ、外部リソースの有無など）でBean生成を制御できます。"),
                choice("b", "カスタムConditionはパフォーマンス上の理由でSpring Bootでは推奨されていない", misconception: "カスタムConditionが非推奨と誤解",
                       explanation: "Spring自体がカスタムConditionを使って自動設定を構築しています。適切に使えば問題ありません。"),
                choice("c", "カスタムConditionはBean定義にしか使えず、@ComponentScanには適用できない", misconception: "適用範囲の誤解",
                       explanation: "@Conditionalは@Component、@Bean、@Configurationなど様々な箇所に適用できます。"),
                choice("d", "毎回`matches()`が呼ばれるため、ビジネスロジックをConditionに入れるとランタイムパフォーマンスが低下する", misconception: "Conditionがランタイムで毎回評価されると誤解",
                       explanation: "Conditionはアプリケーションコンテキスト起動時の1度のみ評価されます。ランタイムのパフォーマンスへの影響はありません。")
            ],
            explanationRef: "explain-boot3-cfg-cond-004",
            designIntent: "カスタム条件のユースケースを理解する。"
        ),
    ]

    // MARK: - Group 6: Actuator設定 (3問)
    private static let cfgActuator: [Quiz] = [
        quiz(
            id: "boot3-cfg-actuator-001",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .configuration,
            tags: ["Actuator", "management.endpoints.web.exposure", "セキュリティ"],
            code: """
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: "health,info,metrics"
  endpoint:
    health:
      show-details: when-authorized
""",
            question: "`management.endpoints.web.exposure.include=*` を本番で使う場合のリスクとして正しいのはどれか？",
            choices: [
                choice("a", "全エンドポイントが公開されるため、`/actuator/shutdown` や `/actuator/env` など機密情報や破壊的操作が外部から実行される可能性がある", correct: true,
                       explanation: "`*` は全エンドポイントを公開します。`shutdown`は強制停止、`env`は環境変数一覧（シークレット含む）が見えるため、認証なしの`*`は本番で危険です。"),
                choice("b", "`*` を指定するとActuatorエンドポイントのレスポンスが2倍になりパフォーマンスが低下する", misconception: "存在しないパフォーマンス影響",
                       explanation: "公開範囲はセキュリティとプライバシーの問題であり、パフォーマンスへの直接影響はありません。"),
                choice("c", "`*` を指定するとSpring Securityが自動でBasic認証を要求する", misconception: "Actuatorの自動認証保護を誤解",
                       explanation: "Spring Securityがあれば保護されますが、Spring Securityなしでは保護されません。`*`使用時はSecurityの設定が必要です。"),
                choice("d", "`include=*` を使うとカスタムエンドポイントが無効になる", misconception: "ワイルドカードでカスタムが除外されると誤解",
                       explanation: "`*`はカスタムエンドポイントも含む全てを公開します。カスタムエンドポイントも有効になります。")
            ],
            explanationRef: "explain-boot3-cfg-actuator-001",
            designIntent: "ActuatorのセキュリティリスクとExposure設定を理解する。"
        ),
        quiz(
            id: "boot3-cfg-actuator-002",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .configuration,
            tags: ["management.server.port", "管理ポート分離", "セキュリティ"],
            code: """
management:
  server:
    port: 8081
  endpoints:
    web:
      exposure:
        include: "*"
""",
            question: "Actuatorを別ポート（8081）で公開する理由として正しいのはどれか？",
            choices: [
                choice("a", "ビジネスAPIポート（8080）とActuatorを分離してファイアウォールでActuatorを内部ネットワークのみに制限できる", correct: true,
                       explanation: "ポート分離により、外部からは8080のみアクセスさせ、8081のActuatorは内部ネットワークのみに限定できます。ゼロトラスト境界に合わせた設計です。"),
                choice("b", "ポートを分けるとActuatorがより多くのメトリクスを収集できる", misconception: "ポート分離がメトリクス量を増やすと誤解",
                       explanation: "ポートはActuatorの公開経路の設定です。収集するメトリクスの種類・量には影響しません。"),
                choice("c", "Actuatorは8081ポートのみ対応しており8080では動作しない", misconception: "Actuatorのポートが固定と誤解",
                       explanation: "Actuatorのポートは設定で自由に変更できます。デフォルトはアプリと同じポート（8080等）です。"),
                choice("d", "別ポートに分けるとActuatorのレスポンスが5倍速くなる", misconception: "存在しないパフォーマンス改善",
                       explanation: "ポート分離はネットワーク分離・セキュリティが目的です。パフォーマンス改善は主な目的ではありません。")
            ],
            explanationRef: "explain-boot3-cfg-actuator-002",
            designIntent: "Actuatorのポート分離とセキュリティを理解する。"
        ),
        quiz(
            id: "boot3-cfg-actuator-003",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .configuration,
            tags: ["カスタムInfoContributor", "/actuator/info", "ビルド情報"],
            code: """
# build.gradle (Spring Boot Plugin)
springBoot {
    buildInfo()
}

# application.yml
management:
  info:
    build:
      enabled: true
    git:
      enabled: true
      mode: full
""",
            question: "`/actuator/info` にビルド情報・Gitコミット情報を表示する設定について正しいのはどれか？",
            choices: [
                choice("a", "Gradleの`buildInfo()`タスクが`build-info.properties`を生成し、`git.properties`はgit-commit-id-pluginで生成する", correct: true,
                       explanation: "ビルド情報はGradle/MavenのプラグインがJARにプロパティファイルとして埋め込みます。Actuatorはこれを読んで `/actuator/info` に表示します。"),
                choice("b", "`management.info.build.enabled=true` だけでSpring Bootがビルド情報を自動生成する", misconception: "設定だけで情報が生成されると誤解",
                       explanation: "プロパティファイルはビルド時に生成が必要です。Spring Boot起動時に自動生成する機能はありません。"),
                choice("c", "Gitコミット情報は`application.yml`に手動で書かなければ表示されない", misconception: "プラグインによる自動生成を知らない",
                       explanation: "git-commit-id-maven-plugin（またはGradleの対応プラグイン）が`git.properties`を自動生成します。手動記述は不要です。"),
                choice("d", "`/actuator/info` は認証なしに公開してよい情報のみ含むため、セキュリティ設定は不要", misconception: "infoが常に安全と誤解",
                       explanation: "Gitコミットハッシュや環境情報は攻撃者に有益な情報になり得ます。環境に応じて公開範囲を検討すべきです。")
            ],
            explanationRef: "explain-boot3-cfg-actuator-003",
            designIntent: "Actuatorの/actuator/info設定を理解する。"
        ),
    ]
}
