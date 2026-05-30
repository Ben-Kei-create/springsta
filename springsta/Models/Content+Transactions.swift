import Foundation

extension Quiz {
    static let transactionQuizzes: [Quiz] = (txBasics + txPropagation + txIsolation
        + txRollback + txAdvanced)
        .map { $0.contextualizedForPresentation() }

    // MARK: - Group 1: トランザクション基礎 (6問)
    private static let txBasics: [Quiz] = [
        quiz(
            id: "boot3-tx-basics-001",
            level: .foundation,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Transactional", "ACID", "原子性"],
            code: """
@Service
public class BankService {

    @Transactional
    public void transfer(Long fromId, Long toId, int amount) {
        Account from = accountRepo.findById(fromId).orElseThrow();
        Account to   = accountRepo.findById(toId).orElseThrow();

        from.withdraw(amount);  // (A) 残高減算
        to.deposit(amount);     // (B) 残高加算

        accountRepo.save(from);
        accountRepo.save(to);
    }
}
""",
            question: "`@Transactional` を使う最大の理由として正しいのはどれか？",
            choices: [
                choice("a", "(A)と(B)の両操作を原子的にまとめ、途中で例外が発生しても残高が崩れないようにするため", correct: true,
                       explanation: "@Transactionalはメソッド全体を1トランザクションに包みます。(A)成功後に(B)で例外が起きても(A)はロールバックされ、整合性が保たれます。"),
                choice("b", "@Transactionalを付けると並行アクセスが自動でシリアライズされる", misconception: "トランザクションが並列制御を完全に解決すると誤解",
                       explanation: "直列化は分離レベルSERIALIZABLEで実現します。@Transactionalだけで全ての並行問題を解決するわけではありません。"),
                choice("c", "@Transactionalを付けるとメソッドの実行が非同期になりパフォーマンスが向上する", misconception: "トランザクションと非同期を混同",
                       explanation: "@Transactionalは同期的に動作します。非同期化には@Asyncが必要です。"),
                choice("d", "@Transactionalがなければ`save()`が動作しない", misconception: "saveにトランザクションが必須と誤解",
                       explanation: "JpaRepositoryのsave()自体が@Transactionalを持っているため呼び出せます。ただし複数操作をまとめるには呼び出し元への@Transactionalが必要です。")
            ],
            explanationRef: "explain-boot3-tx-basics-001",
            designIntent: "@Transactionalの原子性の役割を理解する。"
        ),
        quiz(
            id: "boot3-tx-basics-002",
            level: .foundation,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Transactional", "Proxy", "self-invocation"],
            code: """
@Service
public class OrderService {

    public void processAll(List<Order> orders) {
        orders.forEach(this::processSingle);  // (A) 内部呼び出し
    }

    @Transactional
    public void processSingle(Order order) {
        // DB操作
    }
}
""",
            question: "(A) のように同じクラス内から `@Transactional` メソッドを呼ぶと何が起きるか？",
            choices: [
                choice("a", "Springのプロキシを経由しないため、`@Transactional` が無視されトランザクションが開始されない", correct: true,
                       explanation: "@TransactionalはSpring AOPプロキシで動作します。`this.method()` の呼び出しはプロキシをバイパスするため@Transactionalのインターセプタが動作しません。"),
                choice("b", "`@Transactional` は内部呼び出しでも正常に動作し、各Orderが個別トランザクションで処理される", misconception: "内部呼び出しでもトランザクションが動くと誤解",
                       explanation: "Springのデフォルト（JDKプロキシ/CGLIBプロキシ）では内部呼び出しはAOPが効きません。"),
                choice("c", "同クラス内の呼び出しは禁止されており、コンパイルエラーになる", misconception: "内部呼び出しがコンパイルエラーと誤解",
                       explanation: "コンパイルエラーは発生しません。AOP動作が想定通りにならない点が落とし穴です。"),
                choice("d", "`@Transactional` のスコープが広がり、`processAll` 全体が1トランザクションになる", misconception: "内部呼び出しでスコープが広がると誤解",
                       explanation: "プロキシをバイパスするため、`processSingle` の@Transactionalは全く機能しません。")
            ],
            explanationRef: "explain-boot3-tx-basics-002",
            designIntent: "Springのトランザクションプロキシの仕組みとself-invocationの落とし穴を理解する。"
        ),
        quiz(
            id: "boot3-tx-basics-003",
            level: .foundation,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Transactional", "クラスレベル", "メソッドレベル"],
            code: """
@Service
@Transactional(readOnly = true)  // クラスレベル
public class ProductService {

    public List<Product> findAll() { ... }  // readOnly=true 継承

    @Transactional  // メソッドレベルで上書き
    public void save(Product p) { ... }  // readOnly=false
}
""",
            question: "クラスレベルとメソッドレベルの `@Transactional` の優先順位として正しいのはどれか？",
            choices: [
                choice("a", "メソッドレベルの設定がクラスレベルを上書きし、`save()` は `readOnly=false` で動作する", correct: true,
                       explanation: "より詳細な（メソッドレベル）の@Transactionalが優先されます。デフォルト（readOnly=false）を持つ@Transactionalで上書きされ書き込みが可能になります。"),
                choice("b", "クラスレベルとメソッドレベルの設定がマージされ、より制限の強い方が採用される", misconception: "制限の強い方が勝つと誤解",
                       explanation: "マージではなく上書きです。メソッドレベルの設定が完全にクラスレベルを置き換えます。"),
                choice("c", "メソッドレベルの`@Transactional`がある場合、クラスレベルの`@Transactional`は全メソッドで無効になる", misconception: "1つのメソッドで上書きすると全体が無効になると誤解",
                       explanation: "メソッドレベルがない`findAll()`はクラスレベルのreadOnly=trueを継承します。上書きはそのメソッドのみに適用されます。"),
                choice("d", "クラスレベルに`readOnly=true`があると、`@Transactional`を付けても書き込みは禁止される", misconception: "クラスレベルが完全優先と誤解",
                       explanation: "メソッドレベルの@Transactionalで上書きできるため書き込みは可能です。")
            ],
            explanationRef: "explain-boot3-tx-basics-003",
            designIntent: "@Transactionalの優先順位を理解する。"
        ),
        quiz(
            id: "boot3-tx-basics-004",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["トランザクション境界", "Service層", "責務"],
            code: """
// パターンA: Controllerにトランザクションを置く（非推奨）
@RestController
public class OrderController {
    @Transactional
    @PostMapping("/orders")
    public ResponseEntity<?> create(@RequestBody OrderDto dto) {
        orderService.processOrder(dto);
        return ResponseEntity.ok().build();
    }
}

// パターンB: Service層にトランザクションを置く（推奨）
@Service
public class OrderService {
    @Transactional
    public void processOrder(OrderDto dto) { ... }
}
""",
            question: "トランザクション境界をController層ではなくService層に置く理由として正しいのはどれか？",
            choices: [
                choice("a", "Service層はビジネスロジックの境界であり、REST・バッチ・テストなど複数呼び出し元でトランザクション境界を共有できる", correct: true,
                       explanation: "Service層にトランザクションを置くことでControllerからもバッチからも同じトランザクション境界を使えます。Controllerに置くとテストが難しくなり、再利用性も下がります。"),
                choice("b", "Spring MVCの仕様でControllerに@Transactionalを付けることは禁止されている", misconception: "技術的に禁止と誤解",
                       explanation: "技術的には動作しますが、設計上の問題があります。禁止ではなく非推奨です。"),
                choice("c", "Controllerに@Transactionalを付けるとHTTPセッションが終了するまでトランザクションが継続する", misconception: "HTTPセッションとトランザクションが連動すると誤解",
                       explanation: "トランザクション境界はメソッドの開始・終了です。HTTPセッションとは無関係です。"),
                choice("d", "Service層に@Transactionalを置くとDBのロックが自動で解放される", misconception: "Service層のトランザクションがロックを特別管理すると誤解",
                       explanation: "ロックはトランザクションのコミット・ロールバック時に解放されます。Service/Controllerの違いは関係ありません。")
            ],
            explanationRef: "explain-boot3-tx-basics-004",
            designIntent: "トランザクション境界の適切な配置を理解する。"
        ),
        quiz(
            id: "boot3-tx-basics-005",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["flush", "commit", "タイミング"],
            code: """
@Transactional
public void updateAndRead(Long id) {
    Product p = repo.findById(id).orElseThrow();
    p.setPrice(999);
    // save()は呼ばない（ダーティチェック）

    // 同トランザクション内で再クエリ
    int price = repo.findPriceById(id);  // (A)
}
""",
            question: "(A) の `findPriceById(id)` が返す値として正しいのはどれか（デフォルト設定の場合）？",
            choices: [
                choice("a", "フラッシュ前であれば更新前の999が返る可能性があり、フラッシュ後なら999が返る", correct: true,
                       explanation: "Hibernateはデフォルトでクエリ実行前に自動フラッシュ（FlushMode.AUTO）します。そのため`findPriceById()`の前にフラッシュが走り、999が返るのが一般的な動作です。"),
                choice("b", "同一トランザクション内のSELECTは必ず更新前の値をキャッシュから返す", misconception: "L1キャッシュが更新を見せないと誤解",
                       explanation: "L1キャッシュはエンティティのIDキャッシュです。新しいクエリ（findPriceById）はSQLを発行します。FlushMode.AUTOによりフラッシュ後に最新値が返ります。"),
                choice("c", "@Transactionalがあれば変更は即座にDBに反映されSELECTは常に最新値を返す", misconception: "@Transactionalで即座反映と誤解",
                       explanation: "変更はフラッシュ時にDBに送られますが、コミット前は他のトランザクションには見えません。"),
                choice("d", "同一トランザクション内でDAOを2回呼ぶと例外が発生する", misconception: "複数のクエリが禁止されていると誤解",
                       explanation: "1トランザクション内で複数のクエリを発行することは一般的で問題ありません。")
            ],
            explanationRef: "explain-boot3-tx-basics-005",
            designIntent: "同一トランザクション内でのフラッシュとSELECTの順序を理解する。"
        ),
        quiz(
            id: "boot3-tx-basics-006",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["TransactionSynchronizationManager", "afterCommit", "イベント"],
            code: """
@Transactional
public void createUser(UserDto dto) {
    User user = userRepository.save(new User(dto));

    // コミット後にメール送信
    TransactionSynchronizationManager.registerSynchronization(
        new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                emailService.sendWelcome(user.getEmail());
            }
        }
    );
}
""",
            question: "`afterCommit()` フックを使ってメール送信を行う理由として正しいのはどれか？",
            choices: [
                choice("a", "トランザクションがロールバックした場合にメール送信を行わないようにするため", correct: true,
                       explanation: "メール送信はロールバックできません。トランザクションが成功（コミット）した後に送信することで、不整合（DBロールバック後にメールだけ送られる）を防ぎます。"),
                choice("b", "`afterCommit()` を使うとメール送信が非同期で実行される", misconception: "afterCommitが非同期実行を意味すると誤解",
                       explanation: "`afterCommit()`は同期的に実行されます。非同期にするには@Asyncを別途使います。"),
                choice("c", "`afterCommit()` はトランザクション外でも呼び出せる", misconception: "トランザクション外でも使えると誤解",
                       explanation: "`TransactionSynchronizationManager`はアクティブなトランザクション内でのみ意味があります。トランザクション外での登録は無視される場合があります。"),
                choice("d", "このパターンは非推奨でSpring Boot 3.xでは `@TransactionalEventListener` の使用が必須", misconception: "TransactionSynchronizationが廃止と誤解",
                       explanation: "TransactionSynchronizationは引き続き使用可能です。@TransactionalEventListenerも同様の目的に使えるより宣言的なアプローチです。")
            ],
            explanationRef: "explain-boot3-tx-basics-006",
            designIntent: "コミット後処理のパターンを理解する。"
        ),
    ]

    // MARK: - Group 2: 伝播属性 (6問)
    private static let txPropagation: [Quiz] = [
        quiz(
            id: "boot3-tx-prop-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["REQUIRED", "伝播", "デフォルト"],
            code: """
// 伝播のデフォルト: REQUIRED
@Transactional  // = @Transactional(propagation = Propagation.REQUIRED)
public void serviceA() {
    serviceB();  // 既存トランザクションに参加
}

@Transactional
public void serviceB() {
    // (A) serviceAのトランザクション内で実行
}
""",
            question: "`Propagation.REQUIRED`（デフォルト）の動作として正しいのはどれか？",
            choices: [
                choice("a", "既存トランザクションがあれば参加し、なければ新しいトランザクションを開始する", correct: true,
                       explanation: "REQUIREDは最も一般的な伝播設定です。呼び出し元にトランザクションがあれば合流し、なければ新規作成します。"),
                choice("b", "常に新しいトランザクションを開始し、呼び出し元のトランザクションを一時停止する", misconception: "REQUIREDとREQUIRES_NEWを混同",
                       explanation: "常に新規開始するのはREQUIRES_NEWです。REQUIREDは既存に参加します。"),
                choice("c", "トランザクションなしで実行し、呼び出し元のトランザクションを破棄する", misconception: "NOT_SUPPORTEDとREQUIREDを混同",
                       explanation: "トランザクションなしで実行するのはNOT_SUPPORTEDです。"),
                choice("d", "REQUIRED伝播では呼び出し先がロールバックしても呼び出し元はコミットできる", misconception: "同一トランザクションでの独立ロールバックを誤解",
                       explanation: "同一トランザクションに参加している場合、呼び出し先のロールバックは呼び出し元のトランザクション全体をロールバック対象にします。")
            ],
            explanationRef: "explain-boot3-tx-prop-001",
            designIntent: "デフォルト伝播属性REQUIREDを理解する。"
        ),
        quiz(
            id: "boot3-tx-prop-002",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["REQUIRES_NEW", "新規トランザクション", "独立コミット"],
            code: """
@Service
public class AuditService {

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void log(String action, Long userId) {
        auditRepo.save(new AuditLog(action, userId));
        // このログは呼び出し元がロールバックしても保存される
    }
}

@Service
public class OrderService {

    @Transactional
    public void placeOrder(OrderDto dto) {
        // 注文処理（失敗してもログは残る）
        auditService.log("ORDER_PLACE", dto.getUserId());
        processOrder(dto);  // ← これが例外を投げる
    }
}
""",
            question: "`REQUIRES_NEW` を `AuditService.log()` に使う理由として正しいのはどれか？",
            choices: [
                choice("a", "注文処理がロールバックされても、監査ログの書き込みは別トランザクションで独立してコミットされるため", correct: true,
                       explanation: "REQUIRES_NEWは呼び出し元トランザクションを一時停止して新規トランザクションを開始します。監査ログのような「処理結果に関わらず記録が必要なもの」に使います。"),
                choice("b", "REQUIRES_NEWを使うとデータの書き込みが2倍速くなる", misconception: "存在しないパフォーマンス改善",
                       explanation: "REQUIRES_NEWは独立したコミットが目的です。パフォーマンスの改善は主な目的ではありません。"),
                choice("c", "REQUIRES_NEWは内部呼び出し（this.method()）でのみ有効", misconception: "REQUIRES_NEWと内部呼び出しを関連付けて誤解",
                       explanation: "REQUIRES_NEWはプロキシ経由の外部呼び出しで機能します。内部呼び出しでは@Transactional自体が効きません。"),
                choice("d", "REQUIRES_NEWを使うと2つのトランザクションが並列実行され処理が高速化される", misconception: "REQUIRES_NEWが並列化と誤解",
                       explanation: "REQUIRES_NEWは順次処理です。呼び出し元を停止し、新規トランザクションを実行後、元に戻ります。並列ではありません。")
            ],
            explanationRef: "explain-boot3-tx-prop-002",
            designIntent: "REQUIRES_NEWの独立コミットの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-tx-prop-003",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["NESTED", "セーブポイント", "部分ロールバック"],
            code: """
@Transactional(propagation = Propagation.NESTED)
public void importItem(ItemDto item) {
    try {
        processItem(item);
    } catch (Exception e) {
        // ネストされたトランザクションのみロールバック
        // 呼び出し元のトランザクションは継続
    }
}
""",
            question: "`NESTED` 伝播の動作として正しいのはどれか？",
            choices: [
                choice("a", "セーブポイントを作成し、ネストされた部分のみを部分的にロールバックでき、呼び出し元のトランザクションは継続できる", correct: true,
                       explanation: "NESTEDはJDBCのセーブポイントを使います。内側でエラーが起きても呼び出し元がcatch処理すれば全体のロールバックを避けられます。REQUIRES_NEWと異なり同一接続を使います。"),
                choice("b", "NESTEDはREQUIRES_NEWと全く同じ動作をする", misconception: "NESTEDとREQUIRES_NEWを同一視",
                       explanation: "REQUIRES_NEWは物理的に別トランザクション。NESTEDは同一トランザクション内のセーブポイントです。呼び出し元の変更の見え方が異なります。"),
                choice("c", "NESTEDを使うと内側のロールバックが常に外側全体のロールバックを引き起こす", misconception: "NESTEDがREQUIREDと同じロールバック動作と誤解",
                       explanation: "NESTEDの目的は内側のみのロールバック（セーブポイントへの巻き戻し）です。呼び出し元がcatchすれば外側は継続できます。"),
                choice("d", "NESTEDはMySQLでのみ使用できる", misconception: "特定DBに限定されると誤解",
                       explanation: "NESTEDはJDBCのセーブポイントをサポートするDB（MySQL, PostgreSQL等）で使用できます。DB依存ですがMySQLのみではありません。")
            ],
            explanationRef: "explain-boot3-tx-prop-003",
            designIntent: "NESTEDのセーブポイントによる部分ロールバックを理解する。"
        ),
        quiz(
            id: "boot3-tx-prop-004",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["MANDATORY", "NEVER", "SUPPORTS", "NOT_SUPPORTED"],
            code: """
// 様々な伝播設定の例
@Transactional(propagation = Propagation.MANDATORY)
public void mustHaveTransaction() { ... }  // トランザクションなしで呼ぶと例外

@Transactional(propagation = Propagation.NEVER)
public void noTransactionAllowed() { ... }  // トランザクション内で呼ぶと例外

@Transactional(propagation = Propagation.SUPPORTS)
public void optionalTransaction() { ... }  // あれば参加、なくても実行

@Transactional(propagation = Propagation.NOT_SUPPORTED)
public void suspendIfExists() { ... }  // 既存トランザクションを停止
""",
            question: "`Propagation.MANDATORY` を使う場面として最も適切なのはどれか？",
            choices: [
                choice("a", "必ず呼び出し元のトランザクション内から呼ばれることを強制したいメソッドに使う", correct: true,
                       explanation: "MANDATORYはトランザクションなしで呼ばれると `IllegalTransactionStateException` をスローします。「このメソッドはトランザクション内からのみ呼ぶべき」という設計上の制約を実行時に強制できます。"),
                choice("b", "MANDATORYは新しいトランザクションを開始するためREQUIRES_NEWと同等", misconception: "MANDATORYが新規トランザクションを開始すると誤解",
                       explanation: "MANDATORYは新規トランザクションを開始しません。既存トランザクションへの参加を強制します。"),
                choice("c", "NEVERはトランザクション不要なメソッドを高速化するための最適化設定", misconception: "NEVERをパフォーマンス設定と誤解",
                       explanation: "NEVERはトランザクション内から呼ばれると例外をスローします。意図的に「トランザクション外でのみ実行」を強制する設計上の制約です。"),
                choice("d", "SUPPORTSはREQUIREDと全く同じ動作をする", misconception: "SUPPORTSとREQUIREDを同一視",
                       explanation: "REQUIREDは「なければ新規作成」。SUPPORTSは「なければトランザクションなしで実行」。トランザクション未参照の場合の動作が異なります。")
            ],
            explanationRef: "explain-boot3-tx-prop-004",
            designIntent: "各種伝播属性の使い分けを理解する。"
        ),
        quiz(
            id: "boot3-tx-prop-005",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@TransactionalEventListener", "afterCommit", "ドメインイベント"],
            code: """
@Component
public class UserEventHandler {

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onUserCreated(UserCreatedEvent event) {
        emailService.sendWelcome(event.getEmail());
    }
}

@Service
public class UserService {
    @Transactional
    public void createUser(String email) {
        userRepo.save(new User(email));
        eventPublisher.publishEvent(new UserCreatedEvent(email));
    }
}
""",
            question: "`@TransactionalEventListener(phase = AFTER_COMMIT)` の動作として正しいのはどれか？",
            choices: [
                choice("a", "イベントはトランザクションのコミット完了後にハンドラが呼ばれ、ロールバックした場合はハンドラが実行されない", correct: true,
                       explanation: "AFTER_COMMITはコミット成功後のみハンドラを実行します。通常の@EventListenerはトランザクション内で即座に実行されます。ロールバック時のメール誤送信を防ぐ設計です。"),
                choice("b", "@TransactionalEventListenerのハンドラ内の操作は元のトランザクションに含まれる", misconception: "ハンドラがコミット済みトランザクションに参加すると誤解",
                       explanation: "AFTER_COMMITはコミット後の実行です。ハンドラ内でDBを更新する場合は新規トランザクションが必要です。"),
                choice("c", "@TransactionalEventListenerは@Asyncと同じで必ず別スレッドで実行される", misconception: "AFTER_COMMITが非同期と誤解",
                       explanation: "デフォルトでは同スレッド・同期実行です。非同期にするには@Asyncを別途付けます。"),
                choice("d", "@TransactionalEventListenerはSpring Boot 3.xでは削除された", misconception: "廃止されたという誤情報",
                       explanation: "@TransactionalEventListenerはSpring Boot 3.xでも使用可能です。ドメインイベントパターンに有用です。")
            ],
            explanationRef: "explain-boot3-tx-prop-005",
            designIntent: "@TransactionalEventListenerの動作を理解する。"
        ),
        quiz(
            id: "boot3-tx-prop-006",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["分散トランザクション", "Saga", "2PC"],
            code: """
// マイクロサービス間のSagaパターン（概念）
// OrderService → [注文作成] → PaymentService → [決済] → InventoryService → [在庫減算]
// 失敗した場合は補償トランザクション（取り消し処理）を逆順で実行
""",
            question: "マイクロサービス間の分散トランザクションの解決策として最も一般的なのはどれか？",
            choices: [
                choice("a", "Sagaパターン：各サービスがローカルトランザクションをコミットし、失敗時に補償トランザクションで巻き戻す", correct: true,
                       explanation: "2PC（2フェーズコミット）はマイクロサービスでは実装困難・デッドロックリスクがあります。Sagaパターンはローカルトランザクションとイベントまたはオーケストレーションで整合性を保ちます。"),
                choice("b", "@Transactionalをマイクロサービス間で共有するだけで分散トランザクションが自動解決される", misconception: "@Transactionalが分散対応と誤解",
                       explanation: "Spring の@TransactionalはJVM内のローカルトランザクションです。マイクロサービス間の分散トランザクションは別の仕組みが必要です。"),
                choice("c", "Spring BootはデフォルトでXAプロトコル（2PC）をサポートしているため追加設定不要", misconception: "Spring BootがXAを標準サポートと誤解",
                       explanation: "Spring BootはXA/JTA対応のアダプタ（Atomikos等）を使う場合はサポートしますが、デフォルトではXAを設定していません。また、マイクロサービスでの2PCは一般的に非推奨です。"),
                choice("d", "分散トランザクションはSpring Cloudを使えば完全に解決できる", misconception: "Spring Cloudが分散トランザクションを解決すると誤解",
                       explanation: "Spring Cloudはサービス検索・設定管理等の機能を提供しますが、分散トランザクションの自動解決は行いません。Sagaパターン等の設計が必要です。")
            ],
            explanationRef: "explain-boot3-tx-prop-006",
            designIntent: "分散トランザクションの現実的な解決策を理解する。"
        ),
    ]

    // MARK: - Group 3: 分離レベル (6問)
    private static let txIsolation: [Quiz] = [
        quiz(
            id: "boot3-tx-iso-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["Dirty Read", "READ_COMMITTED", "分離レベル"],
            code: """
@Transactional(isolation = Isolation.READ_COMMITTED)  // デフォルト（多くのDB）
public void process() {
    // コミット済みのデータのみ読める
    // Dirty Readは発生しない
    // Non-Repeatable Read / Phantom Readは発生する可能性あり
}
""",
            question: "Dirty Read（ダーティリード）の説明として正しいのはどれか？",
            choices: [
                choice("a", "まだコミットされていない別トランザクションの変更データを読み取ること", correct: true,
                       explanation: "Dirty Readはコミット前のデータを読むため、その後ロールバックされると存在しないデータを読んだことになります。READ_COMMITTED以上の分離レベルで防ぎます。"),
                choice("b", "同一トランザクション内で同じクエリを2回発行したとき異なる結果が返ること", misconception: "Dirty ReadとNon-Repeatable Readを混同",
                       explanation: "同一トランザクション内での読み取り不整合はNon-Repeatable Readです。Dirty Readは他トランザクションの未コミットデータの問題です。"),
                choice("c", "トランザクション開始後に他トランザクションによる新規INSERTが見えること", misconception: "Dirty ReadとPhantom Readを混同",
                       explanation: "新規INSERTが見える問題はPhantom Readです。Dirty Readは未コミットの変更（UPDATE/DELETE含む）の読み取りです。"),
                choice("d", "ダーティリードはSpring Boot 3.xで全て自動防止される", misconception: "Spring Bootが全て防ぐと誤解",
                       explanation: "ダーティリードはDBの分離レベル設定で防ぎます。Spring Bootが自動で防ぐ仕組みはありません。")
            ],
            explanationRef: "explain-boot3-tx-iso-001",
            designIntent: "Dirty Readの定義と分離レベルの関係を理解する。"
        ),
        quiz(
            id: "boot3-tx-iso-002",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["REPEATABLE_READ", "Non-Repeatable Read", "分離レベル"],
            code: """
@Transactional(isolation = Isolation.REPEATABLE_READ)
public void checkInventory() {
    int stock = inventoryRepo.findStock(productId);  // (A) 100

    // 他トランザクションがここで在庫を変更してもREPEATABLE_READでは見えない

    int stockAgain = inventoryRepo.findStock(productId);  // (B) 必ず100
    if (stock != stockAgain) {
        // REPEATABLE_READでは発生しない
    }
}
""",
            question: "`REPEATABLE_READ` が防ぐ問題として正しいのはどれか？",
            choices: [
                choice("a", "Non-Repeatable Read：同一トランザクション内で同じ行を再読み取りすると異なる値が返る問題", correct: true,
                       explanation: "REPEATABLE_READは（A）と（B）が同じ値を返すことを保証します。他トランザクションの更新は見えません。ただしPhantom Readは発生する可能性があります（DBによる）。"),
                choice("b", "Phantom Read：同一トランザクション内で同じ範囲クエリを発行すると異なる行数が返る問題", misconception: "REPEATABLE_READがPhantom Readも完全防止と誤解",
                       explanation: "REPEATABLE_READはNon-Repeatable Readを防ぎますが、Phantom Readを必ず防ぐかはDB実装依存です（MySQLのInnoDBは防ぐ、PostgreSQLは防がない）。"),
                choice("c", "Dirty Read：コミット前のデータを読む問題", misconception: "REPEATABLE_READとDirty Readの関係を誤解",
                       explanation: "Dirty ReadはREAD_COMMITTED以上の分離レベルで防ぎます。REPEATABLE_READはNon-Repeatable Readへの追加保護です。"),
                choice("d", "REPEATABLE_READはすべての並行問題を解決する最強の分離レベル", misconception: "REPEATABLE_READが全問題を解決すると誤解",
                       explanation: "全問題を解決するのはSERIALIZABLEです。REPEATABLE_READはNon-Repeatable Readを防ぐが、Phantom Readは（実装依存で）発生し得ます。")
            ],
            explanationRef: "explain-boot3-tx-iso-002",
            designIntent: "分離レベルREPEATABLE_READが防ぐ問題を理解する。"
        ),
        quiz(
            id: "boot3-tx-iso-003",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["Phantom Read", "SERIALIZABLE", "範囲クエリ"],
            code: """
@Transactional(isolation = Isolation.SERIALIZABLE)
public long countAndInsertIfZero() {
    long count = repo.countByStatus("PENDING");  // (A) 0件

    // 他トランザクションがここでPENDINGを挿入してもSERIALIZABLEでは見えない

    if (count == 0) {
        repo.save(new Order("PENDING"));  // 安全に挿入
    }
    return count;
}
""",
            question: "Phantom Read（ファントムリード）の説明として正しいのはどれか？",
            choices: [
                choice("a", "同一トランザクション内で同じ範囲クエリを2回実行したとき、他トランザクションのINSERTにより結果行数が変わること", correct: true,
                       explanation: "Phantom Readは行の追加・削除による「幻の行」の問題です。SERIALIZABLE分離レベルで防げます。"),
                choice("b", "Phantom Readは行の値が変わる問題でNon-Repeatable Readと同じ", misconception: "Phantom ReadとNon-Repeatable Readを混同",
                       explanation: "Non-Repeatable Readは「同じ行の値が変わる」問題。Phantom Readは「行数が変わる（新規行の出現・消滅）」問題です。"),
                choice("c", "SERIALIZABLEは全ての問題を防ぐが、デッドロックが多発するためSpring Boot標準で無効化される", misconception: "Spring BootがSERIALIZABLEを無効化と誤解",
                       explanation: "Spring Bootは分離レベルの設定を変更しません。デフォルトはDB依存です。SERIALIZABLEはスループットが低下するため本番での使用は慎重に判断します。"),
                choice("d", "SERIALIZABLEを使えばデッドロックは発生しない", misconception: "SERIALIZABLE = デッドロックなしと誤解",
                       explanation: "SERIALIZABLEはむしろデッドロックが発生しやすい分離レベルです。より多くのロックを取得するためです。")
            ],
            explanationRef: "explain-boot3-tx-iso-003",
            designIntent: "Phantom Readの定義とSERIALIZABLEを理解する。"
        ),
        quiz(
            id: "boot3-tx-iso-004",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["デッドロック", "ロック順序", "タイムアウト"],
            code: """
// トランザクションA: Account 1 → Account 2 の順でロック
// トランザクションB: Account 2 → Account 1 の順でロック（逆順）

// → 互いが相手のロック解放を待ち、デッドロック発生
""",
            question: "デッドロックを防ぐ最も基本的な戦略として正しいのはどれか？",
            choices: [
                choice("a", "全トランザクションで同じ順序でリソースをロックする（ロック順序の統一）", correct: true,
                       explanation: "デッドロックは循環的なロック待ちで発生します。全トランザクションが同一の順序でリソースをロックすれば、循環待ちが起きないためデッドロックを防げます。"),
                choice("b", "@Transactional(timeout)を設定するだけでデッドロックは発生しなくなる", misconception: "タイムアウトがデッドロック防止になると誤解",
                       explanation: "タイムアウトはデッドロック時の検出・回復手段です。デッドロックの発生そのものを防ぐわけではありません。"),
                choice("c", "楽観ロックを使えばデッドロックは100%発生しない", misconception: "楽観ロックがデッドロックを完全防止すると誤解",
                       explanation: "楽観ロックはDBロックを取らないためデッドロックリスクは下がりますが、悲観ロックが必要なシナリオや複数操作が絡む場合は依然リスクがあります。"),
                choice("d", "SERIALIZABLE分離レベルを使えばデッドロックは発生しない", misconception: "SERIALIZABLEがデッドロックを防ぐと誤解",
                       explanation: "SERIALIZABLEはむしろより多くのロックを取得するためデッドロックリスクが上がります。")
            ],
            explanationRef: "explain-boot3-tx-iso-004",
            designIntent: "デッドロックの発生原因と防止策を理解する。"
        ),
        quiz(
            id: "boot3-tx-iso-005",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Transactional timeout", "タイムアウト", "LockTimeoutException"],
            code: """
@Transactional(timeout = 5)  // 5秒でタイムアウト
public void longOperation() {
    // 時間のかかる処理
    for (var item : largeDataset) {
        processItem(item);
    }
}
""",
            question: "`@Transactional(timeout = 5)` の動作として正しいのはどれか？",
            choices: [
                choice("a", "5秒を超えてトランザクションが継続すると `TransactionTimedOutException` がスローされ、ロールバックされる", correct: true,
                       explanation: "タイムアウトを設定するとJDBC/DBレベルでタイムアウトが設定されます。超過すると例外が発生してトランザクションはロールバックします。"),
                choice("b", "5秒を超えると自動でコミットされてトランザクションが正常終了する", misconception: "タイムアウト後に自動コミットされると誤解",
                       explanation: "タイムアウトは正常終了ではなく例外・ロールバックです。自動コミットはされません。"),
                choice("c", "タイムアウトはトランザクション全体ではなく1つのSQL実行に対する制限", misconception: "タイムアウトがSQL単位と誤解",
                       explanation: "Spring の `timeout` はトランザクション全体の時間制限です。SQL単体のタイムアウトはQueryTimeout等で別途設定します。"),
                choice("d", "`timeout` 設定は `readOnly = true` の場合のみ有効", misconception: "readOnlyとtimeoutに依存関係があると誤解",
                       explanation: "`timeout` はreadOnly/readWriteに関係なく動作します。")
            ],
            explanationRef: "explain-boot3-tx-iso-005",
            designIntent: "トランザクションタイムアウトの動作を理解する。"
        ),
        quiz(
            id: "boot3-tx-iso-006",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["PlatformTransactionManager", "JTA", "トランザクションマネージャ"],
            code: """
// Spring Bootが自動設定するトランザクションマネージャ
// JPA + 単一DB: JpaTransactionManager
// 複数DB / JMS: JtaTransactionManager (XA)
""",
            question: "Spring Bootが `JpaTransactionManager` を自動設定する条件として正しいのはどれか？",
            choices: [
                choice("a", "単一のEntityManagerFactoryとデータソースがある場合に自動設定される", correct: true,
                       explanation: "Spring Bootの自動設定は単一JPAデータソース環境で `JpaTransactionManager` をBeanとして登録します。複数データソースや分散トランザクションには別途設定が必要です。"),
                choice("b", "@EnableTransactionManagement をMainクラスに付けなければトランザクションマネージャは自動設定されない", misconception: "@EnableTransactionManagementが必須と誤解",
                       explanation: "Spring Boot の自動設定は `@EnableTransactionManagement` なしでトランザクション管理を有効化します。Spring Bootなしの場合は必要です。"),
                choice("c", "JpaTransactionManagerとJtaTransactionManagerは同時に使用不可", misconception: "混在不可と誤解",
                       explanation: "一般的には1アプリで1つのトランザクションマネージャを使います。ただし設定次第で複数の使い分けは可能です。"),
                choice("d", "JpaTransactionManagerはSpring Boot 3.xで廃止されDataSourceTransactionManagerに統合された", misconception: "廃止されたという誤情報",
                       explanation: "JpaTransactionManagerはSpring Boot 3.xでも使用可能な現役コンポーネントです。")
            ],
            explanationRef: "explain-boot3-tx-iso-006",
            designIntent: "JpaTransactionManagerの自動設定を理解する。"
        ),
    ]

    // MARK: - Group 4: ロールバック制御 (6問)
    private static let txRollback: [Quiz] = [
        quiz(
            id: "boot3-tx-rollback-001",
            level: .foundation,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["RuntimeException", "ロールバック", "検査例外"],
            code: """
@Transactional
public void process() throws IOException {
    repo.save(entity);
    // IOExceptionが発生した場合...
    riskyOperation();  // throws IOException
}
""",
            question: "`IOException` が発生した場合、デフォルトでトランザクションはどうなるか？",
            choices: [
                choice("a", "デフォルトではコミットされる（IOExceptionは検査例外でロールバック対象外）", correct: true,
                       explanation: "Springのデフォルトロールバックルールは `RuntimeException` と `Error` のみです。`IOException` は検査例外（Checked Exception）のためデフォルトではコミットされます。"),
                choice("b", "全ての例外でロールバックされる", misconception: "全例外がロールバック対象と誤解",
                       explanation: "デフォルトはRuntimeException/Error のみがロールバック対象です。検査例外は対象外です。"),
                choice("c", "検査例外はSpringが自動でRuntimeExceptionに変換されロールバックされる", misconception: "検査例外が自動変換されると誤解",
                       explanation: "Springは検査例外を自動変換しません。ロールバック対象にするには`rollbackFor = IOException.class`が必要です。"),
                choice("d", "catchしなかった例外のみロールバックされ、catchした場合はコミットされる", misconception: "catch有無でロールバックが変わると誤解",
                       explanation: "ロールバック判定はメソッドの外に例外が伝播した時点で行われます。メソッド内でcatchすれば例外はSpringに届かないためロールバックは発生しません。")
            ],
            explanationRef: "explain-boot3-tx-rollback-001",
            designIntent: "デフォルトのロールバックルール（検査例外の扱い）を理解する。"
        ),
        quiz(
            id: "boot3-tx-rollback-002",
            level: .foundation,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["rollbackFor", "noRollbackFor", "ロールバック制御"],
            code: """
@Transactional(rollbackFor = {IOException.class, CustomBusinessException.class})
public void importData() throws IOException {
    // 検査例外もロールバック対象に追加
}

@Transactional(noRollbackFor = InventoryWarningException.class)
public void processOrder() {
    // 在庫警告例外は業務ログのみでコミットを継続したい
}
""",
            question: "`noRollbackFor = InventoryWarningException.class` を使う適切な場面として正しいのはどれか？",
            choices: [
                choice("a", "例外が発生してもそれが業務上の「警告」であり、本体の処理はコミットしたいケース", correct: true,
                       explanation: "noRollbackForは特定のRuntimeExceptionが発生してもロールバックしないよう指定できます。業務警告のような「例外だが処理継続」するケースに使います。"),
                choice("b", "`noRollbackFor` を指定するとプログラムが例外を無視して処理を続ける", misconception: "noRollbackForが例外をキャッチすると誤解",
                       explanation: "noRollbackForはロールバック判定の設定です。例外自体は依然としてスローされます。呼び出し元でcatchが必要です。"),
                choice("c", "`noRollbackFor` はSpring Boot 3.x以降では使えない新しい機能", misconception: "バージョン依存への誤解",
                       explanation: "noRollbackForはSpringの古くからある機能です。Spring Boot 3.xでも使用可能です。"),
                choice("d", "`noRollbackFor` はRuntimeExceptionにのみ適用でき、検査例外には使えない", misconception: "noRollbackForの適用範囲を誤解",
                       explanation: "noRollbackForは検査例外にも使用できます。ただし検査例外はデフォルトでロールバック対象外のため、実用的に使うケースは少ないです。")
            ],
            explanationRef: "explain-boot3-tx-rollback-002",
            designIntent: "rollbackFor/noRollbackForの使い分けを理解する。"
        ),
        quiz(
            id: "boot3-tx-rollback-003",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["TransactionStatus", "setRollbackOnly", "手動ロールバック"],
            code: """
@Transactional
public void processWithManualRollback(List<Item> items) {
    for (var item : items) {
        if (!validate(item)) {
            TransactionAspectSupport.currentTransactionStatus()
                .setRollbackOnly();  // ロールバックをマーク
            return;
        }
        repo.save(item);
    }
}
""",
            question: "`setRollbackOnly()` を使う理由として正しいのはどれか？",
            choices: [
                choice("a", "例外をスローせずに「このトランザクションはロールバックすべき」とマークし、メソッド終了時にロールバックさせるため", correct: true,
                       explanation: "setRollbackOnly()は例外を使わずにロールバックを指示できます。例外を外に出せないコンテキスト（ループ内等）でロールバックフラグを設定するときに使います。"),
                choice("b", "setRollbackOnly()はトランザクションを即座にロールバックして処理を中断する", misconception: "即座にロールバックが発生すると誤解",
                       explanation: "setRollbackOnly()はフラグをセットするだけです。実際のロールバックはトランザクション終了時（メソッドの戻り後）に発生します。"),
                choice("c", "setRollbackOnly()後は全てのDB操作が無視される", misconception: "フラグ後のDB操作が無効化されると誤解",
                       explanation: "フラグ設定後もSQL自体は発行されますが、トランザクション終了時にコミットされずロールバックされます。"),
                choice("d", "setRollbackOnly()を使うとトランザクション伝播が変わる", misconception: "伝播への影響を誤解",
                       explanation: "setRollbackOnly()はロールバックフラグの設定のみです。伝播属性には影響しません。")
            ],
            explanationRef: "explain-boot3-tx-rollback-003",
            designIntent: "手動ロールバックマークの使い方を理解する。"
        ),
        quiz(
            id: "boot3-tx-rollback-004",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["UnexpectedRollbackException", "参加トランザクション", "REQUIRES_NEW"],
            code: """
@Transactional
public void outer() {
    try {
        inner();  // REQUIRED: 同一トランザクション参加
    } catch (RuntimeException e) {
        // キャッチしてもUnexpectedRollbackExceptionが発生する可能性あり
    }
    // ここで何らかの処理を続けようとしても...
}

@Transactional  // REQUIRED: 同一トランザクション参加
public void inner() {
    throw new RuntimeException("失敗");
}
""",
            question: "`inner()` でRuntimeExceptionが発生し、`outer()` でcatchした場合に起きる問題として正しいのはどれか？",
            choices: [
                choice("a", "`inner()` でロールバックマークがセットされるため、`outer()` がコミットしようとすると `UnexpectedRollbackException` が発生する", correct: true,
                       explanation: "REQUIREDは同一トランザクションに参加します。inner()で例外→ロールバックマークがセットされ、outer()がcatchしてもトランザクションはロールバック専用状態になります。コミット時にUnexpectedRollbackExceptionが発生します。"),
                choice("b", "outer()でcatchしたため `inner()` のロールバックマークがクリアされ正常にコミットできる", misconception: "catchがロールバックマークをクリアすると誤解",
                       explanation: "catchはロールバックマークをクリアしません。トランザクションは依然ロールバック専用状態です。"),
                choice("c", "`inner()` がREQUIREDのため別トランザクションで動作し、`outer()` には影響しない", misconception: "REQUIREDが独立トランザクションと誤解",
                       explanation: "REQUIREDは既存トランザクションに「参加」します。REQUIRES_NEWを使うと独立したトランザクションになります。"),
                choice("d", "このシナリオではロールバックは発生せず、全ての変更がコミットされる", misconception: "catchで全て正常になると誤解",
                       explanation: "RuntimeExceptionによるロールバックマークはcatchで取り消せません。UnexpectedRollbackExceptionが発生します。")
            ],
            explanationRef: "explain-boot3-tx-rollback-004",
            designIntent: "UnexpectedRollbackExceptionの発生原因を理解する。"
        ),
        quiz(
            id: "boot3-tx-rollback-005",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["バッチ処理", "個別コミット", "REQUIRES_NEW"],
            code: """
@Service
public class BatchService {

    @Autowired
    private ItemProcessor itemProcessor;

    @Transactional
    public BatchResult processAll(List<Item> items) {
        var result = new BatchResult();
        for (var item : items) {
            try {
                itemProcessor.processOne(item);  // REQUIRES_NEW
                result.addSuccess();
            } catch (Exception e) {
                result.addFailed(item.getId());  // 失敗を記録して次へ
            }
        }
        return result;
    }
}

@Service
public class ItemProcessor {
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void processOne(Item item) { ... }
}
""",
            question: "バッチ処理で各アイテムを `REQUIRES_NEW` で個別処理する利点として正しいのはどれか？",
            choices: [
                choice("a", "1件の処理が失敗しても他の件はロールバックされず、成功件数を最大化できる", correct: true,
                       explanation: "REQUIRES_NEWにより各アイテムは独立したトランザクションで処理されます。1件の失敗が他の件に影響しないため、できるだけ多くのデータを処理するバッチに適しています。"),
                choice("b", "REQUIRES_NEWを使うとバッチ全体が1回のSQL発行でDB処理される", misconception: "REQUIRES_NEWがバッチSQLを最適化すると誤解",
                       explanation: "REQUIRES_NEWはトランザクション分離です。SQL発行回数は変わりません。"),
                choice("c", "REQUIRES_NEWを使うと全アイテムが並列処理されて速度が上がる", misconception: "REQUIRES_NEWが並列化を行うと誤解",
                       explanation: "REQUIRES_NEWは順次処理です。並列化には@Asyncやスレッドプールが別途必要です。"),
                choice("d", "このパターンはself-invocationになるためREQUIRES_NEWが機能しない", misconception: "外部Beanへの呼び出しがself-invocationと誤解",
                       explanation: "`ItemProcessor` は別のBeanのため、Springプロキシ経由の外部呼び出しになります。REQUIRES_NEWは正常に機能します。")
            ],
            explanationRef: "explain-boot3-tx-rollback-005",
            designIntent: "バッチ処理でのREQUIRES_NEWパターンを理解する。"
        ),
        quiz(
            id: "boot3-tx-rollback-006",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Retryable", "楽観ロック", "リトライ"],
            code: """
@Retryable(
    value = OptimisticLockingFailureException.class,
    maxAttempts = 3,
    backoff = @Backoff(delay = 100, multiplier = 2)
)
@Transactional
public void updateWithRetry(Long id, int newValue) {
    Entity e = repo.findById(id).orElseThrow();
    e.setValue(newValue);
    repo.save(e);
}
""",
            question: "楽観ロック（`@Version`）と `@Retryable` を組み合わせる理由として正しいのはどれか？",
            choices: [
                choice("a", "楽観ロック失敗（OptimisticLockingFailureException）はリトライで解消できることが多く、自動再試行で成功率を上げるため", correct: true,
                       explanation: "楽観ロックは競合検出後にリトライが前提の設計です。@Retryableで自動リトライすることで、競合が少ない場合でも手動リトライコードを書かずに対応できます。"),
                choice("b", "@Retryableを使うとOptimisticLockingFailureExceptionが発生しなくなる", misconception: "リトライが例外を防ぐと誤解",
                       explanation: "@Retryableは例外発生後の再試行を自動化します。例外の発生を防ぐものではありません。"),
                choice("c", "@RetryableはSpring Bootの標準機能でimportなしで使える", misconception: "標準機能と誤解",
                       explanation: "@RetryableはSpring Retryライブラリ（`spring-retry`）に含まれます。`spring-boot-starter`には含まれないため別途依存を追加します。"),
                choice("d", "@Retryableのリトライ中は同一トランザクションが継続する", misconception: "リトライが同一トランザクションを継続すると誤解",
                       explanation: "各リトライは新しいトランザクションで実行されます。楽観ロックのバージョン更新を再度読み取るためです。")
            ],
            explanationRef: "explain-boot3-tx-rollback-006",
            designIntent: "楽観ロックのリトライパターンを理解する。"
        ),
    ]

    // MARK: - Group 5: 高度なトピック (6問)
    private static let txAdvanced: [Quiz] = [
        quiz(
            id: "boot3-tx-adv-001",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["バルク操作", "JPQL", "@Modifying", "パフォーマンス"],
            code: """
// 非効率: N件のINSERT
items.forEach(item -> repo.save(new Item(item)));

// 効率的: バルクINSERT (JPQL)
@Modifying
@Transactional
@Query("INSERT INTO item (name, price) SELECT d.name, d.price FROM draft_item d WHERE d.approved = true")
int bulkInsertApproved();
""",
            question: "バルク操作で `@Modifying` を使う場合に注意すべきことして正しいのはどれか？",
            choices: [
                choice("a", "バルク操作はPersistence Contextをバイパスするため、操作後のエンティティ状態がキャッシュと不整合になる可能性がある", correct: true,
                       explanation: "JPQLのバルク操作はHibernateのL1キャッシュを更新しません。`@Modifying(clearAutomatically = true)` でキャッシュをクリアするか、操作後に`em.clear()`を呼ぶ必要があります。"),
                choice("b", "@Modifyingを使うとRollbackが無効になる", misconception: "@ModifyingとRollbackの関係を誤解",
                       explanation: "@Modifyingはロールバックに影響しません。バルク操作も@Transactionalのロールバックルールに従います。"),
                choice("c", "バルクINSERTは単一トランザクション内でしか実行できない", misconception: "バルク操作の使用場所を誤解",
                       explanation: "バルク操作はトランザクション内で実行することが推奨されますが、技術的に単一トランザクション限定ではありません。"),
                choice("d", "`@Modifying(clearAutomatically = true)` を付けるとPersistence Context全体が削除されアプリが再起動する", misconception: "clearAutomaticallyの意味を過剰に解釈",
                       explanation: "`clearAutomatically = true` はJPAのPersistence Contextのキャッシュ（L1キャッシュ）をクリアするだけです。アプリの再起動は発生しません。")
            ],
            explanationRef: "explain-boot3-tx-adv-001",
            designIntent: "バルク操作とPersistence Contextの関係を理解する。"
        ),
        quiz(
            id: "boot3-tx-adv-002",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["@Async", "@Transactional", "非同期処理"],
            code: """
@Service
public class AsyncOrderService {

    @Async
    @Transactional
    public CompletableFuture<Void> processAsync(OrderDto dto) {
        // 別スレッドでトランザクション内処理
        orderRepo.save(convertToOrder(dto));
        return CompletableFuture.completedFuture(null);
    }
}
""",
            question: "`@Async` と `@Transactional` を組み合わせた場合の注意点として正しいのはどれか？",
            choices: [
                choice("a", "非同期メソッドは呼び出し元とは別スレッドで実行されるため、呼び出し元のトランザクションには参加できない", correct: true,
                       explanation: "@AsyncはSpringが別スレッドでメソッドを実行します。トランザクションはスレッドローカルに紐付いているため、呼び出し元のトランザクションには参加しません。新しいトランザクションが開始されます。"),
                choice("b", "@AsyncメソッドはすべてREQUIRES_NEWとして動作する", misconception: "@Asyncが自動的にREQUIRES_NEWを使うと誤解",
                       explanation: "@Asyncと@Transactionalを組み合わせると、Propagation.REQUIREDでも新規トランザクションになります（呼び出し元とは別スレッドのため）。"),
                choice("c", "@AsyncメソッドにCompletableFutureを使うとトランザクションのロールバックができなくなる", misconception: "CompletableFutureがロールバックを防ぐと誤解",
                       explanation: "@Transactionalのロールバック動作はCompletableFutureの使用に関わらず機能します。"),
                choice("d", "@Asyncを使うとDBへの書き込みがキューイングされ後で一括コミットされる", misconception: "@AsyncがDBキューイングと関連すると誤解",
                       explanation: "@Asyncはメソッドの実行スレッドを変えるだけです。DBへの書き込みは@Transactionalのルールに従い、メソッド終了時にコミットされます。")
            ],
            explanationRef: "explain-boot3-tx-adv-002",
            designIntent: "@Asyncと@Transactionalの組み合わせ時の注意点を理解する。"
        ),
        quiz(
            id: "boot3-tx-adv-003",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["Outboxパターン", "分散一貫性", "イベント送達保証"],
            code: """
// Outboxパターンの概念
// 1. DBへのビジネスデータ保存 ＋ Outboxテーブルへのイベント記録
//    → 同一トランザクション（原子性保証）
// 2. 別プロセスがOutboxを監視してメッセージブローカーへ送信
//    → At-least-once配信
""",
            question: "Outboxパターンが解決する問題として正しいのはどれか？",
            choices: [
                choice("a", "DBへの書き込みとメッセージブローカーへの送信を同一トランザクション内で原子的に保証できない問題", correct: true,
                       explanation: "DBとメッセージブローカーへの二重書き込みは分散トランザクション（XA）なしには原子性を保証できません。Outboxパターンは「DBへの書き込み+Outboxへのイベント記録」を同一トランザクションにまとめることで解決します。"),
                choice("b", "Outboxパターンを使うと全てのメッセージがexactly-once配信される", misconception: "Outboxパターンがexactly-once保証すると誤解",
                       explanation: "Outboxパターンはat-least-once配信です。重複排除（冪等性）は受信側での対処が必要です。"),
                choice("c", "OutboxパターンはSpring Boot標準の@EventListenerを使えば自動で実現される", misconception: "@EventListenerがOutboxを自動実現すると誤解",
                       explanation: "@EventListenerはアプリ内イベントです。外部メッセージブローカーへの確実な配信にはOutboxのような追加設計が必要です。"),
                choice("d", "OutboxパターンはSpring Boot 3.x専用の新しいアーキテクチャパターン", misconception: "Spring Boot専用の新機能と誤解",
                       explanation: "Outboxパターンはフレームワーク非依存のアーキテクチャパターンです。Spring Boot以外でも使われます。")
            ],
            explanationRef: "explain-boot3-tx-adv-003",
            designIntent: "Outboxパターンが解決する分散システムの問題を理解する。"
        ),
        quiz(
            id: "boot3-tx-adv-004",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["Spring Batch", "JobRepository", "ステップトランザクション"],
            code: """
@Bean
public Step importStep(JobRepository jobRepository,
                       PlatformTransactionManager txManager) {
    return new StepBuilder("importStep", jobRepository)
        .<InputDto, Entity>chunk(100, txManager)
        .reader(reader())
        .processor(processor())
        .writer(writer())
        .build();
}
""",
            question: "Spring Batchの `chunk` 処理でトランザクションが使われる単位として正しいのはどれか？",
            choices: [
                choice("a", "chunk数（ここでは100）ごとに1トランザクションでコミットされる", correct: true,
                       explanation: "Spring Batchのchunk処理は指定件数ごとにトランザクションをコミットします。100件を1トランザクションで処理するため、失敗時のロールバックは最大100件分です。"),
                choice("b", "バッチJob全体が1つのトランザクションとして処理される", misconception: "Job全体が1トランザクションと誤解",
                       explanation: "Job全体を1トランザクションにすると、1万件のバッチで最後の1件が失敗しても全てロールバックされます。chunkトランザクションの方が現実的です。"),
                choice("c", "各アイテム（1件）ごとに独立したトランザクションが作られる", misconception: "1件=1トランザクションと誤解",
                       explanation: "1件ずつのトランザクションは大量データで効率が悪いです。chunkで複数件をまとめてコミットするのがSpring Batchの設計です。"),
                choice("d", "Spring BatchはJPAとトランザクションを共有できないため@Transactionalは使えない", misconception: "Spring BatchとJPAの非互換と誤解",
                       explanation: "Spring BatchはJPAと統合でき、JpaTransactionManagerを使ったchunk処理が可能です。")
            ],
            explanationRef: "explain-boot3-tx-adv-004",
            designIntent: "Spring BatchのChunkトランザクションを理解する。"
        ),
        quiz(
            id: "boot3-tx-adv-005",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["並行性", "在庫管理", "楽観vs悲観"],
            code: """
// シナリオ: 商品の在庫を1個減らして購入処理
// 同時に100人がアクセスする場合
""",
            question: "在庫減算のような「同時に複数ユーザーが操作する」シナリオでの適切なロック戦略として正しいのはどれか？",
            choices: [
                choice("a", "競合が少ない場合は楽観ロック（@Version）＋リトライ、競合が多い場合は悲観ロック（SELECT FOR UPDATE）が向いている", correct: true,
                       explanation: "楽観ロックはロックオーバーヘッドが少ない反面、競合が多いとリトライが増えます。悲観ロックはロックコストがある反面、競合時でも確実に処理できます。使用シナリオに合わせて選択します。"),
                choice("b", "在庫管理には常に楽観ロックが最適で悲観ロックを使う必要はない", misconception: "楽観ロックが常に最適と誤解",
                       explanation: "在庫数量のような高競合リソースでは悲観ロックが適切な場合があります。楽観ロックのリトライコストが問題になるシナリオでは悲観ロックを選びます。"),
                choice("c", "在庫管理には分離レベルSERIALIZABLEのみが安全でそれ以外は使うべきでない", misconception: "SERIALIZABLE必須と誤解",
                       explanation: "SERIALIZABLEはスループットが大幅に低下します。楽観ロック・悲観ロックで適切に設計することで多くのケースに対応できます。"),
                choice("d", "Spring Bootの@Transactionalだけで全ての競合問題が自動解決される", misconception: "@Transactionalが全競合を解決すると誤解",
                       explanation: "@Transactionalはトランザクション境界を提供しますが、競合解決戦略（楽観/悲観ロック）は別途設計する必要があります。")
            ],
            explanationRef: "explain-boot3-tx-adv-005",
            designIntent: "ロック戦略の選択基準を理解する。"
        ),
        quiz(
            id: "boot3-tx-adv-006",
            level: .practice,
            objective: "boot3-practice-transaction",
            category: .transactions,
            tags: ["コネクションプール", "HikariCP", "トランザクション"],
            code: """
# application.yml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
""",
            question: "HikariCPの `maximum-pool-size` とトランザクションの関係として正しいのはどれか？",
            choices: [
                choice("a", "同時に実行できるトランザクション数はプールサイズに制限され、超過するとconnection-timeoutで待機後にタイムアウトする", correct: true,
                       explanation: "各トランザクションはDB接続を1つ使います。プールサイズが10なら同時に10トランザクションが実行できます。超過すると接続待ちになり、connection-timeout後に例外が発生します。"),
                choice("b", "maximum-pool-sizeを大きくすれば全ての同時処理問題が解決される", misconception: "プールサイズ増大が万能解決策と誤解",
                       explanation: "DB側にも最大接続数の制限があります。プールサイズはDB許容接続数・メモリ・CPUコア数を考慮して設定します。闇雲に大きくしても逆効果になることがあります。"),
                choice("c", "HikariCPを使うとトランザクション内で複数のDB接続が使われる", misconception: "1トランザクション=複数接続と誤解",
                       explanation: "標準的な実装では1トランザクション=1接続です。複数接続が必要なのはXA/分散トランザクションです。"),
                choice("d", "`connection-timeout`はトランザクションのタイムアウトと同じ設定", misconception: "connection-timeoutとtransaction timeoutを混同",
                       explanation: "`connection-timeout` は接続プールから接続を取得するまでの最大待機時間です。@Transactional(timeout)はトランザクションの実行時間制限です。別々の設定です。")
            ],
            explanationRef: "explain-boot3-tx-adv-006",
            designIntent: "コネクションプールとトランザクションの関係を理解する。"
        ),
    ]
}
