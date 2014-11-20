#!/usr/bin/perl

open FILE, "<ardendo_services.cfg";
my @lines = <FILE>;
my $i=0;
for my $line (@lines){
	if ($line =~ /^define/){
		print "beg" .  $i . "\n";
		my $filename = "./work/foo" . $i . ".cfg";
		open NAGFILE, ">$filename" or die $!;
		print NAGFILE $line;
	}
	elsif ($line =~ /}/){
		print "end" .  $i . "\n";
		print NAGFILE $line;
		close NAGFILE;
		$i++;
	}
	else{
		print NAGFILE $line;
	}
		
		
}
close FILE;
