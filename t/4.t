use Test::More qw(no_plan);
use Test::Exception;

use File::Basename;
use File::Spec::Functions;

BEGIN { use_ok( 'File::DirWalk' ); }
require_ok( 'File::DirWalk' );

$dw = new File::DirWalk();

ok( -e "t/tree" );
ok( -d "t/tree" );

foreach my $subdir (qw(dir1 dir2 dir3 dir4 dir5)) {
	ok( -e "t/tree/$subdir" );
	ok( -d "t/tree/$subdir" );

	$dw = new File::DirWalk();
	$dw->onBeginWalk(sub {
		my ($path) = @_;
		ok(-e $path);

		if ($dw->currentBasename() eq $subdir) {
			return 42;
		}

		return SUCCESS;
	});
	is( $dw->walk("t/tree"), 42 );

	$dw = new File::DirWalk();
	$dw->onDirEnter(sub {
		my ($path) = @_;
		ok(-e $path);
		ok(-d $path);

		if ($dw->currentBasename() eq $subdir) {
			is( $dw->count(), 10 );
			is( $dw->currentDepth(), 2 );
			return 42;
		}

		return SUCCESS;
	});
	is( $dw->walk("t/tree"), 42 );

	$dw = new File::DirWalk();
	$dw->onDirLeave(sub {
		my ($path) = @_;
		ok(-e $path);
		ok(-d $path);

		if ($dw->currentBasename() eq $subdir) {
			is( $dw->count(), 10 );
			is( $dw->currentDepth(), 2 );
			return 42;
		}

		return SUCCESS;
	});

	is( $dw->walk("t/tree"), 42 );

	$dw = new File::DirWalk();
	$dw->onFile(sub {
		my ($path) = @_;
		ok(-e $path);
		ok(-f $path);
		return SUCCESS;
	});

	is( $dw->walk("t/tree/$subdir"), SUCCESS );
	is( $dw->count(), 10 );
}

$files = 0;
$dw = new File::DirWalk();
$dw->onFile(sub {
	my ($path) = @_;
	ok(-e $path);
	ok(-f $path);
	++$files;
	return SUCCESS;
});

is( $dw->walk("t/tree"), SUCCESS );
is( $files, 50 );
