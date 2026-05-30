import Foundation

extension Quiz {
    static let jpaQuizzes: [Quiz] = (jpaEntity + jpaRepository + jpaQuery + jpaRelationship
        + jpaTransaction + jpaDerived + jpaProjection + jpaAdvanced)
        .map { $0.contextualizedForPresentation() }

    // MARK: - Group 1: エンティティ定義 (6問)
    private static let jpaEntity: [Quiz] = [
        quiz(
            id: "boot3-jpa-entity-001",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Entity", "@Id", "@GeneratedValue"],
            code: """
@Entity
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private int price;
    // getter/setter省略
}
""",
            question: "`@GeneratedValue(strategy = GenerationType.IDENTITY)` の意味として正しいのはどれか？",
            choices: [
                choice("a", "DBの自動採番（AUTO_INCREMENT）をそのまま使い、Spring側でID生成を行わない", correct: true,
                       explanation: "IDENTITYはDBのオートインクリメント機能に委ねます。INSERT後にDBから採番された値を取得します。"),
                choice("b", "UUIDをSpring側で自動生成してIDにセットする", misconception: "IDENTITYとUUID生成を混同",
                       explanation: "UUIDを使うには `GenerationType.UUID` または `@UuidGenerator` を使います。"),
                choice("c", "JPAがシーケンステーブルを自動作成して採番を管理する", misconception: "IDENTITYとSEQUENCE/TABLEを混同",
                       explanation: "シーケンステーブル方式は `GenerationType.TABLE` です。IDENTITYはDB側のオートインクリメントを利用します。"),
                choice("d", "IDはアプリ側でセットしなければならず、NULLのまま保存するとエラーになる", misconception: "IDENTITY戦略ではアプリセット不要と誤解",
                       explanation: "IDENTITYでは明示的にIDをセットしなくてもINSERT後にDBが採番します。")
            ],
            explanationRef: "explain-boot3-jpa-entity-001",
            designIntent: "エンティティのID生成戦略を理解する。"
        ),
        quiz(
            id: "boot3-jpa-entity-002",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Column", "@NotNull", "DDL"],
            code: """
@Entity
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
""",
            question: "`@Column(updatable = false)` を `createdAt` に付けた場合の挙動として正しいのはどれか？",
            choices: [
                choice("a", "エンティティ更新時にUPDATE文で `created_at` カラムが除外される", correct: true,
                       explanation: "`updatable = false` はJPAが生成するUPDATE文からそのカラムを除きます。作成日時を変更させたくないときに使います。"),
                choice("b", "`createdAt` フィールドはどのフレームワークからも変更できなくなる", misconception: "JPAの制約とJavaフィールドの不変性を混同",
                       explanation: "Javaフィールド自体は変更可能です。JPAが生成するSQLのUPDATE文に含めないだけです。"),
                choice("c", "最初のINSERT時にも `created_at` はNULLで保存される", misconception: "updatableをinsertableと混同",
                       explanation: "INSERT時の動作は `insertable` 属性で制御します。`updatable = false` はUPDATEのみに影響します。"),
                choice("d", "JPA起動時にこのカラムは読み取り専用テーブルに移動する", misconception: "存在しない挙動",
                       explanation: "そのような動作はありません。`updatable = false` はSQL生成レベルの制御です。")
            ],
            explanationRef: "explain-boot3-jpa-entity-002",
            designIntent: "@Column属性の実際の効果を理解する。"
        ),
        quiz(
            id: "boot3-jpa-entity-003",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Embeddable", "@Embedded", "値オブジェクト"],
            code: """
@Embeddable
public class Address {
    private String city;
    private String zipCode;
}

@Entity
public class Customer {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Embedded
    private Address address;
}
""",
            question: "`@Embeddable` / `@Embedded` を使ったとき、DBテーブルはどうなるか？",
            choices: [
                choice("a", "`address` のフィールドが `customer` テーブルのカラムとしてフラットに展開される", correct: true,
                       explanation: "@Embeddableはテーブルを分割しません。`city`、`zip_code` などが `customer` テーブルのカラムになります。"),
                choice("b", "`address` 専用の別テーブルが作られ外部キーで結合される", misconception: "@Embeddableと@OneToOneを混同",
                       explanation: "別テーブルになるのは `@Entity` + `@OneToOne` の場合です。@Embeddableは同一テーブルに展開されます。"),
                choice("c", "JSON型カラムとして `address` がシリアライズされて保存される", misconception: "@Embeddableと@Converter/JSONBを混同",
                       explanation: "JSONカラムにするにはカスタム `AttributeConverter` が必要です。@Embeddableはカラム分割です。"),
                choice("d", "`@Embeddable` クラスはスキーマ生成対象外となりDDLに影響しない", misconception: "@Embeddable自体が無視されると誤解",
                       explanation: "@Embeddableのフィールドは親エンティティのテーブルDDLに反映されます。")
            ],
            explanationRef: "explain-boot3-jpa-entity-003",
            designIntent: "値オブジェクトのマッピング方法を理解する。"
        ),
        quiz(
            id: "boot3-jpa-entity-004",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Enumerated", "EnumType", "DB保存"],
            code: """
public enum Status { ACTIVE, INACTIVE, PENDING }

@Entity
public class Account {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private Status status;
}
""",
            question: "`@Enumerated(EnumType.STRING)` を使った場合の問題点として正しいのはどれか？",
            choices: [
                choice("a", "Enum定数の名前を変えると既存データと不整合が起きる", correct: true,
                       explanation: "STRINGは定数名をそのまま保存するため、リファクタリングで名前を変えるとDBの文字列と一致しなくなります。"),
                choice("b", "数値として保存されるため、Enum順序を変えると意味が変わる", misconception: "EnumType.STRINGとORDINALの挙動を逆に理解",
                       explanation: "ORDINALは順序番号を保存するため順序変更が危険です。STRINGは名前を保存するため順序変更は安全です。"),
                choice("c", "Enum定数が3つ以上になるとDBエラーになる", misconception: "存在しない制限",
                       explanation: "Enum定数数の制限はありません。VARCHAR長が問題になることはありますが、定数数そのものは関係ありません。"),
                choice("d", "NULLを許可しないため必ず値が必要になる", misconception: "@EnumeratedのNULL制御への誤解",
                       explanation: "@EnumeratedはNULL許可・不許可を制御しません。NULLを許可するかは@Column(nullable)で制御します。")
            ],
            explanationRef: "explain-boot3-jpa-entity-004",
            designIntent: "Enum保存の落とし穴を理解する。"
        ),
        quiz(
            id: "boot3-jpa-entity-005",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Table", "インデックス", "ユニーク制約"],
            code: """
@Entity
@Table(
    name = "orders",
    uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "product_id"}),
    indexes = @Index(name = "idx_orders_status", columnList = "status")
)
public class Order {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long userId;
    private Long productId;
    private String status;
}
""",
            question: "`@Table` アノテーションの `uniqueConstraints` 属性について正しいのはどれか？",
            choices: [
                choice("a", "`user_id` と `product_id` の組み合わせがユニークになる複合UNIQUE制約がDDLに生成される", correct: true,
                       explanation: "複数カラムを指定した `uniqueConstraints` は複合UNIQUE制約として生成されます。単カラムのユニーク制約は@Column(unique=true)で対応します。"),
                choice("b", "`user_id` 単体と `product_id` 単体の両方にUNIQUE制約が付く", misconception: "複合UNIQUE制約と単一UNIQUE制約を混同",
                       explanation: "複合制約は「組み合わせ」に対してUNIQUEを保証します。各カラム単体に制約は付きません。"),
                choice("c", "アプリ起動時のバリデーションにのみ使われ、DDLには影響しない", misconception: "@UniqueConstraintをBeanValidationと混同",
                       explanation: "@UniqueConstraintはDDL生成（`spring.jpa.hibernate.ddl-auto`）時にSQLに反映されます。バリデーションとは別物です。"),
                choice("d", "テーブル名を `orders` に変更する際に既存のUNIQUEが自動削除される", misconception: "存在しない動作",
                       explanation: "JPA/Hibernateはマイグレーションを自動管理するツールではありません。本番DBの変更はFlywayなどで管理します。")
            ],
            explanationRef: "explain-boot3-jpa-entity-005",
            designIntent: "@Tableアノテーションによるスキーマ制約定義を理解する。"
        ),
        quiz(
            id: "boot3-jpa-entity-006",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@PrePersist", "@PreUpdate", "ライフサイクル"],
            code: """
@Entity
public class Article {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    public void prePersist() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
""",
            question: "`@PrePersist` の正しい説明はどれか？",
            choices: [
                choice("a", "エンティティがDBに初めて保存（INSERT）される直前に呼ばれる", correct: true,
                       explanation: "@PrePersistはEntityManager.persist()が呼ばれた後、INSERT SQL発行前に実行されます。作成日時の自動セットによく使われます。"),
                choice("b", "エンティティがDBから取得（SELECT）された直後に呼ばれる", misconception: "@PrePersistと@PostLoadを混同",
                       explanation: "SELECTで取得後に呼ばれるのは@PostLoadです。@PrePersistはINSERT前です。"),
                choice("c", "UPDATE・INSERT両方の直前に毎回呼ばれる", misconception: "@PrePersistと@PreUpdateの両方を同時に担うと誤解",
                       explanation: "UPDATE前は@PreUpdateが呼ばれます。@PrePersistは最初のINSERT前のみです。"),
                choice("d", "@Transactionalなメソッドの開始前に必ず呼ばれる", misconception: "ライフサイクルコールバックとトランザクション境界を混同",
                       explanation: "@PrePersistはトランザクションではなくエンティティのライフサイクルに紐付きます。persist()呼び出し時に発火します。")
            ],
            explanationRef: "explain-boot3-jpa-entity-006",
            designIntent: "エンティティライフサイクルコールバックの使い方を理解する。"
        ),
    ]

    // MARK: - Group 2: Repositoryインターフェース (5問)
    private static let jpaRepository: [Quiz] = [
        quiz(
            id: "boot3-jpa-repo-001",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["JpaRepository", "CrudRepository", "インターフェース"],
            code: """
public interface ProductRepository extends JpaRepository<Product, Long> {
}
""",
            question: "`JpaRepository<Product, Long>` を継承するだけで使えるメソッドの例として正しいのはどれか？",
            choices: [
                choice("a", "`findById(Long id)`、`save(Product entity)`、`deleteById(Long id)` などがすぐ使える", correct: true,
                       explanation: "JpaRepositoryはCRUD操作、ページング、ソートを含む豊富なメソッドを標準提供します。実装クラスをSpringが自動生成します。"),
                choice("b", "インターフェースだけでは動かず、`@Service` クラスで実装クラスを必ず作る必要がある", misconception: "Repositoryは自動実装されると知らない",
                       explanation: "Spring Data JPAがリポジトリの実装を実行時に動的に生成します。実装クラスは不要です。"),
                choice("c", "`findAll()` はデフォルトで最新50件に制限される", misconception: "存在しない制限",
                       explanation: "`findAll()` はデフォルトで全件取得します。ページングが必要な場合は`findAll(Pageable pageable)`を使います。"),
                choice("d", "第2型引数 `Long` はページサイズを指定している", misconception: "型引数の意味を誤解",
                       explanation: "第2型引数はエンティティのID（主キー）の型です。ページサイズとは無関係です。")
            ],
            explanationRef: "explain-boot3-jpa-repo-001",
            designIntent: "JpaRepositoryの基本的な使い方を理解する。"
        ),
        quiz(
            id: "boot3-jpa-repo-002",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["save()", "merge", "persist"],
            code: """
@Service
@RequiredArgsConstructor
public class ProductService {
    private final ProductRepository repo;

    public Product update(Long id, String newName) {
        Product p = repo.findById(id).orElseThrow();
        p.setName(newName);
        return repo.save(p);  // (A)
    }
}
""",
            question: "既存エンティティに対して `repo.save(p)` を呼んだとき（A）の挙動として正しいのはどれか？",
            choices: [
                choice("a", "IDが存在するため `merge` に相当する処理が走り、UPDATE SQLが発行される", correct: true,
                       explanation: "Spring Data JPAの `save()` は新規（IDがnull）なら `persist()`、既存（IDあり）なら `merge()` を呼びます。"),
                choice("b", "常にINSERT SQLが発行され重複IDエラーになる", misconception: "save()が常にINSERTと誤解",
                       explanation: "save()はIDの有無でpersist/mergeを切り替えます。既存エンティティにはUPDATEが発行されます。"),
                choice("c", "@Transactionalがないためsave()は即時にDBへ反映されない", misconception: "save()にトランザクションが必要と誤解",
                       explanation: "JpaRepositoryの `save()` 自体が@Transactionalを持っています。呼び出し元にアノテーションがなくても動作します。"),
                choice("d", "同一トランザクション内でフィールドを変更した場合、save()の呼び出しは不要", misconception: "ダーティチェックがあれば常にsave()不要と誤解",
                       explanation: "同一トランザクション内の管理対象エンティティならダーティチェックでsave()なしにUPDATEされますが、そのためには@Transactionalが呼び出し元に必要です。このコードはServiceに@Transactionalがないためsave()が必要です。")
            ],
            explanationRef: "explain-boot3-jpa-repo-002",
            designIntent: "save()メソッドの内部動作とpersist/mergeの違いを理解する。"
        ),
        quiz(
            id: "boot3-jpa-repo-003",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["Optional", "findById", "orElseThrow"],
            code: """
public Product getProduct(Long id) {
    return productRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Product not found: " + id));
}
""",
            question: "`findById()` が `Optional<Product>` を返す理由として最も適切なのはどれか？",
            choices: [
                choice("a", "該当データが存在しない場合のNullPointerExceptionを防ぎ、呼び出し元に明示的なハンドリングを強制するため", correct: true,
                       explanation: "Optionalを返すことで「データがない可能性」をAPIで表現します。nullチェック忘れによるNPEを防ぎます。"),
                choice("b", "Optionalにより検索がDBへ送られるのをキャッシュヒット時のみに限定できるため", misconception: "OptionalとL1キャッシュを混同",
                       explanation: "OptionalはNullの安全な表現のためです。キャッシュ制御とは関係ありません。"),
                choice("c", "複数件ヒットした場合にコレクションとして取り出せるようにするため", misconception: "OptionalとListを混同",
                       explanation: "複数件はListやPage<T>を返します。Optionalは0件か1件かの表現です。"),
                choice("d", "戻り値にOptionalを使うとJPAが自動的にLEFT JOINを発行するため", misconception: "存在しない挙動",
                       explanation: "OptionalはJavaの戻り値型です。生成されるSQLには影響しません。")
            ],
            explanationRef: "explain-boot3-jpa-repo-003",
            designIntent: "Optional活用の意図を理解する。"
        ),
        quiz(
            id: "boot3-jpa-repo-004",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["existsById", "count", "deleteAll"],
            code: """
// 現在のコード
if (repo.findById(id).isPresent()) {
    repo.deleteById(id);
}
""",
            question: "上記を1行で書き直すより良い方法はどれか？",
            choices: [
                choice("a", "`repo.deleteById(id)` だけにする（存在しない場合はEmptyResultDataAccessExceptionがスローされるが、try-catchで処理する）", correct: true,
                       explanation: "`deleteById()` は内部で `findById()` してから削除します。事前チェックは二重検索になります。存在しない場合はEmptyResultDataAccessExceptionなのでtry-catchが対応策です。"),
                choice("b", "`if (repo.existsById(id)) repo.deleteById(id)` にする", misconception: "existsByIdで事前確認が最善と誤解",
                       explanation: "これもfindById + deleteで計2クエリ発行します。並行削除の競合も防げません。"),
                choice("c", "`repo.count() > 0` で全件の存在を確認してから削除する", misconception: "count()でIDの存在確認ができると誤解",
                       explanation: "count()は全件数を返します。特定IDの存在確認にはなりません。"),
                choice("d", "`repo.deleteAll()` で全件削除すれば確実", misconception: "IDを指定せず全件削除が安全と誤解",
                       explanation: "deleteAll()は全エンティティを削除します。特定IDの削除とは全く異なります。")
            ],
            explanationRef: "explain-boot3-jpa-repo-004",
            designIntent: "Repositoryの効率的な使い方を理解する。"
        ),
        quiz(
            id: "boot3-jpa-repo-005",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Modifying", "@Query", "バルク更新"],
            code: """
public interface OrderRepository extends JpaRepository<Order, Long> {

    @Modifying
    @Transactional
    @Query("UPDATE Order o SET o.status = 'COMPLETED' WHERE o.createdAt < :cutoff")
    int bulkComplete(@Param("cutoff") LocalDateTime cutoff);
}
""",
            question: "`@Modifying` が必要な理由として正しいのはどれか？",
            choices: [
                choice("a", "@Query でUPDATE/DELETEを実行するとき、SELECTではなく更新クエリであることをSpring Data JPAに伝えるため", correct: true,
                       explanation: "@Queryは通常SELECTを期待します。@Modifyingを付けることでUPDATE/DELETEのバルク操作を許可し、影響行数（int/long）を返せるようになります。"),
                choice("b", "メソッドがトランザクション内で動作することを保証するため", misconception: "@Modifyingと@Transactionalを混同",
                       explanation: "トランザクションの保証は@Transactionalが担います。@Modifyingは更新クエリを宣言するためのアノテーションです。"),
                choice("c", "バルク更新後にキャッシュを自動でクリアするため", misconception: "キャッシュクリアが主目的と誤解",
                       explanation: "@Modifying(clearAutomatically = true)でキャッシュクリアができますが、それはオプション機能です。主な目的はUPDATE/DELETE宣言です。"),
                choice("d", "JPQLのUPDATE文にSQLインジェクション対策を適用するため", misconception: "@Modifyingとセキュリティを関連づける誤解",
                       explanation: "SQLインジェクション対策はパラメータバインディング（:cutoff）が担います。@Modifyingとは無関係です。")
            ],
            explanationRef: "explain-boot3-jpa-repo-005",
            designIntent: "@Modifyingの役割を理解する。"
        ),
    ]

    // MARK: - Group 3: クエリメソッド命名規則 (5問)
    private static let jpaQuery: [Quiz] = [
        quiz(
            id: "boot3-jpa-query-001",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["クエリメソッド", "命名規則", "findBy"],
            code: """
public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByAgeGreaterThanAndActiveTrue(int age);
}
""",
            question: "上記メソッドが生成するSQLのWHERE句として正しいのはどれか？",
            choices: [
                choice("a", "`WHERE age > ? AND active = true`", correct: true,
                       explanation: "Spring Data JPAは `GreaterThan` → `>`、`And` → `AND`、`True` → `= true` と変換します。キャメルケースのフィールド名もスネークケースのカラムにマッピングされます。"),
                choice("b", "`WHERE age >= ? AND active = true`", misconception: "GreaterThanとGreaterThanOrEqualToを混同",
                       explanation: "GreaterThanEqualToまたはGreaterThanOrEqualToが`>=`に対応します。GreaterThanは厳密な`>`です。"),
                choice("c", "`WHERE age > ? OR active = true`", misconception: "AndをOrと読み間違える",
                       explanation: "メソッド名のAndはSQLのANDに対応します。ORにしたい場合はOrを使います（例：`findByAgeOrActive`）。"),
                choice("d", "このメソッド名は無効なためSpring起動時に例外がスローされる", misconception: "複雑な命名規則は無効と誤解",
                       explanation: "Spring Data JPAはこの命名規則を正しく解析できます。起動時に自動的にSQLが生成されます。")
            ],
            explanationRef: "explain-boot3-jpa-query-001",
            designIntent: "クエリメソッドの命名規則を理解する。"
        ),
        quiz(
            id: "boot3-jpa-query-002",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Query", "JPQL", "ネイティブSQL"],
            code: """
// パターンA: JPQL
@Query("SELECT u FROM User u WHERE u.email = :email")
Optional<User> findByEmail(@Param("email") String email);

// パターンB: ネイティブSQL
@Query(value = "SELECT * FROM users WHERE email = :email", nativeQuery = true)
Optional<User> findByEmailNative(@Param("email") String email);
""",
            question: "JPQLとネイティブSQLの違いとして正しいのはどれか？",
            choices: [
                choice("a", "JPQLはエンティティ名・フィールド名を使いDB非依存、ネイティブSQLはテーブル名・カラム名を使い特定DBの機能が使える", correct: true,
                       explanation: "JPQLはJavaオブジェクトモデルを対象にするため移植性が高く、ネイティブSQLはDBベンダー固有の関数やテーブル構造を直接使えます。"),
                choice("b", "ネイティブSQLは @Query なしで書けるが、JPQLは必ず @Query が必要", misconception: "@Queryの必要条件を混同",
                       explanation: "どちらも @Query が必要です。ネイティブSQLには `nativeQuery = true` を追加します。"),
                choice("c", "JPQLはパラメータバインディングができないためSQLインジェクションのリスクがある", misconception: "JPQLのセキュリティへの誤解",
                       explanation: "JPQLは@Paramによるパラメータバインディングをサポートしており、インジェクション対策が可能です。"),
                choice("d", "ネイティブSQLは常にJPQLより高速になる", misconception: "ネイティブSQLは必ず速いという誤解",
                       explanation: "必ずしもネイティブSQLが速いとは限りません。JPQLはHibernateが最適化したSQLを生成します。")
            ],
            explanationRef: "explain-boot3-jpa-query-002",
            designIntent: "JPQLとネイティブSQLの使い分けを理解する。"
        ),
        quiz(
            id: "boot3-jpa-query-003",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["Pageable", "Page", "ページング"],
            code: """
public interface ProductRepository extends JpaRepository<Product, Long> {
    Page<Product> findByCategoryAndPriceLessThan(
        String category, int price, Pageable pageable);
}

// 呼び出し側
Pageable page = PageRequest.of(0, 10, Sort.by("price").ascending());
Page<Product> result = repo.findByCategoryAndPriceLessThan("electronics", 50000, page);
""",
            question: "`Page<Product>` オブジェクトから取得できる情報として正しいのはどれか？",
            choices: [
                choice("a", "コンテンツ一覧（`getContent()`）、総ページ数（`getTotalPages()`）、総件数（`getTotalElements()`）などが取得できる", correct: true,
                       explanation: "Pageはページ内容だけでなくページングメタ情報を含みます。フロントエンドのページネーションUIで必要な情報が揃っています。"),
                choice("b", "`Page<Product>` はListと同じでページングメタ情報は含まない", misconception: "PageとListを同等と誤解",
                       explanation: "ListはPageとは異なります。Pageにはページング情報が含まれますが、Listには含まれません。"),
                choice("c", "ページ番号は1始まりのため`PageRequest.of(0, 10)`は2ページ目を意味する", misconception: "ページ番号が0始まりか1始まりかを逆に理解",
                       explanation: "Spring Dataのページ番号は0始まりです。`PageRequest.of(0, 10)` は最初の10件（0ページ目）です。"),
                choice("d", "`Page<Product>` を使うと自動で全件取得後にJavaでソートが行われる", misconception: "ページングがDB側でなくJava側で行われると誤解",
                       explanation: "Page/Pageableを使うとDB側でLIMIT/OFFSET（または同等）が発行されます。全件をJavaに読み込んでから絞り込む訳ではありません。")
            ],
            explanationRef: "explain-boot3-jpa-query-003",
            designIntent: "ページングAPIの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-jpa-query-004",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["N+1問題", "Fetch Join", "LAZY"],
            code: """
// Order エンティティ
@Entity
public class Order {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<OrderItem> items;
}

// サービス
@Transactional
public List<Order> getOrdersWithItems() {
    List<Order> orders = orderRepository.findAll(); // (1) SELECT * FROM orders
    orders.forEach(o -> o.getItems().size());       // (2) ループ内で追加SELECT
    return orders;
}
""",
            question: "このコードで発生する問題として正しいのはどれか？",
            choices: [
                choice("a", "N+1問題：1件のordersクエリ＋注文件数分のitemsクエリが発行される", correct: true,
                       explanation: "LAZYロードでは `getItems()` を呼ぶ度にSELECTが発行されます。注文が100件あれば101回のSQLが実行されます。"),
                choice("b", "@TransactionalがあるためfindAll()は常にキャッシュから返り、追加SQLは発行されない", misconception: "L1キャッシュで全件カバーできると誤解",
                       explanation: "一次キャッシュはsession内の同一IDの再取得をキャッシュします。findAll()で取得した全Orderのitemsを自動でキャッシュする訳ではありません。"),
                choice("c", "FetchType.LAZYはSpring Bootでは無効で常にEAGERになる", misconception: "Spring BootがLAZYを無効化すると誤解",
                       explanation: "Spring BootはFetchType設定を変更しません。LAZYはそのまま有効です。"),
                choice("d", "このコードは @Transactional なしでは LazyInitializationException が発生するが、付ければ問題ない", misconception: "N+1問題をトランザクション不足と混同",
                       explanation: "@Transactionalなしでは確かにLazyInitializationExceptionが出ますが、付けてもN+1問題は解決しません。解決にはFetch Joinやbatch fetch sizeが必要です。")
            ],
            explanationRef: "explain-boot3-jpa-query-004",
            designIntent: "N+1問題を識別できるようにする。"
        ),
        quiz(
            id: "boot3-jpa-query-005",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["Fetch Join", "@EntityGraph", "N+1解決"],
            code: """
// 解決策A: JPQL Fetch Join
@Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.status = :status")
List<Order> findWithItemsByStatus(@Param("status") String status);

// 解決策B: @EntityGraph
@EntityGraph(attributePaths = {"items"})
List<Order> findByStatus(String status);
""",
            question: "Fetch Joinと@EntityGraphの違いとして正しいのはどれか？",
            choices: [
                choice("a", "Fetch Joinは任意のWHERE条件と組み合わせやすく、@EntityGraphは既存の命名規則メソッドにそのまま適用できる", correct: true,
                       explanation: "@EntityGraphは命名規則メソッドにアノテーション1つでJOIN FETCHを追加できます。Fetch Joinは@Queryで自由にカスタマイズできます。"),
                choice("b", "@EntityGraphはSELECTをN回発行するためFetch Joinより遅い", misconception: "@EntityGraphもN+1が発生すると誤解",
                       explanation: "@EntityGraphはFetch Joinと同様にJOINを使って1回のSELECTで関連を取得します。N+1は解消されます。"),
                choice("c", "Fetch JoinはEAGERロードを無効化するため、LAZY設定が無視される", misconception: "Fetch JoinがグローバルなFetchType設定を変える誤解",
                       explanation: "Fetch Joinはそのクエリに限定した即時ロードです。エンティティのFetchType設定を永続的に変えるものではありません。"),
                choice("d", "どちらを使っても複数の@OneToManyをまとめてFETCHするとHibernateの制限でエラーになる", misconception: "複数Fetch Joinは常に禁止と誤解",
                       explanation: "複数コレクションのFetch Joinは「MultipleBagFetchException」が出る場合があります（Bagではなくsetなら可）。ただし「常にエラー」ではなく回避策もあります。")
            ],
            explanationRef: "explain-boot3-jpa-query-005",
            designIntent: "N+1解決策の使い分けを理解する。"
        ),
    ]

    // MARK: - Group 4: リレーションシップ (5問)
    private static let jpaRelationship: [Quiz] = [
        quiz(
            id: "boot3-jpa-relation-001",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@OneToMany", "@ManyToOne", "mappedBy"],
            code: """
@Entity
public class Team {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToMany(mappedBy = "team")
    private List<Member> members;
}

@Entity
public class Member {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "team_id")
    private Team team;
}
""",
            question: "`mappedBy = \"team\"` の意味として正しいのはどれか？",
            choices: [
                choice("a", "外部キーの管理はMember側の `team` フィールドが担い、Team側はDBには影響しない", correct: true,
                       explanation: "`mappedBy` を指定した側は関連の「非所有者」です。DBの外部キー（`team_id`）はMember.teamフィールドで管理されます。"),
                choice("b", "`mappedBy` は双方向関連に必須で、外部キーカラム名を指定している", misconception: "mappedByとJoinColumn.nameを混同",
                       explanation: "`mappedBy` は外部キー名ではなく「相手側のフィールド名」を指定します。外部キーカラム名は`@JoinColumn(name=)`で指定します。"),
                choice("c", "`mappedBy` を指定すると `team_id` カラムがTeamテーブルに追加される", misconception: "mappedByが所有側と誤解",
                       explanation: "`mappedBy` を指定したTeam側はDBに追加カラムを持ちません。外部キーはMember側（所有者）のテーブルにあります。"),
                choice("d", "`mappedBy` はTeam→Memberのカスケード削除を自動で有効にする", misconception: "mappedByとcascade設定を混同",
                       explanation: "カスケード設定は`@OneToMany(cascade = CascadeType.ALL)`などで別途指定します。`mappedBy`は所有者の指定のみです。")
            ],
            explanationRef: "explain-boot3-jpa-relation-001",
            designIntent: "双方向リレーションシップの所有者概念を理解する。"
        ),
        quiz(
            id: "boot3-jpa-relation-002",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["CascadeType", "orphanRemoval", "ライフサイクル"],
            code: """
@OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
private List<OrderItem> items;
""",
            question: "`orphanRemoval = true` の動作として正しいのはどれか？",
            choices: [
                choice("a", "親Orderから `items` リストに対してorderItemを取り除くと、そのOrderItemがDELETEされる", correct: true,
                       explanation: "`orphanRemoval = true` は親コレクションから取り除かれた（孤立した）子エンティティをDELETEします。コレクションからの除去だけでDBから削除できます。"),
                choice("b", "`orphanRemoval` は `CascadeType.REMOVE` と同じ動作をする", misconception: "orphanRemovalとCascadeType.REMOVEを同一視",
                       explanation: "`CascadeType.REMOVE` は親削除時に子も削除します。`orphanRemoval` はコレクションから取り除いたとき削除します。両方設定する場合が多いです。"),
                choice("c", "`orphanRemoval` を設定するとOrder削除時にOrderItemは削除されなくなる", misconception: "意味を逆に理解",
                       explanation: "`orphanRemoval` の設定は親削除時の動作を変えません。孤立（コレクション除去）した子の自動削除を有効にするだけです。"),
                choice("d", "`orphanRemoval` は `@ManyToMany` 関連のみで有効", misconception: "使用可能な関連タイプを誤解",
                       explanation: "`orphanRemoval` は `@OneToMany` と `@OneToOne` で使用できます。`@ManyToMany` では使用できません。")
            ],
            explanationRef: "explain-boot3-jpa-relation-002",
            designIntent: "orphanRemovalの動作を理解する。"
        ),
        quiz(
            id: "boot3-jpa-relation-003",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@ManyToMany", "中間テーブル", "@JoinTable"],
            code: """
@Entity
public class Student {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToMany
    @JoinTable(
        name = "student_course",
        joinColumns = @JoinColumn(name = "student_id"),
        inverseJoinColumns = @JoinColumn(name = "course_id")
    )
    private List<Course> courses;
}
""",
            question: "`@ManyToMany` を使う場合の設計上の問題として最も重要なのはどれか？",
            choices: [
                choice("a", "中間テーブルに登録日時や評価などの追加属性を持たせたい場合に `@ManyToMany` では対応できない", correct: true,
                       explanation: "追加属性が必要な場合は中間テーブルを専用Entityに昇格させ（例：Enrollment）、@ManyToOne×2で表現するのがベストプラクティスです。"),
                choice("b", "`@ManyToMany` はSpring Boot 3.xで非推奨になった", misconception: "@ManyToManyが廃止されたと誤解",
                       explanation: "@ManyToManyは引き続き有効です。ただし設計上のトレードオフがあるため、用途を見極めて使います。"),
                choice("c", "`@JoinTable` が必須でないとNullPointerExceptionが起きる", misconception: "@JoinTable省略で例外が起きると誤解",
                       explanation: "@JoinTableを省略するとSpringがデフォルト名の中間テーブルを自動で使います。NPEは起きません。"),
                choice("d", "`@ManyToMany` はLAZYロードに対応していないため必ずEAGERになる", misconception: "FetchType.LAZYが使えないと誤解",
                       explanation: "@ManyToManyでもFetchType.LAZY（デフォルト）が使えます。")
            ],
            explanationRef: "explain-boot3-jpa-relation-003",
            designIntent: "@ManyToManyの制限と代替設計を理解する。"
        ),
        quiz(
            id: "boot3-jpa-relation-004",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@OneToOne", "共有主キー", "FetchType"],
            code: """
@Entity
public class UserProfile {
    @Id
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "id")
    private User user;

    private String bio;
}
""",
            question: "`@MapsId` を `@OneToOne` に付けた場合の意味として正しいのはどれか？",
            choices: [
                choice("a", "`UserProfile` の主キーを `User` の主キーと共有する（別途IDを採番しない）", correct: true,
                       explanation: "@MapsIdは関連エンティティのIDを自身のIDとして使う共有主キー設定です。UserProfileは独自のIDシーケンスを持たず、Userと同じIDで管理されます。"),
                choice("b", "`UserProfile` の更新時に `User` エンティティも同時にUPDATEされる", misconception: "@MapsIdをカスケードと混同",
                       explanation: "@MapsIdは主キー共有の設定です。カスケードの設定はcascade属性で行います。"),
                choice("c", "`UserProfile` テーブルには主キーカラムが作られない", misconception: "共有=カラムが消えると誤解",
                       explanation: "主キーカラムは存在します。値がUserのIDと同じになるだけで、カラム自体はあります。"),
                choice("d", "@MapsIdを使うと双方向ナビゲーション（User→UserProfile）が自動で有効になる", misconception: "@MapsIdで双方向が自動設定されると誤解",
                       explanation: "双方向にするにはUser側に`@OneToOne(mappedBy=\"user\")`を明示的に追加する必要があります。")
            ],
            explanationRef: "explain-boot3-jpa-relation-004",
            designIntent: "共有主キーパターンを理解する。"
        ),
        quiz(
            id: "boot3-jpa-relation-005",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["LazyInitializationException", "OpenEntityManagerInViewFilter", "トランザクション外"],
            code: """
// エラーが出るパターン
public Order getOrder(Long id) {
    return orderRepository.findById(id).orElseThrow(); // トランザクション外
}

// Thymeleafテンプレート内
${order.items}  // ここでLazyInitializationException
""",
            question: "`LazyInitializationException` が発生する原因として正しいのはどれか？",
            choices: [
                choice("a", "トランザクション（= JPAセッション）が終了した後にLAZYフィールドにアクセスしているため", correct: true,
                       explanation: "LAZYロードはセッション（Persistence Context）が開いている間のみ可能です。セッションが閉じた後に未初期化のプロキシにアクセスするとLazyInitializationExceptionが発生します。"),
                choice("b", "ThymeleafテンプレートエンジンはJPAに対応していないため", misconception: "テンプレートエンジンとJPAの相性の問題と誤解",
                       explanation: "ThymeleafとJPAは連携可能です。問題はセッションのスコープです。"),
                choice("c", "`@OneToMany` はLAZY設定を禁止されているため発生する", misconception: "@OneToManyのデフォルト設定を逆に理解",
                       explanation: "@OneToManyのデフォルトはLAZYです。LAZYは禁止されていません。"),
                choice("d", "List型のフィールドはJPAがSerializableでなければロードできない", misconception: "存在しない制限",
                       explanation: "SerializableはJPAの必須要件ではありません。LazyInitializationExceptionはセッションスコープの問題です。")
            ],
            explanationRef: "explain-boot3-jpa-relation-005",
            designIntent: "LAZYロードの仕組みとセッションスコープの関係を理解する。"
        ),
    ]

    // MARK: - Group 5: トランザクション (4問)
    private static let jpaTransaction: [Quiz] = [
        quiz(
            id: "boot3-jpa-tx-001",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Transactional", "ダーティチェック", "自動フラッシュ"],
            code: """
@Service
public class MemberService {

    @Transactional
    public void updateEmail(Long id, String newEmail) {
        Member m = memberRepository.findById(id).orElseThrow();
        m.setEmail(newEmail);
        // save() は呼んでいない
    }
}
""",
            question: "`save()` を呼ばなくても `email` がDBに更新される理由として正しいのはどれか？",
            choices: [
                choice("a", "@Transactionalにより管理下に入ったエンティティはトランザクション終了時にダーティチェックで変更が検出され自動でUPDATEされる", correct: true,
                       explanation: "JPAはPersistence Context内の管理対象エンティティの変更をコミット前に自動検出し、必要なUPDATE SQLを生成します。これをダーティチェックといいます。"),
                choice("b", "`setEmail()` を呼んだ瞬間にDBへUPDATEが発行される", misconception: "setterがDBを直接更新すると誤解",
                       explanation: "setterはJavaオブジェクトのフィールドを変更するだけです。DB更新はフラッシュ・コミット時に行われます。"),
                choice("c", "`findById()` が返すエンティティはSpringが監視しており、変更があれば即座に別スレッドでINSERTされる", misconception: "非同期バックグラウンド更新と誤解",
                       explanation: "そのような動作はありません。DB更新はトランザクションのフラッシュ/コミット時に同スレッドで行われます。"),
                choice("d", "`memberRepository` がSingleton BeanのためフィールドはDI後に変更が自動で永続化される", misconception: "BeanのスコープとJPAの永続化を混同",
                       explanation: "Beanのスコープと永続化は無関係です。ダーティチェックはPersistence Contextのメカニズムです。")
            ],
            explanationRef: "explain-boot3-jpa-tx-001",
            designIntent: "ダーティチェックの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-jpa-tx-002",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Transactional", "readOnly", "パフォーマンス"],
            code: """
@Transactional(readOnly = true)
public List<Product> getAllProducts() {
    return productRepository.findAll();
}
""",
            question: "`@Transactional(readOnly = true)` を付けた効果として正しいのはどれか？",
            choices: [
                choice("a", "ダーティチェックが無効化されパフォーマンスが向上し、一部のDB（MySQL等）ではスレーブに自動ルーティングされることがある", correct: true,
                       explanation: "readOnly=trueはJPAがフラッシュ（変更検出）をスキップするため軽量になります。Spring側でもDBへのヒントとして渡せます。"),
                choice("b", "このトランザクション内でSELECTのみ実行でき、INSERT/UPDATEを呼ぶと例外が発生する", misconception: "readOnlyが書き込みをブロックすると誤解",
                       explanation: "readOnly=trueはヒントですが、呼び出し自体はブロックしません。DB側が読み取り専用接続で禁止する場合はDB依存です。"),
                choice("c", "readOnly=trueを付けるとキャッシュが有効になりSELECTがDBに到達しなくなる", misconception: "readOnlyとクエリキャッシュを混同",
                       explanation: "readOnly=trueはダーティチェック無効化のためです。クエリキャッシュは別の仕組みで設定が必要です。"),
                choice("d", "readOnly=trueの付いたメソッドはトランザクションを開始しない", misconception: "readOnlyはトランザクションなしを意味すると誤解",
                       explanation: "readOnly=trueでもトランザクションは開始します。ダーティチェックが無効になるだけです。")
            ],
            explanationRef: "explain-boot3-jpa-tx-002",
            designIntent: "readOnlyトランザクションの最適化効果を理解する。"
        ),
        quiz(
            id: "boot3-jpa-tx-003",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["楽観ロック", "@Version", "OptimisticLockException"],
            code: """
@Entity
public class Inventory {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Version
    private int version;

    private int quantity;
}
""",
            question: "`@Version` による楽観ロックの動作として正しいのはどれか？",
            choices: [
                choice("a", "UPDATE時にWHERE句にversionが含まれ、競合検出時にOptimisticLockExceptionがスローされる", correct: true,
                       explanation: "JPAはUPDATE時に`WHERE id=? AND version=?`を発行します。他プロセスが先に更新してversionが変わっていると0件更新となりOptimisticLockExceptionが発生します。"),
                choice("b", "`@Version` はDBでのレコードロック（SELECT FOR UPDATE）を使う悲観ロックを実装する", misconception: "楽観ロックと悲観ロックを混同",
                       explanation: "@Versionは楽観ロックです。悲観ロックは`@Lock(LockModeType.PESSIMISTIC_WRITE)`で実装します。"),
                choice("c", "`@Version` フィールドはアプリケーション側で手動でインクリメントする必要がある", misconception: "versionの更新が手動と誤解",
                       explanation: "JPAがUPDATE時にversionを自動でインクリメントします。手動で変更する必要はありません（してはいけません）。"),
                choice("d", "`@Version` の型はLongのみ対応している", misconception: "@Versionの型制限を誤解",
                       explanation: "@Versionはint、Integer、long、Long、short、Short、Timestampが使用できます。")
            ],
            explanationRef: "explain-boot3-jpa-tx-003",
            designIntent: "楽観ロックの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-jpa-tx-004",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["flush", "clear", "バッチ処理"],
            code: """
@Transactional
public void bulkInsert(List<ProductDto> dtos) {
    for (int i = 0; i < dtos.size(); i++) {
        Product p = new Product(dtos.get(i));
        entityManager.persist(p);

        if (i % 50 == 49) {
            entityManager.flush();  // (A)
            entityManager.clear();  // (B)
        }
    }
}
""",
            question: "バッチ処理で `flush()` → `clear()` を定期的に呼ぶ理由として正しいのはどれか？",
            choices: [
                choice("a", "flush()でDBへ書き出し、clear()でPersistence Contextから管理対象を解放してメモリを節約するため", correct: true,
                       explanation: "大量データをpersist()し続けるとPersistence Contextが膨大なエンティティを保持しメモリ不足になります。定期的にflush()+clear()することで管理対象を解放します。"),
                choice("b", "flush()はコミットと同じで、定期コミットによってロールバック範囲を小さくするため", misconception: "flush()とcommit()を混同",
                       explanation: "flush()はSQLをDBに送るだけで、コミットはしません。1トランザクション内の操作は全てロールバック可能です。"),
                choice("c", "clear()をしないとDBへの書き込みが重複してDuplicateKeyExceptionが発生するため", misconception: "clear()の目的をエラー防止と誤解",
                       explanation: "clear()はメモリ管理のためです。重複キーエラーはエンティティの設計や一意制約に関係します。"),
                choice("d", "このコードでは `entityManager` を直接使っているため `@Transactional` は不要", misconception: "EntityManager直接使用時にトランザクションが不要と誤解",
                       explanation: "EntityManagerを使う場合もトランザクションは必要です。@Transactionalなしではpersist()がIllegalStateExceptionになります。")
            ],
            explanationRef: "explain-boot3-jpa-tx-004",
            designIntent: "バッチ処理でのメモリ管理を理解する。"
        ),
    ]

    // MARK: - Group 6: 派生クエリ応用 (3問)
    private static let jpaDerived: [Quiz] = [
        quiz(
            id: "boot3-jpa-derived-001",
            level: .foundation,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["countBy", "deleteBy", "existsBy"],
            code: """
public interface ProductRepository extends JpaRepository<Product, Long> {
    long countByCategoryAndPriceGreaterThan(String category, int price);
    boolean existsByNameIgnoreCase(String name);
    int deleteByCreatedAtBefore(LocalDate date);
}
""",
            question: "`deleteByCreatedAtBefore` を呼ぶときに必要な追加アノテーションはどれか？",
            choices: [
                choice("a", "`@Transactional` と `@Modifying`", correct: true,
                       explanation: "deleteBy〜のような変更操作を命名規則で行う場合でも @Modifying と @Transactional が必要です。@Modifying がないと例外が発生します。"),
                choice("b", "`@Query` のみ必要（命名規則のdeleteにはSQLを書かなければならない）", misconception: "deleteByには@Queryが必要と誤解",
                       explanation: "deleteBy〜は命名規則でSpring Dataが自動実装します。@Queryは不要ですが、@Modifying+@Transactionalは必要です。"),
                choice("c", "追加アノテーションは不要、命名規則だけで動作する", misconception: "@Modifyingなしで変更が動くと誤解",
                       explanation: "変更操作（DELETE/UPDATE）には@Modifyingが必要です。省略するとInvalidJpaQueryMethodExceptionなどが発生します。"),
                choice("d", "`@Lock(LockModeType.PESSIMISTIC_WRITE)` が必要", misconception: "削除操作に悲観ロックが必須と誤解",
                       explanation: "@Lockは必須ではありません。バッチ削除に悲観ロックが必要かは設計次第です。")
            ],
            explanationRef: "explain-boot3-jpa-derived-001",
            designIntent: "deleteByの注意点を理解する。"
        ),
        quiz(
            id: "boot3-jpa-derived-002",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["Specification", "JpaSpecificationExecutor", "動的クエリ"],
            code: """
public interface ProductRepository
    extends JpaRepository<Product, Long>, JpaSpecificationExecutor<Product> {}

// 呼び出し側
Specification<Product> spec = (root, query, cb) ->
    cb.and(
        cb.equal(root.get("category"), "electronics"),
        cb.greaterThan(root.get("price"), 10000)
    );
List<Product> results = productRepository.findAll(spec);
""",
            question: "`Specification` を使う利点として正しいのはどれか？",
            choices: [
                choice("a", "条件を動的に組み合わせられるため、検索条件がオプションで変わるUIに対応しやすい", correct: true,
                       explanation: "Specificationはクエリ条件をオブジェクトとして組み合わせられます。フィルタが任意で変わる検索画面などに有効です。"),
                choice("b", "Specificationを使うとSQLが自動でキャッシュされ2回目以降の検索が高速になる", misconception: "SpecificationとQueryキャッシュを混同",
                       explanation: "SpecificationはSQL生成の抽象化です。クエリキャッシュは別の仕組みです。"),
                choice("c", "Specificationを使うとネイティブSQLの実行が可能になる", misconception: "SpecificationとnativeQueryを混同",
                       explanation: "SpecificationはJPQL/Criteria APIベースです。ネイティブSQLには@Query(nativeQuery=true)を使います。"),
                choice("d", "Specificationはパフォーマンスよりも命名規則メソッドより必ず優れている", misconception: "Specificationが常に最善と誤解",
                       explanation: "Specificationは動的条件が多い場合に有用ですが、固定条件なら命名規則の方がシンプルです。")
            ],
            explanationRef: "explain-boot3-jpa-derived-002",
            designIntent: "動的クエリ構築の方法を理解する。"
        ),
        quiz(
            id: "boot3-jpa-derived-003",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["Slice", "Page", "スクロール"],
            code: """
// Pageを使う
Page<Post> findByCategory(String category, Pageable pageable);

// Sliceを使う
Slice<Post> findByCategory(String category, Pageable pageable);
""",
            question: "`Page` と `Slice` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "`Page` は総件数を取得するCOUNTクエリを追加発行するが、`Slice` は発行せず次ページの有無のみ判定する", correct: true,
                       explanation: "Pageは総件数（getTotalElements）取得のためにCOUNTを発行します。Sliceは`limit+1`件取得して次ページの有無だけ判定するため、大量データの無限スクロールに適しています。"),
                choice("b", "`Slice` の方が常にPageより多くのSQLを発行する", misconception: "SliceがPageより重いと誤解",
                       explanation: "SliceはCOUNTクエリを省くためPageより軽量です。"),
                choice("c", "`Slice` は総ページ数を返せるため無限スクロールには不向き", misconception: "SliceとPageの適性を逆に理解",
                       explanation: "Sliceは総ページ数を持たないため無限スクロールに適しています。ページネーションUIが必要な場合はPageが向いています。"),
                choice("d", "`Page` と `Slice` は機能的に同一でパフォーマンスの差もない", misconception: "両者が同一と誤解",
                       explanation: "COUNTクエリの有無で明確にパフォーマンスが異なります。")
            ],
            explanationRef: "explain-boot3-jpa-derived-003",
            designIntent: "PageとSliceの使い分けを理解する。"
        ),
    ]

    // MARK: - Group 7: プロジェクション (3問)
    private static let jpaProjection: [Quiz] = [
        quiz(
            id: "boot3-jpa-proj-001",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["インターフェースプロジェクション", "DTOプロジェクション", "Closed"],
            code: """
// インターフェースプロジェクション
public interface ProductSummary {
    String getName();
    int getPrice();
}

public interface ProductRepository extends JpaRepository<Product, Long> {
    List<ProductSummary> findByCategory(String category);
}
""",
            question: "インターフェースプロジェクションを使う利点として正しいのはどれか？",
            choices: [
                choice("a", "必要なフィールドだけをSELECTするクエリが生成されエンティティ全体を取得するより軽量になる", correct: true,
                       explanation: "クローズドプロジェクション（Closedインターフェース）では指定フィールドのみSELECTされます。エンティティが大きい場合のパフォーマンス改善に有効です。"),
                choice("b", "インターフェースプロジェクションはキャストが必要なため実装クラスより遅い", misconception: "プロキシのオーバーヘッドを過大評価",
                       explanation: "Spring DataはインターフェースプロジェクションにJavaプロキシを使いますが、多くの場合パフォーマンスは問題になりません。"),
                choice("c", "インターフェースプロジェクションはネイティブSQLクエリでのみ動作する", misconception: "JPQLとの相性への誤解",
                       explanation: "インターフェースプロジェクションはJPQLベースの命名規則クエリでも動作します。"),
                choice("d", "インターフェースプロジェクションを使うとエンティティのsave()が呼び出せなくなる", misconception: "プロジェクションが書き込み操作を禁止すると誤解",
                       explanation: "プロジェクションは読み取り専用の返り値の型です。リポジトリの他のメソッドに影響しません。")
            ],
            explanationRef: "explain-boot3-jpa-proj-001",
            designIntent: "プロジェクションによるSELECT最適化を理解する。"
        ),
        quiz(
            id: "boot3-jpa-proj-002",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["DTOプロジェクション", "コンストラクタ式", "JPQL"],
            code: """
public record ProductDto(String name, int price) {}

// リポジトリ
@Query("SELECT new com.example.ProductDto(p.name, p.price) FROM Product p WHERE p.category = :cat")
List<ProductDto> findDtoByCategory(@Param("cat") String cat);
""",
            question: "JPQLの `new` 式を使ったDTOプロジェクションについて正しいのはどれか？",
            choices: [
                choice("a", "コンストラクタが呼ばれJPAの管理対象にはならないためダーティチェックが不要", correct: true,
                       explanation: "new式で生成されたオブジェクトはPersistence Contextの管理外です。変更してもUPDATEは発行されず、軽量な読み取り専用DTOとして使えます。"),
                choice("b", "フルパッケージ名は不要でクラス名だけ指定すればよい", misconception: "JPQLではフルパッケージ名が必要",
                       explanation: "JPQLの`new`式ではフルパッケージ名（完全修飾クラス名）が必要です。省略するとクラスが見つかりません。"),
                choice("c", "recordクラスはJPQLのnew式では使えない", misconception: "recordとJPQLの互換性への誤解",
                       explanation: "Javaのrecordは通常のコンストラクタを持つため、JPQLのnew式で使用可能です。"),
                choice("d", "DTOプロジェクションはPageやSliceと組み合わせられない", misconception: "DTOプロジェクションの返り値型への制限を誤解",
                       explanation: "Page<ProductDto>やSlice<ProductDto>も使用可能です。")
            ],
            explanationRef: "explain-boot3-jpa-proj-002",
            designIntent: "DTOプロジェクションの仕組みと管理対象外の利点を理解する。"
        ),
        quiz(
            id: "boot3-jpa-proj-003",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["Spring Data JDBC", "JPA比較", "シンプル"],
            code: """
// Spring Data JDBC の例（JPA ではない）
@Table("products")
public record Product(@Id Long id, String name, int price) {}

public interface ProductRepository extends CrudRepository<Product, Long> {}
""",
            question: "Spring Data JDBCとSpring Data JPAの違いとして正しいのはどれか？",
            choices: [
                choice("a", "Spring Data JDBCにはPersistence ContextやLAZYロードがなく、シンプルなSQLマッピングに特化する", correct: true,
                       explanation: "Spring Data JDBCはJPAの複雑さ（ダーティチェック、LAZYロード、L1キャッシュ）を持ちません。シンプルなCRUDに適しています。"),
                choice("b", "Spring Data JDBCはSpring Data JPAより機能が豊富でN+1問題も自動で解決する", misconception: "JDBCがJPAの上位互換と誤解",
                       explanation: "Spring Data JDBCはシンプルさが売りです。JPAほど高機能ではなく、N+1の自動解決機能もありません。"),
                choice("c", "Spring Data JDBCはSpring Boot 3.xで非推奨になった", misconception: "Spring Data JDBCが廃止されたと誤解",
                       explanation: "Spring Data JDBCはSpring Boot 3.xでも現役です。シンプルなユースケースで活躍します。"),
                choice("d", "Spring Data JDBCもJPAと同様に @Entity アノテーションが必須", misconception: "@EntityがSpring Data JDBCに必要と誤解",
                       explanation: "Spring Data JDBCは @Entity ではなく @Table を使います（またはクラス名からテーブルを推測）。")
            ],
            explanationRef: "explain-boot3-jpa-proj-003",
            designIntent: "Spring Data JDBCとJPAの使い分けを理解する。"
        ),
    ]

    // MARK: - Group 8: 高度なトピック (4問)
    private static let jpaAdvanced: [Quiz] = [
        quiz(
            id: "boot3-jpa-adv-001",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["ddl-auto", "validate", "Flyway"],
            code: """
# application.yml
spring:
  jpa:
    hibernate:
      ddl-auto: validate
  flyway:
    enabled: true
""",
            question: "本番環境で `ddl-auto: validate` と Flyway を組み合わせる理由として正しいのはどれか？",
            choices: [
                choice("a", "Flywayがマイグレーション後のスキーマをvalidateでエンティティと一致確認し、設定ミスを起動時に検出できる", correct: true,
                       explanation: "Flywayで確実にマイグレーションを実施し、validateでエンティティとDBスキーマの整合性を確認するのが本番推奨の組み合わせです。"),
                choice("b", "`ddl-auto: validate` はFlywayと組み合わせると `create` として動作する", misconception: "validateとcreateを混同",
                       explanation: "validateはDDLを一切実行しません。エンティティとDBスキーマが一致しているか確認するだけです。"),
                choice("c", "Flywayは `ddl-auto: update` と組み合わせるのが最も安全", misconception: "updateがFlywayとの推奨設定と誤解",
                       explanation: "`update` はHibernateが自動でスキーマを変更するため本番では危険です。Flywayを使う場合は `validate` または `none` が推奨です。"),
                choice("d", "`ddl-auto: validate` を本番で使うとSpring起動が2倍以上遅くなる", misconception: "validate処理のコストを過大評価",
                       explanation: "validateは起動時にスキーマ確認を行いますが、通常のアプリで問題になるほど遅くなることはありません。")
            ],
            explanationRef: "explain-boot3-jpa-adv-001",
            designIntent: "本番DBスキーマ管理のベストプラクティスを理解する。"
        ),
        quiz(
            id: "boot3-jpa-adv-002",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["Auditing", "@CreatedDate", "@EnableJpaAuditing"],
            code: """
@Configuration
@EnableJpaAuditing
public class JpaConfig {}

@Entity
@EntityListeners(AuditingEntityListener.class)
public class Article {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;
}
""",
            question: "Spring Data JPAのAuditingについて正しいのはどれか？",
            choices: [
                choice("a", "`@EnableJpaAuditing` を付けないと `@CreatedDate` / `@LastModifiedDate` は自動セットされない", correct: true,
                       explanation: "@EnableJpaAuditingはAuditingの有効化が必要です。忘れるとcreatedAt/updatedAtがnullのままになります。テストでモックが必要なことも注意点です。"),
                choice("b", "`@CreatedDate` は `@PrePersist` より後に呼ばれる", misconception: "AuditingとEntityListenerの実行順を誤解",
                       explanation: "AuditingはEntityListenerとして動作し、@PrePersistと同タイミングで処理されます。順序はいずれもINSERT前です。"),
                choice("c", "`@EnableJpaAuditing` はmain起動クラスに必ず付けなければならない", misconception: "@Configurationクラスへの配置が不可と誤解",
                       explanation: "@EnableJpaAuditingは@Configurationクラスでも起動クラスでも使えます。いずれかのBeanに付いていれば有効です。"),
                choice("d", "Auditingは `@CreatedDate` のみサポートし、更新日時は手動でセットする必要がある", misconception: "@LastModifiedDateが非サポートと誤解",
                       explanation: "@LastModifiedDate、@CreatedBy、@LastModifiedByも含めた4つのアノテーションをサポートします。")
            ],
            explanationRef: "explain-boot3-jpa-adv-002",
            designIntent: "JPA Auditingの設定と使い方を理解する。"
        ),
        quiz(
            id: "boot3-jpa-adv-003",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@Lock", "PESSIMISTIC_WRITE", "SELECT FOR UPDATE"],
            code: """
public interface ProductRepository extends JpaRepository<Product, Long> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT p FROM Product p WHERE p.id = :id")
    Optional<Product> findByIdForUpdate(@Param("id") Long id);
}
""",
            question: "`PESSIMISTIC_WRITE` を使うべき状況として正しいのはどれか？",
            choices: [
                choice("a", "在庫の減算など同一レコードへの同時更新が多く、楽観ロックで競合が頻発するシナリオ", correct: true,
                       explanation: "楽観ロックはリトライが前提ですが、競合が多い場合はリトライコストが増大します。悲観ロック（SELECT FOR UPDATE）はロックを取得して排他的に処理するため競合が多い場面で有効です。"),
                choice("b", "読み取り専用のレポート集計クエリを並列実行する場合", misconception: "悲観ロックが読み取りの並列性を上げると誤解",
                       explanation: "PESSIMISTIC_WRITEはSELECT FOR UPDATEで他のトランザクションの読み取りもブロックします。読み取り専用には不適切です。"),
                choice("c", "楽観ロックより悲観ロックの方が常に安全でパフォーマンスが高い", misconception: "悲観ロックが常に最善と誤解",
                       explanation: "悲観ロックはデッドロックのリスクとスループット低下があります。競合が少ない場合は楽観ロックの方が効率的です。"),
                choice("d", "`PESSIMISTIC_WRITE` はSpring Boot 3.x以降で廃止された", misconception: "非推奨・廃止という誤情報",
                       explanation: "PESSIMISTIC_WRITEはJPA標準の機能として継続して使用可能です。")
            ],
            explanationRef: "explain-boot3-jpa-adv-003",
            designIntent: "悲観ロックの適切な使いどころを理解する。"
        ),
        quiz(
            id: "boot3-jpa-adv-004",
            level: .practice,
            objective: "boot3-foundation-data",
            category: .dataJpa,
            tags: ["@NaturalId", "Hibernate", "キャッシュ"],
            code: """
@Entity
public class Country {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NaturalId
    @Column(unique = true, nullable = false)
    private String isoCode; // 例: "JP", "US"
}

// 検索
session.byNaturalId(Country.class)
       .using("isoCode", "JP")
       .load();
""",
            question: "`@NaturalId` を使う利点として正しいのはどれか？",
            choices: [
                choice("a", "自然キー（isoCodeなど）での検索がHibernateの二次キャッシュと連携し、DBアクセスを削減できる", correct: true,
                       explanation: "@NaturalIdはHibernate固有のアノテーションで、自然キーを明示的に宣言します。二次キャッシュを有効にすると自然キーからIDへのマッピングもキャッシュされます。"),
                choice("b", "`@NaturalId` は主キーの代わりに使うものでDBには主キーカラムが不要になる", misconception: "@NaturalIdが主キー代替になると誤解",
                       explanation: "@NaturalIdはサロゲートキー（id）に加えて自然キーを定義するものです。主キー自体は必要です。"),
                choice("c", "`@NaturalId` を付けるとJPAの `findById()` が自動で `isoCode` を使うようになる", misconception: "@NaturalIdが既存メソッドの挙動を変えると誤解",
                       explanation: "`findById()` はサロゲートキーを使います。自然キーでの検索は`byNaturalId()`または専用メソッドで行います。"),
                choice("d", "`@NaturalId` はSpring Data JPAの標準アノテーションでHibernate非依存", misconception: "HibernateとJPA標準の区別が不明確",
                       explanation: "@NaturalIdはHibernate固有のアノテーションです（javax.persistence／jakarta.persistenceではありません）。Hibernate依存コードになることを意識する必要があります。")
            ],
            explanationRef: "explain-boot3-jpa-adv-004",
            designIntent: "自然キーと@NaturalIdの活用を理解する。"
        ),
    ]
}
