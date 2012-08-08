require 'tire'
require 'active_record'

Tire.index('venues') { delete }

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ":memory:" )

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(version: 1) do
  create_table :venues do |t|
    t.string   :title, :latitude, :longitude
  end
end

class Venue < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks

  tire do
    mapping do
      indexes :title,   type: 'string', analyzer: 'snowball'
      indexes :lat_lon, type: 'geo_point'
    end
  end

  def lat_lon
    [latitude, longitude]
  end

  def to_indexed_json
    to_json(only: ['title'], methods: ['lat_lon'])
  end
end

Venue.create title: 'Pizzeria Pomodoro', latitude: "41.12", longitude: "-71.34"

Venue.tire.index.refresh

# Example 1: Construct the search as a Hash
# query = { query: { filtered: { query: { match_all: ''} }, filter: { geo_distance: { distance: '100km', lat_lon: "41,-71" } } } }

# puts "", "The query:", '-'*80, query.to_json

# s = Tire.search 'venues', query

# puts "", "Results:", '-'*80, s.results.inspect

# Example 2: Construct the search using block syntax
s = Venue.tire.search do
  query { all }
  filter :geo_distance, lat_lon: "41,-71", distance: '100km'
end

puts "", "Results:", '-'*80, s.results.inspect