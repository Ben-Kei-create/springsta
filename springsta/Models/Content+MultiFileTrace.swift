import Foundation

/// ファイル横断的な問題 — 複数ファイルにまたがるコードを CodeFile タブで表示し、
/// 実行フロー・依存関係・設計を問う問題セット
extension Quiz {
    static let multiFileTraceQuizzes: [Quiz] = (
        mfSecurity + mfJpaService + mfAsync + mfBatch + mfErrorFlow
    ).map { $0.contextualizedForPresentation() }

    // MARK: - Security + JWT フィルターチェーン
    private static let mfSecurity: [Quiz] = [
        quiz(
            id: "boot3-mf-security-jwt-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["JWT", "OncePerRequestFilter", "SecurityFilterChain", "ファイル横断"],
            code: mfJwtCombinedCode,
            codeTabs: mfJwtTabs,
            question: "`GET /api/orders` へJWTなしでリクエストした場合のフロー順として正しいものはどれか？",
            choices: [
                choice("a", "JwtFilter → トークンなし → SecurityContextHolderに認証情報なし → SecurityFilterChain → anyRequest().authenticated() → 401", correct: true,
                       explanation: "`JwtFilter`でAuthorizationヘッダが検出されない場合、SecurityContextHolderに認証情報が設定されません。その後 `anyRequest().authenticated()` のチェックで未認証とみなされ401が返ります。"),
                choice("b", "OrderController → Service → Repository → 401", misconception: "Filterがスキップされてコントローラーに到達すると誤解",
                       explanation: "FilterはControllerより前に実行されます。認証が通らなければControllerには到達しません。"),
                choice("c", "JwtFilter → SecurityFilterChain → OrderController → 401が返る", misconception: "Controllerが401を返すと誤解",
                       explanation: "401はSecurityフィルターがControllerへの到達前に返します。"),
                choice("d", "JwtFilterでNullPointerExceptionが発生する", misconception: "トークンなしでNPEが出ると誤解",
                       explanation: "適切に実装されたJwtFilterはトークン未存在を判定してスキップします。")
            ],
            explanationRef: "explain-boot3-mf-security-jwt-001",
            designIntent: "JWTフィルターとSecurityFilterChainを横断した認証フローを追う。"
        ),
        quiz(
            id: "boot3-mf-security-jwt-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["JWT", "@PreAuthorize", "ROLE", "ファイル横断"],
            code: mfJwtCombinedCode,
            codeTabs: mfJwtTabs,
            question: "有効なJWTを持つが `ROLE_USER` のユーザーが `GET /api/admin/stats` にアクセスした場合のフローとして正しいものはどれか？",
            choices: [
                choice("a", "JwtFilter → 認証成功 → SecurityContextHolder設定 → SecurityFilterChain通過 → @PreAuthorize(\"hasRole('ADMIN')\") → 403 Forbidden", correct: true,
                       explanation: "認証は成功しますが、管理者エンドポイントに必要な`ROLE_ADMIN`がないためメソッドセキュリティで403が返ります。"),
                choice("b", "JwtFilterで401が返る", misconception: "有効なJWTでも401になると誤解",
                       explanation: "有効なJWTならJwtFilterは認証情報をSecurityContextに設定します。"),
                choice("c", "SpringはROLE_ADMINを自動付与する", misconception: "Springが権限を自動付与すると誤解",
                       explanation: "権限はJWTのclaimsなどからUserDetailsServiceが設定します。"),
                choice("d", "`anyRequest().authenticated()`でROLE_ADMINも検証される", misconception: "authenticatedとhasRoleを混同",
                       explanation: "`authenticated()`は認証済みかどうかのみを確認します。ロール確認は`@PreAuthorize`や`hasRole()`で行います。")
            ],
            explanationRef: "explain-boot3-mf-security-jwt-002",
            designIntent: "認証成功後の認可（@PreAuthorize）フローをファイル横断で追う。"
        ),
    ]

    // MARK: - JPA + Service + Transaction
    private static let mfJpaService: [Quiz] = [
        quiz(
            id: "boot3-mf-jpa-service-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Transactional", "N+1", "Fetch Join", "ファイル横断"],
            code: mfJpaServiceCombinedCode,
            codeTabs: mfJpaServiceTabs,
            question: "`GET /orders` を呼んだ際にN+1問題が発生するコードの箇所はどれか？",
            choices: [
                choice("a", "`OrderService.findAll()` でLAZY関連の `items` にループ内でアクセスしているため、Order件数+1回のSQLが発生する", correct: true,
                       explanation: "`findAll()` でOrderリストを取得後、`order.getItems()` でLAZYな `items` を参照するとOrder件数分の追加SQLが走ります。Fetch JoinまたはEntityGraphで事前取得します。"),
                choice("b", "`OrderController.list()` でN+1が発生する", misconception: "N+1発生箇所をControllerと誤解",
                       explanation: "ControllerはServiceを呼ぶだけで、SQLが実行されるのはServiceやRepository層です。"),
                choice("c", "`OrderRepository.findAll()` 自体がN+1を起こす", misconception: "findAll自体がN+1の原因と誤解",
                       explanation: "`findAll`はOrderを取得するだけです。N+1はその後のLAZY関連アクセスが引き金です。"),
                choice("d", "`@Transactional(readOnly=true)`があれば自動でFetch Joinが適用される", misconception: "readOnlyでFetch Joinが自動適用されると誤解",
                       explanation: "`readOnly=true`はフラッシュを抑制する最適化です。Fetch Joinの適用には明示的なクエリが必要です。")
            ],
            explanationRef: "explain-boot3-mf-jpa-service-001",
            designIntent: "Controller→Service→Repositoryを横断してN+1問題の発生箇所を特定する。"
        ),
        quiz(
            id: "boot3-mf-jpa-service-002",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Transactional", "self-invocation", "proxy", "ファイル横断"],
            code: mfSelfInvocationCombinedCode,
            codeTabs: mfSelfInvocationTabs,
            question: "このコードで `cancelAndNotify()` 経由で `cancel()` を呼んだ場合、トランザクションはどうなるか？",
            choices: [
                choice("a", "`cancelAndNotify()` → `this.cancel()` の自己呼び出しはプロキシを通らないため、`cancel()` の `@Transactional` が効かず、ロールバックが期待通りに機能しない", correct: true,
                       explanation: "Spring AOPはプロキシ経由で `@Transactional` を適用します。同じクラス内からの直接呼び出し（`this.cancel()`）はプロキシをバイパスします。"),
                choice("b", "`cancelAndNotify()` に `@Transactional` がないためビルドエラー", misconception: "全メソッドに@Transactionalが必要と誤解",
                       explanation: "必ずしも全メソッドに `@Transactional` は不要です。問題はself invocationです。"),
                choice("c", "`cancel()` はpublicなのでプロキシが適用される", misconception: "アクセス修飾子とプロキシ適用を混同",
                       explanation: "publicメソッドでも同じクラスからの直接呼び出しはプロキシを経由しません。"),
                choice("d", "`@Service`アノテーションがないとトランザクションが効かない", misconception: "@ServiceとTransactionalの関係を誤解",
                       explanation: "`@Transactional`は`@Service`がなくても機能します。問題はself invocationです。")
            ],
            explanationRef: "explain-boot3-mf-jpa-service-002",
            designIntent: "ファイル横断でself invocationとトランザクションプロキシの関係を追う。"
        ),
    ]

    // MARK: - Async + Event
    private static let mfAsync: [Quiz] = [
        quiz(
            id: "boot3-mf-async-event-001",
            level: .practice,
            objective: "boot3-practice-architecture",
            category: .architecture,
            tags: ["@Async", "ApplicationEvent", "ファイル横断", "非同期"],
            code: mfAsyncEventCombinedCode,
            codeTabs: mfAsyncEventTabs,
            question: "`OrderService.placeOrder()` が完了後、メール通知のタイミングとして正しいものはどれか？",
            choices: [
                choice("a", "トランザクションのコミット後に `@TransactionalEventListener` が別スレッドで非同期実行されるため、placeOrder()の完了後にメールが送られる", correct: true,
                       explanation: "`@Async` + `@TransactionalEventListener` により、注文保存のトランザクションがコミットしてから非同期でメール送信が実行されます。ロールバック時にはメールは送られません。"),
                choice("b", "`placeOrder()` の途中でメールが送信される", misconception: "イベントの発行タイミングを誤解",
                       explanation: "`@TransactionalEventListener`のデフォルトは`AFTER_COMMIT`フェーズです。"),
                choice("c", "`@Async`を付けるとメールが送信されなくなる", misconception: "@Asyncの動作を誤解",
                       explanation: "`@Async`は別スレッドでの非同期実行を意味します。メール送信は別スレッドで実行されます。"),
                choice("d", "注文がDBに保存される前にメールが送信される", misconception: "トランザクション完了前にイベントが発火すると誤解",
                       explanation: "`AFTER_COMMIT`はコミット後のフェーズです。保存前の送信にはなりません。")
            ],
            explanationRef: "explain-boot3-mf-async-event-001",
            designIntent: "ドメインイベント＋@Async＋@TransactionalEventListenerのファイル横断フローを追う。"
        ),
    ]

    // MARK: - Batch + Scheduling
    private static let mfBatch: [Quiz] = [
        quiz(
            id: "boot3-mf-batch-scheduler-001",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .architecture,
            tags: ["@Scheduled", "JobLauncher", "ファイル横断", "Batch"],
            code: mfBatchSchedulerCombinedCode,
            codeTabs: mfBatchSchedulerTabs,
            question: "毎日深夜2時にバッチが起動するとき、実行順序として正しいものはどれか？",
            choices: [
                choice("a", "@Scheduled → JobLauncher.run() → Job → Step → ItemReader → ItemProcessor → ItemWriter → コミット", correct: true,
                       explanation: "`@Scheduled`メソッドがトリガーとなり`JobLauncher`でJobを起動します。JobはStepを実行し、チャンクごとにread→process→write→commitが繰り返されます。"),
                choice("b", "ItemReader → Job → @Scheduled → JobLauncher → コミット", misconception: "実行フローの順序を誤解",
                       explanation: "ItemReaderはJobがStepを実行して初めて呼ばれます。@Scheduledが出発点です。"),
                choice("c", "JobLauncherがItemWriterを直接呼ぶ", misconception: "JobとItemWriterの直接関係を誤解",
                       explanation: "JobLauncherはJobを起動するだけで、ItemWriterはStepのチャンク処理の一部です。"),
                choice("d", "@ScheduledはJobRepositoryとは無関係に実行される", misconception: "@ScheduledがBatch管理外と誤解",
                       explanation: "`JobLauncher.run()`がJobRepositoryにJob実行状態を記録します。")
            ],
            explanationRef: "explain-boot3-mf-batch-scheduler-001",
            designIntent: "@ScheduledとSpring Batchを組み合わせた実行フローをファイル横断で追う。"
        ),
    ]

    // MARK: - エラーフロー（横断）
    private static let mfErrorFlow: [Quiz] = [
        quiz(
            id: "boot3-mf-error-flow-001",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .errorReading,
            tags: ["例外伝播", "@ControllerAdvice", "ファイル横断", "エラーハンドリング"],
            code: mfErrorFlowCombinedCode,
            codeTabs: mfErrorFlowTabs,
            question: "`OrderService.create()` で `ProductNotFoundException` が投げられた場合のHTTPレスポンスはどれか？",
            choices: [
                choice("a", "`@RestControllerAdvice` の `handleProductNotFound()` が 404 を返す", correct: true,
                       explanation: "`ProductNotFoundException` はServiceから伝播し、`@RestControllerAdvice` がキャッチして適切なHTTPレスポンスに変換します。Controller自体には例外処理コードが不要です。"),
                choice("b", "500 Internal Server Errorが自動的に返る", misconception: "@ControllerAdviceがない場合の動作と混同",
                       explanation: "`@RestControllerAdvice`に`ProductNotFoundException`のハンドラーがある場合、500ではなく設定したステータスが返ります。"),
                choice("c", "`OrderController.create()`でtry-catchしなければ404は返らない", misconception: "Controllerでtry-catchが必須と誤解",
                       explanation: "`@RestControllerAdvice`があればController側でtry-catchは不要です。"),
                choice("d", "`@Transactional` があるためコミット後に例外が握りつぶされる", misconception: "Transactionalが例外を吸収すると誤解",
                       explanation: "`@Transactional`はRuntimeExceptionでロールバックしますが、例外自体は呼び出し元へ伝播します。")
            ],
            explanationRef: "explain-boot3-mf-error-flow-001",
            designIntent: "Service例外→Controller→@ControllerAdviceへの伝播をファイル横断で追う。"
        ),
        quiz(
            id: "boot3-mf-error-flow-002",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .errorReading,
            tags: ["@Valid", "MethodArgumentNotValidException", "@ExceptionHandler", "ファイル横断"],
            code: mfValidationFlowCombinedCode,
            codeTabs: mfValidationFlowTabs,
            question: "emailが空のリクエストを送信した場合、どのクラスで処理されるか？",
            choices: [
                choice("a", "`GlobalExceptionHandler.handleValidation()` がバリデーションエラーを捕捉し、400レスポンスを返す", correct: true,
                       explanation: "`@Valid` がController引数で失敗すると `MethodArgumentNotValidException` が投げられ、`@RestControllerAdvice` で定義したハンドラーがキャッチして400を返します。"),
                choice("b", "`CreateOrderRequest` のコンストラクタで例外が発生する", misconception: "Bean Validationの発火タイミングを誤解",
                       explanation: "Bean Validationは `@Valid` のついた引数をバインド後に検証します。コンストラクタではありません。"),
                choice("c", "`OrderService.create()` がバリデーションを実行する", misconception: "ControllerとService層のバリデーション実施箇所を誤解",
                       explanation: "`@Valid` はController引数レベルで発火します。Serviceに到達する前に止まります。"),
                choice("d", "`OrderRepository` がNULL制約違反で例外を出す", misconception: "DBレベルの制約違反とBean Validationを混同",
                       explanation: "Bean Validationは `@Valid` でController境界で実行されます。DBには到達しません。")
            ],
            explanationRef: "explain-boot3-mf-error-flow-002",
            designIntent: "@Valid → @ControllerAdviceへのバリデーションエラーフローをファイル横断で追う。"
        ),
    ]

    // MARK: - Multi-file code content

    static let mfJwtCombinedCode = """
// JwtFilter.java
@Component
class JwtFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response, FilterChain chain) {
        String token = extractToken(request);
        if (token != null && jwtUtil.validate(token)) {
            Authentication auth = jwtUtil.getAuthentication(token);
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        chain.doFilter(request, response);
    }
}

// SecurityConfig.java
@Bean
SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
        .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/admin/**").hasRole("ADMIN")
            .anyRequest().authenticated()
        ).build();
}
"""

    static let mfJwtTabs: [CodeFile] = [
        CodeFile(filename: "JwtFilter.java", code: """
@Component
class JwtFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response, FilterChain chain) {
        String token = extractToken(request);
        if (token != null && jwtUtil.validate(token)) {
            Authentication auth = jwtUtil.getAuthentication(token);
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        chain.doFilter(request, response);
    }
}
"""),
        CodeFile(filename: "SecurityConfig.java", code: """
@Bean
SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
        .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/api/admin/**").hasRole("ADMIN")
            .anyRequest().authenticated()
        ).build();
}
"""),
        CodeFile(filename: "OrderController.java", code: """
@RestController
@RequestMapping("/api")
class OrderController {
    @GetMapping("/orders")
    List<OrderResponse> list() { return service.findAll(); }

    @GetMapping("/admin/stats")
    @PreAuthorize("hasRole('ADMIN')")
    StatsResponse stats() { return statsService.get(); }
}
"""),
    ]

    static let mfJpaServiceCombinedCode = """
// OrderController.java
@GetMapping("/orders")
List<OrderResponse> list() {
    return orderService.findAll();
}

// OrderService.java
@Transactional(readOnly = true)
public List<OrderResponse> findAll() {
    List<Order> orders = orderRepository.findAll();
    return orders.stream()
        .map(o -> new OrderResponse(o.getId(), o.getItems())) // LAZY items!
        .toList();
}

// Order.java (@Entity)
@OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
private List<OrderItem> items;
"""

    static let mfJpaServiceTabs: [CodeFile] = [
        CodeFile(filename: "OrderController.java", code: """
@RestController
@RequestMapping("/orders")
class OrderController {
    @GetMapping
    List<OrderResponse> list() {
        return orderService.findAll();
    }
}
"""),
        CodeFile(filename: "OrderService.java", code: """
@Service
class OrderService {
    @Transactional(readOnly = true)
    public List<OrderResponse> findAll() {
        List<Order> orders = orderRepository.findAll();
        return orders.stream()
            .map(o -> new OrderResponse(o.getId(), o.getItems())) // N+1 ここ!
            .toList();
    }
}
"""),
        CodeFile(filename: "Order.java", code: """
@Entity
class Order {
    @Id @GeneratedValue Long id;

    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<OrderItem> items; // LAZY ロード
}
"""),
    ]

    static let mfSelfInvocationCombinedCode = """
// OrderService.java
@Service
class OrderService {
    // 自己呼び出しでtransactionalが効かない
    public void cancelAndNotify(Long orderId) {
        cancel(orderId);  // this.cancel() = プロキシを通らない
        notificationService.sendCancel(orderId);
    }

    @Transactional
    public void cancel(Long orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow();
        order.cancel();
        orderRepository.save(order);
    }
}
"""

    static let mfSelfInvocationTabs: [CodeFile] = [
        CodeFile(filename: "OrderService.java", code: """
@Service
class OrderService {
    private final OrderRepository orderRepository;
    private final NotificationService notificationService;

    // @Transactionalなし
    public void cancelAndNotify(Long orderId) {
        cancel(orderId);  // ← self invocation! プロキシを経由しない
        notificationService.sendCancel(orderId);
    }

    @Transactional  // ← cancelAndNotifyから呼ばれる場合は無効
    public void cancel(Long orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow();
        order.cancel();
        orderRepository.save(order);
    }
}
"""),
        CodeFile(filename: "OrderController.java", code: """
@RestController
class OrderController {
    @DeleteMapping("/orders/{id}")
    void cancel(@PathVariable Long id) {
        orderService.cancelAndNotify(id); // Serviceを経由して呼ぶ
    }
}
"""),
    ]

    static let mfAsyncEventCombinedCode = """
// OrderService.java
@Transactional
public Order placeOrder(CreateOrderCommand cmd) {
    Order order = Order.create(cmd);
    orderRepository.save(order);
    eventPublisher.publishEvent(new OrderPlaced(order.id()));
    return order;
}

// NotificationListener.java
@Async
@TransactionalEventListener
public void on(OrderPlaced event) {
    mailService.sendConfirmation(event.orderId()); // コミット後に実行
}
"""

    static let mfAsyncEventTabs: [CodeFile] = [
        CodeFile(filename: "OrderService.java", code: """
@Service
class OrderService {
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public Order placeOrder(CreateOrderCommand cmd) {
        Order order = Order.create(cmd);
        orderRepository.save(order);
        eventPublisher.publishEvent(new OrderPlaced(order.id()));
        return order; // ← コミット後にリスナーが起動
    }
}
"""),
        CodeFile(filename: "NotificationListener.java", code: """
@Component
class NotificationListener {
    @Async
    @TransactionalEventListener // デフォルト: AFTER_COMMIT
    public void on(OrderPlaced event) {
        mailService.sendConfirmation(event.orderId());
    }
}
"""),
        CodeFile(filename: "OrderPlaced.java", code: """
record OrderPlaced(Long orderId) {}
"""),
    ]

    static let mfBatchSchedulerCombinedCode = """
// DailyReportScheduler.java
@Scheduled(cron = "0 0 2 * * *")
void run() throws Exception {
    jobLauncher.run(reportJob, new JobParametersBuilder()
        .addLocalDateTime("runAt", LocalDateTime.now())
        .toJobParameters());
}

// ReportJobConfig.java
@Bean Job reportJob(...) { return ...; }

@Bean Step reportStep(...) {
    return new StepBuilder("report", jobRepository)
        .<ReportRow, ReportRecord>chunk(500, txManager)
        .reader(reader).processor(processor).writer(writer)
        .build();
}
"""

    static let mfBatchSchedulerTabs: [CodeFile] = [
        CodeFile(filename: "DailyReportScheduler.java", code: """
@Component
class DailyReportScheduler {
    private final JobLauncher jobLauncher;
    private final Job reportJob;

    @Scheduled(cron = "0 0 2 * * *") // 毎日深夜2時
    void run() throws Exception {
        jobLauncher.run(reportJob, new JobParametersBuilder()
            .addLocalDateTime("runAt", LocalDateTime.now())
            .toJobParameters());
    }
}
"""),
        CodeFile(filename: "ReportJobConfig.java", code: """
@Configuration
class ReportJobConfig {
    @Bean
    Job reportJob(JobRepository repo, Step reportStep) {
        return new JobBuilder("reportJob", repo).start(reportStep).build();
    }

    @Bean
    Step reportStep(JobRepository repo, PlatformTransactionManager tx,
                    ItemReader<ReportRow> reader,
                    ItemProcessor<ReportRow, ReportRecord> processor,
                    ItemWriter<ReportRecord> writer) {
        return new StepBuilder("reportStep", repo)
            .<ReportRow, ReportRecord>chunk(500, tx)
            .reader(reader).processor(processor).writer(writer).build();
    }
}
"""),
    ]

    static let mfErrorFlowCombinedCode = """
// OrderController.java
@PostMapping("/orders")
ResponseEntity<OrderResponse> create(@RequestBody CreateOrderRequest req) {
    return ResponseEntity.ok(orderService.create(req));
}

// OrderService.java
public OrderResponse create(CreateOrderRequest req) {
    Product product = productRepository.findById(req.productId())
        .orElseThrow(() -> new ProductNotFoundException(req.productId()));
    ...
}

// GlobalExceptionHandler.java
@ExceptionHandler(ProductNotFoundException.class)
ResponseEntity<ErrorResponse> handleProductNotFound(ProductNotFoundException ex) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
        .body(new ErrorResponse(ex.getMessage()));
}
"""

    static let mfErrorFlowTabs: [CodeFile] = [
        CodeFile(filename: "OrderController.java", code: """
@RestController
class OrderController {
    @PostMapping("/orders")
    ResponseEntity<OrderResponse> create(@RequestBody CreateOrderRequest req) {
        return ResponseEntity.ok(orderService.create(req));
        // 例外はControllerAdviceに伝播
    }
}
"""),
        CodeFile(filename: "OrderService.java", code: """
@Service
class OrderService {
    @Transactional
    public OrderResponse create(CreateOrderRequest req) {
        Product product = productRepository.findById(req.productId())
            .orElseThrow(() -> new ProductNotFoundException(req.productId()));
        // ...
    }
}
"""),
        CodeFile(filename: "GlobalExceptionHandler.java", code: """
@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(ProductNotFoundException.class)
    ResponseEntity<ErrorResponse> handleProductNotFound(ProductNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(ex.getMessage()));
    }
}
"""),
    ]

    static let mfValidationFlowCombinedCode = """
// OrderController.java
@PostMapping("/orders")
ResponseEntity<OrderResponse> create(@Valid @RequestBody CreateOrderRequest req) {
    return ResponseEntity.ok(orderService.create(req));
}

// CreateOrderRequest.java
record CreateOrderRequest(@NotBlank String email, @NotNull Long productId) {}

// GlobalExceptionHandler.java
@ExceptionHandler(MethodArgumentNotValidException.class)
ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
    return ResponseEntity.badRequest()
        .body(ErrorResponse.from(ex.getBindingResult()));
}
"""

    static let mfValidationFlowTabs: [CodeFile] = [
        CodeFile(filename: "OrderController.java", code: """
@RestController
class OrderController {
    @PostMapping("/orders")
    ResponseEntity<OrderResponse> create(@Valid @RequestBody CreateOrderRequest req) {
        return ResponseEntity.ok(orderService.create(req));
    }
}
"""),
        CodeFile(filename: "CreateOrderRequest.java", code: """
record CreateOrderRequest(
    @NotBlank String email,
    @NotNull Long productId
) {}
"""),
        CodeFile(filename: "GlobalExceptionHandler.java", code: """
@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        return ResponseEntity.badRequest()
            .body(ErrorResponse.from(ex.getBindingResult()));
    }
}
"""),
    ]
}
