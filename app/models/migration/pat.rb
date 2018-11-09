require "enumerator"

class Pat < OpenMRS
  self.table_name = "patient"
  self.primary_key = "patient_id"

end
