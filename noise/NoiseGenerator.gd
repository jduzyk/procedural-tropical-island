extends Node



func get_noise(noise_properties: Dictionary) -> OpenSimplexNoise:
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	return noise;
