import Foundation

/// Spring Bootを学ぶ前に押さえておきたいJavaの基礎と、
/// Spring Bootそのものの入り口を扱う橋渡しレッスン群。
/// 「Java基礎 → Spring Boot基礎」の階段を作ることが目的で、
/// Java全般を網羅する教材ではない。
extension Lesson {
    static let javaPrerequisiteLessons: [Lesson] = [
        javaClassesAndInstances,
        javaMethods,
        javaStaticVsInstance,
        javaInterfaces,
        javaListAndMap,
        javaExceptionHandling,
        javaAnnotations,
        springBootOverview,
        controllerOverview,
        serviceRepositoryOverview
    ]

    private static let javaClassesAndInstances = Lesson(
        id: "lesson-java-class-instance",
        level: .foundation,
        category: QuizCategory.javaBasics.rawValue,
        title: "Javaのクラスとインスタンス",
        summary: "クラスは設計図、インスタンスはそこから作られる実体",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "クラスとインスタンスの違い",
                body: "クラスは「設計図」、インスタンスは設計図から `new` で作られる実際の「モノ」です。同じクラスから複数のインスタンスを作ることができ、それぞれが独立した状態を持ちます。",
                code: """
public class User {
    String name;
    int age;
}

User user1 = new User();
user1.name = "Taro";

User user2 = new User();
user2.name = "Hanako";
""",
                highlightLines: [6, 9],
                callout: Callout(kind: .tip, text: "同じ User クラスから作っても、user1 と user2 はそれぞれ別のデータを持ちます。")
            ),
            Section(
                id: "s2",
                heading: "フィールドはインスタンスごとの状態",
                body: "クラスの中に書く変数を「フィールド」と呼びます。フィールドはインスタンスごとの状態（データ）を保持します。Spring Bootの `@Entity` クラスも、根本はこの仕組みの上に成り立っています。",
                code: nil,
                highlightLines: [],
                callout: nil
            )
        ],
        keyPoints: [
            "クラスは設計図、インスタンスはそこから作られる実体",
            "newキーワードでインスタンスを生成する",
            "インスタンスごとに独立したフィールドの値を持つ"
        ],
        relatedQuizIds: []
    )

    private static let javaMethods = Lesson(
        id: "lesson-java-methods",
        level: .foundation,
        category: QuizCategory.javaBasics.rawValue,
        title: "メソッドと引数・戻り値",
        summary: "メソッドは処理のまとまり。引数で値を受け取り、戻り値で結果を返す",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "メソッドの基本形",
                body: "メソッドは「処理をひとまとめにしたもの」です。`戻り値の型 メソッド名(引数の型 引数名)` という形で定義し、呼び出し側は丸カッコの中に値を渡します。",
                code: """
public int add(int a, int b) {
    return a + b;
}

int result = add(3, 5); // result は 8
""",
                highlightLines: [1, 2],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "戻り値がない場合は void",
                body: "値を返す必要がないメソッドは戻り値の型を `void` にします。Spring BootのControllerメソッドも、保存処理だけを行って何も返さない場合は `void` を使うことがあります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .note, text: "引数や戻り値の型を意識すると、メソッド呼び出しのエラーが読みやすくなります。")
            )
        ],
        keyPoints: [
            "メソッドは処理のまとまりで、引数を受け取り戻り値を返せる",
            "戻り値が不要なときは void を使う",
            "引数・戻り値の型が合わないとコンパイルエラーになる"
        ],
        relatedQuizIds: []
    )

    private static let javaStaticVsInstance = Lesson(
        id: "lesson-java-static",
        level: .foundation,
        category: QuizCategory.javaBasics.rawValue,
        title: "staticと非static",
        summary: "staticはクラスに属し、非staticはインスタンスに属する",
        estimatedMinutes: 7,
        sections: [
            Section(
                id: "s1",
                heading: "クラスに属するか、インスタンスに属するか",
                body: "`static` が付いたメンバーは「クラスそのもの」に属し、インスタンスを作らなくても `クラス名.メンバー名` で使えます。`static` がないメンバーは、インスタンスごとに別々に存在します。",
                code: """
public class Counter {
    static int total = 0;     // クラスで共有
    int personalCount = 0;    // インスタンスごと

    void increment() {
        total++;
        personalCount++;
    }
}
""",
                highlightLines: [2, 3],
                callout: Callout(kind: .warning, text: "staticなフィールドは全インスタンスで共有されるため、意図せず値が変わってしまうことがあります。")
            ),
            Section(
                id: "s2",
                heading: "Spring Bootではどう関係する？",
                body: "Spring Bootの起動メソッドは `public static void main(String[] args)` のように必ず `static` です。アプリ起動時点ではまだインスタンスが存在しないため、staticなメソッドから処理を始める必要があるのです。",
                code: nil,
                highlightLines: [],
                callout: nil
            )
        ],
        keyPoints: [
            "staticはクラスに属し、インスタンスがなくても使える",
            "非staticなメンバーはインスタンスごとに独立する",
            "mainメソッドがstaticなのは起動時にインスタンスが存在しないため"
        ],
        relatedQuizIds: []
    )

    private static let javaInterfaces = Lesson(
        id: "lesson-java-interface",
        level: .foundation,
        category: QuizCategory.javaBasics.rawValue,
        title: "interfaceとは",
        summary: "interfaceは「やるべきこと」だけを決める約束事",
        estimatedMinutes: 7,
        sections: [
            Section(
                id: "s1",
                heading: "実装を持たない約束事",
                body: "`interface` は「このメソッドを持っていること」を約束する型です。具体的な処理内容は書かず、実装するクラス側が `implements` して中身を埋めます。",
                code: """
public interface NotificationSender {
    void send(String message);
}

public class EmailSender implements NotificationSender {
    public void send(String message) {
        System.out.println("メール送信: " + message);
    }
}
""",
                highlightLines: [1, 5],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "差し替えやすさがメリット",
                body: "interfaceを介して呼び出すコードは、実装クラスが何であるかを気にしません。これにより、後から実装を差し替えたり、テスト用のダミーに置き換えたりしやすくなります。Spring BootのDIは、この性質を活用しています。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "interfaceを意識すると、SpringのRepositoryやServiceの設計意図が理解しやすくなります。")
            )
        ],
        keyPoints: [
            "interfaceはメソッドの約束事だけを定義する型",
            "implementsした実装クラスが中身を埋める",
            "実装の差し替えやテストがしやすくなる"
        ],
        relatedQuizIds: []
    )

    private static let javaListAndMap = Lesson(
        id: "lesson-java-list-map",
        level: .foundation,
        category: QuizCategory.javaBasics.rawValue,
        title: "List / Mapの基本",
        summary: "複数の値をまとめて扱うための代表的なコレクション",
        estimatedMinutes: 7,
        sections: [
            Section(
                id: "s1",
                heading: "Listは順序付きの集まり",
                body: "`List` は値を順番に並べて保持するコレクションです。`add` で追加し、`get(index)` で取り出します。",
                code: """
List<String> names = new ArrayList<>();
names.add("Taro");
names.add("Hanako");

String first = names.get(0); // "Taro"
""",
                highlightLines: [1, 2, 3],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "Mapはキーと値のペア",
                body: "`Map` はキーと値のペアを保持します。キーを指定して値を取り出すため、IDから対応するデータを探すような場面でよく使われます。Spring Data JPAで取得した一覧を `List<Entity>` として受け取ることも多くあります。",
                code: """
Map<String, Integer> scoreByName = new HashMap<>();
scoreByName.put("Taro", 90);
int taroScore = scoreByName.get("Taro"); // 90
""",
                highlightLines: [],
                callout: nil
            )
        ],
        keyPoints: [
            "Listは順序付きでindexから値を取り出せる",
            "Mapはキーと値のペアで管理し、キーから値を検索する",
            "Spring BootのAPIでもList/Mapは戻り値としてよく使われる"
        ],
        relatedQuizIds: []
    )

    private static let javaExceptionHandling = Lesson(
        id: "lesson-java-exceptions",
        level: .foundation,
        category: QuizCategory.javaBasics.rawValue,
        title: "例外処理",
        summary: "想定外の事態をtry-catchで受け止めて適切に対応する",
        estimatedMinutes: 7,
        sections: [
            Section(
                id: "s1",
                heading: "try-catchの基本",
                body: "プログラム実行中に問題が起きると「例外」が発生します。`try` ブロックで処理を試み、問題が起きたときの対応を `catch` ブロックに書きます。",
                code: """
try {
    int result = 10 / number;
    System.out.println(result);
} catch (ArithmeticException e) {
    System.out.println("0では割れません: " + e.getMessage());
}
""",
                highlightLines: [1, 4],
                callout: Callout(kind: .warning, text: "例外を握りつぶして何もしないcatchは、問題の発見を遅らせる原因になります。")
            ),
            Section(
                id: "s2",
                heading: "Spring Bootでの扱われ方",
                body: "Spring Bootでは、Controllerで発生した例外を `@ExceptionHandler` や `@ControllerAdvice` でまとめて受け取り、わかりやすいエラーレスポンスに変換することがよくあります。",
                code: nil,
                highlightLines: [],
                callout: nil
            )
        ],
        keyPoints: [
            "例外はtryで試し、catchで受け止めて対応する",
            "catchブロックでは原因を握りつぶさず適切に扱う",
            "Spring Bootは例外を共通処理でレスポンスに変換できる"
        ],
        relatedQuizIds: []
    )

    private static let javaAnnotations = Lesson(
        id: "lesson-java-annotations",
        level: .foundation,
        category: QuizCategory.javaBasics.rawValue,
        title: "アノテーションとは",
        summary: "コードに「目印」を付けて、フレームワークに意図を伝える仕組み",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "@で始まる目印",
                body: "`@` で始まる記述を「アノテーション」と呼びます。アノテーション自体がコードの動作を直接変えるわけではなく、「このクラス・メソッドはこういう役割を持つ」という目印をコンパイラやフレームワークに伝えるものです。",
                code: """
@Override
public String toString() {
    return "User";
}
""",
                highlightLines: [1],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "Spring Bootは特にアノテーションを多用する",
                body: "`@SpringBootApplication`、`@RestController`、`@Autowired` など、Spring Bootの機能の多くはアノテーションを目印として動作します。アノテーションの意味を1つずつ理解することが、Spring Boot学習の近道になります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "わからないアノテーションが出てきたら「これは何の目印だろう？」と考えると理解しやすくなります。")
            )
        ],
        keyPoints: [
            "アノテーションは@で始まるコードへの目印",
            "それ自体が処理を行うのではなく、フレームワークに意図を伝える",
            "Spring Bootはアノテーションを軸に動作する場面が多い"
        ],
        relatedQuizIds: []
    )

    private static let springBootOverview = Lesson(
        id: "lesson-java-spring-boot-overview",
        level: .foundation,
        category: QuizCategory.bootBasics.rawValue,
        title: "Spring Bootとは",
        summary: "Javaで作るWebアプリの土台を素早く用意できるフレームワーク",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "「土台」を用意してくれる仕組み",
                body: "Spring Bootは、Webアプリを作るときに必要な設定や仕組みをあらかじめ用意してくれるフレームワークです。サーバーの起動やルーティング、データベース接続といった「土台」の部分を素早く整えられます。",
                code: """
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
""",
                highlightLines: [1],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "アノテーションで役割を伝える",
                body: "クラスに `@RestController` と書けばAPIの入り口になり、`@Service` と書けば業務処理を担うクラスになります。これらは前章で学んだ「アノテーション」が、Spring Bootの中で実際に使われている例です。",
                code: nil,
                highlightLines: [],
                callout: nil
            )
        ],
        keyPoints: [
            "Spring BootはWebアプリの土台を素早く整えるフレームワーク",
            "アノテーションでクラスの役割をフレームワークに伝える",
            "細かい設定の多くを自動化してくれる"
        ],
        relatedQuizIds: []
    )

    private static let controllerOverview = Lesson(
        id: "lesson-java-controller-overview",
        level: .foundation,
        category: QuizCategory.webMvc.rawValue,
        title: "Controllerとは",
        summary: "リクエストを最初に受け取り、処理の流れを組み立てる入り口",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "リクエストの入り口",
                body: "`Controller` は、外部からのリクエスト（URLへのアクセス）を最初に受け取るクラスです。受け取った内容をもとに必要な処理を呼び出し、結果をレスポンスとして返します。",
                code: """
@RestController
public class UserController {

    @GetMapping("/users/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }
}
""",
                highlightLines: [1, 4],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "「受付窓口」のような役割",
                body: "Controllerは処理の中身そのものを担当するわけではありません。実際の業務処理は次に紹介する `Service` に任せ、Controllerは「受付窓口」としてリクエストとレスポンスの橋渡しに専念します。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .note, text: "Controllerにビジネスロジックを全て詰め込んでしまうと見通しが悪くなるため、役割分担が大切です。")
            )
        ],
        keyPoints: [
            "Controllerはリクエストを最初に受け取る入り口",
            "URLとメソッドを@GetMapping等のアノテーションで結びつける",
            "実際の処理はServiceに任せ、橋渡しに専念する"
        ],
        relatedQuizIds: []
    )

    private static let serviceRepositoryOverview = Lesson(
        id: "lesson-java-service-repository-overview",
        level: .foundation,
        category: QuizCategory.architecture.rawValue,
        title: "Service / Repositoryとは",
        summary: "業務処理とデータアクセスを役割ごとに分けるレイヤー構造",
        estimatedMinutes: 7,
        sections: [
            Section(
                id: "s1",
                heading: "Serviceは業務処理を担当",
                body: "`Service` は、アプリケーションの業務ロジック（やるべき処理の組み立て）を担当するクラスです。Controllerから呼び出され、必要に応じてRepositoryを使ってデータを取得・保存します。",
                code: """
@Service
public class UserService {
    private final UserRepository repository;

    UserService(UserRepository repository) {
        this.repository = repository;
    }

    public User findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));
    }
}
""",
                highlightLines: [1, 9],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "Repositoryはデータアクセスを担当",
                body: "`Repository` は、データベースとのやり取り（保存・検索など）を担当します。Controller → Service → Repositoryという流れで処理が進むことで、それぞれのクラスが「自分の役割」に集中できます。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "値がどのクラスからどのクラスへ渡っていくのかを意識すると、Spring Bootのコードが読みやすくなります。")
            )
        ],
        keyPoints: [
            "Serviceは業務処理の組み立てを担当する",
            "Repositoryはデータベースとのやり取りを担当する",
            "Controller→Service→Repositoryの流れで役割が分かれる"
        ],
        relatedQuizIds: []
    )
}
