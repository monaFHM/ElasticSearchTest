class Location < ActiveRecord::Base
  attr_accessible :lat, :lng, :name

  has_many :articles
end
