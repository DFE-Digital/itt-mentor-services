class Claims::Claim::FilterFormComponentPreview < ApplicationComponentPreview
  def default
    render Claims::Claim::FilterFormComponent.new(filter_form: Claims::Support::Claims::FilterForm.new)
  end

  def with_content
    render Claims::Claim::FilterFormComponent.new(filter_form: Claims::Support::Claims::FilterForm.new) do
      content_tag(:div, "Content under the form")
    end
  end

  def subset_statuses
    render Claims::Claim::FilterFormComponent.new(filter_form: Claims::Support::Claims::FilterForm.new, statuses: %w[submitted paid])
  end

  def subset_statuses
    render Claims::Claim::FilterFormComponent.new(filter_form: Claims::Support::Claims::FilterForm.new, statuses: %w[submitted paid])
  end
end
