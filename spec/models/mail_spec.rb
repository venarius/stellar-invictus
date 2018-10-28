require 'rails_helper'

describe Mail do
  context 'new mail' do
    describe 'attributes' do
      it { should respond_to :sender }
      it { should respond_to :recipient }
      it { should respond_to :header }
      it { should respond_to :body }
      it { should respond_to :units }
    end
   
    describe 'Relations' do
      it { should belong_to :sender }
      it { should belong_to :recipient }
    end
    
    describe 'Validations' do
      describe 'header' do
        it { should validate_presence_of :header }
        it { should validate_length_of :header }
        it { should allow_values('Test 123').for :header }
        it { should_not allow_values('', nil).for :header }
      end
        
      describe 'body' do
        it { should validate_presence_of :body }
        it { should validate_length_of :body }
        it { should allow_values('test123').for :body }
        it { should_not allow_values('', nil).for :body }
      end
    end
    
    describe 'Functions' do
      before(:each) do
        @user = FactoryBot.create(:user)
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
    end
  end
end
