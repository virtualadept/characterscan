#!/usr/bin/perl
#
# Stupid script to scan/file character sheets
# ./characterscan <Player Initals> <Game> <Character_Name>
#
# v0.1 Inital Write.  Drunk, dont blame me for bad code. 4/20/07
# v0.2 Added Directory Checking - Now Sober, Prompts, Date Bug (martine@danga.com)
# v0.3 Imported to subversion - check there for revision 
# 
# !!!WARNING!!! This script is highly specific to one setup.  Dont really use unless
# you know what you are doing.
#
#

use strict;

my %playerinitals = ( FP => 'Frank',
		DM => 'Dax',
		BB => 'Brandon',
		MF => 'Melinda',
		SM => 'Sky',
		IM => 'Ian',
		CP => 'Cassie'
	      );


my %gameinitals = ( DND => { name => 'dnd',
			     BFS  => 'Brandons_Freak_Show',
			     DFR  => 'Daxs_Wednesday_Forgotten_Realms',
			     NA   => 'Misc',
			     RWOT => 'Red_Wizards_of_Thay' },
		    
		    SW  => { name => 'starwars',
			     CF   => 'Chris_Game' },
		    
                    WOD => { name => 'worldofdarkness',
			     PD	  => 'Project_Daedelus',
			     NA   => 'Misc' } 
		   );


# Sanity checks/Usage
unless ($ARGV[0] && $ARGV[1] && $ARGV[2]) {
	usage();
	exit 0;
};

unless (exists $gameinitals{$ARGV[0]}{'name'} && exists $playerinitals{$ARGV[1]} && exists $gameinitals{$ARGV[0]}{$ARGV[2]}) {
	print "\n\n!!!!!!Check your syntax, platform player and/or game dont exist!!!!!\n\n";
	usage();
	exit 0;
};


# Variables and Shit
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$year += 1900;
$mon += 1;
my $platform = $gameinitals{$ARGV[0]}{'name'} . "scans";
my $player = $playerinitals{$ARGV[1]};
my $game = $gameinitals{$ARGV[0]}{$ARGV[2]};
my $charactername = lc($ARGV[3]);
$charactername =~ s/ /_/g;
my $characterpath = "/home/corvus/rpgscans/$platform/$game/$player/$charactername";
my $savepath = "/home/corvus/rpgscans/$platform/$game/$player/$charactername/$mon-$mday-$year/";
my $scancommand = "/usr/bin/scanadf -N --source ADF --batch-scan -o $savepath/$charactername-%d -S/usr/local/bin/ppmtojpeg.sh";
my $synccommand = "rsync -avPe ssh /home/corvus/rpgscans/$platform/* corvus\@tass.int.vadept.com:/var/www/$gameinitals{$ARGV[0]}{'name'}/characters/.";

# Final Confirmation
print "\n\n*Confirm Selection:\nPlatform:$platform\nPlayer:$player\nCharacter:$charactername\n\nContinue? ";
my $confanswer = <STDIN>;
exit 0 unless ($confanswer == 'Y');

# Make the warn and make the directory if it doesnt exist
unless (-e $characterpath) {
	print "Directory for character \"$charactername\" does not exist.\nDid you mean one of these?\n=====\n";
	print `ls /home/corvus/rpgscans/$platform/$game/$player/.`;
	print "=====\nContinue [y/N]? ";
	my $pathanswer = <STDIN>;
	exit 0 unless ($pathanswer == 'Y');
	print "Making directory $savepath\n";
	`mkdir -p $savepath`;
};

# Finally scan everything
print "Scanning.....\n";
`$scancommand`; 

# Sync to server?
print "Do you wish to sync these to tass [N/y]? ";
my $syncanswer = <STDIN>;
`$synccommand` if ($syncanswer == 'Y');

## ---- ##

# Start Subs
sub usage {
	print "Welcome to the RPG Document Scanner!\nSyntax is characterscan.pl <Platform> <Initals> <Game> <Character Name>\n";
	print "\nPlatform & Game:\n";
	foreach my $platkey (sort keys %gameinitals) {
		print "\n";
		print "-> $platkey => $gameinitals{$platkey}{'name'}\n";
		foreach my $gamekey (sort keys %{$gameinitals{$platkey}}) {
			next if ($gamekey eq 'name');
			print "`--> $gamekey => $gameinitals{$platkey}{$gamekey}\n"
		}
	}
	
	print "\n=====\n\nPlayers:\n";
	foreach $_ (sort keys %playerinitals) {
		print "$_ => $playerinitals{$_}\n";
	}
	print "\n\n";
};
