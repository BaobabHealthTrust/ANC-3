class Bart2Connection::PatientProgram < ActiveRecord::Base
  self.establish_connection :bart2
  self.table_name = "patient_program"
  self.primary_key = "patient_program_id"

  before_save :before_save
  before_create :before_create
  
  include Bart2Connection::Openmrs
  belongs_to :patient, -> {where(voided: 0)}, :class_name => 'Bart2Connection::Patient'
  belongs_to :program, -> {where(retired: 0)}, :class_name => 'Bart2Connection::Program'
  
  def regimens(weight=nil)
    self.program.regimens(weight)
  end

  def closed?
    (self.date_completed.blank? == false)
  end
        
end
