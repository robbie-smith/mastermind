require_relative "guesser"
require_relative "timer"
require_relative "code_generator"
require_relative "responses"
require_relative "validate"

class Command
  include CodeGenerator
  include Responses

  attr_reader :guess, :timer, :won
  attr_accessor :input

  def initialize(override_code = nil)
    code = override_code || CodeGenerator.generate
    @guess = Guesser.new(code)
    @timer = Timer.new
    @validate = Validator.new
    @won = false
    @previous_input = []
  end

  def check_input
    @previous_input << input
    guess.user_input = input
    @validate.check_start(guess.user_input,guess.code)
    start
  end

  def start
    # binding.pry
    check_input unless @previous_input.include?(input)
    if guess.correct_code.eql?(false) && @validate.valid.eql?(true)
      time_start
      guess.start
      print_guess
    elsif guess.correct_code.eql?(true)
      game_over
    end
  end

  def game_over
    if guess.correct_code.eql?(true)
      elapsed_time = @timer.elapsed_time
      counter = @guess.counter
      Responses.game_end(input,counter,elapsed_time)
    end
  end

  def print_guess
      Responses.guess_element_response(guess.user_input,guess.element_holder[:element],guess.element_holder[:position],guess.counter)
  end

  def time_start
    if timer.start_game.eql?(false)
      timer.start_game = true
      timer.time_convert
    end
  end

  def time_end
    if timer.start_game.eql?(true)
      timer.time = Time.new
      timer.end_game = true
      timer.time_convert
    end
  end

end
