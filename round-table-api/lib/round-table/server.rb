require 'sinatra'
require 'json'
require 'jwt'
require 'dotenv/load'
require_relative "api"
require 'sinatra/cross_origin'

class RoundTableAPI < Sinatra::Base
  
  configure do
    enable :cross_origin
  end

  before do
    content_type :json
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  # Create Gameroom
  post '/gameroom' do
    werewolfGame = RoundTable::WerewolfGameroom.new
    RoundTable::RoundTableGameDBService.save werewolfGame 
    werewolfGame.to_json
  end

  # Get Gameroom information
  get '/gameroom/:gameroomid' do |gameroomid|
    auth_token = decodeToken(request)
    werewolfGame = RoundTable::RoundTableGameDBService.get gameroomid 

    raise Sinatra::NotFound.new if werewolfGame.nil?

    role ={}
    role = werewolfGame.getRole(auth_token["username"]) if (auth_token)
    {
      game: werewolfGame,
      results: werewolfGame.getVotes,
      role: role
    }.to_json
  end

  # Register Player to Gameroom
  post '/gameroom/:gameroomid/register' do |gameroomid|
    request.body.rewind
    req = request.body.read
    data = JSON.parse req
    werewolfGame = RoundTable::RoundTableGameDBService.get gameroomid

    raise Sinatra::NotFound.new if werewolfGame.nil?

    player = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:data['username'])
    
    unless werewolfGame.roster.include? player
      werewolfGame.addPlayer(player) 
      RoundTable::RoundTableGameDBService.save werewolfGame
    end

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

    werewolfGame = RoundTable::RoundTableGameDBService.get gameroomid

    raise Sinatra::NotFound.new if werewolfGame.nil?

    werewolfGame.submitVote(player:decoded_token["username"], voteFor:data['vote'])
    RoundTable::RoundTableGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Start Game in Gameroom
  post '/gameroom/:gameroomid/start' do |gameroomid|
    auth_token = request.env['HTTP_AUTHORIZATION']
    werewolfGame = RoundTable::RoundTableGameDBService.get gameroomid

    raise Sinatra::NotFound.new if werewolfGame.nil?

    werewolfGame.start
    RoundTable::RoundTableGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Change Time in Day in Gameroom
  post '/gameroom/:gameroomid/:timeOfDay' do |gameroomid,timeOfDay|
    decoded_token=decodeToken(request)

    werewolfGame = RoundTable::RoundTableGameDBService.get gameroomid

    raise Sinatra::NotFound.new if werewolfGame.nil?
    
    if timeOfDay == 'day'
      print "Sending To Day"
      deactivatedPlayer = werewolfGame.sendToDay decoded_token["username"] 
    end
    if timeOfDay == 'night'
      print "Sending to Night"
      deactivatedPlayer = werewolfGame.sendToNight decoded_token["username"]
    end
    RoundTable::RoundTableGameDBService.save werewolfGame
    
    {
      game: werewolfGame,
      deactivatedPlayer: deactivatedPlayer
    }.to_json
  end

  # Needed for CORS
  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization"
  
    200
  end

  not_found do
    'Game was not found'
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
