class Recurring < ActiveRecord::Base
   attr_accessible :name, :template_type, :interval, :days_inadvance, :start_date, :end_date, :every, :on
end
