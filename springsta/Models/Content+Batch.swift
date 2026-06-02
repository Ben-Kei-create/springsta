import Foundation

extension Quiz {
    static let batchQuizzes: [Quiz] = (
        batchBasics + batchStep + batchScheduling + batchJob
    ).map { $0.contextualizedForPresentation() }

    // MARK: - Spring Batch 基礎
    private static let batchBasics: [Quiz] = [
        quiz(
            id: "boot3-batch-basics-001",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .architecture,
            tags: ["Spring Batch", "Job", "Step", "Chunk"],
            code: """
@Bean
Job importUserJob(JobRepository jobRepository, Step step1) {
    return new JobBuilder("importUserJob", jobRepository)
        .start(step1)
        .build();
}

@Bean
Step step1(JobRepository jobRepository, PlatformTransactionManager txManager,
           ItemReader<User> reader, ItemProcessor<User, UserDto> processor,
           ItemWriter<UserDto> writer) {
    return new StepBuilder("step1", jobRepository)
        .<User, UserDto>chunk(100, txManager)
        .reader(reader)
        .processor(processor)
        .writer(writer)
        .build();
}
""",
            question: "Spring Batchのチャンク指向ステップで`chunk(100, txManager)`が意味することとして正しいものはどれか？",
            choices: [
                choice("a", "100件読み込むごとにprocessor・writerを実行してトランザクションをコミットする", correct: true,
                       explanation: "チャンクサイズは一度にRead→Process→Writeして1トランザクションでコミットする件数です。メモリ効率と障害回復のバランスを取ります。"),
                choice("b", "100スレッドで並列実行する", misconception: "チャンクサイズとスレッド数を混同",
                       explanation: "並列処理にはPartitioningやMultiThreadedStep等の設定が別途必要です。"),
                choice("c", "100件ごとにJobを再起動する", misconception: "チャンクとJobの関係を誤解",
                       explanation: "チャンクはStepの読み書き単位です。Job単位ではありません。"),
                choice("d", "`chunk(100)`はリトライ回数を100に設定する", misconception: "チャンクサイズとリトライを混同",
                       explanation: "リトライ設定は`.faultTolerant().retryLimit(3)`などで行います。")
            ],
            explanationRef: "explain-boot3-batch-basics-001",
            designIntent: "Spring Batchのチャンク指向処理の基本構造を理解する。"
        ),
        quiz(
            id: "boot3-batch-basics-002",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .architecture,
            tags: ["ItemReader", "ItemProcessor", "ItemWriter", "責務分離"],
            code: """
@Bean
FlatFileItemReader<UserCsvRow> reader() {
    return new FlatFileItemReaderBuilder<UserCsvRow>()
        .name("userReader")
        .resource(new ClassPathResource("users.csv"))
        .delimited()
        .names("name", "email", "age")
        .targetType(UserCsvRow.class)
        .build();
}

@Bean
ItemProcessor<UserCsvRow, User> processor() {
    return row -> {
        if (!isValidEmail(row.email())) return null; // nullを返すとskip
        return User.from(row);
    };
}
""",
            question: "`ItemProcessor`でnullを返すと何が起きるか？",
            choices: [
                choice("a", "そのアイテムはスキップされ、writerに渡されない", correct: true,
                       explanation: "`ItemProcessor`がnullを返すとそのitemはフィルタリングされます。バリデーション失敗アイテムを除外する場合に使います。"),
                choice("b", "nullが渡るためwriterでNullPointerExceptionが発生する", misconception: "nullがwriterに到達すると誤解",
                       explanation: "Spring Batchはnullをフィルタリングします。writerにはnullが渡りません。"),
                choice("c", "Step全体が終了する", misconception: "nullリターンをStep終了と誤解",
                       explanation: "nullはそのアイテムのスキップです。Stepは次のアイテムの処理を続けます。"),
                choice("d", "`ItemProcessor`でnullを返すことは禁止されている", misconception: "nullリターンが不正と誤解",
                       explanation: "フィルタリングのためにnullを返すことは仕様として定義されています。")
            ],
            explanationRef: "explain-boot3-batch-basics-002",
            designIntent: "ItemProcessorのnullリターンによるフィルタリング動作を理解する。"
        ),
        quiz(
            id: "boot3-batch-basics-003",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .architecture,
            tags: ["JobRepository", "JobExecution", "リスタート"],
            code: """
// 同じJobNameとJobParametersで再実行した場合の動作
Job importJob = ... // allowStartIfComplete: false (デフォルト)
""",
            question: "Spring Batchの`JobRepository`とジョブの再実行について正しいものはどれか？",
            choices: [
                choice("a", "デフォルトでは同じJobNameと同じJobParametersのJobは1度しか成功実行できない。再実行にはタイムスタンプなどパラメータを変えるか`allowStartIfComplete(true)`が必要", correct: true,
                       explanation: "`JobRepository`は実行履歴を管理します。デフォルトでCOMPLETEDの実行に対して同一パラメータでの再実行を防ぎます。"),
                choice("b", "Spring Batchは毎回Jobの履歴を破棄する", misconception: "JobRepositoryの永続性を誤解",
                       explanation: "`JobRepository`はDB（または`MapJobRepository`でインメモリ）に実行状態を保存します。"),
                choice("c", "FAILEDでも同じパラメータでの再実行はできない", misconception: "FAILEDジョブの再実行可否を誤解",
                       explanation: "FAILEDのJobは同じパラメータで再実行（リスタート）できます。途中からの再開（前回失敗ステップから）も可能です。"),
                choice("d", "`JobRepository`はBeanを定義しなくてもSpring Bootが自動設定しない", misconception: "Spring BootのBatch自動設定を見落としている",
                       explanation: "`spring-boot-starter-batch`を入れるとJobRepositoryを含むBatch基盤が自動設定されます。")
            ],
            explanationRef: "explain-boot3-batch-basics-003",
            designIntent: "JobRepositoryによる実行履歴管理とジョブの再実行ルールを理解する。"
        ),
        quiz(
            id: "boot3-batch-basics-004",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .architecture,
            tags: ["faultTolerant", "skip", "retry", "障害処理"],
            code: """
.<CsvRow, User>chunk(100, txManager)
.reader(reader)
.processor(processor)
.writer(writer)
.faultTolerant()
    .skipLimit(10)
    .skip(MalformedDataException.class)
    .retryLimit(3)
    .retry(TransientDataAccessException.class)
.build()
""",
            question: "この設定でTransientDataAccessExceptionが発生した場合の動作として正しいものはどれか？",
            choices: [
                choice("a", "1チャンク内で最大3回リトライし、3回失敗してもskip対象でなければStepが失敗する", correct: true,
                       explanation: "`retry`はチャンクレベルで失敗したら再試行します。`retryLimit`を超えたらその例外はスキップされるか（skip設定あれば）、Stepが失敗します。"),
                choice("b", "`skipLimit(10)`の範囲内なら`TransientDataAccessException`もスキップされる", misconception: "skipとretryの適用例外クラスの独立性を見落としている",
                       explanation: "`skip`対象の例外クラスと`retry`対象は独立して設定します。このコードではskipはMalformedDataException限定です。"),
                choice("c", "フォールトトレラントを設定するとすべての例外がスキップされる", misconception: "faultTolerantが全例外をスキップすると誤解",
                       explanation: "`faultTolerant()`はskip/retryの設定を有効にするだけです。スキップ/リトライは明示したクラスのみが対象です。"),
                choice("d", "`retry`を使うとトランザクションが保存されずにロールバックされる", misconception: "retryとトランザクションの動作を誤解",
                       explanation: "チャンクが失敗してリトライされる場合、そのチャンクはロールバックされて再試行されます。")
            ],
            explanationRef: "explain-boot3-batch-basics-004",
            designIntent: "Spring Batchのfaulttolerant設定でskipとretryを使い分ける。"
        ),
    ]

    // MARK: - Step設計 / Partitioning
    private static let batchStep: [Quiz] = [
        quiz(
            id: "boot3-batch-step-001",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .architecture,
            tags: ["Partitioning", "並列処理", "Tasklet"],
            code: """
@Bean
Step partitionedStep(JobRepository jobRepository,
                     PartitionHandler handler,
                     Partitioner partitioner) {
    return new StepBuilder("partitionedStep", jobRepository)
        .partitioner("workerStep", partitioner)
        .partitionHandler(handler)
        .gridSize(4)
        .build();
}
""",
            question: "Spring BatchのPartitioningステップの目的として正しいものはどれか？",
            choices: [
                choice("a", "データを複数のパーティションに分割し、gridSize分の並列Stepで処理することで大量データの処理を高速化する", correct: true,
                       explanation: "`gridSize(4)`で4つのWorker Stepが並列実行されます。ローカルマルチスレッドまたはリモートワーカーへの分散が可能です。"),
                choice("b", "`gridSize`はチャンクサイズと同じ意味", misconception: "gridSizeとchunkSizeを混同",
                       explanation: "`gridSize`はパーティション（並列Worker）の数を表します。チャンクサイズとは別の概念です。"),
                choice("c", "Partitioningは必ず別のJVMプロセスで実行される", misconception: "ローカル/リモートパーティションを混同",
                       explanation: "`ThreadPoolPartitionHandler`を使えば同一JVM内のスレッドで並列実行できます。"),
                choice("d", "Partitioningを使うとJobRepositoryが不要になる", misconception: "Partitioningの設定を誤解",
                       explanation: "`JobRepository`はPartitioningでも必要で、各パーティションの実行状態を記録します。")
            ],
            explanationRef: "explain-boot3-batch-step-001",
            designIntent: "Spring BatchのPartitioningによる並列処理の仕組みを理解する。"
        ),
    ]

    // MARK: - @Scheduled / スケジューリング
    private static let batchScheduling: [Quiz] = [
        quiz(
            id: "boot3-batch-schedule-001",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .observability,
            tags: ["@Scheduled", "@EnableScheduling", "cron", "fixedRate"],
            code: """
@Component
class ReportScheduler {
    @Scheduled(cron = "0 0 2 * * *")  // 毎日深夜2時
    void dailyReport() {
        reportService.generate();
    }

    @Scheduled(fixedRate = 60_000)  // 1分ごと
    void healthCheck() {
        monitoringService.check();
    }
}

@SpringBootApplication
@EnableScheduling
class App {}
""",
            question: "`@Scheduled`の`cron`と`fixedRate`の違いとして正しいものはどれか？",
            choices: [
                choice("a", "`cron`は指定した日時に実行し、`fixedRate`は前回実行開始からの一定間隔で繰り返す", correct: true,
                       explanation: "`cron`は「秒 分 時 日 月 曜日」で実行時刻を指定します。`fixedRate`はミリ秒単位で前回実行開始から次の実行を計算します。"),
                choice("b", "`fixedRate`は前回の処理が終わってから次を起動する", misconception: "fixedRateとfixedDelayを混同",
                       explanation: "前回処理完了後の一定間隔は`fixedDelay`です。`fixedRate`は前回開始時刻から次の開始を計算するため、処理が長引くと重複します。"),
                choice("c", "`@EnableScheduling`は`@SpringBootApplication`に含まれているため不要", misconception: "@EnableSchedulingの必要性を見落としている",
                       explanation: "`@EnableScheduling`は明示的に付ける必要があります。"),
                choice("d", "`@Scheduled`は別スレッドプールなしに常に並列実行される", misconception: "デフォルトのスケジューラースレッドを誤解",
                       explanation: "デフォルトは単一スレッドです。並列実行には`TaskScheduler`をカスタム設定します。")
            ],
            explanationRef: "explain-boot3-batch-schedule-001",
            designIntent: "@ScheduledのcronとfixedRate/fixedDelayの違いを理解する。"
        ),
        quiz(
            id: "boot3-batch-schedule-002",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .observability,
            tags: ["@Scheduled", "分散環境", "ShedLock", "重複実行防止"],
            code: """
// 複数インスタンス環境での@Scheduled問題
@Scheduled(fixedRate = 60_000)
void dailyCleanup() {
    // インスタンスが3台あれば、3台同時に実行される
    cleanupService.deleteExpiredData();
}
""",
            question: "複数インスタンスで`@Scheduled`が全インスタンスで実行される問題の対処として正しいものはどれか？",
            choices: [
                choice("a", "ShedLockなどの分散ロックライブラリを使い、DBにロックを確保したインスタンスのみ実行する", correct: true,
                       explanation: "`@Scheduled`はJVM内のスケジューラーでインスタンス数分実行されます。ShedLockはDB/Redis等でロックを管理して重複実行を防ぎます。"),
                choice("b", "`@Scheduled`はクラスター環境を検知して自動でリーダーが実行する", misconception: "@Scheduledの自動クラスタリングを誤解",
                       explanation: "`@Scheduled`はクラスター認識機能を持ちません。単純にインスタンス数分実行されます。"),
                choice("c", "Kubernetes環境では1Podにしかデプロイできない", misconception: "インスタンス数とバッチを混同",
                       explanation: "Kubernetesでも複数レプリカが可能です。スケジュールジョブには`CronJob`リソースを使う方法もあります。"),
                choice("d", "`@Primary`を付けることで1インスタンスのみ実行される", misconception: "@Primaryがクラスター調整に使えると誤解",
                       explanation: "`@Primary`はBean候補の優先付けで、実行インスタンスの調整には使えません。")
            ],
            explanationRef: "explain-boot3-batch-schedule-002",
            designIntent: "複数インスタンス環境での@Scheduledの重複実行問題と対策を理解する。"
        ),
    ]

    // MARK: - JobLauncher / JobParameters
    private static let batchJob: [Quiz] = [
        quiz(
            id: "boot3-batch-job-001",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .architecture,
            tags: ["JobLauncher", "JobParameters", "プログラム起動"],
            code: """
@RestController
class BatchTriggerController {
    private final JobLauncher jobLauncher;
    private final Job importJob;

    @PostMapping("/batch/import")
    void trigger() throws JobExecutionException {
        JobParameters params = new JobParametersBuilder()
            .addLocalDateTime("runAt", LocalDateTime.now())
            .toJobParameters();
        jobLauncher.run(importJob, params);
    }
}
""",
            question: "`JobParameters`にタイムスタンプを含める理由として正しいものはどれか？",
            choices: [
                choice("a", "同一JobNameで毎回ユニークなパラメータを持つことで、繰り返し実行を可能にするため", correct: true,
                       explanation: "同じJobNameとJobParametersでは2回目以降の実行が`JobInstanceAlreadyCompleteException`になります。タイムスタンプを付けることでユニーク性を確保します。"),
                choice("b", "パラメータがないとJobが起動しない", misconception: "JobParametersの必須性を誤解",
                       explanation: "空のJobParametersでも起動できますが、再実行ができなくなります。"),
                choice("c", "`addLocalDateTime`はSpring Boot 2.xでは使えない", misconception: "JobParametersのAPIを誤解",
                       explanation: "`JobParametersBuilder`はSpring Batchの機能です。バージョンによって`addDate`等のAPIが異なります。"),
                choice("d", "タイムスタンプパラメータはジョブ内で参照できない", misconception: "JobParametersのStep内参照を誤解",
                       explanation: "`@Value(\"#{jobParameters['runAt']}\")` でStep内でもJobParametersを参照できます。")
            ],
            explanationRef: "explain-boot3-batch-job-001",
            designIntent: "JobParametersのユニーク性とJobの繰り返し実行可能設計を理解する。"
        ),
        quiz(
            id: "boot3-batch-job-002",
            level: .practice,
            objective: "boot3-practice-batch",
            category: .architecture,
            tags: ["JobExecutionListener", "Listener", "Before/After"],
            code: """
@Component
class JobNotificationListener implements JobExecutionListener {
    @Override
    public void beforeJob(JobExecution jobExecution) {
        log.info("Job started: {}", jobExecution.getJobInstance().getJobName());
    }

    @Override
    public void afterJob(JobExecution jobExecution) {
        if (jobExecution.getStatus() == BatchStatus.COMPLETED) {
            slackService.notify("バッチ完了");
        } else {
            slackService.alert("バッチ失敗！");
        }
    }
}
""",
            question: "`JobExecutionListener`の役割として正しいものはどれか？",
            choices: [
                choice("a", "Job開始前後のフックポイントを提供し、通知・ログ・前処理/後処理を一元化できる", correct: true,
                       explanation: "`beforeJob`/`afterJob`でJob横断の処理（通知、DBクリーンアップ等）を実装できます。`JobExecutionListener`の他にも`StepExecutionListener`があります。"),
                choice("b", "`JobExecutionListener`はStepの読み書きに割り込む", misconception: "JobとStep Listenerを混同",
                       explanation: "読み書きに割り込むのは`ItemReadListener`/`ItemWriteListener`/`ItemProcessListener`です。"),
                choice("c", "`afterJob`はジョブがCOMPLETEDの場合のみ呼ばれる", misconception: "afterJobの実行条件を誤解",
                       explanation: "`afterJob`はジョブの成功/失敗問わず呼ばれます。`jobExecution.getStatus()`で状態を判定します。"),
                choice("d", "`JobExecutionListener`を使うには`@EnableBatchProcessing`が必要", misconception: "Listenerの有効化条件を誤解",
                       explanation: "`JobExecutionListener`を実装してBeanにするだけで自動検出されます。")
            ],
            explanationRef: "explain-boot3-batch-job-002",
            designIntent: "JobExecutionListenerによるバッチジョブの前後処理を理解する。"
        ),
    ]
}
