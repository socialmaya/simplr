class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :invite_only

  def my_orders
    @orders = current_user.orders
  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @user = current_user
    @cart = @user.my_cart
    @products = @cart.products
    @order = @user.orders.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @user = current_user
    @cart = @user.my_cart
    @order = @user.orders.new(order_params)
    @order.product_token_list = @cart.product_token_list
    @order.total = @cart.total

    # Use the TrustCommerce test servers
    ActiveMerchant::Billing::Base.mode = :test

    gateway = ActiveMerchant::Billing::TrustCommerceGateway.new(
                :login => 'TestMerchant',
                :password => 'password')

    # ActiveMerchant accepts all amounts as Integer values in cents
    amount = @order.total.cents  # $10.00

    # The card verification value is also known as CVV2, CVC2, or CID
    credit_card = ActiveMerchant::Billing::CreditCard.new(
                    :first_name         => params[:first_name],
                    :last_name          => params[:last_name],
                    :number             => params[:card_number],
                    :month              => '8',
                    :year               => Time.now.year+1,
                    :verification_value => params[:verification_value])

    respond_to do |format|
      # Validating the card automatically detects the card type
      if @order.save and credit_card.validate.empty?
        # empty out cart after order
        @cart.update product_token_list: "[]"

        # Capture $10 from the credit card
        response = gateway.purchase(amount, credit_card)

        if response.success?
          format.html {
            redirect_to @order, notice: "Successfully charged $#{sprintf("%.2f", amount / 100)} to the credit card #{credit_card.display_number}"
          }
        else
          format.html {
            redirect_to @order, notice: "Credit card could not be successfully charged..."
          }
        end

        format.json { render :show, status: :created, location: @order }
      else
        format.html {
          redirect_to store_path, notice: "Credit card could not be successfully charged..."
        }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    if params[:token]
      @order = Order.find_by_unique_token(params[:token])
      @order ||= Order.find_by_id(params[:token])
    else
      @order = Order.find_by_id(params[:id])
      @order ||= Order.find_by_unique_token(params[:id])
    end
    redirect_to '/404' unless @order
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.fetch(:order, {})
  end
end
