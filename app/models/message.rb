class Message < ApplicationRecord

  belongs_to :inbox
  belongs_to :outbox

  validates :body, presence: true
  validates :body, length: { maximum: 500 }

  after_save    :update_unreads
  after_destroy :update_unreads

  PAID_MESSAGE = "I've lost my script, please issue a new one at a charge of €10"

  def update_unreads
    self.inbox.update!( unread_count: self.inbox.unread_messages.count)
  end

  def broadcast!(sender, recipient)
    InboxChannel.broadcast_to recipient.id,
                              body: body,
                              owner: sender.full_name,
                              message_id: id
    OutboxChannel.broadcast_to sender.id,
                               body: body,
                               owner: recipient.full_name,
                               message_id: id

  end

  def self.create_paid!(sender = User.current.first)
    message = create! outbox: sender.outbox,
                      inbox: User.default_admin.inbox,
                      body: PAID_MESSAGE
    message.broadcast_paid! sender
    message
  end

  def broadcast_paid!(sender, recipient = User.default_admin)
    InboxChannel.broadcast_to recipient.id,
                              body: PAID_MESSAGE,
                              owner: sender.full_name,
                              message_id: id
  end


end