class Bart2Connection::OrderType < ActiveRecord::Base
  self.table_name = "order_type"
  self.primary_key = "order_type_id"
  include Bart2Connection::Openmrs
end