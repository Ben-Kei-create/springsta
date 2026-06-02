import Foundation

extension Quiz {
    static let errorReading3Quizzes: [Quiz] = (
        err3Startup + err3Runtime + err3Performance + err3Integration
    ).map { $0.contextualizedForPresentation() }

    // MARK: - 起動エラー
    private static let err3Startup: [Quiz] = [
        quiz(
            id: "boot3-err3-startup-001",
            level: .foundation,
            objective: "boot3-foundation-config",
            category: .errorReading,
            tags: ["@ConfigurationProperties", "BindException", "必須フィールド"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Caused by: org.springframework.boot.context.properties
  .bind.BindException:
  Failed to bind properties under 'app.database'
  to com.example.DatabaseProperties:

  Property: app.database.url
  Value: null
  Reason: Property 'app.database.url' must not be null
""",
            question: "このBindExceptionの原因として正しいものはどれか？",
            choices: [
                choice("a", "`DatabaseProperties`クラスで`@NotNull`等が付いた必須フィールド`url`がapplication.ymlに定義されていない", correct: true,
                       explanation: "`@ConfigurationProperties`と`@Validated`を組み合わせると`@NotNull`フィールドが未設定の場合にBindExceptionが発生します。`app.database.url`をapplication.ymlに追加して解決します。"),
                choice("b", "URLの値に不正な文字が含まれている", misconception: "型変換エラーと未設定エラーを混同",
                       explanation: "型変換エラーの場合は`failed to convert`メッセージが出ます。`null`は未設定を示します。"),
                choice("c", "`@ConfigurationProperties`クラスに`@Component`が付いていない", misconception: "Bean登録の問題とバインドエラーを混同",
                       explanation: "Bean未登録なら`NoSuchBeanDefinitionException`が出ます。このエラーはプロパティ値の未設定です。"),
                choice("d", "Spring Boot 3.xでは`app.*`プレフィックスは使用禁止", misconception: "プレフィックスの制限を誤解",
                       explanation: "`app.*`はSpring Bootのカスタムプロパティとして自由に使用できます。")
            ],
            explanationRef: "explain-boot3-err3-startup-001",
            designIntent: "@ConfigurationPropertiesの必須フィールド未設定によるBindExceptionを特定できる。"
        ),
        quiz(
            id: "boot3-err3-startup-002",
            level: .foundation,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["Flyway", "チェックサム", "マイグレーション", "FlywayException"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Caused by: org.flywaydb.core.api.exception.FlywayValidateException:
  Validate failed: Migrations have failed validation
  Migration checksum mismatch for migration version 2
  -> Applied to database : 1234567890
  -> Resolved locally    : 9876543210
  Either revert the changes to the migration, or run
  `flyway repair` to update the schema history table.
""",
            question: "このFlywayエラーの原因として正しいものはどれか？",
            choices: [
                choice("a", "すでにDBに適用済みの`V2__add_column.sql`を後から修正したためチェックサムが不一致になった", correct: true,
                       explanation: "Flywayは適用済みマイグレーションの変更を検出します。適用済みSQLは変更禁止です。`flyway repair`でスキーマ履歴を修正するか、変更を`V3__...sql`として追加します。"),
                choice("b", "`V2__add_column.sql`のファイル名が命名規則に違反している", misconception: "命名規則違反とチェックサム不一致を混同",
                       explanation: "命名規則違反なら別のエラーが出ます。チェックサム不一致は内容の変更を示します。"),
                choice("c", "DBのFlywayスキーマ履歴テーブルが存在しない", misconception: "テーブル未作成と検証失敗を混同",
                       explanation: "テーブル未存在の場合はFlywayが自動作成します。このエラーは既存レコードとの不一致です。"),
                choice("d", "SQLファイルのエンコードがUTF-8でない", misconception: "文字コードとチェックサムを混同",
                       explanation: "文字コード問題ならSQL実行時にエラーが出ます。このエラーはファイル内容変更によるチェックサム不一致です。")
            ],
            explanationRef: "explain-boot3-err3-startup-002",
            designIntent: "Flywayチェックサム不一致エラーから適用済みマイグレーションの変更禁止ルールを理解できる。"
        ),
        quiz(
            id: "boot3-err3-startup-003",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .errorReading,
            tags: ["@SpringBootTest", "@MockBean", "UnsatisfiedDependencyException"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

org.springframework.beans.factory.UnsatisfiedDependencyException:
  Error creating bean with name 'orderService':
  Unsatisfied dependency expressed through field 'paymentClient';
  nested exception is NoSuchBeanDefinitionException:
  No qualifying bean of type
  'com.example.PaymentClient' available

  at ...OrderServiceTest.java (via reflection)
""",
            question: "テスト起動時のUnsatisfiedDependencyExceptionの原因として正しいものはどれか？",
            choices: [
                choice("a", "`@SpringBootTest`でフルコンテキストをロードしているが`PaymentClient`の`@MockBean`が宣言されておらず、実Beanが解決できない", correct: true,
                       explanation: "`@SpringBootTest`は全Beanをロードします。外部クライアント等をモックしたい場合はテストクラスに`@MockBean`を付けて偽のBeanを登録します。"),
                choice("b", "`@SpringBootTest`には`classes`属性で対象クラスを明示しなければならない", misconception: "classes属性の必須化を誤解",
                       explanation: "`classes`属性は省略可能で、省略時は`@SpringBootApplication`からスキャンします。"),
                choice("c", "`PaymentClient`は`@FeignClient`なので`@SpringBootTest`では使えない", misconception: "FeignClientとSpringBootTestの組み合わせを誤解",
                       explanation: "FeignClientもBeanとして登録されます。テストでは`@MockBean`またはWireMockで代替します。"),
                choice("d", "テストクラスに`@Autowired`がないためDIが失敗した", misconception: "テストの@Autowiredと起動失敗を混同",
                       explanation: "テストクラスへの`@Autowired`はSpring Test Contextが自動で処理します。Beanが見つからないことが問題です。")
            ],
            explanationRef: "explain-boot3-err3-startup-003",
            designIntent: "@SpringBootTestでの@MockBean欠落によるUnsatisfiedDependencyExceptionを特定できる。"
        ),
        quiz(
            id: "boot3-err3-startup-004",
            level: .foundation,
            objective: "boot3-foundation-starter",
            category: .errorReading,
            tags: ["@SpringBootApplication", "複数起動クラス", "メインクラス"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

java.lang.IllegalStateException:
  Found multiple @SpringBootApplication-annotated classes:
  [com.example.Application,
   com.example.legacy.OldApplication]
  Please remove ambiguous configuration.
""",
            question: "このエラーの原因と修正として正しいものはどれか？",
            choices: [
                choice("a", "プロジェクトに`@SpringBootApplication`が複数存在し、どちらを起動エントリポイントにするか曖昧になっている。一方を削除するかサブモジュールに移動する", correct: true,
                       explanation: "`@SpringBootApplication`はプロジェクトに1つが原則です。テストやマイグレーション用の古いクラスが残っている場合は削除または整理します。"),
                choice("b", "`@SpringBootApplication`は`@Configuration`と重複して使えない", misconception: "@SpringBootApplicationの構成を誤解",
                       explanation: "`@SpringBootApplication`は`@Configuration`を内包しているため重複はエラーにはなりません。"),
                choice("c", "Mavenのmainクラス指定をpom.xmlで行えば解決する", misconception: "ビルド設定と実行時エラーを混同",
                       explanation: "pom.xmlの設定はJARのマニフェスト向けです。このエラーはSpring Bootのコンポーネントスキャン時の問題です。"),
                choice("d", "`@SpringBootApplication`の代わりに`@EnableAutoConfiguration`を使うと解決する", misconception: "アノテーション置き換えで解決するアンチパターン",
                       explanation: "複数クラスの存在が問題であり、アノテーションの変更では解決しません。")
            ],
            explanationRef: "explain-boot3-err3-startup-004",
            designIntent: "複数@SpringBootApplicationクラス起動エラーから一意性の原則を理解できる。"
        ),
        quiz(
            id: "boot3-err3-startup-005",
            level: .foundation,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["ddl-auto", "create-drop", "本番環境", "データ消失"],
            code: """
// application-prod.yml
spring:
  jpa:
    hibernate:
      ddl-auto: create-drop

// 本番再起動後のログ:
Hibernate: drop table if exists orders
Hibernate: drop table if exists users
Hibernate: create table orders (...)
Hibernate: create table users (...)

// 再起動後、全データが消失
""",
            question: "本番DBで再起動のたびにデータが消失する原因として正しいものはどれか？",
            choices: [
                choice("a", "`ddl-auto: create-drop`はアプリ起動時にテーブルを再作成し終了時に削除する。本番では`validate`またはFlywayを使うべき", correct: true,
                       explanation: "`create-drop`は開発・テスト用の設定です。本番では`validate`でスキーマ検証のみ行い、スキーマ変更はFlywayに委譲します。"),
                choice("b", "YAMLのインデントが間違っているためプロパティが無効になった", misconception: "YAML構文エラーとDDL設定を混同",
                       explanation: "インデントが正しくなければ設定が無視されてデフォルト値が使われます。ログにdrop/createが出ているため設定は反映されています。"),
                choice("c", "`validate`に変更するとHibernateはDDLを一切実行しなくなる", misconception: "validateの動作を誤解",
                       explanation: "`validate`はスキーマの整合性検証のみ行い、DDLは実行しません。これが本番推奨の設定です。"),
                choice("d", "FlywayとHibernateのDDL自動生成は同時に使えない", misconception: "Flywayとddl-autoの組み合わせを誤解",
                       explanation: "Flyway使用時は`ddl-auto: validate`または`none`にしてHibernateの自動DDLを無効化するのが標準パターンです。")
            ],
            explanationRef: "explain-boot3-err3-startup-005",
            designIntent: "create-dropによる本番データ消失問題を特定し適切なddl-auto設定を選択できる。"
        ),
        quiz(
            id: "boot3-err3-startup-006",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["ポート443", "root権限", "Permission denied"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Caused by: java.net.SocketException:
  Permission denied
  at java.net.PlainSocketImpl.socketBind(Native Method)
  at java.net.AbstractPlainSocketImpl.bind(...)

// application.yml:
server:
  port: 443
""",
            question: "ポート443でのSocket Permission deniedエラーの原因として正しいものはどれか？",
            choices: [
                choice("a", "Linuxでは1024未満のポートへのバインドにroot権限が必要。非rootユーザーでJavaアプリを実行しているため拒否された", correct: true,
                       explanation: "Unix/Linuxでは1024番未満のウェルノウンポートはroot権限が必要です。本番では8443等の高位ポートを使い、前段にリバースプロキシ（Nginx）でポート転送するのが一般的です。"),
                choice("b", "Spring Bootはポート443をHTTPS専用として予約している", misconception: "Spring Bootが443を予約していると誤解",
                       explanation: "Spring BootはポートをOSに委譲してバインドします。Spring Boot自体がポートを予約することはありません。"),
                choice("c", "`server.port=443`はapplication.propertiesにしか書けない", misconception: "YAMLとpropertiesの機能差を誤解",
                       explanation: "`application.yml`と`application.properties`は同等の設定ファイルです。この問題はOS権限の問題です。"),
                choice("d", "Java 17以降ではHTTPSポートのバインドがデフォルトで無効", misconception: "Java 17のセキュリティ変更を誤解",
                       explanation: "Java 17でHTTPSポートバインドが無効化されたという事実はありません。")
            ],
            explanationRef: "explain-boot3-err3-startup-006",
            designIntent: "ポート443バインド失敗からLinuxのwell-knownポートの権限制約を理解できる。"
        ),
        quiz(
            id: "boot3-err3-startup-007",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .errorReading,
            tags: ["@EnableJpaRepositories", "カスタムパッケージ", "NoSuchBeanDefinitionException"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

org.springframework.beans.factory.NoSuchBeanDefinitionException:
  No qualifying bean of type
  'com.example.infra.db.UserRepository' available

// プロジェクト構造:
// com.example.Application (起動クラス)
// com.example.infra.db.UserRepository (Repository)
""",
            question: "Repositoryが見つからないエラーの原因として最も可能性が高いものはどれか？",
            choices: [
                choice("a", "起動クラス`com.example.Application`のコンポーネントスキャン範囲外のパッケージにRepositoryがある場合、`@EnableJpaRepositories(basePackages=...)`で明示的に指定する必要がある", correct: true,
                       explanation: "`@SpringBootApplication`はデフォルトでそのクラスと同パッケージ以下をスキャンします。`com.example.infra.db`がサブパッケージであれば通常スキャンされますが、別モジュールやスキャン除外設定がある場合は`@EnableJpaRepositories`で指定します。"),
                choice("b", "`UserRepository`に`@Repository`アノテーションが必要", misconception: "@Repository必須と誤解",
                       explanation: "Spring Data JPAの`JpaRepository`継承インタフェースは`@Repository`なしでBeanとして登録されます。"),
                choice("c", "`JpaRepository<User, Long>`のIDの型が間違っている", misconception: "ジェネリクス型エラーとBean未登録を混同",
                       explanation: "ジェネリクス型の不一致はコンパイルエラーまたは別の実行時エラーになります。"),
                choice("d", "Spring Boot 3.xではJPAリポジトリに`@Transactional`が必要", misconception: "@Transactional必須と誤解",
                       explanation: "Spring Data JPAのデフォルトメソッドはすでにトランザクション管理されています。")
            ],
            explanationRef: "explain-boot3-err3-startup-007",
            designIntent: "カスタムパッケージ構造でのJpaRepository未検出エラーから@EnableJpaRepositoriesの役割を理解できる。"
        ),
        quiz(
            id: "boot3-err3-startup-008",
            level: .practice,
            objective: "boot3-foundation-di",
            category: .errorReading,
            tags: ["BeanDefinitionParsingException", "@Bean", "重複定義"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

org.springframework.beans.factory.parsing
  .BeanDefinitionParsingException:
  Configuration problem:
  @Bean method 'dataSource' in
  'com.example.config.PrimaryDataSourceConfig'
  overridden by
  'com.example.config.LegacyDataSourceConfig'
  which is not marked as @Primary.
  Overriding is not allowed.
""",
            question: "このBeanDefinitionParsingExceptionの原因として正しいものはどれか？",
            choices: [
                choice("a", "2つの`@Configuration`クラスが同名`dataSource`の`@Bean`メソッドを定義しており、Bean定義の上書きが無効化されているため競合した", correct: true,
                       explanation: "Spring Boot 2.1以降はデフォルトでBean定義の上書きが禁止されています。一方のBeanを削除するか、`@Primary`で優先度を設定するか、名前を変えて`@Qualifier`で解決します。"),
                choice("b", "`@Bean`メソッドのアクセス修飾子がpublicでなければならない", misconception: "アクセス修飾子の制約と重複定義を混同",
                       explanation: "`@Bean`メソッドはpackage-privateでも動作します。このエラーはBean名の重複です。"),
                choice("c", "`@Configuration`クラスに`@ComponentScan`が付いていない", misconception: "@ComponentScanの有無と@Bean競合を混同",
                       explanation: "`@Configuration`クラスの`@Bean`は`@ComponentScan`不要で登録されます。"),
                choice("d", "Spring BootではDataSourceのBeanを手動定義できない", misconception: "DataSourceのカスタム定義の制限を誤解",
                       explanation: "DataSourceを手動定義することは一般的です。問題はBean名の重複です。")
            ],
            explanationRef: "explain-boot3-err3-startup-008",
            designIntent: "同名@Bean重複定義によるBeanDefinitionParsingExceptionを特定し解消できる。"
        ),
        quiz(
            id: "boot3-err3-startup-009",
            level: .practice,
            objective: "boot3-foundation-config",
            category: .errorReading,
            tags: ["@Value", "デフォルト値", "プロパティファイル未存在"],
            code: """
// コード
@Value("${app.api.key:default-key}")
private String apiKey;

// 起動ログ
INFO: Using default value for 'app.api.key': 'default-key'
// 実行時: 全APIコールが401 Unauthorizedで失敗

// application.yml が src/main/resources ではなく
// src/main/resources/config/ に配置されている
""",
            question: "APIキーがデフォルト値になってしまう原因として正しいものはどれか？",
            choices: [
                choice("a", "`application.yml`がSpring Bootのデフォルト検索パスに存在しないため、プロパティファイルが読み込まれずデフォルト値`default-key`が使われている", correct: true,
                       explanation: "Spring Bootはデフォルトで`classpath:application.yml`を読みます。`src/main/resources/config/`も検索パスですが、`config/`下のファイルが優先されるケースもあります。ファイルパスと`spring.config.location`を確認します。"),
                choice("b", "`${app.api.key:default-key}`の構文はYAMLでは使用できない", misconception: "@ValueのSpEL構文をYAMLと混同",
                       explanation: "`@Value`のデフォルト値構文はYAML/properties両方で使用できます。"),
                choice("c", "`@Value`でデフォルト値を指定すると常にデフォルト値が使われる", misconception: "@Valueのデフォルト値の動作を誤解",
                       explanation: "デフォルト値は該当プロパティが未定義の場合にのみ使われます。プロパティが読み込まれれば正しい値になります。"),
                choice("d", "Spring Boot 3.xでは`@Value`のデフォルト値機能が廃止された", misconception: "Spring Boot 3.xの変更を誤解",
                       explanation: "`@Value`のデフォルト値機能はSpring Boot 3.xでも有効です。")
            ],
            explanationRef: "explain-boot3-err3-startup-009",
            designIntent: "@Valueデフォルト値が使われる状況からプロパティファイルの読み込みパスの問題を特定できる。"
        ),
        quiz(
            id: "boot3-err3-startup-010",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .errorReading,
            tags: ["Actuator", "管理ポート", "ポート競合"],
            code: """
***************************
APPLICATION FAILED TO START
***************************

Caused by: org.springframework.boot.web.server
  .PortInUseException:
  Web server failed to start. Port 8080 was already in use.

// application.yml:
management:
  server:
    port: 8080
server:
  port: 8080
""",
            question: "このポート競合エラーの原因として正しいものはどれか？",
            choices: [
                choice("a", "`management.server.port`とメインの`server.port`に同じポート8080を設定しているため、2つのサーバーが同一ポートにバインドしようとして競合した", correct: true,
                       explanation: "`management.server.port`を指定するとActuator用の別のサーブレットコンテナが起動します。同じポートを指定すると競合します。別ポート（例：8081）を指定するか、`management.server.port`を削除してデフォルト（同一ポート）にします。"),
                choice("b", "他のプロセスがポート8080を使用している", misconception: "外部プロセス競合と設定誤りを混同",
                       explanation: "外部プロセスが原因なら`lsof -i :8080`で確認できます。ただしこのケースはActuator管理ポートの設定誤りが原因です。"),
                choice("c", "Actuatorと通常のAPIは同一ポートで共存できない", misconception: "Actuatorの共存制限を誤解",
                       explanation: "`management.server.port`を指定しなければActuatorは通常のサーバーポートで動作します。"),
                choice("d", "`spring-boot-starter-actuator`を削除すれば起動できる", misconception: "Actuatorの削除で解決するアンチパターン",
                       explanation: "Actuatorは有用なツールです。ポート設定を修正するのが正しい対処です。")
            ],
            explanationRef: "explain-boot3-err3-startup-010",
            designIntent: "Actuator管理ポート競合エラーからmanagement.server.portの設定ミスを特定できる。"
        ),
    ]

    // MARK: - ランタイムエラー
    private static let err3Runtime: [Quiz] = [
        quiz(
            id: "boot3-err3-runtime-001",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["ConcurrentModificationException", "List", "反復処理"],
            code: """
java.util.ConcurrentModificationException
  at java.util.ArrayList$Itr.checkForComodification(ArrayList.java:911)
  at java.util.ArrayList$Itr.next(ArrayList.java:861)
  at com.example.service.OrderService
    .removeExpiredOrders(OrderService.java:45)

// 問題のコード:
for (Order order : orders) {
    if (order.isExpired()) {
        orders.remove(order); // ← ここ
    }
}
""",
            question: "このConcurrentModificationExceptionの原因として正しいものはどれか？",
            choices: [
                choice("a", "拡張for文での反復中に同じListに対してremove操作を行ったため、イテレータが変更を検出して例外を投げた", correct: true,
                       explanation: "`ArrayList`のイテレータは変更カウンタ（modCount）で変更を検出します。`Iterator.remove()`、`removeIf()`、またはStreamの`filter()`を使って安全に削除します。"),
                choice("b", "マルチスレッド環境で複数スレッドが同時にリストを操作した", misconception: "並行スレッド問題と同一スレッド反復削除を混同",
                       explanation: "このケースは単一スレッドでの反復中の変更が原因です。マルチスレッドの場合は`CopyOnWriteArrayList`を使います。"),
                choice("c", "`orders`リストがnullである", misconception: "NullPointerExceptionとの混同",
                       explanation: "`orders`がnullなら`NullPointerException`が発生します。"),
                choice("d", "`Order.isExpired()`がRuntimeExceptionを投げている", misconception: "例外の発生箇所を誤解",
                       explanation: "スタックトレースはArrayListのイテレータ内部を示しており、`isExpired()`メソッドが問題ではありません。")
            ],
            explanationRef: "explain-boot3-err3-runtime-001",
            designIntent: "反復中のList変更によるConcurrentModificationExceptionを特定しremoveIfで解決できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-002",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["StackOverflowError", "Lombok", "@ToString", "循環参照"],
            code: """
java.lang.StackOverflowError
  at com.example.model.Order.toString(Order.java)
  at com.example.model.Customer.toString(Customer.java)
  at com.example.model.Order.toString(Order.java)
  at com.example.model.Customer.toString(Customer.java)
  ...（繰り返し）

// エンティティ定義:
@ToString
@Entity
class Order {
    @ManyToOne
    Customer customer; // CustomerもOrderへ@OneToMany
}
""",
            question: "LombokによるStackOverflowErrorの原因として正しいものはどれか？",
            choices: [
                choice("a", "Lombokの`@ToString`が双方向関連のエンティティで相互にtoStringを呼び合い無限再帰になった。`@ToString(exclude=\"customer\")`または`@ToString.Exclude`で関連フィールドを除外する", correct: true,
                       explanation: "`@ToString`は全フィールドを含めるため、双方向関連では無限再帰が発生します。`@ToString(exclude={\"orders\"})`で循環する側のフィールドを除外します。"),
                choice("b", "LombokはSpring Bootのエンティティクラスに使用できない", misconception: "LombokとJPAの組み合わせを誤解",
                       explanation: "LombokはJPAエンティティで広く使われますが、双方向関連でのtoStringに注意が必要です。"),
                choice("c", "`@ManyToOne`関連はtoStringに含めることができない", misconception: "JPA関連とLombokの制約を誤解",
                       explanation: "技術的には含めることができますが、双方向の場合に循環するため除外が推奨です。"),
                choice("d", "スタックサイズをJVMオプションで増やせば解決する", misconception: "スタックサイズ増加で根本解決できると誤解",
                       explanation: "スタックサイズ増加は一時的な回避策で根本解決ではありません。循環参照自体を排除します。")
            ],
            explanationRef: "explain-boot3-err3-runtime-002",
            designIntent: "Lombok@ToStringの双方向関連による無限再帰StackOverflowErrorを特定し@ToString.Excludeで解決できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-003",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["ClassCastException", "キャッシュ", "ジェネリクス型"],
            code: """
java.lang.ClassCastException:
  class java.lang.String cannot be cast to
  class com.example.dto.UserDto
  (java.lang.String is in module java.base of loader 'bootstrap';
   com.example.dto.UserDto is in unnamed module of loader 'app')

  at com.example.service.UserService
    .getCachedUser(UserService.java:42)

// 問題のコード:
@Cacheable("users")
public UserDto getCachedUser(Long id) { ... }
// 以前: 同じキャッシュ名で String を返すメソッドが存在していた
""",
            question: "このClassCastExceptionの原因として正しいものはどれか？",
            choices: [
                choice("a", "キャッシュに以前保存されたString型の値が残っており、`UserDto`への型キャストに失敗した。キャッシュをクリアするか、キャッシュキー名を変更する", correct: true,
                       explanation: "インメモリキャッシュやRedisはJavaの型情報を保証しません。戻り型が変わった場合はキャッシュをクリアするか、別のキャッシュ名を使います。"),
                choice("b", "`UserDto`に引数なしコンストラクタが必要", misconception: "デシリアライズ要件と型キャスト例外を混同",
                       explanation: "Redisシリアライズではデフォルトコンストラクタが必要な場合がありますが、このエラーはString→UserDtoのキャスト失敗です。"),
                choice("c", "`@Cacheable`はプリミティブ型の戻り値にしか使えない", misconception: "@Cacheableの型制限を誤解",
                       explanation: "`@Cacheable`はあらゆるオブジェクト型に使用できます。"),
                choice("d", "Springのバージョンアップ後に`@Cacheable`の動作が変わった", misconception: "バージョン変更で発生したと誤解",
                       explanation: "バージョン変更ではなく、同一キャッシュ名に異なる型の値が混在していることが原因です。")
            ],
            explanationRef: "explain-boot3-err3-runtime-003",
            designIntent: "キャッシュ内の型不一致によるClassCastExceptionを特定しキャッシュクリアで解決できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-004",
            level: .practice,
            objective: "boot3-foundation-di",
            category: .errorReading,
            tags: ["IllegalStateException", "ApplicationContext", "手動コンテキスト生成"],
            code: """
java.lang.IllegalStateException:
  ApplicationContext has not been refreshed yet

  at org.springframework.context
    .support.AbstractApplicationContext.assertBeanFactoryActive(...)
  at org.springframework.context
    .support.AbstractApplicationContext.getBean(...)
  at com.example.util.LegacyBeanLookup.getService(LegacyBeanLookup.java:23)

// 問題のコード:
AnnotationConfigApplicationContext ctx =
    new AnnotationConfigApplicationContext();
ctx.register(AppConfig.class);
// ctx.refresh() を呼び忘れ
Object svc = ctx.getBean("orderService");
""",
            question: "このIllegalStateExceptionの原因として正しいものはどれか？",
            choices: [
                choice("a", "`AnnotationConfigApplicationContext`を手動生成後に`refresh()`を呼ばずにBeanを取得しようとしたため、コンテキストが未初期化状態だった", correct: true,
                       explanation: "`register()`はBeanの登録だけを行い、`refresh()`でコンテキストが初期化されます。Spring Bootを使えば`SpringApplication.run()`がこれを自動で行います。"),
                choice("b", "`AppConfig`クラスに`@Configuration`が付いていない", misconception: "設定クラスの問題と手動コンテキスト初期化を混同",
                       explanation: "`@Configuration`がなければ別のエラーが出ます。このエラーは`refresh()`の未呼び出しです。"),
                choice("c", "`AnnotationConfigApplicationContext`はSpring Boot 3.xで廃止された", misconception: "クラスの廃止を誤解",
                       explanation: "`AnnotationConfigApplicationContext`はSpring Boot 3.xでも使用可能です。"),
                choice("d", "Beanの名前`orderService`が間違っている", misconception: "NoSuchBeanDefinitionExceptionとIllegalStateExceptionを混同",
                       explanation: "Bean名が間違っていれば`NoSuchBeanDefinitionException`が出ます。このエラーはコンテキスト未初期化です。")
            ],
            explanationRef: "explain-boot3-err3-runtime-004",
            designIntent: "手動ApplicationContextでのrefresh()未呼び出しによるIllegalStateExceptionを特定できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-005",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["EntityNotFoundException", "EmptyResultDataAccessException", "deleteById"],
            code: """
// Spring Data JPA 2.x (旧):
userRepository.deleteById(999L);
// → EmptyResultDataAccessException: No class User entity with id 999 exists!

// Spring Data JPA 3.x (新):
userRepository.deleteById(999L);
// → jakarta.persistence.EntityNotFoundException:
//   Unable to find com.example.User with id 999
""",
            question: "存在しないIDに対して`deleteById()`を呼んだ際の例外の扱いとして正しいものはどれか？",
            choices: [
                choice("a", "Spring Data JPA 3.xでは存在しないIDの`deleteById()`が`EntityNotFoundException`になった。削除前に`existsById()`で確認するか例外をキャッチして処理する", correct: true,
                       explanation: "バージョンによって例外型が異なります。サービス層では`deleteById()`の前に存在チェックを行うか、`findById().ifPresent(repo::delete)`パターンを使うと安全です。"),
                choice("b", "`deleteById()`は存在しないIDを無視して何もしない", misconception: "deleteByIdの動作を誤解",
                       explanation: "Spring Data JPAの`deleteById()`は対象が存在しない場合に例外を投げます。"),
                choice("c", "`@Transactional`を付ければ例外が発生しなくなる", misconception: "@Transactionalが例外を抑制すると誤解",
                       explanation: "`@Transactional`はトランザクション管理です。存在しないエンティティへのアクセスには別の対処が必要です。"),
                choice("d", "Hibernate 6.xでは`delete`操作のSQL実行は行われない", misconception: "Hibernateの動作を誤解",
                       explanation: "Hibernateは削除前にエンティティの存在確認（SELECT）を行います。")
            ],
            explanationRef: "explain-boot3-err3-runtime-005",
            designIntent: "deleteByIdの例外型の変化を理解し存在確認パターンを選択できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-006",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["StaleObjectStateException", "楽観ロック", "@Version", "長時間処理"],
            code: """
org.hibernate.StaleObjectStateException:
  Row was updated or deleted by another transaction
  (or unsaved-value mapping was incorrect):
  [com.example.entity.Reservation#101]

  at com.example.service.ReservationService
    .confirm(ReservationService.java:78)

// シナリオ: ユーザーが予約フォームを5分間放置後に送信
""",
            question: "このStaleObjectStateExceptionが発生するシナリオとして正しいものはどれか？",
            choices: [
                choice("a", "フォーム表示時に取得したエンティティのバージョン番号が、5分後の送信時点でDBのバージョンと一致せず楽観ロックが失敗した。UIでの再試行案内とリトライ処理を実装する", correct: true,
                       explanation: "楽観ロックは長時間操作の後の更新競合検出に有効です。ユーザーへの「別の更新が入りました。再読み込みしてください」メッセージと、必要に応じて`@Retryable`でのリトライを実装します。"),
                choice("b", "DBの行ロックがタイムアウトした", misconception: "LockTimeoutExceptionとStaleObjectStateExceptionを混同",
                       explanation: "ロックタイムアウトは`LockTimeoutException`です。このエラーは楽観ロック（@Version）の競合検出です。"),
                choice("c", "5分以上のトランザクションは自動でロールバックされる", misconception: "トランザクションタイムアウトと楽観ロック失敗を混同",
                       explanation: "トランザクションタイムアウトは設定可能ですが、このシナリオは長時間の「画面放置」後の再送信です。"),
                choice("d", "`@Version`フィールドの型がLongである必要がある", misconception: "型制限を誤解",
                       explanation: "`@Version`はInt、Long、Timestamp型に対応しています。エラーはバージョン不一致の競合検出です。")
            ],
            explanationRef: "explain-boot3-err3-runtime-006",
            designIntent: "長時間フォーム操作後のStaleObjectStateExceptionから楽観ロックの競合シナリオを理解できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-007",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["CannotCreateTransactionException", "DB接続拒否", "ランタイム"],
            code: """
org.springframework.transaction.CannotCreateTransactionException:
  Could not open JPA EntityManager for transaction;
  nested exception is org.hibernate.exception
  .JDBCConnectionException: Unable to acquire JDBC Connection

Caused by: com.mysql.cj.jdbc.exceptions.CommunicationsException:
  Communications link failure
  The last packet sent successfully to the server was 0 milliseconds ago.
  The driver has not received any packets from the server.
""",
            question: "アプリ起動後しばらくしてからこのエラーが発生する原因として最も可能性が高いものはどれか？",
            choices: [
                choice("a", "DBサーバーがダウンしたかネットワーク断絶が発生し、HikariCPプール内のコネクションが無効になった", correct: true,
                       explanation: "起動後に発生するDB接続失敗は環境の変化（DB再起動、ファイアウォール、接続タイムアウト）が原因です。`spring.datasource.hikari.connection-test-query`や`keepaliveTime`を設定してコネクション検証を行います。"),
                choice("b", "application.ymlのDB URLが間違っている", misconception: "起動時エラーと実行時エラーを混同",
                       explanation: "URL設定が間違っていれば起動時にエラーが出ます。起動後に発生するエラーは接続状態の変化が原因です。"),
                choice("c", "`@Transactional`のタイムアウト設定が短すぎる", misconception: "トランザクションタイムアウトとJDBC接続失敗を混同",
                       explanation: "タイムアウトは`QueryTimeoutException`や`TransactionTimedOutException`で出ます。"),
                choice("d", "HikariCPの`maximum-pool-size`が0に設定されている", misconception: "プールサイズ0と接続失敗を混同",
                       explanation: "プールサイズ0は起動時に設定エラーになります。このエラーはネットワークレベルの接続失敗です。")
            ],
            explanationRef: "explain-boot3-err3-runtime-007",
            designIntent: "実行時のDB接続失敗エラーからネットワーク断絶とHikariCPの接続検証設定の必要性を理解できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-008",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .errorReading,
            tags: ["Lombok", "NoSuchMethodException", "no-arg constructor", "JPA"],
            code: """
java.lang.RuntimeException:
  No default constructor for entity:
  com.example.entity.Product

Caused by: org.hibernate.InstantiationException:
  No default constructor for entity: com.example.entity.Product

// エンティティ定義:
@Entity
@AllArgsConstructor  // 全引数コンストラクタのみ生成
public class Product {
    @Id Long id;
    String name;
    BigDecimal price;
}
""",
            question: "このInstantiationExceptionの原因として正しいものはどれか？",
            choices: [
                choice("a", "LombokのAccording to `@AllArgsConstructor`のみ付けているため引数なしコンストラクタが生成されず、Hibernateがエンティティをインスタンス化できない", correct: true,
                       explanation: "JPAはリフレクションでエンティティを生成するため引数なしコンストラクタが必須です。`@NoArgsConstructor`を追加するか、`@AllArgsConstructor`と`@NoArgsConstructor`を併用します。"),
                choice("b", "`@Entity`に`name`属性が必要", misconception: "@Entityのname属性の必要性を誤解",
                       explanation: "`@Entity`の`name`属性は省略可能です。エラーはコンストラクタの問題です。"),
                choice("c", "BigDecimal型はJPAでサポートされていない", misconception: "型サポートの誤解",
                       explanation: "`BigDecimal`はJPAでサポートされています。"),
                choice("d", "フィールドに`private`修飾子がないためアクセスできない", misconception: "フィールドのアクセス修飾子とコンストラクタを混同",
                       explanation: "JPAはフィールドにリフレクションでアクセスできますが、コンストラクタが優先されます。問題は引数なしコンストラクタの欠如です。")
            ],
            explanationRef: "explain-boot3-err3-runtime-008",
            designIntent: "Lombok@AllArgsConstructorのみ使用時のJPA引数なしコンストラクタ欠落エラーを特定できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-009",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["JpaSystemException", "cascade remove", "非所有側"],
            code: """
org.springframework.orm.jpa.JpaSystemException:
  A collection with cascade=\"all-delete-orphan\" was no longer
  referenced by the owning entity instance

  at com.example.service.DepartmentService
    .removeEmployee(DepartmentService.java:55)

// 問題のコード:
Department dept = deptRepo.findById(1L).get();
dept.setEmployees(new ArrayList<>()); // ← リスト置き換え
deptRepo.save(dept);
""",
            question: "このJpaSystemExceptionの原因として正しいものはどれか？",
            choices: [
                choice("a", "`CascadeType.ALL`と`orphanRemoval=true`が付いたコレクションを新しいListインスタンスに差し替えたため、Hibernateが管理外とみなしてエラーになった。`clear()`で中身だけを消去する", correct: true,
                       explanation: "orphanRemovalが有効なコレクションは`new ArrayList<>()`に差し替えてはいけません。`dept.getEmployees().clear()`のように既存のコレクションインスタンスを操作します。"),
                choice("b", "`@OneToMany`には`mappedBy`が必須", misconception: "mappedByの必須化と管理外コレクション問題を混同",
                       explanation: "`mappedBy`は双方向関連で使いますが省略可能です。このエラーはコレクション参照の差し替えです。"),
                choice("c", "`deptRepo.save()`の代わりに`deptRepo.saveAndFlush()`を使う必要がある", misconception: "save/saveAndFlushの違いと本エラーを混同",
                       explanation: "`save()`と`saveAndFlush()`の違いはフラッシュタイミングです。コレクション差し替えが根本原因です。"),
                choice("d", "`CascadeType.ALL`は`CascadeType.REMOVE`を含まない", misconception: "CascadeTypeの内容を誤解",
                       explanation: "`CascadeType.ALL`は`PERSIST`、`MERGE`、`REMOVE`、`REFRESH`、`DETACH`を含みます。")
            ],
            explanationRef: "explain-boot3-err3-runtime-009",
            designIntent: "orphanRemoval付きコレクションの差し替えによるJpaSystemExceptionを特定しclear()で解決できる。"
        ),
        quiz(
            id: "boot3-err3-runtime-010",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["TransactionSystemException", "コミット失敗", "@Transactional"],
            code: """
org.springframework.transaction.TransactionSystemException:
  Could not commit JPA transaction;
  nested exception is
  jakarta.persistence.RollbackException:
  Error while committing the transaction

Caused by: jakarta.validation.ConstraintViolationException:
  Validation failed for classes [com.example.entity.Order]
  during persist time for groups [jakarta.validation.groups.Default]
  List of constraint violations: [
    ConstraintViolationImpl{message='must not be blank',
    path=orderNumber}
  ]
""",
            question: "このTransactionSystemExceptionの根本原因として正しいものはどれか？",
            choices: [
                choice("a", "トランザクションコミット時にBean Validationが実行され`orderNumber`フィールドの`@NotBlank`制約違反が検出された。`orderNumber`に値を設定するか、入力バリデーションをサービス層で事前に行う", correct: true,
                       explanation: "`@NotBlank`などのBean ValidationはHibernateがflushする際に検証されます。`TransactionSystemException`はトランザクション自体の問題ではなく、コミット前の検証失敗がネストされています。"),
                choice("b", "トランザクションの伝播設定が`REQUIRES_NEW`のため競合した", misconception: "トランザクション伝播とコミット失敗を混同",
                       explanation: "伝播設定の問題なら別のエラーメッセージが出ます。ネストされた原因を確認するとConstraintViolationExceptionです。"),
                choice("c", "DBのコネクションが切断された", misconception: "DB接続失敗とバリデーション失敗を混同",
                       explanation: "DB接続切断は`CommunicationsException`や`JDBCConnectionException`で出ます。"),
                choice("d", "`@Transactional`の`readOnly=true`が設定されているため書き込みが失敗した", misconception: "readOnly制限とバリデーション失敗を混同",
                       explanation: "`readOnly=true`でも技術的には書き込みコマンドを出せますがDBで拒否される場合があります。このエラーはバリデーション違反です。")
            ],
            explanationRef: "explain-boot3-err3-runtime-010",
            designIntent: "TransactionSystemExceptionのネストされた原因からBean Validationのコミット時検証失敗を特定できる。"
        ),
    ]

    // MARK: - パフォーマンス / タイムアウト警告
    private static let err3Performance: [Quiz] = [
        quiz(
            id: "boot3-err3-perf-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .errorReading,
            tags: ["HikariCP", "コネクションリーク", "Apparent connection leak"],
            code: """
WARN  com.zaxxer.hikari.pool.ProxyLeakTask:
  Apparent connection leak detected for
  connection com.mysql.cj.jdbc.ConnectionImpl@3f4a5b6c
  on thread http-nio-8080-exec-3
  Stack trace follows:
    at com.example.service.ReportService
      .generateReport(ReportService.java:88)

// leakDetectionThreshold: 2000ms
""",
            question: "「Apparent connection leak」警告の原因として最も可能性が高いものはどれか？",
            choices: [
                choice("a", "`generateReport`メソッドがDBコネクションを取得後2秒以上返却していない。長時間クエリの最適化、または処理の分割でコネクション保持時間を短縮する", correct: true,
                       explanation: "`leakDetectionThreshold`を超えてコネクションが保持されると警告が出ます。スタックトレースの箇所でロジックを見直し、クエリを最適化するか`@Transactional`スコープを狭くします。"),
                choice("b", "コネクションプールのサイズが小さすぎる", misconception: "プールサイズとリーク警告を混同",
                       explanation: "プールサイズ不足は`Connection is not available`エラーになります。リーク警告はコネクション保持時間の問題です。"),
                choice("c", "`leakDetectionThreshold`を0に設定すると警告が消える", misconception: "警告を無効化することで解決するアンチパターン",
                       explanation: "警告を無効化してもコネクションリークは解消されません。根本原因を修正します。"),
                choice("d", "MySQLドライバのバージョンが古い", misconception: "JDBCドライバとリーク検出を混同",
                       explanation: "リーク検出はHikariCPが独自に行います。ドライバのバージョンは関係ありません。")
            ],
            explanationRef: "explain-boot3-err3-perf-001",
            designIntent: "HikariCPのコネクションリーク警告からコネクション保持時間の問題を特定できる。"
        ),
        quiz(
            id: "boot3-err3-perf-002",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["スロークエリ", "タイムアウト", "インデックス不足"],
            code: """
WARN  o.s.web.servlet.DispatcherServlet:
  Resolved [org.springframework.web.context.request
  .async.AsyncRequestTimeoutException]

// アプリケーションログ:
WARN  c.e.service.OrderService:
  Method 'findOrdersByDateRange' took 12543ms to execute.
  Expected: < 1000ms

// 実行されたクエリ:
SELECT * FROM orders
WHERE created_at BETWEEN ? AND ?
ORDER BY created_at DESC

// ordersテーブル: 500万件, created_atにインデックスなし
""",
            question: "クエリが12秒かかる原因と対処として正しいものはどれか？",
            choices: [
                choice("a", "`created_at`カラムにインデックスがなく500万件のフルスキャンが発生している。`CREATE INDEX idx_orders_created_at ON orders(created_at)`でインデックスを追加する", correct: true,
                       explanation: "大量データの日付範囲検索にはインデックスが必須です。FlywayのマイグレーションでDDLを追加し、`EXPLAIN`でクエリプランを確認します。"),
                choice("b", "`SELECT *`を`SELECT id`に変更すれば速くなる", misconception: "SELECT *の影響を過大評価",
                       explanation: "インデックスなしのフルスキャンが主因であり、SELECT * vs SELECT idはインデックスがある場合にカバリングインデックスとして有効ですが、根本対処はインデックス追加です。"),
                choice("c", "Spring Bootのタイムアウト設定を30秒に延ばす", misconception: "タイムアウト延長で根本解決するアンチパターン",
                       explanation: "タイムアウトを伸ばしてもクエリは遅いままです。インデックスの追加が根本解決です。"),
                choice("d", "HikariCPのスレッドプールが詰まっている", misconception: "スレッドプールとクエリ遅延を混同",
                       explanation: "1件のクエリが12秒かかっているのはフルスキャンが原因です。スレッドプールの問題ではありません。")
            ],
            explanationRef: "explain-boot3-err3-perf-002",
            designIntent: "スロークエリ警告からインデックス不足を特定しマイグレーションで解決できる。"
        ),
        quiz(
            id: "boot3-err3-perf-003",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .errorReading,
            tags: ["Hibernate", "HHH90000025", "コレクションフェッチ", "ページング"],
            code: """
WARN  o.h.h.i.ast.QueryTranslatorImpl:
  HHH90000025: FirstResult/maxResults specified with collection
  fetch; applying in memory!

// クエリ:
@Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.userId = :uid")
Page<Order> findByUserId(@Param("uid") Long uid, Pageable pageable);
""",
            question: "このHibernate警告が示す問題として正しいものはどれか？",
            choices: [
                choice("a", "コレクションの`JOIN FETCH`とページング（LIMIT/OFFSET）を同時に使うとHibernateがSQL上でページングできず全件をメモリに読み込んでからページングする。`countQuery`を分離するか2回のクエリに分割する", correct: true,
                       explanation: "JOIN FETCHでコレクションを展開するとレコード数が増え、SQLレベルのLIMITは期待通りに動きません。回避策は`@BatchSize`か、まずIDのみページングして次にコレクションをロードする2ステップクエリです。"),
                choice("b", "Pageableの`size`が大きすぎる", misconception: "ページサイズとメモリフェッチ警告を混同",
                       explanation: "ページサイズの大小は無関係です。JOIN FETCHとページングの組み合わせが問題です。"),
                choice("c", "`@Query`の代わりにメソッド名クエリを使えば解決する", misconception: "クエリ記述方法と実行計画を混同",
                       explanation: "メソッド名クエリでも同じJOIN FETCHを行えば同じ問題が発生します。"),
                choice("d", "この警告は無視しても機能的に問題はない", misconception: "パフォーマンス問題を軽視",
                       explanation: "全件メモリロードは大量データ時にOOMや重大なパフォーマンス劣化を引き起こします。")
            ],
            explanationRef: "explain-boot3-err3-perf-003",
            designIntent: "HHH90000025警告からJOIN FETCHとページングの組み合わせ問題を理解できる。"
        ),
        quiz(
            id: "boot3-err3-perf-004",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["バッチ更新", "stale @Version", "StaleStateException"],
            code: """
org.hibernate.StaleStateException:
  Batch update returned unexpected row count from update
  [0]; actual row count: 0; expected: 1;
  statement: update product set price=?, version=?+1
  where id=? and version=?

  at com.example.service.BulkPriceUpdateService
    .updatePrices(BulkPriceUpdateService.java:67)
""",
            question: "バッチ更新でrow count 0が返るエラーの原因として正しいものはどれか？",
            choices: [
                choice("a", "UPDATE文の`WHERE id=? AND version=?`条件に一致するレコードが見つからなかった。バッチ処理開始後に別のトランザクションがバージョンを更新したため", correct: true,
                       explanation: "楽観ロックのバッチ更新では更新行数0は競合を意味します。バッチ処理前に最新バージョンを再取得するか、PESSIMISTIC_WRITEロックを使用します。"),
                choice("b", "バッチサイズ設定が大きすぎてSQLが失敗した", misconception: "バッチサイズとStaleStateExceptionを混同",
                       explanation: "バッチサイズは行数制限です。このエラーは更新条件不一致（楽観ロック）です。"),
                choice("c", "Hibernateのバッチ更新はIDのみでWHERE条件を作るため", misconception: "Hibernateのバッチ更新の動作を誤解",
                       explanation: "`@Version`が付いている場合、HibernateはWHERE句にバージョンカラムを含めます。"),
                choice("d", "DBのauto_commitが有効なためトランザクションが無効", misconception: "auto_commitと楽観ロック競合を混同",
                       explanation: "auto_commitの設定は関係ありません。楽観ロックの競合検出です。")
            ],
            explanationRef: "explain-boot3-err3-perf-004",
            designIntent: "バッチ更新のStaleStateExceptionから楽観ロック競合を特定できる。"
        ),
        quiz(
            id: "boot3-err3-perf-005",
            level: .practice,
            objective: "boot3-practice-security",
            category: .errorReading,
            tags: ["UserDetailsService", "キャッシュなし", "DBアクセス過多"],
            code: """
// Spring Security アクセスログ (1リクエスト中):
DEBUG o.s.s.core.userdetails.UserDetailsService:
  loadUserByUsername called: user@example.com
DEBUG o.s.s.core.userdetails.UserDetailsService:
  loadUserByUsername called: user@example.com
DEBUG o.s.s.core.userdetails.UserDetailsService:
  loadUserByUsername called: user@example.com
// ← 1リクエストで10回以上呼ばれている

// HikariCPログ: 頻繁なコネクション取得でスループット低下
""",
            question: "1リクエストでloadUserByUsernameが複数回呼ばれる原因として正しいものはどれか？",
            choices: [
                choice("a", "`UserDetailsService`にキャッシュが設定されていないため、リクエスト内の認可チェックごとにDBへSELECTが実行されている。`@Cacheable`またはSpring Security Cache Decoratorを使う", correct: true,
                       explanation: "メソッドセキュリティ（`@PreAuthorize`等）が複数箇所にあると認証情報の再取得が繰り返されます。`UserDetailsService`に`@Cacheable`を付けてセッションまたはリクエストスコープでキャッシュします。"),
                choice("b", "`@EnableMethodSecurity`を削除すればDBアクセスが減る", misconception: "メソッドセキュリティ削除で解決するアンチパターン",
                       explanation: "メソッドセキュリティを削除するとセキュリティが弱くなります。キャッシュを設定するのが正しい対処です。"),
                choice("c", "Spring Securityのフィルターチェーンに不要なフィルターが含まれている", misconception: "フィルター数とloadUserByUsernameの呼び出しを混同",
                       explanation: "フィルター数が原因でloadUserByUsernameが複数回呼ばれることはありません。認可チェックの頻度が問題です。"),
                choice("d", "JWTトークンの有効期限が短すぎて再認証が発生している", misconception: "JWT再認証とUserDetailsService再呼び出しを混同",
                       explanation: "JWT有効期限切れなら401エラーになります。このケースはリクエスト内での複数回呼び出しです。")
            ],
            explanationRef: "explain-boot3-err3-perf-005",
            designIntent: "UserDetailsServiceの過剰なDB呼び出しからキャッシュ未設定の問題を特定し@Cacheableで解決できる。"
        ),
        quiz(
            id: "boot3-err3-perf-006",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["@Cacheable", "同一Bean呼び出し", "プロキシ", "セルフインボケーション"],
            code: """
@Service
public class ProductService {

    @Cacheable("products")
    public Product findById(Long id) {
        return productRepo.findById(id).orElseThrow();
    }

    public List<Product> findMultiple(List<Long> ids) {
        return ids.stream()
            .map(this::findById) // ← 同一Beanからの呼び出し
            .collect(toList());
    }
}
// findMultipleを呼ぶとキャッシュが効かず毎回DBアクセスが発生
""",
            question: "`@Cacheable`が効かない原因として正しいものはどれか？",
            choices: [
                choice("a", "同一Bean内からのメソッド呼び出し（セルフインボケーション）はSpring AOPプロキシを通らないため`@Cacheable`が機能しない。`ApplicationContext`からBeanを取得するか、`findById`を別のBeanに移動する", correct: true,
                       explanation: "Spring AOPはプロキシベースのため、同一クラス内の`this.findById()`はプロキシをバイパスします。`@Transactional`も同様の問題があります。"),
                choice("b", "`@Cacheable`はvoidメソッドにしか効かない", misconception: "@Cacheableの対象メソッドを誤解",
                       explanation: "`@Cacheable`はvoidには使えません（キャッシュする値がないため）。戻り値があるメソッドに使います。"),
                choice("c", "キャッシュ名`products`がapplication.ymlに定義されていない", misconception: "キャッシュ名の定義必須を誤解",
                       explanation: "シンプルキャッシュ（ConcurrentMapCacheManager）はキャッシュ名の事前定義が不要です。セルフインボケーションが原因です。"),
                choice("d", "`@EnableCaching`がない場合はキャッシュが機能しない", misconception: "@EnableCaching不足と誤解",
                       explanation: "`@EnableCaching`がなければ全体的にキャッシュが機能しません。ただしこのケースはセルフインボケーションが問題です。")
            ],
            explanationRef: "explain-boot3-err3-perf-006",
            designIntent: "同一Bean内@Cacheableのセルフインボケーション問題からSpring AOPプロキシの仕組みを理解できる。"
        ),
        quiz(
            id: "boot3-err3-perf-007",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["@Async", "例外無視", "void戻り値"],
            code: """
@Service
public class NotificationService {

    @Async
    public void sendEmail(String to, String body) {
        emailClient.send(to, body); // ← 例外が発生しても呼び出し元に伝わらない
    }
}

// 呼び出し元のログ: 正常終了と表示されるがメールが届かない
// sendEmailの実行スレッドログ: 例外が出ているが握りつぶされている
""",
            question: "`@Async` voidメソッドの例外が握りつぶされる原因と対処として正しいものはどれか？",
            choices: [
                choice("a", "void戻り値の`@Async`メソッドで発生した例外はデフォルトで無視される。`AsyncUncaughtExceptionHandler`を実装して例外をログ出力・アラート送信する", correct: true,
                       explanation: "`Future`や`CompletableFuture`を返す`@Async`メソッドは呼び出し元で`get()`することで例外を取得できます。void戻り値の場合は`SimpleAsyncUncaughtExceptionHandler`が使われますがデフォルトはログのみです。"),
                choice("b", "`@Async`メソッドに`@Transactional`を付ければ例外が伝播する", misconception: "@Transactionalで@Async例外が伝播すると誤解",
                       explanation: "`@Transactional`はトランザクション管理です。別スレッドの例外伝播とは無関係です。"),
                choice("c", "`@EnableAsync`をMainクラスに付ければ例外がコンソールに表示される", misconception: "@EnableAsyncの機能を誤解",
                       explanation: "`@EnableAsync`は非同期実行の有効化のみを行います。例外ハンドリングは別設定です。"),
                choice("d", "void戻り値の代わりに`Future<Void>`を返せばよい", misconception: "Future<Void>で自動的に例外処理されると誤解",
                       explanation: "`Future<Void>`を返しても呼び出し元が`get()`を呼ばなければ例外は検出されません。`AsyncUncaughtExceptionHandler`が確実な方法です。")
            ],
            explanationRef: "explain-boot3-err3-perf-007",
            designIntent: "@Async voidメソッドの例外無視問題からAsyncUncaughtExceptionHandlerの実装必要性を理解できる。"
        ),
        quiz(
            id: "boot3-err3-perf-008",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .errorReading,
            tags: ["DataIntegrityViolationException", "@Transactional", "バルクインサート"],
            code: """
org.springframework.dao.DataIntegrityViolationException:
  could not execute batch;
  SQL [insert into audit_log (event, user_id, timestamp) values (?,?,?)];
  constraint [audit_log.user_id_fk];
  nested exception is
  org.hibernate.exception.ConstraintViolationException

  at com.example.service.AuditService
    .saveAllLogs(AuditService.java:44)

// saveAllLogsに@Transactionalなし
// 一部のレコードのみ挿入されている
""",
            question: "バルクインサートでDataIntegrityViolationExceptionが発生し一部のみ挿入される原因として正しいものはどれか？",
            choices: [
                choice("a", "`saveAllLogs`に`@Transactional`がないため、バッチ中に制約違反が発生しても途中までの挿入がコミットされてしまう。`@Transactional`を付けてバッチ全体を原子的に処理する", correct: true,
                       explanation: "トランザクションなしのバルクインサートは途中失敗で部分コミットになります。`@Transactional`を付けることで全成功または全ロールバックを保証します。"),
                choice("b", "外部キー制約は`@ManyToOne`で定義しなければ無視される", misconception: "JPAアノテーションとDB制約を混同",
                       explanation: "DB側の外部キー制約はJPAアノテーションに関わらず適用されます。"),
                choice("c", "`saveAll()`の代わりに`save()`をループで呼べば解決する", misconception: "saveAll vs saveのループで解決すると誤解",
                       explanation: "`save()`をループで呼んでも`@Transactional`がなければ同様に部分コミットが発生します。"),
                choice("d", "HibernateのバッチサイズをYAMLで設定すれば一括コミットされる", misconception: "バッチサイズがトランザクション境界を制御すると誤解",
                       explanation: "バッチサイズはSQL発行の最適化です。トランザクション境界は`@Transactional`で制御します。")
            ],
            explanationRef: "explain-boot3-err3-perf-008",
            designIntent: "@Transactional未設定によるバルクインサートの部分コミット問題を特定し解決できる。"
        ),
    ]

    // MARK: - インテグレーション / テストエラー
    private static let err3Integration: [Quiz] = [
        quiz(
            id: "boot3-err3-integration-001",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .errorReading,
            tags: ["@DirtiesContext", "テスト遅延", "コンテキスト再作成"],
            code: """
// テスト実行ログ:
INFO: Starting Spring application context...  // test1
INFO: Starting Spring application context...  // test2
INFO: Starting Spring application context...  // test3
INFO: Starting Spring application context...  // test4
// ...30クラス分のコンテキスト起動ログ

// 全テスト実行時間: 15分（通常は2分のはず）

// 各テストクラスに @DirtiesContext が付いている
""",
            question: "`@DirtiesContext`によってテストが遅くなる原因として正しいものはどれか？",
            choices: [
                choice("a", "`@DirtiesContext`はテスト後にSpring ApplicationContextを破棄して再作成させるため、クラスごとにコンテキスト起動コストが発生してテスト時間が大幅に増加した", correct: true,
                       explanation: "Spring Testはデフォルトでコンテキストをキャッシュします。`@DirtiesContext`はこれを無効化します。不要な`@DirtiesContext`を削除し、コンテキスト汚染は`@MockBean`や`@Sql`でのデータリセットで対処します。"),
                choice("b", "`@DirtiesContext`はメモリリークを防ぐための必須アノテーション", misconception: "@DirtiesContextの役割を誤解",
                       explanation: "`@DirtiesContext`はコンテキストを汚染するテスト後に使うオプションです。必須ではなく多用はアンチパターンです。"),
                choice("c", "テストの並列実行設定がないため逐次実行で時間がかかっている", misconception: "並列実行設定とコンテキスト再作成を混同",
                       explanation: "並列実行でも`@DirtiesContext`があれば都度コンテキスト再作成コストが発生します。"),
                choice("d", "`@SpringBootTest`の代わりに`@WebMvcTest`を使えば解決する", misconception: "@WebMvcTestへの変更で全問題が解決すると誤解",
                       explanation: "`@WebMvcTest`は軽量ですが、`@DirtiesContext`が付いていれば同様に再作成されます。")
            ],
            explanationRef: "explain-boot3-err3-integration-001",
            designIntent: "@DirtiesContextによるテスト速度低下の原因と適切な代替手段を理解できる。"
        ),
        quiz(
            id: "boot3-err3-integration-002",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .errorReading,
            tags: ["Testcontainers", "ContainerLaunchException", "Docker未起動"],
            code: """
org.testcontainers.containers.ContainerLaunchException:
  Timed out waiting for container port to open
  (localhost ports: [5432] should be listening)

Caused by: org.rnorth.ducttape.TimeoutException:
  Timeout waiting for result with value

// より詳細なエラー:
com.github.dockerjava.api.exception.DockerException:
  Could not connect to Docker daemon at 'unix:///var/run/docker.sock'.
  Is the Docker daemon running?
""",
            question: "TestcontainersのContainerLaunchExceptionの原因として最も可能性が高いものはどれか？",
            choices: [
                choice("a", "テスト実行環境でDockerデーモンが起動していないためTestcontainersがコンテナを起動できない。Dockerを起動するか、CI環境ではDinD（Docker in Docker）設定を追加する", correct: true,
                       explanation: "TestcontainersはDockerAPIを使用します。`unix:///var/run/docker.sock`への接続失敗はDockerデーモンが停止していることを示します。CI/CDパイプラインではDockerサービスの起動設定が必要です。"),
                choice("b", "Testcontainersのバージョンが古くPostgreSQL 15に対応していない", misconception: "バージョン非対応とデーモン未起動を混同",
                       explanation: "バージョン非対応なら別のエラーメッセージが出ます。`/var/run/docker.sock`の接続失敗はデーモン未起動です。"),
                choice("c", "ポート5432が既に使用されている", misconception: "ポート競合とコンテナ起動失敗を混同",
                       explanation: "ポート競合なら`Address already in use`エラーが出ます。このエラーはDockerデーモン接続失敗です。"),
                choice("d", "`@Testcontainers`アノテーションが付いていない", misconception: "@Testcontainersの欠落と起動失敗を混同",
                       explanation: "`@Testcontainers`はオプションです。`@Container`で宣言したコンテナは自動起動されます。Dockerデーモンの起動が根本問題です。")
            ],
            explanationRef: "explain-boot3-err3-integration-002",
            designIntent: "TestcontainersのContainerLaunchExceptionからDockerデーモン未起動の問題を特定できる。"
        ),
        quiz(
            id: "boot3-err3-integration-003",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .errorReading,
            tags: ["@SpringBootTest", "プロファイル", "@ActiveProfiles"],
            code: """
// テスト実行時のログ:
INFO: The following profiles are active: default

// テストで期待していた設定:
// application-test.yml の spring.datasource.url=jdbc:h2:mem:testdb

// 実際に接続されたDB:
// application.yml の spring.datasource.url=jdbc:mysql://prod-db:3306/app
// → 本番DBへの接続試行でテストが失敗
""",
            question: "`@SpringBootTest`が誤ったプロファイルを使う原因として正しいものはどれか？",
            choices: [
                choice("a", "テストクラスに`@ActiveProfiles(\"test\")`が付いていないため、デフォルトプロファイルが適用されてapplication-test.ymlが読み込まれなかった", correct: true,
                       explanation: "`@SpringBootTest`はプロファイルを自動検出しません。`@ActiveProfiles(\"test\")`をテストクラスに付けるか、`spring.profiles.active=test`をapplication.ymlに設定します。"),
                choice("b", "`application-test.yml`のファイル名は`application-test.properties`でなければならない", misconception: "YAMLとpropertiesの優先順位を誤解",
                       explanation: "YAML形式のプロファイル固有ファイルは正しく動作します。プロファイルの指定が問題です。"),
                choice("c", "`@SpringBootTest`は常にproductionプロファイルを使用する", misconception: "@SpringBootTestの動作を誤解",
                       explanation: "`@SpringBootTest`はアクティブプロファイルを自動で`production`にはしません。明示的な指定がない場合はdefaultプロファイルになります。"),
                choice("d", "`src/test/resources`にapplication-test.ymlを置かなければならない", misconception: "テストリソースのパス問題と誤解",
                       explanation: "テストリソースは`src/test/resources`に置くのが適切ですが、プロファイル指定がなければ読み込まれません。")
            ],
            explanationRef: "explain-boot3-err3-integration-003",
            designIntent: "@SpringBootTestでの誤ったプロファイル適用から@ActiveProfilesの必要性を理解できる。"
        ),
        quiz(
            id: "boot3-err3-integration-004",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .errorReading,
            tags: ["MockMvc", "NullPointerException", "@MockBean", "配置ミス"],
            code: """
java.lang.NullPointerException: Cannot invoke
  "com.example.service.UserService.findById(Long)"
  because "this.userService" is null

  at com.example.controller.UserControllerTest
    .testGetUser(UserControllerTest.java:38)

// テストクラス:
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired MockMvc mockMvc;

    void testGetUser() {
        @MockBean UserService userService; // ← メソッド内で宣言
        ...
    }
}
""",
            question: "`@MockBean`が機能せずNullPointerExceptionになる原因として正しいものはどれか？",
            choices: [
                choice("a", "`@MockBean`がメソッド内のローカル変数として宣言されているためSpring TestContextに登録されず、Controllerに注入されるBeanがnullになった", correct: true,
                       explanation: "`@MockBean`はクラスフィールドとして宣言する必要があります。メソッド内のローカル変数に付けてもSpringが認識しません。"),
                choice("b", "`@WebMvcTest`では`@MockBean`を使用できない", misconception: "@WebMvcTestと@MockBeanの組み合わせを誤解",
                       explanation: "`@WebMvcTest`と`@MockBean`の組み合わせは標準的なパターンです。宣言の場所が問題です。"),
                choice("c", "`UserService`に`@Service`が付いていない", misconception: "@Serviceアノテーション不足と誤解",
                       explanation: "`@MockBean`はBeanの代替品を作ります。実際の`@Service`実装の有無は関係ありません。"),
                choice("d", "`MockMvc`は実際のHTTPサーバーを起動するため`@MockBean`が効かない", misconception: "MockMvcの仕組みを誤解",
                       explanation: "`MockMvc`はサーブレットコンテナをモックするため実サーバー起動は不要です。`@MockBean`は`@WebMvcTest`のSpringコンテキストに登録されます。")
            ],
            explanationRef: "explain-boot3-err3-integration-004",
            designIntent: "@MockBeanのメソッド内ローカル変数宣言によるNullPointerExceptionを特定しフィールド宣言に修正できる。"
        ),
        quiz(
            id: "boot3-err3-integration-005",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .errorReading,
            tags: ["@Sql", "@Transactional", "テストスコープ", "SQL未実行"],
            code: """
@SpringBootTest
@Transactional
@Sql("/test-data.sql")
class OrderServiceIntegrationTest {

    @Autowired OrderService orderService;

    @Test
    void findOrderById() {
        // test-data.sqlでINSERTしたはずのデータが見えない
        Optional<Order> result = orderService.findById(1L);
        assertFalse(result.isPresent()); // ← データが存在しない
    }
}
""",
            question: "`@Sql`で挿入したデータが見えない原因として正しいものはどれか？",
            choices: [
                choice("a", "`@Transactional`が付いたテストでは`@Sql`が同一トランザクション内で実行されるが、テスト対象サービスが別トランザクションを開始するとデータが見えない場合がある。`@Sql`のexecutionPhaseを`BEFORE_TEST_METHOD`に設定するか、`@Transactional`を外す", correct: true,
                       explanation: "`@Sql`はデフォルトで`@Transactional`テストと同一トランザクションで実行されます。テスト後にロールバックされる未コミットデータは、別トランザクションを開始するサービスからは見えません。`PROPAGATION_REQUIRES_NEW`のサービスを呼ぶ場合は特に注意が必要です。"),
                choice("b", "`@Sql`ファイルはsrc/main/resourcesに置かなければならない", misconception: "@Sqlのリソースパスを誤解",
                       explanation: "`@Sql`で参照するリソースはsrc/test/resourcesに置くのが一般的です。"),
                choice("c", "`@Sql`と`@SpringBootTest`は同時に使用できない", misconception: "@Sqlと@SpringBootTestの組み合わせを誤解",
                       explanation: "`@Sql`と`@SpringBootTest`は問題なく組み合わせられます。"),
                choice("d", "H2データベースではSQLのSYNTAXエラーが発生しても無視される", misconception: "H2のSQL互換性とデータ未挿入を混同",
                       explanation: "H2でのSQLエラーは例外として伝播します。このケースはトランザクションスコープの問題です。")
            ],
            explanationRef: "explain-boot3-err3-integration-005",
            designIntent: "@Transactionalテストでの@Sqlデータ不可視問題からトランザクションスコープの影響を理解できる。"
        ),
        quiz(
            id: "boot3-err3-integration-006",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .errorReading,
            tags: ["WireMock", "ConnectionRefused", "並列テスト", "ポート競合"],
            code: """
com.github.tomakehurst.wiremock.client.VerificationException:
  No requests were made to WireMock

// または:
java.net.ConnectException: Connection refused: localhost/127.0.0.1:8089

// CI環境での並列テスト実行ログ:
WireMockServer starting on port 8089  // TestA
WireMockServer starting on port 8089  // TestB ← 同じポート
""",
            question: "並列テストでのWireMockポート競合エラーの原因と対処として正しいものはどれか？",
            choices: [
                choice("a", "複数のテストクラスが固定ポート8089でWireMockを起動しようとしてポートが競合する。`WireMockServer`にポート0を指定してランダムポートを使用し、テスト前に動的ポートをクライアント設定に反映させる", correct: true,
                       explanation: "`new WireMockServer(0)`でランダムポートを割り当てると並列実行でのポート競合を防げます。`wireMockServer.port()`で実際のポートを取得してHTTPクライアントのベースURLを設定します。"),
                choice("b", "WireMockはCI環境では使用できない", misconception: "WireMockのCI環境制限を誤解",
                       explanation: "WireMockはCI環境で広く使われています。ポート競合が問題です。"),
                choice("c", "テストの実行順序を制御すれば競合しない", misconception: "順序制御で並列競合を解決するアンチパターン",
                       explanation: "順序制御はテストの独立性を損ないます。ランダムポートで真の並列実行を実現します。"),
                choice("d", "WireMockの代わりにMockitoを使えばポート競合は起きない", misconception: "WireMockとMockitoの用途を混同",
                       explanation: "MockitoはJavaオブジェクトのモックです。HTTPレベルのスタブにはWireMockが適切です。")
            ],
            explanationRef: "explain-boot3-err3-integration-006",
            designIntent: "WireMock並列テストのポート競合からランダムポート割り当てによる解決策を選択できる。"
        ),
        quiz(
            id: "boot3-err3-integration-007",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .errorReading,
            tags: ["StepVerifier", "AssertionError", "タイムアウト", "WebFlux"],
            code: """
java.lang.AssertionError:
  VerifySubscriberAssert$DefaultVerifySubscriberAssert
  timed out! (after 3s)
  Actual signals:
    onSubscribe()
    onNext(User{id=1, name='Alice'})
    // onComplete() が来なかった

  at com.example.UserFluxTest
    .testFindAllUsers(UserFluxTest.java:42)

// テスト対象:
Flux<User> findAllUsers() {
    return userRepository.findAll()
        .filter(u -> u.isActive()); // ← 全員isActive=falseのテストデータ
}
""",
            question: "`StepVerifier`でAssertionErrorのタイムアウトが発生した原因として正しいものはどれか？",
            choices: [
                choice("a", "`filter(u -> u.isActive())`で全ユーザーが除外されてonCompleteのみ発行されるはずが、`StepVerifier`が`onNext`シグナルを期待していたため。テストデータにアクティブユーザーを追加するかexpectNextCountを修正する", correct: true,
                       explanation: "`StepVerifier`の`expectNextCount(1)`等が期待するシグナル数と実際のシグナルが一致しないとタイムアウトします。テストデータがフィルタ条件を満たしているか確認します。"),
                choice("b", "WebFluxのスレッドプールが詰まって処理が遅延した", misconception: "スレッドプールの詰まりとStepVerifierタイムアウトを混同",
                       explanation: "スタックトレースから1件のonNextは届いており、2件目（またはonComplete）が来ていないことが分かります。スレッドプールの問題ではありません。"),
                choice("c", "`StepVerifier.create().verifyComplete()`のデフォルトタイムアウトを延ばす", misconception: "タイムアウト延長で根本解決するアンチパターン",
                       explanation: "タイムアウトを延ばしてもテストデータの問題は解決しません。"),
                choice("d", "`@DataR2dbcTest`を使わないとリアクティブリポジトリが動かない", misconception: "テストスライスとリポジトリ動作を混同",
                       explanation: "`@SpringBootTest`でもR2DBCリポジトリは動作します。テストデータとフィルタ条件の不一致が問題です。")
            ],
            explanationRef: "explain-boot3-err3-integration-007",
            designIntent: "StepVerifierタイムアウトエラーからフィルタ条件とテストデータの不一致を特定できる。"
        ),
    ]
}
