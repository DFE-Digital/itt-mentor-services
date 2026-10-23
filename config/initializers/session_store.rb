# activerecord-session_store 2.3.0 only saves a session when `data=` receives
# something different from the stored hash. The wizards mutate nested session
# state in place, which that comparison cannot see, so always treat assigned
# data as changed.
Rails.application.config.to_prepare do
  ActiveRecord::SessionStore::Session.class_eval do
    def data=(data)
      attribute_will_change!(self.class.data_column_name)
      @data = data
    end
  end
end
