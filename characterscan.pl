#!/usr/bin/perl
#
# Stupid script to scan/file character sheets
# ./characterscan <Player Initals> <Game> <Character_Name>
#
# v0.1 Inital Write.  Drunk, dont blame me for bad code. 4/20/07
# v0.2 Added Directory Checking - Now Sober, Prompts, Date Bug (martine@danga.com)
# v0.3 Imported to subversion - check there for revision 


use strict;


my %playerinitals = ( FP => 'Frank',
		DM => 'Dax',
		BB => 'Brandon',
		MF => 'Melinda',
		SM => 'Sky',
		IM => 'Ian',
		CP => 'Cassie'
	      );

my %gameinitals = ( RWOT => 'Red_Wizards_of_Thay',
	      BFS  => 'Brandons_Freak_Show',
	      DFR  => 'Daxs_Wednesday_Forgotten_Realms',
	      NA => 'Misc',
	    );

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$year += 1900;
$mon += 1;

unless ($ARGV[0] && $ARGV[1] && $ARGV[2]) {
	print "Welcome to D&D Document Scanner!\nSyntax is $0 <Initals> <Game> <Character Name>\n";
	print "Players:\n";
	foreach $_ (sort keys %playerinitals) {
		print "$_ => $playerinitals{$_}\n";
	}
	print "=====\nGames:\n";
	foreach $_ (sort keys %gameinitals) {
		print "$_ => $gameinitals{$_}\n";
	}
};

unless (exists $playerinitals{$ARGV[0]} && exists $gameinitals{$ARGV[1]}) {
	print "=====\nCheck your syntax, player and/or game dont exist\n";
	exit 0;
};



my $player = $playerinitals{$ARGV[0]};
my $game = $gameinitals{$ARGV[1]};
my $charactername = lc($ARGV[2]);
$charactername =~ s/ /_/g;

my $characterpath = "/home/corvus/dndscans/$game/$player/$charactername";
my $savepath = "/home/corvus/dndscans/$game/$player/$charactername/$mon-$mday-$year/";
my $scancommand = "/usr/bin/scanadf -N --source ADF --batch-scan -o $savepath/$charactername-%d -S/usr/local/bin/ppmtojpeg.sh";
my $synccommand = "rsync -avPe ssh /home/corvus/dndscans/* corvus\@tass.int.vadept.com:/var/www/dnd/characters/.";


unless (-e $characterpath) {
	print "Directory for character \"$charactername\" does not exist.\nDid you mean one of these?\n=====\n";
	print `ls /home/corvus/dndscans/$game/$player/.`;
	print "=====\nContinue [y/N]? ";
	my $pathanswer = <STDIN>;
	exit 0 unless ($pathanswer == 'Y');
	print "Making directory $savepath\n";
	`mkdir -p $savepath`;
};

print "Scanning.....\n";
`$scancommand`; 

print "Do you wish to sync these to tass [N/y]? ";
my $syncanswer = <STDIN>;
`$synccommand` if ($syncanswer) == 'Y');
