use Test::More qw(no_plan);
use Test::Exception;

use File::Basename;
use File::DirWalk;

my $perl_path        = dirname($^X);
my $perl_interpreter = basename($^X);

$dw = new File::DirWalk();

ok( ref($dw) eq 'File::DirWalk' );

ok ($dw->setHandler(onBeginWalk => sub { SUCCESS }));
ok ($dw->setHandler(onLink      => sub { SUCCESS }));
ok ($dw->setHandler(onFile      => sub { SUCCESS }));
ok ($dw->setHandler(onDirEnter  => sub { SUCCESS }));
ok ($dw->setHandler(onDirLeave  => sub { SUCCESS }));

dies_ok {$dw->setHandler(onBeginWalk => 0)};
dies_ok {$dw->setHandler(onLink      => 0)};
dies_ok {$dw->setHandler(onFile      => 0)};
dies_ok {$dw->setHandler(onDirEnter  => 0)};
dies_ok {$dw->setHandler(onDirLeave  => 0)};

dies_ok {$dw->setHandler(Foo => sub {})};

$dw->onFile(sub {
	my ($path) = @_;
	
	if (basename($path) eq "1.t") {
		return ABORTED;
	}

	return SUCCESS;
});

ok( $dw->walk($0) == ABORTED );

$dw->onDirEnter(sub {
	my ($path) = @_;

	if ($path eq $perl_path) {
		return FAILED;
	}
		
	return SUCCESS;
});

ok( $dw->walk($perl_path) == FAILED );

$dw->onBeginWalk(sub {
	my ($path) = @_;
	if (dirname($path) eq $dw->currentDir) {
		return ABORTED;
	}

	return SUCCESS;
});

ok( $dw->walk($perl_path) == ABORTED );

$dw->onBeginWalk(sub {
	my ($path) = @_;
	if ($path eq $dw->currentPath) {
		return ABORTED;
	}

	return SUCCESS;
});

ok( $dw->walk($perl_path) == ABORTED );

$dw = new File::DirWalk();
$dw->onFile(sub {
	my ($path) = @_;

	if ($dw->currentBasename() eq $perl_interpreter) {
		return 42;
	}

	return SUCCESS;
});

ok( $dw->walk($perl_path) == 42 );
