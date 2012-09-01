#!/usr/bin/perl

use strict;
use warnings;

use Cwd;

use File::Basename;
use File::DirWalk;

my $dw = new File::DirWalk();

my $size = 0;

$dw->setDepth(1);

$dw->onBeginWalk(sub {
	my ($path) = @_;

	if ($dw->filesInDir() > 0) {
		print $dw->currentBasename() . "\n";

		$size += -s $path;
	}

	return SUCCESS;
});

$dw->onDirLeave(sub {
	print $dw->filesInDir(), " files ($size bytes)\n";
	return SUCCESS;
});

if (-e $ARGV[0]) {
	$dw->walk($ARGV[0]);
} else {
 	my $cwd = getcwd();
 	$dw->walk($cwd);
}
