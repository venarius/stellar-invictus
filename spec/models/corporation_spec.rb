# == Schema Information
#
# Table name: corporations
#
#  id           :bigint(8)        not null, primary key
#  bio          :text
#  motd         :text
#  name         :string
#  tax          :float            default(0.0)
#  ticker       :string
#  units        :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :bigint(8)
#
# Indexes
#
#  index_corporations_on_chat_room_id  (chat_room_id)
#  index_corporations_on_name          (name) UNIQUE
#  index_corporations_on_ticker        (ticker) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#

require 'rails_helper'

describe Corporation do
  context 'new corporation' do
    describe 'attributes' do
      it { should respond_to :motd }
      it { should respond_to :tax }
      it { should respond_to :bio }
      it { should respond_to :users }
      it { should respond_to :corp_applications }
      it { should respond_to :finance_histories }
      it { should respond_to :units }
      it { should respond_to :name }
      it { should respond_to :ticker }
    end

    describe 'Relations' do
      it { should have_many :users }
      it { should have_many :finance_histories }
      it { should have_many :corp_applications }
    end
  end
end
