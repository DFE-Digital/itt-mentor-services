class Claims::Sampling::ClaimsController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization
  before_action :set_provider_sampling
  after_action :mark_as_downloaded, only: :download

  def download
    provider_name = @provider_sampling.provider_name.parameterize
    send_data @provider_sampling.csv_file.download, filename: "sampling-claims-#{provider_name}-#{Time.current.iso8601}.csv"
  end

  private

  def set_provider_sampling
    @provider_sampling = download_access_token.activity_record
  rescue ActiveRecord::RecordNotFound, ActiveSupport::MessageVerifier::InvalidSignature
    render "error"
  end

  def download_access_token
    @download_access_token = Claims::DownloadAccessToken.find_by_token_for!(:csv_download, token_param)
  end

  def token_param
    params.fetch(:token, nil)
  end

  def mark_as_downloaded
    @provider_sampling.update!(downloaded_at: Time.current)
    download_access_token.update!(downloaded_at: Time.current)
  end
end
