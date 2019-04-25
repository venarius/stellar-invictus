# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  admin                  :boolean
#  avatar                 :string
#  banned                 :boolean
#  banned_until           :datetime
#  banreason              :string
#  bio                    :text
#  bounty                 :integer          default(0)
#  bounty_claimed         :integer          default(0)
#  chat_mod               :boolean          default(FALSE)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  corporation_role       :integer          default("recruit")
#  docked                 :boolean          default(FALSE)
#  donator                :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  equipment_worker       :boolean          default(FALSE)
#  family_name            :string
#  full_name              :string
#  in_warp                :boolean          default(FALSE)
#  is_attacking           :boolean
#  last_action            :datetime
#  logout_timer           :boolean          default(FALSE)
#  muted                  :boolean          default(FALSE)
#  name                   :string
#  online                 :integer          default(0)
#  provider               :string
#  remember_created_at    :datetime
#  reputation_1           :float            default(0.0)
#  reputation_2           :float            default(0.0)
#  reputation_3           :float            default(0.0)
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  route                  :string           default([]), is an Array
#  uid                    :string
#  units                  :integer          default(10)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  active_spaceship_id    :integer
#  corporation_id         :bigint(8)
#  faction_id             :bigint(8)
#  fleet_id               :bigint(8)
#  location_id            :bigint(8)
#  mining_target_id       :integer
#  npc_target_id          :integer
#  system_id              :bigint(8)
#  target_id              :integer
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_corporation_id        (corporation_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_faction_id            (faction_id)
#  index_users_on_family_name_and_name  (family_name,name) UNIQUE
#  index_users_on_fleet_id              (fleet_id)
#  index_users_on_location_id           (location_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_system_id             (system_id)
#
# Foreign Keys
#
#  fk_rails_...  (corporation_id => corporations.id)
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (fleet_id => fleets.id)
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (system_id => systems.id)
#

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
      it { should respond_to :missions }
      it { should respond_to :blueprints }
      it { should respond_to :banned }
      it { should respond_to :banned_until }
      it { should respond_to :banreason }
      it { should respond_to :admin }
      it { should respond_to :equipment_worker }
      it { should respond_to :logout_timer }
      it { should respond_to :donator }
      it { should respond_to :market_listings }
    end

    describe 'Relations' do
      it { should have_many :chat_messages }
      it { should have_many :spaceships }
      it { should have_many :structures }
      it { should have_many :friendships }
      it { should have_many :missions }
      it { should have_many :blueprints }
      it { should have_and_belong_to_many :chat_rooms }
      it { should have_many :market_listings }
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

      describe 'full_name' do
        it 'should not allow duplicate full_names' do
          user = create :user
          user2 = build :user, name: user.name, family_name: user.family_name
          expect(user2.valid?).to eq(false)
          user2.name = 'Peter'
          expect(user2.valid?).to eq(true)
          user2.name = user.name
          user2.family_name = 'Venkman'
          expect(user2.valid?).to eq(true)
        end
      end

      describe 'avatar' do
        it { should validate_presence_of :avatar }
        it { should allow_values('M_1', 'F_1').for :avatar }
        it { should_not allow_values('', nil, 'blub', '<script>Meme</script>').for :avatar }
      end
    end

    describe 'Functions' do
      let!(:user) { create :user_with_faction }

      describe 'full_name' do
        it 'should return full_name of user' do
          expect(user.full_name).to eq("#{user.name} #{user.family_name}".downcase.titleize)
        end

        it 'should update full_name when name or family_name changes' do
          user.update(name: 'Bob')
          expect(user.full_name.split.first).to eq('Bob')
        end
      end

      describe 'active_spaceship' do
        it 'should return current active spaceship' do
          expect(user.reload.active_spaceship).to eq(Spaceship.find(user.active_spaceship_id))
        end

        it 'should return nil if no active spaceship' do
          user.update(active_spaceship_id: nil)
          expect(user.reload.active_spaceship).to eq(nil)
        end
      end

      describe 'can be attacked' do
        it 'should return false if player in warp' do
          user.in_warp = true
          expect(user.can_be_attacked).to eq(false)
        end

        it 'should return false if player docked' do
          user.docked = true
          expect(user.can_be_attacked).to eq(false)
        end

        it 'should return true if player in space and not in warp' do
          expect(user.can_be_attacked).to eq(true)
        end

        it 'should return false if player in space and not in warp but not online' do
          user.update(online: 0)
          expect(user.can_be_attacked).to eq(false)
        end
      end

      describe 'target' do
        it 'should return current target of user' do
          enemy = create(:user_with_faction)
          user.update(target_id: enemy.id)
          expect(user.reload.target).to eq(enemy)
        end
      end

      describe 'npc_target' do
        it 'should return current npc_target of user' do
          enemy = create(:npc)
          user.update(npc_target_id: enemy.id)
          expect(user.reload.npc_target).to eq(enemy)
        end
      end

      describe 'die' do
        it 'increase job size' do
          user.die
          expect(PlayerDiedWorker.jobs.size).to eq(1)
        end
      end

      describe 'mining_target' do
        it 'should return asteroid if mining_target_id' do
          user.update(mining_target_id: Asteroid.first.id)
          expect(user.mining_target).to eq(Asteroid.first)
        end

        it 'should return nothing if mining_target_id not set' do
          expect(user.mining_target).to eq(nil)
        end
      end

      describe 'give_bounty' do
        it 'should give given user some bounty if user has bounty' do
          enemy = create(:user_with_faction)
          user.active_spaceship.update(name: 'Valadria')
          user.update(bounty: 1000)
          user.give_bounty(enemy)
          expect(enemy.units).not_to eq(10)
        end

        it 'should give given user some bounty if user has less bounty than worth bounty' do
          enemy = create(:user_with_faction)
          user.active_spaceship.update(name: 'Valadria')
          user.update(bounty: 1)
          user.give_bounty(enemy)
          expect(enemy.units).to eq(11)
        end
      end
    end
  end
end
