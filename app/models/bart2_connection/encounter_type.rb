class Bart2Connection::EncounterType < ActiveRecord::Base
  self.establish_connection :bart2
  self.table_name="encounter_type"
  self.primary_key= "encounter_type_id"
  include Bart2Connection::Openmrs
  has_many :encounters,->{where(voided: 0)}, :class_name => "Bart2Connection::Encounter"
end
