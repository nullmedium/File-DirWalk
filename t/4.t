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
        my ($path,$dir,$basename) = @_;
        ok(-e $path);
        ok(-d $dir);
        is($dw->currentDir(), $dir);
        is($dw->currentBasename(), $basename);

        if (($dw->currentBasename() eq $subdir) and ($basename eq $subdir)) {
            return 42;
        }

        return SUCCESS;
    });
    is( $dw->walk("t/tree"), 42 );

    $dw = new File::DirWalk();
    $dw->onDirEnter(sub {
        my ($path,$dir,$basename) = @_;
        ok(-e $path);
        ok(-d $path);
        ok(-d $dir);
        is($dw->currentDir(), $dir);
        is($dw->currentBasename(), $basename);

        if (($dw->currentBasename() eq $subdir) and ($basename eq $subdir)) {
            is( $dw->currentDepth(), 2 );
            is( @{$dw->entryList()}, 10);
            is( $dw->count(), 10 );

            foreach my $expected (qw(file0 file1 file2 file3 file4 file5 file6 file7 file8 file9)) {
                my @foo = grep(/$expected/, @{$dw->entryList()});
                is(@foo, 1);
                is($foo[0], $expected);
            }
            
            return 42;
        }

        return SUCCESS;
    });
    is( $dw->walk("t/tree"), 42 );

    $dw = new File::DirWalk();
    $dw->onDirLeave(sub {
        my ($path,$dir,$basename) = @_;
        ok(-e $path);
        ok(-d $path);
        ok(-d $dir);
        is($dw->currentDir(), $dir);
        is($dw->currentBasename(), $basename);

        if (($dw->currentBasename() eq $subdir) and ($basename eq $subdir)) {
            is( $dw->currentDepth(), 2 );
            is( @{$dw->entryList()}, 10);
            is( $dw->count(), 10 );

            foreach my $expected (qw(file0 file1 file2 file3 file4 file5 file6 file7 file8 file9)) {
                my @foo = grep(/$expected/, @{$dw->entryList()});
                is(@foo, 1);
                is($foo[0], $expected);
            }
            
            return 42;
        }

        return SUCCESS;
    });

    is( $dw->walk("t/tree"), 42 );

    $dw = new File::DirWalk();
    $dw->onFile(sub {
        my ($path,$dir,$basename) = @_;
        ok(-e $path);
        ok(-f $path);
        ok(-d $dir);
        is($dir, "t/tree/$subdir");
        is($dw->currentDir(), "t/tree/$subdir");
        is($dw->currentDir(), $dir);
        is($dw->currentBasename(), $basename);
        return SUCCESS;
    });

    is( $dw->walk("t/tree/$subdir"), SUCCESS );
    is( $dw->count(), 10 );
}

$files = 0;
$dw = new File::DirWalk();
$dw->onFile(sub {
    my ($path,$dir,$basename) = @_;
    ok(-e $path);
    ok(-f $path);
    ok(-d $dir);
    is($dw->currentDir(), $dir);
    is($dw->currentBasename(), $basename);
    ++$files;
    return SUCCESS;
});

is( $dw->walk("t/tree"), SUCCESS );
is( $files, 50 );
