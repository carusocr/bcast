#!/usr/local/bin/perl

use DBI;
use strict;


my %dbparams = ( host => '',
                 db   => '',
                 user => '',
                 pwd  => '' );
my %tbl = ();
my $day = `date -d 'yesterday' +%Y-%m-%d`;chomp $day;
my $datadir = "/havic/src";
system("cd $datadir");

my $dbh = DBI->connect("dbi:mysql:$dbparams{db}:$dbparams{host}",$dbparams{user},$dbparams{pwd});
my $sth = $dbh->prepare("select id, page_url, date_found from 
                         ascout_url where page_url like '%youtu%' and media_file not like '%HVC%' and date_found like '$day%' or page_url like '%youtu%' and media_file is NULL and date_found like '$day%' order by date_found desc");

$sth->execute;
while(my ($idx, $url, $dat) = $sth->fetchrow){
#added to fix feature-related suffix
    $url =~ s/NR\=1\&//;
    $url =~ s/\&NR\=1//;
    $url =~ s/\&feature\=.+//;
    $url =~ s/\&nofeather\=.+//;
    $url =~ s/\&list\=.+//;
    $url =~ s/\&list\=UL//;
    $url =~ s/feature\=player_embedded\&//;
    $url =~ s/feature\=.+?\&//;
  	$url =~ s/youtu\.be\//www\.youtube\.com\/watch\?v\=/;
		$url =~ s/\?\&v\=/\?v\=/;
    $tbl{$idx}{URL} = $url;
    $tbl{$idx}{DATE} = $dat;
}
$sth->finish;
$dbh->disconnect;

foreach my $k(sort { $a <=> $b } keys %tbl){
    printf "%d\n",$k;
    print "$tbl{$k}{URL}\n";
    my $cldl_ret = clive_dl($tbl{$k}{URL},$k);
    system($cldl_ret) unless $cldl_ret == -1;
}

sub clive_dl {
    my ($url,$targ) = @_;
    my $vid_id = undef;
    my $ofil = "HVC${targ}.mp4";
    my $cmd = "youtube-dl -f 18 -o $datadir/$ofil $url";
    if(! -e $ofil){ return($cmd) } else { return(-1) }
}


