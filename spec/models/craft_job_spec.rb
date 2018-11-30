require 'rails_helper'

describe CraftJob do
  context 'new craft_job' do
    describe 'attributes' do
      it { should respond_to :loader }
      it { should respond_to :completion }
      it { should respond_to :user }
      it { should respond_to :location }
    end
   
    describe 'Relations' do
      it { should belong_to :user }
      it { should belong_to :location }
    end
  end
end
