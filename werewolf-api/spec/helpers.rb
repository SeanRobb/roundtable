require 'faker'

module Helpers
  def createValidGame(playercount = 6)
    werewolfGame = Werewolf::Gameroom.new()
    until werewolfGame.roster.length >= playercount+1 do
      werewolfGame.addPlayer(Werewolf::Gameroom::Player.new(name:Faker::Name.name))
    end
    werewolfGame
  end
  def majorityVillagersVoteFor(game, player)
    votes = game.activePlayers.length / 2 + 1
    voters = game.activePlayers.select { |activePlayer|  activePlayer != player}
    for i in 0..votes-1
      game.submitVote(player:voters[i].name,voteFor:player.name)
    end
    for i in votes..game.activePlayers.length-2
      game.submitVote(player:voters[i].name,voteFor:voters[0].name)
    end
    game.submitVote(player:player.name,voteFor:voters[0].name)
    game
  end
  def allWerewolvesVoteFor(game, player)
    game.activeWerewolves.each {|werewolf|  game.submitVote(player:werewolf.name,voteFor:player.name)}
    game
  end
  def simulateDay(game, werewolfFound=false)
    allWerewolvesVoteFor(game, game.activeVillagers[0])
    game.sendToDay(game.narrator.name)
    return if game.hasFinished
    majorityVillagersVoteFor(game, game.activeWerewolves[0]) if werewolfFound
    majorityVillagersVoteFor(game, game.activeVillagers[0]) unless werewolfFound
    game.sendToNight(game.narrator.name)
  end

end