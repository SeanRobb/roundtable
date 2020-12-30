require_relative "./api/version"
require 'aws-record'
require 'securerandom'

module RoundTable
  class Gameroom
    attr_accessor :id, :type, :created, :hasStarted, :hasFinished
    def initialize(params = {})
      @id = params.fetch(:id, (0...4).map { (65 + rand(26)).chr }.join)
      @type = params.fetch(:type, "Werewolf")
      @created = params.fetch(:created, Time.now.getutc)
      @hasStarted = params.fetch(:hasStarted, false)
      @hasFinished = params.fetch(:hasFinished, false)
    end
    def to_model
      game = RoundTableGames.new()
      game.id=@id
      game.gameType=@type
      game.created=@created
      game.hasStarted=@hasStarted
      game.hasFinished=@hasFinished
      game
    end
    def exist?
      return !@id.empty?
    end
    def start 
      # Validate a game can start
      raise 'Game has already started' if hasStarted
      @hasStarted = true
    end
    class Player
      attr_accessor :name
      def initialize(params = {}) 
        raise 'Must set name for player' if params[:name].nil? or params[:name].empty?
        @name=params.fetch(:name).strip
        @isActive=params.fetch(:isActive,false)
      end
      def active?
        @isActive
      end
      def activate 
        @isActive = true
      end
      def deactivate
        @isActive = false
      end
      def exist?
        !name.empty?
      end
      def to_s
        "#{@name} - #{@isActive ? "Active": "Inactive"}"
      end
      def ==(other)
        self.name.downcase == other.name.downcase
      end
    end
  end
  class NextRoundGameroom < Gameroom
    attr_accessor :roster, :bets, :options
    def initialize(params={})
      params[:type] = "Next Round"
      super params
      @roster = params.fetch(:roster, [])
      @bets=params.fetch(:bets, [])
      @options=params.fetch(:options, [])

      gameInfo = params.fetch(:gameInfo, {}).transform_keys(&:to_sym)

      @bets=gameInfo[:bets] if gameInfo.has_key? :bets 
      @options=gameInfo[:options] if gameInfo.has_key? :options 

      @roster=gameInfo[:roster] if gameInfo.has_key? :roster 
      @roster = @roster.map { |player| 
        player = NextRoundPlayer.new(player.transform_keys(&:to_sym)) unless player.is_a? (NextRoundPlayer)
        player
      }
      @bets = @bets.map { |bet| 
        bet = Bet.new(bet.transform_keys(&:to_sym)) unless bet.is_a? (Bet)
        bet
      }
      @options = @options.map { |option| 
        option = Option.new(option.transform_keys(&:to_sym)) unless option.is_a? (Option)
        option
      }
    end
    def add_player(player)
      raise 'Player already exists' if roster.include? player
      player.makeCaptain if roster.length == 0

      roster.push(player)
    end
    def add_option(option)
      raise 'Option already exists' if options.include? option
      options.push(option)
    end
    def get_bet(betId)
      bets.find {|bet|
        bet.id == betId
      }
    end
    def get_player(playerName)
      roster.find {|player| 
        player.name == playerName
      }
    end
    def open_bet(option)
      bet = option.to_bet
      bets.push(bet)
      bet
    end
    def freeze_bet(betId)
      betToFreeze = get_bet betId
      betToFreeze.freeze unless betToFreeze.nil?
    end
    def close_bet(betId, correctChoice=nil)
      betToClose = get_bet betId
      betToClose.close unless betToClose.nil?
      unless correctChoice.nil? then
        betToClose.correctChoice = correctChoice
        correctPlayers = roster.select {|player| 
          bet = player.betsPlaced.find {|placed|
            placed[:id] == betId
          }
          next if bet.nil?
          next unless bet[:selection] == correctChoice
          player
        }
        correctPlayers.each {|player|
          player.points = player.points + 1
        }
      end
    end
    def place_bet(playerName, betId, selection)
      bet = get_bet betId

      raise "Bet must exist to have a selection to be placed" if bet.nil?
      raise "Selection must be a choice to place a bet" unless bet.choiceA == selection or bet.choiceB == selection
      raise "Bet must be open to be placed" unless bet.opened?

      player = get_player playerName
      raise "Player must be in gameroom to place a bet" if player.nil?

      # ensure to see if bet is already placed
      player.betsPlaced = player.betsPlaced.delete_if {|selectedBet| selectedBet[:id].eql? betId}
      player.betsPlaced.push({id:betId,selection:selection})
    end
    def getRole(playerName)
      player = @roster.find {|player| player.name == playerName}
      return {} unless player
      role ={
        player: player,
        name:"",
      }
      if player.captain? 
        role[:name] = "Captain"
      else
        role[:name] = "Player" 
      end

      return role
    end
    def leaderboard
      roster.map {|player| 
        {name:player.name, points:player.points}
      }.sort {|a1,a2| a2[:points] <=> a1[:points]}
    end
    def openBets
      bets.select(&:opened?)
    end
    def frozenBets
      bets.select(&:frozen?)
    end
    def closedBets
      bets.select(&:closed?)
    end
    def captain
      roster.find(&:captain?)
    end
    def ==(other)
      self.id == other.id
      self.created == other.created
      self.hasStarted == other.hasStarted
      self.hasFinished == other.hasFinished

      self.roster == other.roster
      self.bets == other.bets
      self.options == other.options
    end
    def to_model
      game = super
      gameInfo = Hash.new
      gameInfo[:roster]=@roster
      gameInfo[:bets]=@bets
      gameInfo[:options]=@options
      game.gameInfo = gameInfo

      game
    end
    def as_json(options={})
      {
        id: @id,
        type:@type,
        created: @created,
        roster: @roster,
        bets: @bets,
        options: @options,
        hasStarted: @hasStarted,
        hasFinished: @hasFinished,
      }
    end
    def to_json(*options)
      as_json(*options).to_json(*options)
    end
    def to_s
      "Id: #{id} Roster: #{roster} options: #{options}"
    end
    class Bet 
      attr_accessor :id, :title, :description, :choiceA, :choiceB, :created, :state, :correctChoice, :link
      def initialize(params={})
        @id=params.fetch(:id, SecureRandom.uuid)
        @title=params.fetch(:title).strip
        @description=params.fetch(:description).strip
        @choiceA=params.fetch(:choiceA).strip
        @choiceB=params.fetch(:choiceB).strip
        @created=params.fetch(:created,Time.now.getutc)
        @state=params.fetch(:state, "OPEN")
        @correctChoice=params.fetch(:correctChoice, "").strip
        @link=params.fetch(:link,"").strip
      end
      def open
        @state="OPEN"
      end
      def freeze
        @state="FROZEN"
      end
      def close
        @state="CLOSED"
      end
      def opened?
        @state == "OPEN"
      end
      def frozen?
        @state == "FROZEN"
      end
      def closed?
        @state == "CLOSED"
      end
      def ==(other)
        self.id == other.id
      end
      def to_h(*options)
        {
          :id => @id,
          :title => @title,
          :description => @description,
          :choiceA => @choiceA,
          :choiceB => @choiceB,
          :created => @created.to_i,
          :correctChoice => @correctChoice,
          :state => @state,
          :link=>@link,
        }
      end
      def as_json(options={})
        {
          id: @id,
          title: @title,
          created: @created,
          description: @description,
          choiceA: @choiceA,
          choiceB: @choiceB,
          correctChoice: @correctChoice,
          state: @state,
          link: @link,
        }
      end
      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end
    class Option
      attr_accessor :id, :title, :description, :choiceA, :choiceB, :link
      def initialize(params={})
        @id=params.fetch(:id, SecureRandom.uuid)
        @title=params.fetch(:title).strip
        @description=params.fetch(:description).strip
        @choiceA=params.fetch(:choiceA).strip
        @choiceB=params.fetch(:choiceB).strip
        @link=params.fetch(:link,"").strip
      end
      def to_bet
        RoundTable::NextRoundGameroom::Bet.new(
          title:@title,
          description:@description,
          choiceA:@choiceA,
          choiceB:@choiceB,
          link:@link
        )
      end
      def to_h(*options)
        {
          :id=>@id,
          :title => @title,
          :description => @description,
          :choiceA => @choiceA,
          :choiceB => @choiceB,
          :link=> @link,
        }
      end
      def as_json(options={})
        {
          id:@id,
          title: @title,
          description: @description,
          choiceA: @choiceA,
          choiceB: @choiceB,
          link: @link,
        }
      end
      def to_json(*options)
        as_json(*options).to_json(*options)
      end
      def ==(other)
        self.title.downcase == other.title.downcase &&
         self.description.downcase == other.description.downcase 
      end
    end
    class NextRoundPlayer < Player
      attr_accessor :betsPlaced, :points, :isCaptain
      def initialize(params = {}) 
        super params
        @points=params.fetch(:points,0).to_i
        @betsPlaced = params.fetch(:betsPlaced,[]).map{|betPlaced| betPlaced.transform_keys(&:to_sym)}
        @isCaptain = params.fetch(:isCaptain, false)
      end
      def captain?
        @isCaptain
      end
      def makeCaptain
        @isCaptain = true
      end
      def makePlayer
        @isCaptain = false
      end
      def to_h(*options)
        {
          :name => @name,
          :isCaptain => @isCaptain,
          :betsPlaced => @betsPlaced,
          :points => @points,
        }
      end
      def as_json(options={})
        {
          name: @name,
          isCaptain: @isCaptain,
          betsPlaced: @betsPlaced,
          points: @points,
        }
      end
      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end
  end
  # TODO refactor to snake case functions
  class WerewolfGameroom < Gameroom
    attr_accessor :roster, :location, :villageWins
    def initialize(params = {})
      params[:type] = "Werewolf"
      super params

      @roster = params.fetch(:roster, [])
      @location = params.fetch(:location, Location.new())
      @villageWins = params.fetch(:villageWins, false)

      gameInfo = params.fetch(:gameInfo, {}).transform_keys(&:to_sym)

      @roster=gameInfo[:roster] if gameInfo.has_key? :roster 
      @location=gameInfo[:location] if gameInfo.has_key? :location 
      @villageWins=gameInfo[:villageWins] if gameInfo.has_key? :villageWins 
      
      @roster = @roster.map { |player| 
        player = WerewolfPlayer.from_json(player) unless player.is_a? (WerewolfPlayer)
        player
      }
      # TODO clarify parsing of object
      @location = Location.from_json(@location) unless @location.is_a? (Location)
    end
    def add_player(player)
      raise 'Player already exists' if roster.include? player
      raise 'Game has already started' if @hasStarted
      player.makeNarrator if roster.length == 0

      roster.push(player)
    end
    def start()
      # Validate a game can start
      raise 'Game has already started' if hasStarted
      raise 'Not enough players' if roster.length < 7

      @location = Location.new()

      roster.each{ |player| 
        player.activate unless player.narrator?
        player.makeVillager unless player.narrator?
      }

      case activePlayers.length
        when 0..8 
          targetWerewolves = 1
        when 9..11
          targetWerewolves = 2
        else
          targetWerewolves = 3
      end

      createNewWerewolf until activeWerewolves.length >= targetWerewolves 

      @hasStarted = true
    end
    def createNewWerewolf
      potentialWerewolves = @roster.reject { |player| player.narrator? or player.werewolf? } 
      potentialWerewolves[rand(potentialWerewolves.length-1)].makeWerewolf
    end
    def sendToDay(callerName)
      raise "Only narrator can change day" unless callerName == narrator.name
      return nil unless @location.night?

      #  Tally up votes
      tally = activeWerewolves.map(&:vote).tally
      playerToDeactivate = tally.find {|player,votes| votes >= votesNeeded}
      player = roster.find { |player| player.name == playerToDeactivate.first} unless playerToDeactivate.nil?
      
      player.deactivate unless player.nil?

      gameOver?
      
      # Prep for Day 
      activeWerewolves.each(&:resetVote)      
      @location.increment 

      player
    end
    def sendToNight(callerName)
      raise "Only narrator can change day" unless callerName == narrator.name
      return nil if @location.night?

      #  Tally up votes
      tally = activePlayers.map(&:vote).tally
      playerToDeactivate = tally.find {|player,votes| votes >= votesNeeded}
      player = roster.find { |player| player.name == playerToDeactivate.first} unless playerToDeactivate.nil?
      
      player.deactivate unless player.nil?

      gameOver?

      #Prep for Night
      activePlayers.each(&:resetVote)  
      @location.increment

      player
    end
    def submitVote(params={})
      player = activePlayers.find {|activePlayer| activePlayer.name == params.fetch(:player)}
      raise "Only active players can vote" if player.nil?
      voteFor = activePlayers.find {|activePlayer| activePlayer.name == params.fetch(:voteFor)}
      raise "Only active players can be voted for" if voteFor.nil?
      player.vote = voteFor.name
    end
    def getRole(playerName)
      player = @roster.find {|player| player.name == playerName}
      return {} unless player
      role ={
        player: player,
        name:"",
        description:"",
        isActive: player.active?,
        isAsleepAtNight: false,
        ballot:[],
        vote: player.vote
      }
      if player.werewolf? 
        role[:name] = "Werewolf"
        role[:description] = "At night werewolves vote for which villager to attack." +
        " Night votes must be unanimous. During the day werewolves must blend in" +
        " with the other villagers they can vote and debate like all other villagers." +
        " Villagers votes will need a majority during the day."
      elsif player.narrator?
        role[:name] = "Narrator" 
        role[:description] = "The narrator will be the story teller of this village." +
        " You control when days change and will inform players when to go to sleep" +
        " and wake up."
      else 
        role[:name] = "Villager"
        role[:description] = "Villagers work hard to settle their new town. Hidden amonst this group of villagers their are werewolves."+
        " For the success of the town it is critical to remove all of the werewolves. Every night the werewolves hunt villagers and "+
        "every day the villagers vote who they believe is a werewolf. The vote is based on a majority. If the villagers successfully "+
        "vote for a werewolf then that werewolf will be removed from the village never to return. It is a race against time, will the "+
        "villagers find and remove all of the werewolves before the werewolves attack all of the villagers? Do your best to decide who "+
        "you can trust."
        role[:isAsleepAtNight] = true
      end

      if !player.narrator? && !@location.night?
        role[:ballot] = @roster.select {|player| (player.active? && player.name != playerName)}.map {|player| player.name}
      end

      if player.werewolf? && @location.night?
        role[:ballot] = @roster.select {|player| (player.active? && !player.werewolf? && player.name != playerName)}.map {|player| player.name}
      end

      return role
    end
    def getVotes
      voters = activePlayers
      voters = activeWerewolves if @location.night?
      
      votes = voters.reject{|player| player.vote.empty?}.group_by(&:vote).map {|player,votesFor| 
         [player, votesFor.map(&:name)]
      }.to_h

      {
        needs: votesNeeded,
        votes: votes
      }
    end
    def narrator
      roster.find(&:narrator?)
    end
    def activeWerewolves 
      activePlayers.select(&:werewolf?)
    end
    def activeVillagers
      activePlayers.select(&:villager?)
    end
    def activePlayers
      roster.select(&:active?)
    end
    def votesNeeded
      if @location.night? then
        activeWerewolves.length 
      else
        (activePlayers.length/2).floor + 1
      end
    end
    def gameOver?
      @hasFinished = true if activeWerewolves.length == 0 or activeVillagers.length == 0
      @villageWins = true if activeWerewolves.length == 0 
      @villageWins = false if activeVillagers.length == 0 
      @hasFinished
    end
    def to_s
      "Id: #{id} Roster: #{roster} V Wins: #{villageWins}"
    end
    def as_json(options={})
      {
        id: @id,
        created: @created,
        type:@type,
        roster: @roster,
        location: @location,
        hasStarted: @hasStarted,
        hasFinished: @hasFinished,
        villageWins: @villageWins
      }
    end
    def to_json(*options)
      as_json(*options).to_json(*options)
    end

    def to_model
      game = super
      gameInfo = Hash.new
      gameInfo[:roster]=@roster
      gameInfo[:location]=@location
      gameInfo[:villageWins]=@villageWins
      game.gameInfo = gameInfo

      game
    end

    def ==(other)
      self.id == other.id
      self.created == other.created
      self.hasStarted == other.hasStarted
      self.hasFinished == other.hasFinished

      self.roster == other.roster
      self.location == other.location
      self.villageWins == other.villageWins
    end
    def hash
      id.hash
    end

    class Location
      attr_accessor :day
      def initialize(params={})
        @day = params.fetch(:day, params.fetch('day',0))
        @isNight = params.fetch(:isNight, true)
      end
      def increment
        @day += 1 if @isNight
        @isNight = !@isNight
      end
      def night?
        @isNight
      end
      def exist?
        return day >= 0
      end
      def to_s
        "Day:#{day} isNight:#{isNight}"
      end
      def self.from_json(parsedJSON)
        Location.new(parsedJSON.transform_keys(&:to_sym))
      end
      def as_json(options={})
        {
          day: @day.to_i,
          isNight: @isNight,
        }
      end
      def to_json(*options)
        as_json(*options).to_json(*options)
      end
      def to_h(*options)
        {:day=>@day,:isNight=>@isNight}
      end
      def ==(other)
        self.day == other.day
        self.night? == other.night?
      end
    end

    class WerewolfPlayer < Player
      attr_accessor :vote
      def initialize(params = {}) 
        super params
        @isNarrator=params.fetch(:isNarrator,false)
        @isWerewolf=params.fetch(:isWerewolf,false)
        @vote=params.fetch(:vote, nil)
      end

      def makeWerewolf
        @isWerewolf = true
        @isNarrator = false
      end
      def makeVillager
        @isWerewolf = false
        @isNarrator = false
      end
      def werewolf?
        @isWerewolf
      end
      def makeNarrator
        @isNarrator = true
      end
      def narrator?
        @isNarrator
      end
      def villager?
        not (narrator? || werewolf?)
      end
      def resetVote
        @vote=nil
      end

      def self.from_json(parsedJSON)
        WerewolfPlayer.new(parsedJSON.transform_keys(&:to_sym))
      end
      def to_s
        "#{name} - #{isWerewolf ? "Werewolf": (isNarrator ? "Narrator": "Villager")} - #{isActive ? "Active": "Inactive"} - Voting For: #{vote}"
      end
      def as_json(options={})
        hashedVote = '' if @vote.nil?
        hashedVote = @vote unless @vote.nil?
        {
          name: @name,
          isNarrator: @isNarrator,
          isWerewolf: @isWerewolf,
          isActive: @isActive,
          vote: hashedVote,
        }
      end
      def to_json(*options)
        as_json(*options).to_json(*options)
      end
      def to_h(*options)
        hashedVote = '' if @vote.nil?
        hashedVote = @vote unless @vote.nil?
        {
          :name => @name,
          :isNarrator => @isNarrator,
          :isWerewolf => @isWerewolf,
          :isActive => @isActive,
          :vote => hashedVote,
        }
      end

    end
  end
  # Class for DynamoDB table
  # This could also be another file you depend on locally.
  class RoundTableGames
    include Aws::Record
    set_table_name "RoundTableGames"
    string_attr :id, hash_key: true
    string_attr :gameType
    datetime_attr :created
    boolean_attr :hasStarted
    boolean_attr :hasFinished

    map_attr :gameInfo
  end

  module RoundTableGameDBService
    def self.get(gameroomId)
      game = RoundTable::RoundTableGames.find(id:gameroomId)
      return nil if game.nil?
      return nil if game.nil?
      gameroom=RoundTable::WerewolfGameroom.new(game.to_h) if game.gameType == "Werewolf"
    
      gameroom=RoundTable::NextRoundGameroom.new(game.to_h) if game.gameType == "Next Round"
      gameroom
    end
    def self.save(gameroom)
      gameroom.to_model.save(force:true)
    end
  end
end
