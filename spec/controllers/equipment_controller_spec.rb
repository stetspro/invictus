require 'rails_helper'

RSpec.describe EquipmentController, type: :controller do
  context 'with login' do
    before (:each) do
      @user = FactoryBot.create(:user_with_faction, docked: true)
      sign_in @user
    end
    
    describe 'POST update' do
      before(:each) do
        @equipment1 = FactoryBot.create(:item, loader: "equipment.weapons.laser_gatling", spaceship: @user.active_spaceship)
        @equipment2 = FactoryBot.create(:item, loader: "equipment.storage.small_black_hole", spaceship: @user.active_spaceship)
      end
      
      it 'should update equip status of items on main slot' do
        post :update, params: {ids: {"main": [@equipment1.id]}}
        expect(response.status).to eq(200)
        expect(@equipment1.reload.equipped).to be_truthy
      end
      
      it 'should update not equip status of items on utility slot if ship has no slots' do
        post :update, params: {ids: {"utility": [@equipment2.id]}}
        expect(response.status).to eq(400)
        expect(@equipment2.reload.equipped).to be_falsey
      end
      
      it 'should update equip status of items on utility slot if ship has slots' do
        ship = FactoryBot.create(:spaceship, name: "Valadria", user: @user)
        @user.update_columns(active_spaceship_id: ship.id)
        @equipment2.update_columns(spaceship_id: ship.id)
        post :update, params: {ids: {"utility": [@equipment2.id]}}
        expect(response.status).to eq(200)
        expect(@equipment2.reload.equipped).to be_truthy
      end
      
      it 'should not update equip status of items if not docked' do
        @user.update_columns(docked: false)
        post :update, params: {ids: {"main": [@equipment1.id]}}
        expect(response.status).to eq(400)
        expect(@equipment1.reload.equipped).to be_falsey
      end
      
      it 'should not update equip status of trying to fit wrong slot' do
        post :update, params: {ids: {"utility": [@equipment1.id]}}
        expect(response.status).to eq(400)
        expect(@equipment1.reload.equipped).to be_falsey
      end
      
      it 'should not update equip status of trying to fit wrong slot' do
        post :update, params: {ids: {"main": [@equipment2.id]}}
        expect(response.status).to eq(400)
        expect(@equipment2.reload.equipped).to be_falsey
      end
      
      it 'should fail on random params given' do
        post :update, params: {ids: {"blub": [@equipment2.id]}}
        expect(response.status).to eq(400)
        expect(@equipment2.reload.equipped).to be_falsey
      end
      
      it 'should fail if item is not in spaceship' do
        @equipment1.update_columns(spaceship_id: nil)
        post :update, params: {ids: {"main": [@equipment1.id]}}
        expect(response.status).to eq(400)
        expect(@equipment1.reload.equipped).to be_falsey
      end
      
      it 'should unequip items no listed in params' do
        post :update, params: {ids: {"main": [@equipment1.id]}}
        expect(response.status).to eq(200)
        expect(@equipment1.reload.equipped).to be_truthy
        post :update
        expect(response.status).to eq(200)
        expect(@equipment1.reload.equipped).to be_falsey
      end
    end
  end
end