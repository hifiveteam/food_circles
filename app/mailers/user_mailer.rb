﻿class UserMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  ADMIN_EMAIL = 'jk@joinfoodcircles.org'
  SUPPORT_EMAIL = 'support@joinfoodcircles.org'

  #fc_dev: Mandrill credentials for email.
  default from: "\"FoodCircles\" <hey@joinfoodcircles.org>"
  require 'mail'
  Mail.defaults do
    delivery_method :smtp, {:address => "smtp.mandrillapp.com",
                            :port => 587,
                            :domain => "foodcircles.net",
                            :user_name => "jk@joinfoodcircles.org",
                            :password => "uQjfYEZZxNUpGq0oeoVjmw",
                            :authentication => 'plain',
                            :enable_starttls_auto => true}
  end
  #tkxel_dev: Send email upon voucher creation
  def food_mail(email)

    @url = 'http://foodcircles.net/?app=mobile_email'
    mail(:to => email, :reply_to => 'jk@joinfoodcircles.org', :subject => "Your hunger is powerful.")
  end

  def signupsuccess(user)
    mail(
      :to => user.email,
      :subject => "Your hunger is powerful",
      :reply_to => 'hey@joinfoodcircles.org'
    )
  end

  def voucher(user, r)
    @user = user
    @payment = r
    mail(
      :to => @user.email,
      :subject => "Your Voucher for #{r.offer.venue.name}",
      :reply_to => 'hey@joinfoodcircles.org'
    )
  end

  def remind_mail(to)
    mail_for_remind(:to => to, :subject => "Newsletter Mail")
  end

  def social_butterfly(fb)
    mail(:to => ADMIN_EMAIL, :subject => "Social Butterfly Matchmaking", :body => "Someone would like to apply for Social Butterflies! Their profile is #{fb}")
  end

  def restaurant_signup(email, name)
    mail(:to => email, :subject => "Thanks for signing up.", :body => "Someone will get back with you soon, #{name}.")
  end

  def restaurant_notify(email, name)
    mail(:to => ADMIN_EMAIL, :subject => "New Restaurant Request", :body => "#{name} would like to join FoodCircles. Please contact them at #{email}.")
  end

  def company_signup(email, name, company)
    mail(:to => email, :subject => "Thanks for signing up.", :body => "Someone will get back with you soon, #{name}.")
  end

  def company_notify(email, name, company)
    mail(:to => ADMIN_EMAIL, :subject => "New Company Request", :body => "#{name} from #{company} would like to join FoodCircles. Please contact them at #{email}.")
  end

  def nonprofits_signup(email, name)
    mail(:to => email, :subject => "Thanks for your interest.", :body => "Someone will get back with you soon, #{name}.")
  end

  def nonprofits_notify(email, name, organization, website, from_grand_rapids = false)
    subject = "New Buy One, Feed One Request"
    subject += " from Grand Rapids" if from_grand_rapids
    mail(:to => ADMIN_EMAIL, :subject => subject, :body => "#{name} from #{organization} would like to join FoodCircles. Their website is  #{website}. Please contact them at #{email}.")
  end

  def students_signup(email)
    mail(:to => email, :subject => "Thanks for your interest.", :body => "Someone will get back with you soon.")
  end

  def students_notify(email)
    mail(:to => ADMIN_EMAIL, :subject => "New Student Request", :body => "A student would like to join FoodCircles. Please contact them at #{email}.")
  end

  def organizers_signup(email)
    mail(:to => email, :subject => "Thanks for your interest.", :body => "Someone will get back with you soon.")
  end

  def organizers_notify(email, location, address, date, num_diners, occassion, budget, food_preferences, donation, feedback)
    mail(:to => ADMIN_EMAIL, :subject => "New Organizers Request", :body => "An organizer would like to join FoodCircles. They will be dining #{location} on #{date} with #{num_diners} guests. The occasion is #{occassion} with a budget of #{budget}. Their food preferences include #{food_preferences}. They would like to donate #{donation}. They provided the following feedback: #{feedback}. Please contact them at #{email}")
  end

  def nomination_signup(email)
    mail(:to => email, :reply_to => 'hey@joinfoodcircles.org', :subject => "Thanks for your nomination.", :body => "Really appreciate it. Let us know if you have any questions at all.")
  end

  def nomination_notify(email, name, contact, story, feedback)
    mail(:to => ADMIN_EMAIL, :subject => "New Nomination", :body => "A nomination has come in. The name is #{name}. The contact is #{contact}. The story is #{story}. They provided the following feedback: #{feedback}. If need be, reach them at #{email}.")
  end

  def notification_about_available_vouchers(user, venue)
    @name = user.name || "Hey"
    @restaurant_name = venue.name
    @restaurant_url = venue_popup_url(venue)
    mail(:to => user.email, :subject => "Dish Available!")
  end

  def monthly_invoice(venue, months_before = 1)
    d = months_before.month.ago
    @calculations = Calculations::Monthly.new(venue, d.month.to_s + "_" + d.year.to_s)
    mail(:to => venue.email, cc: ADMIN_EMAIL, :reply_to => 'hey@joinfoodcircles.org', :subject => "Your #{@calculations.month} impact report")
  end

  def followup_email(payment)
    @payment = payment
    fun = @payment.charity.follow_up_notes
    used_fun = @payment.user.follow_up_notes
    available_fun = fun - used_fun
    available_photos = @payment.charity.charity_photos

    if available_photos.size > 0
      selected_photo = available_photos.sample
      @img_photo = Foodcircles::Application.config.action_mailer.asset_host + selected_photo.photo.remote_url
    else
      @img_photo = ActionController::Base.helpers.asset_path("mails/followup-image-sample.png")
    end

    if available_fun.size > 0
      @selected_fun = available_fun.sample
      @payment.user.follow_up_notes << @selected_fun
    else
      @selected_fun = nil
    end


    mail(:to => @payment.user.email, :subject => "A followup from #{@payment.charity.name}")
  end

  def postcard_notification(postcard)
    @postcard = postcard
    mail(:to => SUPPORT_EMAIL, :subject => "Postcard Alert")
  end

  def voucher_expiring_soon(payment_id)
    payment = Payment.find_by_id(payment_id)
    @payment = payment.decorate

    mail(:to => payment.user.email, :reply_to => 'used@inbound.foodcircles.net', :subject => "Hanging out with friends this week? Grabbing food could be an option")
  end

  def badge_email(email, category, title)
    @category = category
    @title = title
    mail(
      :to => email,
      :from => 'hey@joinfoodcircles.org',
      :cc => 'gs@joinfoodcircles.org',
      :reply_to => 'gs@joinfoodcircles.org',
      :subject => 'Have a little something for you. Need address.'
    )
  end

end
