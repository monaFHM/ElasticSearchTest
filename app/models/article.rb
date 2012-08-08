require 'pry'

class Article < ActiveRecord::Base

  after_save do
    update_index 
  end

  attr_accessible :category_id, :content, :location_id, :published_date, :publisher_id, :title 

  belongs_to :category
  belongs_to :location
  belongs_to :publisher

  include Tire::Model::Search
  include Tire::Model::Callbacks

  # tire do
  #   mapping do
  #     indexes :title,   type: 'string', analyzer: 'snowball'
  #     indexes :lat_lon, type: 'geo_point'
  #   end
  # end

  tire do
    mapping do
      indexes :title,   type: 'string', analyzer: 'snowball'
      indexes :content,   type: 'string', analyzer: 'snowball'
      indexes :category_id, type:'integer'
      indexes :published_date, :type => 'date'
      indexes :lat_lon, type: 'geo_point'
      indexes :publisher do
          indexes :name, :type => 'string', analyzer: 'snowball'
          #indexes :last_name,  :type => 'string', :boost => 100
      end
    end
  end

  def lat_lon 
    #[location.lat,location.lng]
    #{lat_lon: {lat: location.lat, lon: location.lng}}
    [location.lng, location.lat]
  end

  self.include_root_in_json = false
  def to_indexed_json
    to_json(methods: ['lat_lon'], include: :publisher)
  end

  def self.search(params)

    lat_lng_arr=[]
    if params[:location] && !params[:location].empty?
      loc = Location.find(params[:location])
      lat_lng_arr << loc.lat
      lat_lng_arr << loc.lng
    end

    # binding.pry
    
   s=tire.search(load: true) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?
      #query { string("publisher.name:#{params[:publisher]}")} if params[:publisher].present?
      if params[:publisher].present?
        query do
          boolean do
            should do
              fuzzy 'publisher.name', params[:publisher]
              #binding.pry
            end
          end
        end
      end

      #loc_publisher = { fuzzy: {publisher: {name: 'Sarai'} } }
      filter :range, published_date: {lte: Time.zone.now}
      filter :term, category_id: params[:category] if params[:category].present?
      #query :term, {publisher: {name: params[:publisher]}} if params[:publisher].present?

      #filter :geo_distance, lat_lon: "51,7", distance: '100km' if lat_lng_arr!=[]
      distance = params[:radius] || '100km'
      filter :geo_distance, lat_lon: lat_lng_arr.join(","), distance: distance if lat_lng_arr!=[]
    end

    



    # search = Tire::Search::Search.new('articles', load: true)
    # search.query  { string(params[:query]) } if params[:query].present?
    # if params[:publisher].present?
    #   search.query do
    #       fuzzy(:publisher, params[:publisher])
    #   end
    # end    
    # search.filter :geo_distance, lat_lon: lat_lng_arr.join(","), distance: '100km' if lat_lng_arr!=[]
    # binding.pry
    # r= search.results    


    

  end

  # "geo_distance" : {
  #               "distance" : "12km",
  #               "location" : {
  #                   "lat" : 34,
  #                   "lon" : -118
  #               } 

  # def self.jsonsearch()
  #   query = { query: { filtered: { query: { match_all: ''} }, filter: { geo_distance: { distance: '100km', lat_lon: "51, 7" } } } }

  # end





    # loc_query=geopoint

end
