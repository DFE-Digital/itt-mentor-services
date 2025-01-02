class Claims::Clawback::ClaimsController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization
  before_action :validate_token
  before_action :set_clawback

  def download
    send_data @clawback.csv_file.download, filename: "clawback-claims-#{Time.current.iso8601}.csv"
  end

  private

  def validate_token
    @clawback_id = Rails.application.message_verifier(:clawback).verify(token_param)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render "error"
  end

  def set_payment
    @clawback = Claims::Clawback.find(@clawback_id)
  rescue ActiveRecord::RecordNotFound
    render "error"
  end

  def token_param
    params.fetch(:token, nil)
  end
end
