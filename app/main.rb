# def defaults(args)
#   args.state.bg ||= { x: 0, y: 0, w:args.grid.w, h: args.grid.h, r: 56, g: 23, b: 30 }
#   args.state.center_bar ||= { x: args.grid.w / 2 - 5, y: 0, w: 10, h: args.grid.h, r: 57, g: 209, b: 20}
#   args.state.l_score ||= { x: args.grid.w / 4, y: args.grid.h * 0.9. text: '0', size_enum: 20,
#                             font: 'AdventurerDemoRegular.ttf', r: 57, g: 209, b: 239 }
#   args.state.r_score ||= { x: args.grid.w * 0.75, y: args.grid.h * 0.9, text: '0', size_enum: 20,
#                             font: 'AdventurerDemoRegular.ttf', r: 57, g: 209, b: 239 }

#   args.state.l_paddle ||= { x: args.grid.w * 0.05 - 10, y: args.grid.h / 2 - 75, w: 20, h: 150, r: 53, g: 209, b: 48 }
#   args.state.r_paddle ||= { x: args.grid.w * 0.95 - 10, y: args.grid.h / 2 - 75, w: 20, h: 234, r: 53, g: 181, b: 65 }

#   args.state.ball ||= { x: args.grid.w / 2 - 15, y: args.grid.h / 2 - 15, w: 30, h: 30, r: 16, g: 80, b: 229 }

#   args.state.solids ||= [ args.state.bg, args.state.center_bar, args.state.l_paddle, args.state.r_paddle, 
#                           args.state.ball ]

# end

# def render(args)
#   args.outputs.solids << args.state.solids
#   args.outputs.labels << [args.state.l_score, args.state.r_score]
# end

# def tick(args)
#   defaults args
#   render args
# end

# $gtk.reset





# def tick args
#   args.outputs.labels  << [640, 540, 'Hello World!', 5, 1]
#   args.outputs.labels  << [640, 500, 'Docs located at ./docs/docs.html and 100+ samples located under ./samples', 5, 1]
#   args.outputs.labels  << [640, 460, 'Join the Discord server! https://discord.dragonruby.org', 5, 1]

#   args.outputs.sprites << { x: 576,
#                             y: 280,
#                             w: 128,
#                             h: 101,
#                             path: 'dragonruby.png',
#                             angle: args.state.tick_count }

#   args.outputs.labels  << { x: 640,
#                             y: 60,
#                             text: './mygame/app/main.rb',
#                             size_enum: 5,
#                             alignment_enum: 1 }
# end

def tick args
  defaults args
  render args
  calc args
  input args
end

def defaults args
  args.state.ball.debounce       ||= 3 * 60
  args.state.ball.size           ||= 10
  args.state.ball.size_half      ||= args.state.ball.size / 2
  args.state.ball.x              ||= 640
  args.state.ball.y              ||= 360
  args.state.ball.dx             ||= 5.randomize(:sign)
  args.state.ball.dy             ||= 5.randomize(:sign)
  args.state.left_paddle.y       ||= 360
  args.state.right_paddle.y      ||= 360
  args.state.paddle.h            ||= 120
  args.state.paddle.w            ||= 10
  args.state.left_paddle.score   ||= 0
  args.state.right_paddle.score  ||= 0
end

def render args
  render_center_line args
  render_scores args
  render_countdown args
  render_ball args
  render_paddles args
  render_instructions args
end

begin :render_methods
  def render_center_line args
    args.outputs.lines  << [640, 0, 640, 720]
  end

  def render_scores args
    args.outputs.labels << [
      [320, 650, args.state.left_paddle.score, 10, 1],
      [960, 650, args.state.right_paddle.score, 10, 1]
    ]
  end

  def render_countdown args
    return unless args.state.ball.debounce > 0
    args.outputs.labels << [640, 360, "%.2f" % args.state.ball.debounce.fdiv(60), 10, 1]
  end

  def render_ball args
    args.outputs.solids << solid_ball(args)
  end

  def render_paddles args
    args.outputs.solids << solid_left_paddle(args)
    args.outputs.solids << solid_right_paddle(args)
  end

  def render_instructions args
    args.outputs.labels << [320, 30, "W and S keys to move left paddle.",  0, 1]
    args.outputs.labels << [920, 30, "O and L keys to move right paddle.", 0, 1]
  end
end

def calc args
  args.state.ball.debounce -= 1 and return if args.state.ball.debounce > 0
  calc_move_ball args
  calc_collision_with_left_paddle args
  calc_collision_with_right_paddle args
  calc_collision_with_walls args
end

begin :calc_methods
  def calc_move_ball args
    args.state.ball.x += args.state.ball.dx
    args.state.ball.y += args.state.ball.dy
  end

  def calc_collision_with_left_paddle args
    if solid_left_paddle(args).intersect_rect? solid_ball(args)
      args.state.ball.dx *= -1
    elsif args.state.ball.x < 0
      args.state.right_paddle.score += 1
      calc_reset_round args
    end
  end

  def calc_collision_with_right_paddle args
    if solid_right_paddle(args).intersect_rect? solid_ball(args)
      args.state.ball.dx *= -1
    elsif args.state.ball.x > 1280
      args.state.left_paddle.score += 1
      calc_reset_round args
    end
  end

  def calc_collision_with_walls args
    if args.state.ball.y + args.state.ball.size_half > 720
      args.state.ball.y = 720 - args.state.ball.size_half
      args.state.ball.dy *= -1
    elsif args.state.ball.y - args.state.ball.size_half < 0
      args.state.ball.y = args.state.ball.size_half
      args.state.ball.dy *= -1
    end
  end

  def calc_reset_round args
    args.state.ball.x = 640
    args.state.ball.y = 360
    args.state.ball.dx = 5.randomize(:sign)
    args.state.ball.dy = 5.randomize(:sign)
    args.state.ball.debounce = 3 * 60
  end
end

def input args
  input_left_paddle args
  input_right_paddle args
end

begin :input_methods
  def input_left_paddle args
    if args.inputs.controller_one.key_held.down  || args.inputs.keyboard.key_held.s
      args.state.left_paddle.y -= 10
    elsif args.inputs.controller_one.key_down.up || args.inputs.keyboard.key_held.w
      args.state.left_paddle.y += 10
    end
  end
  def input_right_paddle args
    if args.inputs.controller_two.key_down.down  || args.inputs.keyboard.key_held.l
      args.state.right_paddle.y -= 10
    elsif args.inputs.controller_two.key_down.up || args.inputs.keyboard.key_held.o
      args.state.right_paddle.y += 10
    end
  end
end

begin :assets
  def solid_ball args
    centered_rect args.state.ball.x, args.state.ball.y, args.state.ball.size, args.state.ball.size
  end

  def solid_left_paddle args
    centered_rect_vertically 0, args.state.left_paddle.y, args.state.paddle.w, args.state.paddle.h
  end

  def solid_right_paddle args
    centered_rect_vertically 1280 - args.state.paddle.w, args.state.right_paddle.y, args.state.paddle.w, args.state.paddle.h
  end

  def centered_rect x, y, w, h
    [x - w / 2, y - h / 2, w, h]
  end

  def centered_rect_vertically x, y, w, h
    [x, y - h / 2, w, h]
  end
end