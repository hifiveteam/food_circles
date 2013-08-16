class TimelineController < ApplicationController
  include PaymentCommons

  before_filter :authenticate_user!
  def index
    get_friends_purchases
    load_payments

    @weekly_total = current_user.payments.where("created_at > ?", Time.now - 1.week).collect{ |p| p.amount }.sum
    current_vouchers = Voucher.where("start_date <= ? and end_date >= ?", Time.now, Time.now)
    @total_vouchers = current_vouchers.collect{ |v| v.total }.sum
    @available_vouchers = current_vouchers.collect{ |v| v.available }.sum
  end
end
