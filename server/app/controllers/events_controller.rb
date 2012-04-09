class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    cookies[:id] = SecureRandom.hex(10) unless cookies[:id]
    initialize_sensor

    @events = Event.find_nearby @sensor, @sensor[:range], request_date, client_time_zone
    @current_date = formatted_date
    if request_date != "all"
      @previous_day_path = index_path(request_date - 1.day, @sensor[:range])
      @next_day_path = index_path(request_date + 1.day, @sensor[:range])
    end
    @decrease_range_path = index_path(request_date, @sensor[:range] / 2)
    @increase_range_path = index_path(request_date, @sensor[:range] * 2)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def index_path date, range
    "/events?latitude=#{@sensor[:latitude]}&longitude=#{@sensor[:longitude]}&range=#{range}&date=#{date}"
  end

  def formatted_date
    date = request_date
    if date == "all"
      "All Dates"
    elsif date.beginning_of_day == Time.now.in_time_zone(client_time_zone).beginning_of_day
      "Today"
    else
      date.strftime "%a, %b %e"
    end
  end

  def request_date
    if params[:date] == "all"
      "all"
    elsif params[:date]
      Time.parse(params[:date]).in_time_zone client_time_zone
    else
      Time.now.in_time_zone client_time_zone
    end
  end

  def initialize_sensor
    range = params[:range] ? params[:range].to_f : 5.0
    if params[:latitude] && params[:longitude]
      @sensor = { :latitude => params[:latitude].to_f, :longitude => params[:longitude].to_f, :range => range }
      save_request!
    else
      @sensor = { :latitude => 37.79457002, :longitude => -122.41135877, :range => range }
    end
  end

  def save_request!
    @request = Request.new({:latitude => params[:latitude], :longitude => params[:longitude], :client_id => cookies[:id]})
    @request.save or logger.warn "Error saving client request: #{@request.errors}"
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  def find_or_create_tweet
    tweet = Tweet.find_or_create_by_tweet_id params[:tweet][:tweet_id]
    tweet.update_attributes params[:tweet]
    tweet.truck = find_or_create_truck
    tweet.save
    tweet
  end

  def find_or_create_truck
    truck = Truck.find_or_create_by_name params[:truck][:name]
    truck.update_attributes params[:truck]
    truck
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @event.tweets.push find_or_create_tweet

    respond_to do |format|
      if @event.save
        Event.merge_all!
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /events/1/correct
  # POST /events/1/correct.json
  def correct
    @event = Event.find(params[:id])
    @correction = Correction.find(params[:correction_id])

    @event.update_attributes(ActiveSupport::JSON.decode @correction.to_json(:except => [:id, :event_id, :updated_at]))
    @event.verified = true

    respond_to do |format|
      if @event.save
        Event.merge_all!
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
end
