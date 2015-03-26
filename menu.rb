require 'mongo_mapper'


class Menu
	include MongoMapper::Document
	set_collection_name "menus"
	key :kitchenid, String, :required => true
	key :data, Hash, :required => true, :default => {"items"=>{}}
end