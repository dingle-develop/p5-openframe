package OpenFrame::Request;

use strict;
use warnings::register;

use OpenFrame::Object;
use base qw ( OpenFrame::Object );

our $VERSION = '3.01';

sub uri {
  my $self = shift;

  if (!ref($self)) {
    $self->error("uri called as a class method");
  }

  my $uri  = shift;
  if (defined( $uri )) {
    $self->{ uri } = $uri;
    return $self;
  } else {
    return $self->{ uri };
  }
}

sub arguments {
  my $self = shift;
  my $args = shift;
  if (defined( $args )) {
    $self->{ args } = $args;
    return $self;
  } else {
    return $self->{ args };
  }
}

sub cookies {
  my $self = shift;
  my $ctin = shift;
  if (defined( $ctin )) {
    $self->{ ctin } = $ctin;
    return $ctin;
  } else {
    return $self->{ ctin };
  }
}

1;
