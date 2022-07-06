tool
extends Sprite


func _ready():
	
	var image = Image.new();
	image.create(100, 100, false, Image.FORMAT_RGBA8)
	

	image.lock();
	for y in 50:
		for x in 50:
			image.set_pixel(x,y, Color.red)
	
	image.unlock();
	
	var image_texture = ImageTexture.new();	
	image_texture.create_from_image(image);
	texture = image_texture;
