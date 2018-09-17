class Bart2Connection::Encounter < ActiveRecord::Base
  self.establish_connection :bart2
  before_save :before_save
  before_create :before_create
  
  self.table_name = "encounter"
  self.primary_key = "encounter_id"

  include Bart2Connection::Openmrs
  has_many :observations, -> { where voided: 0 }, :class_name => "Bart2Connection::Observation", dependent: :destroy
  has_many :orders, -> { where voided: 0 }, :class_name => "Bart2Connection::Order", dependent: :destroy
  has_many :drug_orders, foreign_key: "order_id", :class_name => "Bart2Connection::DrugOrder", through: "orders",  :foreign_key => 'order_id'
  
  belongs_to :type, -> { where retired: 0 }, :class_name => "Bart2Connection::EncounterType", :foreign_key => :encounter_type, optional: true
  belongs_to :provider, -> { where voided: 0 }, :class_name => "Bart2Connection::Person", :foreign_key => :provider_id, optional: true
  belongs_to :patient, -> { where voided: 0 }, :class_name => "Bart2Connection::Patient", optional: true

  # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
  scope :current, -> {where('DATE(encounter.encounter_datetime) = CURRENT_DATE()')}

  def before_save
    self.provider = User.current.person if self.provider.blank?
    # TODO, this needs to account for current visit, which needs to account for possible retrospective entry
    self.encounter_datetime = Time.now if self.encounter_datetime.blank?
  end

  def after_save
    #self.add_location_obs
  end

  def after_void(reason = nil)
    self.observations.each do |row| 
      if not row.order_id.blank?
        ActiveRecord::Base.connection.exedef void(reason = "Voided through #{BART_VERSION}",date_voided = Time.now)

   # ActiveRecord::Base.connection.execute("UPDATE encounter SET voided = 1 WHERE encounter_id = #{self.id}")
    self.update_attributes(:voided => 1)
  endcute <<EOF
UPDATE drug_order SET quantity = NULL WHERE order_id = #{row.order_id};
EOF
      end rescue nil
      row.void(reason) 
    end rescue []

    self.orders.each do |order|
      order.void(reason) 
    end
  end

  def name
    self.type.name rescue "N/A"
  end

  def encounter_type_name=(encounter_type_name)
    self.type = EncounterType.find_by_name(encounter_type_name)
    raise "#{encounter_type_name} not a valid encounter_type" if self.type.nil?
  end

  def to_s
    if name == 'REGISTRATION'
      "Patient was seen at the registration desk at #{encounter_datetime.strftime('%I:%M')}" 
    elsif name == 'TREATMENT'
      o = orders.collect{|order| order.drug_order}.join(", ")
      # o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No prescriptions have been made" if o.blank?
      o
    elsif name == 'DISPENSING'
      o = orders.collect{|order| order.drug_order}.join(", ")
      # o = "TREATMENT NOT DONE" if self.patient.treatment_not_done
      o = "No TTV vaccine given" if o.blank?
      o
    elsif name == 'VITALS'
      temp = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("TEMPERATURE (C)") && "#{obs.answer_string}".upcase != 'UNKNOWN' }
      weight = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("WEIGHT (KG)") && "#{obs.answer_string}".upcase != '0.0' }
      height = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("HEIGHT (CM)") && "#{obs.answer_string}".upcase != '0.0' }
      systo = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("SYSTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      diasto = observations.select {|obs| obs.concept.concept_names.map(&:name).collect{|n| n.upcase}.include?("DIASTOLIC BLOOD PRESSURE") && "#{obs.answer_string}".upcase != '0.0' }
      vitals = [weight_str = weight.first.answer_string + 'KG' rescue 'UNKNOWN WEIGHT',
        height_str = height.first.answer_string + 'CM' rescue 'UNKNOWN HEIGHT', bp_str = "BP: " + 
          (systo.first.answer_string.to_i.to_s rescue "?") + "/" + (diasto.first.answer_string.to_i.to_s rescue "?")]
      temp_str = temp.first.answer_string + '°C' rescue nil
      vitals << temp_str if temp_str                          
      vitals.join(', ')
    elsif name == 'DIAGNOSIS'
      diagnosis_array = []
      observations.each{|observation|
        next if observation.obs_group_id != nil
        observation_string =  observation.answer_string
        child_ob = observation.child_observation
        while child_ob != nil
          observation_string += " #{child_ob.answer_string}"
          child_ob = child_ob.child_observation
        end
        diagnosis_array << observation_string
        diagnosis_array << " : "
      }
      diagnosis_array.compact.to_s.gsub(/ : $/, "")    
    elsif name == 'OBSERVATIONS' || name == 'CURRENT PREGNANCY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Breech Delivery", "Breech")}.join(", ")   
    elsif name == 'SURGICAL HISTORY'
      observations.collect{|observation| observation.to_s.titleize.gsub("Tuberculosis Test Date Received", "Date")}.join(", ")
    elsif name == "ANC VISIT TYPE"
      observations.collect{|o| "Visit No.: " + o.value_numeric.to_i.to_s}.join(", ")
    else  
      observations.collect{|observation| observation.to_s.titleize}.join(", ")
    end  
  end

  def self.statistics(encounter_types, opts={})
encounter_types = EncounterType.where(['name IN (?)', encounter_types])
    encounter_types_hash = encounter_types.inject({}) {|result, row| result[row.encounter_type_id] = row.name; result }
    rows = self.where(['encounter_type IN (?)', encounter_types.map(&:encounter_type_id)]).where(opts[:conditions]).group("encounter_type").select("count(*) as number, encounter_type")
    return rows.inject({}) {|result, row| result[encounter_types_hash[row['encounter_type']]] = row['number']; result }
  end

end
