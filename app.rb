require 'sinatra'
require 'sinatra/reloader'
require 'dotenv'
require 'pry'
require 'httparty'

Dotenv.load
# city = "Boston"
# response = HTTParty.get("http://beermapping.com/webservice/locquery/#{ENV["BEER_MAPPING_API_KEY"]}/#{city}")

get '/breweries' do
  city = "Boston"
  response = HTTParty.get("http://beermapping.com/webservice/locquery/#{ENV["BEER_MAPPING_API_KEY"]}/#{city}")
  @breweries = response["bmp_locations"]["location"]

  erb :'breweries/index'
end


