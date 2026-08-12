require 'rails_helper'

RSpec.describe "SellOrder", type: :request do
  let(:sell_order) { create(:sell_order, :with_allocation) }
  let(:user) do
    create(:user, email: "admin@example", password: "adminPass", password_confirmation: "adminPass")
  end

  describe "GET /dashboard/sell_orders" do
    context "when user has already signin" do
      before { sign_in user }

      it "returns http success" do
        get "/dashboard/sell_orders"
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        get "/dashboard/sell_orders"
        expect(response.body).to include("Manage open sales, payments and billing.")
      end
    end

    context "when user has not signin" do
      it "returns http redirect" do
        get "/dashboard/sell_orders"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/sell_orders"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/sell_orders"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "GET /dashboard/sell_orders/:id" do
    context "when user has already signin" do
      before do
        sell_order
        sign_in user
      end

      it "returns http success" do
        get "/dashboard/sell_orders/#{sell_order.id}"
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        get "/dashboard/sell_orders/#{sell_order.id}"
        expect(response.body).to include("Sell Order")
      end
    end

    context "when user has not signin" do
      before { sell_order }

      it "returns http redirect" do
        get "/dashboard/sell_orders/#{sell_order.id}"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/sell_orders/#{sell_order.id}"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/sell_orders/#{sell_order.id}"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "POST /dashboard/sell_orders/:id/invoice" do
    context "when user has already signin and performs action" do
      before do
        create(:order, :as_completed, :with_products, trait_amount: 1, sell_order:)
        sign_in user
      end

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/invoice"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/invoice"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/invoice"
        follow_redirect!
        expect(response.body).to include("Sell order was set to invoicing.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      before do
        create(:order, sell_order:)
        sign_in user
      end

      it "returns http unprocessable content" do
        post "/dashboard/sell_orders/#{sell_order.id}/invoice"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/invoice"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { sell_order }

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/invoice"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/invoice"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/invoice"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "POST /dashboard/sell_orders/:id/deliver" do
    context "when user has already signin and performs action" do
      let(:sell_order) { create(:sell_order, :with_delivery_allocation, :as_packed) }

      before do
        create(:order, :as_packed, sell_order:)
        sign_in user
      end

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/deliver"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/deliver"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/deliver"
        follow_redirect!
        expect(response.body).to include("Sell order was set to delivering.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      before do
        sell_order
        sign_in user
      end

      it "returns http unprocessable content" do
        post "/dashboard/sell_orders/#{sell_order.id}/deliver"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/deliver"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { sell_order }

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/deliver"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/deliver"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/deliver"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "POST /dashboard/sell_orders/:id/close" do
    context "when user has already signin and performs action" do
      let(:sell_order) do
        create(:sell_order, :as_invoicing, :with_allocation, :with_transfer_payment, total: 10_000)
      end

      before do
        create(:order, :as_completed, :with_products, trait_amount: 1, sell_order:)
        sign_in user
      end

      it "returns http success" do
        post "/dashboard/sell_orders/#{sell_order.id}/close"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/close"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/close"
        follow_redirect!
        expect(response.body).to include("Sell order was closed.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      before do
        sell_order
        sign_in user
      end

      it "returns http unprocessable content" do
        post "/dashboard/sell_orders/#{sell_order.id}/close"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/close"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { sell_order }

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/close"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/close"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/close"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "POST /dashboard/sell_orders/:id/payment" do
    let(:sell_order) do
      create(:sell_order, :as_invoicing, :with_allocation, total: 10_000)
    end

    context "when user has already signin and with card payment" do
      before do
        sell_order
        sign_in user
      end

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "card" }
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "card" }
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "card" }
        follow_redirect!
        expect(response.body).to include("Payment saved.")
      end
    end

    context "when user has already signin and with transfer payment" do
      before do
        sell_order
        sign_in user
      end

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "transfer" }
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "transfer" }
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "transfer" }
        follow_redirect!
        expect(response.body).to include("Payment saved.")
      end
    end

    context "when user has already signin and with cash payment" do
      before do
        sell_order
        sign_in user
      end

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "cash", cash_pay: sell_order.total }
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "cash", cash_pay: sell_order.total }
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "cash", cash_pay: sell_order.total }
        follow_redirect!
        expect(response.body).to include("Payment saved.")
      end
    end

    context "when user has already signin and do not send required param" do
      before do
        sell_order
        sign_in user
      end

      it "returns http bad request when payment_type is missing" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment: "card" }
        expect(response).to have_http_status(:bad_request)
      end

      it "return valid flash alert message when payment_type is missing" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment: "card" }
        expect(response.body).to include("param is missing or the value is empty or invalid: payment_type")
      end

      it "returns http bad request when cash_pay is missing" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "cash" }
        expect(response).to have_http_status(:bad_request)
      end

      it "return valid flash alert message when cash_pay is missing" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "cash" }
        expect(response.body).to include("param is missing or the value is empty or invalid: cash_pay")
      end
    end

    context "when user has already signin and do not send wrong param value" do
      before do
        sell_order
        sign_in user
      end

      it "returns http bad request" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "trap" }
        expect(response).to have_http_status(:bad_request)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment", params: { payment_type: "trap" }
        expect(response.body).to include("is not a valid payment_type")
      end
    end

    context "when user has not signin" do
      before { sell_order }

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/payment"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end
end
