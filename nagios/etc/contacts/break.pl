#!/usr/bin/perl

open FILE, "<", "contactgroups.cfg";
my @lines = <FILE>;
my $i=0;
for my $line (@lines){
	if ($line =~ /^define/){
		my $filename = "contactgroup" . $i . ".cfg";
		open NAGFILE, ">$filename" or die $!;
		print NAGFILE $line;
	}
	elsif ($line =~ /^}/){
		print NAGFILE $line;
		close NAGFILE;
		$i++;
	}
	else{
		print NAGFILE $line;
	}
		
		
}
close FILE;
