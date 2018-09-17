class Bart2Connection::ConceptSet < ActiveRecord::Base
  self.establish_connection :bart2
  self.table_name = "concept_set"
  self.primary_key = "concept_set_id"
  
  include Bart2Connection::Openmrs
  belongs_to :set, -> { where retired: 0 }, :class_name => 'Bart2Connection::Concept'
  belongs_to :concept, -> { where retired: 0 }, :class_name => "Bart2Connection::Concept", optional: true
end
