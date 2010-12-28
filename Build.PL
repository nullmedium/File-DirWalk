#!/usr/bin/perl

use strict;
use Module::Build;

Module::Build->new( module_name => 'File::DirWalk',
                    author      => 'jens.luedicke@gmail.com',
                    license     => 'perl',
                    requires    => {'Test::Simple' => '0.72'},
                    sign        => 1,
                    create_makefile_pl => 'traditional',
                  )->create_build_script;
