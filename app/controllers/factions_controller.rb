class FactionsController < ApplicationController
  before_action :redirect_if_faction, except: [:choose_faction]
  skip_before_action :redirect_if_no_faction
  
  def index
    @factions = Faction.all
  end
  
  def choose_faction
    if !current_user.faction
      faction = Faction.find(params[:id]) rescue nil
      if faction and current_user.update_columns(faction_id: faction.id, location_id: faction.location.id, system_id: faction.location.system.id)
        spaceship = Spaceship.create(user_id: current_user.id, name: 'Nano', image: 'nano', hp: 100, armor: 10, power: 10, defense: 10, price: 0)
        current_user.update_columns(active_spaceship_id: spaceship.id)
        redirect_to game_path
      else
        flash[:error] = I18n.t('errors.something_went_wrong')
        redirect_to factions_path
      end
    else
      redirect_to game_path
    end
  end
  
  protected
  
  def redirect_if_faction
    redirect_to game_path if current_user.faction
  end
end