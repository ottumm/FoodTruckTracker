class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    normalize_params!
    cookies[:id] = SecureRandom.hex(10) unless cookies[:id]

    if geo_sensor?
      save_request
      @events = Event.find_nearby params, client_time_zone
    elsif params[:date] == "all"
      @events = Event.all
    else
      @events = Event.find_today client_time_zone, params[:date]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def normalize_params!
    params[:latitude] = params[:latitude].to_f unless params[:latitude].nil?
    params[:longitude] = params[:longitude].to_f unless params[:longitude].nil?
    params[:range] = params[:range].to_f unless params[:range].nil?
  end

  def geo_sensor?
    params[:lat] && params[:long]
  end

  def client_time_zone
    params[:tz] ? ActiveSupport::TimeZone[params[:tz].to_i] : "Pacific Time (US & Canada)"
  end

  def save_request!
    params[:client_id] = cookies[:id]
    @request = Request.new params
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
