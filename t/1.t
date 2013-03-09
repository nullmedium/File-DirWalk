use Test::More qw(no_plan);
use Test::Exception;

BEGIN { use_ok( 'File::DirWalk' ); }
require_ok( 'File::DirWalk' );

$dw = new File::DirWalk();

ok( ref($dw) eq 'File::DirWalk' );

is ($dw->getDepth(), 0);
dies_ok { $dw->setDepth(-1) };
is ($dw->getDepth(), 0);
ok ($dw->setDepth(1));
is ($dw->getDepth(), 1);

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
