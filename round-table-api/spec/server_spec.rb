require "spec_helper"
require 'jwt'

RSpec.describe RoundTableAPI do
  include Rack::Test::Methods
  def app 
     RoundTableAPI
  end
  describe "Game Modification Endpoints", :api => true do  
    describe "Werewolf API" do 
      before do
        @token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IlNlYW4iLCJpYXQiOjE1OTMyOTI0NjZ9.uFEUKXW6rUowmNH03DZHrCL39bJ9oI4E_CT8lyeX8rQ"
        @player = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:"Sean")
        @player.activate
        @player2 = RoundTable::WerewolfGameroom::WerewolfPlayer.new(name:"Lauren")
        @player2.activate
        @votes={@player.name => [@player2.name]}
        @stubGameroom = object_double(RoundTable::WerewolfGameroom.new, :type => "Werewolf", :add_player => [],
          :id => "SWSG", :submitVote => true, :start => true, :sendToDay => true,
          :sendToNight => true, :roster => [@player,@player2], :getRole => {
            name: "This Is My Role",
            description: "This is my Descripition"
          }, :getVotes => @votes)
        allow(RoundTable::WerewolfGameroom).to receive(:new).and_return(@stubGameroom)
        allow(RoundTable::RoundTableGameDBService).to receive(:save).with(@stubGameroom)
        allow(RoundTable::RoundTableGameDBService).to receive(:get).with(@stubGameroom.id).and_return(@stubGameroom)
      end    

      describe "Non player specific calls" do  
        context "Create gameroom" do    
          let(:response) {post "/gameroom", {type:"Werewolf"}.to_json}

          it "returns game in the response" do
            expect(response.status).to eq 200
            expect(response.body).to eq(@stubGameroom.to_json)
          end
        end
        context "Get gameroom information" do
          let(:response) {get "/gameroom/#{@stubGameroom.id}"}
          it "returns gameroom" do
            puts response.body
            expect(response.status).to eq 200
            expect(response.body).to eq({game:@stubGameroom,role:{},waitingroom:{"description":"You need at least 7 players to play","canStart":false},results:@votes}.to_json)
          end
        end
        context "Register to a gameroom" do
          let(:response) {post "/gameroom/#{@stubGameroom.id}/register" , {username: "Sean"}.to_json}
          it "returns gameroom and JWT" do
            expect(response.status).to eq 200
            expect(response.body).to include(@stubGameroom.to_json)
            expect(response.body).to include("\"bearer\"")
            data = JSON.parse response.body
          end
        end
      end

      describe "Player specific calls" do  
        context "Get gameroom information" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            get "/gameroom/#{@stubGameroom.id}"
          }
          it "returns gameroom" do
            expect(response.status).to eq 200
            data = JSON.parse(response.body)
            expect(response.body).to include(@stubGameroom.to_json)
            expect(data["results"]).to eq(@votes)
            expect(data["role"]["name"]).to eq("This Is My Role")
            expect(data["role"]["description"]).to eq("This is my Descripition")
          end
        end
        context "Submit vote" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            post "/gameroom/#{@stubGameroom.id}/werewolf/vote", {vote: "Lauren"}.to_json
          }
          it "returns gameroom" do
            expect(response.status).to eq 200
            expect(response.body).to eq(@stubGameroom.to_json)
          end
        end
        context "Start game" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            post "/gameroom/#{@stubGameroom.id}/start"
          }
          it "returns gameroom" do
            expect(response.status).to eq 200
            expect(response.body).to eq(@stubGameroom.to_json)
          end
        end
        context "Send to night" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            post "/gameroom/#{@stubGameroom.id}/werewolf/night"
          }
          it "returns gameroom" do
            expect(response.status).to eq 200
            expect(response.body).to eq({game:@stubGameroom, deactivatedPlayer:true}.to_json)
          end
        end
        context "Send to day" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            post "/gameroom/#{@stubGameroom.id}/werewolf/day"
          }
          it "returns gameroom" do
            expect(response.status).to eq 200
            expect(response.body).to eq({game:@stubGameroom, deactivatedPlayer:true}.to_json)
          end
        end
      end
    end
    describe "Next Round API" do
      before do
        @token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IlNlYW4iLCJpYXQiOjE1OTMyOTI0NjZ9.uFEUKXW6rUowmNH03DZHrCL39bJ9oI4E_CT8lyeX8rQ"
        @player = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:"Sean")
        @player.activate
        @player2 = RoundTable::NextRoundGameroom::NextRoundPlayer.new(name:"Lauren")
        @player2.activate
        @bet=createBet
        @leaderboard=[{name:"Sean", points:10}, {name:"Lauren", points:3}]
        @stubGameroom = object_double(RoundTable::NextRoundGameroom.new, :type => "Next Round",
          :add_player => nil,
          :place_bet => nil,
          :id => "SWSG", :roster => [@player,@player2],
          :bets => [@bet],
          :get_bet => @bet,
          :add_option=> @bet,
          :open_bet=> @bet,
          :freeze_bet=> @bet,
          :close_bet=> @bet,
          :leaderboard=>@leaderboard,
          :getRole => {
            name: "This Is My Role",
          })
        allow(RoundTable::NextRoundGameroom).to receive(:new).and_return(@stubGameroom)
        allow(RoundTable::RoundTableGameDBService).to receive(:save).with(@stubGameroom)
        allow(RoundTable::RoundTableGameDBService).to receive(:get).with(@stubGameroom.id).and_return(@stubGameroom)
      end  
      describe "Non player specific calls" do  
        context "Create gameroom" do    
          let(:response) {post "/gameroom", {type:"Next Round"}.to_json}

          it "returns game in the response" do
            expect(response.status).to eq 200
            expect(response.body).to eq(@stubGameroom.to_json)
          end
        end
        context "Get gameroom information" do
          let(:response) {get "/gameroom/#{@stubGameroom.id}"}
          it "returns gameroom" do
            expect(response.status).to eq 200
            expect(response.body).to eq({game:@stubGameroom,role:{},waitingroom:{"description":"You need at least 2 players to play","canStart":true},leaderboard:@leaderboard}.to_json)
          end
        end
        context "Register to a gameroom" do
          let(:response) {
            post "/gameroom/#{@stubGameroom.id}/register" ,
           {username: "Sean"}.to_json
          }
          it "returns gameroom and JWT" do
            expect(response.status).to eq 200
            expect(response.body).to include(@stubGameroom.to_json)
            expect(response.body).to include("\"bearer\"")
            data = JSON.parse response.body
          end
        end
      end
      describe "Player specific calls" do 
        context "Get gameroom information" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            get "/gameroom/#{@stubGameroom.id}"
          }
          it "returns gameroom" do
            expect(response.status).to eq 200
            data = JSON.parse(response.body)
            expect(response.body).to include(@stubGameroom.to_json)
            expect(response.body).to include(@leaderboard.to_json)
            expect(data["role"]["name"]).to eq("This Is My Role")
          end
        end
        context "Create new option to game" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            post "/gameroom/#{@stubGameroom.id}/next-round/option",
            {
              title: "Next touchdown",
              description: "Who will score the next touchdown?",
              choiceA: "Packers",
              choiceB: "Bears"
            }.to_json
          }
          it "creates a new option in the game" do 
            puts response.body
            expect(response.status).to eq 200
            data = JSON.parse(response.body)
            expect(response.body).to include(@stubGameroom.to_json)
          end
        end
        context "Create new bet to game" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            post "/gameroom/#{@stubGameroom.id}/next-round/bet",
            {
              title: "Next touchdown",
              description: "Who will score the next touchdown?",
              choiceA: "Packers",
              choiceB: "Bears"
            }.to_json
          }
          it "creates a new bet in the game" do 
            expect(response.status).to eq 200
            data = JSON.parse(response.body)
            expect(response.body).to include(@stubGameroom.to_json)
          end
        end
        context "Change bet state in game" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            put "/gameroom/#{@stubGameroom.id}/next-round/bet/#{@bet.id}/state",
            {
              state:"freeze"
            }.to_json
          }
          it "creates a new bet in the game" do 
            expect(response.status).to eq 200
            data = JSON.parse(response.body)
            expect(response.body).to include(@stubGameroom.to_json)
          end
        end
        context "select a choice in a bet" do
          let(:response) {
            header 'Authorization', "Bearer #{@token}"
            put "/gameroom/#{@stubGameroom.id}/next-round/bet/#{@bet.id}/selection",
            {
              selection: @bet.choiceA
            }.to_json
          }
          it "creates a new bet in the game" do 
            expect(response.status).to eq 200
            data = JSON.parse(response.body)
            expect(response.body).to include(@stubGameroom.to_json)
          end
        end
      end
    end
  end
end