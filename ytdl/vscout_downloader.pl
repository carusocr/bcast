#!/usr/bin/perl -w

=head1 NAME

vscout_downloader.pl

=head1 SYNOPSIS

vscout_downloader.pl <target site>

=head1 DESCRIPTION

This is a script used in conjunction with the ascout database
to download video clips from a variety of online sites(e.g. 
youTube, Vimeo) for the VAST video collection project.

The script reads in site-specific information from the site.xml
and havicdb.xml configuration files. Each site has a different
downloader application and a different database query used to
retrieve the list of video files for download. After the 
configuration information is read, the script queries the database
and generates a list of URLs. It also retrieves the associated
unique row ID numbers, which are used in the output file names.

During the download step, the script first checks to see if the output 
file already exists in the target directory. If not, it executes the 
clip download command(either wget, curl, vimeo_downloader, or youtube-dl).
After an attempted clip download, the script runs the clip_check 
subroutine. This runs a unix 'file' command on the newly generated clip and
returns one of several expected values (e.g. 'flv','mp4','unk'). A second
subroutine, update_db, takes the returned file type value and uses it to
update the media_file value in the ascout_url table. If a file either
does not exist or is not either Flash, OGG, MPEG4, or html, it is flagged 
as 'unknown' and registered as a failed download.

=head1 AUTHOR

Chris Caruso <carusocr@ldc.upenn.edu>

=cut

use strict;
use XML::Simple;
use DBI;

die "Must provide target site!\n" unless $ARGV[0];

my $datadir = "data";
my $configdir = "config";
my %datatype = 	( MPEG 	=> 	'mp4',
									Flash	=> 	'flv',
									HTML 	=> 	'html',
									Ogg  	=> 	'ogg',
									unk		=>	'unk');
									
									
my $target_site = "$ARGV[0]";
my $db_cfg_file = "havicdb.xml";
my $site_cfg_file = "site.xml";
my $xml = new XML::Simple;
my $db_cfg = $xml->XMLin("$configdir/$db_cfg_file");
my $host = $db_cfg->{server};
my $db = $db_cfg->{db};
my $username = $db_cfg->{username};
my $pwd = $db_cfg->{pwd};

my $site_cfg = $xml->XMLin("$configdir/$site_cfg_file");
my $qry = $site_cfg->{site}->{$target_site}->{query};
my $dl_cmd = $site_cfg->{site}->{$target_site}->{download_cmd};
my %tbl=();

#run query to get list of IDs and download URLs

my $dbh = DBI->connect("dbi:mysql:$db:$host",$username,$pwd);
my $sth = $dbh->prepare($qry);
$sth->execute;
while(my ($idx, $url) = $sth->fetchrow){

	#youtube string trimming
	if ($target_site eq 'youtube'){
		$url =~ s/(watch\?).*?(v=.{11}).*?$/$1$2/;
	}
	#populate hash
	$tbl{$idx}{URL} = $url;
}

my $upd_sth = $dbh->prepare( "update ascout_url set media_file = ? where id = ?");
foreach my $k(sort {$a<=>$b} keys %tbl){
	my $ofilroot = "HVC${k}";
	#if file doesn't exist, try to download it
	if ((!-e "$datadir/$ofilroot.mp4") && (!-e "$datadir/$ofilroot.flv")){
		#download to output file with temp name until we verify type
		my $ofil = $ofilroot . ".tmp";
		my $dl_cmd = "$dl_cmd $datadir/$ofil $tbl{$k}{URL}";
		print "$dl_cmd\n";
		system($dl_cmd);
		my $cliptype = &clip_check("$datadir/$ofil");
		print "clip is $cliptype\n";
		my $media_file = $ofilroot . "." . $cliptype;
		#if clip is anything other than html/flv/mp4, flag and remove it
		if ($cliptype eq "unk"){
			$media_file = 'fail';
			unlink "$datadir/$ofil" if (-e "$datadir/$ofil");
		}
		#otherwise, rename
		else {rename ("$datadir/$ofil", "$datadir/$ofilroot.$cliptype");}
		$upd_sth->execute($media_file, $k );
	}
}
$dbh->disconnect();

sub clip_check {
#runs file command on downloaded file, returns extension
#File::Type module not nearly as fast as this method...

	my ($clip) = @_;
	my $fileinfo = `file $clip`;
	my @known_types = qw/HTML Flash MPEG Ogg/;
	my $known_regex = join('|', @known_types);
	my $type =($fileinfo=~/($known_regex)/)? $1 : 'unk';
	return ($datatype{$type}); 
}
