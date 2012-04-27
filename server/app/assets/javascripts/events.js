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
		title: "Current Location"
	});

	var infowindow = new google.maps.InfoWindow({maxWidth: 320});

	for(var i=0; i<events.length; i++) {
		var marker = new google.maps.Marker({
			position: new google.maps.LatLng(events[i].latitude, events[i].longitude),
			map: map,
			title: events[i].truck.name
		});
		var image = new google.maps.MarkerImage(smallProfileImage(events[i].truck.profile_image), null, null, null, new google.maps.Size(24,24));
		marker.setIcon(image);
		marker.setAnimation(google.maps.Animation.DROP);

		google.maps.event.addListener(marker, 'click', (function(marker, i) {
			return function() {
				var info = '<div class="map-info">' + $($('.event')[i]).html() + '</div>'
				infowindow.setContent(info);
				infowindow.open(map, marker);
				$('.map-info').css('overflow', 'hidden');
				$('.map-info .tweet-toggle').css('visibility', 'hidden');
			}
		})(marker, i));
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
