require 'rails_helper'

describe Jumpgate do
  context 'new jumpgate' do
    describe 'attributes' do
      it { should respond_to :origin }
      it { should respond_to :destination }
      it { should respond_to :traveltime }
    end

    describe 'Relations' do
      it { should belong_to :origin }
      it { should belong_to :destination }
    end
  end

  describe 'Validations' do
    describe 'traveltime' do
      it { should validate_presence_of :traveltime }
      it { should allow_values(10, 20, 30).for :traveltime }
      it { should_not allow_values('', nil, 'A', 'TestMeLongerThanTenChars', 'Utrgas11').for :traveltime }
    end
  end
end
