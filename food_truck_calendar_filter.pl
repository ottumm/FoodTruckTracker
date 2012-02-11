use LWP;
use Data::ICal;

my @calendars = (
	{
		NAME   => 'Ebbett\'s Good to Go',
		URL    => 'https://www.google.com/calendar/ical/lk3ib70tqh4b62vgjj8lprvbn0%40group.calendar.google.com/public/basic.ics',
		FILTER => '64th & Hollis'
	},
	{
		NAME   => 'Doc\'s of the Bay',
		URL    => 'https://www.google.com/calendar/ical/docstruck%40gmail.com/public/basic.ics',
		FILTER => '62nd and Hollis'
	}
);

my $browser = LWP::UserAgent->new();
my $newcal = Data::ICal->new();

foreach my $calendar ( @calendars )
{
	my $response = $browser->get( $calendar->{URL} );
	$response->is_success or die "Could not GET " . $calendar->{URL} . " : " . $response->status_line;
	my $ical = Data::ICal->new( data => $response->content );
	$ical or die "Could not parse " . $calendar->{NAME} . " : " . $ical->error_message;
	
	my $last_timestamp;
	for ( my $i = 1, my $entry = $ical->entries->[0]; defined( $entry ); $entry = $ical->entries->[$i++] )
	{
		if ( entry_passes_filter( $entry, $calendar->{FILTER} ) )
			{ add_entry( $entry, $calendar->{NAME}, $newcal ); }
	}
}

output( $newcal );

sub entry_passes_filter
{
	my ( $entry, $filter ) = @_;
	my $summary = $entry->property( "summary" );
	return $summary && $summary->[0]->value =~ /$filter/;
}

sub add_entry
{
	my ( $entry, $name, $calendar ) = @_;
	my $location = $entry->property( "summary" )->[0]->value;
	$entry->property( "summary" )->[0]->value( $name );
	$entry->property( "location" )->[0]->value( $location );
	$calendar->add_entry( $entry );
}

sub output
{
	my ( $ical ) = @_;
	my $output = $ical->as_string;
	$output =~ s/\r//g;
	print add_headers( $output );
}

sub add_headers
{
	my ( $s ) = @_;
	my $end_current_header = "VERSION:2\.0\n";
	my $header = headers();
	$s =~ s/$end_current_header/$end_current_header$header/;
	return $s;
}

sub headers
{
	return <<AnUnlikelyNameForAnEnding
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:Emeryville Food Trucks
X-WR-TIMEZONE:America/Los_Angeles
X-WR-CALDESC:
BEGIN:VTIMEZONE
TZID:America/Los_Angeles
X-LIC-LOCATION:America/Los_Angeles
BEGIN:DAYLIGHT
TZOFFSETFROM:-0800
TZOFFSETTO:-0700
TZNAME:PDT
DTSTART:19700308T020000
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:-0700
TZOFFSETTO:-0800
TZNAME:PST
DTSTART:19701101T020000
RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
END:STANDARD
END:VTIMEZONE
AnUnlikelyNameForAnEnding
}
