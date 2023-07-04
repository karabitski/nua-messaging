class PaymentProviderFactory
  def self.provider
    @provider ||= Provider.new
  end
end

class Provider
  def debit_card(user, failed_response = false)
    unless failed_response
      Payment.create! user: user
    else
      fail FailedPaymentError.new("Payment failed")
    end
  end
end

class FailedPaymentError < StandardError; end
