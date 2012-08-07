# encoding: UTF-8
require 'faker'

categories=[]
publisher=[]
locations=[]

def time_rand
  from = Time.new(1950,1,1)
  to = Time.now
  Time.at(from + rand * (to.to_f - from.to_f))
end


#Category
5.times do 
  categories<<Category.create(:title => Faker::Company.bs).id
end
#Publisher
5.times do
  publisher<<Publisher.create(:name =>Faker::Name.name, :birthday => time_rand).id
end
#Location

locations << Location.create(:name => "Münster", :lat => 51.899320, :lng =>7.591553 ).id
locations << Location.create(:name => "Hamm", :lat => 51.651202, :lng =>7.822266 ).id
locations << Location.create(:name => "Dortmund", :lat => 51.487312, :lng => 7.470703).id
locations << Location.create(:name => "Greven", :lat => 52.075230, :lng => 7.624512).id
locations << Location.create(:name => "Wiesbaden", :lat => 50.063251, :lng => 8.261719).id



30.times do
   c="#{Faker::Company.catch_phrase} #{Faker::Company.bs} #{Faker::Lorem.paragraphs}"
  Article.create(:publisher_id => publisher.shuffle.first, :category_id => categories.shuffle.first, :location_id => locations.shuffle.first, :title => Faker::Company.catch_phrase, :content =>c, :published_date=>time_rand )
end


#Articels
