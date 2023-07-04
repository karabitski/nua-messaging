require 'rails_helper'

describe MessagesController do

  def create_users
    @current_user = User.create is_patient: true
    @current_user_inbox = @current_user.create_inbox
    @current_user_outbox = @current_user.create_outbox
    @doctor = User.create is_doctor: true, is_patient: false
    @doctor_inbox = @doctor.create_inbox
    @doctor_outbox = @doctor.create_outbox
    @admin = User.create is_admin: true, is_patient: false
    @admin_inbox  = @admin.create_inbox
    @admin_outbox = @admin.create_outbox
  end

  def initial_message
    Message.create body: 'initial', inbox: @current_user_inbox, outbox: @doctor_outbox
  end

  def message_to_doctor
    Message.create body: 'reply', inbox: @doctor_inbox, outbox: @current_user_outbox
  end

  def valid_attributes
    {reply: initial_message.id, message: { body: 'reply' } }
  end

  describe "POST create" do
    before { create_users }
    it "creates a new Message" do
      post :create, params: valid_attributes
      assert_response :redirect
      expect(@current_user_outbox.messages.count).to eq(1)
      expect(@doctor_inbox.messages.count).to eq(1)
      expect(@doctor_inbox.unread_messages.count).to eq(1)
    end

    it "doctor opens a Message and it gets read" do
      get :show, params: { id: message_to_doctor.id }
      expect(@doctor_inbox.messages.count).to eq(1)
      expect(@doctor_inbox.unread_messages.count).to eq(0)
    end

    it "paid prescription message is sent" do
      post :paid
      message = @admin_inbox.messages.first
      expect(message.body).to eq(Message::PAID_MESSAGE)
      Provider.any_instance.stub(:debit_card).and_return Payment
      expect(Payment.count).to eq(1)
    end

    it "payment for paid prescription fails" do
      post :paid, params: { failure: true }
      expect(@admin_inbox.messages.count).to eq(0)
      expect(Payment.count).to eq(0)
      assert_response :redirect
    end
  end
end
