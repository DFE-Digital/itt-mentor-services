class Claims::Clawback::ClaimsController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization
  before_action :validate_token
  before_action :set_clawback
  after_action :mark_as_downloaded, only: :download

  def download
    send_data @clawback.csv_file.download, filename: "clawback-claims-#{Time.current.iso8601}.csv"
  end

  private

  def validate_token
    @clawback_id = Rails.application.message_verifier(:clawback).verify(token_param)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render "error"
  end

  def set_clawback
    @clawback = Claims::Clawback.find(@clawback_id)
    raise CSVPreviouslyDownloadedError if @clawback.downloaded?
  rescue ActiveRecord::RecordNotFound, CSVPreviouslyDownloadedError
    render "error"
  end

  def token_param
    params.fetch(:token, nil)
  end

  def mark_as_downloaded
    @clawback.update!(downloaded_at: Time.current)
  end
end

class CSVPreviouslyDownloadedError < StandardError; end
