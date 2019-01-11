require 'rails_helper'

RSpec.describe StructuresController, type: :controller do
  describe 'without login' do
    describe 'POST open_container' do
      it 'should redirect to new session path' do
        post :open_container
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST pickup_cargo' do
      it 'should redirect to new session path' do
        post :pickup_cargo
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST attack' do
      it 'should redirect to new session path' do
        post :attack
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST abandoned_ship' do
      it 'should redirect to new session path' do
        post :abandoned_ship
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  describe 'with login' do
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
      @container = FactoryBot.create(:structure, user: @user, location: @user.location)
      5.times do
        Item.create(structure: @container, loader: 'test', equipped: false)
      end
    end
    
    describe 'POST open_container' do
      it 'should render partial on success' do
        post :open_container, params: {id: @container.id}
        expect(response.status).to eq(200)
        expect(response).to render_template('structures/_cargocontainer')
      end
      
      it 'should render partial for wreck on success' do
        container = FactoryBot.create(:structure, location: @user.location, structure_type: 'wreck')
        post :open_container, params: {id: container.id}
        expect(response.status).to eq(200)
        expect(response).to render_template('structures/_cargocontainer')
      end
      
      it 'should fail if container not found' do
        post :open_container, params: {id: 2000}
        expect(response.status).to eq(400)
      end
      
      it 'should fail if container in other location' do
        @container.update_columns(location_id: Location.last.id)
        post :open_container, params: {id: @container.id}
        expect(response.status).to eq(400)
      end
      
      it 'should fail if user docked' do
        @user.update_columns(docked: true)
        post :open_container, params: {id: @container.id}
        expect(response.status).to eq(400)
      end
    end
    
    describe 'POST pickup_cargo' do
      it 'should pickup_cargo and not call police if same user' do
        post :pickup_cargo, params: {id: @container.id, loader: 'test'}
        expect(response.status).to eq(200)
        expect(@user.reload.active_spaceship.get_weight).to eq(5)
        expect(PoliceWorker.jobs.size).to eq(0)
        expect(Structure.count).to eq(0)
      end
      
      it 'should pickup all cargo and not call police if same user' do
        post :pickup_cargo, params: {id: @container.id}
        expect(response.status).to eq(200)
        expect(@user.reload.active_spaceship.get_weight).to eq(5)
        expect(PoliceWorker.jobs.size).to eq(0)
        expect(Structure.count).to eq(0)
      end
      
      it 'should pickup_cargo and call police if not same user' do
        user2 = FactoryBot.create(:user_with_faction)
        sign_in user2
        post :pickup_cargo, params: {id: @container.id, loader: 'test'}
        expect(response.status).to eq(200)
        expect(user2.reload.active_spaceship.get_weight).to eq(5)
        expect(Structure.count).to eq(0)
      end
      
      it 'should not pickup_cargo if docked' do
        @user.update_columns(docked: true)
        post :pickup_cargo, params: {id: @container.id, loader: 'test'}
        expect(response.status).to eq(400)
        expect(Structure.count).to eq(1)
      end
      
      it 'should not pickup_cargo user in other location' do
        @user.update_columns(location_id: Location.last.id)
        post :pickup_cargo, params: {id: @container.id, loader: 'test'}
        expect(response.status).to eq(400)
        expect(Structure.count).to eq(1)
      end
      
      it 'should not pickup_cargo if user full' do
        10.times do
          Item.create(spaceship: @user.active_spaceship, loader: 'test', equipped: false)
        end
        post :pickup_cargo, params: {id: @container.id, loader: 'test'}
        expect(response.status).to eq(400)
        expect(Structure.count).to eq(1)
      end
      
      it 'should only pickup cargo until user is full' do
        8.times do
          Item.create(spaceship: @user.active_spaceship, loader: 'test', equipped: false)
        end
        post :pickup_cargo, params: {id: @container.id, loader: 'test'}
        expect(response.status).to eq(200)
        expect(@user.reload.active_spaceship.get_weight).to eq(10)
        expect(Structure.count).to eq(1)
      end
    end
    
    describe 'POST attack' do
      it 'should destroy and not call police if own container' do
        post :attack, params: {id: @container.id}
        expect(response.status).to eq(200)
        expect(Structure.count).to eq(0)
        expect(PoliceWorker.jobs.size).to eq(0)
      end
      
      it 'should destroy and call police if not own container' do
        user2 = FactoryBot.create(:user_with_faction)
        sign_in user2
        post :attack, params: {id: @container.id}
        expect(response.status).to eq(200)
        expect(Structure.count).to eq(0)
      end
      
      it 'should not destroy if user in other location' do
        @container.update_columns(location_id: Location.last.id)
        post :attack, params: {id: @container.id}
        expect(response.status).to eq(400)
        expect(Structure.count).to eq(1)
      end
    end
    
    describe 'POST abandoned_ship' do
      before(:each) do
        @abandoned_ship = FactoryBot.create(:structure, location: @user.location, structure_type: 'abandoned_ship', riddle: 1)
      end
      
      it 'should render_template if user in same location as structure' do
        post :abandoned_ship, params: {id: @abandoned_ship.id}
        expect(response.status).to eq(200)
        expect(response).to render_template('structures/_abandoned_ship')
      end
      
      it 'should not render_template if user docked' do
        @user.update_columns(docked: true)
        post :abandoned_ship, params: {id: @abandoned_ship.id}
        expect(response.status).to eq(400)
      end
      
      it 'should not render_template if user in warp' do
        @user.update_columns(in_warp: true)
        post :abandoned_ship, params: {id: @abandoned_ship.id}
        expect(response.status).to eq(400)
      end
      
      it 'should not render_template if user in other location' do
        @user.update_columns(location_id: Location.last.id)
        post :abandoned_ship, params: {id: @abandoned_ship.id}
        expect(response.status).to eq(400)
      end
      
      it 'should fail if false answer given' do
        post :abandoned_ship, params: {id: @abandoned_ship.id, text: "Glub"}
        expect(response.status).to eq(400)
      end
      
      it 'should succeed if right answer given' do
        post :abandoned_ship, params: {id: @abandoned_ship.id, text: "9"}
        expect(response.status).to eq(200)
        expect(@user.location.structures.count).to eq(3)
      end
      
      it 'should fail if user in other location' do
        @user.update_columns(location_id: Location.last.id)
        post :abandoned_ship, params: {id: @abandoned_ship.id, text: "9"}
        expect(response.status).to eq(400)
        expect(@abandoned_ship.location.structures.count).to eq(2)
      end
    end
  end
end