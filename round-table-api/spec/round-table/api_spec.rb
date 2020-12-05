RSpec.describe RoundTable do
  it "has a version number" do
    expect(RoundTable::VERSION).not_to be nil
  end
  
  describe "Werewolf", :werewolf => true do
    describe "create a gameroom" do
      it "can create a new gameroom" do
        werewolfGame = RoundTable::WerewolfGameroom.new()
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
        playerRoster = [RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:'sean')]
        location = RoundTable::WerewolfGameroom::Location.new()
        hasStarted = true
        hasFinished = true


        werewolfGame = RoundTable::WerewolfGameroom.new(id:id,created:created,
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
        player = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:name)

        expect(player).to exist
        expect(player.name).to eq(name)
        expect(player.narrator?).to be_falsey 
        expect(player.werewolf?).to be_falsey
        expect(player.active?).to be_falsey
        expect(player.vote).to be_nil
      end
      it "player names are trimmed when created" do
        name='  se an  '
        player = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:name)

        expect(player).to exist
        expect(player.name).to eq('se an')
        expect(player.narrator?).to be_falsey 
        expect(player.werewolf?).to be_falsey
        expect(player.active?).to be_falsey
        expect(player.vote).to be_nil
      end
      it "can not create player without a name" do
        expect {RoundTable::WerewolfGameroom::WerewolfPlayer.new()}.to raise_error('Must set name for player')
      end
      it "can set params when creating player" do
        name='sean'
        isNarrator=true
        isWerewolf=false
        isActive=false
        vote='Lauren'
        player = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:name,isNarrator:isNarrator,isWerewolf:isWerewolf,
        isActive:isActive,vote:vote)
        expect(player).to exist
        expect(player.name).to eq(name)
        expect(player.narrator?).to eq(isNarrator) 
        expect(player.werewolf?).to eq(isWerewolf)
        expect(player.active?).to eq(isActive)
        expect(player.vote).to eq(vote)
      end
      it "can add player to a game" do
        gameroom = RoundTable::WerewolfGameroom.new()
        player = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:'sean')
        gameroom.add_player(player)
        expect(gameroom.roster).to include player
      end
      it "cannot add player to a game with the same name" do
        gameroom = RoundTable::WerewolfGameroom.new()
        player1 = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:'sean')
        gameroom.add_player(player1)

        expect(gameroom.roster).to include player1

        player2 = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:'sean')
        expect { gameroom.add_player(player2)}.to raise_error('Player already exists')

        player3 = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:'sEaN')
        expect { gameroom.add_player(player3)}.to raise_error('Player already exists')
      end
      it "narrator defaults to the first person in the room" do
        gameroom = RoundTable::WerewolfGameroom.new()
        player1 = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:'sean')
        player2 = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:'test')
        gameroom.add_player(player1)
        gameroom.add_player(player2)

        expect(gameroom.roster).to include player1
        expect(gameroom.roster).to include player2
        expect(gameroom.narrator).to equal(player1)
      end

      it "cannot add a player after game has started" do
        gameroom = createWerewolfValidGame()
        player3 = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:'late player')
        gameroom.start
        expect { gameroom.add_player(player3)}.to raise_error('Game has already started')
      end
    end
    describe "gameroom starts game" do
      it "changes game status hasStarted to true" do
        werewolfGame = createWerewolfValidGame()
        werewolfGame.start
        expect(werewolfGame.hasStarted).to be_truthy
      end
      it "can not start a game that is already started" do
        werewolfGame = createWerewolfValidGame()
        werewolfGame.start
        expect { werewolfGame.start }.to raise_error('Game has already started')
      end
      it "must have 7 people to start" do
        werewolfGame = createWerewolfValidGame(5)
        expect { werewolfGame.start }.to raise_error('Not enough players')
      end
      it "starts in first night" do
        werewolfGame = createWerewolfValidGame()
        werewolfGame.location = RoundTable::WerewolfGameroom::Location.new(day:12,isNight:false)
        werewolfGame.start
        expect(werewolfGame.location.day).to eq(0)
        expect(werewolfGame.location.night?).to be_truthy
      end
      it "send to day increaments day" do
        werewolfGame = createWerewolfValidGame()
        werewolfGame.start
        werewolfGame.sendToDay(werewolfGame.narrator.name)
        expect(werewolfGame.location.day).to eq(1)
        expect(werewolfGame.location.night?).to be_falsey
      end
      it "has a narrator" do
        werewolfGame = createWerewolfValidGame()
        werewolfGame.start
        expect(werewolfGame.narrator). to be_truthy
      end
      it "has active werewolves" do
        werewolfGame = createWerewolfValidGame()
        werewolfGame.start
        expect(werewolfGame.activeWerewolves). to be_truthy
      end
      it "has active villagers" do
        werewolfGame = createWerewolfValidGame()
        werewolfGame.start
        expect(werewolfGame.activeVillagers). to be_truthy
      end
      it "has active players" do
        werewolfGame = createWerewolfValidGame()
        werewolfGame.start
        expect(werewolfGame.activePlayers). to be_truthy
      end
      it "has 1 werewolf for 6 players" do
        werewolfGame1 = createWerewolfValidGame()
        werewolfGame1.start
        expect(werewolfGame1.activeWerewolves.length).to eq(1)
      end
      it "has 1 werewolf for 9 players" do
        werewolfGame2 = createWerewolfValidGame(8)
        werewolfGame2.start
        expect(werewolfGame2.activeWerewolves.length).to eq(1)
      end
      it "has 2 werewolves for 9 players" do
        werewolfGame2 = createWerewolfValidGame(9)
        werewolfGame2.start
        expect(werewolfGame2.activeWerewolves.length).to eq(2)
      end
      it "has 2 werewolves for 11 players" do
        werewolfGame2 = createWerewolfValidGame(11)
        werewolfGame2.start
        expect(werewolfGame2.activeWerewolves.length).to eq(2)
      end
      it "has 3 werewolves for 12 players" do
        werewolfGame1 = createWerewolfValidGame(12)
        werewolfGame1.start
        expect(werewolfGame1.activeWerewolves.length).to eq(3)
      end
      it "has 3 werewolves for 15 players" do
        werewolfGame2 = createWerewolfValidGame(15)
        werewolfGame2.start
        expect(werewolfGame2.activeWerewolves.length).to eq(3)
      end
    end
    describe "gameroom successfully executes gameplay" do
      describe "General Gameplay" do
        before(:each) do
          @werewolfGame = createWerewolfValidGame
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
            @werewolfGame = createWerewolfValidGame
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
            @werewolfGame = createWerewolfValidGame
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
            @werewolfGame = createWerewolfValidGame
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
            @werewolfGame = createWerewolfValidGame 10
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
            @werewolfGame = createWerewolfValidGame 10
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
            @werewolfGame = createWerewolfValidGame 10
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
            @werewolfGame = createWerewolfValidGame 15
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
            @werewolfGame = createWerewolfValidGame 15
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
            @werewolfGame = createWerewolfValidGame 15
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
    it "interacts with DB correctly", :database => true do
      gameroom = createWerewolfValidGame()
      gameroom.start
      simulateDay(gameroom)
      RoundTable::RoundTableGameDBService.save gameroom
      room = RoundTable::RoundTableGameDBService.get gameroom.id
      expect(room).to eq(gameroom)
    end
  end

  describe "Next Round", :nextRound => true do 
    describe "create a gameroom" do
      it "can create a new gameroom" do
        nextRoundGame = RoundTable::NextRoundGameroom.new
        expect(nextRoundGame).to exist
        expect(nextRoundGame.id).to satisfy('4 Random Char String') { |id|
          id.length == 4 and id.kind_of? String
        }
        expect(nextRoundGame.created.to_s).to eq(Time.now.getutc.to_s) 
        expect(nextRoundGame.roster).to be_empty
        expect(nextRoundGame.bets).to be_empty
        expect(nextRoundGame.options).to be_empty
      end
      it "can pass in params" do
        id = 'abcd'
        created = Time.now.getutc
        playerRoster = [RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:'sean')]
        bets = [createBet]
        options = [createOption]

        nextRoundGame = RoundTable::NextRoundGameroom.new(id:id, created:created,
        roster:playerRoster,bets:bets,options:options)
        expect(nextRoundGame).to exist
        expect(nextRoundGame.id).to eq(id)
        expect(nextRoundGame.created).to eq(created) 
        expect(nextRoundGame.roster).to eq(playerRoster)
        expect(nextRoundGame.bets).to eq(bets)
        expect(nextRoundGame.options).to eq(options)
      end
    end
    describe "player manipulation" do
      it "can create player with name" do
        name='sean'
        player = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:name)

        expect(player).to exist
        expect(player.name).to eq(name)
        expect(player.points).to eq(0)
        expect(player.betsPlaced).to be_empty
        expect(player.captain?).to be_falsey 
      end
      it "player names are trimmed when created" do
        name='  se an  '
        player = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:name)

        expect(player).to exist
        expect(player.name).to eq('se an')
        expect(player.captain?).to be_falsey 
        expect(player.betsPlaced).to be_empty
        expect(player.points).to eq(0)
      end
      it "can not create player without a name" do
        expect {RoundTable::NextRoundGameroom::NextRoundPlayer.new()}.to raise_error('Must set name for player')
      end
      it "can set params when creating player" do
        name='sean'
        isCaptain=true
        betsPlaced=[]
        points=0
        player = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:name,betsPlaced:betsPlaced,points:points,
          isCaptain:isCaptain)
        expect(player).to exist
        expect(player.name).to eq(name)
        expect(player.points).to eq(points)
        expect(player.betsPlaced).to eq(betsPlaced)
        expect(player.captain?).to eq(isCaptain) 
      end
      it "can add player to a game" do
        gameroom = RoundTable::NextRoundGameroom.new()
        player = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:'sean')
        gameroom.add_player(player)
        expect(gameroom.roster).to include player
      end
      it "cannot add player to a game with the same name" do
        gameroom = RoundTable::NextRoundGameroom.new()
        player1 = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:'sean')
        gameroom.add_player(player1)

        expect(gameroom.roster).to include player1

        player2 = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:'sean')
        expect { gameroom.add_player(player2)}.to raise_error('Player already exists')

        player3 = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:'sEaN')
        expect { gameroom.add_player(player3)}.to raise_error('Player already exists')
      end
      it "captain defaults to the first person in the room" do
        gameroom = RoundTable::NextRoundGameroom.new()
        player1 = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:'sean')
        player2 = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:'test')
        gameroom.add_player(player1)
        gameroom.add_player(player2)

        expect(gameroom.roster).to include player1
        expect(gameroom.roster).to include player2
        expect(gameroom.captain).to equal(player1)
      end
    end
    describe "options & bet lifecycle is functioning" do
      it "can create new options" do
        title = "Option Title"
        description = "Option Description"
        choiceA = "Choice A"
        choiceB = "Choice B"
        option = RoundTable::NextRoundGameroom::Option.new(title:title,description:description,choiceA:choiceA, choiceB:choiceB)

        expect(option.title).to eq(title)
        expect(option.description).to eq(description)
        expect(option.choiceA).to eq(choiceA)
        expect(option.choiceB).to eq(choiceB)
      end
      it "can add an option" do
        game = RoundTable::NextRoundGameroom.new
        option = RoundTable::NextRoundGameroom::Option.new(
          title:"Option Title",
          description:"Option Description",
          choiceA:"Choice A",
          choiceB:"Choice B")

        game.add_option option

        expect(game.options).not_to be_empty
        expect(game.options).to include(option)
      end
      it "can create new bets" do
        title = "Option Title"
        description = "Option Description"
        choiceA = "Choice A"
        choiceB = "Choice B"

        bet = RoundTable::NextRoundGameroom::Bet.new(title:title,description:description,choiceA:choiceA, choiceB:choiceB)


        expect(bet.id).not_to be_nil
        expect(bet.title).to eq(title)
        expect(bet.description).to eq(description)
        expect(bet.choiceA).to eq(choiceA)
        expect(bet.choiceB).to eq(choiceB)
        expect(bet.created).not_to be_nil
        expect(bet.state).not_to be_nil
        expect(bet.state).to eq("OPEN")
      end
      it "can create bet from option" do
        title = "Option Title"
        description = "Option Description"
        choiceA = "Choice A"
        choiceB = "Choice B"

        option = RoundTable::NextRoundGameroom::Option.new(title:title,description:description,choiceA:choiceA, choiceB:choiceB)

        bet = option.to_bet


        expect(bet.title).to eq(title)
        expect(bet.description).to eq(description)
        expect(bet.choiceA).to eq(choiceA)
        expect(bet.choiceB).to eq(choiceB)
        expect(bet.created).not_to be_nil
        expect(bet.state).not_to be_nil
        expect(bet.state).to eq("OPEN")
      end
      it "can open a bet" do
        game = RoundTable::NextRoundGameroom.new
        option1 = RoundTable::NextRoundGameroom::Option.new(
          title:"Option Title 1",
          description:"Option Description 1",
          choiceA:"Choice A 1",
          choiceB:"Choice B 1")

        option2 = RoundTable::NextRoundGameroom::Option.new(
          title:"Option Title 2",
          description:"Option Description 2",
          choiceA:"Choice A 2",
          choiceB:"Choice B 2")

        game.add_option option1

        game.add_option option2

        bet = game.open_bet option1

        expect(game.bets).to include(bet)
        expect(game.openBets).to include(bet)
        expect(game.frozenBets).not_to include(bet)
        expect(game.closedBets).not_to include(bet)
      end
      it "can freeze a bet" do
        game = RoundTable::NextRoundGameroom.new
        option1 = RoundTable::NextRoundGameroom::Option.new(
          title:"Option Title 1",
          description:"Option Description 1",
          choiceA:"Choice A 1",
          choiceB:"Choice B 1")

        option2 = RoundTable::NextRoundGameroom::Option.new(
          title:"Option Title 2",
          description:"Option Description 2",
          choiceA:"Choice A 2",
          choiceB:"Choice B 2")

        game.add_option option1

        game.add_option option2

        bet = game.open_bet option1

        game.freeze_bet bet.id

        expect(game.bets).to include(bet)
        expect(game.openBets).not_to include(bet)
        expect(game.frozenBets).to include(bet)
        expect(game.closedBets).not_to include(bet)
      end
      it "can close a bet" do
        game = RoundTable::NextRoundGameroom.new
        option1 = RoundTable::NextRoundGameroom::Option.new(
          title:"Option Title 1",
          description:"Option Description 1",
          choiceA:"Choice A 1",
          choiceB:"Choice B 1")

        option2 = RoundTable::NextRoundGameroom::Option.new(
          title:"Option Title 2",
          description:"Option Description 2",
          choiceA:"Choice A 2",
          choiceB:"Choice B 2")

        game.add_option option1

        game.add_option option2

        bet = game.open_bet option1

        game.close_bet bet.id

        expect(game.bets).to include(bet)
        expect(game.openBets).not_to include(bet)
        expect(game.frozenBets).not_to include(bet)
        expect(game.closedBets).to include(bet)
      end
    end
    describe "gameroom successfully executes gameplay" do
      it "can allow for players to enter selection on open bets" do
        nextRoundGameroom = createNextRoundValidGame 
        openBetsFromOptions(nextRoundGameroom, 2)
        
        player1 = nextRoundGameroom.roster[2]
        player2 = nextRoundGameroom.roster[4]

        bet = nextRoundGameroom.openBets[1]

        nextRoundGameroom.place_bet(player1.name,bet.id,bet.choiceA)

        expect(nextRoundGameroom.get_player(player1.name).betsPlaced).to include({id:bet.id,selection:bet.choiceA})
      end
      it "can not allow for non existant players to enter a selection on a open bet" do
        nextRoundGameroom = createNextRoundValidGame 
        openBetsFromOptions(nextRoundGameroom, 2)
        player1 = nextRoundGameroom.roster[2]

        bet = nextRoundGameroom.openBets[1]

        expect {nextRoundGameroom.place_bet("#{player1.name} #{rand(100)}",bet.id,bet.choiceA)}
        .to raise_error('Player must be in gameroom to place a bet')
      end
      it "can not allow for players to enter a invalid selection on a open bet" do
        nextRoundGameroom = createNextRoundValidGame 
        openBetsFromOptions(nextRoundGameroom, 2)
        player1 = nextRoundGameroom.roster[2]

        bet = nextRoundGameroom.openBets[1]

        expect {nextRoundGameroom.place_bet(player1.name,bet.id,"#{bet.choiceA} #{rand(100)}")}
        .to raise_error('Selection must be a choice to place a bet')      
      end
      it "can not allow for players to enter a selection on a non-existant bet" do
        nextRoundGameroom = createNextRoundValidGame 
        openBetsFromOptions(nextRoundGameroom, 2)
        player1 = nextRoundGameroom.roster[2]

        bet = nextRoundGameroom.openBets[1]

        expect {nextRoundGameroom.place_bet(player1.name,"#{bet.id} 000",bet.choiceA)}
        .to raise_error('Bet must exist to have a selection to be placed')
      end
      it "can not allow for players to enter selection on frozen bets" do
        nextRoundGameroom = createNextRoundValidGame 
        openBetsFromOptions(nextRoundGameroom, 2)
        player1 = nextRoundGameroom.roster[2]

        bet = nextRoundGameroom.openBets[1]

        nextRoundGameroom.freeze_bet(bet.id)

        expect {nextRoundGameroom.place_bet(player1.name,bet.id,bet.choiceA)}
        .to raise_error('Bet must be open to be placed')
      end
      it "can not allow for players to enter selection on closed bets" do
        nextRoundGameroom = createNextRoundValidGame 
        openBetsFromOptions(nextRoundGameroom, 2)
        player1 = nextRoundGameroom.roster[2]

        bet = nextRoundGameroom.openBets[1]
        nextRoundGameroom.close_bet(bet.id)

        expect {nextRoundGameroom.place_bet(player1.name,bet.id,bet.choiceA)}
        .to raise_error('Bet must be open to be placed')
      end
      it "can calculate a leaderboard - 1 bet & 1 player" do
        nextRoundGameroom = createNextRoundValidGame 
        openBetsFromOptions(nextRoundGameroom, 2)
        
        player1 = nextRoundGameroom.roster[2]
        player2 = nextRoundGameroom.roster[4]

        bet = nextRoundGameroom.openBets[1]

        nextRoundGameroom.place_bet(player1.name,bet.id,bet.choiceA)

        nextRoundGameroom.close_bet(bet.id,bet.choiceA)

        leaderboard = nextRoundGameroom.leaderboard

        expect(leaderboard[0][:name]).to eq(player1.name)
      end

      it "can calculate a leaderboard - 2 bet & 2 player" do
        nextRoundGameroom = createNextRoundValidGame 
        openBetsFromOptions(nextRoundGameroom, 3)
        
        player1 = nextRoundGameroom.roster[2]
        player2 = nextRoundGameroom.roster[4]

        bet1 = nextRoundGameroom.openBets[0]
        bet2 = nextRoundGameroom.openBets[1]
        bet3 = nextRoundGameroom.openBets[2]

        nextRoundGameroom.place_bet(player1.name,bet1.id,bet1.choiceA)
        nextRoundGameroom.place_bet(player2.name,bet2.id,bet2.choiceA)
        nextRoundGameroom.place_bet(player2.name,bet3.id,bet3.choiceA)

        nextRoundGameroom.close_bet(bet1.id,bet1.choiceA)

        leaderboard = nextRoundGameroom.leaderboard
        expect(leaderboard[0][:name]).to eq(player1.name)

        nextRoundGameroom.close_bet(bet2.id,bet2.choiceA)
        nextRoundGameroom.close_bet(bet3.id,bet3.choiceA)

        leaderboard = nextRoundGameroom.leaderboard
        expect(leaderboard[0][:name]).to eq(player2.name)
        expect(leaderboard[1][:name]).to eq(player1.name)
      end
    end
    it "interacts with DB correctly", :database => true do
      gameroom = createNextRoundValidGame()
      openBetsFromOptions(gameroom, 3)

      RoundTable::RoundTableGameDBService.save gameroom
      room = RoundTable::RoundTableGameDBService.get gameroom.id
      expect(gameroom).to eq(room)
    end
  end
end
