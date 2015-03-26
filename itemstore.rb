require './menu'

class ItemStore
  def self.all
  	Menu.all
  end

  def self.create(attributes)
    Menu.create(attributes)
  end

  def self.find(id)
  	x = Menu.where(:kitchenid => id).first
  	if !x 
  		x = Menu.new
  	end
  	x
  end

  def self.updateOrCreate(id,data)
  	x = Menu.where(:kitchenid => id).first
  	if x 
  		x.data = data
  		x.save
  	else
  		x = Menu.new
  		x.kitchenid = id
  		x.data = data
  		x.save
  	end
  end
end