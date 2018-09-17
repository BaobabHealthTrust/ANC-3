class Bart2Connection::Person < ActiveRecord::Base
  self.establish_connection :bart2
  self.table_name = "person"
  self.primary_key  = "person_id"

  before_save :before_save
  before_create :before_create
  
  include Bart2Connection::Openmrs

  cattr_accessor :session_datetime
  cattr_accessor :migrated_datetime
  cattr_accessor :migrated_creator
  cattr_accessor :migrated_location

  has_one :patient, ->{where(voided:0)}, :class_name => "Bart2Connection::Patient", :foreign_key => :patient_id, dependent: :destroy
  has_many :names, ->{where(voided:0)}, :class_name => "Bart2Connection::PersonName", :foreign_key => :person_id, dependent: :destroy#, :order => 'person_name.preferred DESC'
  has_many :addresses, ->{where(voided:0)}, :class_name => "Bart2Connection::PersonAddress", :foreign_key => :person_id, dependent: :destroy#, :order => 'person_address.preferred DESC', :conditions => {:voided => 0}
  has_many :person_attributes, ->{where(voided:0)}, :class_name => "Bart2Connection::PersonAttribute", :foreign_key => :person_id
  
  def after_void(reason = nil)
    self.patient.void(reason) rescue nil
    self.names.each{|row| row.void(reason) }
    self.addresses.each{|row| row.void(reason) }
    self.relationships.each{|row| row.void(reason) }
    self.person_attributes.each{|row| row.void(reason) }
    # We are going to rely on patient => encounter => obs to void those
  end

end
