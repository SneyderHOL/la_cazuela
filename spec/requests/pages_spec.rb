require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /about" do
    it "returns http success" do
      get "/about"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /contact" do
    it "returns http success" do
      get "/contact"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /location" do
    it "returns http success" do
      get "/location"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /menu" do
    it "returns http success" do
      get "/menu"
      expect(response).to have_http_status(:success)
    end
  end
end
