begin
	`thin stop`
rescue
end

begin
	`thin -d start`
rescue
end
