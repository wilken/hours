DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/db/entries_#{ENV['RACK_ENV']||'development'}.db")  
