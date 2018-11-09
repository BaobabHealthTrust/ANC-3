require "settings"
module CoreService
	def self.get_global_property_value(global_property)
		property_value = Settings[global_property] 
		if property_value.nil?
			property_value = GlobalProperty.where({:property => "#{global_property}"}
													).first.property_value rescue nil
		end
		return property_value
	end

end
	
