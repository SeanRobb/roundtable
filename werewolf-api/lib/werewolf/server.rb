require 'sinatra'
require 'json'
require_relative "api"

before do
  content_type :json
end
post '/gameroom' do
  werewolfGame = Werewolf::Gameroom.new()
  werewolfGame.to_json
end

