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
    @events = @truck.events.sort {|a,b| b.start_time <=> a.start_time}
    @sensor = @sensor = { :latitude => @events.first.latitude, :longitude => @events.first.longitude, :range => 10 }

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @truck }
    end
  end
end
