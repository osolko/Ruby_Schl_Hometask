require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'


def is_barber_exist? db, name
	db.execute('SELECT * FROM barber where name=?',[name]).length > 0 
end

def get_db 
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

def seed_db db, barber
	barber.each do |barber|
		if !is_barber_exist? db, barber
			db.execute 'INSERT INTO barber (name) VALUES (?)', [barber]
		end
	end
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS "Users" 
			(	"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
				"username" TEXT, 
				"phone" TEXT,
				"datestamp" TEXT,
				"barber" TEXT,
				"color" TEXT 
			)'

	db.execute 'CREATE TABLE IF NOT EXISTS "barber" 
			(	"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
				"name" TEXT
			)'

		# передаємо в функцію 2 параметри базу (змінна db) 
		# та елементи масива як параметри, для заповнення бази	
	seed_db db, ['Jessie Pinkman','Walter White','Gus Frig','Mike Erthol'] 
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	@error = "somehing wrong..."
	erb :about
end

get '/other' do
	erb :other
end

get '/contacts' do
	erb :contacts
end

get '/visit' do

	db = get_db
	@barberlist = db.execute 'SELECT * FROM barber' 

	erb :visit
end

post '/visit' do
	@username = params[:username]
	@phonenum = params[:phone]
	@datetime = params[:datetime]
	@worker   = params[:barber]
	@color	  = params[:color] 


# multiple validation msg
	def get_validation_msg 
		
		hh ={ :username => "name i required",
		 	   :phone =>    "phone is required",
		 	   :datetime => "date is required"
			}

		@error = hh.select {|key,_| params[key] == ""}.values.join(" , ")
	end

	if get_validation_msg  != ''
		return erb :visit
	end

# f = File.open "public/users.txt", "a"  #а дописуємо в кінець файлу
# 	f.write "Customer : #{@username} , #{@phonenum},  when: #{@datetime} \n\t worker: #{@worker} , hair color: #{@color} \n"
# 	f.close		

	db = get_db
	db.execute 'INSERT INTO Users (username, phone, datestamp, barber, color) 
				VALUES (?, ?, ?, ?, ?)', [@username, @phone, @datetime, @worker, @color]
	db.close


 	erb "<h2>Thank you <b>#{@username.capitalize}</b>, we will contact with you!</h2>"
end


#--------contact------

post '/contacts' do
  # @mail = params[:email]   
  # @msg   = params[:message]

# Pony.options = { :from => 'noreply@example.com', 
# 				 :via => :smtp, 
# 				 :via_options => { 
# 				 	:address => 'smtp.ukr.net', 
# 				    :port          => '2525',
# 			        :enable_starttls_auto => true,
# 			        :user_name      => 'bender2019',
# 			      	:password       => 'K440V7*is7',
# 			      	:authentication => :plain, # :plain, :login, :cram_md5, no auth by default
# 			      	:domain         => "localhost:4567.localdomain"
# 			    	}
# 	      		} 

# Pony.mail(:to => 'bender2019@ukr.net') # Sends mail to bender2019@ukr.net from noreply@example.com using smtp



 #  f = File.open "public/contacts.txt", "a"  #а дописуємо в кінець файлу
 # 	f.write "USER-mail : #{@mail} ,message: #{@msg} \n"
 # 	f.close		

 	erb "Thank you for the msg"
end


#--------admin part------

get '/admin' do
	erb :login_form
end

post '/admin' do
	@login 	= params[:username]
	@pass	= params[:password]

	if @login == 'admin' && @pass == 'admin'
 		send_file 'public/users.txt'
 #		send_file 'public/contacts.txt'
	 	erb :login_form
	else
		@denied = "Wrong credential, access denied"
		erb :login_form
	end
end

get '/showusers' do
 
	db = get_db
	@results = db.execute 'SELECT * FROM Users order by id desc' 

	erb :showusers

end