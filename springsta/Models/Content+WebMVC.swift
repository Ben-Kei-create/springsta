import Foundation

// MARK: - Web MVC 50問

extension Quiz {
    static let webMvcQuizzes: [Quiz] = (wmvcBasics + wmvcPathMapping + wmvcRequestResponse
        + wmvcExceptionHandling + wmvcValidation + wmvcFilterInterceptor
        + wmvcDispatcher + wmvcRestDesign).map { $0.contextualizedForPresentation() }

    // ─────────────────────────────────────────
    // Group 1: @RestController 基礎 (8問)
    // ─────────────────────────────────────────
    private static let wmvcBasics: [Quiz] = [
        quiz(
            id: "boot3-wmvc-basics-001",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@GetMapping", "@RequestMapping", "HTTPメソッド"],
            code: """
// 書き方A
@RequestMapping(value = "/users", method = RequestMethod.GET)
List<User> list() { ... }

// 書き方B
@GetMapping("/users")
List<User> list() { ... }
""",
            question: "AとBの動作の違いとして正しいものはどれか？",
            choices: [
                choice("a", "機能的に同じ。`@GetMapping` は `@RequestMapping(method=GET)` のショートカット",
                       correct: true,
                       explanation: "`@GetMapping`・`@PostMapping`・`@PutMapping`・`@DeleteMapping`・`@PatchMapping` はSpring 4.3で追加された合成アノテーションです。`@RequestMapping` より簡潔に書けます。"),
                choice("b", "`@GetMapping` はレスポンスを必ずJSON形式にする",
                       misconception: "GetMappingがJSONを強制すると誤解",
                       explanation: "JSONへの変換は `produces` や `@ResponseBody` の仕組みです。HTTPメソッドとは別です。"),
                choice("c", "`@RequestMapping` はクラスレベルにのみ使える",
                       misconception: "@RequestMappingの使用箇所を制限して誤解",
                       explanation: "`@RequestMapping` はクラスレベルにもメソッドレベルにも使えます。"),
                choice("d", "`@GetMapping` は認証なしでアクセスできる",
                       misconception: "@GetMappingがセキュリティを制御すると誤解",
                       explanation: "アクセス制御はSpring Securityが担います。")
            ],
            explanationRef: "explain-boot3-wmvc-basics-001",
            designIntent: "@GetMappingと@RequestMappingの等価性を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-basics-002",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@PathVariable", "URLパラメータ", "型変換"],
            code: """
@RestController
@RequestMapping("/orders")
class OrderController {
    @GetMapping("/{id}")
    OrderResponse getOrder(@PathVariable Long id) {
        return service.find(id);
    }
}
""",
            question: "`@PathVariable Long id` の動作として正しいものはどれか？",
            choices: [
                choice("a", "URLの `{id}` 部分を `Long` 型に自動変換して引数に渡す",
                       correct: true,
                       explanation: "Springは `@PathVariable` の型に合わせて文字列を自動変換します。`/orders/42` なら `id=42L` になります。変換できない値（例：`/orders/abc`）は `MethodArgumentTypeMismatchException`（HTTP 400）になります。"),
                choice("b", "変換は行われずURLパラメータは常に `String` で受け取る必要がある",
                       misconception: "型変換が自動で行われないと誤解",
                       explanation: "SpringはLong・Integer・UUID等への自動変換に対応しています。"),
                choice("c", "`{id}` の名前と引数名 `id` は一致しなくてもよい",
                       misconception: "変数名の一致が不要と誤解",
                       explanation: "デフォルトでは `{id}` と引数名 `id` が一致している必要があります。異なる場合は `@PathVariable(\"id\")` と明示します。"),
                choice("d", "`Long` 型なので `/orders/0` は受け付けない",
                       misconception: "0がLongで無効な値と誤解",
                       explanation: "`0` は有効な `Long` 値です。")
            ],
            explanationRef: "explain-boot3-wmvc-basics-002",
            designIntent: "@PathVariableの自動型変換を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-basics-003",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@RequestParam", "クエリパラメータ", "required", "defaultValue"],
            code: """
@GetMapping("/users")
List<User> search(
    @RequestParam String name,
    @RequestParam(required = false, defaultValue = "10") int limit
) { ... }
""",
            question: "`?name=Alice` のみを送った場合（`limit` なし）の動作はどれか？",
            choices: [
                choice("a", "`name=\"Alice\"`、`limit=10` でメソッドが呼ばれる",
                       correct: true,
                       explanation: "`required = false` かつ `defaultValue = \"10\"` を指定しているため、`limit` が省略されても `10` が使われます。`name` は `required=true`（デフォルト）なので省略するとHTTP 400になります。"),
                choice("b", "`limit` が省略されたためHTTP 400になる",
                       misconception: "defaultValueがあっても400になると誤解",
                       explanation: "`defaultValue` を指定すると省略可能です。"),
                choice("c", "`limit` は `null` になる",
                       misconception: "プリミティブ型がnullになると誤解",
                       explanation: "`int` はプリミティブなので `null` になりません。`defaultValue` の `\"10\"` が使われます。"),
                choice("d", "`name` も省略可能なためエラーにならない",
                       misconception: "nameもrequired=falseと誤解",
                       explanation: "`name` はデフォルトの `required=true` なので省略するとHTTP 400になります。")
            ],
            explanationRef: "explain-boot3-wmvc-basics-003",
            designIntent: "@RequestParamのrequired/defaultValueの動作を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-basics-004",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@RequestBody", "JSONデシリアライズ", "Jackson"],
            code: """
@PostMapping("/users")
@ResponseStatus(HttpStatus.CREATED)
UserResponse create(@RequestBody CreateUserRequest req) {
    return service.create(req);
}
""",
            question: "`@RequestBody` の役割として正しいものはどれか？",
            choices: [
                choice("a", "リクエストのHTTPボディをJSONとしてデシリアライズし `CreateUserRequest` オブジェクトに変換する",
                       correct: true,
                       explanation: "SpringはJacksonを使ってリクエストボディのJSONをJavaオブジェクトに変換します。Content-Typeが `application/json` でないと変換できず HTTP 415 になることがあります。"),
                choice("b", "URLのクエリパラメータを受け取る",
                       misconception: "@RequestParamと混同",
                       explanation: "クエリパラメータは `@RequestParam` です。`@RequestBody` はHTTPボディを対象にします。"),
                choice("c", "フォームデータ（application/x-www-form-urlencoded）を受け取る",
                       misconception: "フォーム送信と@RequestBodyを混同",
                       explanation: "フォームデータは `@ModelAttribute` で受け取ります。`@RequestBody` はJSONやXMLのボディを対象とします。"),
                choice("d", "ファイルアップロードを受け取る",
                       misconception: "@RequestPartと混同",
                       explanation: "ファイルは `@RequestPart` や `MultipartFile` で受け取ります。")
            ],
            explanationRef: "explain-boot3-wmvc-basics-004",
            designIntent: "@RequestBodyがJSONをJavaオブジェクトに変換することを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-basics-005",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["ResponseEntity", "HTTPステータス", "ヘッダー"],
            code: """
@PostMapping("/items")
ResponseEntity<ItemResponse> create(@RequestBody CreateItemRequest req) {
    ItemResponse item = service.create(req);
    URI location = URI.create("/items/" + item.id());
    return ResponseEntity.created(location).body(item);
}
""",
            question: "`ResponseEntity.created(location).body(item)` が返すHTTPレスポンスはどれか？",
            choices: [
                choice("a", "HTTP 201 Created + `Location` ヘッダー + レスポンスボディ",
                       correct: true,
                       explanation: "`ResponseEntity.created(uri)` は HTTP 201 を設定し `Location` ヘッダーにURIをセットします。RESTのPOSTで新規リソースを作った後の推奨レスポンスです。"),
                choice("b", "HTTP 200 OK + `Location` ヘッダー",
                       misconception: "createdが200を返すと誤解",
                       explanation: "`created()` は201を返します。200は `ok()` です。"),
                choice("c", "HTTP 201 Created のみ（ボディなし）",
                       misconception: ".body()を付けてもボディが設定されないと誤解",
                       explanation: "`.body(item)` でレスポンスボディが設定されます。"),
                choice("d", "HTTP 302 Found（リダイレクト）",
                       misconception: "LocationヘッダーをリダイレクトとしてのLocationと混同",
                       explanation: "302のLocationはリダイレクト先ですが、201のLocationは作成リソースのURLです。")
            ],
            explanationRef: "explain-boot3-wmvc-basics-005",
            designIntent: "ResponseEntity.createdの201+Locationヘッダーの意味を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-basics-006",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@ResponseStatus", "ステータスコード", "アノテーション"],
            code: """
@DeleteMapping("/{id}")
@ResponseStatus(HttpStatus.NO_CONTENT)
void delete(@PathVariable Long id) {
    service.delete(id);
}
""",
            question: "`@ResponseStatus(HttpStatus.NO_CONTENT)` の効果はどれか？",
            choices: [
                choice("a", "このメソッドが正常終了すると HTTP 204 No Content が返される",
                       correct: true,
                       explanation: "`@ResponseStatus` でメソッドが返すステータスコードを宣言します。DELETEは慣例的にボディなしの204を返します。例外が発生した場合はこのステータスではなく例外ハンドラのステータスになります。"),
                choice("b", "レスポンスボディにHTMLが含まれなくなる",
                       misconception: "No ContentをHTMLなしと誤解",
                       explanation: "HTTP 204はボディがないことを意味します（ステータスが204）。HTMLの有無はコンテンツタイプの問題です。"),
                choice("c", "DELETEメソッドは必ず204を返すためこのアノテーションは不要",
                       misconception: "DELETEのデフォルトが204と誤解",
                       explanation: "デフォルトは200です。204にするには明示が必要です。"),
                choice("d", "204を返すとクライアントはリクエストを再送する",
                       misconception: "204がリトライを意味すると誤解",
                       explanation: "204は正常な応答でリトライを意味しません。")
            ],
            explanationRef: "explain-boot3-wmvc-basics-006",
            designIntent: "@ResponseStatusで返却HTTPステータスを宣言することを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-basics-007",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@RequestHeader", "HTTPヘッダー取得"],
            code: """
@GetMapping("/secure")
String secure(
    @RequestHeader("X-API-Key") String apiKey,
    @RequestHeader(value = "Accept-Language",
                   required = false,
                   defaultValue = "ja") String lang
) { ... }
""",
            question: "`@RequestHeader` の動作として正しいものはどれか？",
            choices: [
                choice("a", "HTTPリクエストヘッダーの値を引数にバインドする。`required=false` なら省略可能",
                       correct: true,
                       explanation: "`@RequestHeader` はHTTPヘッダーを取得します。`X-API-Key` は必須（省略で400）、`Accept-Language` は任意でデフォルト `\"ja\"` です。`@RequestParam` のクエリパラメータ版に相当します。"),
                choice("b", "HTTPボディのヘッダー部分（JSONの先頭キー）を取得する",
                       misconception: "HTTPヘッダーとJSONのフィールドを混同",
                       explanation: "HTTPヘッダーはリクエストのメタデータ部分です。JSONとは別です。"),
                choice("c", "`@RequestHeader` はPOSTリクエストでしか使えない",
                       misconception: "ボディを持つメソッドのみ有効と誤解",
                       explanation: "GETを含むすべてのHTTPメソッドでヘッダーは存在します。"),
                choice("d", "ヘッダー名の大文字・小文字は区別される",
                       misconception: "HTTPヘッダーが大文字小文字を区別すると誤解",
                       explanation: "HTTP仕様でヘッダー名は大文字小文字を区別しません。Springも同様です。")
            ],
            explanationRef: "explain-boot3-wmvc-basics-007",
            designIntent: "@RequestHeaderによるHTTPヘッダー取得を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-basics-008",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["produces", "Content-Type", "JSON", "メディアタイプ"],
            code: """
@GetMapping(value = "/report",
            produces = MediaType.APPLICATION_JSON_VALUE)
ReportResponse getReport() { ... }
""",
            question: "`produces = MediaType.APPLICATION_JSON_VALUE` を指定した効果はどれか？",
            choices: [
                choice("a", "このエンドポイントは `Accept: application/json` ヘッダーを持つリクエストのみ受け付け、レスポンスのContent-Typeが `application/json` になる",
                       correct: true,
                       explanation: "`produces` は「このエンドポイントが返せるメディアタイプ」を宣言します。クライアントの `Accept` ヘッダーと一致しない場合はHTTP 406 Not Acceptableになります。"),
                choice("b", "リクエストのContent-Typeを限定する",
                       misconception: "consumesとproducesを混同",
                       explanation: "リクエストのContent-Typeを限定するのは `consumes` です。`produces` はレスポンスのメディアタイプです。"),
                choice("c", "JSONデシリアライズを無効にしてレスポンスを文字列にする",
                       misconception: "producesがシリアライズを無効化すると誤解",
                       explanation: "`produces` はシリアライズの無効化ではなくメディアタイプの宣言です。"),
                choice("d", "指定しないとJSONが返らない",
                       misconception: "producesを省略するとJSONが返らないと誤解",
                       explanation: "`@RestController` があれば省略してもJacksonによるJSONシリアライズが行われます。")
            ],
            explanationRef: "explain-boot3-wmvc-basics-008",
            designIntent: "producesによるメディアタイプ制約を理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 2: パスマッピング (7問)
    // ─────────────────────────────────────────
    private static let wmvcPathMapping: [Quiz] = [
        quiz(
            id: "boot3-wmvc-path-001",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@RequestMapping", "クラスレベル", "プレフィックス"],
            code: """
@RestController
@RequestMapping("/api/v1/users")
class UserController {
    @GetMapping("/{id}")
    User get(@PathVariable Long id) { ... }

    @PostMapping
    User create(@RequestBody CreateUserRequest req) { ... }
}
""",
            question: "`get` メソッドが処理するURLとして正しいものはどれか？",
            choices: [
                choice("a", "`GET /api/v1/users/{id}` — クラスとメソッドのマッピングが結合される",
                       correct: true,
                       explanation: "クラスレベルの `@RequestMapping` はプレフィックスになります。メソッドの `@GetMapping(\"/{id}\")` と結合して `GET /api/v1/users/{id}` になります。バージョニングや共通パスに使います。"),
                choice("b", "`GET /{id}` — メソッドレベルのみが有効",
                       misconception: "クラスレベルの@RequestMappingが無視されると誤解",
                       explanation: "クラスレベルとメソッドレベルは結合されます。"),
                choice("c", "`GET /api/v1/users` と `GET /{id}` が両方マッピングされる",
                       misconception: "クラスとメソッドのパスが分離して登録されると誤解",
                       explanation: "クラスレベルはプレフィックスとして機能し、メソッドのパスと結合されます。"),
                choice("d", "`@RequestMapping` はクラスとメソッドの両方に付けるとエラー",
                       misconception: "二重定義がエラーになると誤解",
                       explanation: "クラス＋メソッドの組み合わせは正式なSpring MVCの使い方です。")
            ],
            explanationRef: "explain-boot3-wmvc-path-001",
            designIntent: "クラスとメソッドのRequestMappingの結合を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-path-002",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@PathVariable", "@RequestParam", "使い分け"],
            code: """
// A: パスに含める
GET /orders/42

// B: クエリパラメータ
GET /orders?id=42
""",
            question: "RESTful設計でAとBの使い分けの基準として最も正しいものはどれか？",
            choices: [
                choice("a", "リソースを特定するID（必須）はパス（A）、絞り込みや任意条件はクエリパラメータ（B）に置くのが慣例",
                       correct: true,
                       explanation: "REST設計では `/orders/42` のようにリソース識別子はパスに入れます。`/orders?status=shipped&limit=10` のようなフィルタ・ソート・ページングはクエリパラメータが適切です。"),
                choice("b", "GETはA、POSTはBを使う",
                       misconception: "HTTPメソッドとパラメータ位置を対応づけて誤解",
                       explanation: "HTTPメソッドとパスパラメータ/クエリパラメータの使い分けは独立した概念です。"),
                choice("c", "数値IDはA、文字列IDはBに置く",
                       misconception: "型でパラメータ位置を決めると誤解",
                       explanation: "型ではなくリソース識別の意味で判断します。"),
                choice("d", "Springはどちらでもパフォーマンスはまったくかわらない",
                       misconception: "パフォーマンスが設計基準と誤解",
                       explanation: "パフォーマンス差は無視できる範囲です。可読性・RESTfulな表現が主な基準です。")
            ],
            explanationRef: "explain-boot3-wmvc-path-002",
            designIntent: "@PathVariableと@RequestParamの設計上の使い分けを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-path-003",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@PathVariable", "複数", "ネストリソース"],
            code: """
@GetMapping("/users/{userId}/orders/{orderId}")
OrderResponse getUserOrder(
    @PathVariable Long userId,
    @PathVariable Long orderId
) { ... }
""",
            question: "このエンドポイントが処理するURLの例として正しいものはどれか？",
            choices: [
                choice("a", "`GET /users/10/orders/55` — `userId=10`、`orderId=55`",
                       correct: true,
                       explanation: "複数の `@PathVariable` はURLの位置に合わせて変数名でバインドされます。ネストリソース（ユーザーの注文）はこのようなURL設計が一般的です。"),
                choice("b", "`GET /users?userId=10&orderId=55`",
                       misconception: "@PathVariableがクエリパラメータにバインドされると誤解",
                       explanation: "`@PathVariable` はURLパス内の `{}` にバインドされます。"),
                choice("c", "`userId` と `orderId` が同じ値でないとマッピングエラーになる",
                       misconception: "複数のPathVariableに制約があると誤解",
                       explanation: "それぞれ独立した変数です。"),
                choice("d", "パス変数が2つあると `@RequestMapping` に変更する必要がある",
                       misconception: "変数が複数になると@GetMappingが使えないと誤解",
                       explanation: "複数の `@PathVariable` は `@GetMapping` でも使えます。")
            ],
            explanationRef: "explain-boot3-wmvc-path-003",
            designIntent: "複数@PathVariableによるネストリソースURLを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-path-004",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@GetMapping", "複数パス", "エイリアス"],
            code: """
@GetMapping({"/health", "/ping", "/status"})
String health() { return "OK"; }
""",
            question: "配列でパスを指定した場合の動作はどれか？",
            choices: [
                choice("a", "`GET /health`・`GET /ping`・`GET /status` のすべてが同じメソッドにマッピングされる",
                       correct: true,
                       explanation: "`@GetMapping` に配列でパスを渡すと複数のURLを1メソッドに割り当てられます。ヘルスチェックエンドポイントで複数の慣例名をまとめるときなどに使います。"),
                choice("b", "最初の `\"/health\"` のみが有効",
                       misconception: "配列の最初だけが使われると誤解",
                       explanation: "配列に指定したすべてのパスが有効になります。"),
                choice("c", "配列指定はコンパイルエラーになる",
                       misconception: "@GetMappingに配列が渡せないと誤解",
                       explanation: "`value` は `String[]` 型なので配列が使えます。"),
                choice("d", "3つのメソッドがコピーされて登録される",
                       misconception: "メソッドが複製されると誤解",
                       explanation: "メソッドは1つでマッピングが3つ登録されます。")
            ],
            explanationRef: "explain-boot3-wmvc-path-004",
            designIntent: "@GetMappingへの複数パス指定を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-path-005",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@RequestParam", "List", "複数値"],
            code: """
@GetMapping("/items")
List<Item> search(
    @RequestParam List<String> tags
) { ... }
""",
            question: "`GET /items?tags=java&tags=spring` というリクエストの場合、`tags` の値はどれか？",
            choices: [
                choice("a", "`[\"java\", \"spring\"]` というListになる",
                       correct: true,
                       explanation: "同名のクエリパラメータを複数指定すると `List<String>` に収集されます。`?tags=java,spring`（カンマ区切り）でも動作します。"),
                choice("b", "最後の `spring` だけが入る",
                       misconception: "同名パラメータの最後の値だけが使われると誤解",
                       explanation: "List型に指定すると複数の値を全部受け取れます。"),
                choice("c", "`\"java&tags=spring\"` という1つの文字列になる",
                       misconception: "URLエンコードされた文字列がそのまま入ると誤解",
                       explanation: "SpringがURLを解析して値を分割します。"),
                choice("d", "HTTP 400 Bad Requestになる",
                       misconception: "同名パラメータ複数指定がエラーになると誤解",
                       explanation: "List型で受け取ることでエラーなく処理できます。")
            ],
            explanationRef: "explain-boot3-wmvc-path-005",
            designIntent: "@RequestParamでList型を使った複数値の受け取りを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-path-006",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@RequestParam", "Optional", "nullable"],
            code: """
@GetMapping("/search")
List<Product> search(
    @RequestParam Optional<String> category
) { ... }
""",
            question: "`?category=` を省略してリクエストした場合の `category` の値はどれか？",
            choices: [
                choice("a", "`Optional.empty()` になる",
                       correct: true,
                       explanation: "`Optional<String>` で受け取ると省略時は `Optional.empty()` になります。`required=false` を明示しなくてもよく、呼び出し側でnullチェック不要なコードが書けます。"),
                choice("b", "`Optional.of(\"\")` になる（空文字が入る）",
                       misconception: "省略と空文字を混同",
                       explanation: "パラメータ自体が省略された場合は `empty()` です。`?category=`（値なし）の場合は `Optional.of(\"\")` になります。"),
                choice("c", "HTTP 400 Bad Requestになる",
                       misconception: "Optional型でも省略はエラーになると誤解",
                       explanation: "`Optional` で受け取ると省略が許容されます。"),
                choice("d", "`null` になる",
                       misconception: "Optional型がnullを返すと誤解",
                       explanation: "Optional型の省略時は `empty()` であって `null` ではありません。")
            ],
            explanationRef: "explain-boot3-wmvc-path-006",
            designIntent: "@RequestParamでOptional型を使った省略対応を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-path-007",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["consumes", "Content-Type", "リクエスト"],
            code: """
@PostMapping(value = "/upload",
             consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
String upload(@RequestPart MultipartFile file) { ... }
""",
            question: "`consumes = MediaType.MULTIPART_FORM_DATA_VALUE` の効果はどれか？",
            choices: [
                choice("a", "Content-Type が `multipart/form-data` のリクエストのみ受け付け、それ以外はHTTP 415 Unsupported Media Typeになる",
                       correct: true,
                       explanation: "`consumes` はリクエストのContent-Typeを制限します。`application/json` のリクエストは415で弾かれます。ファイルアップロードエンドポイントとJSON APIを同じパスに置く場合に使います。"),
                choice("b", "レスポンスのContent-Typeを設定する",
                       misconception: "consumesとproducesを混同",
                       explanation: "レスポンスのメディアタイプは `produces` で設定します。"),
                choice("c", "`consumes` を指定しないとファイルアップロードができない",
                       misconception: "consumesがファイル受信の必須条件と誤解",
                       explanation: "`@RequestPart MultipartFile` があればconsumes指定なしでも動作します。"),
                choice("d", "このエンドポイントはGETリクエストも受け付ける",
                       misconception: "consumesがHTTPメソッドを変更すると誤解",
                       explanation: "HTTPメソッドは `@PostMapping` で決まります。consumesはContent-Typeのみを制限します。")
            ],
            explanationRef: "explain-boot3-wmvc-path-007",
            designIntent: "consumesによるリクエストContent-Type制限を理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 3: リクエスト / レスポンス (7問)
    // ─────────────────────────────────────────
    private static let wmvcRequestResponse: [Quiz] = [
        quiz(
            id: "boot3-wmvc-reqres-001",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["ResponseEntity", "ステータス", "ヘッダー設定"],
            code: """
@GetMapping("/{id}")
ResponseEntity<UserResponse> get(@PathVariable Long id) {
    return service.findById(id)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
}
""",
            question: "ユーザーが見つからない場合に返るHTTPレスポンスはどれか？",
            choices: [
                choice("a", "HTTP 404 Not Found（ボディなし）",
                       correct: true,
                       explanation: "`ResponseEntity.notFound().build()` は HTTP 404 でボディなしのレスポンスを返します。`Optional.map` でユーザーが存在すれば200+ボディ、なければ404を分岐させる慣用パターンです。"),
                choice("b", "HTTP 200 OK（ボディが `null`）",
                       misconception: "notFoundがnullボディの200を返すと誤解",
                       explanation: "`notFound()` は404を設定します。200ではありません。"),
                choice("c", "NullPointerExceptionが発生する",
                       misconception: "orElseの返り値でNPEが起きると誤解",
                       explanation: "`ResponseEntity.notFound().build()` は正しいResponseEntityを返します。"),
                choice("d", "HTTP 500 Internal Server Error",
                       misconception: "Optional.emptyが500を引き起こすと誤解",
                       explanation: "例外をスローしていないので500にはなりません。")
            ],
            explanationRef: "explain-boot3-wmvc-reqres-001",
            designIntent: "OptionalとResponseEntityを組み合わせた404返却パターンを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-reqres-002",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@CrossOrigin", "CORS", "オリジン"],
            code: """
@RestController
@CrossOrigin(origins = "https://frontend.example.com")
class ProductController {
    @GetMapping("/products")
    List<Product> list() { ... }
}
""",
            question: "`@CrossOrigin` の効果として正しいものはどれか？",
            choices: [
                choice("a", "指定したオリジン（https://frontend.example.com）からのブラウザリクエストのCORSを許可する",
                       correct: true,
                       explanation: "`@CrossOrigin` はCORSポリシーを設定します。同じオリジンポリシーにより、フロントエンドとAPIのドメインが異なる場合にブラウザがAPIを呼べるようにするため必要です。"),
                choice("b", "クロスサイトスクリプティング（XSS）を防止する",
                       misconception: "CORSとXSSセキュリティを混同",
                       explanation: "CORSはリソースの共有制御です。XSS防止はHTMLエスケープやCSPが担います。"),
                choice("c", "HTTPSのみ受け付けるようになる",
                       misconception: "originsのhttpsをプロトコル制限と誤解",
                       explanation: "@CrossOriginはプロトコルを強制しません。HTTPSとHTTPの制御はサーバ設定です。"),
                choice("d", "このURLからのリクエストをブロックする",
                       misconception: "originsをブロックリストと誤解",
                       explanation: "`origins` は許可リストです。指定したオリジンを許可します。")
            ],
            explanationRef: "explain-boot3-wmvc-reqres-002",
            designIntent: "@CrossOriginによるCORSの許可設定を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-reqres-003",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@ModelAttribute", "フォームデータ", "バインディング"],
            code: """
@PostMapping("/register")
String register(@ModelAttribute UserForm form) {
    service.register(form);
    return "redirect:/success";
}
""",
            question: "`@ModelAttribute` の役割として正しいものはどれか？",
            choices: [
                choice("a", "フォームデータ（application/x-www-form-urlencoded）をJavaオブジェクトにバインドする",
                       correct: true,
                       explanation: "`@ModelAttribute` はHTMLフォームのPOSTデータをJavaオブジェクトに変換します。`@RequestBody` がJSON向けなのに対して、こちらはフォーム向けです。"),
                choice("b", "JSONリクエストボディをバインドする",
                       misconception: "@RequestBodyと混同",
                       explanation: "JSONは `@RequestBody` で受け取ります。"),
                choice("c", "URLパスの変数をバインドする",
                       misconception: "@PathVariableと混同",
                       explanation: "URLパス変数は `@PathVariable` です。"),
                choice("d", "`@ModelAttribute` がないとフォームデータはすべて無視される",
                       misconception: "省略するとデータが届かないと誤解",
                       explanation: "省略してもSpringはバインドしようとしますが、`@ModelAttribute` を明示するのが推奨です。")
            ],
            explanationRef: "explain-boot3-wmvc-reqres-003",
            designIntent: "@ModelAttributeがフォームデータのバインドに使うことを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-reqres-004",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["Jackson", "JSON", "@JsonProperty", "フィールド名"],
            code: """
record UserResponse(
    @JsonProperty("user_id") Long id,
    @JsonProperty("full_name") String name
) {}
""",
            question: "`@JsonProperty` を付けた場合のJSONレスポンスはどれか？",
            choices: [
                choice("a", "`{\"user_id\": 1, \"full_name\": \"Alice\"}` — フィールド名がスネークケースに変換される",
                       correct: true,
                       explanation: "`@JsonProperty` でJSONのキー名を指定します。Javaのキャメルケースをスネークケースに変換する場合によく使います。全体に適用する場合は `application.yml` の `spring.jackson.property-naming-strategy: SNAKE_CASE` が便利です。"),
                choice("b", "`{\"id\": 1, \"name\": \"Alice\"}` — フィールド名はJavaのフィールド名になる",
                       misconception: "@JsonPropertyが無視されると誤解",
                       explanation: "`@JsonProperty` の値がJSONキー名になります。"),
                choice("c", "レコードクラスはJSONシリアライズできない",
                       misconception: "recordがJacksonで使えないと誤解",
                       explanation: "Spring Boot 2.5以降でrecordはJacksonによるシリアライズ/デシリアライズに対応しています。"),
                choice("d", "`@JsonProperty` を付けるとそのフィールドはJSONから除外される",
                       misconception: "@JsonIgnoreと混同",
                       explanation: "除外は `@JsonIgnore` です。`@JsonProperty` はキー名の指定です。")
            ],
            explanationRef: "explain-boot3-wmvc-reqres-004",
            designIntent: "@JsonPropertyによるJSONキー名のカスタマイズを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-reqres-005",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["HttpServletRequest", "HttpServletResponse", "低レベルAPI"],
            code: """
@GetMapping("/download")
void download(HttpServletRequest req,
              HttpServletResponse res) throws IOException {
    res.setContentType("application/pdf");
    res.setHeader("Content-Disposition", "attachment; filename=report.pdf");
    // OutputStreamに書き込み
}
""",
            question: "`HttpServletResponse` を引数にとる場合のメリットはどれか？",
            choices: [
                choice("a", "Content-Typeやヘッダーを細かく制御でき、OutputStreamに直接書き込める",
                       correct: true,
                       explanation: "ファイルダウンロードや動的コンテンツ生成では `HttpServletResponse` を使ってOutputStreamに直接書き込むことがあります。`ResponseEntity` では表現しにくいバイナリ応答に向いています。"),
                choice("b", "`HttpServletResponse` を引数にとるとHTTPS通信に切り替わる",
                       misconception: "Servletオブジェクトがプロトコルを変更すると誤解",
                       explanation: "プロトコルはサーバ設定で決まります。"),
                choice("c", "`HttpServletResponse` は `@RestController` では使えない",
                       misconception: "@RestControllerとServlet APIが非対応と誤解",
                       explanation: "`@RestController` 内でも `HttpServletResponse` を引数にとれます。"),
                choice("d", "戻り値を `void` にするとHTTP 500になる",
                       misconception: "void戻り値がエラーになると誤解",
                       explanation: "直接レスポンスに書き込む場合は `void` でも問題ありません。")
            ],
            explanationRef: "explain-boot3-wmvc-reqres-005",
            designIntent: "HttpServletResponseの直接操作が必要なケースを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-reqres-006",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@ResponseBody", "@RestController", "暗黙的適用"],
            code: """
@Controller
class LegacyController {
    @GetMapping("/api/data")
    @ResponseBody
    DataResponse getData() { return new DataResponse(); }

    @GetMapping("/page")
    String page() { return "page"; } // ビュー名を返す
}
""",
            question: "`@ResponseBody` と `@Controller` を組み合わせた場合の動作として正しいものはどれか？",
            choices: [
                choice("a", "`getData` はJSONを返し、`page` はビュー名としてテンプレートを解決する",
                       correct: true,
                       explanation: "`@ResponseBody` が付いたメソッドだけ戻り値をシリアライズします。付いていないメソッドは戻り値をビュー名として扱います。`@RestController` は全メソッドに `@ResponseBody` を付けた状態と同等です。"),
                choice("b", "`@ResponseBody` がある1メソッドだけRESTController扱いになりクラス全体には影響しない",
                       misconception: "部分的に@RestControllerになると誤解",
                       explanation: "クラスは `@Controller` のままです。`@ResponseBody` のあるメソッドだけシリアライズします。"),
                choice("c", "`@Controller` と `@ResponseBody` を混在させるとエラー",
                       misconception: "混在がエラーになると誤解",
                       explanation: "混在は動作します。`@RestController` はその組み合わせのショートカットです。"),
                choice("d", "`page` メソッドも `@ResponseBody` の影響を受けてJSONになる",
                       misconception: "クラス全体に@ResponseBodyが適用されると誤解",
                       explanation: "`@ResponseBody` はメソッドレベルで、付いていないメソッドはビュー解決します。")
            ],
            explanationRef: "explain-boot3-wmvc-reqres-006",
            designIntent: "@ControllerクラスでのメソッドごとのResponseBody付与の動作を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-reqres-007",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["ProblemDetail", "RFC 7807", "Spring 6"],
            code: """
// Spring 6 / Spring Boot 3.x
@GetMapping("/{id}")
ResponseEntity<UserResponse> get(@PathVariable Long id) {
    if (!exists(id)) {
        ProblemDetail pd = ProblemDetail.forStatusAndDetail(
            HttpStatus.NOT_FOUND, "User not found: " + id);
        return ResponseEntity.of(pd).build();
    }
    ...
}
""",
            question: "`ProblemDetail` を使うメリットとして正しいものはどれか？",
            choices: [
                choice("a", "RFC 7807準拠のエラーレスポンス形式（type/title/status/detail）を標準化できる",
                       correct: true,
                       explanation: "Spring 6から導入された `ProblemDetail` はRFC 7807（Problem Details for HTTP APIs）に準拠した構造化エラーレスポンスを提供します。独自エラークラスを作らなくても標準フォーマットが使えます。"),
                choice("b", "`ProblemDetail` はDB接続エラーの自動リカバリを行う",
                       misconception: "ProblemDetailがDB操作と関係すると誤解",
                       explanation: "ProblemDetailはHTTPエラーレスポンスの表現形式です。"),
                choice("c", "Spring Boot 3.xではすべてのエラーが自動でProblemDetail形式になる",
                       misconception: "自動でProblemDetail化されると誤解",
                       explanation: "自動化するには `spring.mvc.problemdetails.enabled=true` の設定が必要です。"),
                choice("d", "`ProblemDetail` を使うとHTTP 500が自動で400に変換される",
                       misconception: "ステータスが自動変換されると誤解",
                       explanation: "ステータスは `forStatusAndDetail` で明示します。")
            ],
            explanationRef: "explain-boot3-wmvc-reqres-007",
            designIntent: "Spring 6のProblemDetailによるRFC準拠エラーレスポンスを理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 4: 例外ハンドリング (6問)
    // ─────────────────────────────────────────
    private static let wmvcExceptionHandling: [Quiz] = [
        quiz(
            id: "boot3-wmvc-exception-001",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@ExceptionHandler", "ローカル", "Controllerスコープ"],
            code: """
@RestController
class OrderController {
    @GetMapping("/{id}")
    OrderResponse get(@PathVariable Long id) {
        return service.find(id); // OrderNotFoundExceptionを投げる可能性
    }

    @ExceptionHandler(OrderNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    ErrorResponse handleNotFound(OrderNotFoundException ex) {
        return new ErrorResponse(ex.getMessage());
    }
}
""",
            question: "この `@ExceptionHandler` の有効範囲はどれか？",
            choices: [
                choice("a", "`OrderController` 内でのみ有効。他のControllerのスローは処理しない",
                       correct: true,
                       explanation: "`@ExceptionHandler` をControllerクラスに直接書くと、そのControllerスコープのみで有効です。アプリ全体に適用するには `@RestControllerAdvice` が必要です。"),
                choice("b", "アプリケーション全体のすべてのControllerに有効",
                       misconception: "@ExceptionHandlerが全体に影響すると誤解",
                       explanation: "全体に適用するには `@ControllerAdvice` か `@RestControllerAdvice` が必要です。"),
                choice("c", "`@Service` や `@Repository` で発生した例外も処理する",
                       misconception: "@ExceptionHandlerがService/Repositoryの例外も処理すると誤解",
                       explanation: "@ExceptionHandlerはWeb層（HTTPリクエスト処理中）の例外を処理します。"),
                choice("d", "`@ResponseStatus` がないとHTTP 200で返る",
                       misconception: "@ExceptionHandlerのデフォルトステータスを誤解",
                       explanation: "`@ExceptionHandler` のデフォルトは実装依存ですが通常は200です。`@ResponseStatus(NOT_FOUND)` で404を明示しています。")
            ],
            explanationRef: "explain-boot3-wmvc-exception-001",
            designIntent: "@ExceptionHandlerのControllerスコープを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-exception-002",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@RestControllerAdvice", "グローバル例外ハンドリング"],
            code: """
@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    ErrorResponse handleNotFound(ResourceNotFoundException ex) {
        return new ErrorResponse("NOT_FOUND", ex.getMessage());
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    ErrorResponse handleGeneral(Exception ex) {
        return new ErrorResponse("ERROR", "予期せぬエラーが発生しました");
    }
}
""",
            question: "`@RestControllerAdvice` の役割として正しいものはどれか？",
            choices: [
                choice("a", "すべての `@RestController` / `@Controller` で発生した例外を集約して処理できる",
                       correct: true,
                       explanation: "`@RestControllerAdvice` は `@ControllerAdvice` + `@ResponseBody` の合成です。全Controllerを横断して例外をハンドリングし、エラーレスポンスをJSONで返す典型パターンです。"),
                choice("b", "`@Service` や `@Repository` で発生した例外も処理できる",
                       misconception: "Web層以外の例外も処理すると誤解",
                       explanation: "Web MVC層でスローされた例外（HTTPリクエスト処理中）が対象です。"),
                choice("c", "`@RestControllerAdvice` は1つのControllerにのみ適用できる",
                       misconception: "ControllerAdviceがローカルと誤解",
                       explanation: "@ControllerAdviceはグローバルです。1つに絞るにはbasePackagesなどを指定します。"),
                choice("d", "このクラスにはBeanとしてDIできない",
                       misconception: "@ControllerAdviceがSpring管理外と誤解",
                       explanation: "@RestControllerAdviceはSpring管理Beanです。Serviceなどを@Autowiredできます。")
            ],
            explanationRef: "explain-boot3-wmvc-exception-002",
            designIntent: "@RestControllerAdviceによるグローバル例外ハンドリングを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-exception-003",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["ResponseStatusException", "例外", "HTTP status"],
            code: """
@GetMapping("/{id}")
UserResponse get(@PathVariable Long id) {
    return userRepository.findById(id)
        .orElseThrow(() ->
            new ResponseStatusException(HttpStatus.NOT_FOUND,
                                        "User not found: " + id));
}
""",
            question: "`ResponseStatusException` を使う利点として正しいものはどれか？",
            choices: [
                choice("a", "カスタム例外クラスを作らなくてもHTTPステータスとメッセージを指定して例外を投げられる",
                       correct: true,
                       explanation: "`ResponseStatusException` はSpring MVCに組み込みの例外で、ステータスコードと詳細メッセージを付けてすぐに使えます。404・403・400などを手早くハンドリングしたいときに便利です。"),
                choice("b", "`ResponseStatusException` は `@ExceptionHandler` なしでも自動でJSONになる",
                       misconception: "自動でErrorResponseが返ると誤解",
                       explanation: "Spring Bootのデフォルトエラー応答は `/error` エンドポイントを経由します。構造化JSONにするには `@ExceptionHandler` か `ProblemDetail` が必要です。"),
                choice("c", "このクラスを使うと例外ログが自動で抑制される",
                       misconception: "例外ログが省略されると誤解",
                       explanation: "ログの抑制とは無関係です。"),
                choice("d", "`ResponseStatusException` はネストした例外に対応していない",
                       misconception: "機能の制限を誤解",
                       explanation: "コンストラクタに cause を渡すことでネストした例外を設定できます。")
            ],
            explanationRef: "explain-boot3-wmvc-exception-003",
            designIntent: "ResponseStatusExceptionの手軽なHTTPエラー返却を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-exception-004",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@ExceptionHandler", "優先順位", "具体クラス"],
            code: """
@RestControllerAdvice
class Handler {
    @ExceptionHandler(IllegalArgumentException.class)
    ResponseEntity<String> handleIllegal(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<String> handleGeneral(Exception e) {
        return ResponseEntity.internalServerError().body("error");
    }
}
""",
            question: "`IllegalArgumentException` がスローされたとき、どちらのハンドラが呼ばれるか？",
            choices: [
                choice("a", "`handleIllegal` — より具体的な例外クラスのハンドラが優先される",
                       correct: true,
                       explanation: "Springは例外の継承階層でより具体的なクラスに対応したハンドラを優先します。`IllegalArgumentException` は `Exception` のサブクラスですが、専用ハンドラが先にマッチします。"),
                choice("b", "`handleGeneral` — 後に定義したものが優先される",
                       misconception: "定義順で優先度が決まると誤解",
                       explanation: "定義順ではなく、例外クラスの具体性が優先度を決めます。"),
                choice("c", "2つのハンドラが両方呼ばれる",
                       misconception: "複数ハンドラが連鎖して呼ばれると誤解",
                       explanation: "1つの例外に対して1つのハンドラが呼ばれます。"),
                choice("d", "`Exception.class` の方が基底クラスで優先度が高い",
                       misconception: "基底クラスが高優先と誤解",
                       explanation: "具体的（派生）クラスのハンドラが優先されます。")
            ],
            explanationRef: "explain-boot3-wmvc-exception-004",
            designIntent: "@ExceptionHandlerの具体クラス優先ルールを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-exception-005",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@ResponseStatus", "カスタム例外", "アノテーション"],
            code: """
@ResponseStatus(HttpStatus.NOT_FOUND)
class UserNotFoundException extends RuntimeException {
    UserNotFoundException(Long id) {
        super("User not found: " + id);
    }
}
""",
            question: "`@ResponseStatus` を例外クラスに付けた場合の動作はどれか？",
            choices: [
                choice("a", "この例外がControllerからスローされると自動でHTTP 404が返る（`@ExceptionHandler` 不要）",
                       correct: true,
                       explanation: "例外クラスに `@ResponseStatus` を付けると、Springがその例外をキャッチして指定したステータスで応答します。ただしレスポンスボディのカスタマイズには `@ExceptionHandler` が必要です。"),
                choice("b", "`@ExceptionHandler` と合わせて使わないと無効",
                       misconception: "@ResponseStatusが単独で動かないと誤解",
                       explanation: "例外クラスへの `@ResponseStatus` は単独で機能します。"),
                choice("c", "`RuntimeException` のサブクラスには使えない",
                       misconception: "チェック例外のみ有効と誤解",
                       explanation: "`RuntimeException` でも `@ResponseStatus` を使えます。"),
                choice("d", "レスポンスボディに例外のメッセージが自動でJSONとして返る",
                       misconception: "MessageがJSONに自動変換されると誤解",
                       explanation: "レスポンスボディはSpring Bootのデフォルトエラー形式になります。詳細なJSONは `@ExceptionHandler` で制御します。")
            ],
            explanationRef: "explain-boot3-wmvc-exception-005",
            designIntent: "例外クラスへの@ResponseStatus付与でHTTPステータスを設定することを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-exception-006",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["WhiteLabel", "BasicErrorController", "デフォルトエラー"],
            code: """
// ブラウザで /unknown にアクセスすると
// "Whitelabel Error Page" が表示される
""",
            question: "Spring BootのWhitelabelエラーページが表示される仕組みはどれか？",
            choices: [
                choice("a", "`BasicErrorController` が `/error` エンドポイントを担い、ブラウザ向けにWhitelabelページをレンダリングする",
                       correct: true,
                       explanation: "Spring Bootは `BasicErrorController` で `/error` を処理します。ブラウザ（HTMLを受け入れる）向けにはWhitelabelページ、APIクライアント向けにはJSONエラーを返し分けます。カスタマイズは `ErrorController` を実装するか `@ControllerAdvice` で行います。"),
                choice("b", "Whitelabelページは404のときのみ表示される",
                       misconception: "404専用と誤解",
                       explanation: "500・403なども表示されます。"),
                choice("c", "Whitelabelを無効にするとエラーで500が返る",
                       misconception: "無効化でエラーが悪化すると誤解",
                       explanation: "`server.error.whitelabel.enabled=false` でカスタムエラーページに切り替えられます。"),
                choice("d", "Spring Securityが認証エラーをWhitelabelで表示する",
                       misconception: "セキュリティエラー専用と誤解",
                       explanation: "Spring Security独自の認証エラーは `AuthenticationEntryPoint` で制御します。")
            ],
            explanationRef: "explain-boot3-wmvc-exception-006",
            designIntent: "WhitelabelエラーページとBasicErrorControllerの仕組みを理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 5: バリデーション連携 (5問)
    // ─────────────────────────────────────────
    private static let wmvcValidation: [Quiz] = [
        quiz(
            id: "boot3-wmvc-valid-001",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@Valid", "@RequestBody", "バリデーション発火"],
            code: """
@PostMapping("/users")
UserResponse create(@Valid @RequestBody CreateUserRequest req) { ... }

record CreateUserRequest(
    @NotBlank String name,
    @Email String email
) {}
""",
            question: "`@Valid` を `@RequestBody` に付けた場合の動作はどれか？",
            choices: [
                choice("a", "リクエストのJSONをバインドした後、DTO内の制約（@NotBlank・@Email）を検証し失敗すると `MethodArgumentNotValidException`（HTTP 400）になる",
                       correct: true,
                       explanation: "`@Valid` はBean Validationを起動します。name が空や email 形式が不正な場合は400が自動で返ります。`@ExceptionHandler` でエラーメッセージをカスタマイズするのが一般的です。"),
                choice("b", "`@Valid` を付けてもバリデーションは手動で呼び出す必要がある",
                       misconception: "@Validが自動起動しないと誤解",
                       explanation: "`@Valid` があればSpringが自動でバリデーションを実行します。"),
                choice("c", "バリデーション失敗でも処理が継続し `req` に無効な値が入る",
                       misconception: "@ValidがHTTPリクエストをブロックしないと誤解",
                       explanation: "バリデーション失敗で例外が発生しメソッドは呼ばれません。"),
                choice("d", "`@NotBlank` はnullのみを検証し空文字は通過する",
                       misconception: "@NotBlankと@NotNullを混同",
                       explanation: "`@NotBlank` はnull・空文字・空白文字すべてを拒否します。`@NotNull` はnullのみを拒否します。")
            ],
            explanationRef: "explain-boot3-wmvc-valid-001",
            designIntent: "@Validによる@RequestBodyの自動バリデーションを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-valid-002",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["BindingResult", "バリデーション", "エラー処理"],
            code: """
@PostMapping("/users")
String create(@Valid @ModelAttribute UserForm form,
              BindingResult result) {
    if (result.hasErrors()) {
        return "user/form"; // フォームを再表示
    }
    service.create(form);
    return "redirect:/users";
}
""",
            question: "`BindingResult` を引数に加えた場合の動作はどれか？",
            choices: [
                choice("a", "バリデーション失敗時に例外を投げずにエラー情報を `BindingResult` に入れて処理を継続させる",
                       correct: true,
                       explanation: "`BindingResult` をすぐ後に置くとバリデーション失敗でも例外がスローされず、メソッドに制御が渡ります。フォームの再表示などで使います。`@RestController` のAPIでは `@ExceptionHandler` で処理する方が一般的です。"),
                choice("b", "`BindingResult` があるとバリデーションが無効になる",
                       misconception: "BindingResultがバリデーション自体を無効化すると誤解",
                       explanation: "バリデーションは実行されます。ただし例外にならずBindingResultに結果が入ります。"),
                choice("c", "`BindingResult` は `@RequestBody` と組み合わせて使う",
                       misconception: "@RequestBodyとBindingResultが組み合わさると誤解",
                       explanation: "`BindingResult` は `@ModelAttribute` との組み合わせが一般的です。`@RequestBody` では動作が異なります。"),
                choice("d", "`result.hasErrors()` は常に `false` を返す",
                       misconception: "BindingResultがエラーを検知しないと誤解",
                       explanation: "バリデーション失敗があれば `hasErrors()` は `true` を返します。")
            ],
            explanationRef: "explain-boot3-wmvc-valid-002",
            designIntent: "BindingResultでバリデーションエラーを例外なく受け取る方法を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-valid-003",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@Validated", "@Valid", "グループ検証"],
            code: """
@PostMapping("/users")
void create(@Validated(CreateGroup.class) @RequestBody UserRequest req) {}

@PutMapping("/users/{id}")
void update(@Validated(UpdateGroup.class) @RequestBody UserRequest req) {}
""",
            question: "`@Validated` と `@Valid` の違いとして正しいものはどれか？",
            choices: [
                choice("a", "`@Validated` はSpring独自でバリデーショングループを指定できる。`@Valid` はJakarta EE標準でグループ指定不可",
                       correct: true,
                       explanation: "`@Valid` はJakarta標準のBeanValidation。`@Validated` はSpringが拡張しグループの指定が可能です。作成時と更新時で検証内容を変えたいとき（idは更新時のみ必須）にグループが便利です。"),
                choice("b", "`@Validated` はクラスレベルにのみ使える",
                       misconception: "メソッド引数に@Validatedは使えないと誤解",
                       explanation: "メソッド引数でも使えます。クラスレベルでのメソッドバリデーション有効化にも使います。"),
                choice("c", "`@Valid` と `@Validated` は完全に同じ機能",
                       misconception: "2つが等価と誤解",
                       explanation: "グループ指定という重要な違いがあります。"),
                choice("d", "`@Validated` はDTOではなくサービスクラスでのみ有効",
                       misconception: "@ValidatedをService専用と誤解",
                       explanation: "@ValidatedはController引数でも使えます。")
            ],
            explanationRef: "explain-boot3-wmvc-valid-003",
            designIntent: "@Validatedのグループ検証機能と@Validの違いを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-valid-004",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@Size", "@Min", "@Max", "数値・文字列制約"],
            code: """
record ProductRequest(
    @NotBlank @Size(max = 100) String name,
    @Min(0) @Max(1_000_000) int price,
    @Size(min = 1, max = 10) List<String> tags
) {}
""",
            question: "`price = -1`・`name = \"\"` のリクエストを送った場合の動作はどれか？",
            choices: [
                choice("a", "`@NotBlank` と `@Min(0)` の両方の検証エラーが発生し、HTTP 400で複数のエラーメッセージが返る",
                       correct: true,
                       explanation: "Bean Validationはデフォルトで全制約を検証し、違反をすべて収集します。`name` の空文字違反と `price` のMin違反が同時に報告されます。`MethodArgumentNotValidException` に複数の `FieldError` が入ります。"),
                choice("b", "最初に見つかったエラー（name）のみ報告される",
                       misconception: "エラーが1つだけ返ると誤解",
                       explanation: "デフォルトでは全違反が収集されます。"),
                choice("c", "`price = -1` は `int` なのでバリデーションが効かない",
                       misconception: "プリミティブ型にBeanValidationが効かないと誤解",
                       explanation: "`@Min`・`@Max` はint等のプリミティブに対応しています。"),
                choice("d", "`@Size` と `@Min` は同時に1つのフィールドに付けられない",
                       misconception: "複数アノテーションの組み合わせが不可と誤解",
                       explanation: "1つのフィールドに複数のバリデーションアノテーションを付けることが可能です。")
            ],
            explanationRef: "explain-boot3-wmvc-valid-004",
            designIntent: "複数バリデーション制約の同時検証と全エラー収集を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-valid-005",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["カスタムバリデータ", "@Constraint", "ConstraintValidator"],
            code: """
@Documented
@Constraint(validatedBy = UniqueEmailValidator.class)
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface UniqueEmail {
    String message() default "このメールは既に使われています";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
""",
            question: "カスタムバリデーションアノテーション `@UniqueEmail` を実装するために最低限必要なものはどれか？",
            choices: [
                choice("a", "`ConstraintValidator<UniqueEmail, String>` を実装したクラスに `isValid()` を定義する",
                       correct: true,
                       explanation: "`@Constraint(validatedBy)` に指定したクラスが `ConstraintValidator<アノテーション, 検証する型>` を実装する必要があります。`isValid()` に実際の検証ロジック（DBでメール重複確認など）を書きます。"),
                choice("b", "`@NotBlank` を継承すれば自動で動く",
                       misconception: "既存アノテーションを継承すれば動くと誤解",
                       explanation: "Javaのアノテーションは継承できません。`ConstraintValidator` を実装します。"),
                choice("c", "`@ExceptionHandler` でこのアノテーションを処理する",
                       misconception: "@ExceptionHandlerがカスタムバリデーションを処理すると誤解",
                       explanation: "バリデーションロジックは `ConstraintValidator` に書きます。"),
                choice("d", "`UniqueEmailValidator` に `@Component` は付けない",
                       misconception: "ConstraintValidatorはBeanにできないと誤解",
                       explanation: "`@Component` を付けることでSpring DIが使えDBチェックが可能になります。付けないとDIが効きません。")
            ],
            explanationRef: "explain-boot3-wmvc-valid-005",
            designIntent: "カスタムバリデーターのConstraintValidator実装を理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 6: フィルタ / インターセプタ (6問)
    // ─────────────────────────────────────────
    private static let wmvcFilterInterceptor: [Quiz] = [
        quiz(
            id: "boot3-wmvc-filter-001",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["Filter", "Interceptor", "違い", "実行順序"],
            code: """
// Servlet Filter
public class LogFilter implements Filter {
    public void doFilter(ServletRequest req,
                         ServletResponse res,
                         FilterChain chain) { ... }
}

// Spring HandlerInterceptor
public class AuthInterceptor implements HandlerInterceptor {
    public boolean preHandle(HttpServletRequest req,
                             HttpServletResponse res,
                             Object handler) { ... }
}
""",
            question: "FilterとHandlerInterceptorの最大の違いはどれか？",
            choices: [
                choice("a", "FilterはServletコンテナレベルで動き全リクエストに適用できる。InterceptorはSpring MVCレベルでControllerのマッピングを認識できる",
                       correct: true,
                       explanation: "FilterはDispatcherServletより前（Servlet仕様）で動き、Spring Beanにアクセスしにくいです。Interceptorは DispatcherServlet後でHandlerMethod情報が取れ、特定のControllerやメソッドだけに適用しやすいです。"),
                choice("b", "FilterはGETのみ、InterceptorはPOSTのみ処理できる",
                       misconception: "HTTPメソッドで使い分けが決まると誤解",
                       explanation: "両者ともすべてのHTTPメソッドを処理できます。"),
                choice("c", "InterceptorはServlet仕様でFilterはSpring専用",
                       misconception: "FilterとInterceptorの所属フレームワークを逆に誤解",
                       explanation: "FilterはServlet仕様（Jakarta EE）、InterceptorはSpring MVC固有です。"),
                choice("d", "FilterはレスポンスのみInterceptorはリクエストのみ処理できる",
                       misconception: "処理対象がリクエスト/レスポンスで分かれると誤解",
                       explanation: "両者ともリクエスト・レスポンスの両方を処理できます。")
            ],
            explanationRef: "explain-boot3-wmvc-filter-001",
            designIntent: "FilterとInterceptorの実行レイヤーと特性の違いを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-filter-002",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["HandlerInterceptor", "preHandle", "postHandle", "afterCompletion"],
            code: """
public class TimingInterceptor implements HandlerInterceptor {
    public boolean preHandle(...) {
        request.setAttribute("start", System.currentTimeMillis());
        return true; // trueで処理続行
    }
    public void postHandle(...) { ... }
    public void afterCompletion(...) {
        long elapsed = System.currentTimeMillis()
            - (Long)request.getAttribute("start");
        log.info("処理時間: {}ms", elapsed);
    }
}
""",
            question: "`preHandle` で `false` を返した場合の動作はどれか？",
            choices: [
                choice("a", "以降のハンドラ（Controller）は呼ばれず、レスポンスはInterceptorが直接書き込む責任を持つ",
                       correct: true,
                       explanation: "`preHandle` が `false` を返すとDispatcherServletはそれ以降のInterceptorとControllerの呼び出しを止めます。認証チェックで失敗した場合にここで401を書き込むパターンが一般的です。"),
                choice("b", "例外がスローされてHTTP 500になる",
                       misconception: "falseでエラーになると誤解",
                       explanation: "falseは正常な「処理中断」であってエラーではありません。"),
                choice("c", "`postHandle` は呼ばれるが `afterCompletion` は呼ばれない",
                       misconception: "preHandleのfalseでpostHandleだけ影響すると誤解",
                       explanation: "`preHandle` でfalseを返した場合は `postHandle` も呼ばれません。`afterCompletion` は他のInterceptorのpreHandleが通った場合のみ呼ばれます。"),
                choice("d", "次のInterceptorの `preHandle` は引き続き呼ばれる",
                       misconception: "falseで連鎖が続くと誤解",
                       explanation: "falseを返した時点でチェーンが止まります。")
            ],
            explanationRef: "explain-boot3-wmvc-filter-002",
            designIntent: "HandlerInterceptorのpreHandle falseによる処理中断を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-filter-003",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["OncePerRequestFilter", "フィルタ", "重複実行防止"],
            code: """
@Component
public class JwtFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ... {
        // JWTの検証処理
        filterChain.doFilter(request, response);
    }
}
""",
            question: "`OncePerRequestFilter` を継承する理由はどれか？",
            choices: [
                choice("a", "フォワード・インクルードなどのServletディスパッチでもフィルタが1リクエストにつき1回だけ実行されることを保証する",
                       correct: true,
                       explanation: "Servlet仕様では `forward()` 時などに同じFilterが複数回呼ばれることがあります。`OncePerRequestFilter` はリクエストスコープにフラグを立てて重複実行を防ぎます。JWT検証などでは重複実行防止が重要です。"),
                choice("b", "このFilterは1日に1回だけ実行される",
                       misconception: "OncePerRequestを「1日に1回」と誤解",
                       explanation: "「1リクエストに1回」です。"),
                choice("c", "非同期リクエストでのみ有効",
                       misconception: "非同期処理専用と誤解",
                       explanation: "同期・非同期ともに使えます。"),
                choice("d", "`@Component` を付けずに使う必要がある",
                       misconception: "@Componentと相性が悪いと誤解",
                       explanation: "`@Component` でBeanとして管理することでSpring DIが使えます。")
            ],
            explanationRef: "explain-boot3-wmvc-filter-003",
            designIntent: "OncePerRequestFilterの重複実行防止の目的を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-filter-004",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["Filter", "@Order", "実行順序"],
            code: """
@Component @Order(1)
class LoggingFilter extends OncePerRequestFilter { ... }

@Component @Order(2)
class AuthFilter extends OncePerRequestFilter { ... }
""",
            question: "リクエスト処理時のFilter実行順として正しいものはどれか？",
            choices: [
                choice("a", "`LoggingFilter` → `AuthFilter` の順（数値が小さい方が先）",
                       correct: true,
                       explanation: "`@Order` の数値が小さいほど優先度が高く先に実行されます。ログを最初に取り、その後認証を行うのが一般的な設計です。"),
                choice("b", "`AuthFilter` → `LoggingFilter` の順（数値が大きい方が先）",
                       misconception: "数値が大きい方が優先されると誤解",
                       explanation: "@Orderは値が小さいほど高優先（先に実行）です。"),
                choice("c", "Filterの順序は `@Order` では制御できない",
                       misconception: "@OrderがFilterの順序に効かないと誤解",
                       explanation: "@OrderはBeanの優先度全般に使え、Filterの順序にも有効です。"),
                choice("d", "両方のFilterが並行して実行される",
                       misconception: "Filterが並行で実行されると誤解",
                       explanation: "FilterはFilterChainを通じて順番に実行されます。")
            ],
            explanationRef: "explain-boot3-wmvc-filter-004",
            designIntent: "@OrderによるFilter実行順序の制御を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-filter-005",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["WebMvcConfigurer", "InterceptorRegistry", "登録"],
            code: """
@Configuration
class WebConfig implements WebMvcConfigurer {
    @Autowired AuthInterceptor authInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authInterceptor)
            .addPathPatterns("/api/**")
            .excludePathPatterns("/api/login", "/api/health");
    }
}
""",
            question: "このInterceptorが実行されるURLパターンとして正しいものはどれか？",
            choices: [
                choice("a", "`/api/**` にマッチしかつ `/api/login` と `/api/health` 以外のURL",
                       correct: true,
                       explanation: "`addPathPatterns` で対象を `/api/**` に限定し、`excludePathPatterns` でログイン・ヘルスチェックを除外しています。認証不要なエンドポイントを除いたすべての `/api/` 以下に認証を適用する典型パターンです。"),
                choice("b", "`/api/login` と `/api/health` のみに適用される",
                       misconception: "excludeがincludeになると誤解",
                       explanation: "excludeは除外です。指定したパスはInterceptorを通りません。"),
                choice("c", "全URLに適用される（パターン指定は無視される）",
                       misconception: "addPathPatternsが機能しないと誤解",
                       explanation: "`addPathPatterns` は有効で指定パターンのみに限定されます。"),
                choice("d", "エンドポイントが存在しないURLにも適用される",
                       misconception: "404のURLにもInterceptorが走ると誤解",
                       explanation: "マッピングが存在しないリクエストはInterceptorのpreHandleの前に404になる場合があります。")
            ],
            explanationRef: "explain-boot3-wmvc-filter-005",
            designIntent: "WebMvcConfigurerでのInterceptorパス制御を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-filter-006",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["MDC", "リクエストID", "ログ追跡"],
            code: """
public class RequestIdFilter extends OncePerRequestFilter {
    protected void doFilterInternal(...) throws ... {
        String requestId = UUID.randomUUID().toString();
        MDC.put("requestId", requestId);
        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
""",
            question: "このFilterが `MDC`（Mapped Diagnostic Context）を使う目的はどれか？",
            choices: [
                choice("a", "リクエストIDをスレッドローカルに保存し、そのリクエスト処理中のすべてのログに `requestId` を自動で付与する",
                       correct: true,
                       explanation: "MDCはSLF4Jのスレッドローカルなログコンテキストです。`%X{requestId}` をログパターンに含めると、1つのリクエスト処理中のすべてのログに同じIDが付きます。障害時のログ追跡に非常に有用です。"),
                choice("b", "リクエストIDをDBに保存してリクエストの重複チェックをする",
                       misconception: "MDCがDBと連携すると誤解",
                       explanation: "MDCはスレッドローカルのメモリ上のコンテキストです。DBへの保存は行いません。"),
                choice("c", "`finally` でMDC.clear()するとログが削除される",
                       misconception: "clearがログ自体を消すと誤解",
                       explanation: "`MDC.clear()` はコンテキストをクリアしスレッド再利用時に前のリクエストのIDが混入しないようにします。すでに書いたログは消えません。"),
                choice("d", "このFilterはHTTPS接続のみで動作する",
                       misconception: "MDCがHTTPSと関係すると誤解",
                       explanation: "MDCはHTTPS/HTTPに関係なく動作します。")
            ],
            explanationRef: "explain-boot3-wmvc-filter-006",
            designIntent: "MDCによるリクエストIDのログ自動付与パターンを理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 7: DispatcherServlet / MVC構成 (5問)
    // ─────────────────────────────────────────
    private static let wmvcDispatcher: [Quiz] = [
        quiz(
            id: "boot3-wmvc-dispatcher-001",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["DispatcherServlet", "フロントコントローラ", "リクエスト処理"],
            code: """
// リクエスト処理の流れ（概略）
// HTTP Request
//   → Servlet Filter
//   → DispatcherServlet
//   → HandlerMapping
//   → HandlerAdapter
//   → Controller
//   → ViewResolver (or MessageConverter)
//   → HTTP Response
""",
            question: "DispatcherServletの主な役割はどれか？",
            choices: [
                choice("a", "受け取ったリクエストを適切なHandlerMappingで対応するControllerに振り分けるフロントコントローラ",
                       correct: true,
                       explanation: "Spring MVCのDispatcherServletはフロントコントローラパターンの中心です。HandlerMappingでURLとControllerを対応付け、HandlerAdapterで実際の呼び出しを行い、レスポンスをMessageConvertorまたはViewResolverで変換します。"),
                choice("b", "DBとの接続を管理するコンポーネント",
                       misconception: "DispatcherServletがDB接続を担うと誤解",
                       explanation: "DB接続はDataSource・JPA・HibernateのStack担います。"),
                choice("c", "アプリのセキュリティ認証を行うコンポーネント",
                       misconception: "Spring SecurityとDispatcherServletを混同",
                       explanation: "認証はSpring SecurityのSecurityFilterChainが担います。"),
                choice("d", "リクエストをすべてのControllerに並行してブロードキャストする",
                       misconception: "全Controllerに同時送信すると誤解",
                       explanation: "1リクエストは1つのControllerメソッドにマッピングされます。")
            ],
            explanationRef: "explain-boot3-wmvc-dispatcher-001",
            designIntent: "DispatcherServletのフロントコントローラとしての役割を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-dispatcher-002",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["HttpMessageConverter", "JSON", "Jackson", "変換"],
            code: """
// application.yml
spring:
  jackson:
    default-property-inclusion: non_null
    serialization:
      write-dates-as-timestamps: false
""",
            question: "この設定の効果として正しいものはどれか？",
            choices: [
                choice("a", "nullのフィールドをJSONから除外し、DateをタイムスタンプではなくISO 8601文字列でシリアライズする",
                       correct: true,
                       explanation: "`non_null` でnullフィールドを省略、`write-dates-as-timestamps: false` でLocalDateTimeなどを `\"2024-08-01T10:00:00\"` 形式にします。Spring Bootが自動設定するJacksonObjectMapperに適用されます。"),
                choice("b", "DBのnullカラムをデフォルト値に置き換える",
                       misconception: "Jackson設定がDB値に影響すると誤解",
                       explanation: "この設定はJSONシリアライズにのみ影響します。"),
                choice("c", "`LocalDate` フィールドがJSONに含まれなくなる",
                       misconception: "日付型が除外されると誤解",
                       explanation: "タイムスタンプ形式をやめて文字列形式にするだけです。日付フィールドは含まれます。"),
                choice("d", "この設定は `@SpringBootTest` でのみ有効",
                       misconception: "application.ymlがテスト限定と誤解",
                       explanation: "デフォルトの `application.yml` はすべての環境（プロファイル指定なし）で読み込まれます。")
            ],
            explanationRef: "explain-boot3-wmvc-dispatcher-002",
            designIntent: "JacksonのSpring Boot設定によるシリアライズ制御を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-dispatcher-003",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["コンテントネゴシエーション", "Accept", "XML", "JSON"],
            code: """
@GetMapping(value = "/data",
            produces = {MediaType.APPLICATION_JSON_VALUE,
                        MediaType.APPLICATION_XML_VALUE})
DataResponse getData() { ... }
""",
            question: "クライアントが `Accept: application/xml` ヘッダーを送った場合の動作はどれか？",
            choices: [
                choice("a", "XML形式でレスポンスが返る（コンテンツネゴシエーション）",
                       correct: true,
                       explanation: "Springはクライアントの `Accept` ヘッダーを見て `produces` リストから一致するメディアタイプを選びます。ただし `jackson-dataformat-xml` の依存が必要です。一致しない場合はHTTP 406になります。"),
                choice("b", "producesに複数指定があるため最初のJSONが常に返る",
                       misconception: "最初に書いたメディアタイプが固定で使われると誤解",
                       explanation: "クライアントのAcceptヘッダーで選択されます。"),
                choice("c", "XMLは自動変換できないためHTTP 500になる",
                       misconception: "XMLサポートがないと誤解",
                       explanation: "jackson-dataformat-xmlがあればXML変換できます。"),
                choice("d", "AcceptヘッダーはSpring Bootでは無視される",
                       misconception: "Acceptヘッダーが処理されないと誤解",
                       explanation: "Springはコンテンツネゴシエーションを正式に処理します。")
            ],
            explanationRef: "explain-boot3-wmvc-dispatcher-003",
            designIntent: "コンテンツネゴシエーションによるJSON/XML切り替えを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-dispatcher-004",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["静的リソース", "Static Resources", "src/main/resources"],
            code: """
// src/main/resources/static/css/style.css
// src/main/resources/static/js/app.js
""",
            question: "Spring Bootで静的リソースを配信するデフォルトの場所として正しいものはどれか？",
            choices: [
                choice("a", "`src/main/resources/static/`（または `public/`・`resources/`・`META-INF/resources/`）",
                       correct: true,
                       explanation: "Spring Bootはこれらのディレクトリを自動でリソースハンドラに設定します。`/static/css/style.css` は `GET /css/style.css` でアクセスできます。追加設定なしで静的ファイルを配信できます。"),
                choice("b", "`src/main/webapp/`（Servlet仕様のWebアプリ構成）",
                       misconception: "従来のServletアプリとSpring Bootを混同",
                       explanation: "`webapp/` は組み込みTomcatでは使えません。Spring Bootのデフォルトは `resources/static/` です。"),
                choice("c", "`@Controller` で明示的にマッピングしないと配信できない",
                       misconception: "静的ファイルにも@Controllerが必要と誤解",
                       explanation: "`ResourceHttpRequestHandler` が自動で処理します。"),
                choice("d", "静的ファイルは `@Bean` で `ResourceHandlerRegistry` に登録が必要",
                       misconception: "手動登録が必須と誤解",
                       explanation: "デフォルトの場所に置けば自動で配信されます。")
            ],
            explanationRef: "explain-boot3-wmvc-dispatcher-004",
            designIntent: "Spring Bootの静的リソース配信のデフォルトパスを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-dispatcher-005",
            level: .foundation,
            objective: "boot3-foundation-web",
            category: .webMvc,
            tags: ["@SpringBootTest", "@WebMvcTest", "テストスライス"],
            code: """
@WebMvcTest(UserController.class)
class UserControllerTest {
    @Autowired MockMvc mockMvc;
    @MockBean UserService userService;

    @Test
    void testGet() throws Exception {
        given(userService.find(1L)).willReturn(new UserResponse(...));
        mockMvc.perform(get("/users/1"))
            .andExpect(status().isOk());
    }
}
""",
            question: "`@WebMvcTest` を使うと何がロードされるか？",
            choices: [
                choice("a", "Web MVC層のBeanのみ（Controller・ControllerAdvice・Filter等）ロードされ、ServiceやRepositoryはロードされない",
                       correct: true,
                       explanation: "`@WebMvcTest` はスライステストで、Controllerを中心としたWeb MVC層のみを起動します。ServiceはロードされないためMockBeanでモック化します。`@SpringBootTest` より高速です。"),
                choice("b", "アプリケーション全体のBeanがロードされる",
                       misconception: "@SpringBootTestと同じと誤解",
                       explanation: "`@WebMvcTest` はMVC層のみです。フルコンテキストは `@SpringBootTest` です。"),
                choice("c", "DBのみロードされControllerはロードされない",
                       misconception: "@DataJpaTestと混同",
                       explanation: "`@DataJpaTest` がJPA層のみです。`@WebMvcTest` はController層です。"),
                choice("d", "`@MockBean` は `@WebMvcTest` と組み合わせて使えない",
                       misconception: "@MockBeanとWebMvcTestの相性を誤解",
                       explanation: "`@MockBean` は `@WebMvcTest` と組み合わせてServiceをモック化する典型パターンです。")
            ],
            explanationRef: "explain-boot3-wmvc-dispatcher-005",
            designIntent: "@WebMvcTestのスライステストの特性を理解する。"
        ),
    ]

    // ─────────────────────────────────────────
    // Group 8: REST設計 (6問)
    // ─────────────────────────────────────────
    private static let wmvcRestDesign: [Quiz] = [
        quiz(
            id: "boot3-wmvc-rest-001",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["REST", "HTTPメソッド", "CRUD対応"],
            code: """
// CRUDとHTTPメソッドの対応
""",
            question: "RESTful APIにおけるHTTPメソッドとCRUD操作の正しい対応はどれか？",
            choices: [
                choice("a", "GET=取得、POST=作成、PUT=更新（全体）、PATCH=更新（一部）、DELETE=削除",
                       correct: true,
                       explanation: "REST設計の慣例です。GET はリソース取得、POST は新規作成（201 Created）、PUT は全項目更新（冪等性あり）、PATCH は一部更新、DELETE は削除（204 No Content）です。"),
                choice("b", "GET=削除、POST=更新、PUT=作成、DELETE=取得",
                       misconception: "HTTPメソッドの意味をランダムに誤解",
                       explanation: "HTTPメソッドはRFC仕様で役割が定義されています。"),
                choice("c", "PUTとPATCHは同じで、どちらでも全体・一部更新が行われる",
                       misconception: "PUTとPATCHの違いを誤解",
                       explanation: "PUTは全体置き換え（省略フィールドはnull/デフォルト）、PATCHは部分更新（送ったフィールドのみ変更）です。"),
                choice("d", "POSTは冪等でDELETEは非冪等",
                       misconception: "冪等性をHTTPメソッドで逆に理解",
                       explanation: "DELETEは冪等（何度実行しても同じ状態）、POSTは非冪等（毎回新しいリソースが作られる）です。")
            ],
            explanationRef: "explain-boot3-wmvc-rest-001",
            designIntent: "RESTful APIのHTTPメソッドとCRUDの対応を正確に理解する。"
        ),
        quiz(
            id: "boot3-wmvc-rest-002",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["@PutMapping", "@PatchMapping", "冪等性"],
            code: """
// PUTで全体更新
@PutMapping("/{id}")
UserResponse update(@PathVariable Long id,
                    @RequestBody UpdateUserRequest req) { ... }

// PATCHで一部更新
@PatchMapping("/{id}")
UserResponse patch(@PathVariable Long id,
                   @RequestBody Map<String, Object> fields) { ... }
""",
            question: "`PUT /users/1` に `{\"name\": \"Alice\"}` だけ送った場合の注意点はどれか？",
            choices: [
                choice("a", "PUT は全体更新なので `email` など送らなかったフィールドがnull/デフォルト値で上書きされる可能性がある",
                       correct: true,
                       explanation: "PUTはリソースの全体置き換えです。`email` を送らないと既存の `email` が消える実装になりがちです。一部フィールドだけ更新したい場合はPATCHを使います。"),
                choice("b", "PUTは送ったフィールドのみ更新し、未送信フィールドは維持する",
                       misconception: "PUTをPATCHと同じと誤解",
                       explanation: "それはPATCHの動作です。PUTは全体置き換えが意図です。"),
                choice("c", "PUTとPATCHは同じエンドポイントに定義できない",
                       misconception: "同じパスにPUTとPATCHが共存できないと誤解",
                       explanation: "同じパスに異なるHTTPメソッドをマッピングすることは可能です。"),
                choice("d", "`@PatchMapping` は Spring Boot 3.xで廃止された",
                       misconception: "PATCHサポートが廃止されたと誤解",
                       explanation: "@PatchMappingはSpring Boot 3.xでも現役です。")
            ],
            explanationRef: "explain-boot3-wmvc-rest-002",
            designIntent: "PUTの全体更新とPATCHの部分更新の違いを理解する。"
        ),
        quiz(
            id: "boot3-wmvc-rest-003",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["Location", "POST", "201 Created", "RESTベストプラクティス"],
            code: """
@PostMapping
ResponseEntity<Void> create(@RequestBody CreateOrderRequest req) {
    Order order = service.create(req);
    URI location = ServletUriComponentsBuilder
        .fromCurrentRequest()
        .path("/{id}")
        .buildAndExpand(order.getId())
        .toUri();
    return ResponseEntity.created(location).build();
}
""",
            question: "`ServletUriComponentsBuilder` を使う目的はどれか？",
            choices: [
                choice("a", "現在のリクエストURLを基準に作成したリソースのURLを動的に組み立て `Location` ヘッダーに設定する",
                       correct: true,
                       explanation: "`POST /orders` を受けて `/orders/42` のLocationヘッダーを組み立てます。ハードコードせず現在のホスト・ポート・コンテキストパスを自動で取り込むのがポイントです。"),
                choice("b", "URLのセキュリティ検証を行う",
                       misconception: "セキュリティ目的と誤解",
                       explanation: "URLの組み立てが目的です。セキュリティ検証は別の仕組みです。"),
                choice("c", "リクエストをリダイレクトする",
                       misconception: "リダイレクトの仕組みと混同",
                       explanation: "リダイレクトではなくレスポンスヘッダーにLocationを追加します。"),
                choice("d", "クライアントのIPアドレスを取得する",
                       misconception: "ServletUriComponentsBuilderがIP取得をすると誤解",
                       explanation: "IPアドレスはHttpServletRequestから取得します。")
            ],
            explanationRef: "explain-boot3-wmvc-rest-003",
            designIntent: "POSTの201レスポンスにServletUriComponentsBuilderでLocationを設定する方法を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-rest-004",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["DTO", "Entity", "Controller層", "分離"],
            code: """
// 悪い例: EntityをControllerで直接返す
@GetMapping("/{id}")
User getUser(@PathVariable Long id) {
    return userRepository.findById(id).orElseThrow();
}

// 良い例: DTOで返す
@GetMapping("/{id}")
UserResponse getUser(@PathVariable Long id) {
    return userService.findById(id); // ServiceがDTO変換
}
""",
            question: "ControllerでEntityを直接返さずDTOを使うべき主な理由はどれか？",
            choices: [
                choice("a", "Entityのパスワードハッシュや内部フィールドを誤って公開してしまうリスクを防げる",
                       correct: true,
                       explanation: "Entityはテーブル全列を持ちます。JSONシリアライズするとパスワードハッシュ・削除フラグなど外部に見せてはいけない情報が漏れます。DTOで必要なフィールドのみを公開します。また循環参照（@OneToMany関係）によるシリアライズエラーも防げます。"),
                choice("b", "SpringはEntityをJSONにシリアライズできない",
                       misconception: "Entityのシリアライズが不可と誤解",
                       explanation: "技術的にはできます。ただしセキュリティ・設計上の問題が起きます。"),
                choice("c", "DTOを使わないとJpaRepositoryが起動しない",
                       misconception: "RepositoryとDTO利用を関連づけて誤解",
                       explanation: "JpaRepositoryの起動とDTOは無関係です。"),
                choice("d", "DTO変換でパフォーマンスが向上する",
                       misconception: "パフォーマンスが主目的と誤解",
                       explanation: "変換のオーバーヘッドは通常無視できます。主目的はセキュリティと責務分離です。")
            ],
            explanationRef: "explain-boot3-wmvc-rest-004",
            designIntent: "ControllerでDTOを使う理由（セキュリティ・責務分離）を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-rest-005",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["冪等性", "GET", "安全性", "副作用"],
            code: """
@GetMapping("/orders/{id}/cancel") // GETでキャンセル操作？
void cancelOrder(@PathVariable Long id) {
    service.cancel(id);
}
""",
            question: "このエンドポイント設計の問題点はどれか？",
            choices: [
                choice("a", "GETは「安全なメソッド」（副作用なし）とされているが、ここでは状態変更（キャンセル）を行っており不適切",
                       correct: true,
                       explanation: "HTTP仕様でGETは冪等かつ安全（副作用なし）であることが期待されます。ブラウザのプリフェッチや検索クローラが予期せずキャンセルを実行する危険性があります。状態変更はPOST/PUT/PATCH/DELETEを使います。"),
                choice("b", "キャンセルはPUTでなければならない",
                       misconception: "キャンセル操作がPUT専用と誤解",
                       explanation: "キャンセルはPOSTが一般的（`POST /orders/42/cancel`）またはDELETE・PATCHも使われます。"),
                choice("c", "GETで `void` を返すとエラーになる",
                       misconception: "GETのvoid戻り値がエラーと誤解",
                       explanation: "voidでも動きますが設計の問題があります。"),
                choice("d", "パスに動詞（cancel）を含めるのはRESTfulで推奨される",
                       misconception: "URLに動詞を入れることを肯定",
                       explanation: "REST設計ではURLはリソース（名詞）で表現し、操作はHTTPメソッドで表現することが推奨です。")
            ],
            explanationRef: "explain-boot3-wmvc-rest-005",
            designIntent: "GETの安全性（副作用なし）の原則とRESTful設計を理解する。"
        ),
        quiz(
            id: "boot3-wmvc-rest-006",
            level: .practice,
            objective: "boot3-practice-layered",
            category: .webMvc,
            tags: ["ページネーション", "@RequestParam", "Pageable", "Spring Data"],
            code: """
@GetMapping("/products")
Page<ProductResponse> list(
    @PageableDefault(size = 20, sort = "createdAt",
                     direction = Sort.Direction.DESC)
    Pageable pageable
) {
    return service.findAll(pageable).map(ProductResponse::from);
}
""",
            question: "`Pageable` 引数を使ったリクエストの例として正しいものはどれか？",
            choices: [
                choice("a", "`GET /products?page=0&size=10&sort=name,asc` — クエリパラメータでページ・サイズ・ソートを制御できる",
                       correct: true,
                       explanation: "Spring Data WebSupportが `Pageable` をクエリパラメータからバインドします。`page`（0始まり）・`size`・`sort=フィールド,方向` で制御できます。`@PageableDefault` はパラメータ省略時のデフォルトです。"),
                choice("b", "ページネーションの設定はapplication.ymlでのみ変更できる",
                       misconception: "クエリパラメータでの制御が不可と誤解",
                       explanation: "クエリパラメータで動的に制御できます。"),
                choice("c", "`Pageable` はDBの設定に応じて自動で無効になる",
                       misconception: "DBがPageableを制御すると誤解",
                       explanation: "PageableはSpring Data層で処理されます。"),
                choice("d", "`page=0` は2ページ目を意味する",
                       misconception: "pageが1始まりと誤解",
                       explanation: "Springのページネーションは0始まりです。`page=0` が1ページ目です。")
            ],
            explanationRef: "explain-boot3-wmvc-rest-006",
            designIntent: "PageableとSpring Data Webサポートによるページネーションを理解する。"
        ),
    ]
}
