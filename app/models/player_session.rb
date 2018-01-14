require 'codebreaker'

class PlayerSession

  attr_accessor :name, :tries, :game

  def initialize(name = nil)
    @name = name
    @tries = []
    @game = Codebreaker::Game.new
  end

  def answer
    self.game.get_answer.map do |digit| 
      digit = digit ? digit : '*'
    end.join
  end

  def current_progress
    self.game.progress.map(&:to_s).join
  end

  def add_hint
    self.game.add_hint
  end

  def can_try()
    self.game.can_try
  end

  def try(guess_code)
    self.game.try(guess_code)
  end

  def win?
    self.game.is_win
  end

  def try_number
    self.game.try_number
  end

  def hint_count
    self.game.hint_count
  end

  def secret_number
    self.game.secret_number.join
  end

end