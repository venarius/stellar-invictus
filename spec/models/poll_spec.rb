require 'rails_helper'

describe Poll do
  context 'new poll' do
    describe 'attributes' do
      it { should respond_to :status }
      it { should respond_to :forum_link }
      it { should respond_to :question }
    end

    describe 'Enums' do
      it { should define_enum_for(:status).with_values([:active, :waiting, :in_progress, :finished]) }
    end

    describe 'Functions' do
      before(:each) do
        @poll = FactoryBot.create(:poll)
      end

      describe 'move_up' do
        it 'should move up' do
          @poll.move_up
          expect(@poll.reload.status).to eq("in_progress")
        end

        it 'should move up' do
          @poll.active!
          @poll.move_up
          expect(@poll.reload.status).to eq("waiting")
        end

        it 'should move up' do
          @poll.in_progress!
          @poll.move_up
          expect(@poll.reload.status).to eq("finished")
        end
      end
    end
  end
end
