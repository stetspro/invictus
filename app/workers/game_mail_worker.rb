class GameMailWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(recipient_id)
    user = User.find(recipient_id)
    # Tell user he received mail
    ActionCable.server.broadcast("player_#{user.id}", method: 'received_mail')
  end
end