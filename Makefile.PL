use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'fusinvserv',
    AUTHOR              => q{Gonéri Le Bouder},
    VERSION_FROM        => 'lib/fusinvserv.pm',
    ABSTRACT            => 'A Demo FusionInventory server',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer'     => 1.3095,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'fusinvserv-*' },
);
