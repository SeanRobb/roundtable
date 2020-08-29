RSpec.describe Werewolf do
  it "has a version number" do
    expect(Werewolf::VERSION).not_to be nil
  end

  describe "create a gameroom" do
    it "can create a new gameroom" do
      werewolfGame = Werewolf::Gameroom.new()
      expect(werewolfGame).to exist
      expect(werewolfGame.id).to satisfy('4 Random Char String') { |id|
        id.length == 4 and id.kind_of? String
      }
      expect(werewolfGame.created.to_s).to eq(Time.now.getutc.to_s) 
      expect(werewolfGame.roster).to be_empty
      expect(werewolfGame.location).to_not be_nil
      expect(werewolfGame.hasStarted).to be_falsey
      expect(werewolfGame.hasFinished).to be_falsey
    end
    it "can pass in params" do
      id = 'abcd'
      created = Time.now.getutc
      playerRoster = [Werewolf::Gameroom::Player.new(name:'sean')]
      location = Werewolf::Gameroom::Location.new()
      hasStarted = true
      hasFinished = true


      werewolfGame = Werewolf::Gameroom.new(id:id,created:created,
      roster:playerRoster,location:location, hasStarted:hasStarted, hasFinished:hasFinished)
      expect(werewolfGame).to exist
      expect(werewolfGame.id).to eq(id)
      expect(werewolfGame.created).to eq(created) 
      expect(werewolfGame.roster).to eq(playerRoster)
      expect(werewolfGame.location).to eq(location)
      expect(werewolfGame.hasStarted).to eq(hasStarted)
      expect(werewolfGame.hasFinished).to eq(hasFinished)
    end
  end

  describe "player manipulation" do
    it "can create player with name" do
      name='sean'
      player = Werewolf::Gameroom::Player.new(name:name)

      expect(player).to exist
      expect(player.name).to eq(name)
      expect(player.narrator?).to be_falsey 
      expect(player.werewolf?).to be_falsey
      expect(player.active?).to be_falsey
      expect(player.vote).to be_nil
    end
    it "player names are trimmed when created" do
      name='  se an  '
      player = Werewolf::Gameroom::Player.new(name:name)

      expect(player).to exist
      expect(player.name).to eq('se an')
      expect(player.narrator?).to be_falsey 
      expect(player.werewolf?).to be_falsey
      expect(player.active?).to be_falsey
      expect(player.vote).to be_nil
    end
    it "can not create player without a name" do
      expect {Werewolf::Gameroom::Player.new()}.to raise_error('Must set name for player')
    end
    it "can set params when creating player" do
      name='sean'
      isNarrator=true
      isWerewolf=false
      isActive=false
      vote='Lauren'
      player = Werewolf::Gameroom::Player.new(name:name,isNarrator:isNarrator,isWerewolf:isWerewolf,
      isActive:isActive,vote:vote)
      expect(player).to exist
      expect(player.name).to eq(name)
      expect(player.narrator?).to eq(isNarrator) 
      expect(player.werewolf?).to eq(isWerewolf)
      expect(player.active?).to eq(isActive)
      expect(player.vote).to eq(vote)
    end
    it "can add player to a game" do
      gameroom = Werewolf::Gameroom.new()
      player = Werewolf::Gameroom::Player.new(name:'sean')
      gameroom.addPlayer(player)
      expect(gameroom.roster).to include player
    end
    it "cannot add player to a game with the same name" do
      gameroom = Werewolf::Gameroom.new()
      player1 = Werewolf::Gameroom::Player.new(name:'sean')
      gameroom.addPlayer(player1)

      expect(gameroom.roster).to include player1

      player2 = Werewolf::Gameroom::Player.new(name:'sean')
      expect { gameroom.addPlayer(player2)}.to raise_error('Player already exists')

      player3 = Werewolf::Gameroom::Player.new(name:'sEaN')
      expect { gameroom.addPlayer(player3)}.to raise_error('Player already exists')
    end
    it "narrator defaults to the first person in the room" do
      gameroom = Werewolf::Gameroom.new()
      player1 = Werewolf::Gameroom::Player.new(name:'sean')
      player2 = Werewolf::Gameroom::Player.new(name:'test')
      gameroom.addPlayer(player1)
      gameroom.addPlayer(player2)

      expect(gameroom.roster).to include player1
      expect(gameroom.roster).to include player2
      expect(gameroom.narrator).to equal(player1)
    end

    it "cannot add a player after game has started" do
      gameroom = createValidGame()
      player3 = Werewolf::Gameroom::Player.new(name:'late player')
      gameroom.start
      expect { gameroom.addPlayer(player3)}.to raise_error('Game has already started')
    end
  end

  describe "Gameroom starts game" do
    it "changes game status hasStarted to true" do
      werewolfGame = createValidGame()
      werewolfGame.start
      expect(werewolfGame.hasStarted).to be_truthy
    end
    it "can not start a game that is already started" do
      werewolfGame = createValidGame()
      werewolfGame.start
      expect { werewolfGame.start }.to raise_error('Game has already started')
    end
    it "must have 7 people to start" do
      werewolfGame = createValidGame(5)
      expect { werewolfGame.start }.to raise_error('Not enough players')
    end
    it "starts in first night" do
      werewolfGame = createValidGame()
      werewolfGame.location = Werewolf::Gameroom::Location.new(day:12,isNight:false)
      werewolfGame.start
      expect(werewolfGame.location.day).to eq(0)
      expect(werewolfGame.location.night?).to be_truthy
    end
    it "send to day increaments day" do
      werewolfGame = createValidGame()
      werewolfGame.start
      werewolfGame.sendToDay(werewolfGame.narrator.name)
      expect(werewolfGame.location.day).to eq(1)
      expect(werewolfGame.location.night?).to be_falsey
    end
    it "has a narrator" do
      werewolfGame = createValidGame()
      werewolfGame.start
      expect(werewolfGame.narrator). to be_truthy
    end
    it "has active werewolves" do
      werewolfGame = createValidGame()
      werewolfGame.start
      expect(werewolfGame.activeWerewolves). to be_truthy
    end
    it "has active villagers" do
      werewolfGame = createValidGame()
      werewolfGame.start
      expect(werewolfGame.activeVillagers). to be_truthy
    end
    it "has active players" do
      werewolfGame = createValidGame()
      werewolfGame.start
      expect(werewolfGame.activePlayers). to be_truthy
    end
    it "has 1 werewolf for 6 players" do
      werewolfGame1 = createValidGame()
      werewolfGame1.start
      expect(werewolfGame1.activeWerewolves.length).to eq(1)
    end
    it "has 1 werewolf for 9 players" do
      werewolfGame2 = createValidGame(8)
      werewolfGame2.start
      expect(werewolfGame2.activeWerewolves.length).to eq(1)
    end
    it "has 2 werewolves for 9 players" do
      werewolfGame2 = createValidGame(9)
      werewolfGame2.start
      expect(werewolfGame2.activeWerewolves.length).to eq(2)
    end
    it "has 2 werewolves for 11 players" do
      werewolfGame2 = createValidGame(11)
      werewolfGame2.start
      expect(werewolfGame2.activeWerewolves.length).to eq(2)
    end
    it "has 3 werewolves for 12 players" do
      werewolfGame1 = createValidGame(12)
      werewolfGame1.start
      expect(werewolfGame1.activeWerewolves.length).to eq(3)
    end
    it "has 3 werewolves for 15 players" do
      werewolfGame2 = createValidGame(15)
      werewolfGame2.start
      expect(werewolfGame2.activeWerewolves.length).to eq(3)
    end
  end

  describe "Game Room Successfully executes gameplay" do
    describe "General Gameplay" do
      before(:each) do
        @werewolfGame = createValidGame
        @werewolfGame.start
      end
      describe "Days are controlled By Narrator" do
        it "Gameroom can be sent to day" do
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          expect(@werewolfGame.location.night?).to be_falsey
          
          expect {@werewolfGame.sendToDay(@werewolfGame.activeVillagers[0].name)}.to raise_error('Only narrator can change day')
        end
        it "Gameroom can be sent to night" do
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          expect(@werewolfGame.location.night?).to be_truthy
          
          expect {@werewolfGame.sendToNight(@werewolfGame.activeVillagers[0].name)}.to raise_error('Only narrator can change day')
        end
      end
      describe "Voting rules are followed" do
        it "Game Room only kills werewolf when a majority votes for it - no votes" do
          beforeActivePlayerCount = @werewolfGame.activePlayers.length
          deactivatedPlayer = @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          expect(deactivatedPlayer).to be_nil
          expect(@werewolfGame.activePlayers.length).to eq(beforeActivePlayerCount)
        end
        it "Game Room only kills villager when it is unanimous - no votes" do
          beforeActivePlayerCount = @werewolfGame.activePlayers.length
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          deactivatedPlayer = @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          expect(deactivatedPlayer).to be_nil
          expect(@werewolfGame.activePlayers.length).to eq(beforeActivePlayerCount)
        end
        it "Game Room only allows for active players to vote" do
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          @werewolfGame.activePlayers.each_with_index {|activePlayer, index| 
            voteFor = @werewolfGame.activePlayers[index-1] if index>0
            voteFor = @werewolfGame.activePlayers[index+1] if index==0
            @werewolfGame.submitVote(player:activePlayer.name,voteFor: voteFor.name)
          }
          expect {@werewolfGame.submitVote(player:@werewolfGame.narrator.name,voteFor: @werewolfGame.activePlayers[0].name)}.to raise_error "Only active players can vote"
          expect {@werewolfGame.submitVote(player:@werewolfGame.activePlayers[0].name,voteFor: @werewolfGame.activePlayers[0].name+"123")}.to raise_error "Only active players can be voted for"
        end

        it "Game Room can retrieve tally for day" do
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          @werewolfGame.activePlayers.each_with_index {|activePlayer, index| 
            voteFor = @werewolfGame.activePlayers[index-1] if index>0
            voteFor = @werewolfGame.activePlayers[index+1] if index==0
            @werewolfGame.submitVote(player:activePlayer.name,voteFor: voteFor.name)
          }

          tally = @werewolfGame.getVotes
          @werewolfGame.activePlayers.each_with_index {|activePlayer, index| 
            voteFor = @werewolfGame.activePlayers[index-1] if index>0
            voteFor = @werewolfGame.activePlayers[index+1] if index==0
            expect(tally[:votes][voteFor.name].length).to eq(2) if index == 0 || index == 2
            expect(tally[:votes][voteFor.name].length).to eq(1) if index > 2  || index == 1
          }
          expect(tally[:needs]).to eq((@werewolfGame.activePlayers.length/2).floor + 1)
        end

        it "Game Room can retrieve tally for day" do
          @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          @werewolfGame.activeWerewolves.each_with_index {|activePlayer, index| 
            @werewolfGame.submitVote(player:activePlayer.name,voteFor: @werewolfGame.activeVillagers[0].name)
          }

          tally = @werewolfGame.getVotes
          expect(tally[:votes][@werewolfGame.activeVillagers[0].name].length).to eq(1)
        end
      end
      describe "Roles can be retrieved" do
        it "Returns Villager Role in day" do
          villager=@werewolfGame.roster.find {|player| player.active? && !player.werewolf? && !player.narrator?}
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          role = @werewolfGame.getRole(villager.name)
          expect(role[:name]).to eq("Villager") 
          expect(role[:description]).to eq(
            "Villagers work hard to settle their new town. Hidden amonst this group of villagers their are werewolves."+
        " For the success of the town it is critical to remove all of the werewolves. Every night the werewolves hunt villagers and "+
        "every day the villagers vote who they believe is a werewolf. The vote is based on a majority. If the villagers successfully "+
        "vote for a werewolf then that werewolf will be removed from the village never to return. It is a race against time, will the "+
        "villagers find and remove all of the werewolves before the werewolves attack all of the villagers? Do your best to decide who "+
        "you can trust."
          ) 
          validBallot = @werewolfGame.roster.select {|player| (player.active? && player.name != villager.name)}.map {|player| player.name}
          expect(role[:ballot]).to eq(validBallot) 
          expect(role[:isActive]).to be_truthy
        end
        it "Returns Villager Role in night" do
          villager=@werewolfGame.roster.find {|player| player.active? && !player.werewolf? && !player.narrator?}
          @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          role = @werewolfGame.getRole(villager.name)
          expect(role[:name]).to eq("Villager") 
          expect(role[:description]).to eq(
            "Villagers work hard to settle their new town. Hidden amonst this group of villagers their are werewolves."+
        " For the success of the town it is critical to remove all of the werewolves. Every night the werewolves hunt villagers and "+
        "every day the villagers vote who they believe is a werewolf. The vote is based on a majority. If the villagers successfully "+
        "vote for a werewolf then that werewolf will be removed from the village never to return. It is a race against time, will the "+
        "villagers find and remove all of the werewolves before the werewolves attack all of the villagers? Do your best to decide who "+
        "you can trust."
          ) 
          expect(role[:ballot]).to eq([]) 
          expect(role[:isActive]).to be_truthy
        end
        it "Returns Werewolf Role in day" do
          werewolf=@werewolfGame.roster.find {|player| player.active? && player.werewolf? && !player.narrator?}
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          role = @werewolfGame.getRole(werewolf.name)
          expect(role[:name]).to eq("Werewolf") 
          expect(role[:description]).to eq("At night werewolves vote for which villager to attack." +
          " Night votes must be unanimous. During the day werewolves must blend in" +
          " with the other villagers they can vote and debate like all other villagers." +
          " Villagers votes will need a majority during the day.") 
          validBallot = @werewolfGame.roster.select {|player| (player.active? && player.name != werewolf.name)}.map {|player| player.name}
          expect(role[:ballot]).to eq(validBallot) 
          expect(role[:isActive]).to be_truthy
        end
        it "Returns Werewolf Role in night" do
          werewolf=@werewolfGame.roster.find {|player| player.active? && player.werewolf? && !player.narrator?}
          @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          role = @werewolfGame.getRole(werewolf.name)
          expect(role[:name]).to eq("Werewolf") 
          expect(role[:description]).to eq("At night werewolves vote for which villager to attack." +
          " Night votes must be unanimous. During the day werewolves must blend in" +
          " with the other villagers they can vote and debate like all other villagers." +
          " Villagers votes will need a majority during the day.") 
          validBallot = @werewolfGame.roster.select {|player| (player.active? && player.name != werewolf.name)}.map {|player| player.name}
          expect(role[:ballot]).to eq(validBallot) 
          expect(role[:isActive]).to be_truthy
        end
        it "Returns Narrator Role" do
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          role = @werewolfGame.getRole(@werewolfGame.narrator.name)
          expect(role[:name]).to eq("Narrator") 
          expect(role[:description]).to eq("The narrator will be the story teller of this village." +
          " You control when days change and will inform players when to go to sleep" +
          " and wake up.") 
          expect(role[:ballot]).to eq([]) 
          @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          role = @werewolfGame.getRole(@werewolfGame.narrator.name)
          expect(role[:name]).to eq("Narrator") 
          expect(role[:description]).to eq("The narrator will be the story teller of this village." +
          " You control when days change and will inform players when to go to sleep" +
          " and wake up.") 
          expect(role[:ballot]).to eq([]) 
          expect(role[:isActive]).to be_falsey
        end
      end
    end
    describe "1 werewolf" do
      describe "General Gameplay" do
        before(:each) do
          @werewolfGame = createValidGame
          @werewolfGame.start
        end
        it "Villagers only kill when the vote is a majority" do
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          playerToVoteFor = @werewolfGame.activePlayers[0]
          majorityVillagersVoteFor(@werewolfGame, playerToVoteFor)
          deactivatedPlayer = @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          expect(deactivatedPlayer).not_to be_nil
          expect(deactivatedPlayer).to eq(playerToVoteFor)
          expect(playerToVoteFor.active?).to eq(false)
        end
        it "Werewolves only kill when the vote is unanimous" do
          playerToVoteFor = @werewolfGame.activeVillagers[0]
          allWerewolvesVoteFor(@werewolfGame, playerToVoteFor)
          deactivatedPlayer = @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          expect(deactivatedPlayer).not_to be_nil
          expect(deactivatedPlayer).to eq(playerToVoteFor)
          expect(playerToVoteFor.active?).to eq(false)
        end
      end
      describe "Villagers Win" do
        before(:each) do
          @werewolfGame = createValidGame
          @werewolfGame.start
        end
        it "Find Werewolf Day 1" do
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
        it "Find Werewolf Day 2" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
      end
      describe "Werewolves Win" do
        before(:each) do
          @werewolfGame = createValidGame
          @werewolfGame.start
        end
        it "No Werewolf Found" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
      end
    end
    describe "2 werewolf" do
      describe "General Gameplay" do
        before(:each) do
          @werewolfGame = createValidGame 10
          @werewolfGame.start
        end
        it "Villagers only kill when the vote is a majority" do
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          playerToVoteFor = @werewolfGame.activePlayers[0]
          majorityVillagersVoteFor(@werewolfGame, playerToVoteFor)
          deactivatedPlayer = @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          expect(deactivatedPlayer).not_to be_nil
          expect(deactivatedPlayer).to eq(playerToVoteFor)
          expect(playerToVoteFor.active?).to eq(false)
        end
        it "Werewolves only kill when the vote is unanimous" do
          playerToVoteFor = @werewolfGame.activeVillagers[0]
          allWerewolvesVoteFor(@werewolfGame, playerToVoteFor)
          deactivatedPlayer = @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          expect(deactivatedPlayer).not_to be_nil
          expect(deactivatedPlayer).to eq(playerToVoteFor)
          expect(playerToVoteFor.active?).to eq(false)
        end
      end
      describe "Villagers Win" do
        before(:each) do
          @werewolfGame = createValidGame 10
          @werewolfGame.start
        end
        it "Find Werewolf Day 1 & 2" do
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
        it "Find Werewolf Day 1 & 3" do
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
        it "Find Werewolf Day 1 & 4" do
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
        it "Find Werewolf Day 2 & 3" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
        it "Find Werewolf Day 2 & 4" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
        it "Find Werewolf Day 3 & 4" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
        it "Find Werewolf Day 3 & 4" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
      end
      describe "Werewolves Win" do
        before(:each) do
          @werewolfGame = createValidGame 10
          @werewolfGame.start
        end
        it "No Werewolf Found" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 1" do
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 2" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 3" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 4" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
      end
    end
    describe "3 werewolf" do
      describe "General Gameplay" do
        before(:each) do
          @werewolfGame = createValidGame 15
          @werewolfGame.start
        end
        it "Villagers only kill when the vote is a majority" do
          @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          playerToVoteFor = @werewolfGame.activePlayers[0]
          majorityVillagersVoteFor(@werewolfGame, playerToVoteFor)
          deactivatedPlayer = @werewolfGame.sendToNight(@werewolfGame.narrator.name)
          expect(deactivatedPlayer).not_to be_nil
          expect(deactivatedPlayer).to eq(playerToVoteFor)
          expect(playerToVoteFor.active?).to eq(false)
        end
        it "Werewolves only kill when the vote is unanimous" do
          playerToVoteFor = @werewolfGame.activeVillagers[0]
          allWerewolvesVoteFor(@werewolfGame, playerToVoteFor)
          deactivatedPlayer = @werewolfGame.sendToDay(@werewolfGame.narrator.name)
          expect(deactivatedPlayer).not_to be_nil
          expect(deactivatedPlayer).to eq(playerToVoteFor)
          expect(playerToVoteFor.active?).to eq(false)
        end
      end
      describe "Villagers Win" do
        before(:each) do
          @werewolfGame = createValidGame 15
          @werewolfGame.start
        end
        it "Find Werewolf Day 1 & 2 & 3" do
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
        it "Find Werewolf Day 1 & 3 & 4" do
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end

        it "Find Werewolf Day 1 & 3 & 6" do
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end

        it "Find Werewolf Day 4 & 5 & 6 " do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)    
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame,true)
          simulateDay(@werewolfGame,true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(true)
        end
      end
      describe "Werewolves Win" do
        before(:each) do
          @werewolfGame = createValidGame 15
          @werewolfGame.start
        end
        it "No Werewolf Found" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 1" do
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 2" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 3" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 4" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 5" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 6" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 6 & 7" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame, true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
        it "Werewolf Found Day 5 & 7" do
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          simulateDay(@werewolfGame)
          simulateDay(@werewolfGame, true)
          expect(@werewolfGame.hasFinished).to eq(true)
          expect(@werewolfGame.villageWins).to eq(false)
        end
      end
    end
  end

  # it "interacts with DB correctly" do
  #   gameroom = createValidGame()
  #   gameroom.start
  #   simulateDay(gameroom)
  #   Werewolf::WerewolfGameDBService.save gameroom
  #   room = Werewolf::WerewolfGameDBService.get gameroom.id
  #   expect(room).to eq(gameroom)
  # end
end
