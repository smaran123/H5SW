class NotesController < ApplicationController
  before_filter :is_login?
  before_filter :get_notes
  before_filter :session_types
  before_filter :gmap_json, :only => ["index"]
  #before_filter :trial_period_expired?

  def index
    @note = current_login.notes.new()
  end

  def create
    @note = current_login.notes.new(params[:note])
    @note.save
    respond_to do |format|
      format.js
    end
  end

  def edit
    @note = current_login.notes.find(params[:id])
  end

  def update
    @note = current_login.notes.find(params[:id])

    if @note.update_attribute(params[:note])
      redirect_to notes_path(@note), :notice => t('notes.update.notice')
    else
      render :action => 'edit'
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy
    respond_to do |format|
      format.js
    end
  end

  def get_notes
    if params[:type]=='Customer'
      @notes = search_by_session_type("note", current_login.notes, params[:type].to_s).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    else
      @notes = current_login.notes.where("notable_id=?", session[:job_id]).order("created_at desc").paginate(:per_page => 10, :page => params[:page])
    end
  end
end
