use Test::More qw(no_plan);
use Test::Exception;

use File::Basename;

BEGIN { use_ok( 'File::DirWalk' ); }
require_ok( 'File::DirWalk' );

ok(-e "t/");
ok(-d "t/");

foreach my $f qw(1.t 2.t 3.t 4.t) {
	$dw = new File::DirWalk();
	$dw->setDepth(1);

	$dw->onFile(sub {
		my ($path) = @_;
		ok(-e $path);
		ok(-f $path);

		if ($dw->currentBasename() eq $f) {
			return 42;
		}

		return SUCCESS;
	});

	is($dw->walk("t/"), 42);
}
