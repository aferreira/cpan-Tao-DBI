
use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Tao::DBI',
    VERSION_FROM      => 'lib/Tao/DBI.pm', # finds $VERSION
    PREREQ_PM         => {
        DBI               => 1,
    }, 
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Tao/DBI.pm', # retrieve abstract from module
       AUTHOR         => 'A. R. Ferreira <ferreira@cpan.org>',
       NO_META           => 1) : ()),
);
