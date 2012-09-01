#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::DirWalk;

my $dw = new File::DirWalk();

$dw->onDirEnter(sub {
	my ($path) = @_;

	print "$path\n";
	
	if (basename($path) =~ /sbin|lib|share|local|include|libexec|X11/) {
		return PRUNE;
	}

	return SUCCESS;
});

$dw->onFile(sub {
	my ($path) = @_;

	print "$path\n";
	
	if (basename($path) eq "perl") {
		return ABORTED;
	}

	return SUCCESS;
});

$dw->walk("/usr");
