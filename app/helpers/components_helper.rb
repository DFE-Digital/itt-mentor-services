module ComponentsHelper
  def self.register_components(*components, namespace: nil)
    components.each do |component_name|
      namespaced_component_name = [namespace, component_name].compact.join("_")
      component_class_name = "#{[namespace, component_name].compact.join("/")}_component"

      define_method(namespaced_component_name) do |*args, **kwargs, &block|
        render component_class_name.classify.constantize.new(*args, **kwargs) do |component|
          block.call(component) if block.present?
        end
      end
    end
  end

  register_components :primary_navigation, :secondary_navigation
  register_components :greeting, namespace: :claims
end
