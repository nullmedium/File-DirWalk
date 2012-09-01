use Test::More qw(no_plan);
use Test::Exception;

use File::Basename;
use File::DirWalk;

my $perl_path        = dirname($^X);
my $perl_interpreter = basename($^X);

$dw = new File::DirWalk();

ok( ref($dw) eq 'File::DirWalk' );

dies_ok { $dw->setHandler(Foo => 0); }

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

$dw->onFile(sub {
	my ($path) = @_;

	if (basename($path) eq $perl_interpreter) {
		return ABORTED;
	}

	return SUCCESS;
});

ok( $dw->walk($perl_path) == ABORTED );

$dw->onFile(sub {
	my ($path) = @_;
	
	if (basename($path) eq "sh") {
		return ABORTED;
	}

	return SUCCESS;
});

ok( $dw->walk("/bin") == ABORTED );
