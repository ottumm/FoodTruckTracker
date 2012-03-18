class CorrectionsController < ApplicationController
  # GET /corrections
  # GET /corrections.json
  def index
    @corrections = Correction.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @corrections }
    end
  end

  # GET /corrections/1
  # GET /corrections/1.json
  def show
    @correction = Correction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @correction }
    end
  end

  # GET /corrections/new
  # GET /corrections/new.json
  def new
    @correction = Correction.new
    @correction.event = Event.find params[:event_id]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @correction }
    end
  end

  # GET /corrections/1/edit
  def edit
    @correction = Correction.find(params[:id])
  end

  # POST /corrections
  # POST /corrections.json
  def create
    @correction = Correction.new(params[:correction])

    respond_to do |format|
      if @correction.save
        format.html { redirect_to @correction, notice: 'Correction was successfully created.' }
        format.json { render json: @correction, status: :created, location: @correction }
      else
        format.html { render action: "new" }
        format.json { render json: @correction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /corrections/1
  # PUT /corrections/1.json
  def update
    @correction = Correction.find(params[:id])

    respond_to do |format|
      if @correction.update_attributes(params[:correction])
        format.html { redirect_to @correction, notice: 'Correction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @correction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /corrections/1
  # DELETE /corrections/1.json
  def destroy
    @correction = Correction.find(params[:id])
    @correction.destroy

    respond_to do |format|
      format.html { redirect_to corrections_url }
      format.json { head :no_content }
    end
  end
end
