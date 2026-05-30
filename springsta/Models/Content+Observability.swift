import Foundation

extension Quiz {
    static let observabilityQuizzes: [Quiz] = (obsActuator + obsMetrics + obsLogging + obsTracing)
        .map { $0.contextualizedForPresentation() }

    // MARK: - Group 1: Actuator (5問)
    private static let obsActuator: [Quiz] = [
        quiz(
            id: "boot3-obs-actuator-001",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["Actuator", "/actuator/health", "HealthIndicator"],
            code: """
management:
  endpoint:
    health:
      show-details: always  # 全詳細を表示（本番では when-authorized 推奨）
  health:
    diskspace:
      enabled: true
    db:
      enabled: true
""",
            question: "`/actuator/health` エンドポイントが `DOWN` を返す条件として正しいのはどれか？",
            choices: [
                choice("a", "登録されたいずれかのHealthIndicator（DB接続、ディスク容量等）が DOWN を報告した場合", correct: true,
                       explanation: "HealthIndicatorは各コンポーネントの状態を確認します。DB接続失敗、ディスク残量不足等が検出されると全体がDOWNになります。Kubernetesのliveness/readiness probeと連携してポッドの再起動に使います。"),
                choice("b", "全HealthIndicatorが通過してもJVMヒープ使用率が80%を超えるとDOWNになる", misconception: "ヒープ使用率でDOWNになると誤解",
                       explanation: "デフォルトではJVMヒープのHealthIndicatorはありません。追加カスタムHealthIndicatorで設定は可能です。"),
                choice("c", "/actuator/healthは常にUPを返しDOWNを返すことはない", misconception: "常にUPと誤解",
                       explanation: "HealthIndicatorが異常を検出した場合はDOWNを返します。これがモニタリングツールやKubernetesとの連携で重要な機能です。"),
                choice("d", "@SpringBootTestでテストするとActuatorは自動でDOWNを返す", misconception: "テスト環境でDOWNになると誤解",
                       explanation: "@SpringBootTestでもActuatorは正常動作します。テスト用インメモリDB等が設定されればUPになります。")
            ],
            explanationRef: "explain-boot3-obs-actuator-001",
            designIntent: "HealthIndicatorとActuatorのヘルスチェックを理解する。"
        ),
        quiz(
            id: "boot3-obs-actuator-002",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["カスタムHealthIndicator", "HealthComponent", "外部依存"],
            code: """
@Component
public class ExternalApiHealthIndicator implements HealthIndicator {

    private final ExternalApiClient client;

    @Override
    public Health health() {
        try {
            client.ping();
            return Health.up().withDetail("api", "responding").build();
        } catch (Exception e) {
            return Health.down()
                .withDetail("error", e.getMessage())
                .build();
        }
    }
}
""",
            question: "カスタムHealthIndicatorを実装する場面として適切なのはどれか？",
            choices: [
                choice("a", "外部APIやメッセージキューなど、Spring Bootが自動チェックしない依存サービスの疎通確認をヘルスチェックに含めたい場合", correct: true,
                       explanation: "Spring Bootは標準でDB・Redis等をチェックしますが、カスタムAPI等はありません。HealthIndicatorを実装することで任意の依存サービスをヘルスチェックに組み込めます。"),
                choice("b", "カスタムHealthIndicatorを追加するとデフォルトのDBヘルスチェックが無効になる", misconception: "カスタムが標準を置き換えると誤解",
                       explanation: "カスタムHealthIndicatorは追加されます。デフォルトのチェックは引き続き動作します。"),
                choice("c", "HealthIndicatorのhealth()メソッドは非同期で実行する必要がある", misconception: "非同期が必須と誤解",
                       explanation: "HealthIndicatorは同期的に実行されます。ただし外部APIの遅延を避けるためタイムアウト設定は重要です。"),
                choice("d", "カスタムHealthIndicatorはProductionプロファイルでのみ動作する", misconception: "プロファイル依存と誤解",
                       explanation: "HealthIndicatorはBeanとして登録されれば全プロファイルで動作します。プロファイル限定にするには@Profileを追加します。")
            ],
            explanationRef: "explain-boot3-obs-actuator-002",
            designIntent: "カスタムHealthIndicatorの用途を理解する。"
        ),
        quiz(
            id: "boot3-obs-actuator-003",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["Kubernetes", "liveness", "readiness", "probe"],
            code: """
management:
  endpoint:
    health:
      probes:
        enabled: true  # /actuator/health/liveness, /actuator/health/readiness を有効化
  health:
    livenessState:
      enabled: true
    readinessState:
      enabled: true
""",
            question: "Kubernetesの `livenessProbe` と `readinessProbe` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "livenessはアプリが生存しているか（失敗でPod再起動）、readinessはトラフィックを受け取れる状態か（失敗でServiceから除外）", correct: true,
                       explanation: "livenessProbeが失敗するとKubernetesはコンテナを再起動します。readinessProbeが失敗するとServiceのエンドポイントから除外（トラフィックが届かなくなる）します。"),
                choice("b", "livenessProbeはHTTPのみ対応でreadinessProbeはTCPのみ対応", misconception: "プローブ方式の制限を誤解",
                       explanation: "両プローブともHTTP/TCP/Exec（コマンド実行）をサポートします。"),
                choice("c", "readinessProbeが失敗するとPodが削除される", misconception: "readiness失敗がPod削除につながると誤解",
                       explanation: "readiness失敗はServiceからの除外です。Pod自体は保持されます（liveness失敗が再起動を引き起こします）。"),
                choice("d", "Spring Bootではlivenessとreadinessの区別はなく両方が同じ/actuator/healthで管理される", misconception: "Spring Bootが両プローブを区別しないと誤解",
                       explanation: "probes.enabled=trueにすることで/liveness、/readinessに分離されます。デフォルトでは無効です。")
            ],
            explanationRef: "explain-boot3-obs-actuator-003",
            designIntent: "KubernetesプローブとActuatorの連携を理解する。"
        ),
        quiz(
            id: "boot3-obs-actuator-004",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["/actuator/metrics", "Micrometer", "Counter"],
            code: """
@RestController
public class OrderController {

    private final Counter orderCounter;

    public OrderController(MeterRegistry registry) {
        this.orderCounter = Counter.builder("orders.created")
            .tag("status", "success")
            .description("Number of orders created")
            .register(registry);
    }

    @PostMapping("/orders")
    public ResponseEntity<?> createOrder(@RequestBody OrderDto dto) {
        // 注文処理
        orderCounter.increment();
        return ResponseEntity.ok().build();
    }
}
""",
            question: "Micrometerの `Counter` と `Gauge` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "CounterはHTTPリクエスト数など単調増加する値、Gaugeはアクティブ接続数など増減する現在値", correct: true,
                       explanation: "Counterは1方向（増加のみ）です。Gaugeはキューサイズ、接続数など現在値を測定します。他にTimer（時間測定）、DistributionSummary（分布）があります。"),
                choice("b", "GaugeはCounterと違いPrometheus形式でしか出力できない", misconception: "Gaugeの出力形式を誤解",
                       explanation: "MicrometerはCounter/Gaugeどちらも複数フォーマット（Prometheus、Datadog、CloudWatch等）に対応しています。"),
                choice("c", "Counterは自動的に0にリセットされる時間が1時間に設定されている", misconception: "Counterのリセット挙動を誤解",
                       explanation: "CounterはJVMが起動している間ずっと単調増加します。自動リセットはありません。"),
                choice("d", "Micrometerを使うと@Transactionalが自動的に全メソッドに追加される", misconception: "MicrometerがトランザクションAOPを追加すると誤解",
                       explanation: "Micrometerはメトリクス収集ライブラリです。@Transactionalとは無関係です。")
            ],
            explanationRef: "explain-boot3-obs-actuator-004",
            designIntent: "Micrometerのメトリクス種別を理解する。"
        ),
        quiz(
            id: "boot3-obs-actuator-005",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["/actuator/env", "環境変数マスク", "セキュリティ"],
            code: """
# /actuator/env のレスポンス（マスク例）
{
  "name": "spring.datasource.password",
  "value": "******"  ← マスクされる
}
""",
            question: "`/actuator/env` エンドポイントで設定値がマスクされる仕組みとして正しいのはどれか？",
            choices: [
                choice("a", "password、secret、key、token等を含むプロパティ名はSpring Bootがデフォルトで`******`にマスクする", correct: true,
                       explanation: "Spring BootはSanitizingFunctionで機密性が高いキーワードを含むプロパティ名の値を自動マスクします。カスタマイズも可能です。"),
                choice("b", "マスクされた値はDBに暗号化して保存される", misconception: "マスクとDB保存を混同",
                       explanation: "マスクはActuatorのレスポンス表示のみです。DBへの保存とは無関係です。"),
                choice("c", "/actuator/envを無効化しない限り全プロパティが平文で表示される", misconception: "マスクを知らない",
                       explanation: "Spring Bootはデフォルトで機密性の高いプロパティをマスクします。ただし完全な保護には適切な認証設定も必要です。"),
                choice("d", "マスクはBase64エンコードであり、デコードすれば元の値が分かる", misconception: "マスクがエンコードと誤解",
                       explanation: "Actuatorのマスクは`******`に置換するだけです。エンコードではないためデコードもありません。")
            ],
            explanationRef: "explain-boot3-obs-actuator-005",
            designIntent: "Actuator envエンドポイントのマスク機能を理解する。"
        ),
    ]

    // MARK: - Group 2: メトリクスとモニタリング (5問)
    private static let obsMetrics: [Quiz] = [
        quiz(
            id: "boot3-obs-metrics-001",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["Prometheus", "Grafana", "メトリクス収集"],
            code: """
# application.yml（Prometheusエンドポイント有効化）
management:
  endpoints:
    web:
      exposure:
        include: prometheus, health
  metrics:
    export:
      prometheus:
        enabled: true
""",
            question: "Spring BootのPrometheusメトリクス収集の仕組みとして正しいのはどれか？",
            choices: [
                choice("a", "PrometheusがScrapeして`/actuator/prometheus`からメトリクスを定期的にPull収集する", correct: true,
                       explanation: "PrometheusはPullモデルを採用しています。`/actuator/prometheus`をScrapeターゲットに設定し、一定間隔でメトリクスを収集します。Grafanaでこのデータを可視化するのが一般的な構成です。"),
                choice("b", "Spring BootがPrometheusサーバへメトリクスをPush送信する", misconception: "PullモデルをPushと誤解",
                       explanation: "PrometheusはPullモデルです。PushモデルはPrometheusのPushgatewayや他のツール（Datadog等）を使う場合です。"),
                choice("c", "Prometheusメトリクスを使うにはGrafanaも同時に設定が必要", misconception: "GrafanaがPrometheusの必須依存と誤解",
                       explanation: "PrometheusとGrafanaは独立したツールです。Prometheusだけでメトリクス収集・クエリが可能です。GrafanaはUI可視化ツールです。"),
                choice("d", "/actuator/prometheusへのアクセスは認証なしに公開可能", misconception: "Prometheusエンドポイントが安全と誤解",
                       explanation: "Prometheusエンドポイントにはシステム情報が含まれます。本番では認証やネットワークアクセス制限を設定すべきです。")
            ],
            explanationRef: "explain-boot3-obs-metrics-001",
            designIntent: "PrometheusとSpring Bootの連携を理解する。"
        ),
        quiz(
            id: "boot3-obs-metrics-002",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["@Timed", "Timer", "パフォーマンス計測"],
            code: """
@Service
public class PaymentService {

    @Timed(value = "payment.processing.time",
           description = "Time taken for payment processing",
           percentiles = {0.5, 0.95, 0.99})
    public PaymentResult processPayment(PaymentRequest request) {
        // 決済処理
        return doProcess(request);
    }
}
""",
            question: "`percentiles = {0.5, 0.95, 0.99}` を設定する意味として正しいのはどれか？",
            choices: [
                choice("a", "50パーセンタイル（中央値）・95パーセンタイル・99パーセンタイルのレスポンスタイムを記録する", correct: true,
                       explanation: "パーセンタイルはレスポンスタイムの分布を把握するための重要な指標です。p99は99%のリクエストがその時間以内に完了することを示します。外れ値の影響を受けない平均値より実態を反映します。"),
                choice("b", "処理速度が50%・95%・99%に達したときにアラートを発火する", misconception: "パーセンタイルをアラート閾値と誤解",
                       explanation: "パーセンタイルはアラートではなくメトリクスの記録です。アラートはPrometheus AlertManager等で別途設定します。"),
                choice("c", "この設定により50%・95%・99%の確率で処理が成功するよう保証される", misconception: "パーセンタイルが成功率を保証すると誤解",
                       explanation: "パーセンタイルはレスポンスタイムの分布統計です。成功率とは無関係です。"),
                choice("d", "パーセンタイルは最大3つまでしか設定できない", misconception: "設定数に制限があると誤解",
                       explanation: "任意の数のパーセンタイルを設定できます。ただし多すぎるとメモリ消費が増えます。")
            ],
            explanationRef: "explain-boot3-obs-metrics-002",
            designIntent: "パーセンタイルメトリクスの意味を理解する。"
        ),
        quiz(
            id: "boot3-obs-metrics-003",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["SLO", "SLA", "エラーバジェット"],
            code: """
// SLO（Service Level Objective）の例
// - 99.9%のリクエストが200ms以内に完了する
// - エラーレートが0.1%以下

// Spring Bootでの計測
// → /actuator/prometheus で http_server_requests_seconds_*
//   をPromQLでクエリしてSLO準拠を確認
""",
            question: "SLO（Service Level Objective）をSpring Bootアプリで計測する適切なアプローチとして正しいのはどれか？",
            choices: [
                choice("a", "MicrometerのHTTPメトリクス（http.server.requests）とパーセンタイルを使いPrometheusでクエリしてSLO準拠を確認する", correct: true,
                       explanation: "Spring BootのデフォルトメトリクスにはHTTPリクエストの件数・時間・ステータスが含まれます。PromQLでp99やエラーレートをクエリしてSLOを監視できます。"),
                choice("b", "SLOはSpring Bootのアノテーション`@SLO(99.9)`で設定する", misconception: "存在しないアノテーション",
                       explanation: "@SLOというSpring Boot標準アノテーションは存在しません。SLO監視はObservabilityスタックとの連携で実現します。"),
                choice("c", "SLO計測にはAWS CloudWatchなどのクラウドサービスが必須", misconception: "クラウドサービスが必須と誤解",
                       explanation: "Prometheus+GrafanaなどのOSSスタックでもSLO計測は可能です。"),
                choice("d", "Actuatorの/actuator/metricsだけでSLO準拠の自動アラートが設定できる", misconception: "Actuatorがアラートを自動設定すると誤解",
                       explanation: "Actuatorはメトリクスを公開するだけです。アラートはPrometheus AlertManagerやGrafana等で別途設定します。")
            ],
            explanationRef: "explain-boot3-obs-metrics-003",
            designIntent: "SLOとメトリクス収集の関係を理解する。"
        ),
        quiz(
            id: "boot3-obs-metrics-004",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["JVM メトリクス", "GC", "ヒープ"],
            code: """
# JVM関連のメトリクス（Micrometerが自動収集）
# jvm.memory.used{area="heap"}
# jvm.gc.pause
# jvm.threads.live
# jvm.classes.loaded
""",
            question: "JVMメトリクスでメモリリークを検出する方法として正しいのはどれか？",
            choices: [
                choice("a", "`jvm.memory.used{area=heap}` が時間とともに増加し続けGCを実行しても減少しない場合にメモリリークを疑う", correct: true,
                       explanation: "ヒープ使用量がGC後も減少しない右肩上がりのトレンドはメモリリークのサインです。Grafanaでのトレンド分析やHeapダンプの取得で調査します。"),
                choice("b", "jvm.gc.pauseが0.1秒を超えたら即座にメモリリークと判断する", misconception: "GCポーズとメモリリークを直結",
                       explanation: "GCポーズはヒープサイズ・GCアルゴリズム・オブジェクト生成速度等で変化します。0.1秒超えがメモリリークとは直接言えません。"),
                choice("c", "Spring Bootが自動的にメモリリークを検出してログに警告を出す", misconception: "Spring Bootがメモリリーク自動検出すると誤解",
                       explanation: "メモリリーク自動検出機能はSpring Bootには含まれません。メトリクス監視や専用ツール（VisualVM、Heap Analyzer等）を使います。"),
                choice("d", "JVMメトリクスはDocker/Kubernetesコンテナでは収集できない", misconception: "コンテナ環境でJVMメトリクスが使えないと誤解",
                       explanation: "Micrometerは環境に依存せずJVMメトリクスを収集します。コンテナ環境でも正常に動作します。")
            ],
            explanationRef: "explain-boot3-obs-metrics-004",
            designIntent: "JVMメトリクスを使ったメモリ問題の検出を理解する。"
        ),
        quiz(
            id: "boot3-obs-metrics-005",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["カスタムメトリクス", "MeterRegistry", "ビジネスメトリクス"],
            code: """
@Service
public class OrderMetricsService {

    private final MeterRegistry registry;

    public void recordOrder(Order order) {
        registry.gauge("orders.total.amount",
            Tags.of("category", order.getCategory()),
            order.getAmount());
    }
}
""",
            question: "ビジネスメトリクスをInfraメトリクスと分けて管理する理由として正しいのはどれか？",
            choices: [
                choice("a", "エンジニアがシステム状態を把握するのがInfra、ビジネス目標の達成度を把握するのがビジネスメトリクスで責務と受信者が異なる", correct: true,
                       explanation: "インフラメトリクス（CPU・メモリ・レスポンスタイム）はSREが監視し、ビジネスメトリクス（注文数・売上・コンバージョン率）はビジネスオーナーが確認します。両者を分けることでダッシュボードが明確になります。"),
                choice("b", "ビジネスメトリクスはDBに保存しActuatorで公開する必要はない", misconception: "ビジネスメトリクスの収集方法を誤解",
                       explanation: "ビジネスメトリクスもMicrometerで収集してPrometheus/Grafanaで可視化できます。DBとActuatorは役割が異なります。"),
                choice("c", "1つのダッシュボードに全メトリクスを統合するとアラートが無効になる", misconception: "統合がアラートを無効化すると誤解",
                       explanation: "アラートはメトリクスの表示場所に依存しません。統合ダッシュボードでもアラートは正常に機能します。"),
                choice("d", "Spring Bootはビジネスメトリクスを自動収集するため実装が不要", misconception: "ビジネスメトリクスが自動収集されると誤解",
                       explanation: "HTTPメトリクス等のシステムメトリクスは自動収集されますが、注文数・売上等のビジネスメトリクスは開発者が実装する必要があります。")
            ],
            explanationRef: "explain-boot3-obs-metrics-005",
            designIntent: "ビジネスメトリクスの重要性を理解する。"
        ),
    ]

    // MARK: - Group 3: ログ管理 (5問)
    private static let obsLogging: [Quiz] = [
        quiz(
            id: "boot3-obs-log-001",
            level: .foundation,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["Logback", "SLF4J", "ログレベル"],
            code: """
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class UserService {
    private static final Logger log = LoggerFactory.getLogger(UserService.class);

    public void createUser(String email) {
        log.debug("Creating user: {}", email);  // DEBUGレベル
        // 処理
        log.info("User created successfully: {}", email);   // INFOレベル
    }
}
""",
            question: "本番環境でログレベルを `INFO` に設定する理由として正しいのはどれか？",
            choices: [
                choice("a", "DEBUGログは詳細すぎてパフォーマンスへの影響とログ量増大があるため、本番では不要な詳細を除く", correct: true,
                       explanation: "DEBUGはループ内での出力等で大量のログが生成されます。本番ではINFO以上に設定することで必要な情報を残しつつパフォーマンスへの影響を抑えます。"),
                choice("b", "INFOレベルではエラーログも出力されなくなる", misconception: "INFOがERRORを含まないと誤解",
                       explanation: "INFOを設定するとINFO・WARN・ERRORが全て出力されます。DEBUGとTRACEのみ除外されます。"),
                choice("c", "ログレベルはアプリ再起動なしに変更できない", misconception: "ログレベルの動的変更が不可と誤解",
                       explanation: "/actuator/loggersエンドポイントを使うとアプリ再起動なしにリアルタイムでログレベルを変更できます。"),
                choice("d", "本番では全てのログを無効化することが推奨されている", misconception: "本番でログ無効化が推奨と誤解",
                       explanation: "ログは障害調査の重要な証拠です。INFO以上のログは本番でも必要です。")
            ],
            explanationRef: "explain-boot3-obs-log-001",
            designIntent: "適切なログレベル設定の理由を理解する。"
        ),
        quiz(
            id: "boot3-obs-log-002",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["MDC", "TraceId", "構造化ログ"],
            code: """
// MDC（Mapped Diagnostic Context）を使ったトレースID付与
@Component
public class RequestIdFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain) throws IOException, ServletException {
        String requestId = UUID.randomUUID().toString();
        MDC.put("requestId", requestId);
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.clear();  // スレッドプール再利用のためクリア必須
        }
    }
}
""",
            question: "MDCを使ってログにリクエストIDを付与する目的として正しいのはどれか？",
            choices: [
                choice("a", "複数のログ行を同一リクエストに紐付けて、ログ検索システムで一連の処理フローを追跡できるようにするため", correct: true,
                       explanation: "MDCはスレッドローカルのコンテキストです。リクエスト開始時にIDをセットすることで、そのリクエスト処理中の全ログに同じIDが付きます。LogstashやGrafana Lokiで特定リクエストの全ログを検索できます。"),
                choice("b", "MDCはパスワードのマスキングを自動で行うセキュリティ機能", misconception: "MDCをセキュリティ機能と誤解",
                       explanation: "MDCはコンテキスト情報をログに付加する機能です。セキュリティのマスキングとは無関係です。"),
                choice("c", "MDC.clear()を呼ばなくてもGCが自動でクリアする", misconception: "MDCの手動クリアが不要と誤解",
                       explanation: "MDCはスレッドローカルです。スレッドプールではスレッドが再利用されるため、前のリクエストのMDCが残ります。finally節でのclear()が必須です。"),
                choice("d", "MDCはSpring Boot 3.x固有の機能でSpring Boot 2.xでは使えない", misconception: "MDCがSpring Boot 3.x新機能と誤解",
                       explanation: "MDCはSLF4J/Logbackの機能で、Spring Bootに依存しません。")
            ],
            explanationRef: "explain-boot3-obs-log-002",
            designIntent: "MDCを使ったリクエスト追跡を理解する。"
        ),
        quiz(
            id: "boot3-obs-log-003",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["構造化ログ", "JSON", "Logstash"],
            code: """
# application.yml（JSON形式ログ設定）
logging:
  structured:
    format:
      console: logstash  # Spring Boot 3.4+

# または logback-spring.xml で JsonEncoder を設定
""",
            question: "JSON形式（構造化ログ）でログを出力する利点として正しいのはどれか？",
            choices: [
                choice("a", "ElasticsearchやSplunk等のログ収集ツールがフィールドを自動解析でき、ログ検索・集計・フィルタリングが容易になる", correct: true,
                       explanation: "テキストログはregexパースが必要です。JSON形式なら`{\"level\":\"ERROR\",\"message\":\"...\",\"requestId\":\"xxx\"}`のように構造化されており、ツールがフィールドを直接使えます。"),
                choice("b", "JSON形式にするとログサイズが半分になりディスクが節約できる", misconception: "JSON形式がログを圧縮すると誤解",
                       explanation: "JSON形式はフィールド名等のオーバーヘッドでむしろテキストより大きくなることが多いです。"),
                choice("c", "JSON形式ログはアプリのパフォーマンスを10倍向上させる", misconception: "存在しないパフォーマンス改善",
                       explanation: "ログフォーマットはアプリのビジネスロジックパフォーマンスには影響しません。若干のログ書き込みオーバーヘッドの変化はありますが、10倍の改善はありません。"),
                choice("d", "JSON形式のログはhuman readableでないため開発時には使えない", misconception: "JSON形式が開発に不向きと誤解",
                       explanation: "JSON形式でも`jq`コマンドやIDEプラグインで整形表示できます。環境によってプロファイルでJSONと平文を切り替えることもできます。")
            ],
            explanationRef: "explain-boot3-obs-log-003",
            designIntent: "構造化ログの利点を理解する。"
        ),
        quiz(
            id: "boot3-obs-log-004",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["Spring Boot 3.x Observability", "Micrometer Tracing", "TraceId"],
            code: """
# Spring Boot 3.xのObservability自動設定（Micrometer Tracing）
# 依存追加: spring-boot-starter-actuator + micrometer-tracing-bridge-brave
management:
  tracing:
    sampling:
      probability: 0.1  # 10%のリクエストをサンプリング
""",
            question: "Micrometer Tracingの `sampling.probability` を 1.0 より小さく設定する理由として正しいのはどれか？",
            choices: [
                choice("a", "全リクエストをトレースするとトレースデータ量が膨大になりパフォーマンスへの影響とストレージコストが増えるため", correct: true,
                       explanation: "本番の高トラフィック環境では全トレースの記録はコストが高いです。10%サンプリングでも十分なトレースが集まり問題分析に役立ちます。エラー率が高い場合はエラーリクエストを100%サンプリングする設定も可能です。"),
                choice("b", "sampling.probability=0.1にするとアプリが0.1秒ごとにトレースデータを送信する", misconception: "probabilityを時間間隔と誤解",
                       explanation: "probabilityは確率（0.0〜1.0）です。0.1は10%のリクエストをトレースする設定です。時間間隔ではありません。"),
                choice("c", "sampling.probability=1.0にするとアプリが10倍遅くなる", misconception: "1.0で10倍遅延と誤解",
                       explanation: "トレーシングオーバーヘッドはリクエストに数ミリ秒〜数十ミリ秒程度の影響があります。10倍遅延は現実的ではありません。"),
                choice("d", "Spring Boot 3.xではsampling.probability設定はなくなりprobabilityは常に1.0固定", misconception: "設定が削除されたと誤解",
                       explanation: "sampling.probabilityはSpring Boot 3.xでも設定可能です。")
            ],
            explanationRef: "explain-boot3-obs-log-004",
            designIntent: "トレースサンプリングの考え方を理解する。"
        ),
        quiz(
            id: "boot3-obs-log-005",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["@Observed", "Observation", "Spring Boot 3.x"],
            code: """
@Service
public class OrderService {

    @Observed(name = "order.service.create",
              contextualName = "creating-order")
    public Order createOrder(OrderDto dto) {
        // 処理
        return orderRepository.save(new Order(dto));
    }
}
""",
            question: "`@Observed` アノテーション（Spring Boot 3.x / Micrometer Observation）の効果として正しいのはどれか？",
            choices: [
                choice("a", "メソッド実行のTimer（メトリクス）とSpan（トレース）を自動で記録する", correct: true,
                       explanation: "@ObservedはMicrometer Observation APIを使い、メソッドのTimerメトリクスとZipkin/Jaeger等へのTracingスパンを一括で記録します。`@EnableObservability`と組み合わせて使います。"),
                choice("b", "@Observedを付けるとメソッドの実行ログが自動で出力される", misconception: "@ObservedがSLF4Jログを出力すると誤解",
                       explanation: "@Observedはメトリクスとトレースを記録します。SLF4Jのログ出力は含まれません。"),
                choice("c", "@Observedはprivateメソッドにも適用できる", misconception: "AOPの適用範囲の誤解",
                       explanation: "@ObservedはSpring AOPプロキシで動作するためpublicメソッドのみに適用できます（内部呼び出しも注意が必要）。"),
                choice("d", "@Observedを使うとPrometheusへの依存が必須になる", misconception: "@ObservedがPrometheus必須と誤解",
                       explanation: "@ObservedはMicrometer Observationを使います。バックエンドはPrometheus・Datadog・Zipkin等、設定したものに送信されます。Prometheus必須ではありません。")
            ],
            explanationRef: "explain-boot3-obs-log-005",
            designIntent: "@ObservedによるObservabilityの自動化を理解する。"
        ),
    ]

    // MARK: - Group 4: 分散トレーシング (5問)
    private static let obsTracing: [Quiz] = [
        quiz(
            id: "boot3-obs-trace-001",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["Zipkin", "TraceId", "SpanId", "分散トレーシング"],
            code: """
# Zipkinへのトレース送信設定
management:
  zipkin:
    tracing:
      endpoint: http://zipkin:9411/api/v2/spans
  tracing:
    sampling:
      probability: 1.0
""",
            question: "分散トレーシングで `TraceId` と `SpanId` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "TraceIdはリクエスト全体（マイクロサービス横断）の識別子、SpanIdは各サービスの1処理単位の識別子", correct: true,
                       explanation: "1つのTraceIdが1ユーザーリクエスト全体を表します。そのリクエストを処理する各サービスが独自のSpanIdを生成します。Zipkinでは1つのTraceIdに対して複数のSpanが木構造でつながります。"),
                choice("b", "TraceIdはSpanIdを暗号化したもの", misconception: "TraceIdとSpanIdの関係を誤解",
                       explanation: "どちらも独立したランダムIDです。暗号化の関係はありません。"),
                choice("c", "SpanIdは全てのサービスで同一の値を使う", misconception: "SpanIdが共有されると誤解",
                       explanation: "SpanIdは各サービス・各処理単位で異なる値を生成します。TraceIdが一致することで同一リクエストと識別されます。"),
                choice("d", "分散トレーシングはSpring Cloud Sleuthが必須で、Spring Boot単体では使えない", misconception: "Spring Cloud Sleuthが必須と誤解",
                       explanation: "Spring Boot 3.xではMicrometer Tracingが統合されており、Spring Cloud Sleuthなしにトレーシングが設定できます。")
            ],
            explanationRef: "explain-boot3-obs-trace-001",
            designIntent: "分散トレーシングのTraceIdとSpanIdを理解する。"
        ),
        quiz(
            id: "boot3-obs-trace-002",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["OpenTelemetry", "OTLP", "標準化"],
            code: """
# OpenTelemetry Collector設定
management:
  otlp:
    tracing:
      endpoint: http://otel-collector:4318/v1/traces
  tracing:
    sampling:
      probability: 1.0
""",
            question: "OpenTelemetry（OTel）を使う利点として正しいのはどれか？",
            choices: [
                choice("a", "ベンダー非依存の標準プロトコル（OTLP）でZipkin・Jaeger・Datadog等のバックエンドをコード変更なしに切り替えられる", correct: true,
                       explanation: "OpenTelemetryはCNCFの標準化プロジェクトです。OTLPプロトコルで送信することで、バックエンドをDatadogからGrafana Tempoへ変更してもアプリコードを変更不要にできます。"),
                choice("b", "OpenTelemetryを使うとPrometheusのPullモデルが自動でPushモデルに変換される", misconception: "OTelがPrometheusモデルを変換すると誤解",
                       explanation: "OpenTelemetryとPrometheusは協調して使えますが、自動変換機能はありません。"),
                choice("c", "OpenTelemetryはJVMのみ対応でNode.js・Pythonには使えない", misconception: "JVM専用と誤解",
                       explanation: "OpenTelemetryはポリグロット対応です。Java/Node.js/Python/Go等多言語のSDKが提供されています。"),
                choice("d", "Spring Boot 3.xではOpenTelemetryサポートが廃止されZipkinのみ推奨", misconception: "廃止されたという誤情報",
                       explanation: "Spring Boot 3.xはMicrometer Tracing経由でOpenTelemetry（OTLP）をサポートしています。廃止されていません。")
            ],
            explanationRef: "explain-boot3-obs-trace-002",
            designIntent: "OpenTelemetryのベンダー非依存性を理解する。"
        ),
        quiz(
            id: "boot3-obs-trace-003",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["ログとトレース連携", "TraceId in Log", "相関"],
            code: """
# application.yml（ログへのTraceId自動付与）
logging:
  pattern:
    level: "%5p [${spring.application.name:},%X{traceId:-},%X{spanId:-}]"
""",
            question: "ログパターンにTraceIdを含める利点として正しいのはどれか？",
            choices: [
                choice("a", "ログとトレースを同一のTraceIdで検索し、エラーログからトレースの詳細に直接ジャンプできる", correct: true,
                       explanation: "ログにTraceIdを含めることでLokiやElasticsearchで`traceId=xxx`を検索し、Zipkin/Jaegerで同じIDを検索すれば、ログとトレースを横断した障害調査ができます。"),
                choice("b", "TraceIdをログに含めるとログファイルのサイズが50%削減される", misconception: "存在しないサイズ削減",
                       explanation: "TraceIdはログに情報を追加するため、サイズは増加します。削減にはなりません。"),
                choice("c", "Spring Boot 3.xではTraceIdがデフォルトでログに自動含まれる", misconception: "デフォルト含有と誤解",
                       explanation: "Micrometer Tracingを追加してlogging.patternで設定する必要があります。デフォルトでは含まれません。"),
                choice("d", "TraceIdはセキュリティ上の理由からログに含めてはいけない", misconception: "TraceIdが機密情報と誤解",
                       explanation: "TraceIdはランダムIDで機密情報ではありません。ログに含めることで運用効率が上がります。")
            ],
            explanationRef: "explain-boot3-obs-trace-003",
            designIntent: "ログとトレースの相関を理解する。"
        ),
        quiz(
            id: "boot3-obs-trace-004",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["スロークエリ", "DB可視化", "Span"],
            code: """
// Spring Data JPAのクエリトレーシング
// Micrometer Tracing + datasource-proxy で SQLのSpanが自動生成される

// トレース例
// HTTP GET /users → [100ms]
//   └─ findByEmail SQL → [80ms] ← スロークエリ検出
//      └─ SELECT * FROM users WHERE email = ?
""",
            question: "分散トレーシングでDBクエリのSpanを記録する利点として正しいのはどれか？",
            choices: [
                choice("a", "どのHTTPリクエストがどのSQLを発行し、全体レスポンスタイムのどれだけをDB処理が占めているか可視化できる", correct: true,
                       explanation: "HTTPリクエストのSpanにDBクエリのSpanが入れ子になることで、スロークエリの特定とN+1問題の検出が視覚的にできます。"),
                choice("b", "DBのSpanを記録するとJPAのキャッシュが自動で有効化される", misconception: "SpanとJPAキャッシュを関連付けて誤解",
                       explanation: "トレーシングとJPAのL2キャッシュは無関係です。"),
                choice("c", "SQLスパンの記録にはOracleのみ対応している", misconception: "DB依存と誤解",
                       explanation: "datasource-proxyはJDBC互換のDBであればMySQL・PostgreSQL・H2等に対応します。"),
                choice("d", "SpringはDBのSpanをAOPプロキシなしに自動記録する", misconception: "自動記録の仕組みを誤解",
                       explanation: "DBクエリのSpan記録にはdatasource-proxyやP6Spy等のJDBC Wrapperライブラリを使う必要があります。")
            ],
            explanationRef: "explain-boot3-obs-trace-004",
            designIntent: "トレーシングによるDBパフォーマンス可視化を理解する。"
        ),
        quiz(
            id: "boot3-obs-trace-005",
            level: .practice,
            objective: "boot3-practice-observability",
            category: .observability,
            tags: ["Grafana", "ダッシュボード", "Three Pillars"],
            code: """
// Observabilityの3つの柱（Three Pillars of Observability）
// 1. Metrics（メトリクス）  → Prometheus + Grafana
// 2. Logs（ログ）          → Grafana Loki / ELK Stack
// 3. Traces（トレース）    → Zipkin / Grafana Tempo
""",
            question: "Observabilityの「3つの柱」でそれぞれが解決する問題として正しいのはどれか？",
            choices: [
                choice("a", "Metricsは集計値でトレンドを把握、Logsはイベントの詳細を記録、Tracesはリクエストの処理フローを可視化する", correct: true,
                       explanation: "メトリクスはシステム状態の集計（レスポンスタイムの平均・エラー率）、ログは個々のイベント詳細、トレースはマイクロサービス間のリクエストフローです。3つを組み合わせることで障害の全体像を把握できます。"),
                choice("b", "3つの柱は互いに冗長で、Metricsだけあれば障害調査に十分", misconception: "メトリクスだけで十分と誤解",
                       explanation: "メトリクスはWhatを示しますが、Whyはログが必要で、Whereはトレースが必要です。3つは補完関係にあります。"),
                choice("c", "Three Pillarsはクラウド環境のみに適用される概念", misconception: "クラウド専用と誤解",
                       explanation: "Three PillarsはObservabilityの一般的なフレームワークです。オンプレミスでも同様に適用されます。"),
                choice("d", "Spring Boot 3.xは3つの柱を全てデフォルトで設定する", misconception: "全てデフォルトで設定されると誤解",
                       explanation: "Spring Boot 3.xはActuatorとMicrometer Tracingを含みますが、ログ収集インフラ（Loki等）やトレースバックエンド（Zipkin等）の設定は別途必要です。")
            ],
            explanationRef: "explain-boot3-obs-trace-005",
            designIntent: "Observabilityの3つの柱を理解する。"
        ),
    ]
}
