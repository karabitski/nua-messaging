class MessagesController < ApplicationController

  def show
    @message = Message.find(params[:id])
    @message.toggle!(:read) unless @message.read
  end

  def new
    @reply = Message.find_by(id: params[:message_id])
    @message = Message.new
  end

  def create
    @recipient = find_recipient
    @message = Message.new outbox: current_user.outbox,
                           inbox: @recipient.inbox,
                           body: message_params.fetch(:body)
    if @message.save
      @message.broadcast!(current_user, @recipient)
      redirect_to root_path
    else
      flash[:errors] = @message.errors.full_messages
      render :new
    end
  end

  def index
    @channel = "InboxChannel"
    @mailbox = current_user.inbox
  end

  def outbox
    @channel = "OutboxChannel"
    @mailbox = current_user.outbox
    render :index
  end

  def paid
    begin
      PaymentProviderFactory.provider.debit_card(current_user, params[:failure])
      Message.create_paid!(current_user)
    rescue FailedPaymentError => e
      @error = e.message
    end
    redirect_to root_path
  end

  private

  def message_params
    params.require(:message).permit(:body)
  end

  def find_recipient
    reply = Message.find_by(id: params[:reply])
    reply&.created_at < 1.week.ago ? User.admin.first : User.doctor.first
  end
end
