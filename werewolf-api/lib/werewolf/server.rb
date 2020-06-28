require 'sinatra'
require 'json'
require 'jwt'
require 'dotenv/load'
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
    werewolfGame = Werewolf::Gameroom.new
    Werewolf::WerewolfGameDBService.save werewolfGame 
    werewolfGame.to_json
  end

  # Get Gameroom information
  get '/gameroom/:gameroomid' do |gameroomid|
    auth_token = decodeToken(request)
    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid 
    role ={}
    if (auth_token)
      role = werewolfGame.getRole(auth_token["username"])
    end

    {
      game: werewolfGame,
      results: [],
      role: role
    }.to_json
  end

  # Register Player to Gameroom
  post '/gameroom/:gameroomid/register' do |gameroomid|
    request.body.rewind
    req = request.body.read
    data = JSON.parse req
    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
    #if player does not already exist
    player = Werewolf::Gameroom::Player.new(name:data['username'])
    werewolfGame.addPlayer(player)
    Werewolf::WerewolfGameDBService.save werewolfGame
    
    {
      game: werewolfGame,
      bearer: encodeToken(player:player)
    }.to_json
  end

  # Submit Vote for Player
  post '/gameroom/:gameroomid/vote' do |gameroomid|
    decoded_token=decodeToken(request)

    request.body.rewind  # in case someone already read it
    data = JSON.parse request.body.read

    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
    werewolfGame.submitVote(player:decoded_token["username"], voteFor:data['vote'])
    Werewolf::WerewolfGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Start Game in Gameroom
  post '/gameroom/:gameroomid/start' do |gameroomid|
    auth_token = request.env['HTTP_AUTHORIZATION']
    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
    werewolfGame.start
    Werewolf::WerewolfGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Change Time in Day in Gameroom
  post '/gameroom/:gameroomid/:timeOfDay' do |gameroomid,timeOfDay|
    decoded_token=decodeToken(request)

    werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
    werewolfGame.sendToDay decoded_token["username"] if timeOfDay == 'day'
    werewolfGame.sendToNight decoded_token["username"] if timeOfDay == 'night'
    Werewolf::WerewolfGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Needed for CORS
  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization"
  
    200
  end

  def encodeToken(params = {})
    payload = { username: params.fetch(:player).name, iat: Time.now.to_i }
    JWT.encode payload, ENV['JWT_SECRET'], 'HS256', { typ: 'JWT' }
  end

  def decodeToken(request)
    auth_token = request.env['HTTP_AUTHORIZATION']
    return nil unless auth_token
    auth_token.slice! "Bearer "
    token = JWT.decode auth_token, ENV['JWT_SECRET'], true, { algorithm: 'HS256' }
    token [0]
  end
end
