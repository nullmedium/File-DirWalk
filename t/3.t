use Test::More qw(no_plan);
use Test::Exception;

use File::Basename;

BEGIN { use_ok( 'File::DirWalk' ); }
require_ok( 'File::DirWalk' );

my $perl_path        = dirname($^X);
my $perl_interpreter = basename($^X);

$dw = new File::DirWalk();
$dw->onDirEnter(sub {
	my ($path) = @_;
	ok(-e $path);
	ok(-d $path);

	if ($dw->currentPath() eq $perl_path) {
		return 42;
	}
		
	return SUCCESS;
});

is( $dw->walk($perl_path), 42 );

$dw = new File::DirWalk();
$dw->onDirEnter(sub {
	my ($path) = @_;
	ok(-e $path);
	ok(-d $path);

	if ($dw->currentDir() eq $perl_path) {
		return 42;
	}
		
	return SUCCESS;
});

is( $dw->walk($perl_path), 42 );

$dw = new File::DirWalk();
$dw->onFile(sub {
	my ($path) = @_;
	ok(-e $path);
	ok(-f $path);

	if ($dw->currentBasename() eq $perl_interpreter) {
		return 42;
	}

	return SUCCESS;
});

is( $dw->walk($perl_path), 42 );
