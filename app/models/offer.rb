class Offer < ActiveRecord::Base
  include AlwaysOpen

  belongs_to :venue
  

  # DEPRECATED, SOON TO BE DELETED
  has_many :open_times, :as => :openable, :dependent => :destroy


  has_and_belongs_to_many :category
  has_many :payments

  attr_accessible :image, :name, :venue_id, :category_ids, :price, :original_price, :total, :available, :min_diners, :details
  attr_accessor :image

  has_attached_file :image, styles: {
    deal: '253x163#',
    timeline: '205x155#',
    medium: '300x300>'
  }

  after_create :ensure_always_open


  def as_json(options={})
    { :id => self.id,
      :title => self.name,
      :details => self.details,
      :minimum_diners => self.min_diners,
      :times => self.times || "Not Available",
      :original_price => self.original_price,
      :price => self.price
    }
  end

  def self.currently_available(time=Time.now)
    t = ((time - time.beginning_of_week) / 60) + 300
    self.joins(:open_times).
      where("? BETWEEN open_times.start AND open_times.end", t).
      uniq
  end

  def self.not_available
    t = ((Time.now - Time.now.beginning_of_week) / 60) + 300
    day_end = ((Time.now.end_of_day - Time.now.beginning_of_week) / 60) + 300
    self.joins(:open_times).
      where("open_times.start BETWEEN :now AND :day_end", {now: t, day_end: day_end}).
      uniq
  end

end
