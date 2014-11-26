require 'sinatra'
require 'sinatra/reloader'
require 'dotenv'
require 'pry'
require 'httparty'

Dotenv.load

def search_breweries(city)
  city = URI.encode(city)
  response = HTTParty.get("http://beermapping.com/webservice/loccity/#{ENV["BEER_MAPPING_API_KEY"]}/#{city}")
  breweries = response["bmp_locations"]["location"]

  if breweries.class == Hash
    [breweries]
  else
    breweries
  end
end

get '/breweries' do
  if !params[:search]
    @breweries = search_breweries("Boston")
  else
    @breweries = search_breweries(params[:search])
  end

  erb :'breweries/index'
end
