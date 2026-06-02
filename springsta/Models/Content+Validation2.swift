import Foundation

extension Quiz {
    static let validation2Quizzes: [Quiz] = (
        val2Groups + val2CrossField + val2Custom + val2MethodLevel + val2Groups2
    ).map { $0.contextualizedForPresentation() }

    // MARK: - Group 1: バリデーショングループ (5問)
    private static let val2Groups: [Quiz] = [
        quiz(
            id: "boot3-val2-group-001",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@Validated", "グループ", "バリデーションインターフェース"],
            code: """
public interface OnCreate {}
public interface OnUpdate {}

public class UserDto {
    @Null(groups = OnCreate.class)
    @NotNull(groups = OnUpdate.class)
    private Long id;

    @NotBlank
    private String name;
}

@PostMapping("/users")
public ResponseEntity<?> create(
        @Validated(OnCreate.class) @RequestBody UserDto dto,
        BindingResult result) { ... }
""",
            question: "`@Validated(OnCreate.class)` を使う目的として正しいのはどれか？",
            choices: [
                choice("a", "OnCreate グループに属する制約のみを実行し、新規作成専用のバリデーションルールを適用するため", correct: true,
                       explanation: "@Validated にグループを指定すると、そのグループに属するアノテーション制約だけが評価されます。OnCreate では id が null であることを強制し、OnUpdate では id が必須になるといった使い分けが可能です。"),
                choice("b", "@Validated(OnCreate.class) は OnCreate インターフェースに定義されたメソッドを呼び出してバリデーションを行う", misconception: "グループをバリデーションロジックの定義場所と誤解",
                       explanation: "グループインターフェースにはメソッドを定義しません。ただのマーカーインターフェースであり、制約アノテーションの groups 属性に指定することでグループを識別します。"),
                choice("c", "@Validated を使うと BindingResult が不要になる", misconception: "@Validated と BindingResult の関係を誤解",
                       explanation: "@Validated を使っても BindingResult でエラーをハンドリングする必要はあります。BindingResult を省略すると MethodArgumentNotValidException がスローされます。"),
                choice("d", "グループを指定しない @NotBlank はどのグループでも実行されない", misconception: "デフォルトグループの挙動を誤解",
                       explanation: "グループを指定しない制約は Default グループに属します。@Validated(OnCreate.class) を使うと Default グループの制約は実行されないため、groups に Default.class も追加する必要があります。")
            ],
            explanationRef: "explain-boot3-val2-group-001",
            designIntent: "バリデーショングループを使ってユースケースごとに異なる制約を適用する方法を理解する。"
        ),
        quiz(
            id: "boot3-val2-group-002",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@GroupSequence", "グループ順序", "ショートサーキット"],
            code: """
public interface Step1 {}
public interface Step2 {}

@GroupSequence({ Step1.class, Step2.class })
public interface OrderedChecks {}

public class OrderDto {
    @NotNull(groups = Step1.class)
    @Min(value = 1, groups = Step2.class)
    private Integer quantity;
}
""",
            question: "`@GroupSequence` の動作として正しいのはどれか？",
            choices: [
                choice("a", "Step1 のバリデーションが失敗すると Step2 のバリデーションは実行されない", correct: true,
                       explanation: "@GroupSequence は定義した順にグループを評価し、前のグループでエラーが発生すると後続グループの検証を中断します。これにより null チェックを先に行い、その後に範囲チェックを行うといった効率的な検証が可能です。"),
                choice("b", "@GroupSequence は全グループのバリデーションを並列実行して結果を集約する", misconception: "シーケンシャルを並列と誤解",
                       explanation: "@GroupSequence は必ず順番に実行します。Step1 が通過してから Step2 が実行されます。並列実行の仕組みはありません。"),
                choice("c", "@GroupSequence に含まれないグループは自動的に無視される", misconception: "シーケンス定義がグローバルに影響すると誤解",
                       explanation: "@GroupSequence は指定したグループの実行順を定義するだけです。含まれないグループへの影響はなく、別途 @Validated でそのグループを指定すれば実行されます。"),
                choice("d", "@GroupSequence は @Validated ではなく @Valid と組み合わせる必要がある", misconception: "@Valid と @Validated の使い分けを誤解",
                       explanation: "@GroupSequence で定義したグループを使う場合は @Validated(OrderedChecks.class) のように指定します。@Valid はグループ指定に対応していません。")
            ],
            explanationRef: "explain-boot3-val2-group-002",
            designIntent: "@GroupSequence によるバリデーションのショートサーキット動作を理解する。"
        ),
        quiz(
            id: "boot3-val2-group-003",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["Create vs Update", "グループ", "DTO設計"],
            code: """
public class ProductDto {
    @Null(groups = OnCreate.class)
    @NotNull(groups = OnUpdate.class)
    private Long id;

    @NotBlank(groups = { OnCreate.class, OnUpdate.class })
    @Size(max = 100, groups = { OnCreate.class, OnUpdate.class })
    private String name;

    @NotNull(groups = OnCreate.class)
    private BigDecimal price;
}
""",
            question: "Create と Update で同じ DTO クラスを使う設計の説明として正しいのはどれか？",
            choices: [
                choice("a", "グループを使えば1つの DTO クラスでユースケースごとに必須/任意の差異を表現でき、クラスの重複を減らせる", correct: true,
                       explanation: "バリデーショングループを活用すると、Create では id が null 必須・price 必須、Update では id が必須・price 任意といった違いを1クラスに収められます。ただしクラスが複雑になるためプロジェクトの規模に応じて DTO 分割も検討すべきです。"),
                choice("b", "OnCreate.class と OnUpdate.class を同時に @Validated に指定することはできない", misconception: "複数グループ指定の不可を誤解",
                       explanation: "@Validated({ OnCreate.class, OnUpdate.class }) のように複数グループを同時に指定することは可能です。ただし意味のある使い方かは設計次第です。"),
                choice("c", "グループを使わずに済むよう Create と Update は必ず別 DTO クラスに分割すべき", misconception: "DTO分割を絶対ルールと誤解",
                       explanation: "どちらのアプローチにも利点があります。グループを使った単一 DTO はコードを集約でき、別DTO は各クラスがシンプルになります。プロジェクトの規模やチームの方針に合わせて選択します。"),
                choice("d", "@Null はフィールドが null のときにバリデーション失敗となる", misconception: "@Null の意味を逆に解釈",
                       explanation: "@Null はフィールドが null であることを要求します。null でない場合に失敗します。id の自動採番が前提の Create 操作では、クライアントが id を送ってきたときにエラーとするために @Null を使います。")
            ],
            explanationRef: "explain-boot3-val2-group-003",
            designIntent: "バリデーショングループを使ったCreate/Update DTO 設計パターンを理解する。"
        ),
        quiz(
            id: "boot3-val2-group-004",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@Validated", "@Valid", "グループ指定の違い"],
            code: """
// パターンA
@PostMapping("/a")
public ResponseEntity<?> methodA(
        @Valid @RequestBody UserDto dto) { ... }

// パターンB
@PostMapping("/b")
public ResponseEntity<?> methodB(
        @Validated(OnCreate.class) @RequestBody UserDto dto) { ... }
""",
            question: "`@Valid` と `@Validated` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "@Valid はグループ指定ができず Default グループのみを評価するが、@Validated はグループを指定できる", correct: true,
                       explanation: "@Valid は Jakarta Bean Validation の標準アノテーションでグループ指定の引数を持ちません。@Validated は Spring 独自のアノテーションでグループを指定でき、メソッドレベルのバリデーション有効化にも使います。"),
                choice("b", "@Valid はコントローラーでのみ使用でき、@Validated はサービス層でのみ使用できる", misconception: "使用可能な場所を誤解",
                       explanation: "@Valid はコントローラーのメソッド引数、@Validated はクラスレベルやメソッドレベルで使います。@Validated はコントローラーでも使えます。"),
                choice("c", "@Validated を使うと BindingResult が自動的に生成されない", misconception: "@Validated がBindingResultに影響すると誤解",
                       explanation: "@Validated を使っても BindingResult を引数に追加すれば同様にエラーを受け取れます。BindingResult の動作に違いはありません。"),
                choice("d", "@Valid を使うとネストされたオブジェクトのバリデーションは行われない", misconception: "@Validのカスケードバリデーションを誤解",
                       explanation: "@Valid はカスケードバリデーションをサポートしています。ネストされたオブジェクトのフィールドに @Valid を付けることで再帰的にバリデーションが実行されます。")
            ],
            explanationRef: "explain-boot3-val2-group-004",
            designIntent: "@Valid と @Validated のグループ指定の違いを理解する。"
        ),
        quiz(
            id: "boot3-val2-group-005",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@Validated", "クラスレベル", "サービスBean"],
            code: """
@Service
@Validated
public class AccountService {

    public AccountDto createAccount(
            @NotNull @Valid AccountDto dto) {
        // ...
    }

    public List<AccountDto> findAll(
            @Min(1) int page,
            @Max(100) int size) {
        // ...
    }
}
""",
            question: "Beanクラスに `@Validated` をクラスレベルで付与する効果として正しいのはどれか？",
            choices: [
                choice("a", "そのBeanのメソッドパラメータと戻り値に対するBeanバリデーションが有効になり、違反時に ConstraintViolationException がスローされる", correct: true,
                       explanation: "クラスレベルの @Validated はSpring AOPを使ってメソッドの引数・戻り値のバリデーションを有効化します。コントローラーの BindingResult ではなく ConstraintViolationException がスローされるため、@ExceptionHandler での処理が必要です。"),
                choice("b", "クラスレベルの @Validated は全メソッドの引数を OnCreate グループで検証する", misconception: "クラスレベル@Validatedとグループ適用を混同",
                       explanation: "クラスレベルの @Validated は特定のグループを指定するわけではなく、メソッドバリデーションAOPを有効化するためのマーカーです。グループを指定する場合は @Validated(OnCreate.class) のようにします。"),
                choice("c", "@Validated をサービスクラスに付けると @Service が不要になる", misconception: "@Validated が @Service を包含すると誤解",
                       explanation: "@Validated はバリデーションAOPを有効化するためのアノテーションです。@Service はそのクラスをSpringのサービス層Beanとして登録するアノテーションであり、両者は別の役割を持っています。"),
                choice("d", "クラスレベルの @Validated は private メソッドにも適用される", misconception: "AOPがprivateメソッドに適用できると誤解",
                       explanation: "SpringのAOPはプロキシベースであるため、private メソッドやfinalクラスには適用されません。@Validated によるメソッドバリデーションも同様にpublicメソッドが対象です。")
            ],
            explanationRef: "explain-boot3-val2-group-005",
            designIntent: "クラスレベル@Validatedによるメソッドバリデーションの仕組みを理解する。"
        )
    ]

    // MARK: - Group 2: クロスフィールドバリデーション (5問)
    private static let val2CrossField: [Quiz] = [
        quiz(
            id: "boot3-val2-cross-001",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@AssertTrue", "クロスフィールド", "メソッドバリデーション"],
            code: """
public class PasswordResetDto {
    @NotBlank
    private String password;

    @NotBlank
    private String passwordConfirm;

    @AssertTrue(message = "パスワードが一致しません")
    public boolean isPasswordMatching() {
        return password != null
            && password.equals(passwordConfirm);
    }
}
""",
            question: "`@AssertTrue` をクラス内のメソッドに付けるクロスフィールドバリデーションの特徴として正しいのはどれか？",
            choices: [
                choice("a", "フィールドをまたいだ検証ロジックをクラス内に記述でき、追加のクラス作成が不要", correct: true,
                       explanation: "@AssertTrue をメソッドに付けると、そのメソッドが true を返す必要があります。複数フィールドを参照するロジックを簡潔に記述でき、専用の ConstraintValidator クラスを作らずに済みます。"),
                choice("b", "@AssertTrue メソッドは private にする必要がある", misconception: "可視性の要件を誤解",
                       explanation: "@AssertTrue を付けるメソッドは public である必要があります。Bean Validationのプロパティアクセスの規約に従い、is で始まるpublicメソッドが対象となります。"),
                choice("c", "@AssertTrue はboolean型フィールドにのみ付けられる", misconception: "@AssertTrueをフィールド専用と誤解",
                       explanation: "@AssertTrue はboolean型のフィールドまたはboolean型を返すメソッドに付けられます。メソッドに付けることでクロスフィールドバリデーションが実現できます。"),
                choice("d", "@AssertTrue メソッド内でフィールドが null の場合は自動的にスキップされる", misconception: "null安全の自動処理を誤解",
                       explanation: "@AssertTrue はメソッドが false を返せばエラーになります。null チェックはメソッド内で明示的に行う必要があります。例のように `password != null &&` と書くのが正しいアプローチです。")
            ],
            explanationRef: "explain-boot3-val2-cross-001",
            designIntent: "@AssertTrueを使ったシンプルなクロスフィールドバリデーションを理解する。"
        ),
        quiz(
            id: "boot3-val2-cross-002",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["ConstraintValidator", "クラスレベル制約", "カスタムアノテーション"],
            code: """
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = DateRangeValidator.class)
public @interface ValidDateRange {
    String message() default "終了日は開始日より後である必要があります";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}

public class DateRangeValidator
        implements ConstraintValidator<ValidDateRange, EventDto> {
    @Override
    public boolean isValid(EventDto dto, ConstraintValidatorContext ctx) {
        if (dto.getStartDate() == null || dto.getEndDate() == null) {
            return true;
        }
        return dto.getEndDate().isAfter(dto.getStartDate());
    }
}
""",
            question: "クラスレベルのカスタム制約アノテーションを使ったクロスフィールドバリデーションの説明として正しいのはどれか？",
            choices: [
                choice("a", "@Target(ElementType.TYPE) でクラスに付与し、ConstraintValidator の型引数に対象クラスを指定することで複数フィールドを検証できる", correct: true,
                       explanation: "クラスレベルの制約では ConstraintValidator<ValidDateRange, EventDto> のように検証対象の型を DTO クラスに指定します。isValid メソッド内でオブジェクト全体を受け取るため、複数フィールドを参照したロジックが書けます。"),
                choice("b", "クラスレベルの ConstraintValidator は Spring Bean として登録できないため @Autowired は使えない", misconception: "ConstraintValidatorへのDI不可を誤解",
                       explanation: "Spring環境では ConstraintValidator を @Component で登録することでDIが使えます。Spring Boot はデフォルトで LocalValidatorFactoryBean を使いており、ConstraintValidator への自動DIをサポートしています。"),
                choice("c", "クラスレベルのエラーはフィールドエラーと同様に BindingResult.getFieldErrors() で取得できる", misconception: "フィールドエラーとオブジェクトエラーを混同",
                       explanation: "クラスレベルの制約違反は BindingResult.getGlobalErrors() で取得します。特定フィールドに紐付かないためオブジェクトエラー（グローバルエラー）として扱われます。"),
                choice("d", "isValid メソッドでフィールドが null のとき false を返すと @NotNull の重複となりエラーが2件発生する", misconception: "nullチェックの二重登録を誤解",
                       explanation: "isValid で null のとき true を返すことが推奨されており、null チェックは専用の @NotNull アノテーションに任せます。これにより責務が分離され、nullの場合にクロスフィールド検証をスキップできます。")
            ],
            explanationRef: "explain-boot3-val2-cross-002",
            designIntent: "クラスレベルのカスタム制約でクロスフィールドバリデーションを実装する方法を理解する。"
        ),
        quiz(
            id: "boot3-val2-cross-003",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["パスワード確認", "クロスフィールド", "ConstraintValidatorContext"],
            code: """
public class PasswordValidator
        implements ConstraintValidator<PasswordMatch, RegisterDto> {

    @Override
    public boolean isValid(RegisterDto dto, ConstraintValidatorContext ctx) {
        if (dto.getPassword() == null) return true;

        boolean matches = dto.getPassword()
                             .equals(dto.getPasswordConfirm());
        if (!matches) {
            ctx.disableDefaultConstraintViolation();
            ctx.buildConstraintViolationWithTemplate(
                    ctx.getDefaultConstraintMessageTemplate())
               .addPropertyNode("passwordConfirm")
               .addConstraintViolation();
        }
        return matches;
    }
}
""",
            question: "`ConstraintValidatorContext` でプロパティノードを指定する目的として正しいのはどれか？",
            choices: [
                choice("a", "エラーを特定のフィールドに紐付けることで、クライアントがどのフィールドにエラーがあるかを特定しやすくなる", correct: true,
                       explanation: "デフォルトではクラスレベルの制約違反はオブジェクトエラーになります。addPropertyNode(\"passwordConfirm\") とすることでエラーを passwordConfirm フィールドに紐付け、フロントエンドが該当入力欄にエラーを表示しやすくなります。"),
                choice("b", "addPropertyNode を呼ぶとそのフィールドの @NotBlank バリデーションが自動的にスキップされる", misconception: "プロパティノード指定が他のバリデーションに影響すると誤解",
                       explanation: "addPropertyNode はエラーメッセージの紐付け先を指定するだけです。他のバリデーションアノテーションの動作には影響しません。"),
                choice("c", "disableDefaultConstraintViolation を呼ばないとエラーが2件発生する", misconception: "デフォルト制約違反の扱いを正確に理解していない",
                       explanation: "disableDefaultConstraintViolation を呼ばずに buildConstraintViolationWithTemplate を追加すると、デフォルト（クラスレベル）とプロパティレベルの2件のエラーが発生します。1件にまとめるために disableDefaultConstraintViolation が必要です。"),
                choice("d", "ConstraintValidatorContext は各 isValid 呼び出しでシングルトンインスタンスが再利用される", misconception: "ContextのライフサイクルをSingleton と誤解",
                       explanation: "ConstraintValidatorContext は各バリデーション実行ごとに新しいインスタンスが提供されます。ConstraintValidator 実装クラス自体はSpring管理下でシングルトンになり得ますが、Context は呼び出しごとに異なります。")
            ],
            explanationRef: "explain-boot3-val2-cross-003",
            designIntent: "ConstraintValidatorContextを使ってエラーを特定フィールドに紐付ける方法を理解する。"
        ),
        quiz(
            id: "boot3-val2-cross-004",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["日付範囲", "startDate", "endDate", "クロスフィールド"],
            code: """
@ValidDateRange
public class EventCreateDto {

    @NotNull
    @FutureOrPresent
    private LocalDate startDate;

    @NotNull
    private LocalDate endDate;
}

// バリデーターの isValid 実装
public boolean isValid(EventCreateDto dto, ConstraintValidatorContext ctx) {
    if (dto.getStartDate() == null || dto.getEndDate() == null) {
        return true; // @NotNull に任せる
    }
    return !dto.getEndDate().isBefore(dto.getStartDate());
}
""",
            question: "日付範囲バリデーションで `startDate` または `endDate` が null のとき `true` を返す設計の理由として正しいのはどれか？",
            choices: [
                choice("a", "null チェックは @NotNull の責務であり、クロスフィールド検証の責務は日付の前後関係のみに絞るべきだから", correct: true,
                       explanation: "isValid で null のとき true を返すことで、null かどうかの判定を @NotNull に委譲し、クロスフィールドバリデーターは純粋に「endDate が startDate より前ではないか」だけに集中できます。責務の分離によりコードが読みやすくなります。"),
                choice("b", "null のとき true を返さないと NullPointerException が発生するため", misconception: "NPE回避が主目的と誤解",
                       explanation: "NPE 回避も副次的な効果ですが、主目的は責務の分離です。null チェックを行って false を返すこともできますが、その場合 @NotNull のエラーと重複してエラーが2件発生するという問題が生じます。"),
                choice("c", "isValid が true を返すと @NotNull のチェックがスキップされる", misconception: "isValid の戻り値が他のアノテーションに影響すると誤解",
                       explanation: "isValid の戻り値は自身のバリデーション結果のみに影響します。@NotNull は独立して評価されます。null のとき isValid で true を返しても @NotNull は別途評価されエラーになります。"),
                choice("d", "isBefore の代わりに isAfter を使うと常に false になる", misconception: "日付比較メソッドの意味を混同",
                       explanation: "!dto.getEndDate().isBefore(dto.getStartDate()) は endDate が startDate 以降であることを確認します。これは dto.getEndDate().isAfter(dto.getStartDate()) || dto.getEndDate().isEqual(dto.getStartDate()) と同義です。同じ日を許容するかどうかで使い分けます。")
            ],
            explanationRef: "explain-boot3-val2-cross-004",
            designIntent: "クロスフィールドバリデーションでのnull処理と責務分離を理解する。"
        ),
        quiz(
            id: "boot3-val2-cross-005",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@ScriptAssert", "代替手段", "クラスレベルバリデーション"],
            code: """
// @ScriptAssert の使用例（非推奨）
@ScriptAssert(lang = "javascript",
    script = "_this.endDate.isAfter(_this.startDate)",
    message = "終了日は開始日より後にしてください")
public class EventDto { ... }

// 推奨される代替実装
@ValidDateRange  // カスタムクラスレベルアノテーション
public class EventDto { ... }
""",
            question: "`@ScriptAssert` が非推奨とされる理由として正しいのはどれか？",
            choices: [
                choice("a", "JDKのスクリプトエンジン依存や型安全性の欠如、GraalVMネイティブイメージでの非対応などの問題があるため", correct: true,
                       explanation: "@ScriptAssert は Nashorn (JavaScript エンジン) などに依存しますが、JDK 15以降で Nashorn が削除され、GraalVM ネイティブイメージでも動作しません。また文字列でロジックを書くため IDE のサポートが弱く、リファクタリングにも対応しにくいです。"),
                choice("b", "@ScriptAssert は複数フィールドを参照できないため非推奨となった", misconception: "機能的な制限が理由と誤解",
                       explanation: "@ScriptAssert は複数フィールドを参照できます。非推奨の理由は機能的な制限ではなく、JDKのスクリプトエンジンの廃止やネイティブイメージとの非互換性です。"),
                choice("c", "@ScriptAssert は Spring Boot では最初から使用できない", misconception: "@ScriptAssert自体が使えないと誤解",
                       explanation: "@ScriptAssert は hibernate-validator に含まれており、Spring Boot でも使用できました。しかしJDKの変更により動作が不安定になったため代替手段（カスタム ConstraintValidator）への移行が推奨されています。"),
                choice("d", "@ScriptAssert を使うとアプリケーション起動時に例外がスローされる", misconception: "起動時エラーが発生すると誤解",
                       explanation: "スクリプトエンジンが利用可能な環境では起動時に例外は発生しません。ただし JDK の構成によってはバリデーション実行時にエラーになる場合があります。")
            ],
            explanationRef: "explain-boot3-val2-cross-005",
            designIntent: "@ScriptAssertの問題点とカスタムConstraintValidatorへの移行理由を理解する。"
        )
    ]

    // MARK: - Group 3: カスタム制約 (5問)
    private static let val2Custom: [Quiz] = [
        quiz(
            id: "boot3-val2-custom-001",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["カスタムアノテーション", "@UniqueEmail", "@Constraint"],
            code: """
@Target({ ElementType.FIELD, ElementType.PARAMETER })
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Constraint(validatedBy = UniqueEmailValidator.class)
public @interface UniqueEmail {
    String message() default "このメールアドレスは既に使用されています";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
""",
            question: "カスタム制約アノテーションで `@Constraint(validatedBy = ...)` を付ける目的として正しいのはどれか？",
            choices: [
                choice("a", "Bean Validation フレームワークにこのアノテーションの検証ロジックを担うクラスを伝えるため", correct: true,
                       explanation: "@Constraint(validatedBy = UniqueEmailValidator.class) により、Bean Validation ランタイムは @UniqueEmail が付いた値を検証する際に UniqueEmailValidator を使用します。validatedBy を複数指定すれば異なる型向けの Validator を登録できます。"),
                choice("b", "@Constraint を付けないとアノテーション自体がコンパイルエラーになる", misconception: "@Constraintがコンパイルに必須と誤解",
                       explanation: "@Constraint がなくてもアノテーションはコンパイルできます。ただし Bean Validation がそのアノテーションを制約として認識しないため、バリデーションが実行されません。"),
                choice("c", "validatedBy には複数のクラスを指定できない", misconception: "validatedByの配列指定を誤解",
                       explanation: "validatedBy は Class 配列なので複数指定できます。例えば String 型と Integer 型を受け付ける Validator を別々に定義して同一アノテーションで利用できます。"),
                choice("d", "@Constraint を付けると Spring の @Component は不要になる", misconception: "@ConstraintとSpring DIを混同",
                       explanation: "@Constraint は Bean Validation の仕組みです。@Autowired で Spring Bean を注入する場合は @Component（または @Service 等）を付けて Spring 管理 Bean にする必要があります。")
            ],
            explanationRef: "explain-boot3-val2-custom-001",
            designIntent: "カスタム制約アノテーションの定義に必要な要素を理解する。"
        ),
        quiz(
            id: "boot3-val2-custom-002",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["ConstraintValidator", "実装", "型パラメータ"],
            code: """
@Component
public class UniqueEmailValidator
        implements ConstraintValidator<UniqueEmail, String> {

    @Autowired
    private UserRepository userRepository;

    @Override
    public void initialize(UniqueEmail annotation) {
        // 初期化処理（必要に応じて）
    }

    @Override
    public boolean isValid(String email, ConstraintValidatorContext ctx) {
        if (email == null) return true;
        return !userRepository.existsByEmail(email);
    }
}
""",
            question: "`ConstraintValidator<UniqueEmail, String>` の2つの型引数の役割として正しいのはどれか？",
            choices: [
                choice("a", "第1引数は対応する制約アノテーション型、第2引数はバリデーション対象の値の型を指定する", correct: true,
                       explanation: "ConstraintValidator<A extends Annotation, T> の A が制約アノテーション、T が検証対象の値の型です。String を指定することで @UniqueEmail が String 型のフィールドに使われたときのみこの Validator が適用されます。"),
                choice("b", "第1引数はバリデーション対象のクラス、第2引数はエラーメッセージの型を表す", misconception: "型引数の意味を誤解",
                       explanation: "第1引数は制約アノテーション型（UniqueEmail）、第2引数はバリデーション対象の値の型（String）です。エラーメッセージはアノテーションの message 属性で定義します。"),
                choice("c", "型引数に Object を指定するとすべての型に対応するが推奨されない", misconception: "Object指定の振る舞いを誤解",
                       explanation: "Object を指定すると任意の型に適用できますが、型安全性が失われます。isValid の引数が Object になるためキャストが必要になり、実際には具体的な型を指定することが推奨されます。"),
                choice("d", "ConstraintValidator は interface であるため @Component を付けても Spring Bean にならない", misconception: "interfaceへの@Componentが無効と誤解",
                       explanation: "@Component を付けた実装クラスは Spring Bean として管理されます。Spring Boot の LocalValidatorFactoryBean は Spring の ApplicationContext を参照して ConstraintValidator の Bean を解決します。")
            ],
            explanationRef: "explain-boot3-val2-custom-002",
            designIntent: "ConstraintValidatorの型パラメータの意味とSpring DIとの統合を理解する。"
        ),
        quiz(
            id: "boot3-val2-custom-003",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["isValid", "Repository注入", "DBチェック"],
            code: """
@Override
public boolean isValid(String email, ConstraintValidatorContext ctx) {
    if (email == null) return true;
    return !userRepository.existsByEmail(email);
}
""",
            question: "ConstraintValidator の `isValid` でリポジトリを使ってDBチェックを行う際の注意点として正しいのはどれか？",
            choices: [
                choice("a", "バリデーション実行のたびにDBクエリが発生するため、パフォーマンスへの影響とトランザクションコンテキストの考慮が必要", correct: true,
                       explanation: "リポジトリ呼び出しはDBアクセスを伴うため、バリデーション実行コストが高くなります。また isValid はサービス層のトランザクション外で呼ばれることが多く、必要であれば @Transactional を考慮する必要があります。ユニーク制約はDBレベルの制約も合わせて設けることが推奨されます。"),
                choice("b", "isValid は必ず @Transactional を付けなければならない", misconception: "@Transactionalが必須と誤解",
                       explanation: "読み取り専用のチェックであれば @Transactional なしでも動作します。ただし LazyInitializationException などが発生する場合は @Transactional(readOnly = true) が必要になることがあります。"),
                choice("c", "ConstraintValidator に @Autowired でリポジトリを注入しても実行時は null になる", misconception: "DIが正常に機能しないと誤解",
                       explanation: "Spring Boot 環境では LocalValidatorFactoryBean が Spring のコンテキストを使って ConstraintValidator を生成するため、@Autowired によるDIが正常に機能します。ただし Spring 管理外で Validator を直接 new した場合は null になります。"),
                choice("d", "isValid の戻り値が false のとき自動的にロールバックが発生する", misconception: "バリデーション失敗とトランザクションを混同",
                       explanation: "isValid が false を返してもトランザクションのロールバックは自動的には発生しません。ロールバックは @Transactional とともに例外がスローされた場合に起こります。")
            ],
            explanationRef: "explain-boot3-val2-custom-003",
            designIntent: "isValid内でのDB呼び出しのコストとトランザクション上の注意点を理解する。"
        ),
        quiz(
            id: "boot3-val2-custom-004",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@Constraint", "validatedBy", "複数型対応"],
            code: """
@Constraint(validatedBy = {
    PhoneNumberValidator.ForString.class,
    PhoneNumberValidator.ForLong.class
})
public @interface ValidPhoneNumber {
    String message() default "無効な電話番号形式です";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
""",
            question: "`@Constraint(validatedBy = { ... })` に複数クラスを指定する目的として正しいのはどれか？",
            choices: [
                choice("a", "同じ制約アノテーションを異なる型（String、Long など）のフィールドに適用できるようにするため", correct: true,
                       explanation: "ConstraintValidator の第2型引数がそれぞれ String と Long の Validator を定義し、validatedBy に両方を登録することで、@ValidPhoneNumber を String 型にも Long 型にも使えます。フレームワークが対象フィールドの型に一致する Validator を自動的に選択します。"),
                choice("b", "複数 Validator を指定するとすべてが並列実行され結果が AND 結合される", misconception: "並列実行とAND結合を誤解",
                       explanation: "複数 Validator を指定しても並列実行はされません。対象フィールドの型に一致する Validator が1つ選ばれて実行されます。型に一致する Validator がなければエラーになります。"),
                choice("c", "validatedBy を空配列にするとバリデーションがスキップされる", misconception: "空配列指定の効果を誤解",
                       explanation: "validatedBy を空配列にすると、制約アノテーションには Validator が紐付かず、バリデーション実行時に UnexpectedTypeException が発生する場合があります。"),
                choice("d", "1つの制約アノテーションに対して Validator は必ず1つでなければならない", misconception: "1対1の対応が必須と誤解",
                       explanation: "validatedBy は配列型なので複数の ConstraintValidator を登録できます。これにより同一アノテーションで多くの型をサポートできます。")
            ],
            explanationRef: "explain-boot3-val2-custom-004",
            designIntent: "validatedByに複数Validatorを指定して複数型に対応する方法を理解する。"
        ),
        quiz(
            id: "boot3-val2-custom-005",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["message", "groups", "payload", "アノテーション定義"],
            code: """
public @interface UniqueEmail {
    String message() default "{com.example.validation.UniqueEmail.message}";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
    String field() default "email"; // 追加属性の例
}
""",
            question: "カスタム制約アノテーションに `message`、`groups`、`payload` の3属性が必須である理由として正しいのはどれか？",
            choices: [
                choice("a", "Bean Validation の仕様で制約アノテーションに必須とされており、これらがないとアノテーションが制約として認識されない", correct: true,
                       explanation: "Bean Validation 仕様（Jakarta Bean Validation）では制約アノテーションは必ず message、groups、payload の3属性を持つことが求められています。これらがないと @Constraint が付いていても仕様準拠の制約として動作しません。"),
                choice("b", "message は必須だが groups と payload は省略しても動作する", misconception: "groupsとpayloadを省略可能と誤解",
                       explanation: "Bean Validation 仕様では3属性すべてが必須です。groups と payload を省略するとフレームワークが制約として認識できず、動作しない場合や例外が発生する場合があります。"),
                choice("c", "payload は Spring Security と連携するためのセキュリティ情報を格納する属性である", misconception: "payloadの用途を誤解",
                       explanation: "payload は制約に追加のメタデータを付与するための拡張ポイントです。Severity（エラーレベル）などのアプリ固有の情報を型安全に付与できます。Spring Security とは直接関係ありません。"),
                choice("d", "groups に Default.class を明示しないと Default グループに含まれない", misconception: "Default グループの扱いを誤解",
                       explanation: "groups のデフォルト値を空配列 `{}` にすると、その制約は Default グループに属します。明示的に Default.class を指定しなくても空配列で Default グループに属することが保証されます。")
            ],
            explanationRef: "explain-boot3-val2-custom-005",
            designIntent: "カスタム制約アノテーションに必須の3属性とその意味を理解する。"
        )
    ]

    // MARK: - Group 4: メソッドレベルバリデーション (5問)
    private static let val2MethodLevel: [Quiz] = [
        quiz(
            id: "boot3-val2-method-001",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@Validated", "@Service", "メソッドバリデーション"],
            code: """
@Service
@Validated
public class OrderService {

    public OrderDto createOrder(@NotNull @Valid OrderDto dto) {
        return orderRepository.save(toEntity(dto));
    }

    @NotEmpty
    public List<OrderDto> findByCustomer(@NotNull Long customerId) {
        return orderRepository.findByCustomerId(customerId);
    }
}
""",
            question: "`@Service` クラスに `@Validated` を付ける効果として正しいのはどれか？",
            choices: [
                choice("a", "Spring AOP によりメソッドの引数と戻り値のバリデーションが有効化され、違反時に ConstraintViolationException がスローされる", correct: true,
                       explanation: "@Validated をクラスに付けると Spring が AOP プロキシを生成し、メソッド呼び出しをインターセプトします。引数の @NotNull 違反や戻り値の @NotEmpty 違反は ConstraintViolationException としてスローされ、コントローラーの MethodArgumentNotValidException とは異なります。"),
                choice("b", "@Validated を付けると全メソッドに対して @Transactional が適用される", misconception: "@Validatedと@Transactionalを混同",
                       explanation: "@Validated はバリデーションAOPのみを有効化します。トランザクション管理には別途 @Transactional が必要です。"),
                choice("c", "@Validated をサービスに付けるとコントローラーの @Valid と二重にバリデーションが実行される", misconception: "二重バリデーションが発生すると誤解",
                       explanation: "コントローラーの @Valid とサービスの @Validated は独立した仕組みです。コントローラーでは BindingResult と MethodArgumentNotValidException が使われ、サービスでは ConstraintViolationException が使われます。同じロジックが二重になるわけではありません。"),
                choice("d", "メソッドバリデーションが有効になるのはインターフェース経由で呼び出したときのみ", misconception: "プロキシ呼び出しの制約を誤解",
                       explanation: "Spring AOPプロキシ経由の呼び出し（外部からの呼び出し）であればインターフェースの有無に関わらずバリデーションが適用されます。ただし同一クラス内からの直接呼び出しではプロキシを経由しないためバリデーションが効きません。")
            ],
            explanationRef: "explain-boot3-val2-method-001",
            designIntent: "@Validatedをサービスクラスに付けたときのメソッドバリデーションの仕組みを理解する。"
        ),
        quiz(
            id: "boot3-val2-method-002",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@NotNull", "メソッド引数", "ConstraintViolationException"],
            code: """
@Service
@Validated
public class UserService {

    public UserDto getUser(@NotNull Long id) {
        return userRepository.findById(id)
            .map(this::toDto)
            .orElseThrow(() -> new UserNotFoundException(id));
    }
}

// 呼び出し元
userService.getUser(null); // ← どうなるか？
""",
            question: "`@Validated` が付いたサービスの `@NotNull` 引数に null を渡したとき何が起きるか？",
            choices: [
                choice("a", "メソッド本体が実行される前に ConstraintViolationException がスローされる", correct: true,
                       explanation: "Spring AOPプロキシがメソッド呼び出しをインターセプトし、引数のバリデーションを先に実行します。@NotNull 違反が検出されると ConstraintViolationException がスローされ、メソッド本体（userRepository.findById）は実行されません。"),
                choice("b", "メソッド本体が実行されて userRepository.findById(null) が呼ばれる", misconception: "バリデーションが実行されないと誤解",
                       explanation: "@Validated によるメソッドバリデーションが有効な場合、プロキシがメソッド本体の実行前にバリデーションを実行します。null が渡されるとメソッド本体は実行されません。"),
                choice("c", "MethodArgumentNotValidException がスローされる", misconception: "サービス層の例外をコントローラー層の例外と混同",
                       explanation: "MethodArgumentNotValidException はコントローラーで @Valid/@Validated を使ったリクエストボディのバリデーション失敗時にスローされます。サービス層のメソッドバリデーションでは ConstraintViolationException がスローされます。"),
                choice("d", "@NotNull は戻り値にのみ使用できるためコンパイルエラーになる", misconception: "@NotNullの使用箇所を誤解",
                       explanation: "@NotNull はフィールド、メソッド引数、戻り値など多くのターゲットに使用できます。メソッド引数への使用は有効であり、コンパイルエラーにはなりません。")
            ],
            explanationRef: "explain-boot3-val2-method-002",
            designIntent: "サービス層のメソッドバリデーションでConstraintViolationExceptionがスローされる仕組みを理解する。"
        ),
        quiz(
            id: "boot3-val2-method-003",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@NotEmpty", "戻り値バリデーション", "メソッドレベル"],
            code: """
@Service
@Validated
public class ProductService {

    @NotEmpty(message = "商品一覧が空です")
    public List<ProductDto> getActiveProducts() {
        return productRepository.findByActiveTrue()
            .stream()
            .map(this::toDto)
            .collect(Collectors.toList());
        }
}
""",
            question: "メソッドの戻り値に `@NotEmpty` を付けた場合の動作として正しいのはどれか？",
            choices: [
                choice("a", "メソッドが空のリストを返したとき ConstraintViolationException がスローされる", correct: true,
                       explanation: "@Validated なクラスのメソッド戻り値に @NotEmpty を付けると、Spring AOPがメソッドの実行後に戻り値を検証します。空のリストが返された場合は ConstraintViolationException がスローされます。DBが空のケースをエラーとして扱いたい場合に使えますが、設計上の注意が必要です。"),
                choice("b", "@NotEmpty を戻り値に付けるとコンパイルエラーになる", misconception: "戻り値への制約アノテーション使用をコンパイルエラーと誤解",
                       explanation: "@NotEmpty は @Target に METHOD を含む場合、メソッドに付けられます。ただし戻り値のバリデーションとして機能するには @Validated によるAOPが必要です。"),
                choice("c", "戻り値の @NotEmpty は null チェックのみで、空リストはバリデーションをパスする", misconception: "@NotEmptyと@NotNullを混同",
                       explanation: "@NotEmpty は null でないこと、かつ空でないこと（サイズ > 0）の両方を確認します。@NotNull は null チェックのみです。空リストは @NotEmpty に違反します。"),
                choice("d", "戻り値バリデーションは @Valid のみがサポートしており @NotEmpty は使えない", misconception: "戻り値バリデーションにおける制約の種類を誤解",
                       explanation: "@Valid は戻り値オブジェクトのカスケードバリデーションに使います。@NotEmpty のような制約アノテーションは戻り値に直接付けて値自体を検証できます。どちらも @Validated なクラスで動作します。")
            ],
            explanationRef: "explain-boot3-val2-method-003",
            designIntent: "メソッド戻り値のバリデーションの動作と注意点を理解する。"
        ),
        quiz(
            id: "boot3-val2-method-004",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["ConstraintViolationException", "MethodArgumentNotValidException", "例外の違い"],
            code: """
// コントローラー層（@Valid使用）
@PostMapping("/orders")
public ResponseEntity<?> create(
        @Valid @RequestBody OrderDto dto,
        BindingResult result) {
    // MethodArgumentNotValidException or BindingResult
}

// サービス層（@Validated使用）
@Service
@Validated
public class OrderService {
    public void process(@NotNull OrderDto dto) {
        // ConstraintViolationException
    }
}
""",
            question: "`ConstraintViolationException` と `MethodArgumentNotValidException` の違いとして正しいのはどれか？",
            choices: [
                choice("a", "MethodArgumentNotValidException はコントローラーのリクエストボディバリデーション失敗で発生し、ConstraintViolationException はメソッドバリデーション（サービス層等）違反で発生する", correct: true,
                       explanation: "MethodArgumentNotValidException は Spring MVC が @Valid/@Validated のリクエストボディバリデーション失敗時にスローします。ConstraintViolationException は Jakarta Bean Validation の例外で、@Validated なBeanのメソッドバリデーション違反時にスローされます。@ControllerAdvice でそれぞれ適切にハンドリングが必要です。"),
                choice("b", "ConstraintViolationException はデータベース制約違反のときにスローされる", misconception: "ConstraintViolationExceptionとDB制約を混同",
                       explanation: "DB制約違反は DataIntegrityViolationException（JPA/JDBC）がスローされます。ConstraintViolationException は Bean Validation の制約違反です。パッケージも jakarta.validation と org.springframework.dao で異なります。"),
                choice("c", "どちらの例外も Spring Boot が自動的に 400 Bad Request として返す", misconception: "両例外の自動ハンドリングを誤解",
                       explanation: "MethodArgumentNotValidException は Spring MVC のデフォルトハンドリングで 400 が返ります。ConstraintViolationException はデフォルトでは 500 Internal Server Error になるため、@ControllerAdvice での明示的なハンドリングが必要です。"),
                choice("d", "BindingResult を引数に追加すると ConstraintViolationException もキャッチできる", misconception: "BindingResultがConstraintViolationExceptionをキャッチできると誤解",
                       explanation: "BindingResult はコントローラーの @Valid/@Validated によるリクエストバリデーションエラーのみをキャプチャします。サービス層の ConstraintViolationException はキャッチできません。")
            ],
            explanationRef: "explain-boot3-val2-method-004",
            designIntent: "コントローラー層とサービス層のバリデーション例外の違いとハンドリング方法を理解する。"
        ),
        quiz(
            id: "boot3-val2-method-005",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@Validated", "インターフェース", "継承", "AOPの注意点"],
            code: """
public interface OrderService {
    OrderDto createOrder(@NotNull @Valid OrderDto dto);
}

@Service
@Validated
public class OrderServiceImpl implements OrderService {

    @Override
    public OrderDto createOrder(OrderDto dto) {
        // インターフェースの制約が継承されるか？
        return ...;
    }
}
""",
            question: "`@Validated` を付けたサービス実装クラスがインターフェースを実装する場合の注意点として正しいのはどれか？",
            choices: [
                choice("a", "インターフェースのメソッドに付けた制約アノテーションは実装クラスのオーバーライドメソッドにも適用されるが、実装クラスのメソッドには同じ制約を再定義してはいけない", correct: true,
                       explanation: "Bean Validation では、インターフェースのメソッドに定義した制約は実装クラスのオーバーライドメソッドに継承されます。ただし実装クラスのオーバーライドメソッドに同じ制約を重複定義するとバリデーションが2回実行されてしまいます。制約はインターフェースに一元管理するのが推奨パターンです。"),
                choice("b", "@Validated はインターフェースに付ける必要があり、実装クラスに付けても効果がない", misconception: "@Validatedの配置場所を誤解",
                       explanation: "@Validated は実装クラスに付けることで Spring AOP プロキシが生成されます。インターフェースへの @Validated はメソッドバリデーション有効化の効果を持ちません。"),
                choice("c", "インターフェースのメソッドに付けた @NotNull はオーバーライドされると無効になる", misconception: "アノテーションの継承を誤解",
                       explanation: "Bean Validation 仕様では、インターフェースのメソッドパラメータ制約は実装クラスのオーバーライドメソッドにも継承されます。オーバーライドによって無効化はされません。"),
                choice("d", "@Validated なクラスでは final メソッドにもバリデーションが適用される", misconception: "AOPとfinalメソッドの関係を誤解",
                       explanation: "Spring AOP はプロキシベースのため、final メソッドへのインターセプトはできません。CGLIB プロキシも final メソッドはオーバーライドできないため、final メソッドにバリデーションは適用されません。")
            ],
            explanationRef: "explain-boot3-val2-method-005",
            designIntent: "@Validatedとインターフェース・継承の組み合わせにおける制約の継承と重複定義の問題を理解する。"
        )
    ]

    // MARK: - Group 5: エラーレスポンス & i18n (5問)
    private static let val2Groups2: [Quiz] = [
        quiz(
            id: "boot3-val2-i18n-001",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["BindingResult", "カスタムエラー", "rejectValue"],
            code: """
@PostMapping("/users")
public ResponseEntity<?> createUser(
        @Valid @RequestBody UserDto dto,
        BindingResult bindingResult) {

    if (userService.existsByUsername(dto.getUsername())) {
        bindingResult.rejectValue(
            "username",
            "duplicate.username",
            "このユーザー名は既に使用されています"
        );
    }

    if (bindingResult.hasErrors()) {
        return ResponseEntity.badRequest()
            .body(buildErrorResponse(bindingResult));
    }
    return ResponseEntity.ok(userService.create(dto));
}
""",
            question: "`BindingResult.rejectValue()` を使う目的として正しいのはどれか？",
            choices: [
                choice("a", "アノテーションでは表現しにくいビジネスロジック上のエラー（重複チェック等）をフィールドエラーとして追加するため", correct: true,
                       explanation: "rejectValue(field, code, message) を使うと、DBアクセスが必要な重複チェックなどのビジネスロジックバリデーション結果をフィールドエラーとして BindingResult に追加できます。これにより @Valid のエラーと同じ仕組みでエラーレスポンスを構築できます。"),
                choice("b", "rejectValue を呼ぶとその場で例外がスローされてメソッドの処理が中断される", misconception: "rejectValueが即座に例外をスローすると誤解",
                       explanation: "rejectValue は BindingResult にエラーを記録するだけです。例外はスローされません。その後 hasErrors() でエラーの有無を確認し、必要に応じてエラーレスポンスを返します。"),
                choice("c", "rejectValue は BindingResult の代わりに使うメソッドで、同時に引数に加えることはできない", misconception: "rejectValueとBindingResultの関係を誤解",
                       explanation: "rejectValue は BindingResult のインスタンスメソッドです。BindingResult を引数に受け取ったうえで bindingResult.rejectValue(...) と呼び出します。"),
                choice("d", "rejectValue で追加したエラーは bindingResult.getGlobalErrors() で取得する", misconception: "フィールドエラーとグローバルエラーを混同",
                       explanation: "rejectValue はフィールド名を指定するため、フィールドエラーとして追加されます。getFieldErrors() または getFieldError(\"username\") で取得します。グローバルエラーは reject() メソッドで追加します。")
            ],
            explanationRef: "explain-boot3-val2-i18n-001",
            designIntent: "BindingResult.rejectValueを使ってビジネスロジックバリデーションエラーをフィールドエラーとして追加する方法を理解する。"
        ),
        quiz(
            id: "boot3-val2-i18n-002",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["messages.properties", "カスタムメッセージ", "i18n"],
            code: """
# src/main/resources/messages.properties
NotBlank.userDto.name=名前は必須です
NotBlank.name=名前フィールドは空にできません
NotBlank={0}は必須入力項目です

# src/main/resources/messages_en.properties
NotBlank.userDto.name=Name is required
NotBlank={0} is required
""",
            question: "`messages.properties` でバリデーションメッセージを上書きするときの優先順位として正しいのはどれか？",
            choices: [
                choice("a", "「制約コード.オブジェクト名.フィールド名」が最優先で、「制約コード.フィールド名」「制約コード」の順に優先度が下がる", correct: true,
                       explanation: "Spring の MessageCodesResolver は複数のメッセージコードを生成し、最も具体的なコード（型名+フィールド名）から順に解決します。NotBlank.userDto.name → NotBlank.name → NotBlank.java.lang.String → NotBlank の順に探します。最初に見つかったものが使われます。"),
                choice("b", "messages.properties の最後に定義したキーが優先される", misconception: "ファイル内の定義順が優先度を決めると誤解",
                       explanation: "メッセージの優先順位はキーの具体性によって決まります。ファイル内の定義順序は関係ありません。"),
                choice("c", "アノテーションの message 属性に直書きした文字列は messages.properties より低い優先度になる", misconception: "アノテーションのmessageと外部ファイルの優先順位を誤解",
                       explanation: "アノテーションの message 属性に `{...}` 形式でキーを指定した場合は messages.properties から解決されます。直接文字列を書いた場合はその文字列が使われ、messages.properties は参照されません。"),
                choice("d", "messages_en.properties は Spring Boot では自動的に読み込まれない", misconception: "ロケール別ファイルの自動読み込みを誤解",
                       explanation: "Spring の MessageSource はロケールに基づいて messages_en.properties などのロケール別ファイルを自動的に解決します。Accept-Language ヘッダーや LocaleContextHolder で設定されたロケールに応じて適切なファイルが選択されます。")
            ],
            explanationRef: "explain-boot3-val2-i18n-002",
            designIntent: "messages.propertiesによるバリデーションメッセージのカスタマイズと優先順位を理解する。"
        ),
        quiz(
            id: "boot3-val2-i18n-003",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["メッセージ補間", "プレースホルダー", "アノテーション属性"],
            code: """
# messages.properties
Size.userDto.name=名前は{min}文字以上{max}文字以下で入力してください
Min.userDto.age={value}歳以上である必要があります

# アノテーション
@Size(min = 2, max = 50)
private String name;

@Min(18)
private int age;
""",
            question: "`{min}`、`{max}`、`{value}` などのプレースホルダーについて正しいのはどれか？",
            choices: [
                choice("a", "制約アノテーションの属性名と一致しており、バリデーション時に実際の属性値で置換される", correct: true,
                       explanation: "Bean Validation のメッセージ補間では {属性名} がアノテーションの対応する属性値に置換されます。@Size の {min} は min 属性の値 2、{max} は max 属性の値 50 に置換されます。これにより動的なエラーメッセージが実現できます。"),
                choice("b", "{min} は messages.properties に別途定義する必要がある", misconception: "プレースホルダーを別キーとして誤解",
                       explanation: "{min} などはメッセージ補間の変数であり、messages.properties に定義するものではありません。Bean Validation フレームワークがアノテーションの属性値で自動的に置換します。"),
                choice("c", "{javax.validation.constraints.NotBlank.message} のように完全修飾名で参照する必要がある", misconception: "完全修飾名が必須と誤解",
                       explanation: "完全修飾名の形式は hibernate-validator のデフォルトメッセージを参照する場合に使います。{min} や {max} は属性値の補間であり、完全修飾名は不要です。"),
                choice("d", "プレースホルダーは英語以外の言語のメッセージでは使用できない", misconception: "言語による制限があると誤解",
                       explanation: "プレースホルダーはメッセージの言語に関係なく使用できます。messages_ja.properties でも messages_en.properties でも同様に {min} が属性値に置換されます。")
            ],
            explanationRef: "explain-boot3-val2-i18n-003",
            designIntent: "メッセージ補間でのプレースホルダーとアノテーション属性値の対応を理解する。"
        ),
        quiz(
            id: "boot3-val2-i18n-004",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["@ControllerAdvice", "グローバルエラー", "ValidationExceptionHandler"],
            code: """
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationErrors(
            MethodArgumentNotValidException ex) {
        List<FieldErrorDto> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(fe -> new FieldErrorDto(
                fe.getField(),
                fe.getDefaultMessage()))
            .collect(Collectors.toList());
        return ResponseEntity.badRequest()
            .body(new ErrorResponse("VALIDATION_ERROR", errors));
    }
}
""",
            question: "`@ControllerAdvice` でバリデーションエラーをグローバルに処理する利点として正しいのはどれか？",
            choices: [
                choice("a", "各コントローラーメソッドに BindingResult を引数で受け取るコードを書かずに済み、エラーレスポンス形式をアプリ全体で統一できる", correct: true,
                       explanation: "@ControllerAdvice の @ExceptionHandler でバリデーション例外をキャッチすると、コントローラーメソッドに BindingResult を追加する必要がなくなります。全コントローラーで一貫したエラーレスポンス形式を提供でき、コードの重複を排除できます。"),
                choice("b", "@ControllerAdvice を使うとバリデーション例外が自動的にログに記録される", misconception: "自動ログ記録機能があると誤解",
                       explanation: "@ControllerAdvice 自体にログ記録機能はありません。必要であれば @ExceptionHandler メソッド内で明示的にログ出力を行います。"),
                choice("c", "@ControllerAdvice の @ExceptionHandler は最初にマッチした例外ハンドラーのみ実行される", misconception: "複数ハンドラーの実行順を誤解",
                       explanation: "@ExceptionHandler は例外の型に基づいて一致するハンドラーが選ばれます。最も具体的な型のハンドラーが選択されます。複数が同じ型を処理する場合は実行順は未定義です。"),
                choice("d", "@ControllerAdvice は @RestController のみに適用され、@Controller には効果がない", misconception: "@ControllerAdviceの適用範囲を誤解",
                       explanation: "@ControllerAdvice は @Controller と @RestController の両方に適用されます。basePackages 等で範囲を絞ることもできますが、デフォルトはすべてのコントローラーが対象です。")
            ],
            explanationRef: "explain-boot3-val2-i18n-004",
            designIntent: "@ControllerAdviceを使ったグローバルバリデーションエラーハンドリングの利点を理解する。"
        ),
        quiz(
            id: "boot3-val2-i18n-005",
            level: .practice,
            objective: "boot3-practice-validation",
            category: .validation,
            tags: ["FieldError", "ObjectError", "BindingResult", "getGlobalErrors"],
            code: """
@PostMapping("/events")
public ResponseEntity<?> createEvent(
        @Valid @RequestBody EventDto dto,
        BindingResult bindingResult) {

    if (bindingResult.hasErrors()) {
        List<FieldError> fieldErrors = bindingResult.getFieldErrors();
        List<ObjectError> globalErrors = bindingResult.getGlobalErrors();

        // フィールドエラー：特定フィールドに紐付き
        // グローバルエラー：オブジェクト全体に紐付き（例：クラスレベルの制約）
    }
}
""",
            question: "`BindingResult` のフィールドエラーとオブジェクトエラー（グローバルエラー）の違いとして正しいのはどれか？",
            choices: [
                choice("a", "フィールドエラーは特定のフィールドに紐付く制約違反で、オブジェクトエラーはクラスレベルの制約違反や reject() で追加したエラー", correct: true,
                       explanation: "getFieldErrors() は @NotBlank、@Size などフィールド固有の制約違反を返します。getGlobalErrors() はクラスレベルのカスタム制約（@ValidDateRange など）や bindingResult.reject() で追加したオブジェクト全体のエラーを返します。hasErrors() はどちらも含めて確認します。"),
                choice("b", "getGlobalErrors() は全フィールドのエラーを結合して返す", misconception: "globalをすべてのエラーの集合と誤解",
                       explanation: "getGlobalErrors() はオブジェクトレベルのエラーのみを返します。全エラーを取得するには getAllErrors() を使います。"),
                choice("c", "フィールドエラーにはエラーメッセージのみが含まれ、どのフィールドのエラーかは判定できない", misconception: "FieldErrorがフィールド情報を持たないと誤解",
                       explanation: "FieldError は getField() でフィールド名、getDefaultMessage() でメッセージ、getRejectedValue() で拒否された値を取得できます。どのフィールドのエラーかは明確に判定できます。"),
                choice("d", "クラスレベルの @ValidDateRange 違反は getFieldErrors() で取得できる", misconception: "クラスレベル違反がフィールドエラーとして記録されると誤解",
                       explanation: "クラスレベルの制約違反はデフォルトではオブジェクトエラーとして BindingResult に記録されます。ただし ConstraintValidatorContext で addPropertyNode を指定した場合はフィールドエラーとして記録されます。")
            ],
            explanationRef: "explain-boot3-val2-i18n-005",
            designIntent: "BindingResultのフィールドエラーとオブジェクトエラーの違いと取得方法を理解する。"
        )
    ]
}
