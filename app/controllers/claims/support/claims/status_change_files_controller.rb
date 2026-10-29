class Claims::Support::Claims::StatusChangeFilesController < Claims::Support::ApplicationController
  def show
    claim = policy_scope(Claims::Claim).find(params.require(:claim_id))
    event = policy_scope(Claims::ClaimStatusChange).where(claim:).find(params.require(:status_change_id))
    authorize event, :download?

    source = event.source
    file = source.csv_file if source.respond_to?(:csv_file)
    return file_not_found unless file&.attached?

    send_data file.download, filename: file.filename.to_s, type: "text/csv", disposition: "attachment"
  rescue ActiveStorage::FileNotFoundError
    file_not_found
  end

  private

  def file_not_found
    render plain: t(".show.unavailable"), status: :not_found
  end
end
