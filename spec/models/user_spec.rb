require 'rails_helper'

describe User do
  context 'new user' do
    describe 'attributes' do
      it { should respond_to :email }
      it { should respond_to :password }
      it { should respond_to :password_confirmation }
      it { should respond_to :name }
      it { should respond_to :family_name }
      it { should respond_to :online }
      it { should respond_to :full_name }
      it { should respond_to :avatar }
      it { should respond_to :appear }
      it { should respond_to :disappear }
      it { should respond_to :faction }
      it { should respond_to :location }
      it { should respond_to :system }
      it { should respond_to :chat_messages }
      it { should respond_to :in_warp }
      it { should respond_to :spaceships }
      it { should respond_to :active_spaceship }
      it { should respond_to :structures }
      it { should respond_to :friendships }
      it { should respond_to :chat_rooms }
      it { should respond_to :bounty }
      it { should respond_to :bounty_claimed }
      it { should respond_to :route }
    end
   
    describe 'Relations' do
      it { should belong_to :faction }
      it { should belong_to :system }
      it { should belong_to :location }
      it { should have_many :chat_messages }
      it { should have_many :spaceships }
      it { should have_many :structures }
      it { should have_many :friendships }
      it { should have_and_belong_to_many :chat_rooms }
    end
    
    describe 'Validations' do
      describe 'email' do
        it { should validate_presence_of :email }
        it { should validate_uniqueness_of(:email).ignoring_case_sensitivity }
        it { should allow_values('test@example.org').for :email }
        it { should_not allow_values('', nil, 'test', '123').for :email }
      end
        
      describe 'password' do
        it { should validate_presence_of :password }
        it { should validate_length_of :password }
        it { should allow_values('test123').for :password }
        it { should_not allow_values('', nil, 'test', '123').for :password }
      end
      
      describe 'name' do
        it { should validate_presence_of :name }
        it { should validate_length_of :name }
        it { should allow_values('Gerno', 'Maximilian', 'Greg', 'Al').for :name }
        it { should_not allow_values('', nil, 'A', 'TestMeLongerThanTenChars', 'Gerno11', '111').for :name }
      end
      
      describe 'family_name' do
        it { should validate_presence_of :family_name }
        it { should validate_length_of :family_name }
        it { should allow_values('Utrigas', 'Gregory', 'Meyers', 'Al').for :family_name }
        it { should_not allow_values('', nil, 'A', 'TestMeLongerThanTenChars', 'Utrgas11', '111').for :family_name }
      end
      
      describe 'avatar' do
        it { should validate_presence_of :avatar }
        it { should allow_values('Utrigas', 'Gregory', 'Meyers', 'Al').for :avatar }
        it { should_not allow_values('', nil).for :avatar }
      end
    end
    
    describe 'Functions' do
      before(:each) do
        @user = FactoryBot.create(:user_with_faction)
      end
      
      describe 'full_name' do
        it 'should return full_name of user' do
          expect(@user.full_name).to eq("#{@user.name} #{@user.family_name}")
        end
      end
      
      describe 'appear' do
        it 'should set online to true' do
          @user.appear
          expect(AppearWorker.jobs.size).to eq(1)
        end
      end
      
      describe 'disappear' do
        it 'should set online to false' do
          @user.disappear
          expect(DisappearWorker.jobs.size).to eq(1)
        end
      end
      
      describe 'active_spaceship' do
        it 'should return current active spaceship' do
          expect(@user.reload.active_spaceship).to eq(Spaceship.find(@user.active_spaceship_id))
        end
        
        it 'should return nil if no active spaceship' do
          @user.update_columns(active_spaceship_id: nil)
          expect(@user.reload.active_spaceship).to eq(nil)
        end
      end
      
      describe 'can be attacked' do
        it 'should return false if player in warp' do
          @user.in_warp = true
          expect(@user.can_be_attacked).to eq(false)
        end
        
        it 'should return false if player docked' do
          @user.docked = true
          expect(@user.can_be_attacked).to eq(false)
        end
        
        it 'should return true if player in space and not in warp' do
          expect(@user.can_be_attacked).to eq(true)
        end
        
        it 'should return false if player in space and not in warp but not online' do
          @user.update_columns(online: 0)
          expect(@user.can_be_attacked).to eq(false)
        end
      end
      
      describe 'target' do
        it 'should return current target of user' do
          enemy = FactoryBot.create(:user_with_faction)
          @user.update_columns(target_id: enemy.id)
          expect(@user.reload.target).to eq(enemy)
        end
      end
      
      describe 'npc_target' do
        it 'should return current npc_target of user' do
          enemy = FactoryBot.create(:npc)
          @user.update_columns(npc_target_id: enemy.id)
          expect(@user.reload.npc_target).to eq(enemy)
        end
      end
      
      describe 'die' do
        it 'increase job size' do
          @user.die
          expect(PlayerDiedWorker.jobs.size).to eq(1)
        end
      end
      
      describe 'mining_target' do
        it 'should return asteroid if mining_target_id' do
          @user.update_columns(mining_target_id: Asteroid.first.id)
          expect(@user.mining_target).to eq(Asteroid.first)
        end
        
        it 'should return nothing if mining_target_id not set' do
          expect(@user.mining_target).to eq(nil)
        end
      end
    end
  end
end