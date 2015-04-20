class Sola::InstrumentsController < ApplicationController
  before_action :set_sola_instrument, only: [:show, :edit, :update, :destroy]

  # GET /sola/instruments
  # GET /sola/instruments.json
  def index
    @sola_instruments = Sola::Instrument.all
  end

  # GET /sola/instruments/1
  # GET /sola/instruments/1.json
  def show
  end

  # GET /sola/instruments/new
  def new
    @sola_instrument = Sola::Instrument.new
  end

  # GET /sola/instruments/1/edit
  def edit
  end

  # POST /sola/instruments
  # POST /sola/instruments.json
  def create
    @sola_instrument = Sola::Instrument.new(sola_instrument_params)

    respond_to do |format|
      if @sola_instrument.save
        format.html { redirect_to @sola_instrument, notice: 'Instrument was successfully created.' }
        format.json { render :show, status: :created, location: @sola_instrument }
      else
        format.html { render :new }
        format.json { render json: @sola_instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sola/instruments/1
  # PATCH/PUT /sola/instruments/1.json
  def update
    respond_to do |format|
      if @sola_instrument.update(sola_instrument_params)
        format.html { redirect_to @sola_instrument, notice: 'Instrument was successfully updated.' }
        format.json { render :show, status: :ok, location: @sola_instrument }
      else
        format.html { render :edit }
        format.json { render json: @sola_instrument.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sola/instruments/1
  # DELETE /sola/instruments/1.json
  def destroy
    @sola_instrument.destroy
    respond_to do |format|
      format.html { redirect_to sola_instruments_url, notice: 'Instrument was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sola_instrument
      @sola_instrument = Sola::Instrument.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sola_instrument_params
      params[:sola_instrument]
    end
end
