def haversine_distance(p1, p2)
	def to_rad angle
		angle/180 * Math::PI
	end

	def sin2 r
		Math.sin(r) * Math.sin(r)
	end

	def cos2 r
		Math.cos(r) * Math.cos(r)
	end

	radius = 6371 # km
	d_lat = to_rad p2[:lat] - p1[:lat]
	d_lon = to_rad p2[:long] - p1[:long]
	lat1 = to_rad p1[:lat]
	lat2 = to_rad p2[:lat]

	a = sin2(d_lat/2) + sin2(d_lon/2) * Math.cos(lat1) * Math.cos(lat2)
	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	radius * c
end
