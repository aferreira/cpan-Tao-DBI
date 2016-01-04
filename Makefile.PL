
use 5.006;
use ExtUtils::MakeMaker;

my $EUMM_VERSION = eval $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    NAME              => 'Tao::DBI',
    VERSION_FROM      => 'lib/Tao/DBI.pm', # finds $VERSION
    PREREQ_PM         => {
        DBI               => 1,
    }, 
    ($] >= 5.005 ? (
       ABSTRACT_FROM  => 'lib/Tao/DBI.pm', # retrieve abstract from module
       AUTHOR         => 'A. R. Ferreira <ferreira@cpan.org>',
    ) : ()),
    ($EUMM_VERSION > 6.4501 ? (
        META_MERGE => {
            resources => {
                repository => 'http://github.com/aferreira/cpan-Tao-DBI',
            }
        },
    ) : ()),
);
