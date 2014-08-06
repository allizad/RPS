require 'pg'
require 'pry-byebug'

module RPS
  class DBI
    def initialize
      @db = PG.connect(host: 'localhost', dbname: 'RPS')
      build_tables
    end

    def build_tables
      @db.exec(%q[
        CREATE TABLE IF NOT EXISTS users(
          id serial NOT NULL PRIMARY KEY,
          )])
      # USERS
      # GAMES
      # ROUNDS
    end
  end
end