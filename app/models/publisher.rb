class Publisher < ActiveRecord::Base
  attr_accessible :birthday, :name
  
  has_many :articles
end
