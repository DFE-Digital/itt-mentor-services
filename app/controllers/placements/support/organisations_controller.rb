class Placements::Support::OrganisationsController < Placements::Support::ApplicationController
  def index
    @schools = Placements::School.order(:name)
    @providers = Provider.all
  end

  def new
    organisation
    organisation_types
  end

  def select_type
    if params_organisation_type == "school"
      redirect_to new_placements_support_school_path
    elsif params_organisation_type == "itt_provider"
      redirect_to new_placements_support_provider_path
    else
      organisation.errors.add(
        :organisation_type,
        t("activerecord.errors.models.organisation.attributes.type.blank"),
      )
      organisation_types
      render :new
    end
  end

  private

  def organisation_types
    @organisation_types ||= [
      OpenStruct.new(id: "itt_provider", name: t("itt_provider")),
      OpenStruct.new(id: "school", name: t("school")),
    ]
  end

  def organisation
    @organisation ||= Placements::School.new
  end

  def params_organisation_type
    params.dig(:placements_school, :organisation_type)
  end
end
