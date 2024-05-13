# Imports
require 'rubygems'
require 'gosu'

# Module defining drawing order for game elements
module ZOrder
  Background = 0
  Boards = 1
  Person = 2
  UI = 4
end

## GAME WINDOW
class GameWindow < Gosu::Window
  def initialize
    # Initialize everything
    $time = 0
    @minutes = 0
    super(640,480, false)
    self.caption = "Board Breaker"
    @ButtonPress = false
    @ButtonPressTime = 0
    # Load images and sounds
    @background_image = Gosu::Image.new("media/background.png")
    @instructions_image = Gosu::Image.new("media/instructions.png")
    @music = Gosu::Sample.new("media/kungfu.mp3")
    @music.play(volume = 0.03, speed = 1, looping = true)
    # Create player objects and set positions
    @tkd_person_1 = Player.new
    @tkd_person_2 = Player.new
    @tkd_person_1.warp(530, 380)
    @tkd_person_2.warp(100, 100)
    # Load animation tiles for boards
    @board_animation = Gosu::Image::load_tiles("media/board.png", 25, 25)
    # Create arrays for storing boards and persons
    @boards = Array.new
    @person = Array.new
    @font = Gosu::Font.new(20)
  end
  
  ## PLAYER CONTROLS
  def update
    $time += 1
    # Let player one use arrow keys
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft
      @tkd_person_1.turn_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight
      @tkd_person_1.turn_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0
      @tkd_person_1.accelerate
    end
    if Gosu::button_down? Gosu::KbDown or Gosu::button_down? Gosu::GpButton0
      @tkd_person_1.deaccelerate
    end
    # Let player two use WASD
    if Gosu::button_down? Gosu::KbA or Gosu::button_down? Gosu::GpLeft
      @tkd_person_2.turn_left
    end
    if Gosu::button_down? Gosu::KbD or Gosu::button_down? Gosu::GpRight
      @tkd_person_2.turn_right
    end
    if Gosu::button_down? Gosu::KbW or Gosu::button_down? Gosu::GpButton0
      @tkd_person_2.accelerate
    end
    if Gosu::button_down? Gosu::KbS or Gosu::button_down? Gosu::GpButton0
      @tkd_person_2.deaccelerate
    end
    # Move players and handle board collection
    @tkd_person_1.move
    @tkd_person_2.move
    @tkd_person_1.collect_boards(@boards)
    @tkd_person_2.collect_boards(@boards)
    # Generate new boards 7% of time and if there are less than 25 on screen
    if rand(100) < 7 and @boards.size < 25
      @boards.push(Board.new(@board_animation))
    end
  end

  # ANIMATIONS
  def draw
    # Draw background image
    @background_image.draw(0, 0, ZOrder::Background)
    @seconds = ($time-@ButtonPressTime)/60
    @minutes = Time.at(@seconds).utc.strftime("%M:%S")
    if @minutes == "00:00"
      @boards.clear
    end
    # Before one minute
    if @minutes < "01:00"
      # Animate players and draw boards
      @tkd_person_1.animate
      @tkd_person_2.animate
      @boards.each{ |board| board.draw}
      # Draw each player's score and the time with a shadow
      @font.draw("Time: #{@minutes}", 266, 16, ZOrder::UI, 1.0, 1.0, 0xff_000000)
      @font.draw("Time: #{@minutes}", 265, 15, ZOrder::UI, 1.0, 1.0, 0xff_00d900)
      @font.draw("Player 1 Score: #{@tkd_person_1.score}", 91, 16, ZOrder::UI, 1.0, 1.0, 0xff_000000)
      @font.draw("Player 2 Score: #{@tkd_person_2.score}", 401, 16, ZOrder::UI, 1.0, 1.0, 0xff_000000)
      @font.draw("Player 1 Score: #{@tkd_person_1.score}", 90, 15, ZOrder::UI, 1.0, 1.0, 0xff_1259ff)
      @font.draw("Player 2 Score: #{@tkd_person_2.score}", 400, 15, ZOrder::UI, 1.0, 1.0, 0xff_ff0000)
    end
    # After one minute
    if @minutes >= "01:00"
      # Handle end game conditions and draw messages of winner
      if @tkd_person_1.score == @tkd_person_2.score
        @font.draw("TIE!!!", 301, 211, ZOrder::UI, 1.0, 1.0, 0xff_000000)
        @font.draw("TIE!!!", 300, 210, ZOrder::UI, 1.0, 1.0, 0xff_d900ff)
      end
      if @tkd_person_1.score > @tkd_person_2.score
        @font.draw("PLAYER 1 WON!!!", 249, 211, ZOrder::UI, 1.0, 1.0, 0xff_000000)
        @font.draw("PLAYER 1 WON!!!", 248, 210, ZOrder::UI, 1.0, 1.0, 0xff_1259ff)
      end
      if @tkd_person_2.score > @tkd_person_1.score
        @font.draw("PLAYER 2 WON!!!", 249, 211, ZOrder::UI, 1.0, 1.0, 0xff_000000)
        @font.draw("PLAYER 2 WON!!!", 248, 210, ZOrder::UI, 1.0, 1.0, 0xff_ff0000)
      end
    # Draw end game instructions
    @font.draw("Press escape to quit.", 241, 236, ZOrder::UI, 1.0, 1.0, 0xff_000000)
    @font.draw("Press space to play again.", 222, 261, ZOrder::UI, 1.0, 1.0, 0xff_000000)
    @font.draw("Press escape to quit.", 240, 235, ZOrder::UI, 1.0, 1.0, 0xff_00d900)
    @font.draw("Press space to play again.", 221, 260, ZOrder::UI, 1.0, 1.0, 0xff_00d900)
    @boards.clear
    end
    # Draw instructions image if button not pressed
    if @ButtonPress == false
      @instructions_image.draw(0,0, 10)
    end
  end

  # KEY PRESSES
  def button_down(id)
    # Record time of button press if it hasn't occurred yet
    if @ButtonPress == false
      @ButtonPressTime = $time
    end
    @ButtonPress = true
    # Calculate elapsed time in seconds since button press
    @seconds = ($time-@ButtonPressTime)/60
    @minutes = Time.at(@seconds).utc.strftime("%M:%S")
    if @minutes > "01:00"
      # Close the game if 'Escape' is pressed
      if id == Gosu::KbEscape
          close
      end
      # Otherwise reset the game if 'Space' is pressed
      if id == Gosu::KbSpace
        @ButtonPressTime = $time
        @tkd_person_1.clear_score
        @tkd_person_2.clear_score
        @tkd_person_1.warp(530, 380)
        @tkd_person_2.warp(100, 100)
        @tkd_person_1.clearangle
        @tkd_person_2.clearangle
      end
    end
  end
end

## PLAYER CLASS
class Player
  # Initialize player attributes
  def initialize
    @image = Gosu::Image.new("media/taekwondo.bmp")
    @animation = Gosu::Image::load_tiles("media/taekwondo.png", 50, 64)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end
  # Set player position
  def warp(x, y)
    @x, @y = x, y
  end
  # Rotate the player left or right
  def turn_left
    @angle -= 4.5
  end
  def turn_right
    @angle += 4.5
  end
  def clearangle
    @angle = 0
  end
  # Accelerate or decelerate player in current direction
  def accelerate
    @vel_x = Gosu::offset_x(@angle,3)
    @vel_y = Gosu::offset_y(@angle, 3)
  end
  def deaccelerate
    @vel_x = Gosu::offset_x(@angle, -3)
    @vel_y = Gosu::offset_y(@angle, -3)
  end
  # Move player based on velocity
  def move
    @x += @vel_x
    @y += @vel_y
    # Wrap player around screen
    @x %= 640
    @y %= 480
    @vel_x *= 0.95
    @vel_y *= 0.95
  end
  # Draw player image and animation frames rotated according to angle
  def draw
    @image.draw_rot(@x, @y, 1, @angle)
  end
  def animate
    img = @animation[Gosu::milliseconds / 100 % @animation.size]
    img.draw_rot(@x, @y, 1, @angle)
  end
  def score
    @score
  end
  def clear_score
    @score = 0
  end
  # Check for collision with boards and update score
  def collect_boards(boards)
    if boards.reject! {|board| Gosu::distance(@x, @y, board.x, board.y) < 35 }
      # Increment score if player collides with a board
      @score += 1
    end
  end
end

## BOARD CLASS
class Board
  attr_reader :x, :y

  def initialize(animation)
    # Initialize board attributes
    @animation = animation
    @color = Gosu::Color.argb(0xff_00ff00)
    # Randomize initial position within screen bounds
    @x = ( rand * 570 ) + 35
    @y = ( rand * 410 ) + 35
  end

  # Draw board
  def draw
    img = @animation[1 / 100 % @animation.size]
    img.draw_rot(@x,@y,2, 90)
  end
end

# Create game window
window = GameWindow.new

# Start the game loop
window.show
