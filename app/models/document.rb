class Document < ActiveRecord::Base
  attr_accessible :description, :document, :company_id, :documentable_id, :documentable_type, :jobsite_id, :document_file_name
  belongs_to :documentable, :polymorphic => true
  #has_attached_file :document
  validates_format_of :document_file_name, :with => %r{\.(docx|doc|pdf|zip|jpg|jpeg|gif|png|tif|tiff|txt|ppt|pptx|xls|xlsx)$}i, :message => "Only allow docx|doc|pdf|zip|jpg|jpeg|gif|png|tif|tiff|txt|ppt|pptx|xls|xlsx."
  has_attached_file :document,
    :storage => :s3,
    :whiny => false,
    :s3_credentials => {"access_key_id" => ENV["S3_ACCESS_KEY_ID"], "secret_access_key" => ENV["S3_SECRET_ACCESS_KEY"]},
    :s3_host_name => 's3-us-west-2.amazonaws.com',
    :path => "uploaded_files/document/:id/:basename.:extension",
    :bucket => S3_BUCKET_NAME if Rails.env == "production"

  #has_attached_file :document,:styles => {:original => "900x900>", :default => "280x190>" } if Rails.env == "development"
    
  def self.search(search)
    if search
      where('document_file_name LIKE?', "%#{search}%")
    else
      scoped
    end
  end

  #Helper method to determine whether or not an attachment is an image.
  def document?
    document_content_type =~ %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|png|x-png)$}
  end

  private
  
  def resize_images
    return false unless document?
  end
end