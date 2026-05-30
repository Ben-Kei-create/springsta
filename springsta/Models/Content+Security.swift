import Foundation

extension Quiz {
    static let securityQuizzes: [Quiz] = (secBasics + secFilterChain + secAuth
        + secAuthorization + secCsrfCors + secAdvanced)
        .map { $0.contextualizedForPresentation() }

    // MARK: - Group 1: Spring Security基礎 (6問)
    private static let secBasics: [Quiz] = [
        quiz(
            id: "boot3-sec-basics-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["SecurityFilterChain", "フィルターチェーン", "自動設定"],
            code: """
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/public/**").permitAll()
                .anyRequest().authenticated()
            )
            .formLogin(Customizer.withDefaults())
            .httpBasic(Customizer.withDefaults());
        return http.build();
    }
}
""",
            question: "`SecurityFilterChain` を `@Bean` として定義する意味として正しいのはどれか？",
            choices: [
                choice("a", "Spring Bootのデフォルトセキュリティ設定を上書きしてカスタムの認証・認可ルールを定義するため", correct: true,
                       explanation: "@Beanでカスタム `SecurityFilterChain` を定義するとSpring Bootの自動設定（`UserDetailsServiceAutoConfiguration`等）を置き換えます。アプリ固有のルールを適用するための標準的なアプローチです。"),
                choice("b", "`SecurityFilterChain` はHTTPサーバのポート設定を行うBeanである", misconception: "FilterChainがサーバ設定と誤解",
                       explanation: "ポート設定は `server.port` で行います。SecurityFilterChainはHTTPリクエストへのセキュリティルール定義です。"),
                choice("c", "`@EnableWebSecurity` を付けるとSpring Bootのセキュリティは完全に無効化される", misconception: "@EnableWebSecurityが無効化と誤解",
                       explanation: "@EnableWebSecurityはWebセキュリティサポートを有効化するアノテーションです。無効化には`@EnableWebSecurity(debug=true)`等の別設定が必要です。"),
                choice("d", "`formLogin()` と `httpBasic()` は同時に定義できない", misconception: "複数認証方式の共存不可と誤解",
                       explanation: "formLoginとhttpBasicは共存できます。どちらの認証方式でもリクエストを処理できるようになります。")
            ],
            explanationRef: "explain-boot3-sec-basics-001",
            designIntent: "SecurityFilterChainの役割を理解する。"
        ),
        quiz(
            id: "boot3-sec-basics-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["UserDetailsService", "UserDetails", "認証"],
            code: """
@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username)
            throws UsernameNotFoundException {
        return userRepository.findByEmail(username)
            .map(user -> User.builder()
                .username(user.getEmail())
                .password(user.getPasswordHash())
                .roles(user.getRole().name())
                .build())
            .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));
    }
}
""",
            question: "`UserDetailsService.loadUserByUsername()` が呼ばれるタイミングとして正しいのはどれか？",
            choices: [
                choice("a", "ユーザーがログインを試みたとき、認証マネージャがユーザー情報を取得するために呼ぶ", correct: true,
                       explanation: "Spring SecurityはloadUserByUsername()でDBからユーザー情報を取得し、入力パスワードとハッシュを比較して認証を行います。"),
                choice("b", "全てのHTTPリクエストごとにloadUserByUsername()が呼ばれる", misconception: "毎リクエストで呼ばれると誤解",
                       explanation: "通常はログイン時のみ呼ばれます。セッションまたはJWTにより、以降のリクエストはユーザー情報を再取得しません。"),
                choice("c", "`@Service` を付けなければloadUserByUsername()は動作しない", misconception: "@ServiceがUserDetailsServiceに必須と誤解",
                       explanation: "重要なのはUserDetailsServiceインターフェースを実装したBeanがSpringコンテキストに存在することです。@Componentでも@Serviceでも登録されれば動作します。"),
                choice("d", "loadUserByUsername()内でパスワードの検証（比較）も行う必要がある", misconception: "パスワード検証をloadUserByUsernameで行うと誤解",
                       explanation: "loadUserByUsername()はユーザー情報の「取得」のみです。パスワードの検証はPasswordEncoderをSpring Securityが内部で使います。")
            ],
            explanationRef: "explain-boot3-sec-basics-002",
            designIntent: "UserDetailsServiceの役割を理解する。"
        ),
        quiz(
            id: "boot3-sec-basics-003",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["PasswordEncoder", "BCrypt", "パスワードハッシュ"],
            code: """
@Bean
public PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
}

// 登録時
String hashed = passwordEncoder.encode(rawPassword);
user.setPasswordHash(hashed);

// 認証時（Spring Securityが内部で実行）
boolean matches = passwordEncoder.matches(rawPassword, storedHash);
""",
            question: "BCryptPasswordEncoderを使う理由として正しいのはどれか？",
            choices: [
                choice("a", "ソルト付きのスローハッシュ関数でレインボーテーブル攻撃やブルートフォースに強い", correct: true,
                       explanation: "BCryptはランダムなソルトを自動生成し、計算コストを調整できるスローハッシュです。MD5/SHA等の高速ハッシュよりブルートフォース攻撃に耐性があります。"),
                choice("b", "BCryptはパスワードを暗号化（可逆変換）するため元のパスワードを復元できる", misconception: "ハッシュと暗号化を混同",
                       explanation: "BCryptはハッシュ（一方向変換）です。元のパスワードを復元することはできません。これが意図した設計です。"),
                choice("c", "同じパスワードに対してencode()を2回呼ぶと必ず同じハッシュ値になる", misconception: "BCryptの毎回異なるソルトを知らない",
                       explanation: "BCryptは毎回ランダムなソルトを使うため、同じパスワードでも実行ごとに異なるハッシュ値が生成されます。matches()はソルトを埋め込んだハッシュを使って比較します。"),
                choice("d", "BCryptPasswordEncoderは平文パスワードを受け入れず必ずBase64でエンコードが必要", misconception: "前処理が必要と誤解",
                       explanation: "BCryptPasswordEncoderは平文パスワードを直接受け付けます。Base64等の前処理は不要です。")
            ],
            explanationRef: "explain-boot3-sec-basics-003",
            designIntent: "BCryptPasswordEncoderの特性を理解する。"
        ),
        quiz(
            id: "boot3-sec-basics-004",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["SecurityContext", "Authentication", "スレッドローカル"],
            code: """
// 現在のユーザーを取得
Authentication auth = SecurityContextHolder.getContext().getAuthentication();
String username = auth.getName();
Collection<? extends GrantedAuthority> authorities = auth.getAuthorities();
""",
            question: "`SecurityContextHolder` にユーザー情報が格納されるタイミングとして正しいのはどれか？",
            choices: [
                choice("a", "認証成功後にSpring SecurityのフィルターがSecurityContextHolderにAuthenticationをセットし、リクエストスコープで保持される", correct: true,
                       explanation: "認証フィルター（UsernamePasswordAuthenticationFilter等）が認証成功後にSecurityContextHolderにセットします。スレッドローカルで保持されるためリクエスト処理中はどこからでも取得できます。"),
                choice("b", "SecurityContextHolderの情報はアプリ起動時に設定され全ユーザーで共有される", misconception: "共有シングルトンと誤解",
                       explanation: "デフォルトのSTRATEGY（ThreadLocalSecurityContextHolderStrategy）はスレッドローカルです。リクエストごとに独立した認証情報が保持されます。"),
                choice("c", "`@Transactional` メソッド内でのみSecurityContextHolderにアクセスできる", misconception: "トランザクション内限定と誤解",
                       explanation: "SecurityContextHolderはトランザクションと無関係に、リクエストを処理するスレッド上でアクセスできます。"),
                choice("d", "SecurityContextHolderはDBに認証情報を永続化する", misconception: "DBに保存されると誤解",
                       explanation: "SecurityContextHolderはスレッドローカルのインメモリ保持です。DB永続化が必要な場合はセッション管理やJWTで別途対応します。")
            ],
            explanationRef: "explain-boot3-sec-basics-004",
            designIntent: "SecurityContextHolderの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-sec-basics-005",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["セッション管理", "SessionCreationPolicy", "STATELESS"],
            code: """
// RESTful API向け設定（ステートレス）
http.sessionManagement(session -> session
    .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
);
""",
            question: "`SessionCreationPolicy.STATELESS` を設定する場合として適切なのはどれか？",
            choices: [
                choice("a", "JWTなどトークンベースの認証でセッションを使わないREST APIを構築する場合", correct: true,
                       explanation: "STATELESSはHTTPセッションを作成せず、SecurityContextHolderもリクエスト間で保持しません。各リクエストで認証を再実行するJWTベースAPIに適しています。"),
                choice("b", "STATELESSを設定するとユーザーのログイン状態が永久に維持される", misconception: "STATELESSがセッション不要で永続認証と誤解",
                       explanation: "STATELESSはセッションを使わないため、ログイン状態をサーバで保持しません。各リクエストで認証情報（トークン等）を送る必要があります。"),
                choice("c", "STATELESSを設定するとCSRF保護が自動で強化される", misconception: "STATELESSがCSRF保護を強化すると誤解",
                       explanation: "むしろSTATELESSなREST APIではCSRFを無効化する場合が多いです（Cookieベースのセッションを使わないため）。"),
                choice("d", "STATELESSはformLoginと組み合わせて使うのが推奨設定", misconception: "STATELESSとformLoginの組み合わせを誤解",
                       explanation: "formLoginはセッションベースの認証フローです。STATELESSと組み合わせると認証後にセッションが保持されないため機能しません。REST APIではJWT等のトークン認証を使います。")
            ],
            explanationRef: "explain-boot3-sec-basics-005",
            designIntent: "STATELESSセッションポリシーの使い所を理解する。"
        ),
        quiz(
            id: "boot3-sec-basics-006",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["認証 vs 認可", "AuthenticationManager", "AccessDecisionManager"],
            code: """
// 認証（Authentication）: 「あなたは誰？」
// → UsernamePasswordAuthenticationFilter, JwtAuthenticationFilter等

// 認可（Authorization）: 「何をしていいの？」
// → AuthorizationFilter, @PreAuthorize, requestMatchers().hasRole()等
""",
            question: "認証（Authentication）と認可（Authorization）の違いとして正しいのはどれか？",
            choices: [
                choice("a", "認証はユーザーの身元確認、認可は確認済みユーザーが特定リソースへのアクセス権を持つかの確認", correct: true,
                       explanation: "AuthenticationはWho（誰か）、AuthorizationはWhat（何ができるか）の検証です。Springでは認証後に認可フィルターが動作します。"),
                choice("b", "認証と認可は同じ処理で、Spring Securityでは区別されていない", misconception: "両者を同一視",
                       explanation: "Spring Securityは認証（AuthenticationManager）と認可（AuthorizationManager）を明確に分離した設計です。"),
                choice("c", "認可（Authorization）が先に実行され、失敗すると認証（Authentication）がスキップされる", misconception: "順序を逆に理解",
                       explanation: "必ず認証が先です。誰かを確認してから、その人に権限があるか確認します。"),
                choice("d", "Spring Bootでは認可の設定は不要で、認証さえ設定すれば全リソースが自動保護される", misconception: "認証のみで全保護と誤解",
                       explanation: "認証後にどのユーザーがどのリソースにアクセスできるかは認可で設定します。認証だけでは全認証ユーザーが全リソースにアクセスできてしまいます。")
            ],
            explanationRef: "explain-boot3-sec-basics-006",
            designIntent: "認証と認可の概念の違いを理解する。"
        ),
    ]

    // MARK: - Group 2: FilterChain設定 (5問)
    private static let secFilterChain: [Quiz] = [
        quiz(
            id: "boot3-sec-filter-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["requestMatchers", "antMatcher", "パスパターン"],
            code: """
http.authorizeHttpRequests(auth -> auth
    .requestMatchers("/api/admin/**").hasRole("ADMIN")
    .requestMatchers("/api/public/**").permitAll()
    .requestMatchers(HttpMethod.GET, "/api/products/**").hasAnyRole("USER", "ADMIN")
    .requestMatchers(HttpMethod.POST, "/api/products/**").hasRole("ADMIN")
    .anyRequest().authenticated()
);
""",
            question: "`requestMatchers` のルールが評価される順序として正しいのはどれか？",
            choices: [
                choice("a", "定義順（上から）に評価され、最初にマッチしたルールが適用される", correct: true,
                       explanation: "requestMatchersは上から順に評価されます。より具体的なパターンを先に書くことが重要です。`anyRequest()`は必ず最後に置く必要があります。"),
                choice("b", "より厳しい（restrictive）ルールが常に優先される", misconception: "厳しい方が自動優先と誤解",
                       explanation: "優先順位は厳しさではなく定義順です。意図しない順序で書くと期待通りに動きません。"),
                choice("c", "`permitAll()` ルールは全ての `hasRole()` より常に優先される", misconception: "permitAllが最優先と誤解",
                       explanation: "permitAllも定義順で評価されます。`/api/admin/**` の後に `/api/public/**` があるため、adminパスがまずADMINロールでチェックされます。"),
                choice("d", "`anyRequest()` は最も高い優先度を持つ", misconception: "anyRequestが最高優先と誤解",
                       explanation: "`anyRequest()` は最後のキャッチオールで、他のマッチャーの後に必ず置きます。先に書くと後続のルールに到達しません（コンパイルエラーになります）。")
            ],
            explanationRef: "explain-boot3-sec-filter-001",
            designIntent: "requestMatchersの評価順序を理解する。"
        ),
        quiz(
            id: "boot3-sec-filter-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["カスタムフィルター", "OncePerRequestFilter", "JWT"],
            code: """
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String token = extractToken(request);
        if (token != null && jwtService.isValid(token)) {
            Authentication auth = jwtService.getAuthentication(token);
            SecurityContextHolder.getContext().setAuthentication(auth);
        }
        filterChain.doFilter(request, response);  // (A)
    }
}
""",
            question: "`OncePerRequestFilter` を継承する理由として正しいのはどれか？",
            choices: [
                choice("a", "フォワードやインクルードを含むリクエストのディスパッチで1リクエストにつき1回だけ実行されることを保証するため", correct: true,
                       explanation: "OncePerRequestFilterはサーブレットのforward/include/error dispatch等でフィルターが複数回呼ばれるのを防ぎます。JWTの検証などを1回だけ実行するのに適しています。"),
                choice("b", "`OncePerRequestFilter` は非同期リクエストを自動で同期処理に変換する", misconception: "OncePerRequestFilterの機能を誤解",
                       explanation: "非同期処理の変換はOncePerRequestFilterの機能ではありません。非同期対応には`shouldNotFilterAsyncDispatch()`をオーバーライドします。"),
                choice("c", "(A) の `filterChain.doFilter()` を呼ばないとリクエストが破棄され401が返る", misconception: "doFilter省略の結果を誤解",
                       explanation: "filterChain.doFilter()を呼ばないとリクエスト処理が止まり（ハング）レスポンスが返らない、またはフィルターが明示的にレスポンスを書いて終了します。自動的に401が返るわけではありません。"),
                choice("d", "カスタムJWTフィルターは `@Component` の代わりに `@Bean` で定義しなければ動作しない", misconception: "@Componentと@Beanの差への誤解",
                       explanation: "@Componentでも@Beanでもフィルターとして登録できます。ただし@ComponentでAutoConfiguration経由で二重登録されないよう注意が必要な場合があります。")
            ],
            explanationRef: "explain-boot3-sec-filter-002",
            designIntent: "カスタムフィルターの実装方法を理解する。"
        ),
        quiz(
            id: "boot3-sec-filter-003",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["exceptionHandling", "AuthenticationEntryPoint", "AccessDeniedHandler"],
            code: """
http.exceptionHandling(ex -> ex
    .authenticationEntryPoint((request, response, authException) -> {
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.getWriter().write("{\"error\": \"Unauthorized\"}");
    })
    .accessDeniedHandler((request, response, accessDeniedException) -> {
        response.setStatus(HttpStatus.FORBIDDEN.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.getWriter().write("{\"error\": \"Forbidden\"}");
    })
);
""",
            question: "`AuthenticationEntryPoint` と `AccessDeniedHandler` の使い分けとして正しいのはどれか？",
            choices: [
                choice("a", "AuthenticationEntryPointは未認証アクセス（401）、AccessDeniedHandlerは認証済みだが権限不足（403）のエラーをカスタマイズする", correct: true,
                       explanation: "EntryPointはAnonymousUser等の未認証リクエスト用、AccessDeniedHandlerは認証済みユーザーの権限不足時用です。REST APIでJSON形式のエラーレスポンスを返すときにカスタマイズします。"),
                choice("b", "`AuthenticationEntryPoint` はログイン成功時のリダイレクト先を設定する", misconception: "AuthenticationEntryPointをSuccessHandlerと混同",
                       explanation: "ログイン成功時のリダイレクトはAuthenticationSuccessHandlerで設定します。EntryPointは認証失敗/未認証時の応答です。"),
                choice("c", "カスタムEntryPointを設定するとformLoginが自動で無効化される", misconception: "EntryPointの設定がformLoginに影響すると誤解",
                       explanation: "exceptionHandlingの設定とformLoginの設定は独立しています。formLoginは別途設定します。"),
                choice("d", "`AccessDeniedHandler` は全てのHttpステータスコードに対応できる", misconception: "全ステータスへの対応と誤解",
                       explanation: "AccessDeniedHandlerは403 Forbidden（権限不足）のケースに対応します。他のステータスコードへの応答は別のコンポーネントが担います。")
            ],
            explanationRef: "explain-boot3-sec-filter-003",
            designIntent: "セキュリティエラーハンドリングを理解する。"
        ),
        quiz(
            id: "boot3-sec-filter-004",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["複数SecurityFilterChain", "securityMatcher", "APIと管理画面"],
            code: """
@Bean
@Order(1)
public SecurityFilterChain apiSecurityChain(HttpSecurity http) throws Exception {
    http.securityMatcher("/api/**")
        .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
        .authorizeHttpRequests(a -> a.anyRequest().authenticated());
    return http.build();
}

@Bean
@Order(2)
public SecurityFilterChain webSecurityChain(HttpSecurity http) throws Exception {
    http.authorizeHttpRequests(a -> a.anyRequest().authenticated())
        .formLogin(Customizer.withDefaults());
    return http.build();
}
""",
            question: "複数の `SecurityFilterChain` を定義するユースケースとして正しいのはどれか？",
            choices: [
                choice("a", "REST API（JWT認証・STATELESS）と管理画面（フォームログイン・セッション）で異なるセキュリティポリシーを適用する場合", correct: true,
                       explanation: "securityMatcherでURLパターンごとに異なるSecurityFilterChainを適用できます。@Orderで評価順を制御し、APIとWeb画面で異なる認証方式を共存させることができます。"),
                choice("b", "複数のSecurityFilterChainを定義するとセキュリティが2倍強化される", misconception: "複数定義が強化につながると誤解",
                       explanation: "複数定義は強化ではなく、異なるルールの適用です。各リクエストは最初にマッチしたChainのみが処理します。"),
                choice("c", "`@Order` なしに複数のSecurityFilterChainを定義するとコンパイルエラーになる", misconception: "@Orderが必須と誤解",
                       explanation: "@Orderがないと順序が不定になり、意図しない動作をします。エラーではありませんが、必ず@Orderで明示するのがベストプラクティスです。"),
                choice("d", "Spring Boot 3.xでは SecurityFilterChain は1つしか定義できない", misconception: "複数定義が不可と誤解",
                       explanation: "Spring Boot 3.xでも複数のSecurityFilterChainを定義できます。これはSpring Securityの標準機能です。")
            ],
            explanationRef: "explain-boot3-sec-filter-004",
            designIntent: "複数SecurityFilterChainの活用を理解する。"
        ),
        quiz(
            id: "boot3-sec-filter-005",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["SecurityMatcher", "パブリックエンドポイント", "静的リソース"],
            code: """
http.authorizeHttpRequests(auth -> auth
    .requestMatchers("/css/**", "/js/**", "/images/**").permitAll()
    .requestMatchers("/actuator/health").permitAll()
    .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").hasRole("DEV")
    .anyRequest().authenticated()
);
""",
            question: "静的リソース（CSS/JS）を `permitAll()` で設定する際の注意点として正しいのはどれか？",
            choices: [
                choice("a", "WebSecurityCustomizerでセキュリティフィルター自体をバイパスする方がパフォーマンスが良い場合がある", correct: true,
                       explanation: "`permitAll()` はフィルタリングして許可しますが、静的リソースはセキュリティ処理自体が不要なことが多いです。`WebSecurityCustomizer.ignoring()` でフィルターチェーンをバイパスするとオーバーヘッドを削減できます。"),
                choice("b", "`permitAll()` を設定すると認証済みユーザーもCSS/JSにアクセスできなくなる", misconception: "permitAllが認証ユーザーをブロックすると誤解",
                       explanation: "`permitAll()` は「誰でも（未認証含む）アクセス可能」という設定です。認証ユーザーも当然アクセスできます。"),
                choice("c", "静的リソースに `permitAll()` を設定しないとSpring Bootが起動しない", misconception: "静的リソースのpermitAllが必須と誤解",
                       explanation: "起動条件ではありませんが、`permitAll()` がないと静的リソースへのアクセスも認証が必要になります。"),
                choice("d", "`/actuator/health` を `permitAll()` にするとActuatorの全エンドポイントが公開される", misconception: "healthがpermitAllで全Actuatorが公開されると誤解",
                       explanation: "requestMatchersは明示したパスのみに適用されます。`/actuator/health` を許可しても他のActuatorエンドポイントは影響を受けません。")
            ],
            explanationRef: "explain-boot3-sec-filter-005",
            designIntent: "静的リソースのセキュリティ設定を理解する。"
        ),
    ]

    // MARK: - Group 3: 認証方式 (6問)
    private static let secAuth: [Quiz] = [
        quiz(
            id: "boot3-sec-auth-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["JWT", "Bearer", "トークン認証"],
            code: """
// リクエストヘッダー
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhbGljZSIsInJvbGVzIjpbIlVTRVIiXX0.xxx

// JWTの構造: Header.Payload.Signature
// {alg: "HS256"}.{sub:"alice", roles:["USER"], exp:1234567890}.HMAC
""",
            question: "JWT（JSON Web Token）をREST API認証に使う利点として正しいのはどれか？",
            choices: [
                choice("a", "サーバがセッション状態を持たずスケールアウトしやすい（ステートレス認証）", correct: true,
                       explanation: "JWTはペイロードに認証情報を含み、サーバ側でセッションを保持不要です。ロードバランサ下の複数インスタンスでもセッション共有設定なしに認証が機能します。"),
                choice("b", "JWTはサーバ側で無効化（失効）できないためセキュリティが高い", misconception: "失効不可をセキュリティの利点と誤解",
                       explanation: "失効不可はJWTのデメリットです。ログアウト後もトークンの有効期限内は使えてしまいます。対策にはブラックリスト管理や短い有効期限が必要です。"),
                choice("c", "JWTのペイロードは暗号化されているため機密情報を含めても安全", misconception: "JWTが暗号化されていると誤解",
                       explanation: "通常のJWT（JWS）はBase64エンコードであり暗号化ではありません。誰でもデコードできます。機密情報は含めてはいけません。JWEは暗号化できますが別規格です。"),
                choice("d", "JWTを使うとパスワードの保存が不要になる", misconception: "JWTがパスワード不要にすると誤解",
                       explanation: "JWTはトークンの形式です。最初のログイン認証にはパスワード等の認証情報が引き続き必要です。")
            ],
            explanationRef: "explain-boot3-sec-auth-001",
            designIntent: "JWT認証の利点と注意点を理解する。"
        ),
        quiz(
            id: "boot3-sec-auth-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["OAuth2", "ResourceServer", "JWT"],
            code: """
# application.yml（OAuth2 Resource Serverの設定）
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: https://auth.example.com/realms/myrealm
""",
            question: "Spring Bootで `resourceserver.jwt` の設定をする目的として正しいのはどれか？",
            choices: [
                choice("a", "認証サーバ（Keycloak等）が発行したJWTを検証する公開鍵をIssuer URIから取得してトークンを自動検証する", correct: true,
                       explanation: "issuer-uriを設定するとSpring Bootが`.well-known/openid-configuration`エンドポイントから公開鍵情報を取得し、JWTの署名と有効期限を自動検証します。"),
                choice("b", "この設定だけでOAuth2認証サーバが起動する", misconception: "resourceserver設定がサーバ起動と誤解",
                       explanation: "resourceserverはトークンを「検証する」側の設定です。認証サーバはKeycloak等の別サービスです。"),
                choice("c", "issuer-uriを設定するとJWTの発行（生成）も自動で行われる", misconception: "resourceserverが発行も行うと誤解",
                       explanation: "リソースサーバはトークンを検証するだけです。発行は認証サーバ（Authorization Server）の役割です。"),
                choice("d", "Spring Boot 3.xでは`oauth2-resource-server`の依存が標準含まれるため追加不要", misconception: "標準含まれると誤解",
                       explanation: "`spring-boot-starter-oauth2-resource-server`を別途依存に追加する必要があります。")
            ],
            explanationRef: "explain-boot3-sec-auth-002",
            designIntent: "OAuth2 Resource Serverの設定を理解する。"
        ),
        quiz(
            id: "boot3-sec-auth-003",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["OAuth2 Login", "OIDC", "ソーシャルログイン"],
            code: """
# application.yml（Google OAuth2ログイン）
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: ${GOOGLE_CLIENT_ID}
            client-secret: ${GOOGLE_CLIENT_SECRET}
            scope: openid, profile, email
""",
            question: "Spring Bootで `spring.security.oauth2.client.registration` を設定するとどうなるか？",
            choices: [
                choice("a", "「Googleでログイン」などのOAuth2/OIDCを使ったソーシャルログインが有効になる", correct: true,
                       explanation: "spring-boot-starter-oauth2-clientと組み合わせることで、指定した認証プロバイダへのOAuth2認可コードフローが自動設定されます。`/oauth2/authorization/google`へのリダイレクトが自動生成されます。"),
                choice("b", "この設定だけでアプリがOAuth2認証サーバになる", misconception: "クライアント設定がサーバになると誤解",
                       explanation: "これはOAuth2クライアント（Google等を使ってログインする側）の設定です。認証サーバには別途Spring Authorization Server等が必要です。"),
                choice("c", "`scope: openid` を設定するとパスワードがGoogleに送信される", misconception: "OIDCのscopeがパスワード送信と誤解",
                       explanation: "openid scopeはIDトークンを取得するためのOIDC標準スコープです。パスワードはGoogleの認証ページでのみ入力し、アプリには届きません。"),
                choice("d", "Google以外のプロバイダ（GitHub等）には対応していない", misconception: "Googleのみ対応と誤解",
                       explanation: "Spring SecurityはGoogle、GitHub、Facebook、Okta等の一般的なプロバイダに対応しています。カスタムプロバイダも設定可能です。")
            ],
            explanationRef: "explain-boot3-sec-auth-003",
            designIntent: "OAuth2 Loginの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-sec-auth-004",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["Remember-me", "セッション", "永続化"],
            code: """
http.rememberMe(remember -> remember
    .tokenRepository(persistentTokenRepository())
    .tokenValiditySeconds(604800)  // 1週間
);

@Bean
public PersistentTokenRepository persistentTokenRepository() {
    JdbcTokenRepositoryImpl repo = new JdbcTokenRepositoryImpl();
    repo.setDataSource(dataSource);
    return repo;
}
""",
            question: "Remember-me機能の注意点として正しいのはどれか？",
            choices: [
                choice("a", "持続的なトークンをDBに保存する設定でないとサーバ再起動後にRemember-meトークンが無効になる", correct: true,
                       explanation: "デフォルトのインメモリトークン（SimpleHashBasedTokenRepository）はサーバ再起動で失効します。JdbcTokenRepositoryImplを使うとDB保存で永続化できます。"),
                choice("b", "Remember-meトークンが漏洩してもパスワードと同等の権限は持たない", misconception: "Remember-meトークンが弱い認証と誤解",
                       explanation: "Remember-meトークンは事実上のパスワード代替です。漏洩すると第三者がそのアカウントにログインできます。HTTPSでの転送と適切な保管が必要です。"),
                choice("c", "Remember-meはCSRF攻撃に対して自動的に保護される", misconception: "Remember-meがCSRFを自動保護すると誤解",
                       explanation: "Remember-meとCSRF保護は独立した機能です。Remember-meを使っていてもCSRF対策は別途必要です。"),
                choice("d", "`tokenValiditySeconds` を設定しないとトークンは1時間で失効する", misconception: "デフォルトの有効期限を誤解",
                       explanation: "デフォルトのtokenValiditySecondsは2週間（1209600秒）です。1時間ではありません。")
            ],
            explanationRef: "explain-boot3-sec-auth-004",
            designIntent: "Remember-meの実装と注意点を理解する。"
        ),
        quiz(
            id: "boot3-sec-auth-005",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["ログアウト", "logoutSuccessUrl", "CookieクリアrLogout"],
            code: """
http.logout(logout -> logout
    .logoutUrl("/logout")
    .logoutSuccessUrl("/login?logout")
    .invalidateHttpSession(true)
    .deleteCookies("JSESSIONID", "remember-me")
    .clearAuthentication(true)
);
""",
            question: "`logout()` の設定で `deleteCookies(\"JSESSIONID\")` を設定する理由として正しいのはどれか？",
            choices: [
                choice("a", "JSESSIONIDクッキーを削除しないと、セッションを無効化してもクライアントが同じCookieを送り続けるため", correct: true,
                       explanation: "サーバでセッションを無効化しても、クライアントはJSESSIONIDを送り続けます。deleteCookiesでブラウザのCookieを削除することで完全なログアウトになります。"),
                choice("b", "JSESSIONIDを削除すると全ユーザーが強制ログアウトされる", misconception: "一人のログアウトが全員に影響と誤解",
                       explanation: "deleteCookies はそのレスポンスを受け取ったブラウザのCookieのみを削除します。他ユーザーには影響しません。"),
                choice("c", "`invalidateHttpSession(true)` だけでCookieも削除されるため `deleteCookies` は不要", misconception: "invalidateがCookieも消すと誤解",
                       explanation: "`invalidateHttpSession` はサーバ側のセッションデータを削除します。クライアントのCookieは残ります。`deleteCookies`で明示的に削除が必要です。"),
                choice("d", "`deleteCookies` はHTTPSでのみ動作する", misconception: "HTTPSのみ対応と誤解",
                       explanation: "`deleteCookies`はHTTP/HTTPS両方で動作します。ただしSecure属性のCookieはHTTPS接続でのみ送受信されます。")
            ],
            explanationRef: "explain-boot3-sec-auth-005",
            designIntent: "完全なログアウト処理の設定を理解する。"
        ),
        quiz(
            id: "boot3-sec-auth-006",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["MFA", "二要素認証", "TOTP"],
            code: """
// 多要素認証の概念（Spring Security拡張）
// 1st Factor: パスワード認証
// 2nd Factor: TOTP (Google Authenticator等)
// → PARTIALLY_AUTHENTICATED → MFA検証後 → FULLY_AUTHENTICATED
""",
            question: "二要素認証（MFA）をSpring Bootで実装する際の設計として正しいのはどれか？",
            choices: [
                choice("a", "カスタムAuthenticationFilterまたは部分認証状態を使い、第1要素成功後に第2要素を要求するフローを実装する", correct: true,
                       explanation: "Spring SecurityはMFAを標準提供しません。AuthenticationFilterのカスタマイズやカスタムGrantedAuthority（PARTIALLY_AUTHENTICATED）を使って2ステップの認証フローを実装します。"),
                choice("b", "`@EnableTwoFactorAuth` アノテーションを付けるだけで自動有効化される", misconception: "存在しないアノテーション",
                       explanation: "`@EnableTwoFactorAuth` というSpring Security標準アノテーションは存在しません。"),
                choice("c", "Spring Boot 3.xでは二要素認証が標準機能として追加された", misconception: "Spring Boot 3.xでMFAが標準化されたと誤解",
                       explanation: "Spring Security/Spring Boot 3.xにMFAの標準実装はありません。拡張ライブラリまたはカスタム実装が必要です。"),
                choice("d", "MFAを実装するにはSpring Cloud Gatewayが必須", misconception: "Spring Cloud Gatewayが必要と誤解",
                       explanation: "MFAはSpring Cloud Gatewayなしにアプリレベルで実装できます。Spring Cloud Gatewayはマイクロサービスのルーティング用です。")
            ],
            explanationRef: "explain-boot3-sec-auth-006",
            designIntent: "MFAの実装アプローチを理解する。"
        ),
    ]

    // MARK: - Group 4: 認可制御 (6問)
    private static let secAuthorization: [Quiz] = [
        quiz(
            id: "boot3-sec-authz-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["@PreAuthorize", "@PostAuthorize", "メソッドセキュリティ"],
            code: """
@Service
public class DocumentService {

    @PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
    public Document getDocument(Long documentId, Long userId) { ... }

    @PostAuthorize("returnObject.ownerId == authentication.principal.id")
    public Document getMyDocument(Long documentId) { ... }
}
""",
            question: "`@PreAuthorize` と `@PostAuthorize` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "@PreAuthorizeはメソッド実行前に権限チェック、@PostAuthorizeはメソッド実行後に戻り値を使ってチェック", correct: true,
                       explanation: "@PreAuthorizeで引数や認証情報を使った事前チェック、@PostAuthorizeで戻り値オブジェクトの所有者確認などの事後チェックができます。"),
                choice("b", "@PostAuthorizeはメソッド実行をキャンセルして権限エラーを返すため常に@PreAuthorizeより安全", misconception: "@PostAuthorizeが事前をキャンセルすると誤解",
                       explanation: "@PostAuthorizeはメソッドが実行された後にチェックします。DB操作等が既に完了した後でのチェックのため、副作用が生じる場合があります。"),
                choice("c", "`#userId` はSpELの変数で、パラメータ名ではなくインデックス（#0）でのみ使える", misconception: "@PreAuthorizeのパラメータ参照方法を誤解",
                       explanation: "`#userId` はメソッドのパラメータ名でアクセスできます。`-parameters` コンパイルフラグまたはSpring AOPの設定が必要ですが、Spring Bootは自動で設定します。"),
                choice("d", "@PreAuthorizeはControllerのみで使用可能でServiceには適用できない", misconception: "@PreAuthorizeの適用場所の誤解",
                       explanation: "@PreAuthorizeはControllerやService、Repositoryなどどのレイヤーでも使用できます。@EnableMethodSecurityが有効であれば機能します。")
            ],
            explanationRef: "explain-boot3-sec-authz-001",
            designIntent: "@PreAuthorizeと@PostAuthorizeの違いを理解する。"
        ),
        quiz(
            id: "boot3-sec-authz-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["@EnableMethodSecurity", "hasRole", "hasAuthority"],
            code: """
@SpringBootApplication
@EnableMethodSecurity  // Spring Boot 3.xの推奨（旧: @EnableGlobalMethodSecurity）
public class App {}
""",
            question: "`hasRole('ADMIN')` と `hasAuthority('ROLE_ADMIN')` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "`hasRole('ADMIN')` は自動で`ROLE_`プレフィックスを付加し `hasAuthority('ROLE_ADMIN')` と同等になる", correct: true,
                       explanation: "Spring SecurityはhasRole()に`ROLE_`プレフィックスを自動付加します。GrantedAuthorityに`ROLE_ADMIN`を登録した場合、どちらの表現でも一致します。"),
                choice("b", "`hasRole()` はURL認証でのみ使え、`hasAuthority()` はメソッドセキュリティのみで使える", misconception: "適用場所に違いがあると誤解",
                       explanation: "両方ともURL認証（requestMatchers）でもメソッドセキュリティ（@PreAuthorize）でも使えます。"),
                choice("c", "`hasAuthority('ROLE_ADMIN')` にはROLE_プレフィックスを含めてはいけない", misconception: "hasAuthorityにROLE_プレフィックス不可と誤解",
                       explanation: "`hasAuthority()` はGrantedAuthorityの文字列と完全一致で比較します。GrantedAuthorityに`ROLE_ADMIN`が含まれる場合は`hasAuthority('ROLE_ADMIN')`が正しい指定です。"),
                choice("d", "Spring Boot 3.xでは `hasRole()` が廃止され `hasAuthority()` のみ使用可能", misconception: "廃止されたという誤情報",
                       explanation: "両方ともSpring Boot 3.xで使用可能です。廃止されていません。")
            ],
            explanationRef: "explain-boot3-sec-authz-002",
            designIntent: "hasRoleとhasAuthorityの関係を理解する。"
        ),
        quiz(
            id: "boot3-sec-authz-003",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["@Secured", "@RolesAllowed", "@PreAuthorize比較"],
            code: """
// 3種類の方法の比較

@Secured("ROLE_ADMIN")  // Spring Security独自
public void method1() {}

@RolesAllowed("ADMIN")  // JSR-250標準
public void method2() {}

@PreAuthorize("hasRole('ADMIN') and #param.length() <= 100")  // SpEL式
public void method3(String param) {}
""",
            question: "`@PreAuthorize` を `@Secured` より推奨する理由として正しいのはどれか？",
            choices: [
                choice("a", "@PreAuthorizeはSpELを使った複雑な条件（引数の検査、複数ロール、カスタム条件）を表現できる", correct: true,
                       explanation: "@SecuredはロールのONLY指定しかできません。@PreAuthorizeはSpELで認証情報・引数・戻り値などを使った柔軟な条件が書けます。"),
                choice("b", "@Securedは非推奨でSpring Boot 3.xで削除された", misconception: "@Securedが削除されたと誤解",
                       explanation: "@SecuredはSpring Boot 3.xでも使用可能です。ただし@PreAuthorizeの方が表現力が高く推奨されます。"),
                choice("c", "@RolesAllowedはJakarta EEアプリでのみ機能しSpring Bootでは動作しない", misconception: "@RolesAllowedがSpring Bootで動作しないと誤解",
                       explanation: "@RolesAllowedはSpring Bootでも`@EnableMethodSecurity(jsr250Enabled=true)`で使用できます。"),
                choice("d", "@PreAuthorizeの方が@Securedより実行速度が速い", misconception: "パフォーマンスの違いがあると誤解",
                       explanation: "両者のパフォーマンス差は無視できるほど小さいです。選択基準は表現力・標準準拠・保守性です。")
            ],
            explanationRef: "explain-boot3-sec-authz-003",
            designIntent: "メソッドセキュリティアノテーションの比較を理解する。"
        ),
        quiz(
            id: "boot3-sec-authz-004",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["Spring Security ACL", "オブジェクトレベル認可", "ドメインオブジェクト"],
            code: """
// ドメインオブジェクトレベルの認可（ACL）の概念
// 「Alice はDocument#1の編集権を持つ」
// 「Bob はDocument#1の読み取り権のみ」
// → @PostFilter, @PreFilter, Spring Security ACL
""",
            question: "オブジェクトレベルの認可（OLS）が必要なシナリオとして正しいのはどれか？",
            choices: [
                choice("a", "ユーザーが自分のデータのみ編集可能で、他ユーザーのデータは読み取りのみというような行レベルのアクセス制御", correct: true,
                       explanation: "「自分のドキュメントのみ編集可能」のようなオブジェクト単位のアクセス制御はロールベース（RBAC）だけでは難しいです。@PostFilterやSpring Security ACL、またはサービス層での手動チェックで実装します。"),
                choice("b", "オブジェクトレベル認可はSpring Security ACLライブラリなしに実装できない", misconception: "ACLライブラリが必須と誤解",
                       explanation: "@PostAuthorize、@PostFilter、またはサービス層での手動チェックでも実装できます。ACLライブラリは複雑な権限管理に有用ですが必須ではありません。"),
                choice("c", "`@PreAuthorize` では行レベルの制御ができないため、DBに直接SQLで制限を掛ける必要がある", misconception: "@PreAuthorizeでの行レベル制御不可と誤解",
                       explanation: "@PreAuthorize(`#doc.ownerId == authentication.principal.id`)のように引数オブジェクトを使った制御が可能です。ただし引数が取得前のIDの場合は@PostAuthorizeが必要です。"),
                choice("d", "Spring BootはRow Level Security（RLS）をDBレベルで自動設定する", misconception: "Spring BootがDB RLSを自動設定すると誤解",
                       explanation: "DB RLSはSpring Bootが自動設定するものではありません。DBの機能として別途設定が必要です。")
            ],
            explanationRef: "explain-boot3-sec-authz-004",
            designIntent: "オブジェクトレベル認可の必要性を理解する。"
        ),
        quiz(
            id: "boot3-sec-authz-005",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["@PostFilter", "@PreFilter", "コレクション認可"],
            code: """
@PostFilter("filterObject.ownerId == authentication.principal.id")
public List<Document> getDocuments() {
    return documentRepository.findAll();  // 全件取得後にフィルタリング
}
""",
            question: "`@PostFilter` を使う場合の問題点として正しいのはどれか？",
            choices: [
                choice("a", "全件をDBから取得してからJavaでフィルタリングするためデータ量が多いと非効率", correct: true,
                       explanation: "@PostFilterはDBから全件取得後にメモリでフィルタリングします。大量データに対しては非効率です。WHERE句でユーザーのオーナーIDを使ったクエリの方がDBレベルで絞り込めて効率的です。"),
                choice("b", "@PostFilterを使うとN+1問題が発生する", misconception: "@PostFilterがN+1を引き起こすと誤解",
                       explanation: "@PostFilterはコレクション要素のフィルタリングです。クエリの発行回数には直接影響しません（DBから全件取得する問題はありますが）。"),
                choice("c", "@PostFilterは戻り値がListのメソッドにのみ適用でき、Pageには使えない", misconception: "@PostFilterの適用型の誤解",
                       explanation: "@PostFilterはIterable実装クラス（List、Set等）に適用できます。Pageの場合は内部のコンテンツへの適用に注意が必要です。"),
                choice("d", "@PostFilterを使うと戻り値がnullになる可能性がある", misconception: "@PostFilterがnullを返すと誤解",
                       explanation: "@PostFilterは空のコレクションを返すことはあっても、nullは返しません。")
            ],
            explanationRef: "explain-boot3-sec-authz-005",
            designIntent: "@PostFilterの効率問題を理解する。"
        ),
        quiz(
            id: "boot3-sec-authz-006",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["Principal", "Authentication", "コントローラ"],
            code: """
@GetMapping("/profile")
public ProfileDto getProfile(
    @AuthenticationPrincipal CustomUserPrincipal principal) {
    return profileService.getProfile(principal.getId());
}
""",
            question: "`@AuthenticationPrincipal` の動作として正しいのはどれか？",
            choices: [
                choice("a", "SecurityContextHolderから認証済みユーザー情報を取得してメソッドパラメータに注入する", correct: true,
                       explanation: "@AuthenticationPrincipalはSecurityContextHolder.getContext().getAuthentication().getPrincipal()を自動で取得・注入するアノテーションです。コントローラでセキュリティコードを減らせます。"),
                choice("b", "@AuthenticationPrincipalを使うと毎回DBからユーザー情報が再取得される", misconception: "毎回DB取得されると誤解",
                       explanation: "@AuthenticationPrincipalはSecurityContext（スレッドローカル）からprincipalを取得します。認証時に一度設定された情報をそのまま使うため、DBアクセスは発生しません。"),
                choice("c", "@AuthenticationPrincipalはWebFlux（リアクティブ）では使えない", misconception: "WebFlux非対応と誤解",
                       explanation: "@AuthenticationPrincipalはSpring MVCとWebFluxの両方で使用できます。"),
                choice("d", "@AuthenticationPrincipalで注入した値はnullになることがないためnullチェックは不要", misconception: "常にnull以外と誤解",
                       explanation: "未認証状態（anonymousユーザー）ではprincipalがAnonymousAuthenticationTokenになる場合があります。CustomUserPrincipalへのキャストが失敗することを考慮し、適切な処理が必要です。")
            ],
            explanationRef: "explain-boot3-sec-authz-006",
            designIntent: "@AuthenticationPrincipalの使い方を理解する。"
        ),
    ]

    // MARK: - Group 5: CSRF・CORS (6問)
    private static let secCsrfCors: [Quiz] = [
        quiz(
            id: "boot3-sec-csrf-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["CSRF", "クロスサイトリクエストフォージェリ", "CSRFトークン"],
            code: """
// CSRF攻撃のシナリオ
// 1. Alice が bank.com にログイン（セッションCookie保持）
// 2. 攻撃者のサイトに誘導
// 3. 攻撃者サイトのフォームが勝手に bank.com へPOST
//    → AliceのCookieが自動添付されてしまう
// 4. bank.com は正規リクエストと判断してしまう
""",
            question: "CSRF対策のCSRFトークンが有効な理由として正しいのはどれか？",
            choices: [
                choice("a", "攻撃者は被害者のブラウザにあるCSRFトークンを事前に知れないためフォームに含められない", correct: true,
                       explanation: "CSRFトークンはセッションに紐付いた秘密値で、HTMLフォームに埋め込まれます。Same-OriginポリシーによりCookieは読めても別サイトからトークン値を読む手段がないため、攻撃者は正しいトークンをリクエストに含められません。"),
                choice("b", "CSRFトークンはパスワードの代替として使われ認証を強化する", misconception: "CSRFトークンを認証強化と誤解",
                       explanation: "CSRFトークンはリクエストの正当性検証（同一サイト起源チェック）のためです。パスワードの代替ではありません。"),
                choice("c", "REST APIでJWTを使えばCSRFトークンは不要でCSRF攻撃は発生しない", misconception: "JWTで全てのCSRFが防ぎと誤解",
                       explanation: "JWTをCookieで保存する場合はCSRFリスクがあります。JWTをLocalStorageに保存してAuthorizationヘッダーで送る場合はCSRFリスクが低い（ただしXSSリスクがある）。"),
                choice("d", "CSRFトークンを使うとXSS攻撃も自動で防止される", misconception: "CSRFとXSS対策を混同",
                       explanation: "CSRFトークンはCSRFを防ぎます。XSS（クロスサイトスクリプティング）は別の攻撃で、Content Security Policy等の別対策が必要です。")
            ],
            explanationRef: "explain-boot3-sec-csrf-001",
            designIntent: "CSRF攻撃の仕組みとCSRFトークンの防御原理を理解する。"
        ),
        quiz(
            id: "boot3-sec-csrf-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["CSRF無効化", "SameSite", "REST API"],
            code: """
// REST APIでCSRFを無効化する場合
http.csrf(csrf -> csrf.disable());

// SameSite Cookie属性を使う場合（CSRF対策の代替）
// server.servlet.session.cookie.same-site=strict
""",
            question: "REST APIでCSRFを無効化して安全にする条件として正しいのはどれか？",
            choices: [
                choice("a", "セッションCookieを使わず全てのリクエストでAuthorizationヘッダーによるトークン認証を行う場合", correct: true,
                       explanation: "CSRFはCookieの自動添付を悪用します。Authorizationヘッダーによるトークン認証は攻撃者が設定できないため、CSRFリスクがありません。JWTをAuthorizationヘッダーで送るREST APIはCSRFを無効化して問題ありません。"),
                choice("b", "HTTPSを使えばCSRFは発生しないためdisable()は常に安全", misconception: "HTTPSがCSRFを防ぐと誤解",
                       explanation: "HTTPSは通信の暗号化です。CSRFの問題（Cookieの自動添付）はHTTPSでも発生します。"),
                choice("c", "Spring Boot 3.xではCSRFはデフォルトで無効化された", misconception: "デフォルト変更という誤情報",
                       explanation: "Spring Boot 3.xでもCSRF保護はデフォルトで有効です。REST APIでは明示的に無効化が必要です。"),
                choice("d", "csrf.disable()を使うとXSS攻撃の保護も無効化される", misconception: "CSRF無効化がXSS防止も解除すると誤解",
                       explanation: "CSRFとXSSは独立したセキュリティ機能です。csrf.disable()はCSRF保護のみを無効化します。")
            ],
            explanationRef: "explain-boot3-sec-csrf-002",
            designIntent: "CSRF無効化の安全な条件を理解する。"
        ),
        quiz(
            id: "boot3-sec-cors-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["CORS", "Cross-Origin", "@CrossOrigin"],
            code: """
@Configuration
public class CorsConfig {

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("https://app.example.com"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);
        return source;
    }
}
""",
            question: "CORSの `allowCredentials(true)` と `allowedOrigins(\"*\")` の組み合わせがエラーになる理由として正しいのはどれか？",
            choices: [
                choice("a", "セキュリティ上の理由から、ブラウザの仕様でcredentials=trueと*の組み合わせは許可されていない", correct: true,
                       explanation: "credentialsを送る場合（Cookie等）、全オリジン（*）のワイルドカードはセキュリティリスクが高いためブラウザが拒否します。具体的なオリジンの指定が必要です。"),
                choice("b", "`allowedOrigins(\"*\")` はSpring Security設定でのみ無効で、@CrossOriginでは動作する", misconception: "設定方法による差異を誤解",
                       explanation: "ブラウザの仕様によるため、設定方法（@CrossOriginかCorsConfigurationSourceか）に関わらず同様です。"),
                choice("c", "`allowCredentials(true)` を使うとHTTPSのみ有効になるためHTTPでエラーになる", misconception: "allowCredentialsとHTTPS要件を混同",
                       explanation: "allowCredentialsとHTTPS要件は直接関係しません。ただしCookieのSecure属性をHTTPSで使うことは別途推奨されます。"),
                choice("d", "`allowCredentials(true)` はSpring Boot 3.xで廃止されて `exposeCookies(true)` に変更された", misconception: "APIが変更されたという誤情報",
                       explanation: "allowCredentials(true)はSpring Boot 3.xでも使用可能です。廃止されていません。")
            ],
            explanationRef: "explain-boot3-sec-cors-001",
            designIntent: "CORSのcredentialsと*の非互換を理解する。"
        ),
        quiz(
            id: "boot3-sec-cors-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["PreflightRequest", "OPTIONS", "CORS"],
            code: """
// Preflightリクエスト
// ブラウザが自動送信: OPTIONS /api/data HTTP/1.1
// Access-Control-Request-Method: POST
// Access-Control-Request-Headers: Authorization

// サーバのレスポンス
// Access-Control-Allow-Origin: https://app.example.com
// Access-Control-Allow-Methods: GET, POST, PUT
// Access-Control-Allow-Headers: Authorization
""",
            question: "CORSのPreflight（プリフライト）リクエストとして正しいのはどれか？",
            choices: [
                choice("a", "ブラウザが実際のリクエスト前にOPTIONSメソッドでサーバにCORSポリシーを確認するリクエスト", correct: true,
                       explanation: "単純リクエスト（GETのフォーム等）以外のCrossOriginリクエストでは、ブラウザが自動的にOPTIONSリクエストを事前送信します。サーバが適切なCORSヘッダーを返せば実際のリクエストが続行されます。"),
                choice("b", "Preflightリクエストはサーバが送信してブラウザが受け取る", misconception: "送信方向を逆に理解",
                       explanation: "Preflightはブラウザが送信してサーバが応答します。"),
                choice("c", "Preflightリクエストを無効化するとCORSが完全に無効化される", misconception: "PreflightとCORS自体の無効化を混同",
                       explanation: "Preflightはブラウザの自動動作です。サーバ側でPreflightに応答しないとブラウザがCORSエラーを出しますが、CORSポリシー自体は別設定です。"),
                choice("d", "Spring SecurityはPreflightリクエストをデフォルトでブロックする", misconception: "PreflightがSpring Securityにブロックされると誤解",
                       explanation: "CorsConfigurationSourceを正しく設定すれば、Spring SecurityはPreflightリクエストを適切に処理します。設定なしでは403になる場合があります。")
            ],
            explanationRef: "explain-boot3-sec-cors-002",
            designIntent: "CORSのPreflightリクエストを理解する。"
        ),
        quiz(
            id: "boot3-sec-headers-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["セキュリティヘッダー", "Content-Security-Policy", "X-Frame-Options"],
            code: """
// Spring Security デフォルトのセキュリティヘッダー
// X-Content-Type-Options: nosniff
// X-Frame-Options: DENY
// X-XSS-Protection: 0 (モダンブラウザでは非推奨)
// Cache-Control: no-cache, no-store, max-age=0

// Content-Security-Policy の追加
http.headers(headers -> headers
    .contentSecurityPolicy(csp -> csp
        .policyDirectives("default-src 'self'; script-src 'self' https://cdn.example.com")
    )
);
""",
            question: "`X-Frame-Options: DENY` の効果として正しいのはどれか？",
            choices: [
                choice("a", "このサイトをiframeで埋め込むことを禁止し、クリックジャッキング攻撃を防ぐ", correct: true,
                       explanation: "X-Frame-Options: DENYはiframe内へのページ埋め込みを禁止します。クリックジャッキング（透明なiframeを重ねてユーザーをだます攻撃）の防止に有効です。"),
                choice("b", "X-Frame-Optionsを設定するとサイトのフレームレートが制限される", misconception: "別の「フレーム」の意味と混同",
                       explanation: "X-Frame-OptionsのFrameはHTMLの`<iframe>`です。映像のフレームレートとは無関係です。"),
                choice("c", "`DENY` の代わりに `SAMEORIGIN` を使うとフレームの使用が完全に許可される", misconception: "SAMEORIGINとALLOWの混同",
                       explanation: "SAMEORIGINは同一オリジンからのみiframeを許可します。完全許可ではありません。"),
                choice("d", "Content-Security-PolicyはX-Frame-Optionsと同じ機能を持つ", misconception: "CSPとX-Frame-Optionsを同一視",
                       explanation: "CSPのframe-ancestors指定がX-Frame-Optionsの後継で同等機能を持ちますが、古いブラウザではX-Frame-Optionsが必要です。")
            ],
            explanationRef: "explain-boot3-sec-headers-001",
            designIntent: "セキュリティヘッダーの効果を理解する。"
        ),
        quiz(
            id: "boot3-sec-headers-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["HTTPS", "HSTS", "TLS"],
            code: """
http.headers(headers -> headers
    .httpStrictTransportSecurity(hsts -> hsts
        .includeSubDomains(true)
        .preload(true)
        .maxAgeInSeconds(31536000)  // 1年
    )
);
""",
            question: "HTTP Strict Transport Security（HSTS）の効果として正しいのはどれか？",
            choices: [
                choice("a", "ブラウザが一度アクセスするとmaxAge期間はHTTPを自動でHTTPSにリダイレクトし、SSL剥奪攻撃を防ぐ", correct: true,
                       explanation: "HSTSはブラウザにHTTPSのみを使うよう指示します。HTTPアクセス試行をブラウザ自身がHTTPSに変換するためSSL剥奪（SSLstrip）攻撃が難しくなります。"),
                choice("b", "HSTSを設定するとSSL証明書が自動発行される", misconception: "HSTSが証明書を発行すると誤解",
                       explanation: "SSL証明書はLet's Encrypt等で別途取得します。HSTSはHTTPSを強制するポリシーの指示のみです。"),
                choice("c", "HSTSはHTTPサイト（非HTTPS）でも設定すれば有効になる", misconception: "HTTP上でHSTSが動くと誤解",
                       explanation: "HSTSはHTTPSレスポンスヘッダーでのみ有効です。HTTPで送っても無視されます。"),
                choice("d", "preload=trueだけでブラウザのpreloadリストに自動登録される", misconception: "preload指定が自動登録と誤解",
                       explanation: "preload=trueはpreloadリストへの申請の意思表示ですが、実際の登録はhstspreload.orgへの申請が別途必要です。")
            ],
            explanationRef: "explain-boot3-sec-headers-002",
            designIntent: "HSTSによるHTTPS強制の仕組みを理解する。"
        ),
    ]

    // MARK: - Group 6: 高度なトピック (6問)
    private static let secAdvanced: [Quiz] = [
        quiz(
            id: "boot3-sec-adv-001",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["脆弱性診断", "OWASP", "セキュリティテスト"],
            code: """
// OWASP Top 10 (2021) Spring Boot関連
// A01: Broken Access Control → @PreAuthorize, requestMatchers
// A02: Cryptographic Failures → BCrypt, HTTPS/TLS
// A03: Injection → JPA(SQLインジェクション対策), Thymeleaf(XSS対策)
// A07: Identification and Authentication → Spring Security設定
""",
            question: "SQLインジェクションをSpring Data JPAで防ぐ仕組みとして正しいのはどれか？",
            choices: [
                choice("a", "JPQLとパラメータバインディング（:param/@Param）を使うことでSQLが動的に文字列結合されず安全", correct: true,
                       explanation: "JPA/JPQLはパラメータをプリペアドステートメントとして処理します。文字列結合を使うと危険ですが、`@Param`による名前付きパラメータはSQLインジェクションを防ぎます。"),
                choice("b", "ネイティブSQL（nativeQuery=true）を使えばSQLインジェクションが自動で防ぎれる", misconception: "nativeQueryが安全と誤解",
                       explanation: "ネイティブSQLでも`:param`バインディングを使えば安全ですが、文字列を直接結合するとSQLインジェクションが発生します。"),
                choice("c", "Spring Security の設定だけでSQLインジェクションは完全に防ぐことができる", misconception: "Spring SecurityがSQLインジェクション対策と誤解",
                       explanation: "Spring Securityは認証・認可のフレームワークです。SQLインジェクション対策はJPAの適切な使用とバインディングが担います。"),
                choice("d", "Spring Boot 3.xではSQL文字列操作が全て禁止されSQLインジェクションは発生しない", misconception: "フレームワークが文字列操作を禁止すると誤解",
                       explanation: "文字列結合でSQLを組み立てることは依然可能です。開発者がパラメータバインディングを使う習慣が重要です。")
            ],
            explanationRef: "explain-boot3-sec-adv-001",
            designIntent: "SQLインジェクション対策とJPAの関係を理解する。"
        ),
        quiz(
            id: "boot3-sec-adv-002",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["XSS", "Thymeleaf", "エスケープ"],
            code: """
<!-- Thymeleafのテキスト表示 -->
<!-- 安全：自動エスケープ -->
<span th:text="${user.name}">名前</span>

<!-- 危険：エスケープなし -->
<span th:utext="${user.name}">名前</span>
""",
            question: "`th:utext` の使用が危険な理由として正しいのはどれか？",
            choices: [
                choice("a", "HTML特殊文字をエスケープしないためユーザー入力に`<script>`タグが含まれるとXSSが発生する", correct: true,
                       explanation: "`th:utext`はHTMLとして出力します（u = unescaped）。ユーザー入力の`<script>alert(1)</script>`がそのまま実行され、XSS攻撃につながります。"),
                choice("b", "`th:utext` は `th:text` より2倍遅い", misconception: "存在しないパフォーマンス差",
                       explanation: "エスケープ処理の違いはパフォーマンスには無視できる影響です。"),
                choice("c", "`th:utext` はSpring Boot 3.xで削除された", misconception: "廃止されたという誤情報",
                       explanation: "`th:utext` は引き続き使用可能ですが、ユーザー入力への使用は危険です。"),
                choice("d", "`th:text` を使っても信頼できるHTMLタグはThymeleafが自動でutext処理する", misconception: "th:textが一部utext処理すると誤解",
                       explanation: "`th:text` は常にHTMLエスケープします。自動でutext処理する機能はありません。")
            ],
            explanationRef: "explain-boot3-sec-adv-002",
            designIntent: "XSS対策とThymeleafのエスケープを理解する。"
        ),
        quiz(
            id: "boot3-sec-adv-003",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["Spring Authorization Server", "認証サーバ", "OAuth2"],
            code: """
# Spring Authorization Server（認証サーバ側）
# 依存: spring-boot-starter-oauth2-authorization-server

@Bean
public RegisteredClientRepository registeredClientRepository() {
    RegisteredClient client = RegisteredClient.withId(UUID.randomUUID().toString())
        .clientId("my-client")
        .clientSecret("{bcrypt}" + passwordEncoder.encode("secret"))
        .authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE)
        .redirectUri("https://myapp.example.com/callback")
        .scope(OidcScopes.OPENID)
        .build();
    return new InMemoryRegisteredClientRepository(client);
}
""",
            question: "Spring Authorization Serverの役割として正しいのはどれか？",
            choices: [
                choice("a", "OAuth2/OIDCの認証サーバとして動作し、JWTトークンの発行やクライアント管理を行う", correct: true,
                       explanation: "Spring Authorization ServerはOAuth2 Authorization ServerとOIDC Providerを実装します。Keycloak等の代わりにSpringのエコシステムで認証サーバを構築できます。"),
                choice("b", "Spring Authorization ServerはKeycloakよりも高機能なため常に置き換えを推奨", misconception: "Spring Authorization Serverが常に優れると誤解",
                       explanation: "Spring Authorization Serverは基本機能を提供しますが、KeycloakはUI管理コンソール、LDAP連携等の豊富な機能を持ちます。用途に応じて選択します。"),
                choice("c", "Spring Authorization Serverを使うとリソースサーバの設定が不要になる", misconception: "認証サーバがリソースサーバも兼ねると誤解",
                       explanation: "認証サーバとリソースサーバは別コンポーネントです。アプリサーバはリソースサーバとして別途設定が必要です。"),
                choice("d", "Spring Authorization Serverは`spring-boot-starter-security`に含まれる", misconception: "標準Securityスターターに含まれると誤解",
                       explanation: "`spring-boot-starter-oauth2-authorization-server`を別途追加する必要があります。")
            ],
            explanationRef: "explain-boot3-sec-adv-003",
            designIntent: "Spring Authorization Serverの役割を理解する。"
        ),
        quiz(
            id: "boot3-sec-adv-004",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["セキュリティテスト", "@WithMockUser", "SecurityMockMvcRequestPostProcessors"],
            code: """
// JWTベースAPIのセキュリティテスト
@Test
void apiEndpoint_withValidJwt_returns200() throws Exception {
    mockMvc.perform(get("/api/data")
        .with(SecurityMockMvcRequestPostProcessors.jwt()
            .authorities(new SimpleGrantedAuthority("SCOPE_read"))))
        .andExpect(status().isOk());
}
""",
            question: "`SecurityMockMvcRequestPostProcessors.jwt()` を使うテストの目的として正しいのはどれか？",
            choices: [
                choice("a", "実際のJWTを発行せずにJWT認証済みのリクエストをシミュレートして認可ロジックをテストする", correct: true,
                       explanation: "`jwt()` はJWT認証フィルターを通ってSecurityContextに認証をセットした状態をシミュレートします。実際のJWT署名検証をスキップして認可ロジックのテストに集中できます。"),
                choice("b", "このテストは実際のJWT署名検証を行うため秘密鍵の設定が必要", misconception: "jwt()が実際の検証を行うと誤解",
                       explanation: "`jwt()` はSpring Security Testのユーティリティで、認証フィルターをバイパスして直接SecurityContextを設定します。秘密鍵は不要です。"),
                choice("c", "`jwt()` は`@WithMockUser`と全く同じ動作をする", misconception: "jwt()と@WithMockUserを同一視",
                       explanation: "`@WithMockUser`はフォーム認証/Basicの認証セットアップ。`jwt()`はJWT（OAuth2）の認証セットアップです。設定されるAuthenticationの型が異なります。"),
                choice("d", "`jwt()` はSpring Boot 3.xで削除されOAuth2TokenRequestPostProcessorに変更された", misconception: "廃止されたという誤情報",
                       explanation: "`jwt()` はSpring Boot 3.xでも使用可能です。")
            ],
            explanationRef: "explain-boot3-sec-adv-004",
            designIntent: "JWTベースAPIのセキュリティテスト方法を理解する。"
        ),
        quiz(
            id: "boot3-sec-adv-005",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["セッション固定攻撃", "Session Fixation", "sessionFixation"],
            code: """
// Spring Securityのデフォルト: 認証後にセッションIDを変更（固定攻撃防止）
http.sessionManagement(session -> session
    .sessionFixation().changeSessionId()  // デフォルト
    // .migrateSession() // 旧属性をコピーしてセッションID変更
    // .none()           // 非推奨: セッションID変更なし（脆弱）
);
""",
            question: "セッション固定攻撃（Session Fixation）の説明として正しいのはどれか？",
            choices: [
                choice("a", "攻撃者が既知のセッションIDを被害者に使わせることで、そのセッションIDでなりすましログインする攻撃", correct: true,
                       explanation: "セッション固定攻撃は攻撃者が用意したセッションIDにURLやCookieで被害者を誘導し、被害者がそのIDでログインした後にそのセッションを乗っ取ります。認証後のセッションID変更（changeSessionId）で防ぎます。"),
                choice("b", "セッション固定攻撃はCSRF攻撃の別名", misconception: "セッション固定とCSRFを混同",
                       explanation: "CSRF（クロスサイトリクエストフォージェリ）は別の攻撃です。セッション固定はセッションIDの乗っ取りです。"),
                choice("c", "`sessionFixation().none()` が最も安全でデフォルトより推奨される", misconception: "none()が安全と誤解",
                       explanation: "`none()`はセッションIDを変更しないため、セッション固定攻撃に脆弱です。デフォルトの`changeSessionId()`が推奨です。"),
                choice("d", "Spring Boot 3.xではセッション固定攻撃の心配は不要になった", misconception: "フレームワーク更新で解決済みと誤解",
                       explanation: "セッション固定攻撃のリスクは設定によります。デフォルトのchangeSessionId()が有効であれば防がれますが、none()に変更した場合は脆弱になります。")
            ],
            explanationRef: "explain-boot3-sec-adv-005",
            designIntent: "セッション固定攻撃と防止策を理解する。"
        ),
        quiz(
            id: "boot3-sec-adv-006",
            level: .practice,
            objective: "boot3-practice-security",
            category: .security,
            tags: ["Mass Assignment", "@JsonIgnore", "入力バリデーション"],
            code: """
// 脆弱なコード: エンティティを直接マップ
@PostMapping("/users")
public User createUser(@RequestBody User user) {
    // userに admin=true を含むJSONを送られるとそのまま保存される
    return userRepository.save(user);
}

// 安全なコード: DTOで受け取る
@PostMapping("/users")
public User createUser(@RequestBody CreateUserDto dto) {
    User user = new User(dto.getName(), dto.getEmail());
    // adminフィールドはDTOに存在しないため設定不可
    return userRepository.save(user);
}
""",
            question: "Mass Assignment脆弱性を防ぐ最も確実な方法として正しいのはどれか？",
            choices: [
                choice("a", "入力を受け取るDTOクラスを別途定義し、受け付けるフィールドを明示的に制限する", correct: true,
                       explanation: "DTOパターンはMass Assignmentの根本的な防止策です。@JsonIgnoreやブラックリスト方式は設定漏れのリスクがあります。DTOで明示的に許可フィールドを定義するホワイトリスト方式が安全です。"),
                choice("b", "`@JsonIgnore` をadminフィールドに付ければMass Assignmentは完全に防げる", misconception: "@JsonIgnoreが万全の防止策と誤解",
                       explanation: "@JsonIgnoreはデシリアライズ（JSONからオブジェクト）を防ぎますが、設定漏れのリスクがあります。DTOの方が明示的で安全です。"),
                choice("c", "Spring Securityのcsrf()設定でMass Assignmentを防げる", misconception: "CSRF設定がMass Assignmentを防ぐと誤解",
                       explanation: "CSRF保護は全く別の攻撃への対策です。Mass AssignmentはAPIの入力設計で対処します。"),
                choice("d", "Hibernate Validatorの@NotNullを全フィールドに付けることでMass Assignmentを防げる", misconception: "バリデーションがMass Assignmentを防ぐと誤解",
                       explanation: "@NotNullはNULL値の検証です。フィールドの受け入れ可否とは無関係です。")
            ],
            explanationRef: "explain-boot3-sec-adv-006",
            designIntent: "Mass Assignment脆弱性の防止策を理解する。"
        ),
    ]
}
