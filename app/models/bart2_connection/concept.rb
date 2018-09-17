class Bart2Connection::Concept < ActiveRecord::Base
  self.establish_connection :bart2
  self.table_name = "concept"
  self.primary_key = "concept_id"

  include Bart2Connection::Openmrs

  has_many :answer_concept_names, -> { where voided: 0 }, :class_name => 'Bart2Connection::ConceptName'
  has_many :concept_names, -> { where voided: 0 }, :class_name => "Bart2Connection::ConceptName"

  has_many :concept_members, :class_name => 'Bart2Connection::ConceptSet', :foreign_key => :concept_set

  def self.find_by_name(concept_name)
    Concept.joins("INNER JOIN concept_name on concept_name.concept_id = concept.concept_id").where(["concept.retired = 0 AND concept_name.voided = 0
      AND concept_name.name =?", "#{concept_name}"]).first
  end

  def shortname
    name = self.concept_names.typed('SHORT').first.name rescue nil
    return name unless name.blank?
    return self.concept_names.first.name rescue nil
  end

  def fullname
    name = self.concept_names.typed('FULLY_SPECIFIED').first.name rescue nil
    return name unless name.blank?
    return self.concept_names.first.name rescue nil
  end
end
