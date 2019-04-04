# == Schema Information
#
# Table name: missions
#
#  id                  :bigint(8)        not null, primary key
#  agent_avatar        :string
#  agent_name          :string
#  deliver_to          :integer
#  difficulty          :integer
#  enemy_amount        :integer
#  faction_bonus       :float
#  faction_malus       :float
#  mission_amount      :integer
#  mission_loader      :string
#  mission_status      :integer
#  mission_type        :integer
#  reward              :integer
#  text                :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  faction_id          :bigint(8)
#  location_id         :bigint(8)
#  mission_location_id :integer
#  user_id             :bigint(8)
#
# Indexes
#
#  index_missions_on_faction_id           (faction_id)
#  index_missions_on_location_id          (location_id)
#  index_missions_on_mission_location_id  (mission_location_id)
#  index_missions_on_mission_type         (mission_type)
#  index_missions_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (faction_id => factions.id)
#  fk_rails_...  (location_id => locations.id)
#  fk_rails_...  (user_id => users.id)
#

require 'rails_helper'

describe Mission do
  context 'new mission' do
    describe 'attributes' do
      it { should respond_to :location }
      it { should respond_to :mission_location }
      it { should respond_to :agent_name }
      it { should respond_to :agent_avatar }
      it { should respond_to :faction }
      it { should respond_to :text }
      it { should respond_to :reward }
      it { should respond_to :deliver_to }
      it { should respond_to :user }
      it { should respond_to :difficulty }
      it { should respond_to :mission_type }
      it { should respond_to :mission_status }
      it { should respond_to :enemy_amount }
      it { should respond_to :mission_loader }
      it { should respond_to :mission_amount }
      it { should respond_to :faction_bonus }
      it { should respond_to :faction_malus }
    end

    describe 'Relations' do
      it { should belong_to :faction }
      it { should belong_to :location }

      it { should have_one :mission_location }
    end

    describe 'Enums' do
      it { should define_enum_for(:mission_type).with_values([:tutorial, :delivery, :combat, :mining, :market, :vip]) }
       it { should define_enum_for(:mission_status).with_values([:offered, :active, :failed, :completed]) }
       it { should define_enum_for(:difficulty).with_values([:easy, :medium, :hard]) }
    end

  end
end
