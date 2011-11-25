require 'spec_helper'

describe VenuesController do
  describe "GET index" do
    it "renders index template" do
      get :index
      response.should render_template("venues/index")
    end
  end
end