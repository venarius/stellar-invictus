require 'rails_helper'

describe User do
    context 'new user' do
        describe 'attributes' do
            it { should respond_to :email }
            it { should respond_to :password }
            it { should respond_to :password_confirmation }
            it { should respond_to :name }
            it { should respond_to :family_name }
            it { should respond_to :faction }
        end
       
        describe 'Relations' do
            it { should belong_to :faction }
        end
        
        describe 'Validations' do
            describe 'email' do
                it { should validate_presence_of :email }
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
        end
    end
end