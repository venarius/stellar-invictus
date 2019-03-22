require 'rails_helper'

describe Blueprint do
  context 'new blueprint' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :loader }
      it { should respond_to :efficiency }
    end

    describe 'Relations' do
      it { should belong_to :user }
    end
  end
end
