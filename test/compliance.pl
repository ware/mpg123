#!/usr/bin/perl -w

use strict;

# just picking samples from the host of available bitstreams
use FindBin qw($Bin);
use File::Basename;

die "Give me the mpg123 command to test\n" unless @ARGV;

my @files=
(
	 "$Bin/compliance/layer1/fl*.mpg"
	,"$Bin/compliance/layer2/fl*.mpg"
	,"$Bin/compliance/layer3/compl.bit"
);

open(SUFDAT, "$Bin/binsuffix") or die "Hm, binsuffix file does not exist, did you run make in $Bin?";
my $bsuf = <SUFDAT>;
chomp($bsuf);
close(SUFDAT);

my $rms="$Bin/rmsdouble.$bsuf";
my $f32conv="$Bin/f32_double.$bsuf";
my $s32conv="$Bin/s32_double.$bsuf";
my $s16conv="$Bin/s16_double.$bsuf";

die "Binaries missing, run make in $Bin\n" unless (-e $rms and -e $f32conv and -e $s16conv);

my $nogap='';
my $floater=0;
my $int32er=0;
{
	open(DAT, "@ARGV --longhelp 2>&1|");
	while(<DAT>)
	{
		$nogap='--no-gapless' if /no-gapless/;
	}
	close(DAT);
	$int32er = test_encoding('s32');
	$floater = test_encoding('f32');
}

for(my $lay=1; $lay<=3; ++$lay)
{
	print "\n";
	print "==== Layer $lay ====\n";

	print "--> 16 bit signed integer output\n";
	tester($files[$lay-1], '', $s16conv);

	if($int32er)
	{
		print "--> 32 bit integer output\n";
		tester($files[$lay-1], '-e s32', $s32conv);
	}

	if($floater)
	{
		print "--> 32 bit floating point output\n";
		tester($files[$lay-1], '-e f32', $f32conv);
	}
}

sub tester
{
	my $pattern = shift;
	my $enc = shift;
	my $conv = shift;
	foreach my $f (glob($pattern))
	{
		my $bit = $f;
		$bit =~ s:mpg$:bit:;
		my $double = $f;
		$double =~ s:(mpg|bit)$:double:;
		die "Please make some files!\n" unless (-e $bit and -e $double);
		print basename($bit).":\t";
		my $commandline = "@ARGV $nogap $enc -q  -s ".quotemeta($bit)." | $conv | $rms ".quotemeta($double)." 2>/dev/null";
		system($commandline);
	}
}

sub test_encoding
{
	my $enc = shift;
	my $supported = 0;
	my @testfiles = glob($files[2]);
	my $testfile = $testfiles[0];
	open(DAT, "@ARGV -q -s -e $enc ".quotemeta($testfile)." 2>/dev/null |");
	my $tmpbuf;
	if(read(DAT, $tmpbuf, 1024) == 1024)
	{
		$supported = 1;
	}
	close(DAT);
	return $supported;
}
