# binary_search.zigの構文と使用している言語機能

このドキュメントでは `binary_search.zig` の実装がどのように構成され、Zigのどの構文や標準ライブラリ機能を利用しているかを説明します。

## ファイル全体の概要

```zig
const std = @import("std");
const print = std.debug.print;

const record = struct {
    key: i32,
    data: i32,
};

const table_len = 100;
var table: [table_len]record = undefined;

pub fn init_table() void { ... }
pub fn binary_search(key: i32) i32 { ... }
pub fn main() !void { ... }
```

- `@import` は他モジュールを読み込むコンパイル時関数で、ここでは標準ライブラリ `std` を利用するために使用しています。
- `const print = std.debug.print;` のように `const` で関数をエイリアスすることで、以降の呼び出しを簡潔にしています。
- `struct` 宣言で `record` 型を定義し、配列 `table` の要素に使用しています。
- 配列長は `const table_len = 100;` で定数化し、配列宣言 `var table: [table_len]record = undefined;` に利用しています。`undefined` の初期化は後続の処理で必ず埋める前提です。

## `init_table`: テーブルの初期化

```zig
pub fn init_table() void {
    for (table[0..], 0..) |*entry, idx| {
        const key: i32 = @intCast(idx);
        entry.* = .{ .key = key, .data = key * 123 };
    }
}
```

- `pub fn` は公開関数を表します。戻り値型が `void` なので失敗しない処理であることを示します。
- `for (table[0..], 0..) |*entry, idx|` は二重イテレーション構文で、最初の引数にスライス（`table[0..]`）を、二番目にインデックス範囲（`0..`）を指定しています。`|*entry, idx|` で各要素へのポインタとインデックス値を同時に受け取ります。
- `@intCast(idx)` はコンパイル時組み込み関数で、`usize` から `i32` への明示的キャストを行います。
- `.{ .key = key, .data = key * 123 }` という構文は匿名構造体リテラルで、ここでは `record` 型と互換であるため代入可能です。`entry.*` に代入することでポインタ参照先の値を更新しています。

## `binary_search`: 二分探索本体

```zig
pub fn binary_search(key: i32) i32 {
    var low: usize = 0;
    var high: usize = table_len - 1;

    while (low <= high) {
        const mid = low + (high - low) / 2;
        const mid_key = table[mid].key;

        if (key == mid_key) {
            return table[mid].data;
        } else if (key < mid_key) {
            if (mid == 0) break;
            high = mid - 1;
        } else {
            low = mid + 1;
        }
    }

    return -1;
}
```

- 返り値を `i32` とすることで、見つかったときは `data` を、見つからなければ `-1` を返します。
- `low`/`high` は `usize` 型で宣言しています。配列の添え字として安全であり、計算時のオーバーフローを防ぐため `(high - low)` を先に計算する形で中央位置を求めています。
- `while` ループ内で `const mid = ...` のようにブロックスコープ内変数を定義できます。
- Zigの `if` 文は式ではなくステートメントです。複合条件を `else if` で連鎖させる点は多くの言語と同様です。
- `mid == 0` の判定は、`usize` で 0 未満への減算が未定義動作となることを避けるガードです。

## `main`: エントリポイント

```zig
pub fn main() !void {
    init_table();
    const result = binary_search(88);
    print("result:{any}\n", .{result});
}
```

- Zigの `main` は `pub fn main() !void` の形を取ります。`!void` は「例外的なエラーを返す可能性がある `void`」というエラーユニオン型ですが、ここでは実際にエラーを返していないため、`init_table()` を直接呼んでいます。
- `print` は `std.debug.print` のエイリアスで、`printf` のように書式文字列とタプル（`.{result}`）を受け取ります。`{any}` は型推論つきのプレースホルダです。

## 主な言語機能のまとめ

- **コンパイル時関数**: `@import`, `@intCast`
- **複合リテラル**: `.{ .field = value }` を使った構造体初期化
- **forループの複数イテレータ**: `for (slice, index_range) |*elem, idx|`
- **エラーハンドリング**: `main` のシグネチャで `!void` を使用しつつ、今回の処理ではエラーを発生させていません。
- **標準ライブラリ呼び出し**: `std.debug.print` によるデバッグ出力

Zigの基本構文と低水準寄りの安全性（ポインタ操作や明示的キャスト）が組み合わさった良い例となっています。
