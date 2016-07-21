Rails.configuration.middleware.use Browser::Middleware do
  version = browser.version
  version = version.to_i unless version.blank?
  redirect_to upgrade_index_path if (browser.ie? && version<=8)
end
