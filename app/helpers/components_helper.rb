module ComponentsHelper
  def primary_navigation(*args, **kwargs, &block)
    render PrimaryNavigationComponent.new(*args, **kwargs) do |component|
      block.call(component) if block.present?
    end
  end
end
