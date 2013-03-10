use Test::More tests => 29;
use Test::Exception;

BEGIN { use_ok( 'File::DirWalk' ); }
require_ok( 'File::DirWalk' );

$dw = new File::DirWalk();
is(ref($dw), 'File::DirWalk' );

is ($dw->getDepth(), 0);
dies_ok { $dw->setDepth(-1) };
is ($dw->getDepth(), 0);
ok ($dw->setDepth(1));
is ($dw->getDepth(), 1);

ok ($dw->onBeginWalk(sub {}));
ok ($dw->onLink(sub {}));
ok ($dw->onFile(sub {}));
ok ($dw->onDirEnter(sub {}));
ok ($dw->onDirLeave(sub {}));
dies_ok {$dw->onBeginWalk(0)};
dies_ok {$dw->onLink(0)};
dies_ok {$dw->onFile(0)};
dies_ok {$dw->onDirEnter(0)};
dies_ok {$dw->onDirLeave(0)};

ok ($dw->setHandler(onBeginWalk => sub {}));
ok ($dw->setHandler(onLink      => sub {}));
ok ($dw->setHandler(onFile      => sub {}));
ok ($dw->setHandler(onDirEnter  => sub {}));
ok ($dw->setHandler(onDirLeave  => sub {}));
dies_ok {$dw->setHandler(onBeginWalk => 0)};
dies_ok {$dw->setHandler(onLink      => 0)};
dies_ok {$dw->setHandler(onFile      => 0)};
dies_ok {$dw->setHandler(onDirEnter  => 0)};
dies_ok {$dw->setHandler(onDirLeave  => 0)};
dies_ok {$dw->setHandler(Foo => sub {})};
