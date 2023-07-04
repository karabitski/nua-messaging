class OutboxChannel < ApplicationCable::Channel
  def subscribed
    stream_from "outbox:#{params[:user_id]}"
  end
end
