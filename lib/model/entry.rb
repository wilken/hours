module Hours
	class Entry  
	  include DataMapper::Resource  
		property :id, Serial  
		property :company, String, :required => true  
		property :description, String, :required => true
		property :hours, Float, :required => true 
		property :date, Date, :required => true 
		property :user, String, :required => true 

		property :created_at, DateTime  
		property :updated_at, DateTime

	end  
	Entry.raise_on_save_failure = true

	DataMapper.finalize.auto_upgrade!
end