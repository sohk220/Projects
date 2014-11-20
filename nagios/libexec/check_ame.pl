#!/usr/bin/perl

require HTTP::Request;
use LWP::Simple;
use XML::Simple;
use Data::Dumper;

# "This script checks the status of AME servers: \n\n";

my $host = $ARGV[0];
my $uri = "http://$host:8080/job/";
my $request= get $uri; 
if (! (defined ($request))) {
print "Server is down! \n\n"; # If request fails, that is an indication that the dynamic link service is down. 
exit 2; 
}

	my $initial_response= XMLin($request);


my $id = $initial_response->{JobId};
my $status = $initial_response->{JobStatus};
my $job_progress = $initial_response->{JobStatus};
my $details = $initial_response->{Details};
my $exception = 'File already exists at destination path'; # This error state occurs when the user submits the same job twice and is non-critical

sub parse_id { 
	 if ($_[0] =~ m/(\d{8})/) { # Extracts CNN ID from details field
		$CNNID = $1;
	}
	$CNNID;
}


	$ID = &parse_id($details);

#print Dumper($initial_xml);


if  ($status =~ /Success|Not Found/) {
	print "AME is idle: \n";
	exit; } elsif (($status =~ 'Failed') && ($initial_response->{Details} =~ $exception)) { # This only checks for the exception. 
		print "AME is idle with a cancelled job: \n";
		exit; 
	} elsif ($status =~ 'Failed') {
	print "Job $ID failed with error $initial_response->{Details} \n";
exit 2;
} else { 
	
sleep 4;

my $request_2= get $uri;
my $response_2= XMLin($request_2);

#print Dumper($response_2);

if (($id =~ $response_2->{JobID}) && ($status =~ 'Queued'))  { # Re-checks after 4 secs and if state remains queued, this will raise a flag. 
	print "Job $ID remains in a queued state \n";
	exit 2;
} elsif (($id =~ $response_2->{JobID}) && ($job_progress =~ $response_2->{JobProgress})){ 
	print "Job $ID is hung at $job_progress: \n";
        exit 2;
} else {
	print "Job $ID progress is  $response_2->{JobProgress} : \n";
   }
}
