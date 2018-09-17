class Bart2Connection::PersonAttribute < ActiveRecord::Base
  self.establish_connection :bart2
  self.table_name = "person_attribute"
  self.primary_key = "person_attribute_id"
  before_save :before_save
  before_create :before_create
  include Bart2Connection::Openmrs

  belongs_to :type,->{where(retired:0)}, :class_name => "Bart2Connection::PersonAttributeType", :foreign_key => :person_attribute_type_id, optional: true
  belongs_to :person,->{where(voided:0)}, :class_name => "Bart2Connection::Person", :foreign_key => :person_id, optional: true
end
