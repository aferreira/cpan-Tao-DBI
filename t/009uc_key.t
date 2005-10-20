
use Test::More;

eval "require DBD::SQLite";
plan skip_all => "DBD::SQLite required for testing Tao::DBI" if $@;

# this script tests FetchHashKeyName => 'NAME_uc'

plan tests => 5;

use_ok('Tao::DBI', qw(dbi_connect));

END { 
  unlink 't/t.db' if -e 't/t.db' 
}

my $dbh = dbi_connect({ dsn => 'dbi:SQLite:dbname=t/t.db', FetchHashKeyName => 'NAME_uc' });
ok($dbh, 'defined $dbh');

{
  my $sql = qq{SELECT 1 AS field};
  my $sth = $dbh->prepare($sql);
  ok($sth, 'prepare ok');
  ok($sth->execute, 'execute ok');
  my $row = $sth->fetchrow_hashref;
  is_deeply($row, { FIELD => 1 }, 'keys in uppercase ok');
}
