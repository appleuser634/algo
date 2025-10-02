const std = @import("std");
const print = std.debug.print;

const record = struct {
    key: i32,
    data: i32,
};

const table_len = 100;
var table: [table_len]record = undefined;

pub fn init_table() void {
    for (table[0..], 0..) |*entry, idx| {
        const key: i32 = @intCast(idx);
        entry.* = .{ .key = key, .data = key * 123 };
    }
}

pub fn binary_search(key: i32) i32 {
    var low: usize = 0;
    var high: usize = table_len - 1;

    while (low <= high) {
        const mid = (high + low) / 2;
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

pub fn main() !void {
    init_table();
    const result = binary_search(88);
    print("result:{any}\n", .{result});
}
