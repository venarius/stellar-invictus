require 'rails_helper'

describe CorpApplication do
  context 'new corp_application' do
    describe 'attributes' do
      it { should respond_to :user }
      it { should respond_to :corporation }
      it { should respond_to :application_text }
    end

    describe 'Relations' do
      it { should belong_to :user }
      it { should belong_to :corporation }
    end
  end
end
