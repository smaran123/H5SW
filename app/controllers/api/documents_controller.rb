class Api::DocumentsController < Api::BaseController
  before_filter :is_login?
  skip_before_filter :verify_authenticity_token
  
  #curl -X GET -d 'type=Job&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/documents.json
  #curl -X GET -d 'type=Customer&api_key=ypVSipVXC2Yd377jz58A' http://localhost:3000/api/documents.xml
  def index
     @documents = current_company.documents.where(:documentable_type => params[:type] )
     respond_to do |format|
       format.xml { render :xml => @documents }
       format.json { render :json => @documents }
     end
  end
  
  # curl -X POST -F document=/home/rails/Documents/smo/SMO-23jun13.pdf -F 'document[documentable_type]=Job&api_key=ypVSipVXC2Yd377jz58A'  http://localhost:3000/api/documents.json
  def create
   @document = current_company.documents.new(params[:document])
    if @document.save
      response_message = {:message => "Document uploaded successfully.", :document => @document}
    else
      response_message = {:message => "Please Try Again."}
    end
    puts @document.errors.inspect
    respond_to do |format|
      format.xml{ render :xml => response_message }
      format.json{ render :json => response_message }
    end
  end
  
#curl -X POST -F api_key="3GCwifyMXudbS9UpBAyc" -F document[documentable_type]="Job" -F document[document]=@"/home/rails/Documents/SMO-23jun13.pdf" http://localhost:3000/api/documents.json
  def destroy
    @document = Document.find(params[:id])
    if @document.destroy
      response_message = {:message => "Document was deleted successfully.", :document => @document}
    else
      response_message = {:message => "Document deletion failed.Please try again."}
    end
    respond_to do |format|
      format.xml { render :xml => response_message }
      format.json { render :json => response_message }
    end
  end
end
