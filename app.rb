require 'sinatra/base'
require 'sinatra/respond_with'
require 'json'
require 'data_mapper'

app_root = File.dirname(__FILE__)

module KreuzbergIntegers
  STARTING_INTEGER = 81726007 # Google 'population of germany', make into number divisible by 11

  class Foundry
    include DataMapper::Resource

    property :id, Integer, :key => true
    timestamps :created_at

    def self.mint!
      minted = new
      minted.id = last_integer + 11
      minted.save
      minted
    end

    def self.last_integer
      max(:id) || STARTING_INTEGER
    end

    def to_s
      id.to_s
    end

    def to_json(opts = {})
      {'integer' => id, 'shorturl' => '', 'stat' => 'ok'}.to_json(opts)
    end
  end

  class App < Sinatra::Base
    register Sinatra::RespondWith
    set :json_encoder, :to_json
    if ENV['RACK_ENV'] != "production"
      set :static, true
    end
    set :views, File.expand_path('views', app_root)

    post '/mint', provides: [:html, :json, :txt] do
      minted = Foundry.mint!
      respond_with :mint, minted do |f|
        f.txt { minted.id.to_s }
      end
    end

    get '/integer/:id.json' do
      integer = Foundry.get(params[:id])
      halt(404) unless integer
      json(integer)
    end

    get '/integer/:id', provides: [:html, :json] do
      integer = Foundry.get(params[:id])
      halt(404) unless integer
      respond_with :mint, integer
    end
  end
end

DataMapper.setup(:default, "sqlite://#{app_root}/integers.sqlite3")
DataMapper.finalize
DataMapper.auto_upgrade!
