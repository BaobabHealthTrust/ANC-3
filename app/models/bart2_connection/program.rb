class Bart2Connection::Program < ActiveRecord::Base
  self.establish_connection :bart2
  self.table_name = "program"
  self.primary_key = "program_id"
  include Bart2Connection::Openmrs
end
