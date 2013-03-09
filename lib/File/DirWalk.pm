# Copyright (c) 2005-2013 Jens Luedicke <jensl@cpan.org>.
# 
# This module is free software; you can redistribute it and/or modify 
# it under the same terms as Perl 5.10.0. For more details, see the
# full text of the licenses in the directory LICENSES.

# This program is distributed in the hope that it will be
# useful, but without any warranty; without even the implied
# warranty of merchantability or fitness for a particular purpose.

package File::DirWalk;
use base qw(Exporter);

our $VERSION = '0.5';
our @EXPORT = qw(FAILED SUCCESS ABORTED PRUNE);

use warnings;
use strict;
use Carp;

use File::Basename;
use File::Spec;

use constant SUCCESS 	=> 1;
use constant FAILED 	=> 0;
use constant ABORTED 	=> -1;
use constant PRUNE 	=> -10;

sub new {
	my ($class) = @_;
	my $self = bless {}, $class;

	$self->{onBeginWalk} = sub { SUCCESS };
	$self->{onLink}      = sub { SUCCESS };
	$self->{onFile}      = sub { SUCCESS };
	$self->{onDirEnter}  = sub { SUCCESS };
	$self->{onDirLeave}  = sub { SUCCESS };

	$self->{depth}       = 0;
	$self->{depthCount} = 0;

	$self->{filesInDir}  = 0;

# 	$self->{customResponse} = {};

	return $self;
}

sub setHandler {
	my ($self,$action,$func) = @_;
    
	if ($action !~ /onBeginWalk|onLink|onFile|onDirEnter|onDirLeave/) {
    	croak("Invalid action argument: $action");
	}
	
	if (ref($func) ne 'CODE') {
    	croak("Second argument must be CODE reference.");
	}

    $self->{$action} = $func;
}

sub onBeginWalk {
	my ($self,$func) = @_;
	$self->setHandler(onBeginWalk => $func);
}

sub onLink {
	my ($self,$func) = @_;
	$self->setHandler(onLink => $func);
}

sub onFile {
	my ($self,$func) = @_;
	$self->setHandler(onFile => $func);
}

sub onDirEnter {
	my ($self,$func) = @_;
	$self->setHandler(onDirEnter => $func);
}

sub onDirLeave {
	my ($self,$func) = @_;
	$self->setHandler(onDirLeave => $func);
}

sub setDepth {
	my ($self,$v) = @_;
	$self->{depth} = $v;
}

sub getDepth {
	my ($self) = @_;
	return $self->{depthCount};
}

sub currentDir {
	my ($self) = @_;
	return $self->{currentDir};
}

sub currentPath {
	my ($self) = @_;
	return $self->{currentPath};
}

sub currentBasename {
	my ($self) = @_;
	return $self->{currentBasename};
}

sub filesInDir {
	my ($self) = @_;
	return $self->{filesInDir};
}

sub walk {
	my ($self,$path) = @_;

	$self->{currentDir}      = dirname($path);
	$self->{currentBasename} = basename($path);
	$self->{currentPath}     = $path;

	if ((my $r = $self->{onBeginWalk}->($path)) != SUCCESS) {
		return $r;
	}

	if (-l $path) {

		if ((my $r = $self->{onLink}->($path)) != SUCCESS) {
			return $r;
		}

	} elsif (-d $path) {

		if ($self->{depth} != 0) {
			if ($self->{depthCount} == $self->{depth}) {
				return SUCCESS;
			}
		}

		opendir (my $dirh, $path) || return FAILED;
		my @dir_contents = readdir $dirh;
		@dir_contents    = File::Spec->no_upwards(@dir_contents);

		$self->{filesInDir} = scalar @dir_contents;
		++$self->{depthCount};

		if ((my $r = $self->{onDirEnter}->($path)) != SUCCESS) {
			return $r;
		}

		# be portable.
		my @dirs = File::Spec->splitdir($path);

		foreach my $f (@dir_contents) {
			# be portable.
			my $path = File::Spec->catfile(@dirs, $f);

			my $r = $self->walk($path);

			if ($r == PRUNE) {
				next;
			} elsif ($r != SUCCESS) {
				return $r;
			}
		}

		closedir $dirh;

		if ((my $r = $self->{onDirLeave}->($path)) != SUCCESS) {
			return $r;
		}
		--$self->{depthCount};
	} else {
		if ((my $r = $self->{onFile}->($path)) != SUCCESS) {
			return $r;
		}
	}

	return SUCCESS;
}

1;

=head1 NAME

File::DirWalk - walk through a directory tree and run callbacks
on files, symlinks and directories.

=head1 SYNOPSIS

    use File::DirWalk;

    my $dw = File::DirWalk->new;

Walk through your homedir and print out all filenames:

    $dw->onFile(sub {
        my ($file) = @_;
        print "$file\n";

        return SUCCESS;
    });

    $dw->walk($ENV{'HOME'});

Walk through your homedir and print out all directories:

    $dw->onDirEnter(sub {
        my ($path) = @_;
        print "$path\n";

        return SUCCESS;
    });

    $dw->walk($ENV{'HOME'});

Walk through your homedir and print out all directories
with depth 3:

    $dw->onDirEnter(sub {
        my ($path) = @_;
        print "$path\n";

        return SUCCESS;
    });

    $dw->setDepth(3);
    $dw->walk($ENV{'HOME'});

=head1 DESCRIPTION

This module can be used to walk through a directory tree and run own functions
on files, directories and symlinks.

=head1 METHODS

=over 4

=item new()

Create a new File::DirWalk object.
The constructor takes no arguments.

=item onBeginWalk(\&func)

Specify a function to be be run on beginning of a walk.

=item onLink(\&func)

Specify a function to be run on symlinks.

=item onFile(\&func)

Specify a function to be run on regular files.

=item onDirEnter(\&func)

Specify a function to be run before entering a directory.

=item onDirLeave(\&func)

Specify a function to be run when leaving a directory.

=item setDepth($int)

Set the directory traversal depth. Once the specified directory depth
has been reached, the C<walk> method returns. The default value is 0.

=item getDepth

Returns the directory traversal depth.

=item currentDir

Returns the directory part of the current path.

    $dw->onBeginWalk(sub {
        my ($path) = @_;

        print "path: " . $path,            "\n"; # /usr/bin/perl
        print "directory: " . $dw->currentDir(), "\n"; # /usr/bin

        return SUCCESS;
    });

=item currentPath

Returns the current path. The string is identical to the
$path argument passed to the callback:

    $dw->onBeginWalk(sub {
        my ($path) = @_;

        print "path: " . $path,            "\n";        # /usr/bin/perl
        print "directory: " . $dw->currentPath(), "\n"; # /usr/bin/perl

        return SUCCESS;
    });

=item currentBasename

Returns the current base name of the current path:

    $dw->onBeginWalk(sub {
        my ($path) = @_;

        print "path: " . $path,            "\n";            # /usr/bin/perl
        print "directory: " . $dw->currentBasename(), "\n"; # perl

        return SUCCESS;
    });

=item filesInDir

Returns the number of files wthin the current directory.
Excludes . and ..

=item walk($path)

Begin the walk through the given directory tree. This method returns if the walk
is finished or if one of the callbacks doesn't return SUCCESS. If the callback function
returns PRUNE, C<walk> will skip to the next element within the current directory
hierarchy. You can use PRUNE to exclude files or folders: 

	$dw->onBeginWalk(sub {
    	my ($path) = @_;

		if ($path =~ /ignore/) {
			return PRUNE;
		}

		return SUCCESS;
	});

=back

=head1 CALLBACKS

All callback-methods expect a function reference as their argument. 
The current path is passed to the callback function.

The callback function must return SUCCESS, otherwise the recursive walk is aborted and
C<walk> returns. Furthermore, C<walk> expects a numeric return value.

=head1 CONSTANTS

File::DirWalk exports the following predefined constants
as return values:

=over 4

=item SUCCESS (1)

=item FAILED  (0)

=item ABORTED (-1)

=item PRUNE   (-10)

=back

=head1 DEVELOPMENT

Please mail the author if you encounter any bugs. The most recent development
version can be found on GitHub: L<https://github.com/nullmedium/File-DirWalk>

=head1 CHANGES

Version 0.4: add more methods, better testing, more documentation.

Version 0.3: add PRUNE constant. add option to specify the directory depth.

Version 0.2: platform portability fixes and more documentation

Version 0.1: first CPAN release

=head1 HISTORY

I wrote DirWalk.pm module for use within my 'Filer' file manager as a directory
traversing backend and I thought it might be useful for others. It is my first
CPAN module.

=head1 AUTHOR

Jens Luedicke E<lt>jensl@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2005-2013 Jens Luedicke <jensl@cpan.org>.

This module is free software; you can redistribute it and/or modify 
it under the same terms as Perl 5.10.0. For more details, see the
full text of the licenses in the directory LICENSES.

This program is distributed in the hope that it will be
useful, but without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose.
