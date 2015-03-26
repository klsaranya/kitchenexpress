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
    MongoMapper.connection = Mongo::Connection.new('localhost', 27017 ,:logger => Logger.new(STDOUT))
    MongoMapper.database = 'admin'
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
	  return { url: url}.to_json
  end


end
