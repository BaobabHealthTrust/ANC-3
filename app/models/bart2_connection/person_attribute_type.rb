class Bart2Connection::PersonAttributeType < ActiveRecord::Base
  self.establish_connection :bart2
  self.table_name = "person_attribute_type"
  self.primary_key = "person_attribute_type_id"
  include Openmrs
  has_many :person_attributes, ->{where(voided:0)}, :class_name => "Bart2Connection::PersonAttribute"
end