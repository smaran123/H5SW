class Api::NotesController < Api::BaseController
    before_filter :is_login?
    skip_before_filter :verify_authenticity_token
  
  #curl -X GET -d 'type=Job&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/notes.json
  #curl -X GET -d 'type=Customer&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/notes.json
  def index
     @notes = current_company.notes.where(:notable_type => params[:type])
     respond_to do |format|
       format.xml{render :xml => @notes}
       format.json{render :json => @notes}
     end
  end
  
  #curl -X POST -d 'note[note_type]=Site Notes&note[description]=hello&note[notable_id]=40&note[notable_type]=Customer&note[jobsite_id]=23&api_key=ypVSipVXC2Yd377jz58A'  http://localhost:3000/api/notes.json
  #curl -X POST -d 'note[note_type]=Site Notes&note[description]=hello&note[notable_id]=40&note[notable_type]=Job&note[jobsite_id]=23&api_key=ypVSipVXC2Yd377jz58A'  http://localhost:3000/api/notes.xml
  def create
    @note = current_company.notes.new(params[:note])
    if @note.save
     response_message = {:message => "Note was successfully created.", :note => @note }
    else
      response_message = {:message => "Note creation failed.Please try again"}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
    end
    
  #curl -X PUT -d note[note_type]=Site Notes&note[description]=hello&note[notable_id]=40&note[notable_type]=Customer&note[jobsite_id]=23&api_key=ypVSipVXC2Yd377jz58A'  http://localhost:3000/api/notes/id.json
  #curl -X PUT -d note[note_type]=Site Notes&note[description]=hello&note[notable_id]=40&note[notable_type]=Job&note[jobsite_id]=23&api_key=ypVSipVXC2Yd377jz58A'  http://localhost:3000/api/notes/id.xml
  def update
    @note = current_company.notes.find(params[:id])
    if @note.update_attributes(params[:note])
      response_message = {:message => "Note was successfully updated.", :note => @note }
    else
      response_message = {:message => "Note updation failed.Please try again"}
    end
    respond_to do |format|
      format.xml{ render :xml => response_message}
      format.json{ render :json => response_message}
    end
  end
end
