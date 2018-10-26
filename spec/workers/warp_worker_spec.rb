require 'rails_helper'

RSpec.describe WarpWorker, type: :worker do
  describe 'perform' do
    it 'should change job size' do
      expect{WarpWorker.perform_async(1,1)}.to change(WarpWorker.jobs, :size).by(1) 
    end
  end
end
