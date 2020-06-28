require "spec_helper"
require 'jwt'

RSpec.describe WerewolfAPI do
  include Rack::Test::Methods
  def app 
     WerewolfAPI
  end
  describe "Game Modification Endpoints" do  
    before do
      @token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6IlNlYW4iLCJpYXQiOjE1OTMyOTI0NjZ9.uFEUKXW6rUowmNH03DZHrCL39bJ9oI4E_CT8lyeX8rQ"
      @player = Werewolf::Gameroom::Player.new(name:"Sean")
      @player.isActive = true
      @player2 = Werewolf::Gameroom::Player.new(name:"Lauren")
      @player2.isActive = true
      @votes={@player.name => [@player2.name]}
      @stubGameroom = object_double(Werewolf::Gameroom.new, :addPlayer => [],
        :id => "SWSG", :submitVote => true, :start => true, :sendToDay => true,
        :sendToNight => true, :roster => [@player,@player2], :getRole => {
          name: "This Is My Role",
          description: "This is my Descripition"
        }, :getVotes => @votes)
      allow(Werewolf::Gameroom).to receive(:new).and_return(@stubGameroom)
      allow(Werewolf::WerewolfGameDBService).to receive(:save).with(@stubGameroom)
      allow(Werewolf::WerewolfGameDBService).to receive(:get).with(@stubGameroom.id).and_return(@stubGameroom)
    end    

    describe "Non player specific calls" do  
      context "Create gameroom" do    
        let(:response) {post "/gameroom"}

        it "returns game in the response" do
          expect(response.status).to eq 200
          expect(response.body).to eq(@stubGameroom.to_json)
        end
      end
      context "Get gameroom information" do
        let(:response) {get "/gameroom/#{@stubGameroom.id}"}
        it "returns gameroom" do
          expect(response.status).to eq 200
          expect(response.body).to eq({game:@stubGameroom,results:@votes,role:{}}.to_json)
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
          post "/gameroom/#{@stubGameroom.id}/vote", {vote: "Lauren"}.to_json
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
          post "/gameroom/#{@stubGameroom.id}/night"
        }
        it "returns gameroom" do
          expect(response.status).to eq 200
          expect(response.body).to eq(@stubGameroom.to_json)
        end
      end
      context "Send to day" do
        let(:response) {
          header 'Authorization', "Bearer #{@token}"
          post "/gameroom/#{@stubGameroom.id}/day"
        }
        it "returns gameroom" do
          expect(response.status).to eq 200
          expect(response.body).to eq(@stubGameroom.to_json)
        end
      end
    end
  end
end