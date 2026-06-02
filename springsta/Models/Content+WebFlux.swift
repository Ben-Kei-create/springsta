import Foundation

extension Quiz {
    static let webFluxQuizzes: [Quiz] = (
        rxBasics + rxOperators + rxWebFlux + rxR2DBC + rxBackpressure
    ).map { $0.contextualizedForPresentation() }

    // MARK: - リアクティブ基礎
    private static let rxBasics: [Quiz] = [
        quiz(
            id: "boot3-rx-basics-001",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["Mono", "Flux", "Publisher", "Reactive Streams"],
            code: """
Mono<User> mono = userRepository.findById(1L);
Flux<User> flux = userRepository.findAll();
""",
            question: "`Mono<T>` と `Flux<T>` の違いとして正しいものはどれか？",
            choices: [
                choice("a", "`Mono<T>` は0〜1件、`Flux<T>` は0〜N件のデータストリームを表すReactive Streamsの`Publisher`", correct: true,
                       explanation: "どちらもProject Reactorが提供する非同期シーケンスです。0件または1件ならMono、複数件を扱うならFluxを使います。"),
                choice("b", "`Mono` は同期的に値を返し、`Flux` は非同期に返す", misconception: "MonoとFluxの非同期性を誤解",
                       explanation: "どちらも非同期・ノンブロッキングです。件数の多寡が主な違いです。"),
                choice("c", "`Flux` はListを返すラッパーに過ぎず、サブスクライブしなくても実行される", misconception: "Fluxが即時評価と誤解",
                       explanation: "Reactorの`Mono`/`Flux`はcold publisherで、subscribeされて初めて処理が開始します。"),
                choice("d", "`Mono<Void>` はエラーを返せない", misconception: "Mono<Void>の用途を誤解",
                       explanation: "`Mono<Void>` も `onError` でエラーシグナルを流せます。")
            ],
            explanationRef: "explain-boot3-rx-basics-001",
            designIntent: "MonoとFluxの基本的な違いとReactive Streamsの概念を理解する。"
        ),
        quiz(
            id: "boot3-rx-basics-002",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["subscribe", "block", "ノンブロッキング"],
            code: """
// ✗ WebFluxアプリで行いがちなアンチパターン
@GetMapping("/users/{id}")
Mono<User> getUser(@PathVariable Long id) {
    User user = userRepository.findById(id).block(); // ブロッキング呼び出し
    return Mono.just(user);
}
""",
            question: "WebFluxアプリで `.block()` を呼ぶことの問題はどれか？",
            choices: [
                choice("a", "イベントループスレッドをブロックしてスループットを著しく下げるアンチパターン", correct: true,
                       explanation: "WebFluxはノンブロッキングI/Oを前提とします。`.block()` はNettyのイベントループをブロックし、スループットの向上が見込めなくなります。"),
                choice("b", "`.block()` はWebFluxでコンパイルエラーになる", misconception: "Blockがコンパイルエラーになると誤解",
                       explanation: "コンパイルは通りますが、実行時に`BlockingOperationError`となる場合があります（リアクタスケジューラーによる）。"),
                choice("c", "WebFluxは必ずKotlinコルーチンを使わなければならない", misconception: "WebFluxの実装言語を限定",
                       explanation: "WebFluxはJavaとKotlinの両方で使えます。Kotlinではコルーチンとの統合も可能です。"),
                choice("d", "`.block()` は読み取り専用操作にのみ安全に使える", misconception: "読み取り専用ならblockが安全と誤解",
                       explanation: "読み取りでもイベントループのブロックは問題です。")
            ],
            explanationRef: "explain-boot3-rx-basics-002",
            designIntent: "WebFluxにおけるblockアンチパターンを理解する。"
        ),
        quiz(
            id: "boot3-rx-basics-003",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["@RestController", "WebFlux", "Mono戻り値"],
            code: """
@RestController
class UserController {
    private final UserRepository repository;

    @GetMapping("/users/{id}")
    Mono<UserResponse> getUser(@PathVariable Long id) {
        return repository.findById(id)
            .map(UserResponse::from)
            .switchIfEmpty(Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND)));
    }
}
""",
            question: "WebFluxのControllerでMono戻り値を返す設計として正しい説明はどれか？",
            choices: [
                choice("a", "Monoを返すことでWebFluxがサブスクライブして非同期にレスポンスを返し、スレッドをブロックしない", correct: true,
                       explanation: "Spring WebFluxはMono/Fluxを直接返すControllerをサポートし、フレームワークがサブスクライブします。ノンブロッキングで処理が完了次第レスポンスが送られます。"),
                choice("b", "WebFluxではControllerのメソッドは必ずvoidを返す", misconception: "WebFluxの戻り値を誤解",
                       explanation: "WebFluxでも`Mono<T>`、`Flux<T>`、Serverless ResponseなどをControllerから返せます。"),
                choice("c", "`switchIfEmpty` はFluxにしか使えない", misconception: "switchIfEmptyのMonoサポートを知らない",
                       explanation: "`switchIfEmpty` はMonoとFluxの両方で使えます。"),
                choice("d", "`ResponseStatusException` はWebFluxでは使えない", misconception: "WebFluxの例外処理を誤解",
                       explanation: "`ResponseStatusException` はWebFluxでも使用可能です。")
            ],
            explanationRef: "explain-boot3-rx-basics-003",
            designIntent: "WebFlux ControllerのMono戻り値によるノンブロッキング処理を理解する。"
        ),
        quiz(
            id: "boot3-rx-basics-004",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["WebFlux", "SpringMVC", "使い分け"],
            code: """
// Spring MVCの選択基準
// ✓ 多くのCRUD処理、チームがブロッキングに慣れている
// ✓ JPAとの統合が多い

// WebFluxの選択基準
// ✓ 高並行、大量接続、ストリーミング
// ✓ リアクティブなマイクロサービス呼び出し
""",
            question: "Spring MVCとWebFluxの使い分けとして最も適切なものはどれか？",
            choices: [
                choice("a", "WebFluxはノンブロッキングI/Oが多いケースで有利だが、JPAなどブロッキングAPIとの相性が悪いため既存エコシステムも考慮する", correct: true,
                       explanation: "JPAはブロッキングAPIです。WebFluxと組み合わせる場合はR2DBCなどリアクティブドライバーが必要です。高スループット要件がない場合はMVCが保守しやすいです。"),
                choice("b", "WebFluxはSpring MVC より常にパフォーマンスが高い", misconception: "WebFluxが常に高速と誤解",
                       explanation: "コンテキストスイッチのオーバーヘッドやブロッキング箇所がある場合はMVCが速いこともあります。"),
                choice("c", "WebFluxはモノリシックアプリには使えない", misconception: "WebFluxの適用対象を制限",
                       explanation: "WebFluxはモノリシックアプリでも使えます。"),
                choice("d", "WebFluxではセキュリティが設定できない", misconception: "WebFluxのセキュリティサポートを否定",
                       explanation: "Spring Security WebFlux（`spring-security-webflux`）が提供されています。")
            ],
            explanationRef: "explain-boot3-rx-basics-004",
            designIntent: "Spring MVCとWebFluxの適切な使い分け基準を理解する。"
        ),
        quiz(
            id: "boot3-rx-basics-005",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["ServerSentEvents", "Flux", "ストリーミング"],
            code: """
@GetMapping(value = "/events", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
Flux<ServerSentEvent<String>> stream() {
    return Flux.interval(Duration.ofSeconds(1))
        .map(i -> ServerSentEvent.<String>builder()
            .id(String.valueOf(i))
            .data("event-" + i)
            .build());
}
""",
            question: "Server-Sent Events（SSE）エンドポイントとしての`Flux`戻り値の説明として正しいものはどれか？",
            choices: [
                choice("a", "`text/event-stream`メディアタイプでFluxが流すデータをHTTPレスポンスとしてサーバーからクライアントへプッシュし続ける", correct: true,
                       explanation: "SSEはHTTPを使った一方向のサーバープッシュです。WebFluxのFluxと組み合わせるとリアルタイムストリーミングAPIを宣言的に実装できます。"),
                choice("b", "SSEはWebSocketと同じ双方向通信", misconception: "SSEとWebSocketを混同",
                       explanation: "SSEはサーバーからクライアントへの一方向です。双方向はWebSocketです。"),
                choice("c", "`Flux.interval`はWebFluxでのみ使え、Spring MVCでは使えない", misconception: "Project ReactorのFluxとWebFluxを混同",
                       explanation: "`Flux.interval`はProject Reactorのoperatorです。Spring MVCでも使えますが、イベントループとの統合はWebFluxが有利です。"),
                choice("d", "SSEエンドポイントはHTTPS環境でのみ動作する", misconception: "SSEのプロトコル要件を誤解",
                       explanation: "SSEはHTTP/HTTPSどちらでも動作します。")
            ],
            explanationRef: "explain-boot3-rx-basics-005",
            designIntent: "WebFluxのServer-Sent Eventsストリーミングを理解する。"
        ),
    ]

    // MARK: - Reactorオペレーター
    private static let rxOperators: [Quiz] = [
        quiz(
            id: "boot3-rx-op-001",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["flatMap", "map", "非同期変換"],
            code: """
// map: 同期変換
Mono<String> name = userMono.map(u -> u.getName());

// flatMap: 非同期変換（Mono/Fluxを返す処理）
Mono<Order> latestOrder = userMono
    .flatMap(u -> orderRepository.findLatestByUserId(u.getId()));
""",
            question: "`map` と `flatMap` の使い分けとして正しいものはどれか？",
            choices: [
                choice("a", "`map`は同期的な値変換に使い、`flatMap`は非同期（Mono/Flux返す）な処理の連鎖に使う", correct: true,
                       explanation: "`flatMap`の`flat`は内側のMonoを平坦化（unwrap）する意味です。非同期のDBアクセスなどMonoを返す処理はflatMapで繋ぎます。"),
                choice("b", "`flatMap`はFluxにしか使えない", misconception: "flatMapのMonoサポートを知らない",
                       explanation: "`Mono.flatMap()`でMonoを返す処理に変換できます。"),
                choice("c", "`map`のほうが非同期処理に向いている", misconception: "mapとflatMapの役割を逆に理解",
                       explanation: "`map`は同期変換です。非同期処理の連鎖には`flatMap`を使います。"),
                choice("d", "`map`ではラムダ式が使えない", misconception: "mapのAPI形式を誤解",
                       explanation: "`map`はラムダ式（Function<T,R>）を引数に取ります。")
            ],
            explanationRef: "explain-boot3-rx-op-001",
            designIntent: "mapとflatMapの使い分けを非同期処理の観点から理解する。"
        ),
        quiz(
            id: "boot3-rx-op-002",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["onErrorReturn", "onErrorResume", "エラーハンドリング"],
            code: """
Mono<User> result = userRepository.findById(id)
    .onErrorReturn(DataAccessException.class, User.anonymous())
    .onErrorResume(ex -> fallbackService.getUser(id));
""",
            question: "`onErrorReturn` と `onErrorResume` の違いとして正しいものはどれか？",
            choices: [
                choice("a", "`onErrorReturn`は固定値を返し、`onErrorResume`は別のMono/Fluxで処理を継続するフォールバック", correct: true,
                       explanation: "`onErrorReturn`はエラー時に即座に値を返します。`onErrorResume`はエラー種別に応じた代替Publisherを返すフォールバック処理に向いています。"),
                choice("b", "`onErrorReturn`は例外を再スローする", misconception: "エラー処理operatorの動作を誤解",
                       explanation: "`onErrorReturn`はエラーを捕捉して代わりの値を発行します。"),
                choice("c", "両方ともFluxにしか使えない", misconception: "エラーhandlerのMonoサポートを知らない",
                       explanation: "`Mono`でも同名のメソッドが使えます。"),
                choice("d", "`onErrorResume`はチェック例外のみに対応する", misconception: "例外タイプの制限を誤解",
                       explanation: "両メソッドとも`Throwable`全般を対象に処理できます。")
            ],
            explanationRef: "explain-boot3-rx-op-002",
            designIntent: "Reactorのエラーハンドリングoperatorの使い分けを理解する。"
        ),
        quiz(
            id: "boot3-rx-op-003",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["zip", "merge", "並行実行"],
            code: """
Mono<Tuple2<User, Order>> combined = Mono.zip(
    userRepository.findById(userId),
    orderRepository.findLatestByUserId(userId)
);
""",
            question: "`Mono.zip`を使う主な目的はどれか？",
            choices: [
                choice("a", "複数の非同期処理を並行実行して全結果が揃ったらTupleとしてまとめる", correct: true,
                       explanation: "`Mono.zip`は複数のMonoを並行にサブスクライブし、全部完了したときに結果をTupleで返します。直列実行より効率的です。"),
                choice("b", "`Mono.zip`はファイルのZIP圧縮を行う", misconception: "zip operatorを圧縮機能と混同",
                       explanation: "ここでのzipはReactive Streamsの「複数ストリームを結合する」意味です。"),
                choice("c", "`Mono.zip`は2つのMonoを直列で実行する", misconception: "並行と直列の実行モデルを混同",
                       explanation: "`Mono.zip`は並行実行です。直列に繋げるには`flatMap`を使います。"),
                choice("d", "`Mono.zip`はFluxとしか組み合わせられない", misconception: "zipの型引数を誤解",
                       explanation: "`Mono.zip`はMonoの組み合わせに使います。")
            ],
            explanationRef: "explain-boot3-rx-op-003",
            designIntent: "Mono.zipによる並行非同期実行パターンを理解する。"
        ),
        quiz(
            id: "boot3-rx-op-004",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["subscribeOn", "publishOn", "スレッドスイッチ"],
            code: """
Mono<String> result = Mono.fromCallable(() -> blockingService.call())
    .subscribeOn(Schedulers.boundedElastic());
""",
            question: "`subscribeOn(Schedulers.boundedElastic())`を使う理由として正しいものはどれか？",
            choices: [
                choice("a", "ブロッキング処理を専用スレッドプールに移してイベントループへの影響を避けるため", correct: true,
                       explanation: "`boundedElastic`はブロッキングI/O専用のスレッドプールです。`subscribeOn`で購読開始スレッドを指定することでNettyのイベントループをブロックしません。"),
                choice("b", "`subscribeOn`でパラメータを渡すと必ず非同期になる", misconception: "subscribeOnの効果を過度に一般化",
                       explanation: "`subscribeOn`は購読するスレッドを指定します。中の処理がブロッキングなら別スレッドでブロックするだけです。"),
                choice("c", "`Schedulers.boundedElastic()`はRxJavaのAPIで、Project Reactorでは使えない", misconception: "RxJavaとProject Reactorを混同",
                       explanation: "`Schedulers.boundedElastic()`はProject Reactorが提供するスケジューラーです。"),
                choice("d", "`subscribeOn`はFluxのみで使える", misconception: "subscribeOnのMonoサポートを知らない",
                       explanation: "`Mono`と`Flux`の両方で`subscribeOn`が使えます。")
            ],
            explanationRef: "explain-boot3-rx-op-004",
            designIntent: "ブロッキング処理をboundedElasticスレッドプールへ逃がすパターンを理解する。"
        ),
        quiz(
            id: "boot3-rx-op-005",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["collectList", "buffer", "Flux→Mono変換"],
            code: """
Mono<List<User>> allUsers = userRepository.findAll()
    .filter(u -> u.isActive())
    .collectList();
""",
            question: "`Flux.collectList()`の動作として正しいものはどれか？",
            choices: [
                choice("a", "FluxのすべてのアイテムをListにまとめてMono<List<T>>として返す", correct: true,
                       explanation: "`collectList`はFluxをサブスクライブして全要素を収集します。大量データには`Mono<List<T>>`ではなくFluxを直接扱うことも検討します。"),
                choice("b", "`collectList`はFluxの最初の1件だけを返す", misconception: "collectListをnextと混同",
                       explanation: "最初の1件はMono.from(flux)や`.next()`です。`collectList`は全件収集です。"),
                choice("c", "`collectList`はFluxではなくMonoにしか使えない", misconception: "collectListの使用対象を誤解",
                       explanation: "`collectList()`はFluxのメソッドです。"),
                choice("d", "`collectList`は同期的にすべての要素が揃うまでスレッドをブロックする", misconception: "collectListが同期的と誤解",
                       explanation: "`collectList`は非同期に全要素を収集し`Mono`として返します。")
            ],
            explanationRef: "explain-boot3-rx-op-005",
            designIntent: "FluxをListに集約するcollectListの動作を理解する。"
        ),
    ]

    // MARK: - WebFlux 実装
    private static let rxWebFlux: [Quiz] = [
        quiz(
            id: "boot3-rx-webflux-001",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["RouterFunction", "HandlerFunction", "関数型エンドポイント"],
            code: """
@Configuration
class UserRouter {
    @Bean
    RouterFunction<ServerResponse> userRoutes(UserHandler handler) {
        return route()
            .GET("/users/{id}", handler::getUser)
            .POST("/users", handler::createUser)
            .build();
    }
}
""",
            question: "WebFluxの関数型エンドポイント（RouterFunction）の特徴として正しいものはどれか？",
            choices: [
                choice("a", "ルーティング定義とハンドラーロジックを分離し、`@Controller`アノテーションなしにルーターをBeanとして定義する", correct: true,
                       explanation: "`RouterFunction`と`HandlerFunction`によるスタイルはアノテーションベースと機能的に同等ですが、より関数型のアプローチです。"),
                choice("b", "RouterFunctionはSpring MVCでも使えず、WebFlux専用", misconception: "RouterFunctionの適用範囲を制限",
                       explanation: "Spring MVCでもRouterFunctionが使えますが、主にWebFluxで使われます。"),
                choice("c", "関数型エンドポイントでは`@Valid`によるバリデーションが使えない", misconception: "バリデーション手段を誤解",
                       explanation: "関数型エンドポイントではHandlerFunction内でバリデーションを手動で実行するか、`WebExchangeBindException`を活用します。"),
                choice("d", "RouterFunctionはGET専用で他のHTTPメソッドはサポートしない", misconception: "RouterFunctionのメソッドサポートを誤解",
                       explanation: "`route().GET().POST().PUT().DELETE()`など主要HTTPメソッドをサポートします。")
            ],
            explanationRef: "explain-boot3-rx-webflux-001",
            designIntent: "WebFluxの関数型エンドポイント定義スタイルを理解する。"
        ),
        quiz(
            id: "boot3-rx-webflux-002",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["WebClient", "非同期HTTP", "外部API"],
            code: """
WebClient client = WebClient.create("https://api.example.com");

Mono<UserDto> user = client.get()
    .uri("/users/{id}", 42)
    .retrieve()
    .bodyToMono(UserDto.class);
""",
            question: "WebFluxで外部APIを呼ぶ際に`WebClient`を推奨する理由として正しいものはどれか？",
            choices: [
                choice("a", "ノンブロッキングな非同期HTTPクライアントで、Reactor型（Mono/Flux）と自然に統合できる", correct: true,
                       explanation: "`RestTemplate`はブロッキングです。WebFluxアプリで外部API呼び出しも非同期にするには`WebClient`が適切です。"),
                choice("b", "`WebClient`はSpring MVCでは使えない", misconception: "WebClientのSpring MVC適用を否定",
                       explanation: "`WebClient`はSpring MVC環境でも使えます（Spring 5以降）。"),
                choice("c", "`RestTemplate`はSpring Boot 3.xで削除された", misconception: "RestTemplateの廃止状況を誤解",
                       explanation: "`RestTemplate`はDeprecatedですが削除はされていません。ただし新規開発には`WebClient`や`RestClient`が推奨されます。"),
                choice("d", "`retrieve()`はレスポンスボディを同期的に取得する", misconception: "retrieveの非同期性を誤解",
                       explanation: "`retrieve()`は非同期のReactive Streamsチェーンを返します。")
            ],
            explanationRef: "explain-boot3-rx-webflux-002",
            designIntent: "WebFlux環境でのWebClientによるノンブロッキングHTTP通信を理解する。"
        ),
        quiz(
            id: "boot3-rx-webflux-003",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["StepVerifier", "WebFlux テスト", "Reactor Test"],
            code: """
@Test
void findById_returnsUser() {
    StepVerifier.create(userService.findById(1L))
        .expectNextMatches(u -> u.getId().equals(1L))
        .expectComplete()
        .verify();
}
""",
            question: "`StepVerifier`を使うテストの特徴として正しいものはどれか？",
            choices: [
                choice("a", "Mono/Fluxのデータシーケンスとシグナルをステップごとにアサートでき、ブロッキングなしでリアクティブストリームをテストできる", correct: true,
                       explanation: "`.expectNext()`、`.expectComplete()`、`.expectError()`などでPublisherのシグナルを検証します。`.verify()`で実行します。"),
                choice("b", "`StepVerifier`はJUnit 5でのみ使える", misconception: "テストフレームワークの制限を誤解",
                       explanation: "`StepVerifier`はProject Reactor TestライブラリでJUnit 4/5どちらでも使えます。"),
                choice("c", "`StepVerifier.create()`でブロッキング処理が発生する", misconception: "StepVerifierがブロッキングと誤解",
                       explanation: "`.verify()`を呼ぶまで処理は起動しません。`.verify()`でテストが完了するまで待機します。"),
                choice("d", "`StepVerifier`はFluxの最初の1件しか検証できない", misconception: "StepVerifierの検証範囲を誤解",
                       explanation: "`.expectNext()`を複数呼び出してシーケンス全体を検証できます。")
            ],
            explanationRef: "explain-boot3-rx-webflux-003",
            designIntent: "StepVerifierによるリアクティブストリームのテスト方法を理解する。"
        ),
    ]

    // MARK: - R2DBC
    private static let rxR2DBC: [Quiz] = [
        quiz(
            id: "boot3-rx-r2dbc-001",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .dataJpa,
            tags: ["R2DBC", "リアクティブDB", "JPA非対応"],
            code: """
interface UserRepository extends ReactiveCrudRepository<User, Long> {
    Flux<User> findByEmail(String email);
}
""",
            question: "WebFluxアプリでR2DBCを使う理由として正しいものはどれか？",
            choices: [
                choice("a", "JPA/HibernateはブロッキングAPIであるため、WebFluxのノンブロッキングモデルにはR2DBCなどリアクティブDBドライバーが適している", correct: true,
                       explanation: "R2DBCはReactive Streams準拠のDBアクセスAPIです。Spring Data R2DBCが`ReactiveCrudRepository`を提供します。"),
                choice("b", "R2DBCはSQLではなくNoSQLを使うための技術", misconception: "R2DBCをNoSQL技術と混同",
                       explanation: "R2DBCはリレーショナルDB（PostgreSQL、MySQL等）への非同期アクセスのための仕様です。"),
                choice("c", "Spring Bootが自動でJPAをR2DBCに置き換える", misconception: "自動置換が行われると誤解",
                       explanation: "JPAとR2DBCは別の依存関係です。開発者が意図的に選択します。"),
                choice("d", "R2DBCではEntity間のリレーションシップマッピングがJPAと同様に使える", misconception: "R2DBCのJPA同等機能を誤解",
                       explanation: "Spring Data R2DBCはJPAに比べリレーションシップ管理が限定的です。JOIN/EAGERなどの機能が少なく手動での管理が必要な場面があります。")
            ],
            explanationRef: "explain-boot3-rx-r2dbc-001",
            designIntent: "WebFlux環境でのR2DBCによるノンブロッキングDB操作を理解する。"
        ),
    ]

    // MARK: - バックプレッシャー
    private static let rxBackpressure: [Quiz] = [
        quiz(
            id: "boot3-rx-bp-001",
            level: .practice,
            objective: "boot3-practice-webflux",
            category: .architecture,
            tags: ["バックプレッシャー", "backpressure", "Flow制御"],
            code: """
Flux.range(1, 1_000_000)
    .onBackpressureDrop()
    .subscribe(item -> slowConsumer.process(item));
""",
            question: "リアクティブプログラミングにおける「バックプレッシャー」とは何か？",
            choices: [
                choice("a", "データの生産速度が消費速度を超えた場合に、消費者が処理できる量を生産者に通知してフロー制御する仕組み", correct: true,
                       explanation: "Reactive Streamsはバックプレッシャーをプロトコルレベルで定義します。`onBackpressureDrop`は消費しきれないアイテムを破棄する戦略です。"),
                choice("b", "バックプレッシャーはエラーハンドリングのための仕組み", misconception: "バックプレッシャーをエラー処理と混同",
                       explanation: "バックプレッシャーはフロー制御の仕組みであり、エラーハンドリングとは異なります。"),
                choice("c", "`onBackpressureDrop`はFluxを一時停止させる", misconception: "Drop戦略の動作を誤解",
                       explanation: "`onBackpressureDrop`は処理しきれない要素を破棄します。一時停止はbufferやlatestを使います。"),
                choice("d", "バックプレッシャーはWebFluxでは無効で、Spring MVCでのみ機能する", misconception: "バックプレッシャーの適用範囲を誤解",
                       explanation: "バックプレッシャーはReactive Streamsの中核概念でWebFluxで活かされます。Spring MVCとは関係ありません。")
            ],
            explanationRef: "explain-boot3-rx-bp-001",
            designIntent: "リアクティブシステムのバックプレッシャーの概念と制御戦略を理解する。"
        ),
    ]
}
