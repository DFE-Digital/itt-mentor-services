# frozen_string_literal: true

module NavigationBarHelper
  def navigation_items
    [
      {
        name: t("navigation_bar.users"),
        url: "#",
        additional_url:
          "#",
      },
      name: t("navigation_bar.organisation_details"),
      url: root_path,
      active: request.path == root_path,
    ]
  end

  def navigation_bar
    render(NavigationBar.new(
             items: navigation_items,
             current_path: request.path,
             current_user:,
           ))
  end
end
