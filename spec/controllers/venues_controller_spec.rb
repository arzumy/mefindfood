require 'spec_helper'

describe VenuesController do
  def body
    '
      { "meta":{"code":200},
        "notifications":[{"type":"notificationTray","item":{"unreadCount":1}}],"response":{"venues":[{"id":"4da2d0109aa4721e6825161a","name":"Fluent Space","contact":{"phone":"60186377223","formattedPhone":"018-637 7223","twitter":"fluentspace"},
        "location":{"address":"50M-3 & 50N-3 Kelana Mall, Jalan SS 6/14 Kelana Jaya","lat":3.104252908499496,"lng":101.599490493536,"distance":240,"postalCode":"47301","city":"Petaling Jaya","state":"Selangor, Malaysia","country":"Malaysia"},
        "categories":[{"id":"4bf58dd8d48988d174941735","name":"Coworking Space","pluralName":"Coworking Spaces","shortName":"Coworking Space","icon":{"prefix":"https://foursquare.com/img/categories/building/default_","sizes":[32,44,64,88,256],"name":".png"},
        "primary":true}],"verified":true,"stats":{"checkinsCount":150,"usersCount":63,"tipCount":0},
        "hereNow":{"count":0}}]}
      }
    '
  end
  
  describe "GET index" do
    it "renders index template" do
      get :index
      response.should render_template("venues/index")
    end
  end

  describe "GET search" do
    it "returns a list of venues" do
      venues = [{name: "Fluent Space", location: {lat: 3.104252908499496, lng: 101.599490493536, distance: 240} }]
      stub_request(:get, "https://api.foursquare.com/v2/venues/search?client_id=ABCDEF&client_secret=ABCDEF&ll=3.106334,101.598912&v=20111125").to_return(body: body)
      get :search, :position => "3.106334,101.598912"
      response.body.should == venues.to_json
    end
  end

end