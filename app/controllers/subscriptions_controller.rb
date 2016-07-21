class SubscriptionsController < ApplicationController
  before_filter :is_login?

  def index
    # display trial expires message and subscription button
  end

  def create
    # add data to our application
    @subscription = Subscription.new(params[:subscription])
    @current_login = Company.find(current_login.id)
    @user = current_login.users.where(:smo_user => "true").count
    # create Stripe customer
    customer = Stripe::Customer.create(
      description: current_login.email, 
      card: @subscription.stripe_card_token
    )
    
    # create Stripe charge
    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @subscription.plan.to_i * 100.to_i * (params[:no_of_users].to_i),
      :description => "Company #{current_login.email} had subscribed in SMO",
      :currency    => 'usd'
    )
    
    @subscription.amount = @subscription.plan.to_i * (params[:no_of_users].to_i)
    @no_of_users = params[:no_of_users]
    @subscription.save
    if expired_on <= 0
      if (params[:subscription][:plan] == "20")
        @day = (Date.today + 30)
      elsif (params[:subscription][:plan] == "60")
        @day = (Date.today + 90)
      elsif (params[:subscription][:plan] == "120")
        @day = (Date.today+ 180)
      else
        @day = (Date.today + 365)
      end 
      current_login.update_attributes(:subscription_date => @day.to_datetime, :status => "paid", :no_of_users => @no_of_users, :plan => @subscription.plan, :stripe_card_token => @subscription.stripe_card_token)
    else
    
    @days_left = (Date.today - current_login.subscription_date.to_date).round
    if (params[:subscription][:plan] == "20")
      @day = (@days_left + 30)
    elsif (params[:subscription][:plan] == "60")
      @day = (@days_left + 90)
    elsif (params[:subscription][:plan] == "120")
      @day = (@days_left + 180)
    else
      @day = (@days_left + 365)
    end 
    @value = (Date.today + @day)
    current_login.update_attributes(:subscription_date => @value.to_datetime,:status => "paid", :no_of_users => @no_of_users, :plan => @subscription.plan, :stripe_card_token => @subscription.stripe_card_token)
    end
  rescue Stripe::CardError => e
    flash[:alert] = e.message
    redirect_to subscriptions_path
   
    #    if @subscription.save_with_payment
    #      redirect_to dashboards_index_path, :notice => "Thank you for subscribing"
    #    else
    #      render 'new'
    #    end
  end
  
  def billing
    @user = current_login.users.where(:smo_user => "true").paginate(:per_page => 10, :page => params[:page1])
    @subscription = Subscription.where(:company_id => current_login.id).paginate(:per_page => 10, :page => params[:page2])
  end
end
