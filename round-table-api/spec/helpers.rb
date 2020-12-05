require 'faker'

module Helpers
  def createWerewolfValidGame(playercount = 6)
    werewolfGame = RoundTable::WerewolfGameroom.new()
    until werewolfGame.roster.length >= playercount+1 do
      werewolfGame.add_player(RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:Faker::Name.name))
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
  def createNextRoundValidGame(playercount = 6, optioncount = 10)
    nextRoundGame = RoundTable::NextRoundGameroom.new()
    until nextRoundGame.roster.length >= playercount+1 do
      nextRoundGame.add_player(RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:Faker::Name.name))
    end
    until nextRoundGame.options.length >= optioncount+1 do
      teamA = Faker::Sports::Basketball.team
      teamB = Faker::Sports::Basketball.team
      quarter = rand(1..4)

      quarterString = "#{quarter}st" if quarter == 1
      quarterString = "#{quarter}nd" if quarter == 2
      quarterString = "#{quarter}rd" if quarter == 3
      quarterString = "#{quarter}th" if quarter == 4

      nextRoundGame.add_option(createOption)
    end
    nextRoundGame
  end
  def createOption
    teamA = Faker::Sports::Basketball.team
    teamB = Faker::Sports::Basketball.team
    quarter = rand(1..4)

    quarterString = "#{quarter}st" if quarter == 1
    quarterString = "#{quarter}nd" if quarter == 2
    quarterString = "#{quarter}rd" if quarter == 3
    quarterString = "#{quarter}th" if quarter == 4

    RoundTable::NextRoundGameroom::Option.new(
      title: "Option - #{rand(10)}",
      description:"Will #{teamA} score more points then #{teamB} in the #{quarterString}?",
      choiceA:teamA,
      choiceB:teamB)
  end
  def createBet
    createOption.to_bet
  end
  def openBetsFromOptions(game,openBetCount = 2)
    until game.openBets.length >= openBetCount+1 do
      game.open_bet(game.options[rand(game.options.length-1)])
    end
  end
end