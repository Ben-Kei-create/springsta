import Foundation

extension Quiz {
    static let deploymentQuizzes: [Quiz] = (
        deployJar + deployDocker + deployCI + deployCloud
    ).map { $0.contextualizedForPresentation() }

    // MARK: - 実行可能JAR / Fat JAR
    private static let deployJar: [Quiz] = [
        quiz(
            id: "boot3-deploy-jar-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["Fat JAR", "実行可能JAR", "spring-boot-maven-plugin"],
            code: """
./mvnw package
java -jar target/demo-0.0.1-SNAPSHOT.jar
""",
            question: "`spring-boot-maven-plugin` が `package` フェーズで生成するJARの特徴として正しいものはどれか？",
            choices: [
                choice("a", "アプリクラスと全依存JARを含む実行可能なFat JAR（uber-jar）が生成される", correct: true,
                       explanation: "Spring Bootプラグインは `BOOT-INF/lib` 配下に依存JARをネストした実行可能JARを作ります。`java -jar` 1コマンドで起動できます。"),
                choice("b", "依存関係は別フォルダに置かれ、JARは薄い状態で生成される", misconception: "通常のMaven packageと混同",
                       explanation: "通常の `maven-jar-plugin` だけでは薄いJARが生成されますが、Spring Bootプラグインは依存込みのFat JARを作ります。"),
                choice("c", "必ずDockerイメージが同時に作られる", misconception: "buildpackとpackageを混同",
                       explanation: "Dockerイメージを作るには `spring-boot:build-image` ゴールを実行します。"),
                choice("d", "`java -jar` では組み込みTomcatが起動しない", misconception: "Fat JARと外部サーバの関係を混同",
                       explanation: "組み込みTomcatが含まれるため `java -jar` でHTTPサーバが起動します。")
            ],
            explanationRef: "explain-boot3-deploy-jar-001",
            designIntent: "Spring Bootの実行可能JARの仕組みと起動方法を理解する。"
        ),
        quiz(
            id: "boot3-deploy-jar-layers-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["レイヤーJAR", "Dockerfile", "キャッシュ"],
            code: """
FROM eclipse-temurin:21-jre
WORKDIR /app
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
""",
            question: "この単純なDockerfileに比べ、Spring Bootのレイヤー分割JARを使う利点はどれか？",
            choices: [
                choice("a", "依存ライブラリ層とアプリコード層を分けることでDockerのキャッシュ効率が上がり、イメージ再ビルド時間が短縮される", correct: true,
                       explanation: "依存ライブラリは変わらない限り再ダウンロード不要になります。`jarmode=layertools` でレイヤーを展開してからCOPYするDockerfileパターンが推奨されます。"),
                choice("b", "Fat JARをそのままCOPYするほうがキャッシュ効率は必ず高い", misconception: "レイヤー分割の利点を誤解",
                       explanation: "Fat JARは毎ビルドで差分検出が難しく、コード1行の変更でも大きいJAR全体が再送されます。"),
                choice("c", "レイヤー分割するとJVMが起動できなくなる", misconception: "レイヤー化とJVM起動を混同",
                       explanation: "レイヤー化はDockerビルドの最適化であり、JVMの動作には影響しません。"),
                choice("d", "spring-boot-maven-pluginなしでもレイヤー分割JARが作れる", misconception: "プラグインの役割を見落としている",
                       explanation: "レイヤーJAR機能はSpring Bootプラグインが提供します。")
            ],
            explanationRef: "explain-boot3-deploy-jar-layers-001",
            designIntent: "レイヤーJARによるDockerビルド最適化を理解する。"
        ),
    ]

    // MARK: - Docker / コンテナ化
    private static let deployDocker: [Quiz] = [
        quiz(
            id: "boot3-deploy-docker-buildpack-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["Buildpack", "build-image", "Dockerfile不要"],
            code: """
./mvnw spring-boot:build-image
""",
            question: "`spring-boot:build-image` ゴールの特徴として正しいものはどれか？",
            choices: [
                choice("a", "Dockerfileを書かずにCloud Native Buildpacksを使ったOCIイメージを作れる", correct: true,
                       explanation: "Spring Boot 2.3以降 `build-image` でBuildpacksを呼び出し、ベストプラクティスが適用されたイメージを生成できます。"),
                choice("b", "必ず外部のDockerデーモンに接続する必要がある", misconception: "podmanやremoteデーモン対応を見落としている",
                       explanation: "Dockerデーモンが必要ですが、remoteデーモンやpodman設定も可能です。"),
                choice("c", "JREではなく必ずJDKベースのイメージが生成される", misconception: "Buildpacksが選ぶ実行環境を誤解",
                       explanation: "BuildpacksはJREのみのランタイムイメージを生成するため不要なJDKは含まれません。"),
                choice("d", "`application.yml` の内容はイメージに含まれない", misconception: "設定ファイルがJARに入ることを見落としている",
                       explanation: "`application.yml` はJARに含まれ、イメージ内で利用されます。環境変数で上書きが推奨されます。")
            ],
            explanationRef: "explain-boot3-deploy-docker-buildpack-001",
            designIntent: "DockerfileレスのBuildpacksイメージビルドを理解する。"
        ),
        quiz(
            id: "boot3-deploy-docker-env-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["環境変数", "コンテナ設定", "SPRING_DATASOURCE_URL"],
            code: """
docker run -e SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/prod \\
           -e SPRING_DATASOURCE_USERNAME=user \\
           -e SPRING_DATASOURCE_PASSWORD=secret \\
           myapp:latest
""",
            question: "コンテナ起動時に環境変数でSpring Bootの設定を上書きする際の命名規則として正しいものはどれか？",
            choices: [
                choice("a", "`spring.datasource.url` の環境変数名は `SPRING_DATASOURCE_URL`（ドットと `-` をアンダースコアに、大文字に変換）", correct: true,
                       explanation: "Spring BootのRelaxed Bindingは環境変数の `_` をドットやハイフンへ変換します。大文字も区別なく解決されます。"),
                choice("b", "環境変数は `application.yml` に反映されないので別の仕組みが必要", misconception: "環境変数の優先順位を見落としている",
                       explanation: "環境変数は `application.yml` より高い優先度を持ち、同じキーの値を上書きします。"),
                choice("c", "ドット区切りそのままの `spring.datasource.url` という環境変数名が正しい", misconception: "環境変数の命名変換を知らない",
                       explanation: "ドット区切りはshellで特殊文字になりえます。アンダースコア区切り大文字への変換が一般的です。"),
                choice("d", "コンテナでは `@Value` が機能しない", misconception: "コンテナ実行環境とSpringの設定解決を混同",
                       explanation: "`@Value` はSpring Bootの外部化設定から値を取得するため、コンテナでも正常に動作します。")
            ],
            explanationRef: "explain-boot3-deploy-docker-env-001",
            designIntent: "コンテナ環境でのSpring Boot設定の上書き方法を理解する。"
        ),
        quiz(
            id: "boot3-deploy-health-probe-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["Kubernetes", "liveness", "readiness", "Actuator"],
            code: """
management:
  endpoint:
    health:
      probes:
        enabled: true
  health:
    livenessState:
      enabled: true
    readinessState:
      enabled: true
""",
            question: "この設定を行うと有効になるエンドポイントの組み合わせとして正しいものはどれか？",
            choices: [
                choice("a", "`/actuator/health/liveness` と `/actuator/health/readiness` が公開される", correct: true,
                       explanation: "Kubernetesデプロイ用のliveness/readinessプローブエンドポイントを個別に有効化できます。"),
                choice("b", "`/actuator/liveness` と `/actuator/readiness` が公開される", misconception: "Actuatorのパス構造を誤解",
                       explanation: "Kubernetesプローブはhealthエンドポイント配下のサブパスとして公開されます。"),
                choice("c", "`/health` だけが公開され、livenessとreadinessは含まれない", misconception: "probes設定を知らない",
                       explanation: "`probes.enabled: true` でKubernetes専用のサブエンドポイントが追加されます。"),
                choice("d", "Kubernetes以外では必ずエラーになる", misconception: "Kubernetesプローブ設定を過度に限定",
                       explanation: "ローカル実行でもエンドポイントは動作します。Kubernetes環境でプローブとして使うための設定です。")
            ],
            explanationRef: "explain-boot3-deploy-health-probe-001",
            designIntent: "KubernetesのlvenessとreadinessプローブをActuatorで提供する方法を理解する。"
        ),
    ]

    // MARK: - CI/CD
    private static let deployCI: [Quiz] = [
        quiz(
            id: "boot3-deploy-ci-test-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["CI", "mvnw", "テスト自動化"],
            code: """
# GitHub Actions workflow
- name: Build and Test
  run: ./mvnw verify
""",
            question: "`./mvnw verify` がCIで実行する処理として正しいものはどれか？",
            choices: [
                choice("a", "コンパイル、単体テスト、結合テストまで含むフェーズを実行する", correct: true,
                       explanation: "`verify` フェーズはMavenライフサイクルで `test` と `integration-test` の後に実行されます。テストが失敗するとCIが止まります。"),
                choice("b", "本番DBへのマイグレーションを実行する", misconception: "verify フェーズの意味を誤解",
                       explanation: "DBマイグレーションは `verify` フェーズの直接の責務ではありません。"),
                choice("c", "`package` だけ実行し、テストをすべてスキップする", misconception: "packageとverifyを混同",
                       explanation: "`-DskipTests` を付けない限りテストは実行されます。`verify` は `package` より後のフェーズです。"),
                choice("d", "Dockerイメージを自動でpushする", misconception: "Mavenのverifyをimage pushと混同",
                       explanation: "Docker pushは別のCIステップとして定義します。")
            ],
            explanationRef: "explain-boot3-deploy-ci-test-001",
            designIntent: "CIパイプラインでのMavenビルドとテスト実行の流れを理解する。"
        ),
        quiz(
            id: "boot3-deploy-ci-config-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["CI/CD", "Secrets", "環境変数"],
            code: """
# GitHub Actions
env:
  SPRING_DATASOURCE_URL: ${{ secrets.DB_URL }}
  SPRING_DATASOURCE_PASSWORD: ${{ secrets.DB_PASSWORD }}
""",
            question: "CIパイプラインでDBシークレットをSpring Bootアプリへ渡す上記の方法として正しい説明はどれか？",
            choices: [
                choice("a", "GitHub Actionsのシークレットを環境変数として渡し、Spring Bootが優先的に読み込む", correct: true,
                       explanation: "Secrets仕組みで暗号化管理されたシークレットを環境変数として渡せます。ログへのシークレット漏洩も防止されます。"),
                choice("b", "`application.yml` にシークレットを直接書くほうがCI/CDで推奨される", misconception: "設定ファイルへの直書きを容認",
                       explanation: "シークレットをリポジトリへ入れるのは危険です。Secrets管理ツールを使います。"),
                choice("c", "Spring Bootは環境変数からJDBC URLを読めない", misconception: "環境変数からのDB設定バインドを知らない",
                       explanation: "環境変数のRelaxed Bindingにより `SPRING_DATASOURCE_URL` はそのまま読み込まれます。"),
                choice("d", "シークレットをログで確認できるようにするため、ログレベルをDEBUGにする必要がある", misconception: "シークレット管理の基本を誤解",
                       explanation: "シークレットはログに出力してはいけません。")
            ],
            explanationRef: "explain-boot3-deploy-ci-config-001",
            designIntent: "CIパイプラインでのシークレット管理とSpring Boot設定注入を理解する。"
        ),
    ]

    // MARK: - クラウド / Graceful Shutdown / 本番設定
    private static let deployCloud: [Quiz] = [
        quiz(
            id: "boot3-deploy-graceful-shutdown-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["Graceful Shutdown", "server.shutdown", "コンテナ停止"],
            code: """
server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s
""",
            question: "この設定でコンテナ停止シグナル（SIGTERM）を受けたときの動作として正しいものはどれか？",
            choices: [
                choice("a", "処理中のリクエストが完了するのを最大30秒待ってからシャットダウンする", correct: true,
                       explanation: "Graceful Shutdownは新規リクエストを止め、既存リクエストの完了を待ちます。タイムアウトは `timeout-per-shutdown-phase` で制御します。"),
                choice("b", "SIGTERMが来ても永遠に待ち続ける", misconception: "タイムアウト設定を見落としている",
                       explanation: "`timeout-per-shutdown-phase: 30s` で上限が設定されています。"),
                choice("c", "SIGTERMは無視されてアプリは停止しない", misconception: "Graceful ShutdownがSIGTERMを無視すると誤解",
                       explanation: "Graceful ShutdownはSIGTERMを受け取った後に処理を完了させ、正常終了します。"),
                choice("d", "設定なしでも既定でGraceful Shutdownが有効", misconception: "既定値を誤解",
                       explanation: "既定は `immediate` です。`graceful` を明示的に設定する必要があります。")
            ],
            explanationRef: "explain-boot3-deploy-graceful-shutdown-001",
            designIntent: "コンテナ停止時のGraceful Shutdownと設定方法を理解する。"
        ),
        quiz(
            id: "boot3-deploy-profile-prod-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["production profile", "logging", "DDL"],
            code: """
spring:
  profiles:
    active: prod
  jpa:
    hibernate:
      ddl-auto: validate
logging:
  level:
    root: WARN
    com.example: INFO
""",
            question: "本番プロファイルでの `ddl-auto: validate` と `root: WARN` ログ設定の組み合わせとして正しい説明はどれか？",
            choices: [
                choice("a", "テーブル構造の整合性を検証しつつ、不要なDEBUGログを抑制する本番向けの設定", correct: true,
                       explanation: "`validate` はスキーマ変更を行わず構造確認のみします。`WARN` ルートログでデバッグ情報を減らしつつ、アプリのINFOログは残します。"),
                choice("b", "`validate` は本番でテーブルを全削除して再作成する", misconception: "create-dropと混同",
                       explanation: "`create-drop` が削除再作成です。`validate` はDDL操作を一切行いません。"),
                choice("c", "`root: WARN` にするとアプリログも抑制されてINFOが出なくなる", misconception: "パッケージ別ログ設定の上書きを見落としている",
                       explanation: "`com.example: INFO` が `root: WARN` より具体的なため、アプリパッケージはINFOで出力されます。"),
                choice("d", "本番では必ず `ddl-auto: create` が推奨される", misconception: "DDL自動生成を本番で推奨と誤解",
                       explanation: "本番ではFlywayやLiquibaseなどのマイグレーションツールを使い、`none` か `validate` が推奨されます。")
            ],
            explanationRef: "explain-boot3-deploy-profile-prod-001",
            designIntent: "本番環境向けのSpring Boot設定パターンを理解する。"
        ),
        quiz(
            id: "boot3-deploy-flyway-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["Flyway", "スキーママイグレーション", "バージョン管理"],
            code: """
-- db/migration/V1__create_users.sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL
);
""",
            question: "Spring BootプロジェクトでFlywayを使うメリットとして正しいものはどれか？",
            choices: [
                choice("a", "スキーマ変更をSQLファイルとしてバージョン管理でき、環境間の整合性を保てる", correct: true,
                       explanation: "Flywayは `V{version}__description.sql` のファイルを順序通りに適用し、どの環境でも同じスキーマ状態を保証します。"),
                choice("b", "`ddl-auto: create` と組み合わせることで本番の安全性が高まる", misconception: "Flyway＋createの組み合わせを誤解",
                       explanation: "FlywayはDDL自動生成の代替です。`ddl-auto: validate` または `none` と組み合わせます。"),
                choice("c", "Flywayはアプリコードのバージョン管理のみに使う", misconception: "Flywayの用途をアプリバージョンと混同",
                       explanation: "FlywayはDBスキーマのバージョン管理ツールです。"),
                choice("d", "本番DBにFlywayが直接コネクションするため、アプリと分離できない", misconception: "Flyway実行タイミングを誤解",
                       explanation: "起動時にFlywayがマイグレーションを実行しますが、設定でrepair/baselineなどの制御も可能です。")
            ],
            explanationRef: "explain-boot3-deploy-flyway-001",
            designIntent: "Flywayによるスキーマバージョン管理の必要性を理解する。"
        ),
        quiz(
            id: "boot3-deploy-connection-pool-001",
            level: .practice,
            objective: "boot3-practice-deployment",
            category: .deployment,
            tags: ["HikariCP", "コネクションプール", "本番チューニング"],
            code: """
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
""",
            question: "`maximum-pool-size: 10` の設定について正しい説明はどれか？",
            choices: [
                choice("a", "同時に保持するDB接続の上限が10になり、超過したリクエストは `connection-timeout` まで待機する", correct: true,
                       explanation: "HikariCPはプール内の接続を再利用します。上限を超えるとタイムアウトまで待機し、超過すると例外が発生します。"),
                choice("b", "10スレッドしかHTTPリクエストを処理できない", misconception: "DBコネクションとHTTPスレッドを混同",
                       explanation: "HTTPスレッドプールとDBコネクションプールは独立しています。"),
                choice("c", "`maximum-pool-size` を大きくすれば必ずパフォーマンスが向上する", misconception: "コネクション数とスループットの関係を単純化",
                       explanation: "DBサーバのリソースに依存します。過大なコネクション数はDB側の負荷を高めます。"),
                choice("d", "Spring Bootのデフォルトコネクションプールはdbcpであり、HikariCPは手動設定が必要", misconception: "デフォルトのコネクションプール実装を誤解",
                       explanation: "Spring Boot 2.x以降のデフォルトはHikariCPです。")
            ],
            explanationRef: "explain-boot3-deploy-connection-pool-001",
            designIntent: "HikariCPコネクションプールの設定と本番チューニングの基礎を理解する。"
        ),
    ]
}
