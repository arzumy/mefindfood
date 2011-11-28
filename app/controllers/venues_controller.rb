class VenuesController < ApplicationController
  def index
  end

  def search
    client = Foursquare2::Client.new(:client_id => ENV['FOURSQ_ID'], :client_secret => ENV['FOURSQ_SECRET'])
    result = client.search_venues(ll: params[:position], v: '20111125', categoryId: '4d4b7105d754a06374d81259', intent: "browse", radius: 10000)
    venues = []
    result.venues.each do |venue|
      begin
        venues << {name: venue.name, popularity: venue.stats.checkinsCount, location: {address: venue.location.address, lat: venue.location.lat, lng: venue.location.lng, distance: venue.location.distance, postalCode: venue.location.postalCode, city: venue.location.city, leaf: false}, stats: {checkinsCount: venue.stats.checkinsCount, tipCount: venue.stats.tipCount, leaf: false}}
      rescue
        next
      end
    end
    render json: venues.sort_by {|venue| venue[:location][:distance]}.to_json
  end
end