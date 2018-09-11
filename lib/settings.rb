require "settingslogic"
class Settings < Settingslogic
	source "#{Rails.root.to_s}/config/application.yml"
	namespace Rails.env
end
