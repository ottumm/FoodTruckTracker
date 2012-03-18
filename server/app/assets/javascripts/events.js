function initializeMap() {
	var myOptions = {
		zoom: 12,
		center: new google.maps.LatLng(sensor.latitude, sensor.longitude),
		mapTypeId: google.maps.MapTypeId.ROADMAP
	}
	var map = new google.maps.Map(document.getElementById("map-canvas"), myOptions);

	new google.maps.Marker({
		position: new google.maps.LatLng(sensor.latitude, sensor.longitude),
		map: map,
		title: "Current Location",
		animation: google.maps.Animation.DROP
	});

	for(var i=0; i<events.length; i++) {
		var marker = new google.maps.Marker({
			position: new google.maps.LatLng(events[i].latitude, events[i].longitude),
			map: map,
			title: events[i].tweets[0].user
		});
		var image = new google.maps.MarkerImage(events[i].tweets[0].small_profile_image);
		marker.setIcon(image);
		marker.setAnimation(google.maps.Animation.DROP);
	}
}

function loadMapScript() {
	var script = document.createElement("script");
	script.type = "text/javascript";
	script.src = "http://maps.googleapis.com/maps/api/js?key=AIzaSyCoNyyQ_MuIRqQhMoNl_VP2C32P0EQM4NI&sensor=true&callback=initializeMap";
	document.body.appendChild(script);
}

window.onload = loadMapScript;
