package OpenFrame::Cookie;

use strict;
use warnings::register;

use CGI::Cookie;
use base qw ( CGI::Cookie );

sub value {
  my $self = shift;
  my $val  = shift;

  if (defined($val) && !ref($val)) {
    $self->SUPER::value( [ $val ] );
  } else {
    $self->SUPER::value( $val, @_ );
  }
}

1;
