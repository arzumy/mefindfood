class VenuesController < ApplicationController
  def index
  end

  def search
    client = Foursquare2::Client.new(:client_id => ENV['FOURSQ_ID'], :client_secret => ENV['FOURSQ_SECRET'])
    result = client.search_venues(ll: params[:position], v: '20111125')
    venues = []
    result.venues.each do |venue|
      begin
        venues << {name: venue.name, location: {lat: venue.location.lat, lng: venue.location.lng, distance: venue.location.distance}}
      rescue
        next
      end
    end
    render json: venues.to_json
  end
end