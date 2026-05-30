import Foundation

extension Quiz {
    static let testingQuizzes: [Quiz] = (testingUnit + testingSlice + testingIntegration
        + testingMock + testingData + testingSecurity)
        .map { $0.contextualizedForPresentation() }

    // MARK: - Group 1: 単体テスト基礎 (6問)
    private static let testingUnit: [Quiz] = [
        quiz(
            id: "boot3-test-unit-001",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["JUnit 5", "@Test", "@DisplayName"],
            code: """
@DisplayName("ユーザーサービスのテスト")
class UserServiceTest {

    @Test
    @DisplayName("存在するIDで取得すると正しいユーザーが返る")
    void findById_existingId_returnsUser() {
        // Arrange
        var service = new UserService(new InMemoryUserRepository());

        // Act
        var user = service.findById(1L);

        // Assert
        assertThat(user.getName()).isEqualTo("Alice");
    }
}
""",
            question: "JUnit 5の単体テストで `@SpringBootTest` を使わない場合の利点として正しいのはどれか？",
            choices: [
                choice("a", "Springコンテキストを起動しないためテストが高速に実行できる", correct: true,
                       explanation: "@SpringBootTestはSpringコンテキスト全体を起動するため遅いです。DIを使わないPOJOテストはコンテキスト不要で数ミリ秒で実行できます。"),
                choice("b", "@SpringBootTestなしのテストはDBに接続できないため常にインメモリ実装を使う必要がある", misconception: "DB接続とSpringコンテキストを同一視",
                       explanation: "DBへの接続自体は直接JDBCやインメモリDBで行えます。@SpringBootTestはSpringのDIコンテキストが必要な場合に使います。"),
                choice("c", "@SpringBootTestなしのテストはCI環境では実行できない", misconception: "CI実行に制限があると誤解",
                       explanation: "CIでの実行に@SpringBootTestの有無は関係ありません。どちらもCIで実行できます。"),
                choice("d", "@SpringBootTestなしのテストは `@Autowired` が使えないため全フィールドをpublicにする必要がある", misconception: "コンストラクタ注入とpublicフィールドを混同",
                       explanation: "テスト対象クラスのインスタンスは直接`new`で作れます。フィールドをpublicにする必要はありません。")
            ],
            explanationRef: "explain-boot3-test-unit-001",
            designIntent: "単体テストにおけるSpringコンテキスト不要の原則を理解する。"
        ),
        quiz(
            id: "boot3-test-unit-002",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["AssertJ", "assertThat", "可読性"],
            code: """
// JUnitのassertEquals
assertEquals("Alice", user.getName());

// AssertJのassertThat
assertThat(user.getName())
    .isEqualTo("Alice")
    .startsWith("A")
    .hasSize(5);
""",
            question: "AssertJを使う利点として正しいのはどれか？",
            choices: [
                choice("a", "メソッドチェーンで複数の検証を流暢に書けて、失敗時のエラーメッセージが具体的", correct: true,
                       explanation: "AssertJはフルーエントAPIでチェーンが書きやすく、期待値/実際値のフォーマットが明確な失敗メッセージを提供します。Spring Bootのデフォルトテスト依存に含まれています。"),
                choice("b", "AssertJはSpring Boot独自のライブラリでJUnitとは同時使用できない", misconception: "AssertJとJUnitの排他的使用を誤解",
                       explanation: "AssertJとJUnit5は共存できます。Spring Bootのstarter-testで両方が依存に含まれます。"),
                choice("c", "AssertJを使うとテストが2倍遅くなる", misconception: "存在しないパフォーマンス低下",
                       explanation: "AssertJはアサーションライブラリです。テストの実行速度への影響はほぼありません。"),
                choice("d", "AssertJはcollectionのアサーションのみに対応し文字列検証はできない", misconception: "AssertJの適用範囲を誤解",
                       explanation: "AssertJはString、Collection、Integer、File、Exception等、多くの型に対応したアサーションを提供します。")
            ],
            explanationRef: "explain-boot3-test-unit-002",
            designIntent: "AssertJの利点を理解する。"
        ),
        quiz(
            id: "boot3-test-unit-003",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@BeforeEach", "@AfterEach", "テスト準備"],
            code: """
class OrderServiceTest {

    private OrderRepository repository;
    private OrderService service;

    @BeforeEach
    void setUp() {
        repository = new InMemoryOrderRepository();
        service = new OrderService(repository);
    }

    @AfterEach
    void tearDown() {
        repository.clear();
    }
}
""",
            question: "`@BeforeEach` の動作として正しいのはどれか？",
            choices: [
                choice("a", "各テストメソッド実行前に毎回呼ばれ、テストの独立性を保つ", correct: true,
                       explanation: "@BeforeEachは各@Testメソッドの前に実行されます。テスト間で状態を共有しないよう毎回新しいインスタンスを用意するのに使います。"),
                choice("b", "クラス内で1回だけ実行されテスト間で状態を共有する", misconception: "@BeforeEachと@BeforeAllを混同",
                       explanation: "クラスで1回だけ実行されるのは@BeforeAllです。@BeforeEachは各テストメソッドの前に実行されます。"),
                choice("c", "@BeforeEachのメソッドは`public static`でなければならない", misconception: "@BeforeAllの要件と混同",
                       explanation: "@BeforeEachはインスタンスメソッドです。static不要です。staticが必要なのは@BeforeAllです（@TestInstance変更時を除く）。"),
                choice("d", "@BeforeEachはSpring Bootテストでのみ動作し、通常のJUnit5では使えない", misconception: "Spring Boot限定と誤解",
                       explanation: "@BeforeEachはJUnit5標準のアノテーションです。Spring Bootに依存しません。")
            ],
            explanationRef: "explain-boot3-test-unit-003",
            designIntent: "@BeforeEachの動作とテスト独立性の原則を理解する。"
        ),
        quiz(
            id: "boot3-test-unit-004",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@ParameterizedTest", "テストパラメータ化", "@ValueSource"],
            code: """
@ParameterizedTest
@ValueSource(strings = {"", " ", "  ", "\\t"})
void isBlank_whenStringIsBlank_returnsTrue(String input) {
    assertThat(StringUtils.isBlank(input)).isTrue();
}
""",
            question: "`@ParameterizedTest` を使う目的として正しいのはどれか？",
            choices: [
                choice("a", "同じテストロジックを複数の入力値で繰り返し実行し、コードの重複を避ける", correct: true,
                       explanation: "@ParameterizedTestは異なる入力でテストを繰り返します。境界値テストや複数ケースの網羅に有効です。"),
                choice("b", "@ParameterizedTestを使うとすべてのテストが並列実行される", misconception: "パラメータ化と並列実行を混同",
                       explanation: "並列実行はJUnit5の設定（`junit.jupiter.execution.parallel.enabled=true`）で制御します。@ParameterizedTestは入力の繰り返しです。"),
                choice("c", "@ValueSourceで指定できる型は文字列のみでintやDoubleは使えない", misconception: "@ValueSourceの型制限を誤解",
                       explanation: "@ValueSourceはints、longs、doubles、strings、chars、booleans、classesをサポートします。"),
                choice("d", "@ParameterizedTestはSpring Boot 3.xでJUnit 5から削除された", misconception: "廃止されたという誤情報",
                       explanation: "@ParameterizedTestはJUnit5に引き続き含まれており、Spring Boot 3.xのstarter-testで使えます。")
            ],
            explanationRef: "explain-boot3-test-unit-004",
            designIntent: "パラメータ化テストの目的を理解する。"
        ),
        quiz(
            id: "boot3-test-unit-005",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["assertThrows", "例外テスト", "assertThatThrownBy"],
            code: """
// パターンA: JUnit5
assertThrows(IllegalArgumentException.class, () -> {
    service.createUser("");
});

// パターンB: AssertJ
assertThatThrownBy(() -> service.createUser(""))
    .isInstanceOf(IllegalArgumentException.class)
    .hasMessageContaining("名前は必須");
""",
            question: "AssertJの `assertThatThrownBy` を使う利点として正しいのはどれか？",
            choices: [
                choice("a", "例外の型だけでなくメッセージや原因（cause）も流暢に検証できる", correct: true,
                       explanation: "assertThatThrownByはメソッドチェーンで例外の詳細を細かく検証できます。JUnit5のassertThrowsより表現力が高いです。"),
                choice("b", "`assertThrows` は例外が発生しなかった場合にテストをスキップするが、`assertThatThrownBy` は失敗させる", misconception: "assertThrowsの挙動を誤解",
                       explanation: "どちらも例外が発生しなかった場合はテストを失敗させます。スキップはしません。"),
                choice("c", "`assertThatThrownBy` はランタイム例外のみ対象で検査例外は使えない", misconception: "検査例外が非対応と誤解",
                       explanation: "assertThatThrownByはThrowableを対象にするため、検査例外（Exception）もランタイム例外も扱えます。"),
                choice("d", "`assertThrows` の戻り値は `void` でメッセージ検証ができない", misconception: "assertThrowsの戻り値を誤解",
                       explanation: "`assertThrows` は発生した例外オブジェクトを返します。`assertEquals(msg, e.getMessage())`で検証できます（ただしAssertJほどフルーエントではない）。")
            ],
            explanationRef: "explain-boot3-test-unit-005",
            designIntent: "例外テストの書き方の違いを理解する。"
        ),
        quiz(
            id: "boot3-test-unit-006",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["テスト設計", "AAA", "テスト命名"],
            code: """
// 良い命名例
@Test
void transfer_whenInsufficientBalance_throwsInsufficientFundsException() {}

// 曖昧な命名例
@Test
void test1() {}

@Test
void transferTest() {}
""",
            question: "テストメソッド名の命名規約として最も推奨されるのはどれか？",
            choices: [
                choice("a", "`methodName_stateUnderTest_expectedBehavior` のような「何をテストしているか」が明確な形式", correct: true,
                       explanation: "テスト名から「どのメソッドを、どの状態で、どうなるべきか」が読み取れる命名が推奨です。失敗時にどの仕様が壊れたかが即座に分かります。"),
                choice("b", "`test1`, `test2` のような連番形式がJUnitの推奨スタイル", misconception: "連番命名が標準的と誤解",
                       explanation: "連番では何をテストしているか不明です。テスト名はドキュメントの役割を果たすべきです。"),
                choice("c", "日本語テスト名はJUnit5で動作しないため英語のみ使う", misconception: "日本語メソッド名が使えないと誤解",
                       explanation: "Java / Kotlin では日本語メソッド名が使えます。@DisplayNameを使うか、メソッド名自体を日本語にするアプローチも多く採られます。"),
                choice("d", "テストメソッドはできるだけ短く一言で命名し、詳細は@DisplayNameに書く", misconception: "特定のスタイルが唯一の正解と誤解",
                       explanation: "@DisplayNameと短いメソッド名の組み合わせも有効なアプローチですが、選択肢aが「最も推奨」されるという点では命名規約の明確さが重要です。")
            ],
            explanationRef: "explain-boot3-test-unit-006",
            designIntent: "テスト命名規約のベストプラクティスを理解する。"
        ),
    ]

    // MARK: - Group 2: スライステスト (6問)
    private static let testingSlice: [Quiz] = [
        quiz(
            id: "boot3-test-slice-001",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@WebMvcTest", "スライステスト", "MockMvc"],
            code: """
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Test
    void getUser_returnsJsonResponse() throws Exception {
        given(userService.findById(1L)).willReturn(new User(1L, "Alice"));

        mockMvc.perform(get("/users/1"))
               .andExpect(status().isOk())
               .andExpect(jsonPath("$.name").value("Alice"));
    }
}
""",
            question: "`@WebMvcTest` が起動するSpringコンテキストの特徴として正しいのはどれか？",
            choices: [
                choice("a", "Webレイヤー（Controller、Filter、HandlerInterceptor）のみをロードし、Service・Repositoryはロードしない", correct: true,
                       explanation: "@WebMvcTestはMVC層に絞ったスライステストです。Serviceは@MockBeanで差し替えます。フルコンテキストより大幅に高速です。"),
                choice("b", "@WebMvcTestはDBへの実際の接続を確認するためRepositoryもロードする", misconception: "@WebMvcTestがDBまで含むと誤解",
                       explanation: "@WebMvcTestはWebレイヤーのみです。DBはロードしません。Repositoryテストには@DataJpaTestを使います。"),
                choice("c", "@WebMvcTestはHTTPサーバ（Tomcat）を実際に起動してポートを占有する", misconception: "MockMvcが実際のサーバを使うと誤解",
                       explanation: "MockMvcはHTTPサーバを起動しません。サーブレットスタックをモックして動作します。実サーバが必要なら@SpringBootTest(webEnvironment=RANDOM_PORT)を使います。"),
                choice("d", "@WebMvcTest は @SpringBootApplication クラスをスキャンして全Beanを登録する", misconception: "@WebMvcTestが全Beanをロードすると誤解",
                       explanation: "@WebMvcTestは指定したControllerクラスと関連するWebコンポーネントのみをロードします。")
            ],
            explanationRef: "explain-boot3-test-slice-001",
            designIntent: "@WebMvcTestのスコープを理解する。"
        ),
        quiz(
            id: "boot3-test-slice-002",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@DataJpaTest", "H2", "インメモリDB"],
            code: """
@DataJpaTest
class ProductRepositoryTest {

    @Autowired
    private ProductRepository repository;

    @Test
    void save_andFindByName() {
        var product = new Product("Widget", 100);
        repository.save(product);

        var found = repository.findByName("Widget");
        assertThat(found).isPresent();
    }
}
""",
            question: "`@DataJpaTest` のデフォルト動作として正しいのはどれか？",
            choices: [
                choice("a", "インメモリDB（H2）を使いJPAコンポーネントのみをロードし、テスト後にロールバックする", correct: true,
                       explanation: "@DataJpaTestはH2等のインメモリDBで動作し、@Entity/@Repository等のJPA関連Beanのみをロードします。各テストはトランザクションでロールバックされます。"),
                choice("b", "@DataJpaTestは本番DBに接続してデータを書き込む", misconception: "@DataJpaTestが本番DBを使うと誤解",
                       explanation: "デフォルトではインメモリDBを使います。本番DBを使いたい場合は`@AutoConfigureTestDatabase(replace=NONE)`を使います。"),
                choice("c", "@DataJpaTestはサービスクラスとコントローラもロードする", misconception: "@DataJpaTestのスコープを誤解",
                       explanation: "@DataJpaTestはJPAレイヤーのみをロードします。Service/Controllerはロードしません。"),
                choice("d", "@DataJpaTestの各テスト後、変更はDBにコミットされ次のテストに引き継がれる", misconception: "テスト後ロールバックを知らない",
                       explanation: "デフォルトで各テストはロールバックされます。テスト間の状態汚染を防ぎます。")
            ],
            explanationRef: "explain-boot3-test-slice-002",
            designIntent: "@DataJpaTestの動作を理解する。"
        ),
        quiz(
            id: "boot3-test-slice-003",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@WebMvcTest", "@MockBean", "SecurityConfig"],
            code: """
@WebMvcTest(UserController.class)
@Import(SecurityConfig.class)
class UserControllerSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @MockBean
    private UserDetailsService userDetailsService;

    @Test
    @WithMockUser(roles = "USER")
    void getProfile_withAuthenticatedUser_returns200() throws Exception {
        mockMvc.perform(get("/profile"))
               .andExpect(status().isOk());
    }
}
""",
            question: "`@WebMvcTest` にSpring Securityの設定を含める場合、正しい説明はどれか？",
            choices: [
                choice("a", "@Importで SecurityConfig を明示的に追加し、認証に必要なBeanを@MockBeanで差し替える必要がある", correct: true,
                       explanation: "@WebMvcTestはSecurityConfig等の@Configurationをスキャンしません。@Importで追加し、UserDetailsService等の依存Beanは@MockBeanで差し替えます。"),
                choice("b", "@WebMvcTestを使うとSpring Securityは自動的に無効化される", misconception: "@WebMvcTestがSecurityを無効化すると誤解",
                       explanation: "@WebMvcTestはSpring Securityのデフォルト設定（CSRF等）を有効にします。完全無効化には`@AutoConfigureMockMvc(addFilters=false)`等が必要です。"),
                choice("c", "`@WithMockUser` はSpring Security本体のアノテーションで認証済みユーザーを実際にDBに作成する", misconception: "@WithMockUserが実際のUserをDBに作成すると誤解",
                       explanation: "@WithMockUserはテスト用のモック認証を設定します。実際のDBアクセスは発生しません。"),
                choice("d", "@MockBeanで UserDetailsService を差し替えるとSSLが無効になる", misconception: "存在しない関連",
                       explanation: "UserDetailsServiceとSSLは無関係です。@MockBeanは指定したBeanの動作をモックに置き換えます。")
            ],
            explanationRef: "explain-boot3-test-slice-003",
            designIntent: "@WebMvcTestとSpring Securityの統合テストを理解する。"
        ),
        quiz(
            id: "boot3-test-slice-004",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@JsonTest", "ObjectMapper", "JSON変換"],
            code: """
@JsonTest
class UserDtoJsonTest {

    @Autowired
    private JacksonTester<UserDto> json;

    @Test
    void serialize_user_to_json() throws Exception {
        var user = new UserDto(1L, "Alice", "alice@example.com");

        assertThat(json.write(user))
            .hasJsonPathStringValue("$.name", "Alice")
            .doesNotHaveJsonPath("$.password");
    }
}
""",
            question: "`@JsonTest` の目的として正しいのはどれか？",
            choices: [
                choice("a", "JacksonのObjectMapperのシリアライズ・デシリアライズをテストし、フィールドのマッピングや除外を検証する", correct: true,
                       explanation: "@JsonTestはJSONのシリアライズ・デシリアライズのみに絞ったスライステストです。@JsonIgnore・@JsonProperty等の設定が意図通りに機能するか検証できます。"),
                choice("b", "@JsonTestを使うとHTTPリクエストのJSONボディをパースする実際のAPI呼び出しを検証できる", misconception: "@JsonTestがAPI統合テストになると誤解",
                       explanation: "@JsonTestはObjectMapper単独のテストです。HTTP通信は含まれません。"),
                choice("c", "@JsonTestはSpring Boot 3.0で廃止された", misconception: "廃止されたという誤情報",
                       explanation: "@JsonTestはSpring Boot 3.xでも引き続き使用可能です。"),
                choice("d", "@JsonTestはXMLシリアライズのテストのみに使用される", misconception: "@JsonTestの対象を誤解",
                       explanation: "@JsonTestはJSONのテスト専用です（名前の通り）。XML向けには別の仕組みを使います。")
            ],
            explanationRef: "explain-boot3-test-slice-004",
            designIntent: "@JsonTestの役割を理解する。"
        ),
        quiz(
            id: "boot3-test-slice-005",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@AutoConfigureTestDatabase", "実DBテスト", "Testcontainers"],
            code: """
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class ProductRepositoryIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:15");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
    }
}
""",
            question: "`@AutoConfigureTestDatabase(replace = NONE)` を使う理由として正しいのはどれか？",
            choices: [
                choice("a", "インメモリDBへの自動置換を無効にして、TestcontainersなどによるPostgreSQL等の実際のDBでテストするため", correct: true,
                       explanation: "デフォルトで@DataJpaTestはH2等に置換します。`replace=NONE`で置換を無効にし、Testcontainersで起動した実DBとの接続テストが可能になります。"),
                choice("b", "`replace=NONE`を指定するとDBへの接続が完全に切断されメモリのみでテストが実行される", misconception: "replaceの意味を逆に理解",
                       explanation: "`replace=NONE`はインメモリDBへの「置換なし」という意味です。実DBへの接続をそのまま使います。"),
                choice("c", "Testcontainersを使うとJUnit5の@Testが使えなくなる", misconception: "Testcontainersが@Testと排他的と誤解",
                       explanation: "TestcontainersはJUnit5と統合されます。@Testを引き続き使用できます。"),
                choice("d", "`@DynamicPropertySource`はSpring Boot 3.xで廃止された", misconception: "廃止されたという誤情報",
                       explanation: "@DynamicPropertySourceはSpring Boot 3.xでも使用可能な現役のアノテーションです。")
            ],
            explanationRef: "explain-boot3-test-slice-005",
            designIntent: "実DBを使ったスライステストの設定を理解する。"
        ),
        quiz(
            id: "boot3-test-slice-006",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@RestClientTest", "RestClient", "WireMock"],
            code: """
@RestClientTest(WeatherClient.class)
class WeatherClientTest {

    @Autowired
    private WeatherClient weatherClient;

    @Autowired
    private MockRestServiceServer server;

    @Test
    void getCurrentTemperature_callsExternalApi() {
        server.expect(requestTo("/weather/tokyo"))
              .andRespond(withSuccess("{\"temp\":25}", MediaType.APPLICATION_JSON));

        int temp = weatherClient.getCurrentTemperature("tokyo");
        assertThat(temp).isEqualTo(25);
    }
}
""",
            question: "`@RestClientTest` の目的として正しいのはどれか？",
            choices: [
                choice("a", "外部APIクライアントクラスのみをロードしMockRestServiceServerで実際のHTTP通信なしにテストする", correct: true,
                       explanation: "@RestClientTestはHTTPクライアントのテスト用スライスです。実際のHTTP通信を発生させずに外部API呼び出しのロジックをテストできます。"),
                choice("b", "@RestClientTestを使うとすべての外部HTTP通信が自動でブロックされる", misconception: "@RestClientTestが全HTTP通信を遮断すると誤解",
                       explanation: "@RestClientTestはテスト対象のクライアントクラスにMockServerを適用します。テスト外のHTTP通信は別途管理が必要です。"),
                choice("c", "@RestClientTestはWebFluxのWebClientには対応していない", misconception: "@RestClientTestのサポート範囲を誤解",
                       explanation: "@RestClientTestはRestTemplateとRestClientに対応します。WebClientのテストには別のアプローチが使われます（MockWebServerなど）。"),
                choice("d", "@RestClientTestはSpring Boot 3.2以前では使えない新機能", misconception: "バージョン依存の誤解",
                       explanation: "@RestClientTestはSpring Bootに以前から存在します。RestTemplateベースのクライアントに対応しています。")
            ],
            explanationRef: "explain-boot3-test-slice-006",
            designIntent: "HTTPクライアントのテスト方法を理解する。"
        ),
    ]

    // MARK: - Group 3: 統合テスト (5問)
    private static let testingIntegration: [Quiz] = [
        quiz(
            id: "boot3-test-int-001",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@SpringBootTest", "webEnvironment", "RANDOM_PORT"],
            code: """
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UserApiIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @LocalServerPort
    private int port;

    @Test
    void getUser_returnsOk() {
        var response = restTemplate.getForEntity(
            "http://localhost:" + port + "/users/1", UserDto.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }
}
""",
            question: "`webEnvironment = RANDOM_PORT` を使う理由として正しいのはどれか？",
            choices: [
                choice("a", "実際のHTTPサーバを起動してポート競合を防ぎながらE2Eに近いテストを行うため", correct: true,
                       explanation: "RANDOM_PORTは空きポートを自動選択してTomcatを起動します。ポートの競合を避けながら実際のHTTPリクエストによるE2Eテストができます。"),
                choice("b", "RANDOM_PORTを指定するとHTTPSを自動で有効化しSSL証明書が生成される", misconception: "RANDOM_PORTとHTTPS設定を混同",
                       explanation: "RANDOM_PORTはポート番号の自動選択だけです。HTTPSとは無関係です。"),
                choice("c", "RANDOM_PORTを使うと@WebMvcTestと同じスライスコンテキストが起動する", misconception: "@SpringBootTestと@WebMvcTestを混同",
                       explanation: "@SpringBootTestは全コンテキストを起動します。@WebMvcTestのスライスとは異なります。"),
                choice("d", "`MOCK`環境では実際のHTTPサーバが起動するためMockMvcが使えない", misconception: "MOCK環境の挙動を誤解",
                       explanation: "`MOCK`環境ではサーバを起動せずMockMvcを使います。`RANDOM_PORT`や`DEFINED_PORT`で実サーバが起動します。")
            ],
            explanationRef: "explain-boot3-test-int-001",
            designIntent: "@SpringBootTestのwebEnvironmentオプションを理解する。"
        ),
        quiz(
            id: "boot3-test-int-002",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["TestRestTemplate", "RestAssured", "HTTPクライアント"],
            code: """
// TestRestTemplate（Spring Boot提供）
var response = restTemplate.getForEntity("/users/1", UserDto.class);
assertThat(response.getStatusCode()).isEqualTo(OK);

// RestAssured（外部ライブラリ）
given().when().get("/users/1")
       .then().statusCode(200)
       .body("name", equalTo("Alice"));
""",
            question: "`TestRestTemplate` と `RestAssured` の使い分けとして正しいのはどれか？",
            choices: [
                choice("a", "TestRestTemplateはSpring Boot統合がシンプルで追加依存不要、RestAssuredはBDD記法で読みやすくレスポンス検証が豊富", correct: true,
                       explanation: "TestRestTemplateはSpring Bootに組み込みで設定が少ない利点があります。RestAssuredはGiven-When-Then記法と豊富なマッチャーで可読性が高い利点があります。"),
                choice("b", "RestAssuredはMockMvcと共に使えないため統合テストのみ対応", misconception: "RestAssuredの対応範囲を誤解",
                       explanation: "RestAssured-MockMvcモジュールを使えばMockMvcとの組み合わせが可能です。"),
                choice("c", "TestRestTemplateはWebFlux（リアクティブ）アプリにのみ対応", misconception: "TestRestTemplateの対応範囲を誤解",
                       explanation: "TestRestTemplateはサーブレットベース（Spring MVC）用です。WebFluxテストにはWebTestClientを使います。"),
                choice("d", "Spring Boot 3.xではTestRestTemplateは廃止されWebTestClientのみになった", misconception: "廃止されたという誤情報",
                       explanation: "TestRestTemplateはSpring Boot 3.xでも使用可能です。")
            ],
            explanationRef: "explain-boot3-test-int-002",
            designIntent: "統合テスト用クライアントの使い分けを理解する。"
        ),
        quiz(
            id: "boot3-test-int-003",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@Sql", "テストデータ", "データセットアップ"],
            code: """
@SpringBootTest
@Sql(scripts = "/test-data/users.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
@Sql(scripts = "/test-data/cleanup.sql", executionPhase = Sql.ExecutionPhase.AFTER_TEST_METHOD)
class UserServiceIntegrationTest {
    // テスト
}
""",
            question: "`@Sql` アノテーションを使う目的として正しいのはどれか？",
            choices: [
                choice("a", "テスト前後にSQLスクリプトを実行してテストデータの投入・クリーンアップを行う", correct: true,
                       explanation: "@SqlはテストメソッドやクラスにSQLスクリプトを紐付けます。BEFORE_TEST_METHODでデータ投入、AFTER_TEST_METHODでクリーンアップが標準的なパターンです。"),
                choice("b", "@SqはJPAのリポジトリをSQLに自動変換してパフォーマンスを改善する", misconception: "@SqlがSQLチューニングツールと誤解",
                       explanation: "@Sqlはテスト用のSQL実行アノテーションです。クエリの最適化は行いません。"),
                choice("c", "@Sqlは@DataJpaTestのみで使用できる", misconception: "@Sqlの適用範囲を誤解",
                       explanation: "@Sqlは@SpringBootTestでも@DataJpaTestでも使用できます。Springのトランザクションテスト基盤があれば動作します。"),
                choice("d", "@Sqlを使うとテスト後のロールバックが無効になる", misconception: "@Sqlがトランザクション管理に影響すると誤解",
                       explanation: "@Sqlのスクリプト実行とトランザクションのロールバックは独立した設定です。@Transactionalがあればロールバックします。")
            ],
            explanationRef: "explain-boot3-test-int-003",
            designIntent: "@Sqlによるテストデータ管理を理解する。"
        ),
        quiz(
            id: "boot3-test-int-004",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["コンテキストキャッシュ", "テスト速度", "@DirtiesContext"],
            code: """
// NG: テストごとにコンテキストを破棄
@SpringBootTest
@DirtiesContext(classMode = DirtiesContext.ClassMode.AFTER_EACH_TEST_METHOD)
class SlowTest {
    @Test void test1() {}
    @Test void test2() {}
    @Test void test3() {}
}
""",
            question: "`@DirtiesContext` を不必要に使うことの問題として正しいのはどれか？",
            choices: [
                choice("a", "テストのたびにSpringコンテキストが再起動されるため、大規模テストスイートで実行時間が大幅に増加する", correct: true,
                       explanation: "Springはデフォルトでコンテキストをキャッシュします。@DirtiesContextはキャッシュを無効化して再起動を強制するため、使いすぎるとテストが何倍も遅くなります。"),
                choice("b", "@DirtiesContextを使うとDBのロールバックが無効になる", misconception: "@DirtiesContextとトランザクションロールバックを混同",
                       explanation: "@DirtiesContextはコンテキストのライフサイクルに関するものです。トランザクションのロールバック設定には影響しません。"),
                choice("c", "@DirtiesContextはSpring Boot 3.xで廃止されコンテキストは常に再利用される", misconception: "廃止されたという誤情報",
                       explanation: "@DirtiesContextは引き続き使用可能です。コンテキストを汚染する操作（Bean置換等）の後に状態をリセットする目的で使います。"),
                choice("d", "@DirtiesContextを使うとアプリの本番コードが書き換えられる", misconception: "テストコードが本番コードを変更すると誤解",
                       explanation: "@DirtiesContextはSpringのテストコンテキストの管理のみに影響します。本番コードには影響しません。")
            ],
            explanationRef: "explain-boot3-test-int-004",
            designIntent: "Springコンテキストキャッシュの仕組みと@DirtiesContextの影響を理解する。"
        ),
        quiz(
            id: "boot3-test-int-005",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["テストピラミッド", "テスト戦略", "速度とカバレッジ"],
            code: """
// テストピラミッド（速い順）
// 1. 単体テスト（多数）   → PojoテストMockを使ったService/Domainテスト
// 2. スライステスト（中数）→ @WebMvcTest, @DataJpaTest
// 3. 統合テスト（少数）   → @SpringBootTest(RANDOM_PORT)
""",
            question: "テストピラミッドの考え方として正しいのはどれか？",
            choices: [
                choice("a", "単体テストを多く・統合テストを少なくすることで速度と信頼性のバランスを取る", correct: true,
                       explanation: "テストピラミッドは「速い単体テストを多く、遅い統合テストは少なく」の原則です。単体テストでロジックを検証し、統合テストで主要フローのみを確認します。"),
                choice("b", "統合テストのみで全てを検証するのが最も確実なテスト戦略", misconception: "統合テストのみが確実と誤解",
                       explanation: "統合テストは遅く、失敗原因の特定が難しいです。細かいロジックのバグ発見には単体テストが向いています。"),
                choice("c", "Spring Bootアプリは@SpringBootTestで全てテストすべきでスライステストは不要", misconception: "@SpringBootTestで全てをカバーすべきと誤解",
                       explanation: "@SpringBootTestは起動が遅いです。スライステストでレイヤーを分けてテストすることで速度と精度が上がります。"),
                choice("d", "テストピラミッドはJava専用の概念でSpring Bootに特化した指針ではない", misconception: "テストピラミッドがJava専用と誤解",
                       explanation: "テストピラミッドはMike Cohnが提唱した一般的なテスト戦略です。Spring Bootに限らずあらゆるソフトウェア開発に適用できます。")
            ],
            explanationRef: "explain-boot3-test-int-005",
            designIntent: "テストピラミッドの原則を理解する。"
        ),
    ]

    // MARK: - Group 4: Mockito (5問)
    private static let testingMock: [Quiz] = [
        quiz(
            id: "boot3-test-mock-001",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@Mock", "@InjectMocks", "Mockito"],
            code: """
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private EmailService emailService;

    @InjectMocks
    private OrderService orderService;
}
""",
            question: "`@InjectMocks` の動作として正しいのはどれか？",
            choices: [
                choice("a", "テストクラスの`@Mock`フィールドを `OrderService` のコンストラクタ（またはフィールド）に自動で注入する", correct: true,
                       explanation: "@InjectMocksはMockitoがOrderServiceをインスタンス化し、@Mockのフィールドをコンストラクタ注入またはフィールド注入で差し込みます。"),
                choice("b", "@InjectMocksを使うとSpringコンテキストが起動してリアルなBeanが注入される", misconception: "@InjectMocksがSpringコンテキストを使うと誤解",
                       explanation: "@InjectMocksはSpringと無関係です。Mockitoが純粋にJavaのリフレクションでインスタンスを作成します。"),
                choice("c", "`@InjectMocks` は `@Mock` と同じ効果でモックオブジェクトを作成する", misconception: "@InjectMocksと@Mockを同一視",
                       explanation: "@Mockはモックを作成します。@InjectMocksはそのモックを注入する対象のインスタンスを作成します。"),
                choice("d", "@InjectMocksは `@Autowired` の代替でSpringプロジェクトでのみ使用できる", misconception: "@InjectMocksがSpring専用と誤解",
                       explanation: "@InjectMocksはMockitoの機能でSpring非依存です。DIフレームワークなしのテストで使います。")
            ],
            explanationRef: "explain-boot3-test-mock-001",
            designIntent: "@Mockと@InjectMocksの役割の違いを理解する。"
        ),
        quiz(
            id: "boot3-test-mock-002",
            level: .foundation,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["when().thenReturn()", "given().willReturn()", "スタブ"],
            code: """
// Mockitoのスタブ設定
when(userRepository.findById(1L)).thenReturn(Optional.of(new User(1L, "Alice")));

// BDDスタイル（BDDMockito）
given(userRepository.findById(1L)).willReturn(Optional.of(new User(1L, "Alice")));
""",
            question: "スタブ設定で `when().thenReturn()` と `given().willReturn()` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "機能的には同じで、`given/willReturn` はBDDスタイルのエイリアスであり可読性の違いのみ", correct: true,
                       explanation: "BDDMockitoの`given()`はMockitoの`when()`と同等ですが、Given-When-Then記法に合わせてテストの可読性を向上させるためのスタイルです。"),
                choice("b", "`given().willReturn()` はvoidメソッドのスタブに使用できないが、`when().thenReturn()` はvoidも対応", misconception: "voidメソッドのスタブへの対応の違いを誤解",
                       explanation: "voidメソッドのスタブには`doNothing().when()` または `willDoNothing().given()`を使います。どちらのスタイルも同等の対応です。"),
                choice("c", "`given().willReturn()` はSpring Bootでのみ使えるSpring固有のAPI", misconception: "BDDMockitoがSpring専用と誤解",
                       explanation: "BDDMockitoはMockitoの一部でSpring非依存です。`org.mockito.BDDMockito`クラスに含まれます。"),
                choice("d", "`when().thenReturn()` はMockito 3.x以降で廃止された", misconception: "廃止されたという誤情報",
                       explanation: "`when().thenReturn()`はMockitoの基本APIで現役です。廃止されていません。")
            ],
            explanationRef: "explain-boot3-test-mock-002",
            designIntent: "スタブ設定のスタイルの違いを理解する。"
        ),
        quiz(
            id: "boot3-test-mock-003",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["verify()", "インタラクション検証", "times()"],
            code: """
@Test
void placeOrder_sendsConfirmationEmail() {
    // Arrange
    var order = new Order(1L, "Alice");
    when(orderRepository.save(any())).thenReturn(order);

    // Act
    orderService.placeOrder(order);

    // Assert
    verify(emailService, times(1)).sendConfirmation(order);
    verify(emailService, never()).sendCancellation(any());
}
""",
            question: "`verify(emailService, times(1))` の目的として正しいのはどれか？",
            choices: [
                choice("a", "`emailService.sendConfirmation()` がちょうど1回呼ばれたことを検証する", correct: true,
                       explanation: "verify()はモックの呼び出し回数を検証します。`times(1)`は1回の呼び出しを期待します。`never()`は呼ばれないことを期待します。"),
                choice("b", "`verify()` はモックの戻り値を検証するためのメソッド", misconception: "verifyがassertThatの代替と誤解",
                       explanation: "`verify()`はモックの呼び出し（インタラクション）を検証します。戻り値のアサーションはassertThat等で行います。"),
                choice("c", "`times(1)` を省略すると呼び出しが0回でも検証が通る", misconception: "timesのデフォルトが0と誤解",
                       explanation: "`verify(mock)`だけでも`times(1)`と等価です。つまり1回の呼び出しを期待します。"),
                choice("d", "verifyはSpring Bootテスト（@MockBean使用時）でのみ動作する", misconception: "verifyがSpring Boot専用と誤解",
                       explanation: "verifyはMockitoの機能でSpring非依存です。@Mockでも@MockBeanでも使用できます。")
            ],
            explanationRef: "explain-boot3-test-mock-003",
            designIntent: "verify()によるインタラクション検証を理解する。"
        ),
        quiz(
            id: "boot3-test-mock-004",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["ArgumentCaptor", "引数検証", "モック引数確認"],
            code: """
@Test
void createUser_savesWithHashedPassword() {
    var captor = ArgumentCaptor.forClass(User.class);

    userService.createUser("Alice", "plaintext");

    verify(userRepository).save(captor.capture());
    assertThat(captor.getValue().getPasswordHash())
        .isNotEqualTo("plaintext")
        .startsWith("$2a$");
}
""",
            question: "`ArgumentCaptor` を使う目的として正しいのはどれか？",
            choices: [
                choice("a", "モックメソッドに渡された引数の具体的な内容（値）を取得して詳細に検証するため", correct: true,
                       explanation: "ArgumentCaptorはverify()で呼び出した引数をキャプチャします。パスワードのハッシュ化確認など、モックに渡されたオブジェクトの内部状態を検証するのに使います。"),
                choice("b", "ArgumentCaptorを使うとモックが自動でレスポンスを返すようになる", misconception: "ArgumentCaptorがスタブ機能を持つと誤解",
                       explanation: "ArgumentCaptorは引数のキャプチャ専用です。スタブ設定はwhen/givenを使います。"),
                choice("c", "ArgumentCaptorはvoidメソッドの引数のみに使用できる", misconception: "voidメソッド限定と誤解",
                       explanation: "ArgumentCaptorは戻り値の有無に関係なくモックメソッドの引数をキャプチャできます。"),
                choice("d", "ArgumentCaptorを使うと`any()`マッチャーが使えなくなる", misconception: "ArgumentCaptorとany()の排他性を誤解",
                       explanation: "ArgumentCaptorとany()は独立して使えます。verify()でcapture()と他のマッチャーを同時に使う場合はeq()を使います。")
            ],
            explanationRef: "explain-boot3-test-mock-004",
            designIntent: "ArgumentCaptorの使い方を理解する。"
        ),
        quiz(
            id: "boot3-test-mock-005",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@MockBean", "@SpyBean", "Spring Boot"],
            code: """
// @MockBean: 完全なモック（全メソッドがデフォルト値を返す）
@MockBean
private EmailService emailService;

// @SpyBean: 実実装を使い一部だけスタブ
@SpyBean
private AuditService auditService;
""",
            question: "`@MockBean` と `@SpyBean` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "@MockBeanは全メソッドをモックに置換するが、@SpyBeanは実実装を維持しつつ特定メソッドのみスタブできる", correct: true,
                       explanation: "@MockBeanは全てのメソッドが空（デフォルト値返却）のモックに置き換わります。@SpyBeanは実際のクラスを動かしつつ、一部のメソッドだけwhen()でスタブできます。"),
                choice("b", "@SpyBeanはインターフェースにのみ適用できる", misconception: "@SpyBeanがインターフェース限定と誤解",
                       explanation: "@SpyBeanは具体クラスに適用します（インターフェースの場合は実装クラスが必要です）。"),
                choice("c", "@MockBeanと@SpyBeanは同じ動作で違いはない", misconception: "両者を同一視",
                       explanation: "実実装を使うか全置換するかが根本的な違いです。"),
                choice("d", "@SpyBeanを使うとテストのたびにSpring Beanが再生成される", misconception: "@SpyBeanがコンテキストを汚染すると誤解",
                       explanation: "@SpyBeanはSpringコンテキストのBeanをSpyに置き換えますが、コンテキスト自体を毎回再生成するわけではありません。ただしコンテキストは汚染されます。")
            ],
            explanationRef: "explain-boot3-test-mock-005",
            designIntent: "@MockBeanと@SpyBeanの使い分けを理解する。"
        ),
    ]

    // MARK: - Group 5: テストデータ管理 (5問)
    private static let testingData: [Quiz] = [
        quiz(
            id: "boot3-test-data-001",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["Testcontainers", "PostgreSQL", "DockerContainer"],
            code: """
@Testcontainers
@SpringBootTest
class UserRepositoryContainerTest {

    @Container
    static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void overrideProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
""",
            question: "Testcontainersを使うメリットとして正しいのはどれか？",
            choices: [
                choice("a", "本番と同じDBエンジン（PostgreSQL等）でテストでき、H2の互換性問題を避けられる", correct: true,
                       explanation: "TestcontainersはDockerで実DBをテスト用に起動します。H2ではサポートされないPostgreSQL固有の機能（JSON型、特定の関数等）もテストできます。"),
                choice("b", "Testcontainersを使うとDockerなしでも本番PostgreSQLに自動接続される", misconception: "DockerなしでTestcontainersが動くと誤解",
                       explanation: "TestcontainersはDockerデーモンが必要です。Docker環境がない場合は動作しません。"),
                choice("c", "Testcontainersのコンテナは1回起動すると全テストスイートで共有されメモリが節約される", misconception: "コンテナ共有がデフォルトと誤解",
                       explanation: "staticフィールドにすることでJVM内で再利用されますが、デフォルトは各テストクラスで起動・終了します。"),
                choice("d", "Testcontainersはモックを使わないためテストが遅くなりCIには向かない", misconception: "TestcontainersがCI非推奨と誤解",
                       explanation: "Testcontainersは多くのCIサービス（GitHub Actions, CircleCI等）で使用されています。Dockerが利用可能なCIであれば問題なく動作します。")
            ],
            explanationRef: "explain-boot3-test-data-001",
            designIntent: "Testcontainersの利点を理解する。"
        ),
        quiz(
            id: "boot3-test-data-002",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["テストフィクスチャ", "ビルダーパターン", "オブジェクトマザー"],
            code: """
// テスト用ビルダー（Object Mother / Test Data Builder パターン）
public class UserTestFactory {
    public static User aValidUser() {
        return new User(1L, "Alice", "alice@example.com", Role.USER);
    }

    public static User anAdminUser() {
        return new User(2L, "Admin", "admin@example.com", Role.ADMIN);
    }
}

// テスト内
var user = UserTestFactory.aValidUser();
""",
            question: "テストデータにObject Motherパターンを使う利点として正しいのはどれか？",
            choices: [
                choice("a", "テスト用のエンティティ生成ロジックを一元管理し、エンティティ変更時の修正箇所を最小化できる", correct: true,
                       explanation: "Object Motherはテストデータ作成を集約します。エンティティにフィールドが追加された場合、ファクトリクラスのみを修正すればよくなります。"),
                choice("b", "Object Motherパターンを使うとJUnit5のパラメータ化テストが自動生成される", misconception: "Object Motherとパラメータ化テストを混同",
                       explanation: "Object Motherはデータ生成パターンです。パラメータ化テストとは独立しています。"),
                choice("c", "Object Motherパターンはテストコードの実行速度を2倍向上させる", misconception: "存在しないパフォーマンス改善",
                       explanation: "Object Motherは保守性のためのパターンです。実行速度には影響しません。"),
                choice("d", "Object Motherはインメモリ実装の代わりに使うDBモックである", misconception: "Object MotherがDBモックと誤解",
                       explanation: "Object Motherはテストオブジェクトを生成するファクトリです。DBのモックとは無関係です。")
            ],
            explanationRef: "explain-boot3-test-data-002",
            designIntent: "テストフィクスチャ管理のベストプラクティスを理解する。"
        ),
        quiz(
            id: "boot3-test-data-003",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@Rollback", "@Commit", "テストトランザクション"],
            code: """
@SpringBootTest
@Transactional
class UserServiceTest {

    @Test
    void createUser_savesSuccessfully() {
        userService.createUser("Alice");
        // このテスト後、DBへの変更はロールバックされる
    }

    @Test
    @Commit  // このテストだけコミット
    void createUser_verifyInDb() {
        userService.createUser("Bob");
    }
}
""",
            question: "`@SpringBootTest` に `@Transactional` を付けた場合の挙動として正しいのはどれか？",
            choices: [
                choice("a", "デフォルトで各テストメソッド後にロールバックされ、DBの状態が元に戻る", correct: true,
                       explanation: "@Transactionalをテストクラスに付けるとデフォルトでロールバックになります。テスト間の状態汚染を防ぐ標準的なパターンです。"),
                choice("b", "@SpringBootTestと@Transactionalを同時に使うとBeanCreationExceptionが発生する", misconception: "組み合わせが不正と誤解",
                       explanation: "@SpringBootTestと@Transactionalは共存できます。多くの統合テストで使われる組み合わせです。"),
                choice("c", "@Transactionalを付けた統合テストでは`@Commit`は使えない", misconception: "@Commitとの排他性を誤解",
                       explanation: "@Commitを使うとデフォルトのロールバック動作を上書きしてコミットできます。"),
                choice("d", "ロールバックは@DataJpaTestでのみ有効で、@SpringBootTestでは機能しない", misconception: "@SpringBootTestのトランザクション動作を誤解",
                       explanation: "@Transactionalと@SpringBootTestの組み合わせでもロールバックは機能します。")
            ],
            explanationRef: "explain-boot3-test-data-003",
            designIntent: "テストのトランザクション管理を理解する。"
        ),
        quiz(
            id: "boot3-test-data-004",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["MockMvc", "andExpect", "ResultMatcher"],
            code: """
mockMvc.perform(
        post("/api/users")
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                {"name": "", "email": "bad-email"}
                """))
    .andExpect(status().isBadRequest())
    .andExpect(jsonPath("$.errors.name").exists())
    .andExpect(jsonPath("$.errors.email").exists());
""",
            question: "MockMvcでバリデーションエラーを検証するこのテストが期待するのはどれか？",
            choices: [
                choice("a", "空のnameと不正なemailでPOSTすると400 Bad Requestが返り、errorsオブジェクトの各フィールドにエラーが含まれる", correct: true,
                       explanation: "このテストは入力バリデーション違反時のHTTPステータスとエラーレスポンス構造を検証します。`jsonPath`でJSONボディの特定パスの存在・値を確認できます。"),
                choice("b", "`jsonPath(\"$.errors.name\").exists()` は値が `null` でないことを確認する", misconception: "exists()がnull確認と誤解",
                       explanation: "`exists()` はJSONPathが指定したパスに要素が存在するかを確認します。値がnullかどうかではありません。"),
                choice("c", "MockMvcはJSONのネストを2階層までしか解析できない", misconception: "MockMvcの深さ制限を誤解",
                       explanation: "MockMvcはJSONPathライブラリを使うため任意の深さのJSONを解析できます。"),
                choice("d", "`andExpect(status().isBadRequest())` は400以上の全ステータスコードにマッチする", misconception: "isBadRequest()の厳密さを誤解",
                       explanation: "`isBadRequest()` はステータスコード400のみにマッチします。範囲マッチには`is4xxClientError()`を使います。")
            ],
            explanationRef: "explain-boot3-test-data-004",
            designIntent: "MockMvcのJSONパス検証を理解する。"
        ),
        quiz(
            id: "boot3-test-data-005",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["カバレッジ", "JaCoCo", "テスト品質"],
            code: """
# build.gradle (JaCoCoの設定)
jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = 0.80  // 80%以上のカバレッジを要求
            }
        }
    }
}
""",
            question: "コードカバレッジ80%について最も正しい考え方はどれか？",
            choices: [
                choice("a", "カバレッジは品質の一指標だが、100%を目指すより重要なビジネスロジックを確実にテストする方が価値が高い場合がある", correct: true,
                       explanation: "カバレッジはコードが「実行された」かを示しますが、「正しく動く」かは別問題です。ゲッター/セッターを含む100%より、コアロジックの実質的なテストが重要です。"),
                choice("b", "カバレッジ100%を達成すればバグは存在しないことが証明される", misconception: "100%カバレッジがバグフリーを保証すると誤解",
                       explanation: "カバレッジはコード行の実行を測定します。境界値・並行性・設計上の欠陥はカバレッジ100%でも検出できません。"),
                choice("c", "Spring Bootプロジェクトでは60%以下のカバレッジは必ずリリース禁止にすべき", misconception: "カバレッジ閾値に絶対的基準があると誤解",
                       explanation: "適切なカバレッジ閾値はプロジェクト・ドメイン・リスク許容度によります。一律の「禁止基準」はありません。"),
                choice("d", "JaCoCoはJUnit5と互換性がなくMaven専用のカバレッジツール", misconception: "JaCoCoの対応範囲を誤解",
                       explanation: "JaCoCoはJUnit5とGradle/Mavenの両方に対応しています。Spring Boot Gradleプロジェクトでも広く使われます。")
            ],
            explanationRef: "explain-boot3-test-data-005",
            designIntent: "コードカバレッジの正しい捉え方を理解する。"
        ),
    ]

    // MARK: - Group 6: Securityテスト (3問)
    private static let testingSecurity: [Quiz] = [
        quiz(
            id: "boot3-test-sec-001",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["@WithMockUser", "@WithUserDetails", "認証テスト"],
            code: """
@Test
@WithMockUser(username = "alice", roles = {"USER"})
void getProfile_withValidUser_returns200() throws Exception {
    mockMvc.perform(get("/profile"))
           .andExpect(status().isOk());
}

@Test
void getProfile_withoutAuth_returns401() throws Exception {
    mockMvc.perform(get("/profile"))
           .andExpect(status().isUnauthorized());
}
""",
            question: "`@WithMockUser` の動作として正しいのはどれか？",
            choices: [
                choice("a", "SecurityContextにモック認証情報をセットしDBへのアクセスなしに認証済みユーザーとしてテストできる", correct: true,
                       explanation: "@WithMockUserはSpring Security Testのアノテーションです。UsernamePasswordAuthenticationTokenをSecurityContextに設定します。実際のUserDetailsServiceは呼ばれません。"),
                choice("b", "@WithMockUserはDBに実際のユーザーを作成してから認証を行う", misconception: "@WithMockUserが実DBにアクセスすると誤解",
                       explanation: "@WithMockUserはモック認証のみです。DBへのアクセスは発生しません。"),
                choice("c", "認証なしのリクエストは常に403 Forbiddenになる", misconception: "401と403を混同",
                       explanation: "認証なし（未ログイン）は401 Unauthorized、認証済みだが権限不足は403 Forbiddenです。"),
                choice("d", "@WithMockUserはJUnit5では動作せずJUnit4のみに対応", misconception: "JUnit4限定と誤解",
                       explanation: "@WithMockUserはJUnit5（@ExtendWith(SpringExtension.class)）でも使用可能です。@SpringBootTestや@WebMvcTestで自動的に統合されます。")
            ],
            explanationRef: "explain-boot3-test-sec-001",
            designIntent: "@WithMockUserによる認証テストを理解する。"
        ),
        quiz(
            id: "boot3-test-sec-002",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["CSRF", "MockMvc", "テスト時のCSRF"],
            code: """
// CSRF無効でのPOSTテスト
mockMvc.perform(post("/api/orders")
        .with(csrf())  // ← CSRFトークンを付与
        .contentType(MediaType.APPLICATION_JSON)
        .content(orderJson))
    .andExpect(status().isCreated());
""",
            question: "`MockMvc` で CSRF が有効なコントローラをテストするとき `.with(csrf())` が必要な理由として正しいのはどれか？",
            choices: [
                choice("a", "Spring SecurityのCSRF保護によりCSRFトークンなしのPOSTは403になるため、テスト用トークンを自動付与する", correct: true,
                       explanation: "Spring SecurityはデフォルトでCSRF保護を有効にします。MockMvcでPOST等のリクエストをする場合、`.with(csrf())`でテスト用トークンを付与しないと403になります。"),
                choice("b", "`.with(csrf())` はJSONボディのエンコードを行うためPOSTリクエストに必須", misconception: "csrfがJSONエンコードと関係すると誤解",
                       explanation: "csrf()はCSRFトークンの付与のみです。JSONのエンコードは`.contentType(APPLICATION_JSON)`と`.content()`で行います。"),
                choice("c", "@WebMvcTestではCSRF保護は自動で無効化されるため`.with(csrf())`は不要", misconception: "@WebMvcTestがCSRFを無効化すると誤解",
                       explanation: "@WebMvcTestでもCSRF保護はデフォルトで有効です。`.with(csrf())`が必要です。完全に無効化するには`@AutoConfigureMockMvc(addFilters=false)`等を使います。"),
                choice("d", "`.with(csrf())` を使うと実際のCSRFトークンがDBに保存される", misconception: "テスト用CSRFトークンがDBに影響すると誤解",
                       explanation: "テスト用のCSRFトークンはインメモリのテストセッションに保存されます。DBへの書き込みは発生しません。")
            ],
            explanationRef: "explain-boot3-test-sec-002",
            designIntent: "テスト時のCSRF対処を理解する。"
        ),
        quiz(
            id: "boot3-test-sec-003",
            level: .practice,
            objective: "boot3-foundation-test",
            category: .testing,
            tags: ["メソッドセキュリティ", "@PreAuthorize", "テスト"],
            code: """
// サービスクラス
@Service
public class ReportService {
    @PreAuthorize("hasRole('ADMIN')")
    public Report generateReport() { ... }
}

// テスト
@SpringBootTest
class ReportServiceTest {

    @Autowired
    private ReportService reportService;

    @Test
    @WithMockUser(roles = "USER")
    void generateReport_withoutAdminRole_throwsAccessDenied() {
        assertThatThrownBy(() -> reportService.generateReport())
            .isInstanceOf(AccessDeniedException.class);
    }
}
""",
            question: "`@PreAuthorize` のメソッドセキュリティを `@WebMvcTest` でなく `@SpringBootTest` でテストする理由として正しいのはどれか？",
            choices: [
                choice("a", "@PreAuthorizeはAOP（Springプロキシ）で動作するため、フルSpringコンテキストが必要", correct: true,
                       explanation: "@PreAuthorizeはSpring AOPのプロキシが処理します。@WebMvcTestはWebレイヤーのみで、Serviceのプロキシは生成されません。フルコンテキストの@SpringBootTestが必要です。"),
                choice("b", "@WebMvcTestでも@PreAuthorizeのテストができるが、@SpringBootTestの方が高速なため推奨される", misconception: "@WebMvcTestでもメソッドSecurityが動くと誤解",
                       explanation: "@WebMvcTestではServiceのAOPプロキシが有効にならないため@PreAuthorizeのテストには不向きです。"),
                choice("c", "@SpringBootTestよりも@WebMvcTestの方が高速であるため@WebMvcTestを使うべき", misconception: "@WebMvcTestへの誤った推薦",
                       explanation: "@WebMvcTestがより高速なのは事実ですが、メソッドセキュリティのテストには@SpringBootTestが必要です。"),
                choice("d", "`@EnableMethodSecurity` を外せば@WebMvcTestでも動作する", misconception: "Securityを無効化すれば解決すると誤解",
                       explanation: "@EnableMethodSecurityを外すと@PreAuthorizeが機能しないためテストが意味をなしません。")
            ],
            explanationRef: "explain-boot3-test-sec-003",
            designIntent: "メソッドセキュリティのテスト方法を理解する。"
        ),
    ]
}
