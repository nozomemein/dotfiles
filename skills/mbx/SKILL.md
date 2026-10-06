---
name: mbx
description: Rustの作業でCargo（cargo）を実行する前に使う。build・test・check・clippy・nextest・fmt・metadata・cleanなど、直接実行とjust・task・script経由の実行を含む。mbxの導入有無は読み込んだ後に確認し、導入済みならそのセッションのCargoをmbx経由に統一、未導入なら通常Cargoで続行する。worktreeのtarget移行やRustの容量・GC調査にも使う。
---

# mbx

Cargoを使う作業では、mbxの有無がまだ分からなくてもこのskillを読む。導入済みと確認できたら、そのセッションではmbxをCargoの起動経路にする。成果物キャッシュとtargetの管理を区別し、実行時のshim・PATH・mbx設定をこのdotfiles repoへ追加しない。

## セッションの起動経路を決める

初回のCargo実行前に、実行する環境で `command -v mbx` と `mbx --version` を確認する。Macでの確認をVMやcontainerの確認として流用しない。

- mbxが見つからなければ、このskillの残りを適用せず通常のCargoで続行する。ユーザーが導入を依頼していない限り、インストールや設定変更を持ち込まない。
- mbxを実行できたら、そのセッション・実行環境の方針を「mbx経由」として保持する。以降のCargo実行ごとに導入判定をやり直す必要はない。別host / VM / containerへ移った場合はその環境で判定する。
- mbxが見つかるが起動に失敗する場合は、未導入と同一視せず原因を確認する。導入済みと判定した後も、エラーを理由に黙ってplain Cargoへ切り替えない。

## 導入済みセッションでのCargo実行

- `command -v cargo` と必要に応じて `mbx doctor` で起動経路を確認する。公式shimが有効なら通常の `cargo` を使う。shellのPATHがまだplain Cargoを指す場合は、`cargo build ...` を `mbx build ...`、`cargo test ...` を `mbx test ...` のように明示実行してmbx経由を維持できる。コンパイルしないCargoコマンドの扱いも、mbx自身のpassthroughに任せる。
- shell commandごとに環境が作り直されるtoolでは、一度の `export PATH=...` が次の呼び出しにも残ると仮定しない。公式shimのPATHを各呼び出しに継承させるか、明示的な `mbx <Cargo subcommand>` を使う。
- just・task・scriptがCargoを起動する場合も、子プロセスへ公式shimのPATHを渡す。新しいshellでの確認だけでは、起動済みのagentやeditorが同じPATHを使う証拠にはならない。shimが未準備なら、依頼された作業のCargoコマンドを明示mbx経由で実行する方法を選ぶ。
- plain Cargoでの比較をユーザーが指定した場合など、作業上必要な迂回は区別して記録する。それ以外では `~/.cargo/bin/cargo` の直指定や `MBX_DISABLE=1` を使わない。
- 起動経路を揃えるためだけにrepoのjustfileや自作の振り分けスクリプトを追加しない。miseも必須にしない。永続的な導入・有効化が依頼範囲に含まれる場合は `mbx setup` と公式shimのPATHを設定し、global設定は `mbx settings` で管理する。容量予算やmachine固有のpathは現地の設定から確認する。

## targetが管理下にあるか

キャッシュのhitが出ても、そのtargetが自動GC対象であるとは限らない。

1. 実行するCargoコマンドのworkspaceと出力先を確認する。`cargo metadata --no-deps --format-version 1` の `workspace_root` / `target_directory`、コマンドの引数、`CARGO_TARGET_DIR`、Cargo設定の `build.target-dir` を見る。`--manifest-path` などがあれば同じworkspaceを調べる。
2. 出力先の実体を確認する。通常のmanaged targetは `target -> <target.root>/v1/<digest>` というリンクであり、現在のtarget rootは `mbx settings get target.root` や `mbx doctor` で確認できる。repo内の通常directoryを管理下と決めつけない。
3. 出力先を変更する必要がなければ `--target-dir` や `CARGO_TARGET_DIR` を追加しない。一般の明示targetは自動配置・check laneを使わず、管理下の外にある指定先の回収は利用者が担当する。既存のmanaged targetやそのリンク内を指定した場合はGC対象に含まれるため、指定の有無だけで判断しない。デバッガやサービスが安定した出力を必要とする場合は、その理由と回収方法を残す。
4. 実directoryが残る場合は `mbx adopt --dry-run /absolute/path/to/workspace` で移行可否を調べる。移行が依頼範囲に含まれる場合、利用中のCargoとの競合を確認して `mbx adopt /absolute/path/to/workspace` で内容を保持したまま管理下へ移す。次の通常mbx buildでも条件が合えば自動移行される。adoptだけでは使用容量は減らず、その後のGC対象になる。

公式setupのrust-analyzer出力には例外がある。1.22.0では `--target-dir target/rust-analyzer` の親targetを管理下に置く処理があるため、引数だけを見て回収対象外と判断しない。実際の親targetのリンクと、使用中のversionの挙動を確認する。

MacとLinuxがsourceを共有する場合は、それぞれのcache / targetを分ける。片方のOS用targetリンクをもう片方のOS向けに付け替えない。VM専用の明示targetを使う場合、その出力の回収はmanaged targetのGCに任せられない。

## 容量調査と回収

まず以下で現状と削除なしの試算を調べる。

```bash
mbx cache stats --json
mbx cache projects
mbx settings ls gc
mbx gc --dry-run --json
```

- cache配下のaction store / managed targetと、repo内の通常target、過去の明示target、VM diskを分けて測る。GCは任意のrepo内のtargetを探索して削除する仕組みではない。
- `gc.max_total_size` は回収目標であり、disk quotaではない。active / 最新 / 保護された出力とビルド中の増加で超過し得る。1.22.0の通常の自動GCはビルド終了時にintervalの経過を判定するため、`gc.auto=true` だけで即時回収を期待しない。最終GCの時刻・logと実際の設定を照合する。
- `mbx cache stats` / GC reportのサイズはlogicalであり、`du`の割当量や `df` の物理空きと同一ではない。APFS clone / hard linkもあるため、project別の共有cache量を単純合算しない。VMの仮想disk容量とhost上の実割当も区別する。
- 調査だけの依頼では試算までにする。回収が依頼範囲に含まれる場合は、managed dataに `mbx gc`、特定workspaceのmanaged targetに `mbx clean` を使う。管理外のtargetは使用終了を確認したうえで、対応するCargoの `clean --target-dir` などで回収する。稼働中のサービス、デバッガ、proc-macro serverが使う出力も確認する。
- 回収後は `df` と容量を測り直す。継続するbuildがある場合、削除量をそのまま物理解放量として報告しない。設定を見直すなら `mbx settings set` を使い、GC間隔の短縮で厳密な容量上限を保証したとは扱わない。

CLIや仕様が異なる場合は、インストール済みversionの `--help` を優先し、必要に応じて[公式のmanaged target仕様](https://mr-boxington.jdx.dev/managed-targets)と[設定仕様](https://mr-boxington.jdx.dev/configuration)を確認する。
