#!/usr/bin/perl

use strict;
use Module::Build;

Module::Build->new( module_name => 'File::DirWalk',
                    author      => 'jens.luedicke@gmail.com',
                    license     => 'perl',
                    requires    => {
                        'Carp'           => '1.08',
                        'File::Spec'     => '3.2501',
                        'File::Basename' => '2.76',
                    },
                    recommends => {
                        'Test::More'   => '0.72',
                        'Test::Exception' => '0.27'
                    },
                    sign        => 1,
                    create_makefile_pl => 'traditional',
                  )->create_build_script;
