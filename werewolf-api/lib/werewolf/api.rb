require_relative "./api/version"

module Werewolf
  class Gameroom
    attr_accessor :id, :created, :roster, :location, :hasStarted, :hasFinished, :villigeWins

    def initialize(params = {})
      @id = params.fetch(:id, (0...4).map { (65 + rand(26)).chr }.join)
      @created = params.fetch(:created, Time.now.getutc)
      @roster = params.fetch(:roster, [])
      @location = params.fetch(:location, Location.new())
      @hasStarted = params.fetch(:hasStarted, false)
      @hasFinished = params.fetch(:hasFinished, false)
      @villigeWins = params.fetch(:hasFinished, false)
    end

    def addPlayer(player)
      raise 'Player already exists' if roster.include? player
      raise 'Game has already started' if hasStarted
      player.isNarrator = true if roster.length == 0

      roster.push(player)
    end

    def start()
      raise 'Game has already started' if hasStarted
      raise 'Not enough players' if roster.length < 7
      @location = Location.new() unless location == Location.new()

      newlyActivePlayers = roster.select { |player| !player.isNarrator } 
      .map {|player| 
        player.isActive = true
        player
      }

      narrator.isActive = false

      targetWerewolves = 1
      targetWerewolves = 2 if newlyActivePlayers.length > 8 and newlyActivePlayers.length < 12
      targetWerewolves = 3 if newlyActivePlayers.length > 11 

      until activeWerewolves.length >= targetWerewolves do
        newlyActivePlayers[rand(newlyActivePlayers.length-1)].isWerewolf = true
      end

      @hasStarted = true
    end

    def sendToDay(callerName)
      raise "Only narrator can change day" unless callerName == narrator.name
      return nil if @location.isNight == false
      @location.isNight = false

      @location.day += 1

      tally = Hash.new(0)
      activeWerewolves.map{|player| player.vote}.each {|vote| 
        tally[vote]+=1 unless vote.nil?
        vote = nil
      }
      playerToDeactivate = tally.find {|player, value| value >= activeWerewolves.length}
      # No Player has enough votes to be deactivated
      return nil if playerToDeactivate.nil?
      player = playerToDeactivate.first

      player.isActive = false

      @hasFinished = true if activeVillagers.length == 0
      @villigeWins = false if activeVillagers.length == 0 

      player
    end

    def sendToNight(callerName)
      raise "Only narrator can change day" unless callerName == narrator.name
      return nil if @location.isNight == true
      @location.isNight = true

      tally = Hash.new(0)
      activePlayers.map{|player| player.vote}.each {|vote| 
        tally[vote]+=1 unless vote.nil?
        vote = nil
      }
      majorityNeeded = (activePlayers.length/2).floor
      playerToDeactivate = tally.find {|player, value| value > majorityNeeded}
      # No Player has enough votes to be deactivated
      return nil if playerToDeactivate.nil?
      player = playerToDeactivate.first

      player.isActive = false


      @hasFinished = true if activeWerewolves.length == 0 or activeVillagers.length == 0
      @villigeWins = true if activeWerewolves.length == 0 
      @villigeWins = false if activeVillagers.length == 0 

      player
    end

    def submitVote(params={})
      player = activePlayers.find {|activePlayer| activePlayer.name == params.fetch(:player)}
      raise "Only active players can vote" if player.nil?
      voteFor = activePlayers.find {|activePlayer| activePlayer.name == params.fetch(:voteFor)}
      raise "Only active players can be voted for" if voteFor.nil?
      player.vote = voteFor
    end
    
    def narrator()
      return roster.find { |player|
        player.isNarrator
      }
    end

    def activeWerewolves() 
      return roster.select { |player|
        player.isWerewolf and player.isActive
      }
    end

    def activeVillagers()
      return roster.select { |player|
        !player.isWerewolf and player.isActive
      }
    end

    def activePlayers()
      return roster.select { |player|
        player.isActive
      }
    end

    def to_s
      print "making string"
      "#{id} #{roster}"
    end


    def as_json(options={})
      {
        id: @id,
        created: @created,
        roster: @roster,
        location: @location,
        hasStarted: @hasStarted,
        hasFinished: @hasFinished,
        villigeWins: @villigeWins
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end

    # def to_json
    #   { :id => id, :created => created, :roster => roster, :location => location, :hasStarted => hasStarted, :hasFinished => hasFinished, :villigeWins => villigeWins}.to_json
    # end

    def exist?
      return !id.empty?
    end

    class Location
      attr_accessor :day, :isNight
      def initialize(params={})
        @day = params.fetch(:day, 0)
        @isNight = params.fetch(:isNight, true)
      end
      def exist?
        return day >= 0
      end
      def ==(other)
        self.day == other.day
        self.isNight == other.isNight
      end
      def as_json(options={})
        {
          day: @day,
          isNight: @isNight,
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
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
      def exist?
        !name.empty?
      end
      def to_s
        "#{name}"
      end
      def as_json(options={})
        {
          name: @name,
          isNarrator: @isNarrator,
          isWerewolf: @isWerewolf,
          isActive: @isActive,
          vote: @vote.name,
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
      def ==(other)
        self.name.downcase == other.name.downcase
      end
    end
  end
end
