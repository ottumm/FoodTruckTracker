function loadGoogleMapsAPI(callback) {
	var script = document.createElement("script");
	script.type = "text/javascript";
	script.src = "http://maps.googleapis.com/maps/api/js?key=AIzaSyCoNyyQ_MuIRqQhMoNl_VP2C32P0EQM4NI&sensor=true&callback=" + callback;
	document.body.appendChild(script);
}
