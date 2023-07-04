require 'rails_helper'

describe Message, :type => :model do
  context "create" do
    it "has an read status after creation" do
      message = Message.create body: 'body', inbox: Inbox.create
      expect(message).to be_valid
      expect(message.read).to eq false
    end
  end
end