class Bart2Connection::Patient < ActiveRecord::Base
  self.establish_connection :bart2
  before_save :before_save
  before_create :before_create
  
  self.table_name = "patient"
  self.primary_key ="patient_id"
  include Openmrs

  has_one :person, ->{where(voided: 0)}, :class_name => "Bart2Connection::Person", :foreign_key => :person_id
  has_many :patient_identifiers, ->{where(voided: 0)}, :class_name => "Bart2Connection::PatientIdentifier", :foreign_key => :patient_id, dependent: :destroy
  has_many :encounters, ->{where(voided: 0)}, :class_name => "Bart2Connection::Encounter"  do
    def find_by_date(encounter_date)
      encounter_date = Date.today unless encounter_date
      where("encounter_datetime BETWEEN ? AND ?",
        encounter_date.to_date.strftime('%Y-%m-%d 00:00:00'),
        encounter_date.to_date.strftime('%Y-%m-%d 23:59:59')
      ) # Use the SQL DATE function to compare just the date part
    end
  end

  def after_void(reason = nil)
    self.person.void(reason) rescue nil
    self.patient_identifiers.each {|row| row.void(reason) }
    self.patient_programs.each {|row| row.void(reason) }
    self.orders.each {|row| row.void(reason) }
    self.encounters.each {|row| row.void(reason) }
  end

  def national_id
    self.patient_identifiers.find_by_identifier_type(PatientIdentifierType.find_by_name("National id").id).identifier rescue nil
  end
end
