class AdsController < ApplicationController
  before_action :set_ad, only: %i[ show edit update destroy ]

  # GET /ads or /ads.json
  def index
    @ads = Ad.order(created_at: :desc)
  end

  # GET /ads/1 or /ads/1.json
  def show
  end

  # GET /ads/new
  def new
    @ad = Ad.new
  end

  # GET /ads/1/edit
  def edit
  end

  # POST /ads or /ads.json
  def create
    @ad = Ad.new(ad_params)

    respond_to do |format|
      if @ad.save
        format.turbo_stream do
          render turbo_stream:
            [
              turbo_stream.update("new_ad", partial: "form", locals: { ad: Ad.new }),
              turbo_stream.prepend("ads", partial: "ad", locals: { ad: @ad })
            ]
        end
        format.html { redirect_to ad_url(@ad), notice: "Ad was successfully created." }
        format.json { render :show, status: :created, location: @ad }
      else
        format.turbo_stream do
          render turbo_stream:
           [ turbo_stream.update("new_ad", partial: "form", locals: { ad: @ad }) ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ads/1 or /ads/1.json
  def update
    respond_to do |format|
      if @ad.update(ad_params)
        format.html { redirect_to ad_url(@ad), notice: "Ad was successfully updated." }
        format.json { render :show, status: :ok, location: @ad }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ad.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ads/1 or /ads/1.json
  def destroy
    @ad.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@ad)
        ]
      end
      format.html { redirect_to ads_url, notice: "Ad was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def search
    sanitized_param = ActiveRecord::Base.sanitize_sql_like(search_params[:title_search])

    @ads = Ad.where("title ILIKE ?", "%#{sanitized_param}%")
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("search_result", partial: "search_results", locals: { ads: @ads })
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_ad
    @ad = Ad.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def ad_params
    params.require(:ad).permit(:title, :description)
  end

  def search_params
    params.permit(:title_search)
  end
end
