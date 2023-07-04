class AddUnreadToInboxes < ActiveRecord::Migration[6.1]
  class Inbox < ActiveRecord::Base
    has_many :unread_messages, -> { where read: false }, class_name: 'Message'
  end

  def self.up
    add_column :inboxes, :unread_count, :integer, default: 0

    Inbox.find_each do |mailbox|
      mailbox.update! unread_count: mailbox.unread_messages.count
    end
  end

  def self.down
    remove_column :inboxes, :unread_count
  end
end
