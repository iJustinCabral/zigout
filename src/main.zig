const rl = @import("raylib");
const std = @import("std");
const rand = std.rand;
const math = std.math;
const Vector2 = rl.Vector2;

const SIZE = Vector2.init(620 * 2, 480 * 2);
const PADDING = 5.0;
const SPEED_INCREMENT = 0.2;

const Paddle = struct {
    position: Vector2,
    size: Vector2,
    speed: f32,
};

const Ball = struct {
    position: Vector2,
    radius: f32,
    speed: Vector2,
};

const Brick = struct {
    position: Vector2,
    size: Vector2,
    isActive: bool,
    color: rl.Color,
};

const brick_colors = [_]rl.Color{
    rl.Color.red,
    rl.Color.blue,
    rl.Color.green,
    rl.Color.yellow,
    rl.Color.purple,
    rl.Color.orange,
};

pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------

    rl.initWindow(SIZE.x, SIZE.y, "zigout");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

    const paddleHitSound = rl.loadSound("resources/paddle_hit.wav");
    defer rl.unloadSound(paddleHitSound);

    const brickHitSound = rl.loadSound("resources/brick_hit.wav");
    defer rl.unloadSound(brickHitSound);

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var paddle = Paddle{
        .position = Vector2.init(SIZE.x / 2 - 50, SIZE.y - 30),
        .size = Vector2.init(100, 20),
        .speed = 15.0,
    };

    var ball = Ball{
        .position = Vector2.init(SIZE.x / 2, SIZE.y / 2),
        .radius = 10.0,
        .speed = Vector2.init(4.0, 4.0),
    };

    const rows = 5;
    const cols = 10;
    const totalPadding = PADDING * (cols - 1);
    const brickWidth = (SIZE.x - totalPadding) / cols;
    const brickHeight = 20.0;
    const brickSize = Vector2.init(brickWidth, brickHeight);
    const bricks = try createBricks(&allocator, rows, cols, brickSize);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        updatePaddle(&paddle);
        updateBall(&ball, paddle, bricks, paddleHitSound, brickHitSound);

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        drawPaddle(paddle);
        drawBall(ball);
        drawBricks(bricks);
    }
}

// MARK: Updates
fn updatePaddle(paddle: *Paddle) void {
    if (rl.isKeyDown(.key_left)) {
        paddle.position.x -= paddle.speed;
    }

    if (rl.isKeyDown(.key_right)) {
        paddle.position.x += paddle.speed;
    }

    // Clamp paddle position
    paddle.position.x = math.clamp(paddle.position.x, 0, SIZE.x - paddle.size.x);
}

fn updateBall(ball: *Ball, paddle: Paddle, bricks: []Brick, paddleSound: rl.Sound, brickSound: rl.Sound) void {
    ball.position = Vector2{
        .x = ball.position.x + ball.speed.x,
        .y = ball.position.y + ball.speed.y,
    };

    // Bounce off screen edges
    if (ball.position.x - ball.radius < 0) {
        ball.speed.x = -ball.speed.x;
        ball.position.x = ball.radius;
    } else if (ball.position.x + ball.radius > SIZE.x) {
        ball.speed.x = -ball.speed.x;
        ball.position.x = SIZE.x - ball.radius;
    }

    if (ball.position.y - ball.radius < 0) {
        ball.speed.y = -ball.speed.y;
        ball.position.y = ball.radius;
    } else if (ball.position.y + ball.radius > SIZE.y) {
        ball.speed.y = -ball.speed.y;
        ball.position.y = SIZE.y - ball.radius;
    }
    // Check collision with paddle
    if (isCollision(ball.*, paddle)) {
        ball.speed.y = -ball.speed.y;

        // Adjusting horizontal speed based on where the ball hits the paddle
        const paddleCenter = paddle.position.x + paddle.size.x / 2;
        const distanceFromCenter = ball.position.x - paddleCenter;
        ball.speed.x = distanceFromCenter * 0.1; // Can adjust this multiplier to fine tune

        rl.playSound(paddleSound);
    }

    for (bricks) |*brick| {
        if (brick.isActive and isCollision(ball.*, brick)) {
            brick.isActive = false;
            ball.speed.y = -ball.speed.y + SPEED_INCREMENT;
            rl.playSound(brickSound);
            break; // only one collision per frame
        }
    }
}

// Create Bricks
fn createBricks(allocator: *const std.mem.Allocator, rows: u32, cols: u32, brickSize: Vector2) ![]Brick {
    const bricks = try allocator.alloc(Brick, rows * cols);
    var prng = rand.DefaultPrng.init(42);
    const index = prng.random();

    for (0..rows) |row| {
        for (0..cols) |col| {
            bricks[row * cols + col] = Brick{
                .position = Vector2{ .x = @as(f32, @floatFromInt(col)) * (brickSize.x + PADDING), .y = @as(f32, @floatFromInt(row)) * (brickSize.y + PADDING) },
                .size = brickSize,
                .isActive = true,
                .color = brick_colors[index.intRangeAtMost(usize, 0, 5)],
            };
        }
    }
    return bricks;
}

// MARK: Drawing
fn drawPaddle(paddle: Paddle) void {
    rl.drawRectangleV(paddle.position, paddle.size, rl.Color.blue);
}

fn drawBall(ball: Ball) void {
    rl.drawCircleV(ball.position, ball.radius, rl.Color.red);
}

fn drawBricks(bricks: []Brick) void {
    for (bricks) |brick| {
        if (brick.isActive) {
            rl.drawRectangleV(brick.position, brick.size, brick.color);
        }
    }
}

// Collision Detection
fn isCollision(ball: Ball, rect: anytype) bool {
    const ballLeft = ball.position.x - ball.radius;
    const ballRight = ball.position.x + ball.radius;
    const ballTop = ball.position.y - ball.radius;
    const ballBottom = ball.position.y + ball.radius;

    const rectLeft = rect.position.x;
    const rectRight = rect.position.x + rect.size.x;
    const rectTop = rect.position.y;
    const rectBottom = rect.position.y + rect.size.y;

    return ballRight > rectLeft and ballLeft < rectRight and ballBottom > rectTop and ballTop < rectBottom;
}
