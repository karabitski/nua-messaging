class InboxChannel < ApplicationCable::Channel

  def subscribed
    stream_from "inbox:#{params[:user_id]}"
  end
end