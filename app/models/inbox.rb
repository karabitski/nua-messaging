class Inbox < ApplicationRecord

  belongs_to :user
  has_many :messages
  has_many :unread_messages, -> { where read: false }, class_name: 'Message'

end