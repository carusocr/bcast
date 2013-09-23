#!/usr/bin/perl -w

=head1 NAME

record_tp.pl

=head1 SYNOPSIS

record_tp.pl [duration in seconds] [transponder cfg file]

=head1 DESCRIPTION

wrapper script for dvbstream - record transponder pid transport stream , then split them out into 
individual mp2 files

=head1 AUTHOR

Kevin Walker <walkerk@ldc.upenn.edu>

=cut
use Proc::Killall;
use IO::Socket;
use File::Touch;
use File::Copy;
use File::stat;
use IPC::System::Simple qw(system systemx capture capturex runx run EXIT_ANY $EXITVAL);
use constant DVBSTREAM => '/usr/local/bin/dvbstream';
use constant TS2ES     => '/usr/local/bin/ts2es';
use constant FFMPEG    => '/usr/local/bin/ffmpeg';
$| = 1;

printf("%d\n",killall('KILL','dvbstream'));

my $card_id = shift;
my $dur     = shift;
die "Invalid recording duration $dur\n" unless $dur =~ /^\d+$/;
my $cfgfil  = shift;

if($cfgfil =~ /random/i){
    opendir(RTPBIN, "/mnt/sdc1/bin") || die "$!";
    @cfglst = grep { /galaxy19_tp\d+\.cfg/ && -f "/mnt/sdc1/bin/$_" } readdir(RTPBIN);
    close(RTPBIN);
    my $idx = int(rand(scalar(@cfglst)));
    $cfgfil = $cfglst[$idx];
}

die "cfgfil $cfgfil cannot be found - exiting\n" unless -f "/mnt/sdc1/bin/$cfgfil";

my $tpfreq = my $tppol = my $tpsrate = undef;
my %tbl = my %lng = ();

open CFG,"/mnt/sdc1/bin/$cfgfil" || die "$!";
$tpfreq = <CFG>; chop $tpfreq; 
$tppol = <CFG>; chop $tppol;
$tpsrate = <CFG>; chop $tpsrate;
while(<CFG>){
    chop;
    if(/^[A-Z\d]+,\w{3},\d+$/){
	my ($k,$l,$v) = split /,/;
	$tbl{$k} = $v;
	$lng{$k} = $l;
    }
}
close(CFG);

my $capdir = "/mnt/data0/incoming";
chdir($capdir) || die "$!";

my $datetime = get_dtstr();
my $tsfile   = sprintf("%s\_%s\_%s\.ts",  $datetime, 'galaxy19','capture');		       
my @dvbargs = ('-c', $card_id, '-n', $dur, 
	       '-f', $tpfreq, '-p', $tppol, 
	       '-s', $tpsrate, join('','-o:', $tsfile),
	       '-from',0, '-to',( $dur / 60 ), 
	       values(%tbl));
systemx(DVBSTREAM, @dvbargs);

foreach my $k(keys %tbl){
    my $ofb = sprintf("%s_%s_%s.mp2", $datetime, $k, $lng{$k});
    my $cvtcmd = sprintf "%s -pid %d %s %s", TS2ES, $tbl{$k}, $tsfile,$ofb;
    system(EXIT_ANY, $cvtcmd);
    if(stat($ofb)->size == 0){ unlink($ofb) }
    else {
	my $exifcmd=sprintf("exiftool -p '%s' %s",'$ChannelMode',$ofb);
        my $chmode=`$exifcmd`;
	if($chmode !~ /Single Channel/){
	    my ($ofbase) = $ofb =~ /(.*)\.mp2$/;
	    my $ofcha = sprintf("%s_%s.mp2",$ofbase,'ch0');
	    my $ofchb = sprintf("%s_%s.mp2",$ofbase,'ch1');
	    my @ffargs = ('-acodec','mp2','-i',$ofb,
			  '-map_channel','0.0.0',$ofcha,
			  '-map_channel','0.0.1',$ofchb);
	    systemx(FFMPEG,@ffargs);
	    unlink($ofb);
	}
	else {
	    print "$ofb $chmode\n";
	    my $tgt = $ofb;
	    $tgt =~ s/\.mp2/_ch0\.mp2/;
	    move($ofb,$tgt);
	}
    }
}

unlink($tsfile);
#exec("/mnt/data0/bin/migrate_satrad.sh");

sub get_dtstr {
    my ($sc,$mi,$hr,$dy,$mo,$yr) = localtime();
    return( sprintf("%0.4d%0.2d%0.2d\_%0.2d%0.2d%0.2d",$yr+1900,$mo+1,$dy,$hr,$mi,$sc) );
}

