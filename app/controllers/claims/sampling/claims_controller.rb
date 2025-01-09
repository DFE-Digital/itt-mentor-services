class Claims::Sampling::ClaimsController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization
  before_action :validate_token
  before_action :set_provider_sampling
  after_action :mark_as_downloaded, only: :download

  def download
    provider_name = @provider_sampling.provider_name.parameterize
    send_data @provider_sampling.csv_file.download, filename: "sampling-claims-#{provider_name}-#{Time.current.iso8601}.csv"
  end

  private

  def validate_token
    @provider_sampling_id = Rails.application.message_verifier(:sampling).verify(token_param)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render "error"
  end

  def set_provider_sampling
    @provider_sampling = Claims::ProviderSampling.find(@provider_sampling_id)
    raise CSVPreviouslyDownloadedError if @provider_sampling.downloaded?
  rescue ActiveRecord::RecordNotFound, CSVPreviouslyDownloadedError
    render "error"
  end

  def token_param
    params.fetch(:token, nil)
  end

  def mark_as_downloaded
    @provider_sampling.update!(downloaded_at: Time.current)
  end
end

class CSVPreviouslyDownloadedError < StandardError; end
