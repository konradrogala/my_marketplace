class AdsController < ApplicationController
  def index
    @ads = Ad.all
  end

  def create
  end
end
