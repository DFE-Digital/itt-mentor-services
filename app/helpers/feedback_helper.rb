module FeedbackHelper
  def feedback_options
    [
      [:very_satified, t(".options.very_satisfied")],
      [:satified, t(".options.satisfied")],
      [:neutral, t(".options.neutral")],
      [:dissatisfied, t(".options.dissatisfied")],
      [:very_dissatified, t(".options.very_dissatisfied")],
    ]
  end
end
