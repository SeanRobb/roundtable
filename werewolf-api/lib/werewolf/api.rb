require_relative "./api/version"
require 'aws-record'

module Werewolf
  class Gameroom
    attr_accessor :id, :created, :roster, :location, :hasStarted, :hasFinished, :villageWins
    def initialize(params = {})
      @id = params.fetch(:id, (0...4).map { (65 + rand(26)).chr }.join)
      @created = params.fetch(:created, Time.now.getutc)
      @roster = params.fetch(:roster, []).map { |player| 
        player = Player.from_json(player) unless player.is_a? (Player)
        player
      }
      # TODO clarify parsing of object
      @location = params.fetch(:location, Location.new())
      @location = Location.from_json(@location) unless @location.is_a? (Location)
      @hasStarted = params.fetch(:hasStarted, false)
      @hasFinished = params.fetch(:hasFinished, false)
      @villageWins = params.fetch(:villageWins, false)
    end
    def addPlayer(player)
      raise 'Player already exists' if roster.include? player
      raise 'Game has already started' if hasStarted
      player.isNarrator = true if roster.length == 0

      roster.push(player)
    end
    def start()
      # Validate a game can start
      raise 'Game has already started' if hasStarted
      raise 'Not enough players' if roster.length < 7

      @location = Location.new()

      roster.each(&:activate)
      narrator.deactivate

      case activePlayers.length
        when 0...9 
          targetWerewolves = 1
        when 9...12
          targetWerewolves = 2
        else
          targetWerewolves = 3
      end

      createNewWerewolf until activeWerewolves.length >= targetWerewolves 

      @hasStarted = true
    end

    def createNewWerewolf
      potentialWerewolves = @roster.reject { |player| player.isNarrator or player.isWerewolf } 
      potentialWerewolves[rand(potentialWerewolves.length-1)].isWerewolf = true
    end

    def sendToDay(callerName)
      raise "Only narrator can change day" unless callerName == narrator.name
      return nil unless @location.isNight

      #  Tally up votes
      playerToDeactivate = activeWerewolves.group_by(&:vote).find {|player,value| value.length >= votesNeeded}

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
      return nil if @location.isNight

      #  Tally up votes
      playerToDeactivate = activePlayers.group_by(&:vote).find {|player,value| value.length >= votesNeeded}

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
        isActive: player.isActive,
        isAsleepAtNight: false,
        ballot:[],
        vote: player.vote
      }
      if player.isWerewolf 
        role[:name] = "Werewolf"
        role[:description] = "At night werewolves vote for which villager to attack." +
        " Night votes must be unanimous. During the day werewolves must blend in" +
        " with the other villagers they can vote and debate like all other villagers." +
        " Villagers votes will need a majority during the day."
      elsif player.isNarrator
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

      if !player.isNarrator && !@location.isNight
        role[:ballot] = @roster.select {|player| (player.isActive && player.name != playerName)}.map {|player| player.name}
      end

      if player.isWerewolf && @location.isNight
        role[:ballot] = @roster.select {|player| (player.isActive && !player.isWerewolf && player.name != playerName)}.map {|player| player.name}
      end

      return role
    end
    def getVotes()
      voters = activePlayers
      voters = activeWerewolves if @location.isNight
      
      newTally = voters.reject{|player| player.vote.empty?}.group_by(&:vote).map {|player,votesFor| 
        { player=> votesFor.map(&:name) }
      }.reduce({}, :merge)

      {
        needs: votesNeeded,
        votes: newTally
      }
    end
    def narrator
      return roster.find { |player|
        player.isNarrator
      }
    end
    def activeWerewolves 
      return roster.select { |player|
        player.isWerewolf and player.isActive
      }
    end
    def activeVillagers
      return roster.select { |player|
        !player.isWerewolf and player.isActive
      }
    end
    def activePlayers
      return roster.select { |player|
        player.isActive
      }
    end
    def votesNeeded
      if @location.isNight then
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
    def exist?
      return !id.empty?
    end
    def to_model
      game = WerewolfGames.new()
      game.id=@id
      game.created=@created
      game.roster=@roster
      game.location=@location
      game.hasStarted=@hasStarted
      game.hasFinished=@hasFinished
      game.villageWins=@villageWins
      game
    end
    class Location
      attr_accessor :day, :isNight
      def initialize(params={})
        @day = params.fetch(:day, params.fetch('day',0))
        @isNight = params.fetch(:isNight, true)
      end
      def increment
        @day += 1 if @isNight
        @isNight = !@isNight
      end
      def exist?
        return day >= 0
      end
      def to_s
        "Day:#{day} isNight:#{isNight}"
      end
      def ==(other)
        self.day == other.day
        self.isNight == other.isNight
      end
      def self.from_json(parsedJSON)
        Location.new(day: parsedJSON.fetch("day", 0), isNight:parsedJSON.fetch("isNight", true))
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
    end
    class Player
      attr_accessor :name, :isNarrator, :isWerewolf, :isActive, :vote
      def initialize(params = {}) 
        raise 'Must set name for player' if params[:name].nil? or params[:name].empty?
        @name=params.fetch(:name).strip
        @isNarrator=params.fetch(:isNarrator,false)
        @isWerewolf=params.fetch(:isWerewolf,false)
        @isActive=params.fetch(:isActive,false)
        @vote=params.fetch(:vote, nil)
      end
      def activate 
        @isActive = true
      end
      def deactivate
        @isActive = false
      end
      def resetVote
        @vote=nil
      end
      def exist?
        !name.empty?
      end
      def self.from_json(parsedJSON)
        Player.new(name: parsedJSON.fetch("name"), 
        isNarrator:parsedJSON.fetch("isNarrator", false), isWerewolf: parsedJSON.fetch("isWerewolf",false),
        isActive: parsedJSON.fetch("isActive",false),vote: parsedJSON.fetch("vote",nil))
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
      def ==(other)
        self.name.downcase == other.name.downcase
      end
    end
  end
  # Class for DynamoDB table
  # This could also be another file you depend on locally.
  class WerewolfGames
    include Aws::Record
    set_table_name "WerewolfGames"
    string_attr :id, hash_key: true
    datetime_attr :created
    list_attr  :roster
    map_attr :location
    boolean_attr :hasStarted
    boolean_attr :hasFinished
    boolean_attr :villageWins
  end


  module WerewolfGameDBService
    def self.get(gameroomId)
      game = Werewolf::WerewolfGames.find(id:gameroomId)
      raise "Game not found" if game.nil?
      gameroom=Werewolf::Gameroom.new(game.to_h) unless game.nil?
      gameroom
    end
    def self.save(gameroom)
      gameroom.to_model.save(force:true)
    end
  end
end
