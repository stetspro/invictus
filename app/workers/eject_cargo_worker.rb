class EjectCargoWorker
  # This worker will be run when the user ejects cargo
  
  include Sidekiq::Worker
  sidekiq_options :retry => false
   
  def perform(user_id, loader, amount)
    user = User.find(user_id)
    
    
    items = Item.where(loader: loader, spaceship: user.active_spaceship, equipped: false, active: false)
    if items.present? and amount
      structure = Structure.create(structure_type: 'container', location: user.location, user: user)
      
      if amount == items.count
        items.update_all(structure_id: structure.id, user_id: nil, spaceship_id: nil, equipped: false)
      else
        items.first(amount).each do |item|
          item.update_columns(structure_id: structure.id, user_id: nil, spaceship_id: nil, equipped: false)
        end
      end
      
      # Tell everyone at location to refresh players and log the eject
      ActionCable.server.broadcast("location_#{user.location.id}", method: 'player_appeared')
      ActionCable.server.broadcast("location_#{user.location.id}", method: 'log', text: I18n.t('log.user_ejected_cargo', user: user.full_name) )
      
      # Tell user to update player info
      ActionCable.server.broadcast("player_#{user.id}", method: 'refresh_player_info')
    end
  end
end