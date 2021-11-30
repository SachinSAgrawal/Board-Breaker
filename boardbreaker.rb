# imports
require 'rubygems'
require 'gosu'

module ZOrder
  Background = 0
  Boards = 1
  Person = 2
  UI = 4
end

class GameWindow < Gosu::Window
  # set everything up
  def initialize
    $time = 0
    @minutes = 0
    super(640,480, false)
    self.caption = "Board Breaker"
    @ButtonPress = false
    @ButtonPressTime = 0
    @background_image = Gosu::Image.new("media/TKD_Background.png")
    @instructions_image = Gosu::Image.new("media/Instructions.png")
    @music = Gosu::Sample.new("media/kungfu.mp3")
    @music.play(volume = 0.03, speed = 1, looping = true)
    @tkd_person_1 = Player.new
    @tkd_person_2 = Player.new
    @tkd_person_1.warp(530, 380)
    @tkd_person_2.warp(100, 100)
    @board_animation = Gosu::Image::load_tiles("media/board.png", 25, 25)
    @boards = Array.new
    @person = Array.new
    @font = Gosu::Font.new(20)
  end
  # player 1 and 2 controls
  def update
    $time += 1
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
    @tkd_person_1.move
    @tkd_person_2.move
    @tkd_person_1.collect_boards(@boards)
    @tkd_person_2.collect_boards(@boards)
    # spawn boards 7% of time and if less than 25 on screen
    if rand(100) < 7 and @boards.size < 25
      @boards.push(Board.new(@board_animation))
    end
  end
  # main animations
  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @seconds = ($time-@ButtonPressTime)/60
    @minutes = Time.at(@seconds).utc.strftime("%M:%S")
    if @minutes == "00:00"
      @boards.clear
    end
    # before one minute
    if @minutes < "01:00"
      @tkd_person_1.animate
      @tkd_person_2.animate
      @boards.each{ |board| board.draw}
      @font.draw("Time: #{@minutes}", 266, 16, ZOrder::UI, 1.0, 1.0, 0xff_000000)
      @font.draw("Time: #{@minutes}", 265, 15, ZOrder::UI, 1.0, 1.0, 0xff_00d900)
      @font.draw("Player 1 Score: #{@tkd_person_1.score}", 91, 16, ZOrder::UI, 1.0, 1.0, 0xff_000000)
      @font.draw("Player 2 Score: #{@tkd_person_2.score}", 401, 16, ZOrder::UI, 1.0, 1.0, 0xff_000000)
      @font.draw("Player 1 Score: #{@tkd_person_1.score}", 90, 15, ZOrder::UI, 1.0, 1.0, 0xff_1259ff)
      @font.draw("Player 2 Score: #{@tkd_person_2.score}", 400, 15, ZOrder::UI, 1.0, 1.0, 0xff_ff0000)
    end
    # after one minute
    if @minutes >= "01:00"
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
    @font.draw("Press escape to quit.", 241, 236, ZOrder::UI, 1.0, 1.0, 0xff_000000)
    @font.draw("Press space to play again.", 222, 261, ZOrder::UI, 1.0, 1.0, 0xff_000000)
    @font.draw("Press escape to quit.", 240, 235, ZOrder::UI, 1.0, 1.0, 0xff_00d900)
    @font.draw("Press space to play again.", 221, 260, ZOrder::UI, 1.0, 1.0, 0xff_00d900)
    @boards.clear
    end
    if @ButtonPress == false
      @instructions_image.draw(0,0, 10)
    end
  end
  # button presses
  def button_down(id)
    if @ButtonPress == false
      @ButtonPressTime = $time
    end
    @ButtonPress = true
    @seconds = ($time-@ButtonPressTime)/60
    @minutes = Time.at(@seconds).utc.strftime("%M:%S")
    if @minutes > "01:00"
      if id == Gosu::KbEscape
          close
      end
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

# update player movements
class Player
  def initialize
    @image = Gosu::Image.new("media/tkd_image.bmp")
    @animation = Gosu::Image::load_tiles("media/TAEKWONDO_GUY.png", 50, 64)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @score = 0
  end
  def warp(x, y)
    @x, @y = x, y
  end
  def turn_left
    @angle -= 4.5
  end
  def turn_right
    @angle += 4.5
  end
  def clearangle
    @angle = 0
  end
  def accelerate
    @vel_x = Gosu::offset_x(@angle,3)
    @vel_y = Gosu::offset_y(@angle, 3)
  end
  def deaccelerate
    @vel_x = Gosu::offset_x(@angle, -3)
    @vel_y = Gosu::offset_y(@angle, -3)
  end
  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480
    @vel_x *= 0.95
    @vel_y *= 0.95
  end
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
  def collect_boards(boards)
    if boards.reject! {|board| Gosu::distance(@x, @y, board.x, board.y) < 35 }
      @score += 1
    end
  end
end

# other stuff
class Board
  attr_reader :x, :y

  def initialize(animation)
    @animation = animation
    @color = Gosu::Color.argb(0xff_00ff00)
    @x = ( rand * 570 ) + 35
    @y = ( rand * 410 ) + 35
  end

  def draw
    img = @animation[1 / 100 % @animation.size]
    img.draw_rot(@x,@y,2, 90)
  end
end

window = GameWindow.new
window.show
