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
        my ($path,$dir,$basename) = @_;
        ok(-e $path);
        ok(-f $path);
        ok(-d $dir);
        is($dir, "t");
        is($dw->currentDir(), "t");
        is($dw->currentDir(), $dir);
        is($dw->currentBasename(), $basename);

        if (($dw->currentBasename() eq $f) and ($basename eq $f)) {
            return 42;
        }

        return SUCCESS;
    });

    is($dw->walk("t/"), 42);
}
