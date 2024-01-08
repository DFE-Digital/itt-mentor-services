class Claims::GreetingComponent < ViewComponent::Base
  def call
    "This is rendered from Claims::GreetingComponent - so long as this page rendered without any errors you're good to go."
  end
end
