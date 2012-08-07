require 'pry'

class Article < ActiveRecord::Base
  attr_accessible :category_id, :content, :location_id, :published_date, :publisher_id, :title

  belongs_to :category
  belongs_to :location
  belongs_to :publisher

  include Tire::Model::Search
  include Tire::Model::Callbacks

  tire do
    mapping do
      indexes :title,   type: 'string', analyzer: 'snowball'
      #indexes :content,   type: 'string', analyzer: 'snowball'
      #indexes :category_id, :index    => :not_analyzed
      indexes :lat_lon, type: 'geo_point'
    end
  end

  def lat_lon 
    return [location.lat,location.lng]
  end

  # def to_indexed_json
  #   to_json(only: ['title'], methods: ['lat_lon'])
  # end

  def self.search(params)

    lat_lng_arr=[]
    if params[:location] && !params[:location].empty?
      loc = Location.find(params[:location])
      lat_lng_arr << loc.lat
      lat_lng_arr << loc.lng
    end
    
    tire.search(load: true) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?
      filter :range, published_date: {lte: Time.zone.now}
      filter :term, category_id: params[:category] if params[:category].present?
      #filter :terms, publisher params[:publisher]

      filter :geo_distance, lat_lon: "41,-71", distance: '100km' if lat_lng_arr!=[]
      #filter :geo_distance, lat_lon: lat_lng_arr.join(","), distance: '100km' if lat_lng_arr!=[]
    end
  end

end
