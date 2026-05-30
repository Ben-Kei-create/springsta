import Foundation

extension Quiz {
    static let architectureQuizzes: [Quiz] = (
        archLayered + archHexagonal + archDDD + archMicroservices + archDesignPatterns + archPerformance
    ).map { $0.contextualizedForPresentation() }

    // MARK: - レイヤードアーキテクチャ
    private static let archLayered: [Quiz] = [
        quiz(
            id: "boot3-arch-layer-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["レイヤード", "関心の分離", "Controller/Service/Repository"],
            code: """
// ✗ アンチパターン
@RestController
class OrderController {
    @Autowired OrderRepository repository; // ControllerがRepositoryを直接使用

    @GetMapping("/orders/{id}")
    Order get(@PathVariable Long id) {
        return repository.findById(id).orElseThrow();
    }
}
""",
            question: "このControllerの設計上の問題点として最も適切なものはどれか？",
            choices: [
                choice("a", "業務ロジックとデータアクセスの境界が曖昧になり、テストや変更が困難になる", correct: true,
                       explanation: "ControllerがRepositoryを直接呼ぶとService層による業務ルールの集約ができず、トランザクション管理や横断的関心事の適用が難しくなります。"),
                choice("b", "`@Autowired` をフィールドに付けること自体が動作しない", misconception: "フィールドインジェクションは動作しない誤解",
                       explanation: "フィールドインジェクションは動作しますが、テストの容易性とIoCの観点からコンストラクタ注入が推奨されます。"),
                choice("c", "`@GetMapping` はControllerには使えない", misconception: "アノテーションの使用場所を誤解",
                       explanation: "`@GetMapping` はControllerに付けるアノテーションです。"),
                choice("d", "Repositoryをコントローラで使うほうが処理が速い", misconception: "層を省略するとパフォーマンスが上がると誤解",
                       explanation: "Service層の除去はわずかなオーバーヘッドを減らすだけで、保守性と設計の悪化が大きなコストになります。")
            ],
            explanationRef: "explain-boot3-arch-layer-001",
            designIntent: "レイヤードアーキテクチャの基本原則と違反時の問題を理解する。"
        ),
        quiz(
            id: "boot3-arch-layer-dto-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["DTO", "Entity公開", "API設計"],
            code: """
// ✗ アンチパターン: EntityをそのままAPIレスポンスに使う
@GetMapping("/users/{id}")
User getUser(@PathVariable Long id) {
    return userRepository.findById(id).orElseThrow();
}
""",
            question: "EntityをそのままAPIレスポンスとして返す設計の問題点はどれか？",
            choices: [
                choice("a", "パスワードハッシュなど公開すべきでないフィールドが漏洩し、DBスキーマとAPIが密結合になる", correct: true,
                       explanation: "Entityを直接公開するとJPAの遅延ロード問題、循環参照のシリアライズエラー、DB変更によるAPIブレイキングチェンジなどが生じます。DTOへの変換を挟みます。"),
                choice("b", "Jacksonはエンティティをシリアライズできない", misconception: "JacksonのEntity変換を誤解",
                       explanation: "技術的には変換できますが、設計上の問題があります。"),
                choice("c", "`@Entity` が付いたクラスはControllerに渡せない", misconception: "アノテーションの制約を誤解",
                       explanation: "文法上は渡せますが、それが問題ではなく設計上の懸念があります。"),
                choice("d", "DTOを使うと必ずパフォーマンスが低下する", misconception: "DTOのオーバーヘッドを過大評価",
                       explanation: "DTOの変換コストは通常無視できるレベルです。保守性と安全性の向上のほうが重要です。")
            ],
            explanationRef: "explain-boot3-arch-layer-dto-001",
            designIntent: "EntityとDTOを分離する理由を設計・セキュリティの観点から理解する。"
        ),
        quiz(
            id: "boot3-arch-layer-service-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["Service層", "業務ロジック", "Fat Controller"],
            code: """
@PostMapping("/orders")
ResponseEntity<OrderResponse> create(@Valid @RequestBody CreateOrderRequest req) {
    // 在庫確認
    if (inventoryRepository.findByProductId(req.productId()).stock() < req.quantity()) {
        return ResponseEntity.badRequest().body(null);
    }
    // 割引計算
    BigDecimal price = priceService.calculate(req.productId(), req.quantity());
    // 注文保存
    Order order = new Order(req.productId(), req.quantity(), price);
    Order saved = orderRepository.save(order);
    return ResponseEntity.ok(OrderResponse.from(saved));
}
""",
            question: "このControllerの設計上の問題点として最も適切なものはどれか？",
            choices: [
                choice("a", "業務ロジックがController内に書かれており、テストが困難でReuse困難なFat Controllerになっている", correct: true,
                       explanation: "在庫確認・価格計算などの業務ロジックはService層へ移すべきです。ControllerはHTTP境界の変換のみを担当するのが原則です。"),
                choice("b", "`ResponseEntity` をControllerで使うべきではない", misconception: "ResponseEntityの使用場所を誤解",
                       explanation: "`ResponseEntity` はController向けのHTTP応答ラッパーです。使用自体は問題ありません。"),
                choice("c", "`@Valid` をControllerで使うべきではない", misconception: "バリデーション実施場所を誤解",
                       explanation: "Controller境界でのバリデーションは推奨です。問題は業務ロジックが混入していることです。"),
                choice("d", "複数のRepositoryを同一Controllerで使うことが禁止されている", misconception: "依存関係の制約を誤解",
                       explanation: "禁止はありませんが、複数Repositoryを直接Controllerが持つのは設計上の懸念があります。")
            ],
            explanationRef: "explain-boot3-arch-layer-service-001",
            designIntent: "Fat ControllerとService層への責務分離を理解する。"
        ),
    ]

    // MARK: - ヘキサゴナルアーキテクチャ / ポートとアダプタ
    private static let archHexagonal: [Quiz] = [
        quiz(
            id: "boot3-arch-hex-port-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["ヘキサゴナル", "Port", "Adapter", "依存関係の逆転"],
            code: """
// Port（インターフェース）
interface OrderRepository {
    Optional<Order> findById(OrderId id);
    void save(Order order);
}

// Adapter（実装）
@Repository
class JpaOrderRepository implements OrderRepository {
    private final SpringDataOrderRepository jpaRepo;
    // ...
}
""",
            question: "ヘキサゴナルアーキテクチャにおける上記コードのPortとAdapterの関係として正しいものはどれか？",
            choices: [
                choice("a", "Portはドメインが定義するインターフェース、AdapterはDB等の外部技術を隠蔽する実装で、依存関係が内側（ドメイン）に向く", correct: true,
                       explanation: "依存性逆転原則(DIP)によりドメインがインフラ技術に依存せず、インフラがドメインのインターフェースを実装します。テスト替えも容易です。"),
                choice("b", "PortはJPAアノテーション、AdapterはSpring Beanを意味する独自用語", misconception: "設計パターンの用語とSpring機構を混同",
                       explanation: "Port/Adapterはアーキテクチャパターンの概念です。JPAやBeanの話ではありません。"),
                choice("c", "ドメインがJpaRepositoryを直接継承することがヘキサゴナルの正しい設計", misconception: "SpringDataとドメインの直結を誤解",
                       explanation: "ドメイン層がSpring Data JPAに直接依存するとフレームワーク依存になり、ヘキサゴナルの目的と矛盾します。"),
                choice("d", "ヘキサゴナルアーキテクチャはマイクロサービスでしか使えない", misconception: "アーキテクチャスタイルの適用範囲を誤解",
                       explanation: "単一アプリでも適用できます。外部技術への依存を逆転させる設計思想です。")
            ],
            explanationRef: "explain-boot3-arch-hex-port-001",
            designIntent: "ヘキサゴナルアーキテクチャのPort/Adapterパターンとその効果を理解する。"
        ),
        quiz(
            id: "boot3-arch-hex-usecase-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["ユースケース", "アプリケーション層", "ビジネスルール"],
            code: """
// アプリケーション層のユースケース
@UseCase
class PlaceOrderUseCase {
    private final OrderRepository orderRepo;
    private final InventoryPort inventoryPort;
    private final EventPublisher eventPublisher;

    void execute(PlaceOrderCommand command) {
        Inventory inv = inventoryPort.findByProductId(command.productId());
        inv.reserve(command.quantity()); // ドメインロジック
        Order order = Order.create(command);
        orderRepo.save(order);
        eventPublisher.publish(new OrderPlaced(order.id()));
    }
}
""",
            question: "このユースケースクラスの設計として正しい説明はどれか？",
            choices: [
                choice("a", "ドメインロジックをドメインオブジェクトに委譲し、ユースケースは協調を調整するオーケストレーターとして機能している", correct: true,
                       explanation: "`inv.reserve()` などの判断はドメインオブジェクトが担い、ユースケースはPort経由で外部サービスを呼び出す調整役に徹しています。"),
                choice("b", "`@UseCase` はSpring Bootが提供する標準アノテーション", misconception: "カスタムアノテーションとSpring標準を混同",
                       explanation: "`@UseCase` はカスタムのステレオタイプアノテーションです。`@Component` の派生として定義できます。"),
                choice("c", "ユースケースはDB操作だけを担当するクラス", misconception: "ユースケースの役割をRepositoryと混同",
                       explanation: "ユースケースは業務フローの調整役であり、DB操作専用クラスではありません。"),
                choice("d", "ドメインオブジェクトに業務ロジックを持たせると貧血ドメインモデルになる", misconception: "貧血ドメインとリッチドメインを逆に理解",
                       explanation: "業務ロジックをドメインオブジェクトに持たせるのがリッチドメインモデルです。貧血ドメインはドメインオブジェクトがデータだけを持つパターンです。")
            ],
            explanationRef: "explain-boot3-arch-hex-usecase-001",
            designIntent: "ユースケース層の責務とドメインとの役割分担を理解する。"
        ),
    ]

    // MARK: - ドメイン駆動設計 (DDD)
    private static let archDDD: [Quiz] = [
        quiz(
            id: "boot3-arch-ddd-aggregate-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["DDD", "集約", "集約ルート", "整合性境界"],
            code: """
// 集約ルート
class Order {
    private final OrderId id;
    private final List<OrderItem> items; // 集約内のエンティティ
    private OrderStatus status;

    void addItem(ProductId productId, int quantity) {
        if (status != OrderStatus.DRAFT) {
            throw new DomainException("確定済みの注文には追加できません");
        }
        items.add(new OrderItem(productId, quantity));
    }
}
""",
            question: "DDDにおける集約（Aggregate）について正しい説明はどれか？",
            choices: [
                choice("a", "集約ルートを通じてのみ集約内部を変更でき、トランザクション整合性の境界となる", correct: true,
                       explanation: "`OrderItem` は `Order` を通じてのみ追加できます。集約は一貫したビジネスルールを保護する境界です。"),
                choice("b", "集約はDBテーブルと1対1に対応する必要がある", misconception: "集約の概念とDBスキーマを混同",
                       explanation: "集約はビジネス上の整合性境界であり、DB設計とは独立した概念です。"),
                choice("c", "集約ルート以外のエンティティはRepositoryで直接保存できる", misconception: "集約の不変条件違反",
                       explanation: "集約内のエンティティは集約ルートを通じて操作し、集約ルートのRepositoryで保存します。"),
                choice("d", "集約は必ずイミュータブル（不変）クラスで実装する", misconception: "集約の実装形態を過度に制限",
                       explanation: "状態変化を持つことが多い集約はイミュータブルである必要はありませんが、ビジネスルールを守る操作を提供します。")
            ],
            explanationRef: "explain-boot3-arch-ddd-aggregate-001",
            designIntent: "DDDの集約パターンとトランザクション整合性の境界を理解する。"
        ),
        quiz(
            id: "boot3-arch-ddd-valueobject-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["DDD", "値オブジェクト", "record", "不変性"],
            code: """
record Money(BigDecimal amount, Currency currency) {
    Money {
        if (amount.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("金額は0以上");
        }
    }

    Money add(Money other) {
        if (!currency.equals(other.currency)) throw new IllegalArgumentException("通貨不一致");
        return new Money(amount.add(other.amount), currency);
    }
}
""",
            question: "値オブジェクト（Value Object）として実装された `Money` recordについて正しい説明はどれか？",
            choices: [
                choice("a", "等価性は同一性でなく値で判断され、不変で自己検証し、ドメイン操作メソッドを持つ", correct: true,
                       explanation: "recordは構造的等価性とイミュータビリティを自然に実現します。コンパクトコンストラクタで制約を強制し、`add()` でドメイン操作を表現しています。"),
                choice("b", "recordはDBの1レコードに対応するためエンティティと同義", misconception: "recordキーワードとDBレコードを混同",
                       explanation: "Javaの `record` はイミュータブルなデータキャリアで、DBレコードとは無関係です。"),
                choice("c", "`Money` にIDが必要なため、`@Id` を追加しなければ値オブジェクトにならない", misconception: "値オブジェクトにIDが必要と誤解",
                       explanation: "値オブジェクトはIDを持ちません。それを持つのがエンティティです。"),
                choice("d", "コンパクトコンストラクタでの例外はSpring Boot 3.xでは非推奨", misconception: "値オブジェクトの検証方法を誤解",
                       explanation: "コンパクトコンストラクタでのバリデーション例外は有効な実装パターンです。")
            ],
            explanationRef: "explain-boot3-arch-ddd-valueobject-001",
            designIntent: "DDDの値オブジェクトとJava recordの組み合わせを理解する。"
        ),
        quiz(
            id: "boot3-arch-ddd-domain-event-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["DDD", "ドメインイベント", "ApplicationEventPublisher"],
            code: """
// ドメインイベント
record OrderPlaced(OrderId orderId, Instant occurredAt) {}

// サービス
@Service
@Transactional
class OrderService {
    private final ApplicationEventPublisher eventPublisher;

    void placeOrder(CreateOrderCommand cmd) {
        Order order = Order.create(cmd);
        orderRepository.save(order);
        eventPublisher.publishEvent(new OrderPlaced(order.id(), Instant.now()));
    }
}

// イベントリスナー
@Component
class EmailNotificationListener {
    @TransactionalEventListener
    void on(OrderPlaced event) {
        mailService.sendConfirmation(event.orderId());
    }
}
""",
            question: "`@TransactionalEventListener` の利点として正しいものはどれか？",
            choices: [
                choice("a", "トランザクションのコミット後にイベントリスナーが実行されるため、保存が確定した後にメール送信できる", correct: true,
                       explanation: "既定では `AFTER_COMMIT` フェーズで実行されます。ロールバックしたトランザクションに対して副作用（メール等）が実行されるのを防げます。"),
                choice("b", "`@TransactionalEventListener` はトランザクションを新規に開始する", misconception: "イベントリスナーのトランザクション動作を誤解",
                       explanation: "既定では呼び出し元のトランザクションのフェーズに対して動作します。新規開始は `@Async` と組み合わせるか `propagation` を指定します。"),
                choice("c", "ドメインイベントはHTTPリクエストと同じスレッドで処理されないため常に非同期", misconception: "SpringのイベントとHTTPスレッドの関係を誤解",
                       explanation: "既定では同期実行です。`@Async` を付けることで非同期実行になります。"),
                choice("d", "`ApplicationEventPublisher` はKafkaやRabbitMQへ直接メッセージを送る", misconception: "SpringのローカルイベントとメッセージブローカーのAPIを混同",
                       explanation: "`ApplicationEventPublisher` はJVM内のローカルイベントバスです。")
            ],
            explanationRef: "explain-boot3-arch-ddd-domain-event-001",
            designIntent: "ドメインイベントとTransactionalEventListenerの役割を理解する。"
        ),
        quiz(
            id: "boot3-arch-ddd-repository-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["DDD", "Repository", "ドメイン定義インターフェース"],
            code: """
// ドメイン層に定義するRepositoryインターフェース
interface OrderRepository {
    Optional<Order> findById(OrderId id);
    List<Order> findByCustomerId(CustomerId customerId);
    void save(Order order);
    void remove(Order order);
}
""",
            question: "DDDのRepository設計として正しい説明はどれか？",
            choices: [
                choice("a", "Repositoryはドメインオブジェクトのコレクションとしてのインターフェースをドメイン層に定義し、永続化の詳細はインフラ層に委ねる", correct: true,
                       explanation: "ドメイン層はRepositoryインターフェースのみを持ち、JPA実装はインフラ層で行います。これによりドメインが永続化技術に依存しません。"),
                choice("b", "DDDのRepositoryはJpaRepositoryを直接継承しなければならない", misconception: "Spring Data JPAの継承をDDDに強制",
                       explanation: "DDDのRepositoryはドメイン定義のインターフェースです。JpaRepositoryの継承はインフラ層の実装の詳細です。"),
                choice("c", "RepositoryはDTOだけを扱い、Entityは渡さない", misconception: "RepositoryとDTOを誤って結びつける",
                       explanation: "Repositoryはドメインオブジェクト（Entity/集約）を扱います。DTOはAPI層での変換に使います。"),
                choice("d", "`findByCustomerId` のようなクエリはRepository定義には含められない", misconception: "Repositoryの責務範囲を誤解",
                       explanation: "ビジネス上必要な検索操作はRepositoryインターフェースに定義できます。")
            ],
            explanationRef: "explain-boot3-arch-ddd-repository-001",
            designIntent: "DDDのRepository設計とSpring Data JPAとの関係を理解する。"
        ),
    ]

    // MARK: - マイクロサービスパターン
    private static let archMicroservices: [Quiz] = [
        quiz(
            id: "boot3-arch-ms-api-gateway-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["マイクロサービス", "API Gateway", "Spring Cloud Gateway"],
            code: """
spring:
  cloud:
    gateway:
      routes:
        - id: order-service
          uri: lb://order-service
          predicates:
            - Path=/api/orders/**
          filters:
            - StripPrefix=1
""",
            question: "Spring Cloud Gatewayのこのルート設定について正しい説明はどれか？",
            choices: [
                choice("a", "`/api/orders/**` へのリクエストをロードバランサー経由で `order-service` にルーティングし、パスプレフィックスを削除する", correct: true,
                       explanation: "`lb://` でサービスディスカバリ経由のLBを指定し、`StripPrefix=1` で `/api` プレフィックスを除いて転送します。"),
                choice("b", "このGatewayを通過するリクエストは暗号化が自動で無効になる", misconception: "Gatewayとセキュリティの関係を誤解",
                       explanation: "GatewayはTLS終端を担うことができますが、自動で無効化はしません。"),
                choice("c", "`lb://` はHTTPのロードバランサーではなくLBaaS APIを呼ぶ指定", misconception: "Spring CloudのLBプレフィックスを誤解",
                       explanation: "`lb://` はSpring CloudのクライアントサイドロードバランシングのURIスキームです。"),
                choice("d", "API Gatewayは認証機能を持てないため別サービスが必要", misconception: "Gatewayの認証機能を否定",
                       explanation: "Spring Cloud GatewayはFilterを使った認証・認可のハンドリングが可能です。")
            ],
            explanationRef: "explain-boot3-arch-ms-api-gateway-001",
            designIntent: "マイクロサービスにおけるAPI Gatewayのルーティング設定を理解する。"
        ),
        quiz(
            id: "boot3-arch-ms-circuit-breaker-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["サーキットブレーカー", "Resilience4j", "フォールバック"],
            code: """
@CircuitBreaker(name = "inventoryService", fallbackMethod = "fallback")
public InventoryResponse checkInventory(Long productId) {
    return inventoryClient.check(productId);
}

private InventoryResponse fallback(Long productId, Exception ex) {
    return new InventoryResponse(productId, 0, false); // 在庫なしとして扱う
}
""",
            question: "Resilience4jのサーキットブレーカーの動作として正しいものはどれか？",
            choices: [
                choice("a", "呼び出しが連続して失敗すると回路がOPENになり、以降の呼び出しはフォールバックが即座に返る", correct: true,
                       explanation: "サーキットブレーカーはOPEN状態でダウンストリームへの呼び出しをショートサーキットし、フォールバックで処理継続できます。障害の連鎖伝播（カスケード障害）を防ぎます。"),
                choice("b", "フォールバックは常に元のメソッドより先に実行される", misconception: "フォールバックの実行タイミングを誤解",
                       explanation: "フォールバックは本来の呼び出しが失敗またはOPEN状態のときに実行されます。"),
                choice("c", "`@CircuitBreaker` はSpring Frameworkの組み込みアノテーション", misconception: "Resilience4jとSpring Frameworkの混同",
                       explanation: "`@CircuitBreaker` はResilience4jが提供するアノテーションです。Spring Cloud Circuit Breakerを経由して利用することも多いです。"),
                choice("d", "サーキットブレーカーを使うと必ずデータの整合性が保証される", misconception: "耐障害性パターンをデータ整合性と混同",
                       explanation: "サーキットブレーカーは可用性向上のパターンです。データ整合性は別途考慮が必要です。")
            ],
            explanationRef: "explain-boot3-arch-ms-circuit-breaker-001",
            designIntent: "サーキットブレーカーパターンとフォールバックによる障害耐性を理解する。"
        ),
        quiz(
            id: "boot3-arch-ms-saga-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["Saga", "分散トランザクション", "補償トランザクション"],
            code: """
// コレオグラフィーSagaのイベントフロー
// 1. OrderService: OrderPlaced イベント発行
// 2. InventoryService: 在庫引当 → InventoryReserved
// 3. PaymentService: 決済処理 → PaymentConfirmed
// 4. (失敗時) PaymentFailed → InventoryService が在庫を戻す補償
""",
            question: "Sagaパターンにおける「補償トランザクション」の役割として正しいものはどれか？",
            choices: [
                choice("a", "分散トランザクションの一部が失敗した際に、それ以前のステップの変更を打ち消す逆操作を実行する", correct: true,
                       explanation: "2フェーズコミットが使えないマイクロサービスでは、Sagaの補償トランザクションで結果整合性を実現します。"),
                choice("b", "補償トランザクションは2フェーズコミットと同等の強い整合性を保証する", misconception: "Sagaの整合性モデルを誤解",
                       explanation: "Sagaは結果整合性モデルです。ロールバック中に読まれた中間状態は見える可能性があります。"),
                choice("c", "Sagaはモノリシックアプリでのみ使用できる", misconception: "Sagaの適用範囲を誤解",
                       explanation: "Sagaはマイクロサービスなど分散システムでの長期トランザクション管理に特に有用です。"),
                choice("d", "補償トランザクションが失敗した場合、Springが自動で再試行する", misconception: "Sagaの補償失敗を自動回復と誤解",
                       explanation: "補償の失敗は人手介入やデッドレタートピックへの転送など、別途対処が必要です。")
            ],
            explanationRef: "explain-boot3-arch-ms-saga-001",
            designIntent: "Sagaパターンと補償トランザクションによる分散システムの整合性管理を理解する。"
        ),
    ]

    // MARK: - 設計パターン
    private static let archDesignPatterns: [Quiz] = [
        quiz(
            id: "boot3-arch-pattern-facade-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["Facade", "BFF", "クライアント向けAPI"],
            code: """
@Service
class OrderFacade {
    private final OrderService orderService;
    private final CustomerService customerService;
    private final InventoryService inventoryService;

    OrderDetailResponse getOrderDetail(Long orderId) {
        Order order = orderService.findById(orderId);
        Customer customer = customerService.findById(order.customerId());
        Inventory inv = inventoryService.checkAll(order.items());
        return OrderDetailResponse.compose(order, customer, inv);
    }
}
""",
            question: "このFacadeパターンの利点として正しいものはどれか？",
            choices: [
                choice("a", "複数サービスの呼び出しを集約してControllerを薄くし、クライアントが必要なデータを一度に取得できる", correct: true,
                       explanation: "FacadeはAPIクライアントにとって複雑なサブシステムの組み合わせを隠蔽します。BFF（Backend for Frontend）パターンにも通じます。"),
                choice("b", "Facadeを使うとトランザクション管理が不要になる", misconception: "Facadeがトランザクション制御を代替すると誤解",
                       explanation: "Facadeはサービス呼び出しの集約です。トランザクション管理は依然として必要です。"),
                choice("c", "FacadeはServiceを直接extends（継承）して作る必要がある", misconception: "コンポジションと継承を混同",
                       explanation: "Facadeは通常コンポジション（依存注入）で実装します。"),
                choice("d", "FacadeパターンはController層には使えない", misconception: "Facadeの使用場所を誤解",
                       explanation: "FacadeはControllerから呼ばれるService層に配置するのが一般的です。")
            ],
            explanationRef: "explain-boot3-arch-pattern-facade-001",
            designIntent: "Facadeパターンによるサービス集約とController薄型化を理解する。"
        ),
        quiz(
            id: "boot3-arch-pattern-strategy-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["Strategyパターン", "OCP", "DI活用"],
            code: """
interface DiscountStrategy {
    BigDecimal apply(BigDecimal price, Customer customer);
}

@Component("vipDiscount")
class VipDiscountStrategy implements DiscountStrategy { /* 20%引き */ }

@Component("regularDiscount")
class RegularDiscountStrategy implements DiscountStrategy { /* 5%引き */ }

@Service
class PriceService {
    private final Map<String, DiscountStrategy> strategies;

    PriceService(Map<String, DiscountStrategy> strategies) {
        this.strategies = strategies;
    }

    BigDecimal calculate(Customer customer, BigDecimal price) {
        return strategies.get(customer.type()).apply(price, customer);
    }
}
""",
            question: "このStrategyパターンのSpring DI活用について正しい説明はどれか？",
            choices: [
                choice("a", "Springが同じインターフェースの実装をMap（Bean名→インスタンス）で自動注入し、if-else分岐なしに戦略を切り替えられる", correct: true,
                       explanation: "Spring DIでは `Map<String, Interface>` 型の引数にBean名をキーとした実装Mapが注入されます。Strategyの追加がOCP（開放閉鎖原則）に従って拡張できます。"),
                choice("b", "`Map<String, DiscountStrategy>` 型の注入はSpringではサポートされない", misconception: "MapへのBean注入を知らない",
                       explanation: "Spring DIはコレクション型への注入をサポートします。"),
                choice("c", "Strategyパターンを使うとすべてのStrategyをシングルトンにできない", misconception: "Strategyのスコープを誤解",
                       explanation: "ステートレスなStrategyはシングルトンが適切で、Springの既定スコープと合います。"),
                choice("d", "StrategyパターンはController層にのみ適用できる", misconception: "Strategyの適用層を制限",
                       explanation: "Strategyパターンはサービス層、ドメイン層など様々な場所に適用できます。")
            ],
            explanationRef: "explain-boot3-arch-pattern-strategy-001",
            designIntent: "StrategyパターンとSpring DIの組み合わせによる拡張可能な設計を理解する。"
        ),
        quiz(
            id: "boot3-arch-pattern-decorator-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["Decoratorパターン", "横断的関心事", "AOP"],
            code: """
@Service
@Primary
class CachingOrderRepository implements OrderRepository {
    private final OrderRepository delegate;
    private final Cache cache;

    @Override
    public Optional<Order> findById(OrderId id) {
        return cache.computeIfAbsent(id, () -> delegate.findById(id));
    }
}
""",
            question: "このDecoratorパターンの設計上の特徴として正しいものはどれか？",
            choices: [
                choice("a", "既存の `OrderRepository` 実装に変更なくキャッシュ機能を追加し、呼び出し元のコードも変えない", correct: true,
                       explanation: "Decoratorは委譲パターンで機能を横から追加します。`@Primary` で注入優先度を上げ、内部で本来の実装へ委譲します。"),
                choice("b", "DecoratorはAOPと同じでSpring AOPを使わずに実装できない", misconception: "DecoratorとAOPを同一視",
                       explanation: "Decoratorは明示的な委譲で実装するGoFパターンで、AOPとは独立して実装できます。"),
                choice("c", "`@Primary` を付けると本来のBeanが削除される", misconception: "@Primaryの挙動を誤解",
                       explanation: "`@Primary` は注入時の優先度を上げるだけで、他のBeanは削除されません。"),
                choice("d", "DecoratorパターンはJavaでは実装できない", misconception: "GoFパターンのJava適用を否定",
                       explanation: "Decoratorは委譲でどの言語でも実装できます。")
            ],
            explanationRef: "explain-boot3-arch-pattern-decorator-001",
            designIntent: "DecoratorパターンとSpring DIを組み合わせた機能拡張を理解する。"
        ),
    ]

    // MARK: - パフォーマンス / スケーラビリティ
    private static let archPerformance: [Quiz] = [
        quiz(
            id: "boot3-arch-perf-caching-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["@Cacheable", "キャッシュ", "パフォーマンス"],
            code: """
@Service
class ProductService {
    @Cacheable(value = "products", key = "#id")
    public Product findById(Long id) {
        return productRepository.findById(id).orElseThrow();
    }

    @CacheEvict(value = "products", key = "#product.id")
    public void update(Product product) {
        productRepository.save(product);
    }
}
""",
            question: "`@Cacheable` と `@CacheEvict` の組み合わせについて正しい説明はどれか？",
            choices: [
                choice("a", "`@Cacheable` は初回のみDBを照会して結果をキャッシュし、`@CacheEvict` は更新時にキャッシュを削除してデータ不整合を防ぐ", correct: true,
                       explanation: "キャッシュの読み書きと無効化をアノテーションで宣言的に管理できます。`@CachePut` で更新と同時にキャッシュを更新するパターンもあります。"),
                choice("b", "`@Cacheable` を付けると毎回DBに問い合わせてキャッシュを更新する", misconception: "CacheableとCachePutを混同",
                       explanation: "`@Cacheable` はキャッシュヒット時はDBを照会しません。"),
                choice("c", "Spring Bootのキャッシュは必ずRedisが必要", misconception: "キャッシュプロバイダーの選択肢を誤解",
                       explanation: "既定ではJVMのConcurrentHashMapを使うSimpleキャッシュが使われます。RedisやEhCacheなど差し替え可能です。"),
                choice("d", "`@CacheEvict` を付けたメソッドはトランザクション内で動作できない", misconception: "キャッシュとトランザクションの関係を誤解",
                       explanation: "`@CacheEvict` と `@Transactional` は組み合わせ可能ですが、トランザクション完了前のキャッシュ削除に注意が必要です。")
            ],
            explanationRef: "explain-boot3-arch-perf-caching-001",
            designIntent: "Spring Cacheアノテーションによる宣言的キャッシング戦略を理解する。"
        ),
        quiz(
            id: "boot3-arch-perf-async-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["@Async", "非同期処理", "CompletableFuture"],
            code: """
@Service
class NotificationService {
    @Async
    public CompletableFuture<Void> sendWelcomeEmail(String email) {
        mailClient.send(email, "ようこそ！");
        return CompletableFuture.completedFuture(null);
    }
}

@SpringBootApplication
@EnableAsync
class App {}
""",
            question: "`@Async` と `@EnableAsync` について正しい説明はどれか？",
            choices: [
                choice("a", "`@EnableAsync` でアプリ全体の非同期処理を有効にし、`@Async` を付けたメソッドは別スレッドプールで実行される", correct: true,
                       explanation: "`@EnableAsync` がなければ `@Async` は無視されます。既定はSimpleAsyncTaskExecutorですが、本番向けにはThreadPoolTaskExecutorを設定します。"),
                choice("b", "`@Async` を付けると戻り値は必ずvoidになる", misconception: "Asyncの戻り値の選択肢を誤解",
                       explanation: "`void`、`Future<T>`、`CompletableFuture<T>` などが使えます。"),
                choice("c", "同一クラス内の別メソッドから呼ぶと非同期になる", misconception: "self invocationの問題を見落としている",
                       explanation: "SpringのAOPプロキシを経由しない自己呼び出しでは `@Async` が効きません。"),
                choice("d", "`@Async` が付いたメソッドは必ずHTTPリクエストスコープの外で実行されるため、セッションは利用できない", misconception: "部分的に正しいが過度に制限的",
                       explanation: "別スレッドのためリクエストスコープのBeanには注意が必要ですが、`@Async` 自体がセッションを禁止するわけではありません。")
            ],
            explanationRef: "explain-boot3-arch-perf-async-001",
            designIntent: "Spring @Asyncによる非同期処理とスレッドプール設定を理解する。"
        ),
        quiz(
            id: "boot3-arch-perf-pagination-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["Pageable", "Page", "Slice", "大量データ"],
            code: """
@GetMapping("/products")
Page<ProductResponse> list(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "20") int size
) {
    Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
    return productRepository.findAll(pageable)
        .map(ProductResponse::from);
}
""",
            question: "`Page<T>` と `Slice<T>` の違いとして正しいものはどれか？",
            choices: [
                choice("a", "`Page<T>` は総件数クエリを発行して全ページ数を計算する。`Slice<T>` は次ページの有無だけを返し、総件数クエリが不要", correct: true,
                       explanation: "膨大なデータで `Page` の `COUNT(*)` が遅い場合、`Slice` で「次ページあり/なし」の返却に絞るとパフォーマンスが改善します。"),
                choice("b", "`Page<T>` は1件しか返せない", misconception: "Pageの意味を誤解",
                       explanation: "`Page<T>` はリストと総件数・ページ情報を含むコンテナです。"),
                choice("c", "`Slice<T>` はソートができない", misconception: "SliceとPageの機能差を誤解",
                       explanation: "`Slice` もPageableのSort情報を使えます。"),
                choice("d", "Spring Data JPAはPageableをコントローラー引数として受け取れない", misconception: "HandlerMethodArgumentResolverのPageable解決を知らない",
                       explanation: "`@PageableDefault` などで `Pageable` をコントローラー引数として受け取れます。")
            ],
            explanationRef: "explain-boot3-arch-perf-pagination-001",
            designIntent: "ページングAPIの設計とPageとSliceの使い分けを理解する。"
        ),
    ]
}
