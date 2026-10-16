# C#学習用リポジトリ

## 目的

C#の応用的な文法を学ぶためのリポジトリ

## 学習の進め方

単元ごとにブランチを作成し、学習を進めていく

各ブランチの成果物として、`notes/` に学習ノート (.md) を作成する

学習ノートはGitHub Wikiと自動同期するようになっている

### 単元一覧

※ 変更の可能性あり

| # | ブランチ名 | テーマ |
| --- | --- | --- |
| 00 | `unit/00-setup` | ソリューション構成と学習テスト環境 |
| 01 | `unit/01-types` | 値型と参照型、`struct`、`var`、`ref` / `out` |
| 02 | `unit/02-classes` | クラス設計、`virtual` / `override`、`internal`、`partial` |
| 03 | `unit/03-properties` | プロパティ深掘り（`init`、`required`、`field` キーワード）、プライマリコンストラクタ |
| 04 | `unit/04-project` | 名前空間、`using` の意味、`global using`、トップレベルステートメント |
| 05 | `unit/05-exceptions` | 例外と `IDisposable` / `using` |
| 06 | `unit/06-delegates` | デリゲート、`Func` / `Action`、ラムダ、イベント |
| 07 | `unit/07-generics` | ジェネリクス制約 `where`、コレクション、`IEnumerable`、`yield return` |
| 08 | `unit/08-extensions` | 拡張メソッド、C#14の拡張メンバー |
| 09 | `unit/09-linq` | LINQ（メソッド構文中心）、遅延評価 |
| 10 | `unit/10-records` | `record`、パターンマッチ、`switch` 式、タプルと分解 |
| 11 | `unit/11-async` | `async` / `await`、`Task`、`CancellationToken` |
| 12 | `unit/12-capstone` | `dotnet new webapi` の生成コード解剖 |
