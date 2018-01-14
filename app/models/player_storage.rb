require 'date'
require 'yaml'
require 'yaml/store'

Player = Struct.new :name, :try_number, :hint_count, :secret_number, :is_win, :date

class PlayerStorage
  
  attr_accessor :store

  def initialize
    @store = YAML::Store.new self.get_storage_path()
  end

  def get_storage_path()
    File.join(Dir.pwd, 'app', 'data', 'player.store')
  end

  def get_players
    self.store.transaction do
      return self.store['player'] ? self.store['player'] : []
    end
  end

  def add_player(player)
    player.date = DateTime.now.to_s

    self.store.transaction do
      if (self.store['player'])
        self.store['player'] += [player]
      else
        self.store['player'] = [player]
      end
    end
  end

end