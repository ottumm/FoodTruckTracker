function initializeMap() {
	function smallProfileImage(profileImage) {
		return profileImage.replace('normal', 'mini');
	}

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
			title: events[i].truck.name
		});
		var image = new google.maps.MarkerImage(smallProfileImage(events[i].truck.profile_image));
		marker.setIcon(image);
		marker.setAnimation(google.maps.Animation.DROP);
	}
}

function toggleTweets(eventId) {
	var toggle = $('#' + eventId + '_tweet_toggle');
	var extras = $('#' + eventId + '_extra_tweets');
	if(toggle.is(':visible')) {
		toggle.hide();
		extras.show();
	}
	else {
		extras.hide();
		toggle.show();
	}
}
