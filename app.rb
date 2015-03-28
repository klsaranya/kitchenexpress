require 'bundler'
require 'bundler/setup'
require './itemstore'
require 'mongo_mapper'
require 'sinatra/cross_origin'
require "aws/s3"

Bundler.require


class Admin < Sinatra::Base
  register Sinatra::CrossOrigin
  set :method_override, true
  set :allow_origin, :any
  set :allow_methods, [:get, :post, :options]
  
  not_found do
    erb :error
  end

  configure :development do
    register Sinatra::Reloader
  end

  configure do
    regex_match = /.*:\/\/(.*):(.*)@(.*):(.*)\//.match("mongodb://kitchenexpress:easymoby@ds053828.mongolab.com:53828/kitchenexpress")
    host = regex_match[3]
    port = regex_match[4]
    db_name = regex_match[1]
    pw = regex_match[2]
    MongoMapper.connection = Mongo::Connection.new(host,port)
    MongoMapper.database = db_name
    MongoMapper.database.authenticate(db_name, pw)
    enable :cross_origin

  end

  get '/' do
  return %Q{
    <form action="imageupload" method="post" accept-charset="utf-8" enctype="multipart/form-data">
      <div>
        <input type="file" name="file" value="" id="file">
      </div>
      <div>
        <input type="submit" value="Upload &uarr;">
      </div>
    </form>
  }
end


  #   get '/' do
  #   return %Q{
  #     <form action="kitchen/<%= kitchenid %>/menu" method="post" accept-charset="utf-8" enctype="multipart/form-data">
  #       <div>
  #         <input type='text' name='kitchenid'/><br/>
  #         <input type='text' name='data'/><br/>
  #       </div>
  #       <div>
  #         <input type="submit">
  #       </div>
  #     </form>
  #   }
  # end

  get '/kitchen/:id/menu' do |id|
  	content_type 'application/json'
  	menu = ItemStore.find(id)
  	menu.data.to_json
  end

  post '/kitchen/:id/menu' do |id|
  	content_type 'application/json'
  	params = JSON.parse(request.env["rack.input"].read)
  	puts params
    ItemStore.updateOrCreate(id,params)
   	{"success" => 1 }.to_json
  end

  # wildcard route
  options '*' do

  end

  post '/imageupload' do
	  awskey     = 'AKIAJZBWURL6MABK22JA'
	  awssecret  = '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'
	  bucket     = 'kitchenexpress-test'
	  file       = params[:file][:tempfile]
	  filename   = 'images/'+ SecureRandom.hex + params[:file][:filename].to_s
	  AWS::S3::Base.establish_connection!(
	    :access_key_id     => awskey,
	    :secret_access_key => awssecret
	  )
	  AWS::S3::S3Object.store(
	    filename,
	    open(file.path),
	    bucket,
	    :access => :public_read
	  )
	  url = "https://#{bucket}.s3.amazonaws.com/#{filename}"
    puts url
	  return { url: url}.to_json

  end


end
