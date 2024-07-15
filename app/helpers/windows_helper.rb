module WindowsHelper
  def window_range_display(start_date, end_date)
    "#{I18n.l(start_date, format: :long)} to #{I18n.l(end_date, format: :long)}"
  end
end
