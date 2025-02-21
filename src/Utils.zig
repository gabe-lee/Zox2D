const std = @import("std");
const math = std.math;
const build_mode = @import("builtin").mode;
const Type = std.builtin.Type;

/// Options controlling how assertions are handled in code
pub const AssertPackageOptions = struct {
    /// A boolean epression that controls when failed assertions result in a `@panic` with a message
    ///
    /// If it evaluates to false, failed assertions are considered `unreachable`
    assert_enabled_condition: bool = build_mode == .Debug or build_mode == .ReleaseSafe,
    /// Controls the difference between two floats within which they will be considered 'approximately equal'
    float_approx_threshold: f64 = math.floatEps(f32),
    /// Controls the difference between two integers within which they will be considered 'approximately equal'
    ///
    /// Usually 0, unless you actually want to allow integers to be asserted as approximately equal
    int_approx_threshold: u64 = 0,
};

pub fn define_assert_package_with_options(comptime options: AssertPackageOptions) type {
    return struct {
        const SHOULD_ASSERT = options.assert_enabled_condition;
        const F_APPROX_THRESHOLD = options.float_approx_threshold;
        const I_APPROX_THRESHOLD = options.int_approx_threshold;
        const approx = struct {
            pub inline fn less_than_or_equal_to(a: anytype, b: anytype) bool {
                if (@typeInfo(b) == .Float or @typeInfo(b) == .ComptimeFloat) {
                    return a <= b + F_APPROX_THRESHOLD;
                } else if (@typeInfo(a) == .Float or @typeInfo(a) == .ComptimeFloat) {
                    return a - F_APPROX_THRESHOLD <= b;
                } else if ((@typeInfo(a) == .Int or @typeInfo(a) == .ComptimeInt) and (@typeInfo(b) == .Int or @typeInfo(b) == .ComptimeInt)) {
                    return a <= b + I_APPROX_THRESHOLD;
                } else {
                    @compileError("invalid types for approx.less_than_or_equal_to");
                }
            }
            pub inline fn less_than(a: anytype, b: anytype) bool {
                if (@typeInfo(b) == .Float or @typeInfo(b) == .ComptimeFloat) {
                    return a < b + F_APPROX_THRESHOLD;
                } else if (@typeInfo(a) == .Float or @typeInfo(a) == .ComptimeFloat) {
                    return a - F_APPROX_THRESHOLD < b;
                } else if ((@typeInfo(a) == .Int or @typeInfo(a) == .ComptimeInt) and (@typeInfo(b) == .Int or @typeInfo(b) == .ComptimeInt)) {
                    return a < b + I_APPROX_THRESHOLD;
                } else {
                    @compileError("invalid types for approx.less_than");
                }
            }
            pub inline fn greater_than_or_equal_to(a: anytype, b: anytype) bool {
                if (@typeInfo(b) == .Float or @typeInfo(b) == .ComptimeFloat) {
                    return a >= b - F_APPROX_THRESHOLD;
                } else if (@typeInfo(a) == .Float or @typeInfo(a) == .ComptimeFloat) {
                    return a + F_APPROX_THRESHOLD >= b;
                } else if ((@typeInfo(a) == .Int or @typeInfo(a) == .ComptimeInt) and (@typeInfo(b) == .Int or @typeInfo(b) == .ComptimeInt)) {
                    return a >= b - I_APPROX_THRESHOLD;
                } else {
                    @compileError("invalid types for approx.greater_than_or_equal_to");
                }
            }
            pub inline fn greater_than(a: anytype, b: anytype) bool {
                if (@typeInfo(b) == .Float or @typeInfo(b) == .ComptimeFloat) {
                    return a > b - F_APPROX_THRESHOLD;
                } else if (@typeInfo(a) == .Float or @typeInfo(a) == .ComptimeFloat) {
                    return a + F_APPROX_THRESHOLD > b;
                } else if ((@typeInfo(a) == .Int or @typeInfo(a) == .ComptimeInt) and (@typeInfo(b) == .Int or @typeInfo(b) == .ComptimeInt)) {
                    return a > b - I_APPROX_THRESHOLD;
                } else {
                    @compileError("invalid types for approx.greater_than");
                }
            }
            pub inline fn equal(a: anytype, b: anytype) bool {
                const abs_diff = @abs(b - a);
                if (@typeInfo(b) == .Float or @typeInfo(b) == .ComptimeFloat or @typeInfo(a) == .Float or @typeInfo(a) == .ComptimeFloat) {
                    return abs_diff < F_APPROX_THRESHOLD;
                } else if ((@typeInfo(a) == .Int or @typeInfo(a) == .ComptimeInt) and (@typeInfo(b) == .Int or @typeInfo(b) == .ComptimeInt)) {
                    return abs_diff < I_APPROX_THRESHOLD;
                } else {
                    @compileError("invalid types for approx.equal");
                }
            }
        };

        /// assert: this code is never reached
        pub fn is_unreachable(comptime reason: []const u8) void {
            if (SHOULD_ASSERT) {
                std.debug.panic("\nASSERT FAILURE\n\t(expecteded unreachable point in code)\n\t{s}\n", .{reason});
            }
            unreachable;
        }

        /// assert: COND == true
        pub fn is_true(comptime cond_name: []const u8, cond: bool, comptime reason: []const u8) void {
            if (!cond) {
                if (SHOULD_ASSERT) {
                    std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} == true\n\texpected {} == true\n", .{ reason, cond_name, cond });
                }
                unreachable;
            }
        }

        /// assert: COND == false
        pub fn is_false(comptime cond_name: []const u8, cond: bool, comptime reason: []const u8) void {
            if (cond) {
                if (SHOULD_ASSERT) {
                    std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} == false\n\texpected {} == false\n", .{ reason, cond_name, cond });
                }
                unreachable;
            }
        }

        // assert: A == B
        pub fn equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a != b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} == {s}\n\texpected {d} == {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                .Bool => {
                    if (a != b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} == {s}\n\texpected {} == {}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert: A == B == C
        pub fn all_3_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a != c or b != c) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} == {s} == {s} \n\texpected {d} == {d} == {d}\n", .{ reason, name_a, name_b, name_c, a, b, c });
                        }
                        unreachable;
                    }
                },
                .Bool => {
                    if (a != c or b != c) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} == {s} == {s}\n\texpected {} == {} == {}\n", .{ reason, name_a, name_b, name_c, a, b, c });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert: A != b
        pub fn not_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a == b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} != {s}\n\texpected {d} != {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                .Bool => {
                    if (a == b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} != {s}\n\texpected {} != {}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert: A != B != C
        pub fn all_3_not_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a == c or b == c or a == b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} != {s} != {s}\n\texpected {d} != {d} != {d}\n", .{ reason, name_a, name_b, name_c, a, b, c });
                        }
                        unreachable;
                    }
                },
                .Bool => {
                    if (a == c or b == c or a == b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} != {s} != {s}\n\texpected {} != {} != {}\n", .{ reason, name_a, name_b, name_c, a, b, c });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert: A != C and B != C
        pub fn neither_equals(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a == c or b == c) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} != {s} and {s} != {s}\n\texpected {d} != {d} and {d} != {d}\n", .{ reason, name_a, name_c, name_b, name_c, a, c, b, c });
                        }
                        unreachable;
                    }
                },
                .Bool => {
                    if (a == c or b == c) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} != {s} and {s} != {s}\n\texpected {} != {} and {} != {}\n", .{ reason, name_a, name_c, name_b, name_c, a, c, b, c });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert: A != B and C != D
        pub fn neither_pair_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime name_d: []const u8, d: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a == b or c == d) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} != {s} and {s} != {s}\n\texpected {d} != {d} and {d} != {d}\n", .{ reason, name_a, name_b, name_c, name_d, a, b, c, d });
                        }
                        unreachable;
                    }
                },
                .Bool => {
                    if (a == b or c == d) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} != {s} and {s} != {s}\n\texpected {} != {} and {} != {}\n", .{ reason, name_a, name_b, name_c, name_d, a, b, c, d });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert: A == B and C == D
        pub fn both_pairs_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime name_d: []const u8, d: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a != b or c != d) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} == {s} and {s} == {s}\n\texpected {d} == {d} and {d} == {d}\n", .{ reason, name_a, name_b, name_c, name_d, a, b, c, d });
                        }
                        unreachable;
                    }
                },
                .Bool => {
                    if (a != b or c != d) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} == {s} and {s} == {s}\n\texpected {} == {} and {} == {}\n", .{ reason, name_a, name_b, name_c, name_d, a, b, c, d });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.both_pairs_equal\n"),
            }
        }

        /// assert approximately (float epsilon): A == B and C == D
        pub fn both_pairs_approx_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime name_d: []const u8, d: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (!approx.equal(a, b) or !approx.equal(c, d)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} == {s} and {s} == {s}\n\texpected (approx) {d} == {d} and {d} == {d}\n", .{ reason, name_a, name_b, name_c, name_d, a, b, c, d });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.both_pairs_approx_equal\n"),
            }
        }

        /// assert approximately (float epsilon): A == B
        pub fn approx_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (!approx.equal(a, b)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} == {s}\n\texpected (approx) {d} == {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert approximately (float epsilon): A == B == C
        pub fn all_3_approx_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (!approx.equal(a, c) or !approx.equal(b, c)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} == {s} == {s}\n\texpected (approx) {d} == {d} = {d}\n", .{ reason, name_a, name_b, name_c, a, b, c });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert approximately (float epsilon): A != B
        pub fn not_approx_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (approx.equal(a, b)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} != {s}\n\texpected (approx) {d} != {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert approximately (float epsilon): A != B != C
        pub fn all_3_not_approx_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (approx.equal(a, c) or approx.equal(b, c) or approx.equal(a, b)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} != {s} != {s}\n\texpected (approx) {d} != {d} != {d}\n", .{ reason, name_a, name_b, name_c, a, b, c });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert approximately (float epsilon): A != C and B != C
        pub fn neither_approx_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (approx.equal(a, c) or approx.equal(b, c)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} != {s} and {s} != {s}\n\texpected (approx) {d} != {d} and {d} != {d}\n", .{ reason, name_a, name_c, name_b, name_c, a, c, b, c });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert approximately (float epsilon): A != B and C != D
        pub fn neither_pair_approx_equal(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime name_c: []const u8, c: anytype, comptime name_d: []const u8, d: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (approx.equal(a, b) or approx.equal(c, d)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} != {s} and {s} != {s}\n\texpected (approx) {d} != {d} and {d} != {d}\n", .{ reason, name_a, name_b, name_c, name_d, a, b, c, d });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.neither_pair_approx_equal\n"),
            }
        }

        /// assert: a < b
        pub fn less_than(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a >= b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} < {s}\n\texpected {d} < {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.less_than\n"),
            }
        }

        pub fn approx_less_than(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (!approx.less_than(a, b)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} < {s}\n\texpected (approx) {d} < {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.approx_less_than\n"),
            }
        }

        pub fn less_than_or_equal_to(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a > b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} <= {s}\n\texpected {d} <= {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.less_than_or_equal_to\n"),
            }
        }

        pub fn approx_less_than_or_equal_to(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (!approx.less_than_or_equal_to(a, b)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} <= {s}\n\texpected (approx) {d} <= {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.approx_less_than_or_equal_to\n"),
            }
        }

        pub fn greater_than(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a <= b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} > {s}\n\texpected {d} > {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.greater_than\n"),
            }
        }

        pub fn approx_greater_than(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (!approx.greater_than(a, b)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} > {s}\n\texpected (approx) {d} > {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.approx_greater_than\n"),
            }
        }

        pub fn greater_than_or_equal_to(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (a < b) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected {s} >= {s}\n\texpected {d} >= {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.greater_than_or_equal_to\n"),
            }
        }

        pub fn approx_greater_than_or_equal_to(comptime name_a: []const u8, a: anytype, comptime name_b: []const u8, b: anytype, comptime reason: []const u8) void {
            switch (@typeInfo(a)) {
                .Int, .Float, .ComptimeInt, .ComptimeFloat => {
                    if (!approx.greater_than_or_equal_to(a, b)) {
                        if (SHOULD_ASSERT) {
                            std.debug.panic("\nASSERT FAILURE\n\t{s}\n\texpected (approx) {s} >= {s}\n\texpected (approx) {d} >= {d}\n", .{ reason, name_a, name_b, a, b });
                        }
                        unreachable;
                    }
                },
                else => @compileError("\ninvalid type(s) for assert.approx_greater_than_or_equal_to\n"),
            }
        }
    };
}
