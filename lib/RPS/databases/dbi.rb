require 'pg'
require 'pry-byebug'

module RPS
  class DBI
    def initialize
      @db = PG.connect(host: 'localhost', dbname: 'RPS')
      build_tables
    end

    def build_tables
      # USERS
      # GAMES
      # ROUNDS
    end
  end
end