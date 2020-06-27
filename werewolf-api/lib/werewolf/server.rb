require 'sinatra'
require 'json'
require_relative "api"
require 'sinatra/cross_origin'

class WerewolfAPI < Sinatra::Base
  configure do
    enable :cross_origin
  end

  before do
    content_type :json
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  # Create Gameroom
  post '/gameroom' do
    werewolfGame = Werewolf::Gameroom.new()
    Werewolf::WerewolfGameDBService.save werewolfGame 
    werewolfGame.to_json
  end

  # Get Gameroom information
  get '/gameroom/:gameroomid' do |gameroomid|
    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid 
    werewolfGame.to_json
  end

  # Register Player to Gameroom
  post '/gameroom/:gameroomid/register' do |gameroomid|
    request.body.rewind  # in case someone already read it
    print request.body.read
    request.body.rewind
    data = JSON.parse request.body.read
    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
    player = Werewolf::Gameroom::Player.new(name:data['username'])
    werewolfGame.addPlayer(player)
    Werewolf::WerewolfGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Submit Vote for Player
  post '/gameroom/:gameroomid/vote' do |gameroomid|
    request.body.rewind  # in case someone already read it
    data = JSON.parse request.body.read
    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
    werewolfGame.submitVote(player:data['username'], voteFor:data['vote'])
    Werewolf::WerewolfGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Start Game in Gameroom
  post '/gameroom/:gameroomid/start' do |gameroomid|
    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
    werewolfGame.start
    Werewolf::WerewolfGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Change Time in Day in Gameroom
  post '/gameroom/:gameroomid/:timeOfDay' do |gameroomid,timeOfDay|
    request.body.rewind  # in case someone already read it
    data = JSON.parse request.body.read
    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
    werewolfGame.sendToDay data['username'] if timeOfDay == 'day'
    werewolfGame.sendToNight data['username'] if timeOfDay == 'night'
    Werewolf::WerewolfGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Needed for CORS
  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  
    200
  end
end
