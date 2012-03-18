class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    cookies[:id] = SecureRandom.hex(10) unless cookies[:id]
    initialize_sensor

    @events = Event.find_nearby @sensor, @sensor[:range], params[:date], client_time_zone

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def initialize_sensor
    if params[:latitude] && params[:longitude] && params[:range]
      @sensor = { :latitude => params[:latitude].to_f, :longitude => params[:longitude].to_f, :range => params[:range].to_f }
      save_request!
    else
      @sensor = { :latitude => 37.79457002, :longitude => -122.41135877, :range => 50 }
    end
  end

  def client_time_zone
    params[:tz] ? ActiveSupport::TimeZone[params[:tz].to_i] : "Pacific Time (US & Canada)"
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

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  def find_or_create_tweet
    if Tweet.exists? params[:tweet][:tweet_id]
      return Tweet.find params[:tweet][:tweet_id]
    end

    tweet = Tweet.new(params[:tweet])
    tweet.save
    tweet
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(params[:event])
    @event.tweets.push find_or_create_tweet

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
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
