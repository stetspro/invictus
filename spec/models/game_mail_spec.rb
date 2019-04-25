# == Schema Information
#
# Table name: game_mails
#
#  id           :bigint(8)        not null, primary key
#  body         :text
#  header       :string
#  read         :boolean          default(FALSE)
#  units        :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :integer
#  sender_id    :integer
#
# Indexes
#
#  index_game_mails_on_recipient_id  (recipient_id)
#  index_game_mails_on_sender_id     (sender_id)
#

require 'rails_helper'

describe GameMail do
  context 'new game_mail' do
    describe 'attributes' do
      it { should respond_to :sender }
      it { should respond_to :recipient }
      it { should respond_to :header }
      it { should respond_to :body }
      it { should respond_to :units }
      it { should respond_to :read }
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
  end
end
