class TrucksController < ApplicationController
  # GET /trucks
  # GET /trucks.json
  def index
  	@trucks = Truck.all

  	respond_to do |format|
  	  format.html # index.html.erb
  	  format.json { render json: @trucks }
  	end
  end

  # GET /trucks/1
  # GET /trucks/1.json
  def show
    @truck  = Truck.find params[:id]
    @events = @truck.all_locations :range_limit => 100
    @center = {:center => @truck.map_center, :range => @truck.map_range}

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @truck }
    end
  end
end
