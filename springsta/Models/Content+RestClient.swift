import Foundation

extension Quiz {
    static let restClientQuizzes: [Quiz] = (
        rcRestTemplate + rcWebClient + rcRestClientNew + rcErrorHandling + rcRetry
    ).map { $0.contextualizedForPresentation() }

    // MARK: - RestTemplate (旧来)
    private static let rcRestTemplate: [Quiz] = [
        quiz(
            id: "boot3-rc-resttemplate-001",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["RestTemplate", "外部API", "HttpMethod"],
            code: """
@Service
class WeatherService {
    private final RestTemplate restTemplate;

    WeatherService(RestTemplateBuilder builder) {
        this.restTemplate = builder
            .setConnectTimeout(Duration.ofSeconds(3))
            .setReadTimeout(Duration.ofSeconds(5))
            .build();
    }

    WeatherResponse getWeather(String city) {
        return restTemplate.getForObject(
            "https://api.weather.com/v1/{city}",
            WeatherResponse.class, city
        );
    }
}
""",
            question: "`RestTemplateBuilder` を使ってRestTemplateを生成する利点として正しいものはどれか？",
            choices: [
                choice("a", "タイムアウト設定などをビルダーで一元管理でき、テスト時にモック注入がしやすい", correct: true,
                       explanation: "`RestTemplateBuilder`はSpringが提供するファクトリで、タイムアウト・インターセプタ・エラーハンドラをチェーンで設定できます。"),
                choice("b", "`new RestTemplate()` と`RestTemplateBuilder`の機能は完全に同じ", misconception: "Builderの付加価値を見落としている",
                       explanation: "`new RestTemplate()`では自動設定されるSpringのカスタマイズが適用されません。"),
                choice("c", "`RestTemplateBuilder` はWebFluxでしか使えない", misconception: "WebFluxとSpring MVCのHTTPクライアントを混同",
                       explanation: "`RestTemplateBuilder`はSpring MVCのブロッキングクライアントです。WebFluxでは`WebClient`を使います。"),
                choice("d", "`getForObject`はPOSTリクエストを送信する", misconception: "HTTPメソッドを混同",
                       explanation: "`getForObject`はGETリクエストを送ります。POSTには`postForObject`を使います。")
            ],
            explanationRef: "explain-boot3-rc-resttemplate-001",
            designIntent: "RestTemplateBuilderによる外部API呼び出し設定を理解する。"
        ),
        quiz(
            id: "boot3-rc-resttemplate-002",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["RestTemplate", "exchange", "ParameterizedTypeReference"],
            code: """
ResponseEntity<List<Product>> response = restTemplate.exchange(
    "https://api.store.com/products",
    HttpMethod.GET,
    HttpEntity.EMPTY,
    new ParameterizedTypeReference<List<Product>>() {}
);
List<Product> products = response.getBody();
""",
            question: "`ParameterizedTypeReference` を使う理由として正しいものはどれか？",
            choices: [
                choice("a", "Javaの型消去により`List<Product>.class`が書けないため、ジェネリクス型情報をランタイムで保持するために使う", correct: true,
                       explanation: "Javaのジェネリクスは型消去されるため`List<Product>.class`は書けません。`ParameterizedTypeReference`の匿名クラスでサブタイプのType情報を保持してデシリアライズします。"),
                choice("b", "`ParameterizedTypeReference`はXMLレスポンスのみに対応", misconception: "対応フォーマットを誤解",
                       explanation: "JSON、XML問わずジェネリクス型のデシリアライズに使います。"),
                choice("c", "`exchange`メソッドはPostのみ対応する", misconception: "exchangeのHTTPメソッド対応を誤解",
                       explanation: "`exchange`はGET/POST/PUT/DELETEなどHttpMethodを引数に取ります。"),
                choice("d", "`response.getBody()`はnullになりえない", misconception: "ResponseBodyのnullを見落としている",
                       explanation: "`getBody()`はサーバーが204 No Contentなどを返した場合にnullになりえます。")
            ],
            explanationRef: "explain-boot3-rc-resttemplate-002",
            designIntent: "RestTemplateでジェネリクスコレクション型のデシリアライズを理解する。"
        ),
    ]

    // MARK: - WebClient
    private static let rcWebClient: [Quiz] = [
        quiz(
            id: "boot3-rc-webclient-001",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["WebClient", "Builder", "BaseUrl", "Header"],
            code: """
@Bean
WebClient githubClient(WebClient.Builder builder) {
    return builder
        .baseUrl("https://api.github.com")
        .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + token)
        .defaultHeader(HttpHeaders.ACCEPT, "application/vnd.github.v3+json")
        .build();
}
""",
            question: "WebClient.BuilderをBeanにする設計の利点として正しいものはどれか？",
            choices: [
                choice("a", "Spring Bootが自動設定したフィルタやメトリクスが引き継がれ、共通ヘッダをデフォルト設定として一元管理できる", correct: true,
                       explanation: "`WebClient.Builder`はSpringが自動設定するもので、`WebClient.create()`と違いアプリ全体で注入されたカスタマイズが適用されます。"),
                choice("b", "`WebClient.Builder`はSpring MVCでは注入できない", misconception: "WebClientのSpring MVC利用を否定",
                       explanation: "Spring MVCでも`WebClient.Builder`は自動設定・注入されます。"),
                choice("c", "`defaultHeader`はGETリクエストにのみ適用される", misconception: "defaultHeaderのスコープを誤解",
                       explanation: "`defaultHeader`は全HTTPメソッドのリクエストに適用されます。"),
                choice("d", "`WebClient`はBeanにすると都度再作成される", misconception: "シングルトンBeanの性質を誤解",
                       explanation: "`@Bean`で生成した`WebClient`はシングルトンとして管理されます。スレッドセーフです。")
            ],
            explanationRef: "explain-boot3-rc-webclient-001",
            designIntent: "WebClient.BuilderをBeanとして定義する利点を理解する。"
        ),
        quiz(
            id: "boot3-rc-webclient-002",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["WebClient", "onStatus", "4xx", "5xx"],
            code: """
Mono<ProductDto> product = webClient.get()
    .uri("/products/{id}", id)
    .retrieve()
    .onStatus(HttpStatus::is4xxClientError,
              resp -> resp.bodyToMono(ErrorBody.class)
                         .flatMap(err -> Mono.error(new ProductNotFoundException(err.message()))))
    .onStatus(HttpStatus::is5xxServerError,
              resp -> Mono.error(new ExternalServiceException("外部サービスエラー")))
    .bodyToMono(ProductDto.class);
""",
            question: "`onStatus`を使うHTTPエラーハンドリングの説明として正しいものはどれか？",
            choices: [
                choice("a", "レスポンスのHTTPステータスに応じて例外を発行するMonoに変換でき、ドメイン例外として業務ロジックで扱える", correct: true,
                       explanation: "4xxと5xxで異なる例外を発行することで、呼び出し側のエラーかサーバー側のエラーかを明確に区別して処理できます。"),
                choice("b", "`onStatus`は正常レスポンスにも適用される", misconception: "onStatusの適用対象を誤解",
                       explanation: "`onStatus`は指定した述語（Predicate）がtrueの場合のみ適用されます。"),
                choice("c", "`onStatus`がなければWebClientは全エラーを無視する", misconception: "デフォルトのエラーハンドリングを誤解",
                       explanation: "`onStatus`なしでも4xx/5xxは`WebClientResponseException`として自動的にエラーになります。"),
                choice("d", "`onStatus`はFluxには使えない", misconception: "onStatusの適用先を誤解",
                       explanation: "`onStatus`はWebClientのレスポンス処理のメソッドで、`retrieve()`の後にチェーンします。")
            ],
            explanationRef: "explain-boot3-rc-webclient-002",
            designIntent: "WebClientのHTTPエラーを業務例外に変換するパターンを理解する。"
        ),
        quiz(
            id: "boot3-rc-webclient-003",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["WebClient", "WireMock", "テスト"],
            code: """
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
class UserClientTest {
    @Autowired UserClient userClient;

    @RegisterExtension
    static WireMockExtension wireMock = WireMockExtension.newInstance()
        .options(wireMockConfig().dynamicPort())
        .build();

    @Test
    void fetchUser() {
        wireMock.stubFor(get("/users/1")
            .willReturn(ok().withJsonBody(...)));
        // ...
    }
}
""",
            question: "WireMockを使ったWebClientのテストの利点として正しいものはどれか？",
            choices: [
                choice("a", "実際の外部サービスに依存せず、スタブHTTPサーバーを立ててWebClientの動作を検証できる", correct: true,
                       explanation: "WireMockはHTTPスタブサーバーです。外部APIの様々なレスポンスパターン（エラー・遅延等）をシミュレートしてWebClientをテストできます。"),
                choice("b", "WireMockはSpring Bootが自動設定するため設定不要", misconception: "WireMockの自動設定を誤解",
                       explanation: "WireMockは別途`wiremock-junit5`等の依存とアノテーション設定が必要です。"),
                choice("c", "WireMockはMockMvcと同じ目的で使う", misconception: "MockMvcとWireMockを混同",
                       explanation: "MockMvcは自アプリのControllerテスト用、WireMockは外部HTTPサービスのスタブです。"),
                choice("d", "WireMockテストではSpring Contextは不要", misconception: "スプリングコンテキストの要否を誤解",
                       explanation: "WireMockはHTTPサーバーですが、テスト対象のService/Clientはコンテキストにより注入されます。")
            ],
            explanationRef: "explain-boot3-rc-webclient-003",
            designIntent: "WireMockを使ったWebClient外部API呼び出しのテスト方法を理解する。"
        ),
    ]

    // MARK: - RestClient (Spring 6.1+)
    private static let rcRestClientNew: [Quiz] = [
        quiz(
            id: "boot3-rc-restclient-001",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["RestClient", "Spring 6.1", "ブロッキング"],
            code: """
@Bean
RestClient productClient(RestClient.Builder builder) {
    return builder
        .baseUrl("https://api.products.com")
        .defaultHeader(HttpHeaders.ACCEPT, MediaType.APPLICATION_JSON_VALUE)
        .build();
}

Product fetch(Long id) {
    return productClient.get()
        .uri("/products/{id}", id)
        .retrieve()
        .body(Product.class);
}
""",
            question: "Spring 6.1で追加された`RestClient`の特徴として正しいものはどれか？",
            choices: [
                choice("a", "WebClientと同じ流暢なAPIでブロッキングHTTP通信ができるRestTemplateの後継として設計されている", correct: true,
                       explanation: "`RestClient`はSpring 6.1で追加されました。`RestTemplate`のブロッキング特性を保ちつつ、`WebClient`ライクな流暢なAPIを提供します。"),
                choice("b", "`RestClient`はWebFlux環境でのみ動作する", misconception: "RestClientをWebFlux専用と誤解",
                       explanation: "`RestClient`はブロッキングクライアントでSpring MVCで使います。"),
                choice("c", "`RestClient`はJava 17以降でのみ使える", misconception: "Javaバージョン要件を誤解",
                       explanation: "Spring Boot 3.2以降で利用可能ですが、Javaバージョンは17+を推奨するだけで必須制約ではありません。"),
                choice("d", "`RestClient.Builder`はBeanとして自動設定されない", misconception: "自動設定の仕組みを誤解",
                       explanation: "Spring Boot 3.2以降`RestClient.Builder`はBeanとして自動設定されます。")
            ],
            explanationRef: "explain-boot3-rc-restclient-001",
            designIntent: "Spring 6.1のRestClientとRestTemplate/WebClientとの位置づけを理解する。"
        ),
    ]

    // MARK: - エラーハンドリング / タイムアウト
    private static let rcErrorHandling: [Quiz] = [
        quiz(
            id: "boot3-rc-error-001",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["HttpClientErrorException", "HttpServerErrorException", "外部API例外"],
            code: """
try {
    UserDto user = restTemplate.getForObject(url, UserDto.class);
} catch (HttpClientErrorException e) {
    log.warn("クライアントエラー: {}", e.getStatusCode());
} catch (HttpServerErrorException e) {
    throw new ExternalServiceException("外部サービス障害");
} catch (ResourceAccessException e) {
    throw new ExternalServiceException("接続タイムアウト");
}
""",
            question: "RestTemplateの例外ヒエラルキーとして正しいものはどれか？",
            choices: [
                choice("a", "`HttpClientErrorException`は4xx、`HttpServerErrorException`は5xx、`ResourceAccessException`はネットワーク・タイムアウトエラー", correct: true,
                       explanation: "RestTemplateはHTTPステータスに応じて例外を分類します。`ResourceAccessException`はIOExceptionをラップします。"),
                choice("b", "`HttpClientErrorException`は5xxのみ対象", misconception: "4xxと5xxの例外クラスを逆に覚えている",
                       explanation: "`Client`の名が示す通り4xxがクライアントエラーで`HttpClientErrorException`です。"),
                choice("c", "RestTemplateはデフォルトでエラーを例外にしない", misconception: "RestTemplateのデフォルトエラーハンドリングを誤解",
                       explanation: "RestTemplateはデフォルトで`DefaultResponseErrorHandler`が4xx/5xxを例外にします。"),
                choice("d", "`ResourceAccessException`はDBアクセスエラーを示す", misconception: "ResourceとDBアクセスを混同",
                       explanation: "`ResourceAccessException`はHTTPリソースへのアクセスエラー（タイムアウト等）です。")
            ],
            explanationRef: "explain-boot3-rc-error-001",
            designIntent: "RestTemplateの例外ヒエラルキーとHTTPステータスとの関係を理解する。"
        ),
        quiz(
            id: "boot3-rc-error-002",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["OpenFeign", "宣言的HTTPクライアント", "Spring Cloud"],
            code: """
@FeignClient(name = "product-service", url = "${product.service.url}")
interface ProductClient {
    @GetMapping("/products/{id}")
    Optional<ProductDto> findById(@PathVariable Long id);

    @PostMapping("/products")
    ProductDto create(@RequestBody CreateProductRequest request);
}
""",
            question: "Spring Cloud OpenFeignの特徴として正しいものはどれか？",
            choices: [
                choice("a", "インターフェースにアノテーションを付けるだけでHTTPクライアントを宣言的に定義でき、実装を自動生成する", correct: true,
                       explanation: "OpenFeignはインターフェース定義からHTTPクライアントのProxy実装を生成します。Spring MVCアノテーションと同じ記法で書けます。"),
                choice("b", "OpenFeignはWebSocketプロトコルを使う", misconception: "FeignとWebSocketを混同",
                       explanation: "OpenFeignはHTTP/HTTPSのRESTクライアントです。"),
                choice("c", "`@FeignClient`はController側に付けるアノテーション", misconception: "FeignをControllerと混同",
                       explanation: "`@FeignClient`はHTTPクライアントのインターフェースに付けます。"),
                choice("d", "OpenFeignはSpring Bootの自動設定のみに対応し、Spring Cloudでは使えない", misconception: "OpenFeignの出自を誤解",
                       explanation: "OpenFeignはSpring Cloudが統合するコンポーネントです。Spring Cloud依存が必要です。")
            ],
            explanationRef: "explain-boot3-rc-error-002",
            designIntent: "OpenFeignによる宣言的HTTPクライアントの仕組みを理解する。"
        ),
    ]

    // MARK: - リトライ / 冪等性
    private static let rcRetry: [Quiz] = [
        quiz(
            id: "boot3-rc-retry-001",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["@Retryable", "リトライ", "冪等性"],
            code: """
@Service
class PaymentClient {
    @Retryable(
        retryFor = {HttpServerErrorException.class, ResourceAccessException.class},
        maxAttempts = 3,
        backoff = @Backoff(delay = 500, multiplier = 2)
    )
    PaymentResponse charge(ChargeRequest request) {
        return restTemplate.postForObject(paymentUrl, request, PaymentResponse.class);
    }
}
""",
            question: "外部API呼び出しのリトライ設計で注意すべき点として正しいものはどれか？",
            choices: [
                choice("a", "POSTなど状態変更を伴う操作をリトライする場合は、冪等性（Idempotency）が保証されていないと二重処理のリスクがある", correct: true,
                       explanation: "5xxエラーでもサーバー側で処理が完了していた場合、リトライで二重決済などが起きます。冪等性キーやべき等性の確認が必要です。"),
                choice("b", "`@Retryable`はGETメソッドにのみ使用を推奨する", misconception: "リトライとHTTPメソッドの推奨を誤解",
                       explanation: "GETは冪等なのでリトライが安全ですが、POSTでも冪等性が保証されていればリトライできます。"),
                choice("c", "`backoff`でdelayを設定すると指数的に増加するのが固定動作", misconception: "multiplierの役割を見落としている",
                       explanation: "`multiplier`を設定すると指数バックオフになります。`delay`のみでは固定インターバルです。"),
                choice("d", "`@Retryable`は`@SpringBootApplication`クラスにのみ付けられる", misconception: "@Retryableの使用場所を誤解",
                       explanation: "`@Retryable`はServiceなどのBeanメソッドに付けます。`@EnableRetry`を設定クラスに付けて有効化します。")
            ],
            explanationRef: "explain-boot3-rc-retry-001",
            designIntent: "リトライと冪等性の関係、バックオフ設定を理解する。"
        ),
        quiz(
            id: "boot3-rc-retry-002",
            level: .practice,
            objective: "boot3-practice-http-client",
            category: .webMvc,
            tags: ["タイムアウト", "ConnectTimeout", "ReadTimeout", "設計"],
            code: """
spring:
  mvc:
    async:
      request-timeout: 30000

# WebClient / RestClientのタイムアウトは個別設定が必要
""",
            question: "外部APIのタイムアウト設計として正しいものはどれか？",
            choices: [
                choice("a", "接続タイムアウト（connectTimeout）と読み取りタイムアウト（readTimeout）は独立して設定し、外部APIの特性に合わせて調整する", correct: true,
                       explanation: "接続確立のタイムアウトとレスポンス受信のタイムアウトは別です。遅いAPIには読み取りタイムアウトを長くし、素早く応答すべきAPIには短く設定します。"),
                choice("b", "タイムアウトを設定しないとSpring Bootがデフォルト1秒で打ち切る", misconception: "デフォルトのタイムアウトを誤解",
                       explanation: "RestTemplateのデフォルトはタイムアウトなし（無限待機）です。必ず設定することを推奨します。"),
                choice("c", "`spring.mvc.async.request-timeout`はWebClientのタイムアウトを設定する", misconception: "MVC非同期タイムアウトとHTTPクライアントタイムアウトを混同",
                       explanation: "`spring.mvc.async.request-timeout`はMVCの非同期リクエスト全体のタイムアウトです。HTTPクライアントのタイムアウトは個別に設定します。"),
                choice("d", "タイムアウトは必ずアプリケーション全体で統一した値にする必要がある", misconception: "タイムアウトの統一設計を強制",
                       explanation: "外部APIの特性（応答速度、重要度）に応じて個別に設定するのが適切です。")
            ],
            explanationRef: "explain-boot3-rc-retry-002",
            designIntent: "外部API呼び出しのタイムアウト設計の考え方を理解する。"
        ),
    ]
}
