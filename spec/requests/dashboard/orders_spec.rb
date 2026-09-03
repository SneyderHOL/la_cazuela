require 'rails_helper'

RSpec.describe "Orders", type: :request do
  include_context "with order for requests"


  describe "GET /dashboard/orders" do
    context "when user has already signin" do
      before { sign_in user }

      it "returns http success" do
        get "/dashboard/orders"
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        get "/dashboard/orders"
        expect(response.body).to include("Manage orders.")
      end
    end

    context "when user has not signin" do
      it "returns http redirect" do
        get "/dashboard/orders"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/orders"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/orders"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "GET /dashboard/sell_orders/:sell_order_id/orders/summary" do
    let(:sell_order) { create(:sell_order, :with_allocation) }

    context "when user has already signin" do
      before do
        sell_order
        sign_in user
      end

      it "returns http success" do
        get "/dashboard/sell_orders/#{sell_order.id}/orders/summary"
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        get "/dashboard/sell_orders/#{sell_order.id}/orders/summary"
        expect(response.body).to include("Orders Summary")
      end
    end

    context "when user has not signin" do
      it "returns http redirect" do
        get "/dashboard/sell_orders/#{sell_order.id}/orders/summary"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/sell_orders/#{sell_order.id}/orders/summary"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/sell_orders/#{sell_order.id}/orders/summary"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "GET /dashboard/orders/:id" do
    context "when user has already signin" do
      before do
        order
        sign_in user
      end

      it "returns http success" do
        get "/dashboard/orders/#{order.id}"
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        get "/dashboard/orders/#{order.id}"
        expect(response.body).to include("Order details")
      end
    end

    context "when user has not signin" do
      before { order }

      it "returns http redirect" do
        get "/dashboard/orders/#{order.id}"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/orders/#{order.id}"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/orders/#{order.id}"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "GET /dashboard/sell_orders/:sell_order_id/orders/new" do
    let(:sell_order) { create(:sell_order, :with_allocation) }

    context "when user has already signin" do
      before do
        order
        sign_in user
      end

      it "returns http success" do
        get "/dashboard/sell_orders/#{order.sell_order.id}/orders/new"
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        get "/dashboard/sell_orders/#{order.sell_order.id}/orders/new"
        expect(response.body).to include("New Order")
      end
    end

    context "when user has not signin" do
      before { order }

      it "returns http redirect" do
        get "/dashboard/sell_orders/#{order.sell_order.id}/orders/new"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/sell_orders/#{order.sell_order.id}/orders/new"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/sell_orders/#{order.sell_order.id}/orders/new"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "GET /dashboard/orders/:id/edit" do
    context "when user has already signin" do
      before do
        order
        sign_in user
      end

      it "returns http success" do
        get "/dashboard/orders/#{order.id}/edit"
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        get "/dashboard/orders/#{order.id}/edit"
        expect(response.body).to include("Edit Order")
      end
    end

    context "when user has already signin and order is not editable" do
      before do
        order.update(status: :packed)
        sign_in user
      end

      it "returns http redirect" do
        get "/dashboard/orders/#{order.id}/edit"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/orders/#{order.id}/edit"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/orders/#{order.id}/edit"
        follow_redirect!
        expect(response.body).to include("This order can no longer be edited.")
      end
    end

    context "when user has not signin" do
      before { order }

      it "returns http redirect" do
        get "/dashboard/orders/#{order.id}/edit"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        get "/dashboard/orders/#{order.id}/edit"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        get "/dashboard/orders/#{order.id}/edit"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "POST /dashboard/sell_orders/:sell_order_id/orders" do
    let(:sell_order) { create(:sell_order, :with_allocation) }
    let(:order_products) do
      {
        order_products_attributes: {
          "0" => {
            product_id: beverage.id,
            quantity: 1,
            note: "no sugar"
          },
          "1" => {
            product_id: beverage.id,
            quantity: 1,
            note: ""
          },
          "2" => {
            product_id: dish.id,
            quantity: 1,
            note: ""
          }
        }
      }
    end

    context "when user has already signin and creates the order" do
      before do
        sell_order
        sign_in user
      end

      it "creates the order" do
        expect { post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params }.to change(Order, :count).by(1)
      end

      it "creates the order_products" do
        expect { post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params }.to change(OrderProduct, :count).by(3)
      end

      it "returns http found" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params
        expect(response).to have_http_status(:found)
      end

      it "returns http success" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params
        follow_redirect!
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params
        follow_redirect!
        expect(response.body).to include("Order created successfully.")
      end
    end

    context "when user has already signin but product_id param does not exist" do
      let(:order_products) do
      {
        order_products_attributes: {
          "0" => {
            product_id: 1,
            quantity: 1,
            note: "no sugar"
          },
          "1" => {
            product_id: 1,
            quantity: 1,
            note: ""
          },
          "2" => {
            product_id: 2,
            quantity: 1,
            note: ""
          }
        }
      }
    end

      before do
        sell_order
        sign_in user
      end

      it "does not creates the order" do
        expect { post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params }.not_to change(Order, :count)
      end

      it "creates the order_products" do
        expect { post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params }.not_to change(OrderProduct, :count)
      end

      it "returns http unprocessable_content" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params
        expect(response.body).to include("Validation failed: Order products product must exist")
      end
    end

    context "when user has already signin but missing order param" do
      let(:body_params) { order_products }

      before do
        sell_order
        sign_in user
      end

      it "does not creates the order" do
        expect { post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params }.not_to change(Order, :count)
      end

      it "creates the order_products" do
        expect { post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params }.not_to change(OrderProduct, :count)
      end

      it "returns http bad_request" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params
        expect(response).to have_http_status(:bad_request)
      end

      it "return valid content" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders", params: body_params
        expect(response.body).to include("param is missing or the value is empty or invalid: order")
      end
    end

    context "when user has not signin" do
      before { sell_order }

      it "returns http redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        post "/dashboard/sell_orders/#{sell_order.id}/orders"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "PUT /dashboard/orders/:id" do
    let(:order) { build(:order, :with_sell_order) }
    let(:lemonade_with_note) { create(:order_product, product: beverage, quantity: 1, note: "no sugar", order:) }
    let(:lemonade_without_note) { create(:order_product, product: beverage, quantity: 1, order:) }
    let(:main_dish) { create(:order_product, product: dish, quantity: 1, order:) }
    let(:order_products) do
      {
        order_products_attributes: {
          "0" => {
            id: lemonade_with_note.id,
            product_id: beverage.id,
            quantity: 2,
            note: "no sugar"
          },
          "1" => {
            id: main_dish.id,
            product_id: dish.id,
            quantity: 2,
            note: ""
          },
          "2" => {
            id: lemonade_without_note.id,
            _destroy: 1
          }
        }
      }
    end

    context "when user has already signin and updates the order" do
      before do
        order.save(validate: false)
        lemonade_with_note
        lemonade_without_note
        main_dish
        sign_in user
      end

      it "updates the order" do
        expect { put "/dashboard/orders/#{order.id}", params: body_params }.not_to change(Order, :count)
      end

      it "updates the order_products" do
        expect { put "/dashboard/orders/#{order.id}", params: body_params }.to change(OrderProduct, :count).by(-1)
      end

      it "updates the quantity of lemonade_with_note" do
        expect { put "/dashboard/orders/#{order.id}", params: body_params }.to change { lemonade_with_note.reload.quantity }.from(1).to(2)
      end

      it "updates the quantity of main_dish" do
        expect { put "/dashboard/orders/#{order.id}", params: body_params }.to change { main_dish.reload.quantity }.from(1).to(2)
      end

      it "destroys lemonade_without_note" do
        put "/dashboard/orders/#{order.id}", params: body_params
        expect(OrderProduct.where(id: lemonade_without_note.id)).not_to exist
      end

      it "returns http found" do
        put "/dashboard/orders/#{order.id}", params: body_params
        expect(response).to have_http_status(:found)
      end

      it "returns http success" do
        put "/dashboard/orders/#{order.id}", params: body_params
        follow_redirect!
        expect(response).to have_http_status(:success)
      end

      it "return valid content" do
        put "/dashboard/orders/#{order.id}", params: body_params
        follow_redirect!
        expect(response.body).to include("Order updated successfully.")
      end
    end

    context "when user has not signin" do
      before { order.save(validate: false) }

      it "returns http redirect" do
        put "/dashboard/orders/#{order.id}"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        put "/dashboard/orders/#{order.id}"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        put "/dashboard/orders/#{order.id}"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "PATCH /dashboard/orders/:id/confirm" do
    context "when user has already signin and performs action" do
      before do
        order
        sign_in user
      end

      it "returns http success" do
        patch "/dashboard/orders/#{order.id}/confirm"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        patch "/dashboard/orders/#{order.id}/confirm"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid content" do
        patch "/dashboard/orders/#{order.id}/confirm"
        follow_redirect!
        expect(response.body).to include("Order was sent to kitchen.")
      end
    end

    context "when user has already signin and is unable to perform action" do
      before do
        order.update(status: :processing)
        sign_in user
      end

      it "returns http unprocessable content" do
        patch "/dashboard/orders/#{order.id}/confirm"
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "return valid flash alert message" do
        patch "/dashboard/orders/#{order.id}/confirm"
        expect(response.body).to include("Unable to perform that action.")
      end
    end

    context "when user has not signin" do
      before { order }

      it "returns http redirect" do
        patch "/dashboard/orders/#{order.id}/confirm"
        expect(response).to have_http_status(:found)
      end

      it "returns http ok after redirect" do
        patch "/dashboard/orders/#{order.id}/confirm"
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "return valid flash alert message" do
        patch "/dashboard/orders/#{order.id}/confirm"
        follow_redirect!
        expect(response.body).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  # describe "DELETE /dashboard/orders/:id" do
  #   context "when user has already signin" do
  #     before do
  #       order
  #       sign_in user
  #     end

  #     it "returns http success" do
  #       delete "/dashboard/orders/#{order.id}"
  #       expect(response).to have_http_status(:ok)
  #     end

  #     it "return valid content" do
  #       delete "/dashboard/orders/#{order.id}"
  #       expect(response.body).to include("Order details")
  #     end
  #   end

  #   context "when user has not signin" do
  #     before { order }

  #     it "returns http redirect" do
  #       delete "/dashboard/orders/#{order.id}"
  #       expect(response).to have_http_status(:found)
  #     end

  #     it "returns http ok after redirect" do
  #       delete "/dashboard/orders/#{order.id}"
  #       follow_redirect!
  #       expect(response).to have_http_status(:ok)
  #     end

  #     it "return valid flash alert message" do
  #       delete "/dashboard/orders/#{order.id}"
  #       follow_redirect!
  #       expect(response.body).to include("You need to sign in or sign up before continuing.")
  #     end
  #   end
  # end
end
