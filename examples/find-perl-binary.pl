#!/usr/bin/perl

use strict;
use warnings;

use File::DirWalk;

my $dw = new File::DirWalk();

$dw->onDirEnter(sub {
	my ($path) = @_;

	if ($dw->currentBasename() =~ /sbin|lib|share|local|include|libexec|X11/) {
		return PRUNE;
	}

	return SUCCESS;
});

my $found = "";

$dw->onFile(sub {
	my ($path) = @_;

	if ($dw->currentBasename() eq "perl") {
        $found = $path;
		return ABORTED;
	}

	return SUCCESS;
});

$dw->walk("/usr");

print "perl is in $found\n";