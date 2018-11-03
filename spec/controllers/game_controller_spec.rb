require 'rails_helper'

RSpec.describe GameController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect_to login' do
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST warp' do
      it 'should redirect_to login' do
        post :warp
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST jump' do
      it 'should redirect_to login' do
        post :jump
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'GET local_players' do
      it 'should redirect_to login' do
        get :local_players
        expect(response.code).to eq('302')
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  context 'with login' do 
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'GET index' do
      it 'should redirect to faction when user has no faction' do
        @user = FactoryBot.create(:user)
        sign_in @user
        
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(factions_path)
      end
      
      it 'should render the game when user has faction' do
        get :index
        expect(response.code).to eq('200')
      end
      
      it 'should redirect to station when player is docked' do
        @user = FactoryBot.create(:user_with_faction, docked: true)
        sign_in @user
        
        get :index
        expect(response.code).to eq('302')
        expect(response).to redirect_to(station_path)
      end
    end
    
    describe 'POST warp' do
      it 'should do nothing with no or invalid id given' do
        post :warp, params: {id: 2022}
        expect(WarpWorker.jobs.size).to eq(0)
        expect(response.code).to eq('400')
      end
      
      it 'should do nothing with id of location in other system given' do
        @user.update_columns(system_id: System.first.id, location_id: System.first.locations.first.id)
        post :warp, params: {id: System.second.locations.first.id}
        expect(WarpWorker.jobs.size).to eq(0)
        expect(response.code).to eq('400')
      end
      
      it 'should start job with valid id given' do
        @user.update_columns(system_id: System.first.id, location_id: System.first.locations.first.id)
        post :warp, params: {id: System.first.locations.second.id}
        expect(WarpWorker.jobs.size).to eq(1)
        expect(response.code).to eq('200')
      end
    end
    
    describe 'POST jump' do
      it 'should do nothing when user not at jumpgate' do
        post :jump
        expect(JumpWorker.jobs.size).to eq(0)
        expect(response.code).to eq('400')
      end
      
      it 'should jump when user at jumpgate' do
        @user.update_columns(location_id: Location.where(system_id: @user.system.id, location_type: 'jumpgate').first.id)
        post :jump
        expect(JumpWorker.jobs.size).to eq(1)
        expect(response.code).to eq('200')
      end
      
      it 'should not jump when user at jumpgate but in warp' do
        @user.update_columns(location_id: Location.where(system_id: @user.system.id, location_type: 'jumpgate').first.id, in_warp: true)
        post :jump
        expect(JumpWorker.jobs.size).to eq(0)
        expect(response.code).to eq('400')
      end
    end
    
    describe 'GET local_players' do
      it 'should render local players' do
        get :local_players
        expect(response.code).to eq('200')
        expect(response).to render_template('game/_players')
      end
    end
    
    describe 'GET ship_info' do
      it 'should render ship info' do
        get :ship_info
        expect(response.code).to eq('200')
        expect(response).to render_template('game/_ship_info')
      end
    end
  end
end