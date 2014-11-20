#!/usr/bin/perl

use strict;
#use LWP::UserAgent;

my $checkCondition = $ARGV[0];
my $queueName= $ARGV[1];
my $warnLevel = $ARGV[2];
my $critLevel = $ARGV[3];



if ($checkCondition eq "consumer")
{
	my $response = `echo "dis ql($queueName) ipprocs" | runmqsc`;
	$response =~ m/CURDEPTH\((\d+)\)/;
	my $procs = $1;
	if ($procs > $critLevel)
	{
		print "CRITICAL: There are $procs consumers for $queueName\n";
		exit 2;
	}
	elsif ($procs > $warnLevel)
	{
		print "WARNING: There are $procs consumers for $queueName\n";
		exit 1;
	}
	else
	{
		exit 0;
	}
}
elsif ($checkCondition eq "messages")
{
	my $response = `echo "dis ql($queueName) curdepth" | runmqsc`;
	$response =~ m/CURDEPTH\((\d+)\)/;
	my $depth = $1;
	if ($depth > $critLevel)
	{
		print "CRITICAL: There are $depth messages in $queueName\n";
		exit 2;
	}
	elsif ($depth > $warnLevel)
	{
		print "WARNING: There are $depth messages in $queueName, attempting to restart QBroker\n";
		# LWP does not work on old ipemsg boxes, using wget instead
#		my $browser = new LWP::UserAgent;
#		my $response = $browser->get('http://http://nycnn-mq1/cgi-bin/qbroker_rest.pl?&cmd=restart&workflow=IPE&service=qbroker') 
#				or print "ERROR: Can't load url, Unable to restart Qbroker\n";
#		my $data;
#		if ($response->is_success) { 
#			print $response->status_line."\n"; 
#			$data = $response->content;
#		}
#		else
#		{
#			print "ERROR Attempting Restart: ".$response->status_line."\n";
#		}
		my $response = `wget 'http://nycnn-mq1/cgi-bin/qbroker_rest.pl?&cmd=restart&workflow=IPE&service=qbroker' -q -O -`;
		if ($response=~m/IPE Workflow is restarting/)
		{
			print "Restart request sent sucessfully\n"; 
			# exit with warning
			exit 1;
		}
		else
		{
			print "Restart Attempt was not succesful\n";
			# Exit critical
			exit 2;
		}
	}
	else
	{
		exit 0;
	}
}
else
{
	print "Check is not working properly";
	exit 1;
}

