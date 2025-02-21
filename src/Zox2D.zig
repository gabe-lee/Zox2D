const std = @import("std");
const math = std.math;
const mem = std.mem;
const Allocator = mem.Allocator;
const ListUnmanaged = std.ArrayListUnmanaged;
const ListManaged = std.ArrayList;
const Type = std.builtin.Type;

const block_alloc = @import("pooled_block_alloc");
const PooledBlockAllocator = block_alloc.PooledBlockAllocator;
const BlockAllocator = block_alloc.BlockAllocator;
const StaticAllocBuffer = block_alloc.StaticAllocBuffer;

const Utils = @import("./Utils.zig");
const AssertPackageOptions = Utils.AssertPackageOptions;

pub fn define_property_mixing_func_type_from_float_type(comptime FLOAT: type) type {
    return fn (prop_a: FLOAT, prop_b: FLOAT) FLOAT;
}

pub const Zox2dOptionsPrimary = struct {
    /// Options controlling how assertions are handled in Zox2D
    assert_package_options: AssertPackageOptions = AssertPackageOptions{},
    /// General float type to use for fields and calculations
    ///
    /// In the vast majority of cases `f32` is a good choice,
    /// but `f64` provides better precision and less round-off-error at the cost of memory footprint,
    /// while `f16` provides better memory footprint at the cost of significant round-off-error
    /// and very small minimum/maximum values available
    float_type: type = f32,
    /// The float type to use for floating point values that should always
    /// be within or near the range [0, 1]
    ///
    /// In the vast majority of cases `f32` is a good choice, but you may try
    /// using `f16` to save mrmory footprint.
    fractional_float_type: type = f32,
    /// General unsigned integer type to use for fields and calculations
    ///
    /// In most cases `u32` is a good choice, but you may experiment with smaller
    /// integer types to save on memory footprint in your project, with the risk that
    /// smaller integer types may cause errors dependant on your project internals
    uint_type: type = u32,
    /// Whether you need the radians included in the body transform for personal use,
    /// normally Zox2D only stores the sine and cosine of the rotation for internal use.
    ///
    /// Without the radians included, you would need to use an inverse trig function to
    /// recalculate the radians from the sine or cosine.
    include_radians_in_transform: bool = false,
    /// Unsigned integer type to use for the collision filter mask
    ///
    /// Directly limits the number of unique collision/interaction
    /// categories that can be applied to an object,
    /// one category for every bit in the integer type
    collision_filter_uint_type: type = u32,
    /// Signed integer type (or `void`) for use in blanket collision filtering
    ///
    /// if you do not use this feature it can be the `void` type to save memory
    collision_filter_group_int_type: type = i32,
    /// Tolerance threshold within which two float values may be considered 'equal'
    approx_tolerance: f64 = math.floatEps(f32),
    /// Unsigned integer type to use in object id objects (except `WorldID`) as their `index` field
    object_id_uint_type: type = u32,
    /// Unsigned integer type to use in `WorldID` as their `index` field
    world_id_uint_type: type = u16,
    /// Unsigned integer type to use in object id objects as their `generation` field
    generation_uint_type: type = u16,
    /// type to use to pack object id objects into a single integer
    ///
    /// MUST have a bit count >= the sum of the bits in the types chosen for `object_id_uint_type` + `world_id_uint_type` + `generation_uint_type`
    packed_id_uint_type: type = u64,
    /// Unsigned integer type used by a `BitSet` as its underlying block type
    ///
    /// NOT RECOMMENDED TO CHANGE
    bitset_uint_type: type = u64,
    /// Whether or not free ids should be validated before use
    validate_free_ids: bool = false,
    /// Controls the inclusion or exclusion of debug functions/fields
    ///
    /// When `false`, struct fields and functions used ONLY for debugging
    /// are replaced with the `void` type or no-op functions to save memory footprint
    /// and compile size
    enable_debug: bool = false,
    /// Option to draw shapes, can be changed at runtime
    debug_draw_shapes: bool = false,
    /// Option to draw joints, can be changed at runtime
    debug_draw_joints: bool = false,
    /// Option to draw additional information for joints, can be changed at runtime
    debug_draw_joint_extras: bool = false,
    /// Option to draw the bounding boxes for shapes, can be changed at runtime
    debug_draw_aabbs: bool = false,
    /// Option to draw the mass and center of mass of dynamic bodies, can be changed at runtime
    debug_draw_mass: bool = false,
    /// Option to draw user-provided debug body names, can be changed at runtime
    debug_draw_body_names: bool = false,
    /// Option to draw contact points, can be changed at runtime
    debug_draw_contacts: bool = false,
    /// Option to visualize the graph coloring used for contacts and joints, can be changed at runtime
    debug_draw_graph_colors: bool = false,
    /// Option to draw contact normals, can be changed at runtime
    debug_draw_contact_normals: bool = false,
    /// Option to draw contact normal impulses, can be changed at runtime
    debug_draw_contact_impulses: bool = false,
    /// Option to draw friction impulses, can be changed at runtime
    debug_draw_friction_impulses: bool = false,
    /// custom type to send to all `debug_draw_____()` functions
    debug_user_data_type: type = void,
    /// custom type to attach to all `Body` objects for user use
    body_user_data_type: type = void,
    /// custom type to attach to all `Shape` objects for user use
    shape_user_data_type: type = void,
    /// custom type to attach to all `World` objects for user use
    world_user_data_type: type = void,
    /// custom type to attach to all `Chain` objects for user use
    chain_user_data_type: type = void,
    /// custom type to attach to all `DistanceJoint` objects for user use
    distance_joint_user_data_type: type = void,
    /// custom type to attach to all `MotorJoint` objects for user use
    motor_joint_user_data_type: type = void,
    /// custom type to attach to all `MouseJoint` objects for user use
    mouse_joint_user_data_type: type = void,
    /// custom type to attach to all `NullJoint` objects for user use
    null_joint_user_data_type: type = void,
    /// custom type to attach to all `PrismaticJoint` objects for user use
    prismatic_joint_user_data_type: type = void,
    /// custom type to attach to all `RevoluteJoint` objects for user use
    revolute_joint_user_data_type: type = void,
    /// custom type to attach to all `WeldJoint` objects for user use
    weld_joint_user_data_type: type = void,
    /// custom type to attach to all `WheelJoint` objects for user use
    wheel_joint_user_data_type: type = void,
    /// custom type to pass to the custom pre-solve filter callback for user use
    pre_solve_user_data_type: type = void,
    /// custom type to pass to the custom collision filter callback for user use
    collision_filter_user_data_type: type = void,
    ///TODO
    custom_task_data_type: type = void,
    ///TODO
    custom_task_type: type = void,
    /// Whether user-created struct types should be validated as correct before use
    validation_mode: ValidationMode = .ValidateButDoNotStoreResult,
    /// the type passed to debug draw functions for color data
    debug_color_type: type = u32,
    /// Allocator for ID pools (free id lists)
    id_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `World` object pools
    world_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `Body` object pools
    body_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `Shape` object pools
    shape_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `BitSet` object pools
    bitset_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `SolverSet` object pools
    solver_set_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `Joint` object pools
    joint_pool_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `Contact` object pools
    contact_pool_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `Island` object pools
    island_pool_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `Chain` object pools
    chain_pool_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `SensorEventBegin` and `SensorEventEnd` lists
    sensor_event_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `ContactTouchEventBegin` and `ContactTouchEventEnd` lists
    contact_touch_event_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `ContactHitEvent` lists
    contact_hit_event_allocator: *Allocator = &std.heap.page_allocator,
    /// Allocator for `MoveEvent` lists
    move_event_allocator: *Allocator = &std.heap.page_allocator,
};

pub fn define_zox2d_with_primary_options(options_1: Zox2dOptionsPrimary) type {
    return struct {
        pub const Zox2dOptionsSecondary = struct {
            /// A user-provided function to draw debug polygon outlines
            debug_draw_polygon_outline: *const DebugDrawPolygonOutlineFunc = no_op_draw_polygon_outline,
            /// A user-provided function to draw debug solid polygons with optional rounded corners
            debug_draw_polygon_solid: *const DebugDrawPolygonSolidFunc = no_op_draw_polygon_solid,
            /// A user-provided function to draw debug circle outlines
            debug_draw_circle_outline: *const DebugDrawCircleOutlineFunc = no_op_draw_circle_outline,
            /// A user-provided function to draw debug solid circles
            debug_draw_circle_solid: *const DebugDrawCircleSolidFunc = no_op_draw_circle_solid,
            /// A user-provided function to draw debug solid circles
            debug_draw_capsule_solid: *const DebugDrawCapsuleSolidFunc = no_op_draw_capsule_solid,
            /// A user-provided function to draw debug line segments
            debug_draw_segment: *const DebugDrawSegmentFunc = no_op_draw_segment,
            /// A user-provided function to draw debug body transforms
            debug_draw_transform: *const DebugDrawTransformFunc = no_op_draw_transform,
            /// A user-provided function to draw debug points
            debug_draw_point: *const DebugDrawPointFunc = no_op_draw_point,
            /// A user-provided function to draw debug text
            debug_draw_text: *const DebugDrawTextFunc = no_op_draw_text,
            /// The default formula for mixing friction interactions when not manuallyoverridden
            default_friction_mixing_formula: ProperyMixingMode = ProperyMixingMode{ .GeometricAverage = void{} },
            /// The default formula for mixing elasticity/bounce/restitution interactions when not manually overridden
            default_elasticity_mixing_formula: ProperyMixingMode = ProperyMixingMode{ .Max = void{} },
            /// The default custom pre-solve callback when none is provided manually
            default_pre_solve_callback: *const CustomPreSolveFunction = pre_solve_always_pass,
            /// The default custom collision filter callback when none is provided manually
            default_collision_filter_callback: *const CustomCollisionFilterFunction = collision_filter_always_pass,
            /// The default overlap check callback when none is provided manually
            default_overlap_check_callback: *const CustomOverlapCheckCallback = collision_filter_always_pass,
            /// The default cast result callback when none is provided manually
            default_cast_result_callback: *const CustomCastResultCallback = cast_result_no_clip_change,

            const assert = Utils.define_assert_package_with_options(options_1.assert_package_options);
            ///TODO
            pub const APPROX_TOLERANCE: Float = @floatCast(options_1.approx_tolerance);
            pub const INCLUDE_RADIANS_IN_TRANSFORM: bool = options_1.include_radians_in_transform;

            /// General float type to use for fields and calculations
            pub const Float = options_1.float_type;
            /// General float type to use for fields and calculations
            pub const FracFloat = options_1.fractional_float_type;
            /// General unsigned integer type to use for fields and calculations
            pub const UInt = options_1.uint_type;
            /// Unsigned integer type to use in object id objects (except `WorldID`) as their `index` field
            pub const ObjectIdUInt = options_1.object_id_uint_type;
            /// Unsigned integer type to use in `WorldID` as their `index` field
            pub const WorldIdUInt = options_1.world_id_uint_type;
            /// Unsigned integer type to use in object id objects as their `generation` field
            pub const GenerationUInt = options_1.generation_uint_type;
            /// type to use to pack object id objects into a single integer
            pub const PackedIdUInt = options_1.packed_id_uint_type;
            /// custom type to send to all `debug_draw_____()` functions
            pub const DebugDrawUserData = options_1.debug_user_data_type;
            /// custom type to attatch to all `Shape` objects for user use
            pub const ShapeUserData = options_1.shape_user_data_type;
            /// custom type to pass to the custom pre-solve filter callback for user use
            pub const PreSolveUsereData = options_1.pre_solve_user_data_type;
            /// custom type to pass to the custom collision filter callback for user use
            pub const CollisionFilterUserData = options_1.collision_filter_user_data_type;
            ///TODO
            pub const CustomTaskData = options_1.custom_task_data_type;
            ///TODO
            pub const CustomUserTask = options_1.custom_task_type;
            /// Type describing the function signature of a formula that mixes 2 properties
            pub const PropertyMixingFormula = fn (prop_a: Float, mat_id_a: UInt, prop_b: Float, mat_id_b: UInt) Float;
            /// Function signature type for a pre-solve callback.
            ///
            /// This is called after a contact is updated. This allows you to inspect a
            /// contact before it goes to the solver. If you are careful, you can modify the
            /// contact manifold (e.g. modify the normal).
            ///
            /// Notes:
            /// - this function must be thread-safe
            /// - this is only called if the shape has enabled pre-solve events
            /// - this is called only for awake dynamic bodies
            /// - this is not called for sensors
            /// - the supplied manifold has impulse values from the previous step
            /// Return false if you want to disable the contact this step
            pub const CustomPreSolveFunction = fn (shape_id_a: ShapeID, shape_id_b: ShapeID, contact_data: ContactData, user_data: PreSolveUsereData) bool;
            /// Function signature type for a contact filter callback.
            ///
            /// This is called when a contact pair is considered for collision. This allows you to
            /// perform custom logic to prevent collision between shapes. This is only called if
            /// one of the two shapes has custom filtering enabled.
            ///
            /// Notes:
            /// - this function must be thread-safe
            /// - this is only called if one of the two shapes has enabled custom filtering
            /// - this is called only for awake dynamic bodies
            /// Return false if you want to disable the collision
            pub const CustomCollisionFilterFunction = fn (shape_id_a: ShapeID, shape_id_b: ShapeID, user_data: CollisionFilterUserData) bool;
            /// Custom callback for overlap checks.
            ///
            /// Called for each shape being tested that would NORMALLY result in a positive overlap.
            ///
            /// Return false to ignore the overlap.
            pub const CustomOverlapCheckCallback = fn (shape_id: ShapeID, user_data: ShapeUserData) bool;
            /// Custom callback for for ray casts.
            ///
            /// Called for each shape found in the query. You control how the ray cast
            /// proceeds by returning a float:
            ///   - return -1: ignore this shape and continue
            ///   - return 0: terminate the ray cast
            ///   - return fraction in range [0, 1): clip the ray to this point
            ///   - return 1: don't clip the ray and continue
            pub const CustomCastResultCallback = fn (shape_id: ShapeID, point: Vec2, normal: Vec2, fraction: FracFloat, user_data: ShapeUserData) FracFloat;
            /// User-provded callback function provided to Zox2D to invoke a task system.
            ///
            /// Returns an instance of the user-provided task type.
            ///
            /// The `item_count` is the number of Zox2D work items that are to be partitioned among workers by the user's task system.
            /// This is essentially a parallel-for. The `min_range` parameter is a suggestion of the minimum number of items to assign
            /// per worker to reduce overhead. For example, suppose the task is small and that `item_count` is 16. A `min_range` of 8 suggests
            /// that your task system should split the work items among just two workers, even if you have more available.
            /// In general the range [`start_index`, `end_index`) send to the user-provided `TaskCallback` function should obey:
            /// `end_index` - `start_index` >= `min_range`
            /// The exception of course is when `item_count` < `min_range`.
            pub const EnqueueTaskCallback = fn (task: TaskCallback, item_count: UInt, min_range: UInt, task_data: CustomTaskData, user_data: CustomUserData) CustomUserTask; //FIXME
            /// User-provded callback function provided to Zox2D to complete a task.
            ///
            /// Finishes a user-provided task object that wraps a Zox2D task.
            pub const FinishTaskCallback = fn (user_task: CustomUserTask, user_data: CustomUserData) void; //FIXME
            /// Task interface
            ///
            /// This is the function signature for a Zox2D task. Your task system is expected to invoke the Zox2D task with these arguments.
            ///
            /// The task spans a range of the parallel-for: [`start_idx`, `end_idx`)
            ///
            /// The worker index must correctly identify each worker in the user thread pool, expected in [0, `worker_count`).
            /// A worker must exist on only one thread at a time and is analogous to the thread index.
            /// The task data is the user-provided custom data type sent from Zox2D when it is enqueued.
            /// The `start_idx` and `end_idx` are expected in the range [0, `item_count`) where `item_count` is the argument to an `EnqueueTaskCallback`
            /// below. Zox2D expects `start_idx` < `end_idx` and will execute a loop like this:
            ///
            /// ```zig
            /// var i: UInt = start_idx;
            /// while (i < end_idx) : (i += 1) {
            ///     do_work();
            /// }
            /// ```
            pub const TaskCallback = fn (start_idx: UInt, end_idx: UInt, worker_idx: UInt, task_data: CustomTaskData) void; //FIXME
            /// Describes How to mix two properties together
            ///
            /// The options are as follows listed in mathematic order where the higher optons ALWAYS evaluate to a value >= the options below them
            ///   - Max = @max(a, b)
            ///   - QuadraticAverage = @sqrt(((a * a) + (b * b)) / 2)
            ///   - ArithmeticAverage = (a + b) / 2
            ///   - GeomtricAverage = @sqrt(a * b)
            ///   - HarmonicAverage = (2 * a * b) / (a + b)
            ///   - Min = @min(a, b)
            pub const ProperyMixingMode = union(PropertyMixingFormulaTag) {
                /// @min(a, b)
                Min: void,
                /// (2 * a * b) / (a + b)
                HarmonicAverage: void,
                /// @sqrt(a * b)
                GeometricAverage: void,
                /// (a + b) / 2
                ArithmeticAverage: void,
                /// @sqrt(((a * a) + (b * b)) / 2)
                QuadraticAverage: void,
                /// @max(a, b)
                Max: void,
                /// Provide your own mixing function
                Custom: *const PropertyMixingFormula,
            };

            /// The type passed to debug draw functions for color data
            pub const DebugColor = options_1.debug_color_type;
            /// The function signature for user-provided `debug_draw_polygon_outline()`function
            pub const DebugDrawPolygonOutlineFunc = fn (vertices: []const Vec2, color: DebugColor, user_data: DebugDrawUserData) void;
            /// The function signature for user-provided `debug_draw_polygon_solid()`function
            pub const DebugDrawPolygonSolidFunc = fn (vertices: []const Vec2, corner_radius: Float, color: DebugColor, user_data: DebugDrawUserData) void;
            /// The function signature for user-provided `debug_draw_circle_outline()`function
            pub const DebugDrawCircleOutlineFunc = fn (center: Vec2, radius: Float, color: DebugColor, user_data: DebugDrawUserData) void;
            /// The function signature for user-provided `debug_draw_circle_solid()`function
            pub const DebugDrawCircleSolidFunc = fn (center: Vec2, radius: Float, color: DebugColor, user_data: DebugDrawUserData) void;
            /// The function signature for user-provided `debug_draw_capsule_solid()`function
            pub const DebugDrawCapsuleSolidFunc = fn (center_a: Vec2, center_b: Vec2, radius: Float, color: DebugColor, user_data: DebugDrawUserData) void;
            /// The function signature for user-provided `debug_draw_segment()`function
            pub const DebugDrawSegmentFunc = fn (point_a: Vec2, point_b: Vec2, color: DebugColor, user_data: DebugDrawUserData) void;
            /// The function signature for user-provided `debug_draw_transform()`function
            pub const DebugDrawTransformFunc = fn (transform: Transform, user_data: DebugDrawUserData) void;
            /// The function signature for user-provided `debug_draw_point()`function
            pub const DebugDrawPointFunc = fn (point: Vec2, size: Float, color: DebugColor, user_data: DebugDrawUserData) void;
            /// The function signature for user-provided `debug_draw_text()`function
            pub const DebugDrawTextFunc = fn (location: Vec2, text: []const u8, color: DebugColor, user_data: DebugDrawUserData) void;

            /// The default `draw_polygon_hull` function when none is provided, does nothing
            pub fn no_op_draw_polygon_outline(vertices: []const Vec2, color: DebugColor, user_data: DebugDrawUserData) void {
                _ = vertices;
                _ = color;
                _ = user_data;
            }

            /// The default `draw_polygon_solid` function when none is provided, does nothing
            pub fn no_op_draw_polygon_solid(vertices: []const Vec2, corner_radius: Float, color: DebugColor, user_data: DebugDrawUserData) void {
                _ = vertices;
                _ = corner_radius;
                _ = color;
                _ = user_data;
            }

            /// The default `draw_circle_outline` function when none is provided, does nothing
            pub fn no_op_draw_circle_outline(center: Vec2, radius: Float, color: DebugColor, user_data: DebugDrawUserData) void {
                _ = center;
                _ = radius;
                _ = color;
                _ = user_data;
            }

            /// The default `draw_circle_solid` function when none is provided, does nothing
            pub fn no_op_draw_circle_solid(center: Vec2, radius: Float, color: DebugColor, user_data: DebugDrawUserData) void {
                _ = center;
                _ = radius;
                _ = color;
                _ = user_data;
            }

            /// The default `draw_capsule_solid` function when none is provided, does nothing
            pub fn no_op_draw_capsule_solid(center_a: Vec2, center_b: Vec2, radius: Float, color: DebugColor, user_data: DebugDrawUserData) void {
                _ = center_a;
                _ = center_b;
                _ = radius;
                _ = color;
                _ = user_data;
            }

            /// The default `debug_draw_segment` function when none provided, does nothing
            pub fn no_op_draw_segment(point_a: Vec2, point_b: Vec2, color: DebugColor, user_data: DebugDrawUserData) void {
                _ = point_a;
                _ = point_b;
                _ = color;
                _ = user_data;
            }

            /// The default `debug_draw_transform` function when none provided, does nothing
            pub fn no_op_draw_transform(transform: Transform, user_data: DebugDrawUserData) void {
                _ = transform;
                _ = user_data;
            }

            /// The default `debug_draw_point` function when none provided, does nothing
            pub fn no_op_draw_point(point: Vec2, size: Float, color: DebugColor, user_data: DebugDrawUserData) void {
                _ = point;
                _ = size;
                _ = color;
                _ = user_data;
            }

            /// The default `debug_draw_text` function when none provided, does nothing
            pub fn no_op_draw_text(location: Vec2, text: []const u8, color: DebugColor, user_data: DebugDrawUserData) void {
                _ = location;
                _ = text;
                _ = color;
                _ = user_data;
            }

            /// The default CustomPreSolveFunction when none provided, always passes
            pub fn pre_solve_always_pass(shape_id_a: ShapeID, shape_id_b: ShapeID, contact_data: ContactData, user_data: PreSolveUsereData) bool {
                _ = shape_id_a;
                _ = shape_id_b;
                _ = contact_data;
                _ = user_data;
                return true;
            }

            /// The default CustomCollisionFilterFunction when none provided, always passes
            pub fn collision_filter_always_pass(shape_id_a: ShapeID, shape_id_b: ShapeID, user_data: CollisionFilterUserData) bool {
                _ = shape_id_a;
                _ = shape_id_b;
                _ = user_data;
                return true;
            }

            /// The default CustomOverlapCheckCallback when none provided, always passes
            pub fn overlap_check_always_pass(shape_id: ShapeID, user_data: ShapeUserData) bool {
                _ = shape_id;
                _ = user_data;
                return true;
            }

            /// The default CustomCastResultCallback when none provided, always returns the orignial clip fraction
            pub fn cast_result_no_clip_change(shape_id: ShapeID, point: Vec2, normal: Vec2, fraction: FracFloat, user_data: ShapeUserData) FracFloat {
                _ = shape_id;
                _ = point;
                _ = normal;
                _ = user_data;
                return fraction;
            }

            pub const Transform = struct {
                position: Vec2,
                rotation: Rotation,
            };

            pub const SinCos = struct {
                sin: FracFloat,
                cos: FracFloat,

                pub const ANGLE_ZERO = SinCos{ .sin = 0.0, .cos = 1.0 };
                pub inline fn new(sin: FracFloat, cos: FracFloat) SinCos {
                    return SinCos{
                        .sin = sin,
                        .cos = cos,
                    };
                }
                pub inline fn new_from_radians(radians: Float) SinCos {
                    return SinCos{
                        .sin = @floatCast(@sin(radians)),
                        .cos = @floatCast(@cos(radians)),
                    };
                }
                pub inline fn new_from_degrees(degrees: Float) SinCos {
                    const radians = math.rad_per_deg * degrees;
                    return SinCos{
                        .sin = @floatCast(@sin(radians)),
                        .cos = @floatCast(@cos(radians)),
                    };
                }
            };

            pub const Rotation = struct {
                radians: if (INCLUDE_RADIANS_IN_TRANSFORM) Float else void,
                sin: FracFloat,
                cos: FracFloat,

                pub const ANGLE_ZERO = Rotation{
                    .radians = if (INCLUDE_RADIANS_IN_TRANSFORM) 0.0 else void{},
                    .sin = 0.0,
                    .cos = 1.0,
                };

                pub inline fn new_from_radians(radians: Float) Rotation {
                    return Rotation{
                        .radians = if (INCLUDE_RADIANS_IN_TRANSFORM) radians else void{},
                        .sin = @floatCast(@sin(radians)),
                        .cos = @floatCast(@cos(radians)),
                    };
                }
                pub inline fn new_from_degrees(degrees: Float) Rotation {
                    const radians = math.rad_per_deg * degrees;
                    return Rotation{
                        .radians = if (INCLUDE_RADIANS_IN_TRANSFORM) radians else void{},
                        .sin = @floatCast(@sin(radians)),
                        .cos = @floatCast(@cos(radians)),
                    };
                }

                pub inline fn get_sin_cos(self: Rotation) SinCos {
                    return SinCos{ .sin = self.sin, .cos = self.cos };
                }

                pub inline fn new_from_sin_cos(sin_cos: SinCos) Rotation {
                    return Rotation{
                        .radians = if (INCLUDE_RADIANS_IN_TRANSFORM) @floatCast(math.acos(sin_cos.cos)) else void{},
                        .sin = sin_cos.sin,
                        .cos = sin_cos.cos,
                    };
                }

                pub inline fn new_from_sin(sin: FracFloat) Rotation {
                    const radians: Float = @floatCast(math.asin(sin));
                    return Rotation{
                        .radians = if (INCLUDE_RADIANS_IN_TRANSFORM) radians else void{},
                        .sin = sin,
                        .cos = @floatCast(@cos(radians)),
                    };
                }
                pub inline fn new_from_cos(cos: FracFloat) Rotation {
                    const radians: Float = @floatCast(math.acos(cos));
                    return Rotation{
                        .radians = if (INCLUDE_RADIANS_IN_TRANSFORM) radians else void{},
                        .sin = @floatCast(@sin(radians)),
                        .cos = cos,
                    };
                }
            };

            /// Also known as the collision 'manifold'
            pub const ContactData = struct {};

            pub const ShapeID = struct {
                index: ObjectIdUInt,
                world: WorldIdUInt,
                generation: GenerationUInt,

                pub const NULL = ShapeID{ .index = 0, .world = 0, .generation = 0 };
                pub inline fn is_null(self: ShapeID) bool {
                    return self.index == 0;
                }
                pub inline fn not_null(self: ShapeID) bool {
                    return self.index != 0;
                }
                pub inline fn equals(self: ShapeID, other: ShapeID) bool {
                    return self.index == other.index and self.world == other.world and self.generation == other.generation;
                }
                pub inline fn pack(self: ShapeID) PackedIdUInt {
                    var val = @as(PackedIdUInt, @intCast(self.index));
                    val |= @as(PackedIdUInt, @intCast(self.world)) << @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits));
                    val |= @as(PackedIdUInt, @intCast(self.generation)) << @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits + @typeInfo(WorldIdUInt).Int.bits));
                }
                pub inline fn unpack_from(val: PackedIdUInt) ShapeID {
                    return ShapeID{
                        .index = @as(ObjectIdUInt, @intCast(val & math.maxInt(ObjectIdUInt))),
                        .world = @as(WorldIdUInt, @intCast((val >> @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits))) & math.maxInt(WorldIdUInt))),
                        .generation = @as(WorldIdUInt, @intCast((val >> @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits + @typeInfo(WorldIdUInt).Int.bits))) & math.maxInt(GenerationUInt))),
                    };
                }
            };

            pub const Vec2 = struct {
                x: Float,
                y: Float,

                pub const ZERO = Vec2{ .x = 0, .y = 0 };

                pub inline fn new(x: Float, y: Float) Vec2 {
                    return Vec2{ .x = x, .y = y };
                }

                // dot-product
                pub inline fn dot(a: Vec2, b: Vec2) f32 {
                    return (a.x * b.x) + (a.y * b.y);
                }

                /// cross-product
                ///
                /// In 2-Dimensions the cross-product is the same as the determinant
                pub inline fn cross(a: Vec2, b: Vec2) f32 {
                    return (a.x * b.y) - (a.y * b.x);
                }

                pub inline fn add(a: Vec2, b: Vec2) Vec2 {
                    return Vec2{ .x = a.x + b.x, .y = a.y + b.y };
                }

                pub inline fn subtract(a: Vec2, b: Vec2) Vec2 {
                    return Vec2{ .x = a.x - b.x, .y = a.y - b.y };
                }

                pub inline fn multiply(a: Vec2, b: Vec2) Vec2 {
                    return Vec2{ .x = a.x * b.x, .y = a.y * b.y };
                }

                pub inline fn divide(a: Vec2, b: Vec2) Vec2 {
                    assert.neither_equals("b.x", b.x, "b.y", b.y, "0", 0, "vector B cannot have either dimension equal zero (causes divide-by-zero)");
                    return Vec2{ .x = a.x / b.x, .y = a.y / b.y };
                }

                pub inline fn scale(a: Vec2, scalar: anytype) Vec2 {
                    return Vec2{ .x = a.x * scalar, .y = a.y * scalar };
                }

                /// scale `add_vec` by `scalar` before adding to `a`
                pub inline fn scaled_add(a: Vec2, add_vec: Vec2, scalar: anytype) Vec2 {
                    return Vec2{ .x = a.x + (add_vec.x * scalar), .y = a.y + (add_vec.y * scalar) };
                }

                /// scale `sub_vec` by `scalar` before subtracting from `a`
                pub inline fn scaled_subtract(a: Vec2, sub_vec: Vec2, scalar: anytype) Vec2 {
                    return Vec2{ .x = a.x - (sub_vec.x * scalar), .y = a.y - (sub_vec.y * scalar) };
                }

                /// scale `mult_vec` by `scalar` before multiplying with `a`
                pub inline fn scaled_multiply(a: Vec2, mult_vec: Vec2, scalar: anytype) Vec2 {
                    return Vec2{ .x = a.x * (mult_vec.x * scalar), .y = a.y * (mult_vec.y * scalar) };
                }

                /// scale `div_vec` by `scalar` before returning `a` divided by the `scaled_div_vec`
                pub inline fn scaled_divide(a: Vec2, div_vec: Vec2, scalar: anytype) Vec2 {
                    assert.neither_equals("div_vec.x", div_vec.x, "div_vec.y", div_vec.y, "0", 0, "vector B cannot have either dimension equal zero (causes divide-by-zero)");
                    assert.not_equal("scalar", scalar, "0", 0, "scalar cannot be zero (causes divide-by-zero)");
                    return Vec2{ .x = a.x / (div_vec.x * scalar), .y = a.y / (div_vec.y * scalar) };
                }

                pub inline fn distance_to(a: Vec2, b: Vec2) Float {
                    const diff = Vec2{ .x = b.x - a.x, .y = b.y - a.y };
                    return @sqrt((diff.x * diff.x) + (diff.y * diff.y));
                }

                pub inline fn distance_to_squared(a: Vec2, b: Vec2) Float {
                    const diff = Vec2{ .x = b.x - a.x, .y = b.y - a.y };
                    return (diff.x * diff.x) + (diff.y * diff.y);
                }

                pub inline fn length(self: Vec2) Float {
                    return @sqrt((self.x * self.x) + (self.y * self.y));
                }

                pub inline fn length_squared(self: Vec2) Float {
                    return (self.x * self.x) + (self.y * self.y);
                }

                pub inline fn length_using_squares(x_squared: Float, y_squared: Float) Float {
                    assert.greater_than_or_equal_to("x_squared", x_squared, "0", 0, "x_squared must be >= 0 (squared numbers are always positive)");
                    assert.greater_than_or_equal_to("y_squared", y_squared, "0", 0, "y_squared must be >= 0 (squared numbers are always positive)");
                    return @sqrt(x_squared + y_squared);
                }

                pub inline fn length_using_sum_of_squares(sum_of_squares: Float) Float {
                    assert.greater_than_or_equal_to("sum_of_squares", sum_of_squares, "0", 0, "sum_of_squares must be >= 0 (squared numbers are always positive)");
                    return @sqrt(sum_of_squares);
                }

                pub inline fn normalize(self: Vec2) Vec2 {
                    if (self.x == 0 and self.y == 0) return Vec2.new(0, 0);
                    const len = @sqrt((self.x * self.x) + (self.y * self.y));
                    return Vec2{ .x = self.x / len, .y = self.y / len };
                }

                pub inline fn normalize_using_length(self: Vec2, len: Float) Vec2 {
                    if (len == 0) return Vec2.new(0, 0);
                    return Vec2{ .x = self.x / len, .y = self.y / len };
                }

                pub inline fn normalize_using_squares(self: Vec2, x_squared: Float, y_squared: Float) Vec2 {
                    const len = @sqrt(x_squared + y_squared);
                    if (len == 0) return Vec2.new(0, 0);
                    return Vec2{ .x = self.x / len, .y = self.y / len };
                }
                pub inline fn normalize_using_sum_of_squares(self: Vec2, sum_of_squares: Float) Vec2 {
                    const len = @sqrt(sum_of_squares);
                    if (len == 0) return Vec2.new(0, 0);
                    return Vec2{ .x = self.x / len, .y = self.y / len };
                }

                pub inline fn angle_between(a: Vec2, b: Vec2) Float {
                    const dot_prod = (a.x * b.x) + (a.y * b.y);
                    const lengths_multiplied = @sqrt((a.x * a.x) + (a.y * a.y)) * @sqrt((b.x * b.x) + (b.y * b.y));
                    assert.greater_than("lengths_multiplied", lengths_multiplied, "0", 0, "the lengths of each vector multiplied by each other cannot be zero (one or both vectors had zero length, causes divide-by-zero)");
                    return math.acos(dot_prod / lengths_multiplied);
                }

                pub inline fn angle_between_using_lengths(a: Vec2, b: Vec2, len_a: Float, len_b: Float) Float {
                    const dot_prod = (a.x * b.x) + (a.y * b.y);
                    const lengths_multiplied = len_a * len_b;
                    assert.greater_than("lengths_multiplied", lengths_multiplied, "0", 0, "the lengths of each vector multiplied by each other cannot be zero (one or both vectors had zero length, causes divide-by-zero)");
                    return math.acos(dot_prod / lengths_multiplied);
                }

                pub inline fn angle_between_using_normals(a_norm: Vec2, b_norm: Vec2) Float {
                    const dot_prod = (a_norm.x * b_norm.x) + (a_norm.y * b_norm.y);
                    return math.acos(dot_prod);
                }

                /// Returns the scalar ratio of (A / B), asserts that A and B have the same slope and are not both (0, 0)
                pub inline fn ratio_of_a_to_b(a: Vec2, b: Vec2) Float {
                    if (a.x != 0 and b.x != 0) {
                        assert.approx_equal("slope of a", a.y / a.x, "slope or b", b.y / b.x, "both slopes must be equal to compare them as a ratio of one to the other");
                        return a.x / b.x;
                    } else if (a.y != 0 and b.y != 0) {
                        assert.approx_equal("slope of a", a.x / a.y, "slope or b", b.x / b.y, "both slopes must be equal to compare them as a ratio of one to the other");
                        return a.y / b.y;
                    } else {
                        assert.is_unreachable("either slope of a != slope of b (one of the vectors has 0 in one axis where the other doesnt) OR both vectors are (0, 0)");
                    }
                }

                pub inline fn perp_ccw(self: Vec2) Vec2 {
                    return Vec2{ .x = -self.y, .y = self.x };
                }

                pub inline fn perp_cw(self: Vec2) Vec2 {
                    return Vec2{ .x = self.y, .y = -self.x };
                }

                pub inline fn lerp_a_to_b(a: Vec2, b: Vec2, delta: Float) Vec2 {
                    return Vec2{ .x = ((b.x - a.x) * delta) + a.x, .y = ((b.y - a.y) * delta) + a.y };
                }

                pub inline fn lerp_a_to_b_with_delta_min_to_max(a: Vec2, b: Vec2, min_delta: Float, delta: Float, max_delta: Float) Vec2 {
                    const percent = (delta - min_delta) / (max_delta - min_delta);
                    return Vec2{ .x = ((b.x - a.x) * percent) + a.x, .y = ((b.y - a.y) * percent) + a.y };
                }

                pub inline fn lerp_a_to_b_with_delta_zero_to_max(a: Vec2, b: Vec2, delta: Float, max_delta: Float) Vec2 {
                    const percent = delta / max_delta;
                    return Vec2{ .x = ((b.x - a.x) * percent) + a.x, .y = ((b.y - a.y) * percent) + a.y };
                }

                pub inline fn rotate_radians(self: Vec2, radians: Float) Vec2 {
                    const cos = @cos(radians);
                    const sin = @sin(radians);
                    return Vec2{ .x = (self.x * cos) - (self.y * sin), .y = (self.x * sin) + (self.y * cos) };
                }

                pub inline fn rotate_degrees(self: Vec2, degrees: Float) Vec2 {
                    const rads = degrees * math.rad_per_deg;
                    const cos = @cos(rads);
                    const sin = @sin(rads);
                    return Vec2{ .x = (self.x * cos) - (self.y * sin), .y = (self.x * sin) + (self.y * cos) };
                }

                pub inline fn rotate_sin_cos(self: Vec2, sin: Float, cos: Float) Vec2 {
                    return Vec2{ .x = (self.x * cos) - (self.y * sin), .y = (self.x * sin) + (self.y * cos) };
                }

                pub inline fn reflect(self: Vec2, reflect_normal: Vec2) Vec2 {
                    const fix_scale = 2 * ((self.x * reflect_normal.x) + (self.y * reflect_normal.y));
                    return Vec2{ .x = self.x - (reflect_normal.x * fix_scale), .y = self.y - (reflect_normal.y * fix_scale) };
                }

                pub inline fn negate(self: Vec2) Vec2 {
                    return Vec2{ .x = -self.x, .y = -self.y };
                }

                pub inline fn equals(a: Vec2, b: Vec2) bool {
                    return a.x == b.x and a.y == b.y;
                }
                pub inline fn approx_equal(a: Vec2, b: Vec2) bool {
                    const abs_diff_x = @abs(b.x - a.x);
                    const abs_diff_y = @abs(b.y - a.y);
                    return (abs_diff_x <= APPROX_TOLERANCE) and (abs_diff_y <= APPROX_TOLERANCE);
                }

                pub inline fn is_zero(self: Vec2) bool {
                    return self.x == 0.0 and self.y == 0.0;
                }

                pub inline fn approx_colinear(a: Vec2, b: Vec2, c: Vec2) bool {
                    const cross_3 = ((c.y - a.y) * (b.x - a.x)) - ((c.x - a.x) * (b.y - a.y));
                    return @abs(cross_3) <= APPROX_TOLERANCE;
                }

                pub inline fn colinear(a: Vec2, b: Vec2, c: Vec2) bool {
                    const cross_3 = ((c.y - a.y) * (b.x - a.x)) - ((c.x - a.x) * (b.y - a.y));
                    return cross_3 == 0;
                }

                /// Returns the (approximate) orientation of a -> b -> c
                pub inline fn approx_orientation(a: Vec2, b: Vec2, c: Vec2) VectorOrientation {
                    const cross_3 = ((c.y - a.y) * (b.x - a.x)) - ((c.x - a.x) * (b.y - a.y));
                    if (@abs(cross_3) <= APPROX_TOLERANCE) return .Colinear;
                    if (cross_3 > 0) return .WindingClockwise;
                    return .WindingCounterClockwise;
                }

                /// Returns the orientation of a -> b -> c
                pub inline fn orientation(a: Vec2, b: Vec2, c: Vec2) VectorOrientation {
                    const cross_3 = ((c.y - a.y) * (b.x - a.x)) - ((c.x - a.x) * (b.y - a.y));
                    if (cross_3 == 0) return .Colinear;
                    if (cross_3 > 0) return .WindingClockwise;
                    return .WindingCounterClockwise;
                }

                pub inline fn velocity_required_to_reach_point_at_time(self: Vec2, point: Vec2, time: Float) Vec2 {
                    return point.subtract(self).scale(1.0 / time);
                }

                pub inline fn velocity_required_to_reach_point_at_time_inverse(self: Vec2, point: Vec2, inverse_time: Float) Vec2 {
                    return point.subtract(self).scale(inverse_time);
                }

                pub inline fn is_valid(self: Vec2) bool {
                    return math.isFinite(self.x) and math.isFinite(self.y);
                }

                pub inline fn abs(self: Vec2) Vec2 {
                    return Vec2{ .x = @abs(self.x), .y = @abs(self.y) };
                }

                pub fn define_simd(comptime N: comptime_int) type {
                    return struct {
                        const SIMDVec2 = @This();
                        const SIMD_T = @Vector(N, Float);
                        const SIMD_BOOL = @Vector(N, bool);
                        // const O = @Vector(N, VectorOrientation);

                        x: SIMD_T,
                        y: SIMD_T,

                        pub inline fn new(x: SIMD_T, y: SIMD_T) SIMDVec2 {
                            return SIMDVec2{ .x = x, .y = y };
                        }

                        pub inline fn new_splat(x: Float, y: Float) SIMDVec2 {
                            return SIMDVec2{ .x = @splat(x), .y = @splat(y) };
                        }

                        // dot-product
                        pub inline fn dot(a: SIMDVec2, b: SIMDVec2) SIMD_T {
                            return (a.x * b.x) + (a.y * b.y);
                        }

                        /// cross-product
                        ///
                        /// In 2-Dimensions the cross-product is the same as the determinant
                        pub inline fn cross(a: SIMDVec2, b: SIMDVec2) SIMD_T {
                            return (a.x * b.y) - (a.y * b.x);
                        }

                        pub inline fn add(a: SIMDVec2, b: SIMDVec2) SIMDVec2 {
                            return SIMDVec2{ .x = a.x + b.x, .y = a.y + b.y };
                        }

                        pub inline fn subtract(a: SIMDVec2, b: SIMDVec2) SIMDVec2 {
                            return SIMDVec2{ .x = a.x - b.x, .y = a.y - b.y };
                        }

                        pub inline fn multiply(a: SIMDVec2, b: SIMDVec2) SIMDVec2 {
                            return SIMDVec2{ .x = a.x * b.x, .y = a.y * b.y };
                        }

                        pub inline fn divide(a: SIMDVec2, b: SIMDVec2) SIMDVec2 {
                            assert.neither_equals("b.x", b.x, "b.y", b.y, "0", 0, "vector B cannot have either dimension equal zero (causes divide-by-zero)");
                            return SIMDVec2{ .x = a.x / b.x, .y = a.y / b.y };
                        }

                        pub inline fn add_single(a: SIMDVec2, b: Vec2) SIMDVec2 {
                            const x_vec: SIMD_T = @splat(b.x);
                            const y_vec: SIMD_T = @splat(b.y);
                            return SIMDVec2{ .x = a.x + x_vec, .y = a.y + y_vec };
                        }

                        pub inline fn subtract_single(a: SIMDVec2, b: Vec2) SIMDVec2 {
                            const x_vec: SIMD_T = @splat(b.x);
                            const y_vec: SIMD_T = @splat(b.y);
                            return SIMDVec2{ .x = a.x - x_vec, .y = a.y - y_vec };
                        }

                        pub inline fn multiply_single(a: SIMDVec2, b: Vec2) SIMDVec2 {
                            const x_vec: SIMD_T = @splat(b.x);
                            const y_vec: SIMD_T = @splat(b.y);
                            return SIMDVec2{ .x = a.x * x_vec, .y = a.y * y_vec };
                        }

                        pub inline fn divide_single(a: SIMDVec2, b: Vec2) SIMDVec2 {
                            assert.neither_equals("b.x", b.x, "b.y", b.y, "0", 0, "vector B cannot have either dimension equal zero (causes divide-by-zero)");
                            const x_vec: SIMD_T = @splat(b.x);
                            const y_vec: SIMD_T = @splat(b.y);
                            return SIMDVec2{ .x = a.x / x_vec, .y = a.y / y_vec };
                        }

                        pub inline fn scale(a: SIMDVec2, scalar: Float) SIMDVec2 {
                            const vec_scalar: SIMD_T = @splat(scalar);
                            return SIMDVec2{ .x = a.x * vec_scalar, .y = a.y * vec_scalar };
                        }

                        /// scale `add_vec` by `scalar` before adding to `a`
                        pub inline fn scaled_add(a: SIMDVec2, add_vec: SIMDVec2, scalar: Float) SIMDVec2 {
                            const vec_scalar: SIMD_T = @splat(scalar);
                            return SIMDVec2{ .x = a.x + (add_vec.x * vec_scalar), .y = a.y + (add_vec.y * vec_scalar) };
                        }

                        /// scale `sub_vec` by `scalar` before subtracting from `a`
                        pub inline fn scaled_subtract(a: SIMDVec2, sub_vec: SIMDVec2, scalar: Float) SIMDVec2 {
                            const vec_scalar: SIMD_T = @splat(scalar);
                            return SIMDVec2{ .x = a.x - (sub_vec.x * vec_scalar), .y = a.y - (sub_vec.y * vec_scalar) };
                        }

                        /// scale `mult_vec` by `scalar` before multiplying with `a`
                        pub inline fn scaled_multiply(a: SIMDVec2, mult_vec: SIMDVec2, scalar: Float) SIMDVec2 {
                            const vec_scalar: SIMD_T = @splat(scalar);
                            return SIMDVec2{ .x = a.x * (mult_vec.x * vec_scalar), .y = a.y * (mult_vec.y * vec_scalar) };
                        }

                        /// scale `div_vec` by `scalar` before returning `a` divided by the `scaled_div_vec`
                        pub inline fn scaled_divide(a: SIMDVec2, div_vec: SIMDVec2, scalar: Float) SIMDVec2 {
                            assert.not_equal("scalar", scalar, "0", 0, "scalar cannot be zero (causes divide-by-zero)");
                            assert.is_true("div_vec.x != 0 AND div_vec.y != 0", @reduce(.And, div_vec.x != @as(SIMD_T, @splat(0))) and @reduce(.And, div_vec.y != @as(SIMD_T, @splat(0))), "vector(s) B cannot have either dimension equal zero (causes divide-by-zero)");
                            const vec_scalar: SIMD_T = @splat(scalar);
                            return SIMDVec2{ .x = a.x / (div_vec.x * vec_scalar), .y = a.y / (div_vec.y * vec_scalar) };
                        }

                        /// scale `add_vec` by `scalar` before adding to `a`
                        pub inline fn scaled_single_add(a: SIMDVec2, add_vec: Vec2, scalar: Float) SIMDVec2 {
                            const scaled_vec_x: SIMD_T = @splat(add_vec.x * scalar);
                            const scaled_vec_y: SIMD_T = @splat(add_vec.y * scalar);
                            return SIMDVec2{ .x = a.x + scaled_vec_x, .y = a.y + scaled_vec_y };
                        }

                        /// scale `sub_vec` by `scalar` before subtracting from `a`
                        pub inline fn scaled_single_subtract(a: SIMDVec2, sub_vec: Vec2, scalar: Float) SIMDVec2 {
                            const scaled_vec_x: SIMD_T = @splat(sub_vec.x * scalar);
                            const scaled_vec_y: SIMD_T = @splat(sub_vec.y * scalar);
                            return SIMDVec2{ .x = a.x - scaled_vec_x, .y = a.y - scaled_vec_y };
                        }

                        /// scale `mult_vec` by `scalar` before multiplying with `a`
                        pub inline fn scaled_single_multiply(a: SIMDVec2, mult_vec: Vec2, scalar: Float) SIMDVec2 {
                            const scaled_vec_x: SIMD_T = @splat(mult_vec.x * scalar);
                            const scaled_vec_y: SIMD_T = @splat(mult_vec.y * scalar);
                            return SIMDVec2{ .x = a.x * scaled_vec_x, .y = a.y * scaled_vec_y };
                        }

                        /// scale `div_vec` by `scalar` before returning `a` divided by the `scaled_div_vec`
                        pub inline fn scaled_single_divide(a: SIMDVec2, div_vec: Vec2, scalar: Float) SIMDVec2 {
                            assert.neither_equals("div_vec.x", div_vec.x, "div_vec.y", div_vec.y, "0", 0, "div_vec cannot have either dimension equal zero (causes divide-by-zero)");
                            assert.not_equal("scalar", scalar, "0", 0, "scalar cannot be zero (causes divide-by-zero)");
                            const scaled_vec_x: SIMD_T = @splat(div_vec.x * scalar);
                            const scaled_vec_y: SIMD_T = @splat(div_vec.y * scalar);
                            return SIMDVec2{ .x = a.x / scaled_vec_x, .y = a.y / scaled_vec_y };
                        }

                        pub inline fn distance_to(a: SIMDVec2, b: SIMDVec2) SIMD_T {
                            const diff = SIMDVec2{ .x = b.x - a.x, .y = b.y - a.y };
                            return @sqrt((diff.x * diff.x) + (diff.y * diff.y));
                        }

                        pub inline fn distance_to_squared(a: SIMDVec2, b: SIMDVec2) SIMD_T {
                            const diff = SIMDVec2{ .x = b.x - a.x, .y = b.y - a.y };
                            return (diff.x * diff.x) + (diff.y * diff.y);
                        }

                        pub inline fn distance_to_single(a: SIMDVec2, b: Vec2) SIMD_T {
                            const vec_x: SIMD_T = @splat(b.x);
                            const vec_y: SIMD_T = @splat(b.y);
                            const diff = SIMDVec2{ .x = vec_x - a.x, .y = vec_y - a.y };
                            return @sqrt((diff.x * diff.x) + (diff.y * diff.y));
                        }

                        pub inline fn distance_to_squared_single(a: SIMDVec2, b: Vec2) SIMD_T {
                            const vec_x: SIMD_T = @splat(b.x);
                            const vec_y: SIMD_T = @splat(b.y);
                            const diff = SIMDVec2{ .x = vec_x - a.x, .y = vec_y - a.y };
                            return (diff.x * diff.x) + (diff.y * diff.y);
                        }

                        pub inline fn length(self: SIMDVec2) SIMD_T {
                            return @sqrt((self.x * self.x) + (self.y * self.y));
                        }

                        pub inline fn length_squared(self: SIMDVec2) SIMD_T {
                            return (self.x * self.x) + (self.y * self.y);
                        }

                        pub inline fn length_using_squares(x_squared: SIMD_T, y_squared: SIMD_T) SIMD_T {
                            assert.greater_than_or_equal_to("x_squared", x_squared, "0", 0, "x_squared must be >= 0 (squared numbers are always positive)");
                            assert.greater_than_or_equal_to("y_squared", y_squared, "0", 0, "y_squared must be >= 0 (squared numbers are always positive)");
                            return @sqrt(x_squared + y_squared);
                        }

                        pub inline fn length_using_sum_of_squares(sum_of_squares: SIMD_T) SIMD_T {
                            assert.greater_than_or_equal_to("sum_of_squares", sum_of_squares, "0", 0, "sum_of_squares must be >= 0 (squared numbers are always positive)");
                            return @sqrt(sum_of_squares);
                        }

                        pub inline fn normalize(self: SIMDVec2) SIMDVec2 {
                            if (self.x == 0 and self.y == 0) return SIMDVec2.new(0, 0);
                            const len = @sqrt((self.x * self.x) + (self.y * self.y));
                            return self{ .x = self.x / len, .y = self.y / len };
                        }

                        pub inline fn normalize_using_length(self: SIMDVec2, len: SIMD_T) SIMDVec2 {
                            if (len == 0) return SIMDVec2.new(0, 0);
                            return SIMDVec2{ .x = self.x / len, .y = self.y / len };
                        }

                        pub inline fn normalize_using_squares(self: SIMDVec2, x_squared: SIMD_T, y_squared: SIMD_T) SIMDVec2 {
                            const len = @sqrt(x_squared + y_squared);
                            if (len == 0) return SIMDVec2.new(0, 0);
                            return SIMDVec2{ .x = self.x / len, .y = self.y / len };
                        }
                        pub inline fn normalize_using_sum_of_squares(self: SIMDVec2, sum_of_squares: SIMD_T) SIMDVec2 {
                            const len = @sqrt(sum_of_squares);
                            if (len == 0) return SIMDVec2.new(0, 0);
                            return SIMDVec2{ .x = self.x / len, .y = self.y / len };
                        }

                        pub inline fn angle_between(a: SIMDVec2, b: SIMDVec2) SIMD_T {
                            const dot_prod = (a.x * b.x) + (a.y * b.y);
                            const lengths_multiplied = @sqrt((a.x * a.x) + (a.y * a.y)) * @sqrt((b.x * b.x) + (b.y * b.y));
                            assert.greater_than("lengths_multiplied", lengths_multiplied, "0", 0, "the lengths of each vector multiplied by each other cannot be zero (one or both vectors had zero length, causes divide-by-zero)");
                            return math.acos(dot_prod / lengths_multiplied);
                        }

                        pub inline fn angle_between_using_lengths(a: SIMDVec2, b: SIMDVec2, len_a: SIMD_T, len_b: SIMD_T) SIMD_T {
                            const dot_prod = (a.x * b.x) + (a.y * b.y);
                            const lengths_multiplied = len_a * len_b;
                            assert.greater_than("lengths_multiplied", lengths_multiplied, "0", 0, "the lengths of each vector multiplied by each other cannot be zero (one or both vectors had zero length, causes divide-by-zero)");
                            return math.acos(dot_prod / lengths_multiplied);
                        }

                        pub inline fn angle_between_using_normals(a_norm: SIMDVec2, b_norm: SIMDVec2) SIMD_T {
                            const dot_prod = (a_norm.x * b_norm.x) + (a_norm.y * b_norm.y);
                            return math.acos(dot_prod);
                        }

                        /// Returns the scalar ratio of (A / B), asserts that A and B have the same slope and are not both (0, 0)
                        pub inline fn ratio_of_a_to_b(a: SIMDVec2, b: SIMDVec2) SIMD_T {
                            if (a.x != 0 and b.x != 0) {
                                assert.approx_equal("slope of a", a.y / a.x, "slope or b", b.y / b.x, "both slopes must be equal to compare them as a ratio of one to the other");
                                return a.x / b.x;
                            } else if (a.y != 0 and b.y != 0) {
                                assert.approx_equal("slope of a", a.x / a.y, "slope or b", b.x / b.y, "both slopes must be equal to compare them as a ratio of one to the other");
                                return a.y / b.y;
                            } else {
                                assert.is_unreachable("either slope of a != slope of b (one of the vectors has 0 in one axis where the other doesnt) OR both vectors are (0, 0)");
                            }
                        }

                        pub inline fn perp_ccw(self: SIMDVec2) SIMDVec2 {
                            return SIMDVec2{ .x = -self.y, .y = self.x };
                        }

                        pub inline fn perp_cw(self: SIMDVec2) SIMDVec2 {
                            return SIMDVec2{ .x = self.y, .y = -self.x };
                        }

                        pub inline fn lerp_a_to_b(a: SIMDVec2, b: SIMDVec2, delta: SIMD_T) SIMDVec2 {
                            return SIMDVec2{ .x = ((b.x - a.x) * delta) + a.x, .y = ((b.y - a.y) * delta) + a.y };
                        }

                        pub inline fn lerp_a_to_b_with_delta_min_to_max(a: SIMDVec2, b: SIMDVec2, min_delta: SIMD_T, delta: SIMD_T, max_delta: SIMD_T) SIMDVec2 {
                            const percent = (delta - min_delta) / (max_delta - min_delta);
                            return SIMDVec2{ .x = ((b.x - a.x) * percent) + a.x, .y = ((b.y - a.y) * percent) + a.y };
                        }

                        pub inline fn lerp_a_to_b_with_delta_zero_to_max(a: SIMDVec2, b: SIMDVec2, delta: SIMD_T, max_delta: SIMD_T) SIMDVec2 {
                            const percent = delta / max_delta;
                            return SIMDVec2{ .x = ((b.x - a.x) * percent) + a.x, .y = ((b.y - a.y) * percent) + a.y };
                        }

                        pub inline fn rotate_radians(self: SIMDVec2, radians: SIMD_T) SIMDVec2 {
                            const cos = @cos(radians);
                            const sin = @sin(radians);
                            return SIMDVec2{ .x = (self.x * cos) - (self.y * sin), .y = (self.x * sin) + (self.y * cos) };
                        }

                        pub inline fn rotate_degrees(self: SIMDVec2, degrees: SIMD_T) SIMDVec2 {
                            const rads = degrees * math.rad_per_deg;
                            const cos = @cos(rads);
                            const sin = @sin(rads);
                            return SIMDVec2{ .x = (self.x * cos) - (self.y * sin), .y = (self.x * sin) + (self.y * cos) };
                        }

                        pub inline fn rotate_sin_cos(self: SIMDVec2, sin: SIMD_T, cos: SIMD_T) SIMDVec2 {
                            return SIMDVec2{ .x = (self.x * cos) - (self.y * sin), .y = (self.x * sin) + (self.y * cos) };
                        }

                        pub inline fn rotate_radians_single(self: SIMDVec2, radians: Float) SIMDVec2 {
                            const cos: SIMD_T = @splat(@cos(radians));
                            const sin: SIMD_T = @splat(@sin(radians));
                            return SIMDVec2{ .x = (self.x * cos) - (self.y * sin), .y = (self.x * sin) + (self.y * cos) };
                        }

                        pub inline fn rotate_degrees_single(self: SIMDVec2, degrees: Float) SIMDVec2 {
                            const rads = degrees * math.rad_per_deg;
                            const cos: SIMD_T = @splat(@cos(rads));
                            const sin: SIMD_T = @splat(@sin(rads));
                            return SIMDVec2{ .x = (self.x * cos) - (self.y * sin), .y = (self.x * sin) + (self.y * cos) };
                        }

                        pub inline fn rotate_sin_cos_single(self: SIMDVec2, sin: Float, cos: Float) SIMDVec2 {
                            const simd_cos: SIMD_T = @splat(cos);
                            const simd_sin: SIMD_T = @splat(sin);
                            return SIMDVec2{ .x = (self.x * simd_cos) - (self.y * simd_sin), .y = (self.x * simd_sin) + (self.y * simd_cos) };
                        }

                        pub inline fn reflect(self: SIMDVec2, reflect_normal: SIMDVec2) SIMDVec2 {
                            const fix_scale = 2 * ((self.x * reflect_normal.x) + (self.y * reflect_normal.y));
                            return SIMDVec2{ .x = self.x - (reflect_normal.x * fix_scale), .y = self.y - (reflect_normal.y * fix_scale) };
                        }

                        pub inline fn negate(self: SIMDVec2) SIMDVec2 {
                            return SIMDVec2{ .x = -self.x, .y = -self.y };
                        }

                        pub inline fn equals(a: SIMDVec2, b: SIMDVec2) SIMD_BOOL {
                            return a.x == b.x and a.y == b.y;
                        }
                        pub inline fn approx_equal(a: SIMDVec2, b: SIMDVec2) SIMD_BOOL {
                            const abs_diff_x = @abs(b.x - a.x);
                            const abs_diff_y = @abs(b.y - a.y);
                            return (abs_diff_x <= APPROX_TOLERANCE) and (abs_diff_y <= APPROX_TOLERANCE);
                        }

                        pub inline fn is_zero(self: SIMDVec2) SIMD_BOOL {
                            return self.x == 0.0 and self.y == 0.0;
                        }

                        pub inline fn approx_colinear(a: SIMDVec2, b: SIMDVec2, c: SIMDVec2) SIMD_BOOL {
                            const cross_3 = ((c.y - a.y) * (b.x - a.x)) - ((c.x - a.x) * (b.y - a.y));
                            return @abs(cross_3) <= APPROX_TOLERANCE;
                        }

                        pub inline fn colinear(a: SIMDVec2, b: SIMDVec2, c: SIMDVec2) SIMD_BOOL {
                            const cross_3 = ((c.y - a.y) * (b.x - a.x)) - ((c.x - a.x) * (b.y - a.y));
                            return cross_3 == 0;
                        }

                        // /// Returns the (approximate) orientation of a -> b -> c
                        // pub inline fn approx_orientation(a: SIMDVec2, b: SIMDVec2, c: SIMDVec2) O {
                        //     const cross_3 = ((c.y - a.y) * (b.x - a.x)) - ((c.x - a.x) * (b.y - a.y));
                        //     if (@abs(cross_3) <= TOLERANCE) return .Colinear;
                        //     if (cross_3 > 0) return .WindingClockwise;
                        //     return .WindingCounterClockwise;
                        // }

                        // /// Returns the orientation of a -> b -> c
                        // pub inline fn orientation(a: SIMDVec2, b: SIMDVec2, c: SIMDVec2) O {
                        //     const cross_3 = ((c.y - a.y) * (b.x - a.x)) - ((c.x - a.x) * (b.y - a.y));
                        //     if (cross_3 == 0) return .Colinear;
                        //     if (cross_3 > 0) return .WindingClockwise;
                        //     return .WindingCounterClockwise;
                        // }

                        pub inline fn velocity_required_to_reach_point_at_time(current: SIMDVec2, target: SIMDVec2, time: SIMD_T) SIMDVec2 {
                            return target.subtract(current).scale(1.0 / time);
                        }

                        pub inline fn velocity_required_to_reach_point_at_time_inverse(current: SIMDVec2, target: SIMDVec2, inverse_time: SIMD_T) SIMDVec2 {
                            return target.subtract(current).scale(inverse_time);
                        }

                        pub inline fn abs(self: SIMDVec2) SIMDVec2 {
                            return SIMDVec2{ .x = @abs(self.x), .y = @abs(self.y) };
                        }
                    };
                }
            };
        };

        pub fn define_zox2d_with_secondary_options(options_2: Zox2dOptionsSecondary) type {
            const _assert = Utils.define_assert_package_with_options(options_1.assert_package_options);
            if (@typeInfo(options_1.collision_filter_group_int_type) != .Void or @typeInfo(options_1.collision_filter_group_int_type) != .Int or @typeInfo(options_1.collision_filter_group_int_type).Int.signedness != .signed) {
                @compileError("options_1.collision_filter_group_int_type must be either the `void` type or a SIGNED integer type");
            }
            if (@typeInfo(options_1.collision_filter_uint_type) != .Int or @typeInfo(options_1.collision_filter_uint_type).Int.signedness != .unsigned) {
                @compileError("options_1.collision_filter_uint_type must be an UNSIGNED integer type");
            }
            if (@typeInfo(options_1.float_type) != .Float) {
                @compileError("options_1.float_type must be a float type");
            }
            if (@typeInfo(options_1.object_id_uint_type) != .Int or @typeInfo(options_1.object_id_uint_type).Int.signedness != .unsigned) {
                @compileError("options_1.object_id_type must be an UNSIGNED integer type");
            }
            if (@typeInfo(options_1.world_id_uint_type) != .Int or @typeInfo(options_1.world_id_uint_type).Int.signedness != .unsigned) {
                @compileError("options_1.world_id_type must be an UNSIGNED integer type");
            }
            if (@typeInfo(options_1.generation_uint_type) != .Int or @typeInfo(options_1.generation_uint_type).Int.signedness != .unsigned) {
                @compileError("options_1.generation_uint_type must be an UNSIGNED integer type");
            }
            if (@typeInfo(options_1.packed_id_uint_type) != .Int or @typeInfo(options_1.packed_id_uint_type).Int.signedness != .unsigned) {
                @compileError("options_1.packed_id_uint_type must be an UNSIGNED integer type");
            }
            if (@typeInfo(options_1.bitset_uint_type) != .Int or @typeInfo(options_1.bitset_uint_type).Int.signedness != .unsigned) {
                @compileError("options_1.bitset_uint_type must be an UNSIGNED integer type");
            }
            return struct {
                const Zox2D = @This();
                const assert = _assert;
                /// General float type to use for fields and calculations
                pub const Float = options_1.float_type;
                /// The float type to use for floating point values that shouls always
                /// be within or near the range [0, 1]
                pub const FracFloat = options_1.fractional_float_type;
                /// General unsigned integer type to use for fields and calculations
                pub const UInt: type = @Type(Type{ .Int = .{ .bits = @typeInfo(Float).Float.bits, .signedness = .unsigned } });

                /// Unsigned integer type to use in object id objects (except `WorldID`) as their `index` field
                pub const ObjectIdUInt = options_1.object_id_uint_type;
                /// Unsigned integer type to use in `WorldID` as their `index` field
                pub const WorldIdUInt = options_1.world_id_uint_type;
                /// Unsigned integer type to use in object id objects as their `generation` field
                pub const GenerationUInt = options_1.generation_uint_type;
                /// type to use to pack object id objects into a single integer
                pub const PackedIdUInt = options_1.packed_id_uint_type;
                /// Unsigned integer type used by a `BitSet` as its underlying block type
                pub const BitsetUInt = options_1.bitset_uint_type;

                /// the type passed to debug draw functions for color data
                pub const DebugColor = options_1.debug_color_type;

                /// custom type to attatch to all `Body` objects for user use
                pub const BodyUserData = options_1.body_user_data_type;
                /// custom type to attatch to all `Shape` objects for user use
                pub const ShapeUserData = options_1.shape_user_data_type;
                /// custom type to attatch to all `World` objects for user use
                pub const WorldUserData = options_1.world_user_data_type;
                /// custom type to attatch to all `Chain` objects for user use
                pub const ChainUserData = options_1.chain_user_data_type;
                /// custom type to attatch to all `NullJoint` objects for user use
                pub const NullJointUserData = options_1.null_joint_user_data_type;
                /// custom type to attatch to all `WeldJoint` objects for user use
                pub const WeldJointUserData = options_1.weld_joint_user_data_type;
                /// custom type to attatch to all `MotorJoint` objects for user use
                pub const MotorJointUserData = options_1.motor_joint_user_data_type;
                /// custom type to attatch to all `MouseJoint` objects for user use
                pub const MouseJointUserData = options_1.mouse_joint_user_data_type;
                /// custom type to attatch to all `WheelJoint` objects for user use
                pub const WheelJointUserData = options_1.wheel_joint_user_data_type;
                /// custom type to attatch to all `DistanceJoint` objects for user use
                pub const DistanceJointUserData = options_1.distance_joint_user_data_type;
                /// custom type to attatch to all `RevoluteJoint` objects for user use
                pub const RevoluteJointUserData = options_1.revolute_joint_user_data_type;
                /// custom type to attatch to all `PrismaticJoint` objects for user use
                pub const PrismaticJointUserData = options_1.prismatic_joint_user_data_type;
                /// custom type to pass to the custom pre-solve filter callback for user use
                pub const PreSolveUserData = options_1.pre_solve_user_data_type;
                /// custom type to pass to the custom collision filter callback for user use
                pub const CollisionFilterUserData = options_1.collision_filter_user_data_type;

                /// Allocator for ID pools (free id lists)
                pub const AllocIDs: *Allocator = options_1.id_allocator;
                /// Allocator for `World` object pools
                pub const AllocWorld: *Allocator = &std.heap.page_allocator;
                /// Allocator for `Body` object pools
                pub const AllocBody: *Allocator = &std.heap.page_allocator;
                /// Allocator for `Shape` object pools
                pub const AllocShape: *Allocator = &std.heap.page_allocator;
                /// Allocator for `BitSet` object pools
                pub const AllocBitSet: *Allocator = &std.heap.page_allocator;
                /// Allocator for `SolverSet` object pools
                pub const AllocSolverSet: *Allocator = &std.heap.page_allocator;
                /// Allocator for `Joint` object pools
                pub const AllocJoint: *Allocator = &std.heap.page_allocator;
                /// Allocator for `Contact` object pools
                pub const AllocContact: *Allocator = &std.heap.page_allocator;
                /// Allocator for `Island` object pools
                pub const AllocIsland: *Allocator = &std.heap.page_allocator;
                /// Allocator for `Chain` object pools
                pub const AllocChain: *Allocator = &std.heap.page_allocator;
                /// Allocator for `SensorEventBegin` and `SensorEventEnd` lists
                pub const AllocSensorEvent: *Allocator = &std.heap.page_allocator;
                /// Allocator for `ContactTouchEventBegin` and `ContactTouchEventEnd` lists
                pub const AllocContactTouchEvent: *Allocator = &std.heap.page_allocator;
                /// Allocator for `ContactHitEvent` lists
                pub const AllocContactHitEvent: *Allocator = &std.heap.page_allocator;
                /// Allocator for `MoveEvent` lists
                pub const AllocMoveEvent: *Allocator = &std.heap.page_allocator;

                ///TODO
                pub const CustomTaskData = options_1.custom_task_data_type;
                ///TODO
                pub const CustomTask = options_1.custom_task_type;
                ///TODO
                pub const CollisionFilterUInt = options_1.collision_filter_uint_type;
                ///TODO
                pub const CollisionFilterGroupInt = options_1.collision_filter_group_int_type;

                /// Underlying `StaticAllocBuffer` to use for the `BitSet` type
                pub const BitsetBuffer = StaticAllocBuffer.define(BitsetUInt, get_allocator(options_1.bitset_allocator));
                /// Object pool for `Body` objects, handles id creation and assignment as well as object storage and retrieval
                pub const BodyPool = define_object_pool(Body, options_1.body_pool_allocator);
                /// Object pool for `Shape` objects, handles id creation and assignment as well as object storage and retrieval
                pub const ShapePool = define_object_pool(Shape, options_1.shape_pool_allocator);
                /// Object pool for `SolverSet` objects, handles id creation and assignment as well as object storage and retrieval
                pub const SolverSetPool = define_object_pool(SolverSet, options_1.solver_set_pool_allocator);
                /// Object pool for `Joint` objects, handles id creation and assignment as well as object storage and retrieval
                pub const JointPool = define_object_pool(Joint, options_1.joint_pool_allocator);
                /// Object pool for `Contact` objects, handles id creation and assignment as well as object storage and retrieval
                pub const ContactPool = define_object_pool(Contact, options_1.contact_pool_allocator);
                /// Object pool for `Island` objects, handles id creation and assignment as well as object storage and retrieval
                pub const IslandPool = define_object_pool(Island, options_1.island_pool_allocator);
                /// Object pool for `Chain` objects, handles id creation and assignment as well as object storage and retrieval
                pub const ChainPool = define_object_pool(Chain, options_1.chain_pool_allocator);

                pub const PropertyMixingMode = Zox2dOptionsSecondary.ProperyMixingMode;
                pub const PropertyMixingFormula = Zox2dOptionsSecondary.PropertyMixingFormula;

                pub const CustomPreSolveFunction = Zox2dOptionsSecondary.CustomPreSolveFunction;
                pub const CustomFilterFunction = Zox2dOptionsSecondary.CustomFilterFunction;
                pub const EnqueueTaskCallback = Zox2dOptionsSecondary.EnqueueTaskCallback;
                pub const FinishTaskCallback = Zox2dOptionsSecondary.FinishTaskCallback;
                pub const TaskCallback = Zox2dOptionsSecondary.TaskCallback;

                ///TODO
                pub const DEBUG_ENABLED: bool = options_1.enable_debug;
                ///TODO
                pub const VALIDATION_MODE: ValidationMode = options_1.validation_mode;
                ///TODO
                pub const APPROX_TOLERANCE: Float = @floatCast(options_1.approx_tolerance);
                ///TODO
                pub const VALIDATE_FREE_IDS: bool = options_1.validate_free_ids;
                ///TODO
                pub const MAX_WORLDS: usize = options_1.max_worlds;
                ///TODO
                pub const INCLUDE_RADIANS_IN_TRANSFORM: bool = options_1.include_radians_in_transform;

                ///TODO
                pub inline fn default_friction_mixing_formula(friction_a: Float, material_id_a: UInt, friction_b: Float, material_id_b: UInt) Float {
                    switch (options_2.default_friction_mixing_formula) {
                        .Min => return @min(friction_a, friction_b),
                        .HarmonicAverage => return Math.harmonic_average(friction_a, friction_b),
                        .GeometricAverage => return Math.arithmetic_average(friction_a, friction_b),
                        .ArithmeticAverage => return Math.arithmetic_average(friction_a, friction_b),
                        .QuadraticAverage => return Math.quadratic_average(friction_a, friction_b),
                        .Max => return @max(friction_a, friction_b),
                        .Custom => |formula| return formula(friction_a, material_id_a, friction_b, material_id_b),
                    }
                }
                ///TODO
                pub inline fn default_elasticity_mixing_formula(elasticity_a: Float, material_id_a: UInt, elasticity_b: Float, material_id_b: UInt) Float {
                    switch (options_2.default_elasticity_mixing_formula) {
                        .Min => return @min(elasticity_a, elasticity_b),
                        .HarmonicAverage => return Math.harmonic_average(elasticity_a, elasticity_b),
                        .GeometricAverage => return Math.arithmetic_average(elasticity_a, elasticity_b),
                        .ArithmeticAverage => return Math.arithmetic_average(elasticity_a, elasticity_b),
                        .QuadraticAverage => return Math.quadratic_average(elasticity_a, elasticity_b),
                        .Max => return @max(elasticity_a, elasticity_b),
                        .Custom => |formula| return formula(elasticity_a, material_id_a, elasticity_b, material_id_b),
                    }
                }

                // var root_alloctor: Allocator = undefined;
                // var allocator_large: Allocator = undefined;
                // var block_allocator_large: BlockAllocator = undefined;
                // var pba_allocator_large: PBA_Large = undefined;
                // var allocator_medium: Allocator = undefined;
                // var block_allocator_medium: BlockAllocator = undefined;
                // var pba_allocator_medium: PBA_Medium = undefined;
                // var allocator_small: Allocator = undefined;
                // var block_allocator_small: BlockAllocator = undefined;
                // var pba_allocator_small: PBA_Small = undefined;
                // var allocator_micro: Allocator = undefined;
                // var block_allocator_micro: BlockAllocator = undefined;
                // var pba_allocator_micro: PBA_Micro = undefined;

                // pub var world_pool: WorldPool = WorldPool{};

                pub fn init() void {
                    // root_alloctor = std.heap.page_allocator;

                    // pba_allocator_large = PBA_Large.new(root_alloctor);
                    // allocator_large = pba_allocator_large.allocator();
                    // block_allocator_large = pba_allocator_large.block_allocator();

                    // pba_allocator_medium = PBA_Medium.new(allocator_large);
                    // allocator_medium = pba_allocator_medium.allocator();
                    // block_allocator_medium = pba_allocator_medium.block_allocator();

                    // pba_allocator_small = PBA_Small.new(allocator_medium);
                    // allocator_small = pba_allocator_small.allocator();
                    // block_allocator_small = pba_allocator_small.block_allocator();

                    // pba_allocator_micro = PBA_Small.new(allocator_small);
                    // allocator_micro = pba_allocator_micro.allocator();
                    // block_allocator_micro = pba_allocator_micro.block_allocator();
                }

                pub fn uninit() void {
                    // world_pool.destroy();

                    // pba_allocator_micro.release_all_memory(false);
                    // pba_allocator_small.release_all_memory(false);
                    // pba_allocator_medium.release_all_memory(false);
                    // pba_allocator_large.release_all_memory(false);
                }

                pub fn get_world_from_id(id: WorldID) *World {
                    assert.greater_than_or_equal_to("id.index", id.index, "1", 1, "index must be >= 1, index 0 indicates NULL");
                    assert.less_than_or_equal_to("id.index", id.index, "max worlds", MAX_WORLDS, "index must be <= max world setting");
                    const world: *World = &world_pool.worlds[id.index - 1];
                    assert.equal("id.index", id.index, "world.world_id", world.world_id, "world located at this index does not have a matching world_id");
                    assert.equal("id.index", id.generation, "world.generation", world.generation, "world located at this index does not have a matching generation");
                    return world;
                }

                pub fn get_world_from_index(index: WorldIdUInt) *World {
                    assert.greater_than_or_equal_to("index", index, "1", 1, "index must be >= 1, index 0 indicates NULL");
                    assert.less_than_or_equal_to("index", index, "max worlds", MAX_WORLDS, "index must be <= max world setting");
                    return &world_pool.worlds[index];
                }

                pub fn get_world_from_index_assert_unlocked(index: WorldIdUInt) *World {
                    assert.greater_than_or_equal_to("index", index, "1", 1, "index must be >= 1, index 0 indicates NULL");
                    assert.less_than_or_equal_to("index", index, "max worlds", MAX_WORLDS, "index must be <= max world setting");
                    const world: *World = &world_pool.worlds[index];
                    assert.is_false("world.is_locked()", world.is_locked(), "attempted to return a locked world");
                    return world;
                }

                pub const Math = struct {
                    pub inline fn lerp_a_to_b(a: Float, b: Float, delta: Float) Float {
                        return ((b - a) * delta) + a;
                    }

                    pub inline fn lerp_a_to_b_with_delta_min_to_max(a: Float, b: Float, min_delta: Float, delta: Float, max_delta: Float) Float {
                        return ((b - a) * ((delta - min_delta) / (max_delta - min_delta))) + a;
                    }

                    pub inline fn lerp_a_to_b_with_delta_zero_to_max(a: Float, b: Float, delta: Float, max_delta: Float) Float {
                        return ((b - a) * (delta / max_delta)) + a;
                    }

                    pub inline fn deg_to_rad(degrees: Float) Float {
                        return math.degreesToRadians(degrees);
                    }

                    pub inline fn rad_to_deg(radians: Float) Float {
                        return math.radiansToDegrees(radians);
                    }

                    pub inline fn approx_less_than_or_equal_to(a: Float, b: Float) bool {
                        return a <= b + APPROX_TOLERANCE;
                    }

                    pub inline fn approx_less_than(a: Float, b: Float) bool {
                        return a < b + APPROX_TOLERANCE;
                    }

                    pub inline fn approx_greater_than_or_equal_to(a: Float, b: Float) bool {
                        return a + APPROX_TOLERANCE >= b;
                    }

                    pub inline fn approx_greater_than(a: Float, b: Float) bool {
                        return a + APPROX_TOLERANCE > b;
                    }

                    pub inline fn approx_equal(a: Float, b: Float) bool {
                        const abs_diff = @abs(b - a);
                        return abs_diff <= APPROX_TOLERANCE;
                    }

                    pub inline fn rate_of_change_required_to_reach_val_at_time(current: Float, target: Float, time: Float) Float {
                        return (target - current) * (1.0 / time);
                    }

                    pub inline fn rate_of_change_required_to_reach_val_at_time_inverse(current: Float, target: Float, inverse_time: Float) Float {
                        return (target - current) * inverse_time;
                    }

                    pub inline fn quadratic_average(a: Float, b: Float) Float {
                        return @sqrt(((a * a) + (b * b)) / 2);
                    }

                    pub inline fn arithmetic_average(a: Float, b: Float) Float {
                        return (a + b) / 2;
                    }

                    pub inline fn geometric_average(a: Float, b: Float) Float {
                        return @sqrt(a * b);
                    }

                    pub inline fn harmonic_average(a: Float, b: Float) Float {
                        return (2 * a * b) / (a + b);
                    }
                };

                pub const Vec2 = options_2.Vec2;

                pub const AABB = struct {
                    min: Vec2 = Vec2.new(math.inf(Float), math.inf(Float)),
                    max: Vec2 = Vec2.new(-math.inf(Float), -math.inf(Float)),

                    pub inline fn combine(a: AABB, b: AABB) AABB {
                        return AABB{
                            .min = Vec2.new(@min(a.min.x, b.min.x), @min(a.min.y, b.min.y)),
                            .max = Vec2.new(@max(a.max.x, b.max.x), @max(a.max.y, b.max.y)),
                        };
                    }

                    pub fn combine_and_return_if_changed(a: *AABB, b: AABB) AABB {
                        var changed = false;
                        if (b.min.x < a.min.x) {
                            changed = true;
                            a.min.x = b.min.x;
                        }
                        if (b.min.y < a.min.y) {
                            changed = true;
                            a.min.y = b.min.y;
                        }
                        if (b.max.x > a.max.x) {
                            changed = true;
                            a.max.x = b.max.x;
                        }
                        if (b.max.y > a.max.y) {
                            changed = true;
                            a.max.y = b.max.y;
                        }
                        return changed;
                    }

                    pub inline fn overlaps(a: AABB, b: AABB) bool {
                        return !(a.x_max < b.x_min or b.x_max < a.x_min or a.y_max < b.y_min or b.y_max < a.y_min);
                    }

                    pub inline fn is_valid(self: AABB) bool {
                        const diff = self.max.subtract(self.min);
                        return diff.x >= 0 and diff.y >= 0 and self.max.is_valid() and self.min.is_valid();
                    }

                    pub inline fn perimeter(self: AABB) Float {
                        return 2.0 * ((self.max.x - self.min.x) + (self.max.y - self.min.y));
                    }

                    pub fn raycast(self: AABB, ray_a: Vec2, ray_b: Vec2) CastResult {
                        var result = CastResult{};
                        var t_min = -math.floatMax(Float);
                        var t_max = math.floatMax(Float);

                        const delta = ray_b.subtract(ray_a);
                        const abs_delta = delta.abs();

                        var normal = Vec2.ZERO;

                        if (abs_delta.x < APPROX_TOLERANCE) {
                            if (ray_a.x < self.min.x or ray_a.x > self.max.x) return result;
                        } else {
                            const delta_x_inverse = 1.0 / delta.x;
                            var t1 = (self.min.x - ray_a.x) * delta_x_inverse;
                            var t2 = (self.max.x - ray_a.x) * delta_x_inverse;
                            var sign: Float = -1.0;

                            if (t1 > t2) {
                                const tmp = t1;
                                t1 = t2;
                                t2 = tmp;
                                sign = 1.0;
                            }

                            if (t1 > t_min) {
                                normal.y = 0.0;
                                normal.x = sign;
                                t_min = t1;
                            }

                            t_max = @min(t_max, t2);

                            if (t_min > t_max) return result;
                        }

                        if (abs_delta.y < APPROX_TOLERANCE) {
                            if (ray_a.y < self.min.y or ray_a.y > self.max.y) return result;
                        } else {
                            const delta_y_inverse = 1.0 / delta.y;
                            var t1 = (self.min.y - ray_a.y) * delta_y_inverse;
                            var t2 = (self.max.y - ray_a.y) * delta_y_inverse;
                            var sign: Float = -1.0;

                            if (t1 > t2) {
                                const tmp = t1;
                                t1 = t2;
                                t2 = tmp;
                                sign = 1.0;
                            }

                            if (t1 > t_min) {
                                normal.x = 0.0;
                                normal.y = sign;
                                t_min = t1;
                            }

                            t_max = @min(t_max, t2);

                            if (t_min > t_max) return result;
                        }

                        if (t_min < 0.0 or t_min > 1.0) return result;

                        result.fraction = t_min;
                        result.normal = normal;
                        result.point = Vec2.lerp_a_to_b(ray_a, ray_b, t_min);
                        result.hit = true;
                        return result;
                    }
                };

                /// Result from World.raycast_closest()
                pub const RayResult = struct {
                    shape_id: ShapeID,
                    point: Vec2,
                    normal: Vec2,
                    fraction: Float,
                    node_visits: UInt,
                    leaf_visits: UInt,
                    hit: bool,
                };

                pub const CastResult = struct {
                    normal: Vec2 = Vec2.ZERO,
                    point: Vec2 = Vec2.ZERO,
                    fraction: Float = 0,
                    iterations: u32 = 1,
                    hit: bool = false,
                };

                pub const BitSet = struct {
                    list: BitsetBuffer.List,

                    pub fn create() BitSet {
                        return BitSet{
                            .list = BitsetBuffer.List.create(),
                        };
                    }

                    pub fn create_with_capacity(bit_capacity: ObjectIdUInt) BitSet {
                        var real_capacity = bit_capacity & 0b111111;
                        real_capacity |= real_capacity >> 1;
                        real_capacity |= real_capacity >> 2;
                        real_capacity |= real_capacity >> 2;
                        real_capacity &= 0b1;
                        real_capacity = real_capacity + (bit_capacity >> 6);
                        var set = BitSet{
                            .list = BitsetBuffer.List.create_with_capacity(real_capacity),
                        };
                        const new_cap = set.list.cap;
                        set.list.grow_len_to_cap();
                        @memset(set.list.ptr[0..new_cap], 0);
                        return set;
                    }

                    pub fn destroy(self: *BitSet) void {
                        self.list.release();
                    }

                    pub fn clear(self: *BitSet) void {
                        self.list.clear();
                    }

                    pub fn set_bit(self: *BitSet, bit_idx: usize) void {
                        const real_idx = bit_idx >> 6;
                        const real_bit_idx: math.Log2Int(u64) = @intCast(bit_idx & 0b111111);
                        if (real_idx >= self.list.len) {
                            const old_cap = self.list.cap;
                            self.list.ensure_cap(real_idx + 1);
                            self.list.grow_len_to_cap();
                            const new_cap = self.list.cap;
                            @memset(self.list.ptr[old_cap..new_cap], 0);
                        }
                        self.list.ptr[real_idx].* |= @as(u64, 1) << real_bit_idx;
                    }

                    pub fn clear_bit(self: *BitSet, bit_idx: usize) void {
                        const real_idx = bit_idx >> 6;
                        if (real_idx > self.list.len) return;
                        const real_bit_idx: math.Log2Int(u64) = @intCast(bit_idx & 0b111111);
                        self.list.ptr[real_idx].* &= ~(@as(u64, 1) << real_bit_idx);
                    }

                    pub fn get_bit(self: *const BitSet, bit_idx: usize) bool {
                        const real_idx = bit_idx >> 6;
                        const real_bit_idx: math.Log2Int(u64) = @intCast(bit_idx & 0b111111);
                        return ((self.list.ptr[real_idx].* >> real_bit_idx) & 0b1) != 0;
                    }

                    pub fn bitwise_or(self: *BitSet, other: BitSet) void {
                        assert.equal("self.u64_list.len", self.list.len, "other.u64_list.len", other.list.len, "can only perform a bitwise OR on two bitsets with equal block length");
                        var i: usize = 0;
                        while (i < self.list.len) : (i += 1) {
                            self.list.ptr[i].* |= other.list.ptr[i].*;
                        }
                    }
                };

                pub const WorldID = struct {
                    index: WorldIdUInt,
                    generation: GenerationUInt,

                    pub const NULL = BodyID{ .index = 0, .world = 0, .generation = 0 };
                    pub inline fn is_null(self: WorldID) bool {
                        return self.index == 0;
                    }
                    pub inline fn not_null(self: WorldID) bool {
                        return self.index != 0;
                    }
                    pub inline fn equals(self: WorldID, other: WorldID) bool {
                        return self.index == other.index and self.generation == other.generation;
                    }
                };

                pub const BodyID = struct {
                    index: ObjectIdUInt,
                    world: WorldIdUInt,
                    generation: GenerationUInt,

                    pub const NULL = BodyID{ .index = 0, .world = 0, .generation = 0 };
                    pub inline fn is_null(self: BodyID) bool {
                        return self.index == 0;
                    }
                    pub inline fn not_null(self: BodyID) bool {
                        return self.index != 0;
                    }
                    pub inline fn equals(self: BodyID, other: BodyID) bool {
                        return self.index == other.index and self.world == other.world and self.generation == other.generation;
                    }
                    pub inline fn pack(self: BodyID) PackedIdUInt {
                        var val = @as(PackedIdUInt, @intCast(self.index));
                        val |= @as(PackedIdUInt, @intCast(self.world)) << @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits));
                        val |= @as(PackedIdUInt, @intCast(self.generation)) << @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits + @typeInfo(WorldIdUInt).Int.bits));
                    }
                    pub inline fn unpack_from(val: PackedIdUInt) BodyID {
                        return BodyID{
                            .index = @as(ObjectIdUInt, @intCast(val & math.maxInt(ObjectIdUInt))),
                            .world = @as(WorldIdUInt, @intCast((val >> @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits))) & math.maxInt(WorldIdUInt))),
                            .generation = @as(WorldIdUInt, @intCast((val >> @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits + @typeInfo(WorldIdUInt).Int.bits))) & math.maxInt(GenerationUInt))),
                        };
                    }
                };

                pub const ShapeID = options_2.ShapeID;

                pub const ChainID = struct {
                    index: ObjectIdUInt,
                    world: WorldIdUInt,
                    generation: GenerationUInt,

                    pub const NULL = ChainID{ .index = 0, .world = 0, .generation = 0 };
                    pub inline fn is_null(self: ChainID) bool {
                        return self.index == 0;
                    }
                    pub inline fn not_null(self: ChainID) bool {
                        return self.index != 0;
                    }
                    pub inline fn equals(self: ChainID, other: ChainID) bool {
                        return self.index == other.index and self.world == other.world and self.generation == other.generation;
                    }
                    pub inline fn pack(self: ChainID) PackedIdUInt {
                        var val = @as(PackedIdUInt, @intCast(self.index));
                        val |= @as(PackedIdUInt, @intCast(self.world)) << @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits));
                        val |= @as(PackedIdUInt, @intCast(self.generation)) << @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits + @typeInfo(WorldIdUInt).Int.bits));
                    }
                    pub inline fn unpack_from(val: PackedIdUInt) ChainID {
                        return ChainID{
                            .index = @as(ObjectIdUInt, @intCast(val & math.maxInt(ObjectIdUInt))),
                            .world = @as(WorldIdUInt, @intCast((val >> @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits))) & math.maxInt(WorldIdUInt))),
                            .generation = @as(WorldIdUInt, @intCast((val >> @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits + @typeInfo(WorldIdUInt).Int.bits))) & math.maxInt(GenerationUInt))),
                        };
                    }
                };

                pub const JointID = struct {
                    index: ObjectIdUInt,
                    world: WorldIdUInt,
                    generation: GenerationUInt,

                    pub const NULL = JointID{ .index = 0, .world = 0, .generation = 0 };
                    pub inline fn is_null(self: JointID) bool {
                        return self.index == 0;
                    }
                    pub inline fn not_null(self: JointID) bool {
                        return self.index != 0;
                    }
                    pub inline fn equals(self: JointID, other: JointID) bool {
                        return self.index == other.index and self.world == other.world and self.generation == other.generation;
                    }
                    pub inline fn pack(self: JointID) PackedIdUInt {
                        var val = @as(PackedIdUInt, @intCast(self.index));
                        val |= @as(PackedIdUInt, @intCast(self.world)) << @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits));
                        val |= @as(PackedIdUInt, @intCast(self.generation)) << @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits + @typeInfo(WorldIdUInt).Int.bits));
                    }
                    pub inline fn unpack_from(val: PackedIdUInt) JointID {
                        return JointID{
                            .index = @as(ObjectIdUInt, @intCast(val & math.maxInt(ObjectIdUInt))),
                            .world = @as(WorldIdUInt, @intCast((val >> @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits))) & math.maxInt(WorldIdUInt))),
                            .generation = @as(WorldIdUInt, @intCast((val >> @as(math.Log2Int(PackedIdUInt), @intCast(@typeInfo(ObjectIdUInt).Int.bits + @typeInfo(WorldIdUInt).Int.bits))) & math.maxInt(GenerationUInt))),
                        };
                    }
                };

                /// This is used to filter collision on shapes. It affects shape-vs-shape collisions
                /// and shape-versus-query collisions.
                ///
                /// Each bit represents a separate category, and a shape can have multiple categories of its own,
                /// and interact with multiple categories, including its own
                ///
                /// Two shapes will interact if both these conditions are true:
                ///   - `shape_a.own_categories & shape_b.interacts_with_categories > 0`
                ///   - `shape_b.own_categories & shape_a.interacts_with_categories > 0`
                ///
                /// ...OR if:
                ///   - `shape_a.collision_group == shape_b.collision_group and shape_a.collision_group > 0`
                ///
                /// The category bits usually represent your application object types,
                /// but you may use whatever categories work for your application.
                /// For example:
                /// ```zig
                /// pub struct MyCollisionCategories = struct {
                ///     pub const Player: CollisionFilterUInt = 1 << 0; // bit 0
                ///     pub const Enemies: CollisionFilterUInt = 1 << 1; // bit 1
                ///     pub const Walls: CollisionFilterUInt = 1 << 2; // bit 2
                ///     pub const Platforms: CollisionFilterUInt = 1 << 3; // bit 3
                ///     pub const Pickups: CollisionFilterUInt = 1 << 4; // bit 4
                ///     // etc.
                /// }
                /// ```
                pub const CollisionFilter = struct {
                    /// The collision category bits THIS shape has
                    own_categories: CollisionFilterUInt,
                    /// The collision category bits this shape INTERACTS with
                    interacts_with_categories: CollisionFilterUInt,
                    /// Collision groups allow a certain group of objects to never collide (negative)
                    /// or always collide (positive). A group index of zero has no effect. Non-zero group filtering
                    /// always wins against the mask bits.
                    /// For example, you may want ragdolls to collide with other ragdolls but you don't want
                    /// ragdoll self-collision. In this case you would give each ragdoll a unique negative group index
                    /// and apply that group index to all shapes on the ragdoll.
                    collision_group: CollisionFilterGroupInt,
                };

                /// The query filter is used to filter collisions between queries and shapes. For example,
                /// you may want a ray-cast representing a projectile to hit players and the static environment
                /// but not debris.
                pub const CollisionQueryFilter = struct {
                    /// The collision category bits THIS query has
                    own_categories: CollisionFilterUInt,
                    /// The collision category bits this query INTERACTS with
                    interacts_with_categories: CollisionFilterUInt,
                };

                /// A body definition holds all the data needed to construct a rigid body.
                /// You can safely re-use body definitions. Shapes are added to a body after construction.
                /// Body definitions are temporary objects used to bundle creation parameters.
                pub const BodyDef = struct {
                    /// The body type: static, kinematic, or dynamic.
                    body_type: BodyType,
                    /// The initial world position of the body. Bodies should be created with the desired position.
                    ///
                    /// Creating bodies at the origin and then moving them nearly doubles the cost of body creation, especially
                    /// if the body is moved after shapes have been added.
                    initial_position: Vec2,
                    /// The initial world rotation of the body. Use `Rotation.new_xxxxxx()` if you have an angle or only one trig value.
                    initial_rotation: Rotation,
                    /// The initial linear velocity of the body's origin. Usually in meters per second.
                    initial_velocity: Vec2,
                    /// The initial rotation speed (angular velocity) of the body. Radians per second.
                    initial_rotation_speed: Float,
                    /// Veloctiy damping is used to reduce the linear velocity. The damping parameter
                    /// can be larger than 1 but the damping effect becomes sensitive to the
                    /// time step when the damping parameter is large.
                    ///
                    /// Velocity damping can be used to reduce the velocity of an object over time
                    /// (for example to emulate air/water resistance)
                    ///
                    /// Generally, large velocity damping is undesirable because it makes objects move slowly
                    /// as if they are floating.
                    velocity_damping: FracFloat,
                    /// Rotation damping is used to reduce the rotation speed (angular velocity). The damping parameter
                    /// can be larger than 1 but the damping effect becomes sensitive to the
                    /// time step when the damping parameter is large.
                    ///
                    /// Angular damping can be use slow down rotating bodies over time.
                    rotation_damping: FracFloat,
                    /// Scale the gravity applied to this body. Non-dimensional.
                    gravity_scale: Float,
                    /// Sleep speed threshold
                    sleep_threshold: Float,
                    /// Optional body name for debugging (if enabled).
                    debug_name: if (DEBUG_ENABLED) []const u8 else void,
                    /// Stores a user-provided data struct for your application use.
                    user_data: BodyUserData,
                    /// Set this flag to false if this body should never fall asleep.
                    enable_sleep: bool = true,
                    /// Is this body initially awake or sleeping?
                    initially_awake: bool = true,
                    /// Should this body be prevented from rotating? Useful for characters.
                    fixed_rotation: bool = false,
                    /// Treat this body as high speed object that performs continuous collision detection
                    /// against dynamic and kinematic bodies, but not other bullet bodies.
                    ///
                    /// WARNING: Bullets should be used sparingly. They are not a solution for general dynamic-versus-dynamic
                    /// continuous collision. They may interfere with joint constraints.
                    is_bullet: bool = false,
                    /// Used to disable a body. A disabled body does not move or collide.
                    initially_enabled: bool = true,
                    /// This allows this body to bypass rotational speed limits. Should only be used
                    /// for circular objects, like wheels.
                    allow_fast_rotation: bool = false,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE) Validation else void,
                };
                pub const Body = struct {
                    debug_name: if (DEBUG_ENABLED) [32]u8 else void = undefined,
                    user_data: BodyUserData,
                    solver_set_index: u32, //TODO make universe option
                    local_index: u32, //TODO make universe option
                    head_contact_key: u32, //TODO make universe option
                    contact_count: u32, //TODO make universe option
                    head_shape_id: u32, //TODO make universe option
                    shape_count: u32, //TODO make universe option
                    head_chain_id: u32, //TODO make universe option
                    head_joint_key: u32, //TODO make universe option
                    joint_count: u32, //TODO make universe option
                    island_id: u32, //TODO make universe option
                    next_island_id: u32, //TODO make universe option
                    prev_island_id: u32, //TODO make universe option
                    mass: Float,
                    rotational_inertia: Float,
                    sleep_threshold: Float,
                    sleep_time: Float,
                    body_move_index: u32, //TODO make universe option
                    id_index: ObjectIdUInt,
                    body_type: BodyType,
                    id_generation: GenerationUInt,
                    flags: u8,

                    const ENABLE_SLEEP: u8 = 1 << 0;
                    const FIXED_ROTATION: u8 = 1 << 1;
                    const IS_SPEED_CAPPED: u8 = 1 << 2;
                    const IS_MARKED: u8 = 1 << 3;
                    pub inline fn sleep_is_enabled(self: *const Body) bool {
                        return self.flags & ENABLE_SLEEP == ENABLE_SLEEP;
                    }
                    pub inline fn set_sleep_enabled(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= ENABLE_SLEEP;
                        } else {
                            self.flags &= ~ENABLE_SLEEP;
                        }
                    }
                    pub inline fn has_fixed_rotation(self: *const Body) bool {
                        return self.flags & FIXED_ROTATION == FIXED_ROTATION;
                    }
                    pub inline fn set_fixed_rotation(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= FIXED_ROTATION;
                        } else {
                            self.flags &= ~FIXED_ROTATION;
                        }
                    }
                    pub inline fn is_speed_capped(self: *const Body) bool {
                        return self.flags & IS_SPEED_CAPPED == IS_SPEED_CAPPED;
                    }
                    pub inline fn set_speed_capped(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= IS_SPEED_CAPPED;
                        } else {
                            self.flags &= ~IS_SPEED_CAPPED;
                        }
                    }
                    pub inline fn is_marked(self: *const Body) bool {
                        return self.flags & IS_MARKED == IS_MARKED;
                    }
                    pub inline fn set_is_marked(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= IS_MARKED;
                        } else {
                            self.flags &= ~IS_MARKED;
                        }
                    }
                };

                pub const BodyState = struct {
                    linear_velocity: Vec2,
                    angular_velocity: Float,
                    flags: UInt,
                    delta_position: Vec2,
                    delta_rotation: SinCos,

                    pub const IDENTITY = BodyState{
                        .linear_velocity = Vec2.ZERO,
                        .angular_velocity = 0.0,
                        .flags = 0,
                        .delta_position = Vec2.ZERO,
                        .delta_rotation = SinCos.ANGLE_ZERO,
                    };
                };

                pub const BodySim = struct {
                    transform: Transform,
                    center: Vec2,
                    prev_center: Vec2,
                    prev_rotation: SinCos,
                    local_center: Vec2,
                    force: Vec2,
                    torque: Float,
                    inverse_mass: Float,
                    inverse_inertia: Float,
                    linear_damping: Float,
                    angular_damping: Float,
                    gravity_scale: Float,
                    body_id_index: ObjectIdUInt,
                    flags: u8,

                    const IS_FAST: u8 = 1 << 0;
                    const IS_BULLET: u8 = 1 << 1;
                    const IS_SPEED_CAPPED: u8 = 1 << 2;
                    const ALLOWED_FAST_ROTATION: u8 = 1 << 3;
                    const ENLARGE_AABB: u8 = 1 << 4;
                    pub inline fn is_fast(self: *const Body) bool {
                        return self.flags & IS_FAST == IS_FAST;
                    }
                    pub inline fn set_is_fast(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= IS_FAST;
                        } else {
                            self.flags &= ~IS_FAST;
                        }
                    }
                    pub inline fn is_bullet(self: *const Body) bool {
                        return self.flags & IS_BULLET == IS_BULLET;
                    }
                    pub inline fn set_is_bullet(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= IS_BULLET;
                        } else {
                            self.flags &= ~IS_BULLET;
                        }
                    }
                    pub inline fn is_speed_capped(self: *const Body) bool {
                        return self.flags & IS_SPEED_CAPPED == IS_SPEED_CAPPED;
                    }
                    pub inline fn set_is_speed_capped(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= IS_SPEED_CAPPED;
                        } else {
                            self.flags &= ~IS_SPEED_CAPPED;
                        }
                    }
                    pub inline fn fast_rotation_allowed(self: *const Body) bool {
                        return self.flags & ALLOWED_FAST_ROTATION == ALLOWED_FAST_ROTATION;
                    }
                    pub inline fn set_fast_rotation_allowed(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= ALLOWED_FAST_ROTATION;
                        } else {
                            self.flags &= ~ALLOWED_FAST_ROTATION;
                        }
                    }
                    pub inline fn enlarge_aabb(self: *const Body) bool {
                        return self.flags & ENLARGE_AABB == ENLARGE_AABB;
                    }
                    pub inline fn set_enlarge_aabb(self: *Body, state: bool) void {
                        if (state) {
                            self.flags |= ENLARGE_AABB;
                        } else {
                            self.flags &= ~ENLARGE_AABB;
                        }
                    }

                    pub inline fn make_sweep(self: *BodySim) Sweep {
                        return Sweep{
                            .center_1 = self.prev_center,
                            .center_2 = self.center,
                            .sin_cos_1 = self.prev_rotation,
                            .sin_cos_2 = self.transform.rotation.sin_cos,
                            .local_center = self.local_center,
                        };
                    }
                };

                pub const Shape = struct {};
                pub const Joint = struct {};
                pub const SolverSet = struct {};
                pub const Contact = struct {};
                pub const Island = struct {};
                pub const Chain = struct {};
                pub const BroadPhase = struct {};
                pub const ConstraintGraph = struct {};
                // pub const SensorArray = struct {};
                // pub const TaskContextArray = struct {};
                // pub const SensorTaskContextArray = struct {};
                // pub const MoveEventArray = struct {};
                // pub const SensorBeginTouchEventArray = struct {};
                // pub const SensorEndTouchEventArray = struct {};
                // pub const ContactBeginTouchEventArray = struct {};
                // pub const ContactEndTouchEventArray = struct {};
                // pub const ContactHitEventArray = struct {};

                ///
                ///
                /// Also known as the collision 'manifold'
                pub const ContactData = options_2.ContactData;
                pub const Profile = struct {};

                pub const TaskContext = struct {
                    contact_states: BitSet,
                    enlarged_sims: BitSet,
                    awake_islands: BitSet,
                    split_sleep_time: Float,
                    split_island_id: ObjectIdUInt,
                };

                pub fn mix_properties_max(a: Float, mat_id_a: UInt, b: Float, mat_id_b: UInt) Float {
                    _ = mat_id_a;
                    _ = mat_id_b;
                    return @max(a, b);
                }
                pub fn mix_properties_quadratic_average(a: Float, mat_id_a: UInt, b: Float, mat_id_b: UInt) Float {
                    _ = mat_id_a;
                    _ = mat_id_b;
                    return @sqrt(((a * a) + (b * b)) / 2.0);
                }
                pub fn mix_properties_arithmetic_average(a: Float, mat_id_a: UInt, b: Float, mat_id_b: UInt) Float {
                    _ = mat_id_a;
                    _ = mat_id_b;
                    return (a + b) / 2.0;
                }
                pub fn mix_properties_geometric_average(a: Float, mat_id_a: UInt, b: Float, mat_id_b: UInt) Float {
                    _ = mat_id_a;
                    _ = mat_id_b;
                    return @sqrt(a * b);
                }
                pub fn mix_properties_harmonic_average(a: Float, mat_id_a: UInt, b: Float, mat_id_b: UInt) Float {
                    _ = mat_id_a;
                    _ = mat_id_b;
                    return (2 * a * b) / (a + b);
                }
                pub fn mix_properties_min(a: Float, mat_id_a: UInt, b: Float, mat_id_b: UInt) Float {
                    _ = mat_id_a;
                    _ = mat_id_b;
                    return @min(a, b);
                }

                /// World definition used to create a simulation world.
                pub const WorldDef = struct { //CHECKPOINT implement default values
                    /// Gravity vector
                    gravity: Vec2,
                    /// Speed threshold for a bounce to occur, usually in m/s. Collisions above this
                    /// speed have restitution applied (will bounce).
                    bounce_threshold: Float,
                    /// Threshold speed for hit events. Usually meters per second.
                    hit_event_thershold: Float,
                    /// Contact stiffness. Cycles per second. Increasing this increases the speed of overlap recovery, but can introduce jitter.
                    contact_hertz: Float,
                    /// Contact bounciness. Non-dimensional. You can speed up overlap recovery by decreasing this with
                    /// the trade-off that overlap resolution becomes more energetic.
                    contact_damping: Float,
                    /// This parameter controls how fast overlap is resolved (shapes are pushed out of each other)
                    /// and usually has units of meters per second. This only
                    /// puts a cap on the resolution speed. The resolution speed is increased by increasing the hertz and/or
                    /// decreasing the damping ratio.
                    contact_max_pushout_speed: Float,
                    /// Joint stiffness. Cycles per second.
                    joint_hertz: Float,
                    /// Joint bounciness. Non-dimensional.
                    joind_damping: Float,
                    /// Maximum linear speed. Usually meters per second.
                    maximum_linear_speed: Float,
                    /// Optional mixing callback for friction.
                    ///
                    /// The default Zox2D options use the geometic average: `@sqrt(a * b)`
                    friction_mixing_func: PropertyMixingFormula = mix_properties_geometric_average,
                    /// Optional mixing callback for elasticity (bounce/restitution).
                    ///
                    /// The default Zox2D options use the max of both values: `@max(a, b)`
                    elasticity_mixing_func: PropertyMixingFormula = mix_properties_max,
                    /// Can bodies go to sleep to improve performance
                    enable_sleep: bool,
                    /// Enable continuous collision
                    enable_continuous: bool,
                    /// Number of workers to use with the provided task system.
                    ///
                    /// Zox2D does not create threads for you, this value represents the number of threads your
                    /// application has or will create and allocate to Zox2D for simulation
                    ///
                    /// Do no modify the default value unless you also provide a task system and task callbacks
                    /// (`enqueue_task_callback` and `finish_task_callback`)
                    worker_count: UInt,
                    /// Function to spawn tasks
                    enqueue_task_callback: EnqueueTaskCallback,
                    /// Function to finish a task
                    finish_task_callback: FinishTaskCallback,
                    /// User data type that is provided to `enqueue_task_callback` and `finish_task_callback`
                    user_task_data: CustomTaskData,
                    /// User data for the world
                    user_data: WorldUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _valid_internal: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void = if (VALIDATION_MODE == .ValidateAndStoreResult) Validation.Unchecked else void{},
                };

                pub const World = struct {
                    broad_phase: BroadPhase,
                    constraint_graph: ConstraintGraph,
                    body_pool: BodyPool,
                    solver_set_pool: SolverSetPool,
                    joint_pool: JointPool,
                    contact_pool: ContactPool,
                    island_pool: IslandPool,
                    shape_pool: ShapePool,
                    chain_pool: ChainPool,
                    sensor_array: SensorArray,
                    tast_contexts: TaskContextArray,
                    sensor_task_contexts: SensorTaskContextArray,
                    body_move_events: MoveEventArray,
                    sensor_begin_events: SensorBeginTouchEventArray,
                    contact_begin_events: ContactBeginTouchEventArray,
                    sensor_end_events: [2]SensorEndTouchEventArray,
                    contact_end_events: [2]ContactEndTouchEventArray,
                    end_event_idx: u8 = 0,
                    contat_hit_events: ContactHitEventArray,
                    debug_body_set: if (DEBUG_ENABLED) BitSet else void,
                    debug_joint_set: if (DEBUG_ENABLED) BitSet else void,
                    debug_contact_set: if (DEBUG_ENABLED) BitSet else void,
                    step_idx: u64, //TODO: make zox2d option
                    split_island_id: ObjectIdUInt,
                    gravity: Vec2,
                    hit_event_threshold: Float,
                    bounce_threshold: Float,
                    max_linear_speed: Float,
                    contact_max_push_speed: Float,
                    contact_hertz: Float,
                    contact_damping: FracFloat,
                    joint_hertz: Float,
                    joint_damping: FracFloat,
                    friction_calculation_function: PropertyMixingFormula,
                    bounce_calculation_function: PropertyMixingFormula,
                    generation: GenerationUInt,
                    profile: Profile,
                    custom_pre_solve_func: CustomPreSolveFunction,
                    custom_pre_solve_data: PreSolveUserData,
                    custom_filter_func: CustomFilterFunction,
                    custom_filter_data: CustomFilterData,
                    worker_count: UInt,
                    custom_enqueue_task_callback: EnqueueTaskCallback,
                    custom_finish_task_callback: FinishTaskCallback,
                    custom_task_data: CustomTaskData,
                    custom_tree_task: CustomTask,
                    custom_user_data: WorldUserData,
                    inv_h: Float, //VERIFY what is this for?
                    active_task_count: UInt,
                    task_count: UInt,
                    world_id: WorldIdUInt,
                    flags: u8,

                    pub fn create() World {}

                    pub fn destroy(self: *World) void {
                        _ = self;
                    }

                    pub fn get_body(self: *World, body_id: BodyID) *Body {
                        _ = self;
                        _ = body_id;
                    }
                    pub fn get_body_transform(self: *World, body: *const Body) Transform {
                        _ = self;
                        _ = body;
                    }

                    pub fn get_body_transform_with_id(self: *World, body_id: BodyID) Transform {
                        _ = self;
                        _ = body_id;
                    }

                    pub fn create_body_id(self: *World, body_id_int: ObjectIdUInt) BodyID {
                        _ = self;
                        _ = body_id_int;
                    }

                    pub fn should_bodies_collide(self: *World, body_a: *Body, body_b: *Body) bool {
                        _ = self;
                        _ = body_a;
                        _ = body_b;
                    }

                    pub fn is_body_awake(self: *World, body: *Body) bool {
                        _ = self;
                        _ = body;
                    }

                    pub fn get_body_sim(self: *World, body: *Body) *BodySim {
                        _ = self;
                        _ = body;
                    }

                    pub fn get_body_state(self: *World, body: *Body) *BodyState {
                        _ = self;
                        _ = body;
                    }

                    pub fn wake_body(self: *World, body: *Body) bool {
                        _ = self;
                        _ = body;
                    }

                    pub fn update_body_mass_data(self: *World, body: *Body) bool {
                        _ = self;
                        _ = body;
                    }

                    const SLEEP_ENABLED: u8 = 1 << 0;
                    const LOCKED: u8 = 1 << 1;
                    const ENABLE_WARM_STARTING: u8 = 1 << 2;
                    const ENABLE_CONTINUOUS: u8 = 1 << 3;
                    const ENABLE_SPECULATIVE: u8 = 1 << 4;
                    const IN_USE: u8 = 1 << 5;
                    pub inline fn sleep_enabled(self: *const World) bool {
                        return self.flags & SLEEP_ENABLED == SLEEP_ENABLED;
                    }
                    pub inline fn set_sleep_enabled(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= SLEEP_ENABLED;
                        } else {
                            self.flags &= ~SLEEP_ENABLED;
                        }
                    }
                    pub inline fn is_locked(self: *const World) bool {
                        return self.flags & LOCKED == LOCKED;
                    }
                    pub inline fn set_is_locked(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= LOCKED;
                        } else {
                            self.flags &= ~LOCKED;
                        }
                    }
                    pub inline fn warm_start_enabled(self: *const World) bool {
                        return self.flags & ENABLE_WARM_STARTING == ENABLE_WARM_STARTING;
                    }
                    pub inline fn set_warm_start_enabled(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= ENABLE_WARM_STARTING;
                        } else {
                            self.flags &= ~ENABLE_WARM_STARTING;
                        }
                    }
                    pub inline fn continuous_enabled(self: *const World) bool {
                        return self.flags & ENABLE_CONTINUOUS == ENABLE_CONTINUOUS;
                    }
                    pub inline fn set_continuous_enabled(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= ENABLE_CONTINUOUS;
                        } else {
                            self.flags &= ~ENABLE_CONTINUOUS;
                        }
                    }
                    pub inline fn speculative_enabled(self: *const World) bool {
                        return self.flags & ENABLE_SPECULATIVE == ENABLE_SPECULATIVE;
                    }
                    pub inline fn set_speculative_enabled(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= ENABLE_SPECULATIVE;
                        } else {
                            self.flags &= ~ENABLE_SPECULATIVE;
                        }
                    }
                    pub inline fn in_use(self: *const World) bool {
                        return self.flags & IN_USE == IN_USE;
                    }
                    pub inline fn set_in_use(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= IN_USE;
                        } else {
                            self.flags &= ~IN_USE;
                        }
                    }
                };

                /// Used to create a shape.
                ///
                /// This is a temporary object used to bundle shape creation parameters. You may use
                /// the same shape definition to create multiple shapes.
                pub const ShapeDef = struct {
                    /// User-provided data type for application use
                    user_data: ShapeUserData,
                    /// The Coulomb (dry) friction coefficient, usually in the range [0,1].
                    friction: FracFloat,
                    /// The elasticity (bounce / coefficient of restitution) usually in the range [0,1].
                    ///
                    /// https://en.wikipedia.org/wiki/Coefficient_of_restitution
                    elasticity: FracFloat,
                    /// The rolling resistance usually in the range [0,1].
                    rolling_resistance: FracFloat,
                    /// The speed the surface of the shape is moving at.
                    ///
                    /// This does not physically rotate the shape, but treats
                    /// objects contacting the shape as if the surface is a conveyor belt,
                    /// can be negative for the opposite direction
                    skin_speed: Float,
                    /// User material identifier. This is passed with query results and to friction and elasticity
                    /// combining functions. It is not used internally.
                    material_id: UInt,
                    /// The density, usually in kg/m^2.
                    density: Float,
                    /// Collision filter that determines what other shapes this one interacts with.
                    collision_filter: CollisionFilter,
                    /// Custom debug draw color, if debug is enabled.
                    debug_color: if (DEBUG_ENABLED) DebugColor else void,
                    /// Holds multiple boolean states in a compact format
                    flags: u8,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,

                    pub const IS_SENSOR: u8 = 1 << 0;
                    pub const ENABLE_CONTACT_EVENTS: u8 = 1 << 1;
                    pub const ENABLE_HIT_EVENTS: u8 = 1 << 2;
                    pub const ENABLE_PRE_SOLVE_EVENTS: u8 = 1 << 3;
                    pub const INVOKE_CONTACT_CREATION: u8 = 1 << 4;
                    pub const UPDATE_BODY_MASS: u8 = 1 << 5;

                    pub inline fn is_sensor(self: *const World) bool {
                        return self.flags & IS_SENSOR == IS_SENSOR;
                    }
                    pub inline fn set_is_sensor(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= IS_SENSOR;
                        } else {
                            self.flags &= ~IS_SENSOR;
                        }
                    }
                    pub inline fn contact_events_enabled(self: *const World) bool {
                        return self.flags & ENABLE_CONTACT_EVENTS == ENABLE_CONTACT_EVENTS;
                    }
                    pub inline fn set_contact_events_enabled(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= ENABLE_CONTACT_EVENTS;
                        } else {
                            self.flags &= ~ENABLE_CONTACT_EVENTS;
                        }
                    }
                    pub inline fn hit_events_enabled(self: *const World) bool {
                        return self.flags & ENABLE_HIT_EVENTS == ENABLE_HIT_EVENTS;
                    }
                    pub inline fn set_hit_events_enabled(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= ENABLE_HIT_EVENTS;
                        } else {
                            self.flags &= ~ENABLE_HIT_EVENTS;
                        }
                    }
                    pub inline fn pre_solve_events_enabled(self: *const World) bool {
                        return self.flags & ENABLE_PRE_SOLVE_EVENTS == ENABLE_PRE_SOLVE_EVENTS;
                    }
                    pub inline fn set_pre_solve_events_enabled(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= ENABLE_PRE_SOLVE_EVENTS;
                        } else {
                            self.flags &= ~ENABLE_PRE_SOLVE_EVENTS;
                        }
                    }
                    pub inline fn invokes_contact_creation(self: *const World) bool {
                        return self.flags & INVOKE_CONTACT_CREATION == INVOKE_CONTACT_CREATION;
                    }
                    pub inline fn set_invokes_contact_creation(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= INVOKE_CONTACT_CREATION;
                        } else {
                            self.flags &= ~INVOKE_CONTACT_CREATION;
                        }
                    }
                    pub inline fn automatically_updates_parent_mass(self: *const World) bool {
                        return self.flags & UPDATE_BODY_MASS == UPDATE_BODY_MASS;
                    }
                    pub inline fn set_automatically_updates_parent_mass(self: *World, state: bool) void {
                        if (state) {
                            self.flags |= UPDATE_BODY_MASS;
                        } else {
                            self.flags &= ~UPDATE_BODY_MASS;
                        }
                    }
                };

                /// Used to create a chain of line segments. This is designed to eliminate ghost collisions with some limitations.
                /// - chains are one-sided
                /// - chains have no mass and should be used on static bodies
                /// - chains have a counter-clockwise winding order
                /// - chains are either a loop or open
                /// - a chain must have at least 4 points
                /// - the distance between any two points must be greater than B2_LINEAR_SLOP
                /// - a chain shape should not self intersect (this is not validated)
                /// - an open chain shape has NO COLLISION on the first and final edge
                /// - you may overlap two open chains on their first three and/or last three points to get smooth collision
                /// - a chain shape creates multiple line segment shapes on the body
                ///
                /// https://en.wikipedia.org/wiki/Polygonal_chain
                pub const ChainDef = struct {
                    /// A slice of at least 4 points. These are cloned and may be temporary.
                    points: []Vec2,
                    /// Surface materials for each segment. These are cloned.
                    materials: []SurfaceMaterial,
                    /// Collision filtering data.
                    collision_filter: CollisionFilter,
                    /// Indicates a closed chain formed by connecting the first and last points
                    is_loop: bool,
                    /// custom user-provided data struct
                    user_data: ChainUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// Profiling timing data. Times are in milliseconds.
                pub const TimingStats = struct {
                    step: Float,
                    pairs: Float,
                    collide: Float,
                    solve: Float,
                    merge_islands: Float,
                    prepare_stages: Float,
                    solve_constraints: Float,
                    prepare_constraints: Float,
                    integrate_velocities: Float,
                    warm_start: Float,
                    solve_impulses: Float,
                    integrate_positions: Float,
                    relax_impulses: Float,
                    apply_restitution: Float,
                    store_impulses: Float,
                    transforms: Float,
                    hit_events: Float,
                    refit: Float,
                    bullets: Float,
                    sleep_islands: Float,
                    sensors: Float,
                };

                /// Counters that give details of the simulation size.
                pub const Counters = struct {
                    body_count: UInt,
                    shape_count: UInt,
                    contact_count: UInt,
                    joint_count: UInt,
                    island_count: UInt,
                    stack_used: UInt,
                    static_tree_height: UInt,
                    tree_height: UInt,
                    byte_count: UInt,
                    task_count: UInt,
                    color_counts: [12]UInt,
                };

                /// Distance joint definition
                ///
                /// This requires defining an anchor point on both
                /// bodies and the non-zero distance of the distance joint. The definition uses
                /// local anchor points so that the initial configuration can violate the
                /// constraint slightly. This helps when saving and loading a game.
                pub const DistanceJointDef = struct {
                    /// First attatched body
                    body_id_a: BodyID,
                    /// Second attatched body
                    body_id_b: BodyID,
                    /// Local anchor point relative to body_a's origin
                    local_anchor_a: Vec2,
                    /// Local anchor point relative to body_b's origin
                    local_anchor_b: Vec2,
                    /// The resting length of this joint. Clamped to a stable minimum value
                    length: Float,
                    /// Allow the distance constraint to behave like a spring
                    ///
                    /// If false, the distance joint will be rigid, overriding the limit and motor
                    enable_spring: bool,
                    /// The spring linear stiffness (cycles per second)
                    hertz: Float,
                    /// the spring linear damping ratio in range [0, 1]
                    damping_ratio: FracFloat,
                    /// enable/disable the joint limit
                    enable_limit: bool,
                    /// Minimum length. Clamped to a stable minimum value
                    min_length: Float,
                    /// Maximum length. Must be greater than or equal to the minimum length
                    max_length: Float,
                    /// Enable/disable the joint motor
                    enable_motor: bool,
                    /// The maximum motor force, usually in newtons
                    max_motor_force: Float,
                    /// The desired motor speed, usually in meters per second
                    motor_speed: Float,
                    /// Set this flag to true if the attached bodies should collide
                    collide_connected: bool,
                    /// custom user-provided data struct
                    user_data: DistanceJointUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// A motor joint is used to control the relative motion between two bodies
                ///
                /// A typical usage is to control the movement of a dynamic body with respect to the ground.
                pub const MotorJointDef = struct {
                    /// First attatched body
                    body_id_a: BodyID,
                    /// Second attatched body
                    body_id_b: BodyID,
                    /// Position of bodyB minus the position of bodyA, in bodyA's frame
                    linear_offset: Vec2,
                    /// The bodyB angle minus bodyA angle in radians
                    angular_offset: Float,
                    /// The maximum motor force in newtons
                    max_force: Float,
                    /// The maximum motor torque in newton-meters
                    max_torque: Float,
                    /// Position correction factor in the range [0,1]
                    correction_factor: FracFloat,
                    /// Set this flag to true if the attached bodies should collide
                    collide_connected: bool,
                    /// custom user-provided data struct
                    user_data: MotorJointUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// Revolute joint definition
                ///
                /// This requires defining an anchor point where the bodies are joined.
                /// The definition uses local anchor points so that the
                /// initial configuration can violate the constraint slightly. You also need to
                /// specify the initial relative angle for joint limits. This helps when saving
                /// and loading a game.
                /// The local anchor points are measured from the body's origin
                /// rather than the center of mass because:
                /// 1. you might not know where the center of mass will be
                /// 2. if you add/remove shapes from a body and recompute the mass, the joints will be broken
                pub const RevoluteJointDef = struct {
                    /// The first attached body
                    body_a: BodyID,
                    /// The second attached body
                    body_b: BodyID,
                    /// The local anchor point relative to bodyA's origin
                    local_anchor_a: Vec2,
                    /// The local anchor point relative to bodyB's origin
                    local_anchor_b: Vec2,
                    /// The bodyB angle minus bodyA angle in the reference state (radians).
                    /// This defines the zero angle for the joint limit.
                    reference_angle: Float,
                    /// Enable a rotational spring on the revolute hinge axis
                    enable_spring: bool,
                    /// The spring stiffness Hertz, cycles per second
                    stiffness: Float,
                    /// The spring damping ratio, non-dimensional
                    damping_ratio: FracFloat,
                    /// A flag to enable joint limits
                    enable_limit: bool,
                    /// The lower angle for the joint limit in radians
                    lower_angle: Float,
                    /// The upper angle for the joint limit in radians
                    upper_angle: Float,
                    /// A flag to enable the joint motor
                    enable_motor: bool,
                    /// The maximum motor torque, typically in newton-meters
                    max_motor_torque: Float,
                    /// The desired motor speed in radians per second
                    motor_speed: Float,
                    /// Scale for the debug draw, if enabled
                    debug_draw_size: if (DEBUG_ENABLED) Float else void,
                    /// Set this flag to true if the attached bodies should collide
                    collide_connected: bool,
                    /// custom user-provided data struct
                    user_data: RevoluteJointUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// Weld joint definition
                ///
                /// A weld joint connect to bodies together rigidly. This constraint provides springs to mimic
                /// soft-body simulation.
                pub const WeldJointDef = struct {
                    /// The first attached body
                    body_a: BodyID,
                    /// The second attached body
                    body_b: BodyID,
                    /// The local anchor point relative to bodyA's origin
                    local_anchor_a: Vec2,
                    /// The local anchor point relative to bodyB's origin
                    local_anchor_b: Vec2,
                    /// The bodyB angle minus bodyA angle in the reference state (radians).
                    reference_angle: Float,
                    /// Linear stiffness expressed as Hertz (cycles per second). Use zero for maximum stiffness.
                    linear_stiffness: Float,
                    /// Angular stiffness as Hertz (cycles per second). Use zero for maximum stiffness.
                    angular_stiffness: Float,
                    /// Linear damping ratio, non-dimensional. Use 1 for critical damping.
                    linear_damping_ratio: Float,
                    /// Linear damping ratio, non-dimensional. Use 1 for critical damping.
                    angular_damping_ratio: Float,
                    /// Set this flag to true if the attached bodies should collide
                    collide_connected: bool,
                    /// custom user-provided data struct
                    user_data: WeldJointUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// A mouse joint is used to make a point on a body track a specified world point.
                ///
                /// This a soft constraint and allows the constraint to stretch without
                /// applying huge forces. This also applies rotation constraint heuristic to improve control.
                pub const MouseJointDef = struct {
                    /// The first attached body
                    body_a: BodyID,
                    /// The second attached body
                    body_b: BodyID,
                    /// The initial target point in world space
                    target: Vec2,
                    /// Stiffness in hertz, 0 = max stiffness
                    stiffness: Float,
                    /// Damping ratio, non-dimensional
                    damping_ratio: FracFloat,
                    /// Maximum force, typically in newtons
                    max_force: Float,
                    /// Set this flag to true if the attached bodies should collide.
                    collide_connected: bool,
                    /// custom user-provided data struct
                    user_data: MouseJointUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// A null joint is used to disable collision between two specific bodies.
                pub const NullJointDef = struct {
                    /// The first attached body
                    body_a: BodyID,
                    /// The second attached body
                    body_b: BodyID,
                    /// custom user-provided data struct
                    user_data: NullJointUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// Prismatic joint definition
                ///
                /// This requires defining a line of motion using an axis and an anchor point.
                /// The definition uses local anchor points and a local axis so that the initial
                /// configuration can violate the constraint slightly. The joint translation is zero
                /// when the local anchor points coincide in world space.
                pub const PrismaticJointDef = struct {
                    /// The first attached body
                    body_a: BodyID,
                    /// The second attached body
                    body_b: BodyID,
                    /// The local anchor point relative to bodyA's origin
                    local_anchor_a: Vec2,
                    /// The local anchor point relative to bodyB's origin
                    local_anchor_b: Vec2,
                    /// The local translation unit axis in bodyA
                    local_axis_a: Vec2,
                    /// The constrained angle between the bodies: bodyB angle - bodyA angle
                    reference_angle: Float,
                    /// Enable a linear spring along the prismatic joint axis
                    enable_spring: bool,
                    /// The spring stiffness Hertz, cycles per second, 0 = max
                    stiffness: Float,
                    /// The spring damping ratio, non-dimensional
                    damping_ratio: FracFloat,
                    /// Enable/disable the joint limit
                    enable_limit: bool,
                    /// The lower translation limit (along the specified axis)
                    lower_translation: Float,
                    /// The upper translation limit (along the specified axis)
                    upper_translation: Float,
                    /// Enable/disable the joint motor
                    enable_motor: bool,
                    /// The maximum motor force, typically in newtons
                    max_motor_force: Float,
                    /// The desired motor speed, typically in meters per second
                    motor_speed: Float,
                    /// Set this flag to true if the attached bodies should collide
                    collide_connected: bool,
                    /// custom user-provided data struct
                    user_data: PrismaticJointUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// Wheel joint definition
                ///
                /// This requires defining a line of motion using an axis and an anchor point.
                /// The definition uses local  anchor points and a local axis so that the initial
                /// configuration can violate the constraint slightly. The joint translation is zero
                /// when the local anchor points coincide in world space.
                pub const WheelJointDef = struct {
                    /// The first attached body
                    body_a: BodyID,
                    /// The second attached body
                    body_b: BodyID,
                    /// The local anchor point relative to bodyA's origin
                    local_anchor_a: Vec2,
                    /// The local anchor point relative to bodyB's origin
                    local_anchor_b: Vec2,
                    /// The local translation unit axis in bodyA
                    local_axis_a: Vec2,
                    /// Enable a linear spring along the prismatic joint axis
                    enable_spring: bool,
                    /// The spring stiffness Hertz, cycles per second, 0 = max
                    stiffness: Float,
                    /// The spring damping ratio, non-dimensional
                    damping_ratio: FracFloat,
                    /// Enable/disable the joint limit
                    enable_limit: bool,
                    /// The lower translation limit
                    lower_translation: Float,
                    /// The upper translation limit
                    upper_translation: Float,
                    /// Enable/disable the joint motor
                    enable_motor: bool,
                    /// The maximum motor force, typically in newtons
                    max_motor_force: Float,
                    /// The desired motor speed, typically in meters per second
                    motor_speed: Float,
                    /// Set this flag to true if the attached bodies should collide
                    collide_connected: bool,
                    /// custom user-provided data struct
                    user_data: WheelJointUserData,
                    /// Used internally to detect a valid definition. DO NOT SET.
                    _internal_valid: if (VALIDATION_MODE == .ValidateAndStoreResult) Validation else void,
                };

                /// The explosion definition is used to configure options for explosions. Explosions
                /// consider shape geometry when computing the impulse.
                pub const ExplosionDef = struct {
                    /// Mask to select which collision categories are interacted with
                    filter_mask: CollisionFilterUInt,
                    /// The center of the explosion in world space
                    position: Vec2,
                    /// The radius of the explosion
                    radius: Float,
                    /// The falloff distance beyond the radius. Impulse is reduced to zero at this distance.
                    falloff: Float,
                    /// Impulse per unit length. This applies an impulse according to the shape perimeter that
                    /// is facing the explosion. Explosions only apply to circles, capsules, and polygons. This
                    /// may be negative for implosions.
                    impulse_per_length: Float,
                };

                /// A begin touch event is generated when a shape starts to overlap a sensor shape.
                pub const SensorEventBegin = struct {
                    /// The id of the sensor shape
                    sensor_shape_id: ShapeID,
                    /// The id of the dynamic shape that began touching the sensor shape
                    visitor_shape_id: ShapeID,
                };

                /// An end touch event is generated when a shape stops overlapping a sensor shape.
                ///	These include things like setting the transform, destroying a body or shape, or changing
                ///	a filter. You will also get an end event if the sensor or visitor are destroyed.
                ///	Therefore you should always confirm the shape id is valid using b2Shape_IsValid.
                pub const SensorEventEnd = struct {
                    /// The id of the sensor shape
                    ///
                    /// WARNING: This ShapeID may represent a destroyed shape, you may need to check for validity
                    sensor_shape_id: ShapeID,
                    /// The id of the dynamic shape that stopped touching the sensor shape
                    ///
                    /// WARNING: This ShapeID may represent a destroyed shape, you may need to check for validity
                    visitor_shape_id: ShapeID,
                };

                /// Sensor events are buffered in the Box2D world and are available
                /// as begin/end overlap event slices after the time step is complete.
                /// Note: these may become invalid if bodies and/or shapes are destroyed
                pub const SensorEventList = struct {
                    /// All sensor begin events from this world step
                    begin_events: []SensorEventBegin,
                    /// All sensor end events from this world step
                    end_events: []SensorEventEnd,
                };

                /// A begin touch event is generated when two shapes begin touching.
                pub const ContactTouchBeginEvent = struct {
                    /// Id of the first shape
                    shape_id_a: ShapeID,
                    /// Id of the second shape
                    shape_id_b: ShapeID,
                    /// The initial contact manifold data. This is recorded before the solver is called,
                    /// so all the impulses will be zero.
                    contact_data: ContactData,
                };

                /// An end touch event is generated when two shapes stop touching.
                ///	You will get an end event if you do anything that destroys contacts previous to the last
                ///	world step. These include things like setting the transform, destroying a body
                ///	or shape, or changing a filter or body type.
                pub const ContactTouchEndEvent = struct {
                    /// Id of the first shape
                    ///
                    /// WARNING: This id may correspond to an invalid shape
                    /// if the was destroyed.
                    shape_id_a: ShapeID,
                    /// Id of the second shape
                    ///
                    /// WARNING: This id may correspond to an invalid shape
                    /// if the was destroyed.
                    shape_id_b: ShapeID,
                };

                /// A hit touch event is generated when two shapes collide with a speed faster than the hit speed threshold.
                pub const ContactHitEvent = struct {
                    /// Id of the first shape
                    shape_id_a: ShapeID,
                    /// Id of the second shape
                    shape_id_b: ShapeID,
                    /// Point where the shapes hit
                    point: Vec2,
                    /// Normal vector pointing from shape A to shape B
                    normal: Vec2,
                    /// The speed the shapes are approaching. Always positive. Typically in meters per second.
                    relative_speed: Float,
                };

                /// Contact events are buffered in the Box2D world and are available
                /// as event arrays after the time step is complete.
                ///
                /// NOTE: these may become invalid if bodies and/or shapes are destroyed
                pub const ContactEventList = struct {
                    /// All touch begin events from this world step
                    begin_touch_events: []ContactTouchBeginEvent,
                    /// All touch end events from this world step
                    end_touch_events: []ContactTouchEndEvent,
                    /// All hit events from this world step
                    hit_events: []ContactHitEvent,
                };

                /// Body move events triggered when a body moves.
                /// Triggered when a body moves due to simulation. Not reported for bodies moved by the user.
                /// This also has a flag to indicate that the body went to sleep so the application can also
                /// sleep that actor/entity/object associated with the body.
                ///
                /// On the other hand if the flag does not indicate the body went to sleep then the application
                /// can treat the actor/entity/object associated with the body as awake.
                /// This is an efficient way for an application to update game object transforms rather than
                /// calling functions such as Body.get_transform() because this data is delivered as a contiguous array
                /// and it is only populated with bodies that have moved.
                ///
                /// NOTE: If sleeping is disabled all dynamic and kinematic bodies will trigger move events.
                pub const MoveEvent = struct {
                    /// The final transform of the body after moving this world step
                    transform: Transform,
                    /// The ID of the boy that moved
                    body_id: BodyID,
                    /// The custom user-provided data struct attatched to the body
                    user_data: BodyUserData,
                    /// Whether this body fell asleep this world step
                    fell_asleep: bool,
                };

                /// Body events are buffered by each Zox2D world and are available
                /// as event slices after the time step is complete.
                /// Note: this data becomes invalid if bodies are destroyed
                pub const MoveEventList = struct {
                    /// All move events from this world step
                    move_events: []MoveEvent,
                };

                /// Surface materials allow chain shapes to have per-segment surface properties.
                pub const SurfaceMaterial = struct {
                    /// The Coulomb (dry) friction coefficient, usually in the range [0,1].
                    friction: FracFloat = 0.1,
                    /// The elasticity (bounce / coefficient of restitution) usually in the range [0,1].
                    ///
                    /// https://en.wikipedia.org/wiki/Coefficient_of_restitution
                    elasticity: FracFloat = 0.2,
                    /// The rolling resistance usually in the range [0,1].
                    rolling_resistance: FracFloat = 0.1,
                    /// The speed the surface of the shape is moving at.
                    ///
                    /// This does not physically rotate the shape, but treats
                    /// objects contacting the shape as if the surface is a conveyor belt,
                    /// can be negative for the opposite direction
                    skin_speed: Float = 0.0,
                    /// User material identifier. This is passed with query results and to friction and elasticity
                    /// combining functions. It is not used internally.
                    material_id: ObjectIdUInt,
                    /// Custom debug draw color. if debug is enabled
                    debug_color: if (DEBUG_ENABLED) DebugColor else void,
                };

                pub const Sweep = struct {
                    center_1: Vec2,
                    center_2: Vec2,
                    sin_cos_1: SinCos,
                    sin_cos_2: SinCos,
                    local_center: Vec2,
                };

                pub const Transform = options_2.Transform;

                pub const SinCos = options_2.SinCos;

                pub const Rotation = options_2.Rotation;

                pub const IdPool = struct {
                    free_list: List,
                    next_unused_id: ObjectIdUInt,

                    pub inline fn create() IdPool {
                        return IdPool{ .free_list = List.initCapacity(AllocIDs.*, 1), .next_unused_id = 0 };
                    }

                    pub inline fn destroy(self: *IdPool) IdPool {
                        self.free_list.deinit(AllocIDs.*);
                        self.next_unused_id = 0;
                    }

                    pub fn claim_id(self: *IdPool) ObjectIdUInt {
                        if (self.free_list.len > 0) {
                            return self.free_list.pop();
                        }
                        const new_id = self.next_unused_id;
                        self.next_unused_id += 1;
                        return new_id;
                    }

                    pub fn free_id(self: *IdPool, id: ObjectIdUInt) void {
                        assert.greater_than("self.next_unused_index", self.next_unused_id, "0", 0, "cannot free an index before any indexes have been handed out");
                        assert.less_than("idx", id, "self.next_unused_index", self.next_unused_id, "cannot free an index greater than or equal to the 'next_unused_index'");
                        if (id == self.next_unused_id) {
                            self.next_unused_id -= 1;
                        } else {
                            self.free_list.append(AllocIDs.*, id);
                        }
                    }

                    pub fn validate_free_id(self: *IdPool, id: ObjectIdUInt) void {
                        if (VALIDATE_FREE_IDS) {
                            var i: usize = 0;
                            while (i < self.free_list.len) : (i += 1) {
                                if (self.free_list.items[i] == id) return;
                            }
                            assert.is_unreachable("id was not found in free id list");
                        }
                    }

                    pub inline fn get_used_id_count(self: *const IdPool) ObjectIdUInt {
                        return self.next_unused_id - self.free_list.items.len;
                    }

                    pub inline fn get_id_capacity(self: *const IdPool) ObjectIdUInt {
                        return self.next_unused_id;
                    }

                    pub inline fn get_allocated_bytes(self: *const IdPool) usize {
                        return @sizeOf(ObjectIdUInt) * self.free_list.capacity;
                    }
                    const List = ListUnmanaged(ObjectIdUInt);
                };

                pub fn define_object_pool(comptime T: type, comptime allocator: *Allocator) type {
                    return struct {
                        const Self = @This();

                        object_pool: List,
                        id_pool: IdPool,

                        pub inline fn create() Self {
                            return Self{
                                .object_pool = List.initCapacity(allocator.*, 1),
                                .id_pool = IdPool.create(),
                            };
                        }

                        pub inline fn destroy(self: *Self) void {
                            self.object_pool.deinit(allocator.*);
                            self.id_pool.destroy();
                        }

                        pub inline fn claim_id(self: *Self) ObjectIdUInt {
                            return self.id_pool.claim_id();
                        }

                        pub inline fn free_id(self: *Self, id: ObjectIdUInt) void {
                            self.id_pool.free_id(id);
                        }

                        pub inline fn validate_free_id(self: *Self, id: ObjectIdUInt) void {
                            self.id_pool.validate_free_id(id);
                        }

                        pub inline fn get_used_id_count(self: *const Self) ObjectIdUInt {
                            return self.id_pool.get_used_id_count();
                        }

                        pub inline fn get_id_capacity(self: *const Self) ObjectIdUInt {
                            return self.id_pool.get_id_capacity();
                        }

                        pub inline fn get_id_allocated_bytes(self: *const Self) usize {
                            return self.id_pool.get_allocated_bytes();
                        }
                        const List = ListUnmanaged(T);
                    };
                }
            };
        }
    };
}

pub const VectorOrientation = enum(u8) {
    Colinear = 0,
    WindingClockwise = 1,
    WindingCounterClockwise = 2,
};

pub const AllocatorSize = enum(u8) {
    Large = 0,
    Medium = 1,
    Small = 2,
    Micro = 3,
};

pub const BodyType = enum(u8) {
    Static = 0,
    Kinematic = 1,
    Dynamic = 2,
};

pub const SetType = enum(u8) {
    StaticSet = 0,
    DisabledSet = 1,
    AwakeSet = 2,
    FirstSleepingSet = 3,
};

/// Describes How to mix two properties together
///
/// The options are as follows listed in mathematic order where the higher optons ALWAYS evaluate to a value >= the options below them
///   - Max = @max(a, b)
///   - QuadraticAverage = @sqrt(((a * a) + (b * b)) / 2)
///   - ArithmeticAverage = (a + b) / 2
///   - GeomtricAverage = @sqrt(a * b)
///   - HarmonicAverage = (2 * a * b) / (a + b)
///   - Min = @min(a, b)
pub const PropertyMixingFormulaTag = enum(u8) {
    /// @min(a, b)
    Min = 0,
    /// (2 * a * b) / (a + b)
    HarmonicAverage = 1,
    /// @sqrt(a * b)
    GeomtricAverage = 2,
    /// (a + b) / 2
    ArithmeticAverage = 3,
    /// @sqrt(((a * a) + (b * b)) / 2)
    QuadraticAverage = 4,
    /// @max(a, b)
    Max = 5,
    /// Provide your own mixing function
    Custom = 6,
};

pub const ShapeType = enum(u8) {
    Circle = 0,
    Capsule = 1,
    Segment = 2,
    Polygon = 3,
    ChainSegment = 4,
};

pub const JointType = enum(u8) {
    Distance = 0,
    Motor = 1,
    Mouse = 2,
    Null = 3,
    Prismatic = 4,
    Revolute = 5,
    Weld = 6,
    Wheel = 7,
};

const Validation = enum(u8) {
    Unchecked = 0,
    Valid = 1,
    Invalid = 2,
};

const ValidationMode = enum(u8) {
    DoNotValidate = 0,
    ValidateButDoNotStoreResult = 1,
    ValidateAndStoreResult = 2,
};
