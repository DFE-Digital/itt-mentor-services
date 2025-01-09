class Claims::Payments::ClaimsController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization
  before_action :validate_token
  before_action :set_payment
  after_action :mark_as_downloaded, only: :download

  def download
    send_data @payment.csv_file.download, filename: "payments-claims-#{Time.current.iso8601}.csv"
  end

  private

  def validate_token
    @payment_id = Rails.application.message_verifier(:payments).verify(token_param)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render "error"
  end

  def set_payment
    @payment = Claims::Payment.find(@payment_id)
    raise CSVPreviouslyDownloadedError if @payment.downloaded?
  rescue ActiveRecord::RecordNotFound, CSVPreviouslyDownloadedError
    render "error"
  end

  def token_param
    params.fetch(:token, nil)
  end

  def mark_as_downloaded
    @payment.update!(downloaded_at: Time.current)
  end
end

class CSVPreviouslyDownloadedError < StandardError; end
