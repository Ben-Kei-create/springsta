import Foundation

/// Java基礎レッスンの次に置く「Spring Boot基礎」の橋渡しレッスン群。
/// Controller / Service / Repository / Entity の役割分担と、
/// Web MVC・JPA・Validation・テストの最初の一歩を扱う。
extension Lesson {
    static let springBootFoundationLessons: [Lesson] = [
        springFoundationOverview,
        springControllerMinimum,
        springGetMappingURL,
        springRequestParam,
        springPathVariable,
        springModelThymeleaf,
        springFormPost,
        springServiceLayer,
        springRepositoryLayer,
        springEntityBasics,
        springJpaFetch,
        springValidationBasics,
        springErrorReadingBasics,
        springMockMvcBasics,
        springCrudFlow
    ]

    private static let springFoundationOverview = Lesson(
        id: "lesson-spring-foundation-overview",
        level: .foundation,
        category: QuizCategory.bootBasics.rawValue,
        title: "Spring Bootアプリの全体像",
        summary: "Controller・Service・Repository・Entityがどう連携するかを最初に押さえる",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "Spring Bootは何をしてくれる？",
                body: "Spring Bootは、Webアプリを作るときに必要な「サーバーを起動する」「リクエストを受け取る」「データベースとやり取りする」といった土台を素早く整えてくれるフレームワークです。開発者はアプリ独自の処理に集中できます。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "4つの代表的な役割",
                body: "典型的なSpring Bootアプリは、Controller（受付窓口）・Service（業務処理）・Repository（データアクセス）・Entity（データの形）という4つの役割に分かれて協力します。",
                code: """
@RestController
class UserController { }

@Service
class UserService { }

@Repository
interface UserRepository extends JpaRepository<User, Long> { }

@Entity
class User { }
""",
                highlightLines: [1, 4, 7, 10],
                callout: Callout(kind: .tip, text: "この4つの役割の流れを意識すると、知らないコードを読むときも迷いにくくなります。")
            )
        ],
        keyPoints: [
            "Spring BootはWebアプリの土台を素早く整えるフレームワーク",
            "Controller・Service・Repository・Entityがそれぞれ役割を分担する",
            "リクエストはController→Service→Repositoryの順に流れる",
            "Entityはデータベースのテーブルに対応するデータの形"
        ],
        relatedQuizIds: []
    )

    private static let springControllerMinimum = Lesson(
        id: "lesson-spring-controller-minimum",
        level: .foundation,
        category: QuizCategory.webMvc.rawValue,
        title: "最小のControllerを作る",
        summary: "@Controller / @RestControllerと@GetMappingで最初の画面・APIを作る",
        estimatedMinutes: 5,
        sections: [
            Section(
                id: "s1",
                heading: "@Controllerと@RestControllerの違い",
                body: "`@Controller` はHTML画面（View）を返すクラスに、`@RestController` はJSONなどのデータをそのまま返すクラスに使います。`@RestController` は `@Controller` と `@ResponseBody` を組み合わせたものです。",
                code: """
@RestController
public class HelloController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello, Spring Boot!";
    }
}
""",
                highlightLines: [1, 4],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "画面を返す場合はView名を返す",
                body: "`@Controller` を使う場合、メソッドの戻り値は表示したい画面（View）の名前として扱われます。例えば `\"home\"` を返すと、`home.html` のようなテンプレートが探されます。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .note, text: "@RestControllerはAPI、@Controllerは画面表示、とまず大まかに覚えておくと混乱しません。")
            )
        ],
        keyPoints: [
            "@RestControllerはデータをそのまま返すControllerに使う",
            "@ControllerはHTML画面（View）を返すControllerに使う",
            "@GetMappingでURLとメソッドを結びつける",
            "戻り値の扱いはアノテーションによって変わる"
        ],
        relatedQuizIds: []
    )

    private static let springGetMappingURL = Lesson(
        id: "lesson-spring-getmapping-url",
        level: .foundation,
        category: QuizCategory.webMvc.rawValue,
        title: "URLと@GetMapping",
        summary: "URLパスとハンドラーメソッドがどう結びつくかを理解する",
        estimatedMinutes: 5,
        sections: [
            Section(
                id: "s1",
                heading: "1つのURLに1つのメソッド",
                body: "`@GetMapping(\"/path\")` を付けたメソッドは、そのURLへのGETリクエストを処理します。Controllerクラスの中に複数のメソッドを置き、それぞれ別のURLに対応させることができます。",
                code: """
@RestController
public class ItemController {

    @GetMapping("/items")
    public String list() {
        return "item list";
    }

    @GetMapping("/items/popular")
    public String popular() {
        return "popular items";
    }
}
""",
                highlightLines: [4, 9],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "URLの設計はわかりやすさが大切",
                body: "似たURLが増えてくると、どのメソッドがどのURLに対応するか追いにくくなります。`/items` は一覧、`/items/popular` は人気商品、のように意味のあるパスを設計すると、後から読むときにも理解しやすくなります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "迷ったときは「このURLにアクセスしたら何が返ってきてほしいか」から考えると設計しやすくなります。")
            )
        ],
        keyPoints: [
            "@GetMapping(\"/path\")はそのURLへのGETリクエストを処理する",
            "1つのControllerクラスに複数のURLを対応させられる",
            "URL設計はアクセスした人にとっての分かりやすさを意識する"
        ],
        relatedQuizIds: []
    )

    private static let springRequestParam = Lesson(
        id: "lesson-spring-request-param",
        level: .foundation,
        category: QuizCategory.webMvc.rawValue,
        title: "@RequestParamの基本",
        summary: "クエリ文字列（?id=1）の値をメソッドの引数として受け取る",
        estimatedMinutes: 5,
        sections: [
            Section(
                id: "s1",
                heading: "?以降の値を受け取る",
                body: "`/items?id=1` のような `?` 以降の部分を「クエリ文字列」と呼びます。`@RequestParam` を使うと、このクエリ文字列の値をメソッドの引数として受け取れます。",
                code: """
@GetMapping("/items")
public String findItem(@RequestParam String id) {
    return "id = " + id;
}
// /items?id=1 にアクセスすると id には "1" が入る
""",
                highlightLines: [2],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "型の指定とdefaultValue",
                body: "`@RequestParam Integer page` のように型を指定すれば、数値として受け取ることもできます。また `@RequestParam(defaultValue = \"0\") Integer page` と書けば、パラメータが省略されたときの初期値も指定できます。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .note, text: "クエリ文字列は常に文字列として届くため、数値として扱いたい場合は型変換に失敗しないか意識しておくと安心です。")
            )
        ],
        keyPoints: [
            "@RequestParamはURLの?以降のクエリ文字列を受け取る",
            "引数の型を指定して数値などとして受け取れる",
            "defaultValueでパラメータ省略時の初期値を指定できる"
        ],
        relatedQuizIds: []
    )

    private static let springPathVariable = Lesson(
        id: "lesson-spring-path-variable",
        level: .foundation,
        category: QuizCategory.webMvc.rawValue,
        title: "@PathVariableの基本",
        summary: "URLの一部に埋め込まれた値（/items/1）を受け取る",
        estimatedMinutes: 5,
        sections: [
            Section(
                id: "s1",
                heading: "URLの一部を変数として扱う",
                body: "`/items/1` のようにURLの一部に値が埋め込まれている場合、`@PathVariable` を使ってその値を受け取ります。`{}` で囲んだ部分がプレースホルダーになります。",
                code: """
@GetMapping("/items/{id}")
public String findItem(@PathVariable Long id) {
    return "id = " + id;
}
// /items/1 にアクセスすると id には 1 が入る
""",
                highlightLines: [1, 2],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "@RequestParamとの使い分け",
                body: "「特定の1件を指すURL」には `@PathVariable`（例: `/items/1`）、「検索条件のように省略可能な値」には `@RequestParam`（例: `/items?keyword=spring`）が向いています。どちらもよく使うため、URLの形を見て判断できるようにしておくと読みやすくなります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "URLに「/数字」が含まれていたら@PathVariable、「?キー=値」が含まれていたら@RequestParam、と覚えておくと判断しやすくなります。")
            )
        ],
        keyPoints: [
            "@PathVariableはURLの一部に埋め込まれた値を受け取る",
            "{}で囲んだ部分がプレースホルダーになる",
            "1件を指す場合はPathVariable、条件指定はRequestParamが向いている"
        ],
        relatedQuizIds: []
    )

    private static let springModelThymeleaf = Lesson(
        id: "lesson-spring-model-thymeleaf",
        level: .foundation,
        category: QuizCategory.webMvc.rawValue,
        title: "ModelとThymeleaf",
        summary: "ControllerからViewへ値を渡し、HTML上に表示する仕組み",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "Modelに値を詰めてViewへ渡す",
                body: "`Model` は、ControllerからView（HTML）へ値を渡すための入れ物です。`model.addAttribute(\"name\", \"value\")` のように名前を付けて値を登録すると、View側でその名前を使って値を参照できます。",
                code: """
@GetMapping("/greeting")
public String greeting(Model model) {
    model.addAttribute("userName", "Taro");
    return "greeting"; // greeting.html を表示
}
""",
                highlightLines: [3],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "th:textでHTMLに値を表示する",
                body: "Thymeleafは、HTMLの中にJavaの値を埋め込むためのテンプレートエンジンです。`th:text` 属性を使うと、Modelに登録した値をHTML要素のテキストとして表示できます。",
                code: """
<p th:text="${userName}">ここに名前が入る</p>
""",
                highlightLines: [],
                callout: Callout(kind: .note, text: "th:textで指定した値が、画面表示時に実際の値で置き換えられます。")
            )
        ],
        keyPoints: [
            "Modelはコントローラーからビューへ値を渡す入れ物",
            "model.addAttributeで名前付きの値を登録する",
            "th:textでHTML上にJavaの値を表示できる"
        ],
        relatedQuizIds: []
    )

    private static let springFormPost = Lesson(
        id: "lesson-spring-form-post",
        level: .foundation,
        category: QuizCategory.webMvc.rawValue,
        title: "フォーム送信とPOST",
        summary: "登録・更新の操作にPOSTを使う理由とフォーム送信の流れ",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "フォームのactionとmethod",
                body: "HTMLフォームは `action` で送信先のURL、`method` で送信方法（GETかPOSTか）を指定します。新規登録や更新のような「サーバー側の状態を変える」操作には、一般的に `POST` を使います。",
                code: """
<form action="/items" method="post">
    <input type="text" name="itemName">
    <button type="submit">登録</button>
</form>
""",
                highlightLines: [1],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "@PostMappingで受け取る",
                body: "サーバー側では `@PostMapping` を付けたメソッドが、フォームから送信された値を受け取ります。GETは「データを取得するだけ」、POSTは「データを送って状態を変える」という役割の違いを意識すると、設計の意図が読み取りやすくなります。",
                code: """
@PostMapping("/items")
public String register(@RequestParam String itemName) {
    // 登録処理
    return "redirect:/items";
}
""",
                highlightLines: [],
                callout: Callout(kind: .warning, text: "登録・更新のような操作にGETを使ってしまうと、リンクを開いただけでデータが変わってしまう恐れがあります。")
            )
        ],
        keyPoints: [
            "formのactionとmethodで送信先と送信方法を指定する",
            "登録・更新などの操作には一般的にPOSTを使う",
            "@PostMappingでフォーム送信を受け取って処理する",
            "GETとPOSTの役割の違いを意識すると設計が読み取りやすくなる"
        ],
        relatedQuizIds: []
    )

    private static let springServiceLayer = Lesson(
        id: "lesson-spring-service-layer",
        level: .foundation,
        category: QuizCategory.architecture.rawValue,
        title: "Service層とは",
        summary: "Controllerに業務ロジックを詰め込みすぎず、Serviceに任せる",
        estimatedMinutes: 5,
        sections: [
            Section(
                id: "s1",
                heading: "業務ロジックの置き場所",
                body: "「在庫が0でないか確認してから注文を確定する」「ポイントを計算して加算する」といった、アプリ独自の判断や計算を「業務ロジック」と呼びます。これをControllerに直接書いてしまうと、Controllerが肥大化し見通しが悪くなります。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "Serviceに任せて役割を分ける",
                body: "業務ロジックは `@Service` を付けたクラスにまとめます。Controllerは受け取った値をServiceに渡し、結果を受け取ってレスポンスを組み立てるだけに専念できます。",
                code: """
@Service
public class OrderService {
    public Order placeOrder(Long itemId, int quantity) {
        // 在庫確認や金額計算などの業務ロジック
        return new Order(itemId, quantity);
    }
}
""",
                highlightLines: [1],
                callout: Callout(kind: .tip, text: "「このクラスは何の役割を持つか」を意識すると、コードがどんどん読みやすくなります。")
            )
        ],
        keyPoints: [
            "業務ロジックはアプリ独自の判断・計算処理のこと",
            "Controllerに業務ロジックを詰め込みすぎると見通しが悪くなる",
            "@Serviceを付けたクラスに業務ロジックをまとめる",
            "ControllerはServiceとのやり取りに専念できる"
        ],
        relatedQuizIds: []
    )

    private static let springRepositoryLayer = Lesson(
        id: "lesson-spring-repository-layer",
        level: .foundation,
        category: QuizCategory.dataJpa.rawValue,
        title: "Repository層とは",
        summary: "データベースとのやり取りを専門に担当する層",
        estimatedMinutes: 5,
        sections: [
            Section(
                id: "s1",
                heading: "データベースへの窓口",
                body: "`Repository` は、データの保存・検索・更新・削除といった、データベースとのやり取りを専門に担当します。Serviceは「何をすべきか」を考え、Repositoryは「データをどう出し入れするか」を担当する、という役割分担です。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "JpaRepositoryを継承するだけで使える",
                body: "Spring Data JPAでは、`JpaRepository` を継承したinterfaceを定義するだけで、`save`、`findAll`、`findById` といった基本的なデータ操作が自動的に使えるようになります。",
                code: """
public interface ItemRepository extends JpaRepository<Item, Long> {
}

// 使う側
List<Item> items = itemRepository.findAll();
""",
                highlightLines: [1],
                callout: Callout(kind: .note, text: "interfaceなのに中身が空なのは奇妙に見えますが、JpaRepositoryがすでに必要なメソッドを用意してくれているためです。")
            )
        ],
        keyPoints: [
            "Repositoryはデータベースとのやり取りを専門に担当する",
            "JpaRepositoryを継承するだけで基本的なデータ操作が使える",
            "Serviceは判断、Repositoryはデータの出し入れという役割分担がある"
        ],
        relatedQuizIds: []
    )

    private static let springEntityBasics = Lesson(
        id: "lesson-spring-entity-basics",
        level: .foundation,
        category: QuizCategory.dataJpa.rawValue,
        title: "Entityとは",
        summary: "@Entityと@Idで、Javaのクラスとデータベースのテーブルを対応づける",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "クラスとテーブルを対応づける",
                body: "`@Entity` を付けたクラスは、データベースのテーブルに対応する「データの形」を表します。クラスのフィールドがテーブルの列（カラム）に対応し、インスタンス1つがテーブルの1行（レコード）に対応します。",
                code: """
@Entity
public class Item {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private int price;
}
""",
                highlightLines: [1, 4],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "@Idは主キーの目印",
                body: "`@Id` は、そのフィールドがテーブルの主キー（行を一意に識別する値）であることを示すアノテーションです。`@GeneratedValue` を一緒に付けると、IDの値をデータベース側で自動生成してもらえます。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "Entityは「Javaのクラスとデータベースのテーブルをつなぐ翻訳係」とイメージすると理解しやすくなります。")
            )
        ],
        keyPoints: [
            "@Entityを付けたクラスはデータベースのテーブルに対応する",
            "クラスのフィールドがテーブルの列に対応する",
            "@Idは主キーであることを示すアノテーション",
            "@GeneratedValueでID値の自動生成を任せられる"
        ],
        relatedQuizIds: []
    )

    private static let springJpaFetch = Lesson(
        id: "lesson-spring-jpa-fetch",
        level: .foundation,
        category: QuizCategory.dataJpa.rawValue,
        title: "JPAでデータを取得する",
        summary: "findAll・findByIdとOptionalの基本的な使い方",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "findAllとfindById",
                body: "`JpaRepository` には、すべてのデータを取得する `findAll`、IDを指定して1件取得する `findById` といったメソッドが標準で用意されています。",
                code: """
List<Item> items = itemRepository.findAll();

Optional<Item> found = itemRepository.findById(1L);
""",
                highlightLines: [1, 3],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "Optionalは「あるかもしれないし、ないかもしれない」",
                body: "`findById` の戻り値が `Optional<Item>` になっているのは、「指定したIDのデータが存在しない可能性がある」ことを表すためです。`orElseThrow` を使うと、データが見つからない場合に例外を投げて処理を中断できます。",
                code: """
Item item = itemRepository.findById(1L)
        .orElseThrow(() -> new ItemNotFoundException(1L));
""",
                highlightLines: [],
                callout: Callout(kind: .warning, text: "Optionalの中身を確認せずに直接取り出そうとすると、データが存在しない場合に実行時エラーの原因になります。")
            )
        ],
        keyPoints: [
            "findAllはすべてのデータ、findByIdは1件のデータを取得する",
            "findByIdの戻り値はOptionalで、存在しない可能性を表す",
            "orElseThrowでデータが見つからない場合の処理を書ける"
        ],
        relatedQuizIds: []
    )

    private static let springValidationBasics = Lesson(
        id: "lesson-spring-validation-basics",
        level: .foundation,
        category: QuizCategory.validation.rawValue,
        title: "Validationの基本",
        summary: "@Validと@NotBlankなどで、入力値のチェックを宣言的に行う",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "アノテーションでルールを宣言する",
                body: "`@NotBlank`（空文字でないこと）や `@Email`（メール形式であること）といったアノテーションをフィールドに付けることで、「この値はこうあるべき」というルールを宣言できます。実際のチェックはSpring Bootが代わりに行ってくれます。",
                code: """
public class UserForm {

    @NotBlank
    private String name;

    @Email
    private String email;
}
""",
                highlightLines: [3, 6],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "@ValidでチェックしBindingResultで結果を受け取る",
                body: "Controllerの引数に `@Valid` を付けると、受け取った値に対してバリデーションが実行されます。チェック結果は `BindingResult` で受け取り、エラーがあれば `bindingResult.hasErrors()` で判定して入力画面に戻すなどの対応ができます。",
                code: """
@PostMapping("/users")
public String register(@Valid UserForm form, BindingResult bindingResult) {
    if (bindingResult.hasErrors()) {
        return "userForm";
    }
    // 登録処理
    return "redirect:/users";
}
""",
                highlightLines: [1, 3],
                callout: Callout(kind: .note, text: "バリデーションを使うと、不正な値をチェックする処理を1つずつ手で書かずに済みます。")
            )
        ],
        keyPoints: [
            "@NotBlankや@Emailなどで入力値のルールを宣言できる",
            "@Validを付けるとそのルールに沿ったチェックが実行される",
            "BindingResultでチェック結果を受け取り、エラー時の処理を書く"
        ],
        relatedQuizIds: []
    )

    private static let springErrorReadingBasics = Lesson(
        id: "lesson-spring-error-reading-basics",
        level: .foundation,
        category: QuizCategory.errorReading.rawValue,
        title: "例外とエラー画面の読み方",
        summary: "500エラーやスタックトレースから、原因を読み解く第一歩",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "500エラーは「サーバー側で何かが起きた」サイン",
                body: "画面に「500 Internal Server Error」と表示されたときは、サーバー側の処理中に予期しない問題（例外）が発生したことを意味します。まずは慌てず、ログに出力されたスタックトレース（エラーの詳細情報）を確認します。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "スタックトレースは上から読む",
                body: "スタックトレースには大量の行が表示されますが、まず注目すべきは一番上の行（例外の種類とメッセージ）と、自分が書いたクラス名が登場する行です。フレームワーク内部の行より、自分のコードに関係する行の方が手がかりになることが多いです。",
                code: """
java.lang.NullPointerException: Cannot invoke "String.length()" because "name" is null
    at com.example.demo.UserService.register(UserService.java:21)
    at com.example.demo.UserController.create(UserController.java:15)
""",
                highlightLines: [1, 2],
                callout: Callout(kind: .tip, text: "「何が」「どこで」起きたかをまず特定することが、エラー解決の第一歩です。")
            ),
            Section(
                id: "s3",
                heading: "初心者がつまずきやすい代表例",
                body: "`NullPointerException`（値がnullのまま使おうとした）、`NoSuchElementException`（Optionalの中身がないのに取り出そうとした）などは、特に初心者がよく遭遇する例外です。エラーメッセージに登場するクラス名や行番号は、原因を探す重要な手がかりになります。",
                code: nil,
                highlightLines: [],
                callout: nil
            )
        ],
        keyPoints: [
            "500エラーはサーバー側で例外が発生したサイン",
            "スタックトレースは一番上の行と自分のコードの行に注目する",
            "NullPointerExceptionなど代表的な例外の名前を知っておくと役立つ",
            "エラーメッセージの「何が」「どこで」を特定することから始める"
        ],
        relatedQuizIds: []
    )

    private static let springMockMvcBasics = Lesson(
        id: "lesson-spring-mockmvc-basics",
        level: .foundation,
        category: QuizCategory.testing.rawValue,
        title: "MockMvcテスト入門",
        summary: "実際にサーバーを起動せずにControllerの動作を確認する仕組み",
        estimatedMinutes: 6,
        sections: [
            Section(
                id: "s1",
                heading: "MockMvcは何をテストする？",
                body: "`MockMvc` は、実際にアプリケーションサーバーを起動しなくても、Controllerに対して疑似的にリクエストを送りレスポンスを検証できる仕組みです。「このURLにアクセスしたら、期待通りの結果が返ってくるか」を自動でチェックできます。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "perform・andExpectの基本形",
                body: "`mockMvc.perform(get(\"/items\"))` のように書くと、`/items` へのGETリクエストを疑似的に送信できます。続けて `andExpect(status().isOk())` のように書くことで、「ステータスコードが200（成功）であること」を検証できます。",
                code: """
@Test
void shouldReturnOk() throws Exception {
    mockMvc.perform(get("/items"))
           .andExpect(status().isOk());
}
""",
                highlightLines: [3, 4],
                callout: Callout(kind: .note, text: "テストコードを読むときは「何にアクセスして」「何を期待しているか」の2点に注目すると理解しやすくなります。")
            )
        ],
        keyPoints: [
            "MockMvcはサーバーを起動せずにControllerの動作を検証できる",
            "perform(get(...))で疑似的にリクエストを送信する",
            "andExpect(status().isOk())のように期待する結果を検証する",
            "テストは「何をして」「何を期待するか」で読み解ける"
        ],
        relatedQuizIds: []
    )

    private static let springCrudFlow = Lesson(
        id: "lesson-spring-crud-flow",
        level: .foundation,
        category: QuizCategory.architecture.rawValue,
        title: "小さなCRUDアプリの流れ",
        summary: "一覧・詳細・作成・更新・削除がControllerからEntityまでどう流れるか",
        estimatedMinutes: 7,
        sections: [
            Section(
                id: "s1",
                heading: "CRUDとは",
                body: "Create（作成）・Read（読み取り）・Update（更新）・Delete（削除）の頭文字をとって「CRUD」と呼びます。多くのWebアプリは、形を変えながらもこのCRUDの組み合わせで成り立っています。",
                code: nil,
                highlightLines: [],
                callout: nil
            ),
            Section(
                id: "s2",
                heading: "一覧から詳細、作成までの流れ",
                body: "「一覧画面でアイテムを見る」「詳細画面で1件を確認する」「フォームから新しいアイテムを登録する」という流れでは、Controllerがリクエストを受け取り、Serviceが処理を組み立て、Repositoryがデータベースとやり取りし、Entityとしてデータが受け渡されます。",
                code: """
@GetMapping("/items")
public String list(Model model) {
    model.addAttribute("items", itemService.findAll());
    return "items/list";
}

@PostMapping("/items")
public String create(@Valid ItemForm form, BindingResult result) {
    itemService.register(form);
    return "redirect:/items";
}
""",
                highlightLines: [1, 7],
                callout: nil
            ),
            Section(
                id: "s3",
                heading: "更新・削除も同じ流れの応用",
                body: "更新や削除も基本的には同じ流れの応用です。Controllerが「どのデータに対して、何をするか」を受け取り、Serviceが業務ロジックを実行し、Repositoryがデータベースを更新・削除します。この一連の流れを意識できると、知らないCRUD機能のコードを読むときにも迷わず追いかけられるようになります。",
                code: nil,
                highlightLines: [],
                callout: Callout(kind: .tip, text: "新しいコードを読むときは「これはCRUDのどの操作にあたるか」と考えると、全体の見通しが立てやすくなります。")
            )
        ],
        keyPoints: [
            "CRUDはCreate・Read・Update・Deleteの組み合わせ",
            "Controller→Service→Repository→Entityの流れで処理が進む",
            "更新・削除も基本的には同じ流れの応用として読み解ける",
            "全体の流れを意識すると知らないコードも追いやすくなる"
        ],
        relatedQuizIds: []
    )
}
