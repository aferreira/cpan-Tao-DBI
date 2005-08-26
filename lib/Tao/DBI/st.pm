
package Tao::DBI::st;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw();

our $VERSION = '0.00_02';

# the instance variables:
# DBH
# SQL
#   PLACES, (the mapping between anonymous placholders and named placeholders)
#   ARGNS   (the current argument names)
# STMT
#
# NAME

# creates a SQL::Statement object (the statement is
# prepared during initialization).
sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $obj = bless {}, $class;
  $obj->initialize(@_);
  return $obj;
}

# { dbh => , sql => }
sub initialize {
  my ($self, $args) = @_;
  my $sql = $self->{SQL} = $args->{sql};
  $self->{DBH} = $args->{dbh};
  my ($ssql, $places, $argns) = strip($sql);
  $self->{PLACES} = $places;
  $self->{ARGNS} = $argns;
  $self->{STMT} = $self->{DBH}->prepare($ssql); # needs to support optional args

}

# ($ssql, $places, $argns) = strip($sql);
sub strip {
  my $sql = shift;
  my $ssql = '';
  my @places = (); my %args = ();

  for ( $_ = $sql; ; ) {
    $ssql .= ':', next
      if /\G::/gc;
    $ssql .= "?", push(@places, $1), $args{$1}=1, next
      if /\G:(\w+)/gc;
    $ssql .= $1, next
      if /\G([^:]*)/gc;
    last;
  }
  # if not at the end of string, invalid use of :[^\w:] -> not yet implemented

  my @argns = keys %args;
  return ($ssql, \@places, \@argns);
}

# $stmt->execute($hash_ref)
# $stmt->execute($scalar)
# $stmt->execute
sub execute {
  my $self = shift;
  my $args = shift;

  if (!$args) {
    if (@{$self->{ARGNS}}) {
       die "execute on SQL::Statement missing arguments";
    }
    return $self->{STMT}->execute;

  } elsif (ref $args) {
    return $self->{STMT}->execute(@{%$args}{@{$self->{PLACES}}}, @_);
  } else {
    if (@{$self->{ARGNS}}!=1) {
      die "execute on SQL::Statement with a single non-ref argument only for one-parameter statements";
    }
    return $self->{STMT}->execute(($args) x @{$self->{PLACES}}, @_);
  }
}

# fetch*

use vars qw($AUTOLOAD);

# If method wasn't found, delegates to STMT instance variable.
# This way, instances of this class behaves like DBI statements.
sub AUTOLOAD {
  my $self = shift;
  my $meth = $AUTOLOAD;
  $meth =~ s/.*:://;
  return $self->{STMT}->$meth(@_);
}


1;

# NOTE.
# In SQL statements, ':' has a special meaning as the prefix of a placeholder.
# If you need to include ':' within a statement to be literally interpreted,
# double it: '::'.


__END__

=head1 NAME

Tao::DBI::st - DBI statements with portable support for named placeholders

=head1 SYNOPSIS

  use Tao::DBI qw(dbi_connect dbi_prepare);
  
  $dbh = dbi_connect($args);
  $sql = q{UPDATE T set a = :a, b = :b where k = :k};
  $stmt = $dbh->prepare($sql);
  $rc = $stmt->execute({ k => $k, a => $a, b => $b });
  
  # dbi_prepare() can also be used to create Tao::DBI::st
  $stmt = dbi_prepare($sql, { dbh => $dbh });
  

=head1 DESCRIPTION



=over 4

=item B<execute>

  $sth->execute($hash);
  $sth->execute($param);
  $sth->execute;

Returns 

=back

=head2 EXPORT

Nothing to be exported. Every method is available as a method.

=begin comment

=head1 SEE ALSO

=end comment

=head1 BUGS

Please report bugs via CPAN RT L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tao-DBI>.

=head1 AUTHOR

Adriano R. Ferreira, E<lt>ferreira@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Adriano R. Ferreira

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
