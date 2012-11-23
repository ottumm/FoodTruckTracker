def haversine_distance(p1, p2)
	def to_rad angle
		angle/180 * Math::PI
	end

	lat1 = p1[:latitude]  or p1.latitude
	lon1 = p1[:longitude] or p1.longitude
	lat2 = p2[:latitude]  or p2.latitude
	lon2 = p2[:longitude] or p2.longitude

	lat1 = to_rad lat1
	lon1 = to_rad lon1
	lat2 = to_rad lat2
	lon2 = to_rad lon2

	radius = 3961 # mi
	dlon = lon2 - lon1
	dlat = lat2 - lat1
	a = Math.sin(dlat/2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon/2)**2
	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
	radius * c
end
