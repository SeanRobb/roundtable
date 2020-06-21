require 'sinatra'
require 'json'
require_relative "api"

before do
  content_type :json
end
post '/gameroom' do
  werewolfGame = Werewolf::Gameroom.new()
  Werewolf::WerewolfGameDBService.save werewolfGame 
  werewolfGame.to_json
end

get '/gameroom/:gameroomid' do |gameroomid|
  werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid 
  werewolfGame.to_json
end

post '/gameroom/:gameroomid/register' do |gameroomid|
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
  player = Werewolf::Gameroom::Player.new(name:data['username'])
  werewolfGame.addPlayer(player)
  Werewolf::WerewolfGameDBService.save werewolfGame
  werewolfGame.to_json
end

post '/gameroom/:gameroomid/vote' do |gameroomid|
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
  werewolfGame.submitVote(player:data['username'], voteFor:data['vote'])
  Werewolf::WerewolfGameDBService.save werewolfGame
  werewolfGame.to_json
end

post '/gameroom/:gameroomid/start' do |gameroomid|
  werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
  werewolfGame.start
  Werewolf::WerewolfGameDBService.save werewolfGame
  werewolfGame.to_json
end

post '/gameroom/:gameroomid/:timeOfDay' do |gameroomid,timeOfDay|
  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  werewolfGame = Werewolf::WerewolfGameDBService.get gameroomid
  werewolfGame.sendToDay data['username'] if timeOfDay == 'day'
  werewolfGame.sendToNight data['username'] if timeOfDay == 'night'
  Werewolf::WerewolfGameDBService.save werewolfGame
  werewolfGame.to_json
end