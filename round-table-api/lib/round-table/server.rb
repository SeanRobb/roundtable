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
    payload = json_params unless empty_body?
    if payload[:type] == "Next Round" then
      nextRoundGame = RoundTable::NextRoundGameroom.new
      RoundTable::RoundTableGameDBService.save nextRoundGame 
      return nextRoundGame.to_json
    else
      werewolfGame = RoundTable::WerewolfGameroom.new
      RoundTable::RoundTableGameDBService.save werewolfGame 
      return werewolfGame.to_json
    end
  end

  # Get Gameroom information
  get '/gameroom/:gameroomid' do |gameroomid|
    auth_token = decodeToken(request)
    game = RoundTable::RoundTableGameDBService.get gameroomid 

    raise Sinatra::NotFound.new if game.nil?

    role ={}
    role = game.getRole(auth_token[:username]) if (auth_token)

    returnObject = {
      game: game,
      role: role
    }
    if game.type == "Werewolf" then
      returnObject[:waitingroom] = {
        :description=> "You need at least 7 players to play",
        :canStart => game.roster.count > 6
      }
      returnObject[:results] = game.getVotes 
    elsif game.type == "Next Round" then
      returnObject[:waitingroom] = {
        :description => "You need at least 2 players to play",
        :canStart => game.roster.count > 1
      }
      returnObject[:leaderboard] = game.leaderboard 
    end

    returnObject.to_json    
  end

  # Register Player to Gameroom
  post '/gameroom/:gameroomid/register' do |gameroomid|
    # TODO replace with json_params

    payload = json_params unless empty_body?

    game = RoundTable::RoundTableGameDBService.get gameroomid

    raise Sinatra::NotFound.new if game.nil?

    player = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:payload[:username]) if game.type == "Werewolf"

    player = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:payload[:username]) if game.type == "Next Round"
    
    unless game.roster.include? player
      game.add_player(player) 
      RoundTable::RoundTableGameDBService.save game
    end

    {
      game: game,
      bearer: encodeToken(player:player)
    }.to_json
  end

  # Werewolf Specific
  # Submit Vote for Player
  post '/gameroom/:gameroomid/werewolf/vote' do |gameroomid|
    decoded_token=decodeToken(request)

    payload = json_params unless empty_body?

    werewolfGame = RoundTable::RoundTableGameDBService.get gameroomid

    raise Sinatra::NotFound.new if werewolfGame.nil?

    werewolfGame.submitVote(player:decoded_token[:username], voteFor:payload[:vote])
    RoundTable::RoundTableGameDBService.save werewolfGame
    werewolfGame.to_json
  end

  # Start Game in Gameroom
  post '/gameroom/:gameroomid/start' do |gameroomid|
    game = RoundTable::RoundTableGameDBService.get gameroomid

    raise Sinatra::NotFound.new if game.nil?

    game.start
    RoundTable::RoundTableGameDBService.save game
    game.to_json
  end

  # Change Time in Day in Gameroom
  post '/gameroom/:gameroomid/werewolf/:timeOfDay' do |gameroomid,timeOfDay|
    decoded_token=decodeToken(request)

    werewolfGame = RoundTable::RoundTableGameDBService.get gameroomid

    raise Sinatra::NotFound.new if werewolfGame.nil?
    
    if timeOfDay == 'day'
      print "Sending To Day"
      deactivatedPlayer = werewolfGame.sendToDay decoded_token[:username]
    end
    if timeOfDay == 'night'
      print "Sending to Night"
      deactivatedPlayer = werewolfGame.sendToNight decoded_token[:username]
    end
    RoundTable::RoundTableGameDBService.save werewolfGame
    
    {
      game: werewolfGame,
      deactivatedPlayer: deactivatedPlayer
    }.to_json
  end

  # Next Round
  # Create Option for Captain
  post '/gameroom/:gameroomid/next-round/option' do |gameroomid|
    # parse body
    payload = json_params unless empty_body?
    # create option
    option = RoundTable::NextRoundGameroom::Option.new(payload)
    # get game
    nextRoundGame = RoundTable::RoundTableGameDBService.get gameroomid
    # add option to game
    nextRoundGame.add_option option
    # save game
    RoundTable::RoundTableGameDBService.save nextRoundGame
    # return saved game
    nextRoundGame.to_json
  end
  #delete option
  delete '/gameroom/:gameroomid/next-round/option/:optionid' do |gameroomid,optionid|
    # parse body
    payload = json_params unless empty_body?
    # get game
    nextRoundGame = RoundTable::RoundTableGameDBService.get gameroomid
    # add option to game
    nextRoundGame.options.delete_if {|option| option.id == optionid}
    # save game
    RoundTable::RoundTableGameDBService.save nextRoundGame
    # return saved game
    nextRoundGame.to_json
  end
  # Create Bet
  post '/gameroom/:gameroomid/next-round/bet' do |gameroomid|
    # parse body
    payload = json_params unless empty_body?
    # create bet
    bet = RoundTable::NextRoundGameroom::Option.new(payload)
    # get game
    nextRoundGame = RoundTable::RoundTableGameDBService.get gameroomid
    # add bet to game
    nextRoundGame.open_bet bet
    # save game
    RoundTable::RoundTableGameDBService.save nextRoundGame
    # return saved game
    nextRoundGame.to_json
  end
  # Change state of Bet 
  put '/gameroom/:gameroomid/next-round/bet/:betid/state' do |gameroomid, betid|
    # parse body
    payload = json_params unless empty_body?
    # get game
    nextRoundGame = RoundTable::RoundTableGameDBService.get gameroomid
    # update bet state
    # TODO lock this down to the captain only
    if payload[:state] == "freeze" then
      nextRoundGame.freeze_bet(betid)
    elsif payload[:state] == "close" then
      nextRoundGame.close_bet(betid,payload[:selection])
    end
    # save game
    RoundTable::RoundTableGameDBService.save nextRoundGame
    # return saved game
    nextRoundGame.to_json
  end

  # Submit Bet selection
  put '/gameroom/:gameroomid/next-round/bet/:betid/selection' do |gameroomid, betid|
    # parse body
    payload = json_params unless empty_body?
    decoded_token=decodeToken(request)
    # get game
    nextRoundGame = RoundTable::RoundTableGameDBService.get gameroomid
    nextRoundGame.place_bet(decoded_token[:username],betid,payload[:selection])
 
    # save game
    RoundTable::RoundTableGameDBService.save nextRoundGame
    # return saved game
    nextRoundGame.to_json
  end

  # Needed for CORS
  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Methods"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
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
    token [0].transform_keys(&:to_sym)
  end
  def json_params
    request.body.rewind 
    begin
      JSON.parse(request.body.read).transform_keys(&:to_sym)
    rescue
      halt 400, { message:'Invalid JSON' }.to_json
    end
  end
  def empty_body?
    request.body.rewind 
    request.body.read.empty?
  end
end
