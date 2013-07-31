#!/usr/bin/perl

use JSON;
use File::Slurp;
use Data::Dumper;

for(;;){
    my $jsnobj = JSON->new->allow_nonref;
    
    my $rtmpjsn = read_file('rtmpdump.jsn');
    my $rtmphash = $jsnobj->decode($rtmpjsn);
    
    foreach my $rsrc(@{ $rtmphash->{srclst} }){
	my @cmd = ();
	foreach my $argstr(keys %{ $rtmphash->{argmap} }){
	    
	    if($rtmphash->{argmap}->{$argstr}->{timestamp} =~ /true/){
		my @lt = localtime();
		my $ltstr = sprintf("%0.4d%0.2d%0.2d_%0.2d%0.2d%0.2d",$lt[5] + 1900,$lt[4] + 1, $lt[3],$lt[2],$lt[1],$lt[0]);
		$rsrc->{$argstr} = $ltstr . "_" . $rsrc->{$argstr};
	    }
	    if($rtmphash->{argmap}->{$argstr}->{quoted} =~ /true/){
		push(@cmd, sprintf("%s \"%s\"", $rtmphash->{argmap}->{$argstr}->{shn}, $rsrc->{$argstr}));
	    }
	    else {
		push(@cmd, sprintf("%s %s", $rtmphash->{argmap}->{$argstr}->{shn}, $rsrc->{$argstr}));
	    }
	}
	system("rtmpdump " . join(' ',@cmd));	
	sleep(10);
    }

    sleep(10);
}
