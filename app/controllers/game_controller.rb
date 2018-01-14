require_relative './base_controller.rb'

class GameController < BaseController
  
  aspector do
    around :new, :result, :statistics, :redirect_if_guest
  end

  attr_accessor :player_session

  def index
    redirect_to('/game/new')
  end

  def new
    if params['hint']
      @request.session[:player].add_hint

      return redirect_to('/game/new') 
    elsif params['guess_code']
      return redirect_to('/game/' + (make_try ? 'new' : 'result')) 
    end

    build_response render_template
  end

  def result
    @player = @request.session[:player]

    destroy_session
    save_player_result_to_storage(@player)
    build_response render_template
  end

  def statistics
    return redirect_default if !is_admin

    @storage_players = PlayerStorage.new.get_players

    build_response render_template
  end

  private

  def save_player_result_to_storage(player)
    PlayerStorage.new.add_player(
      Player.new(
        player.name,
        player.try_number,
        player.hint_count,
        player.secret_number,
        player.win?
      )
    )
  end

  def make_try
    @request.session[:player].try(params['guess_code'])

    if @request.session[:player].can_try && !@request.session[:player].win?
      @request.session[:player].tries.push({
        code: params['guess_code'],
        matching: @request.session[:player].current_progress
      })

      true
    else
      false
    end
  end

end