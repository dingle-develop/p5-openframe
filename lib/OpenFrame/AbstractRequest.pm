package OpenFrame::AbstractRequest;

##
## OpenFrame::AbstractRequest -- receives requests from OpenFrame::Server::*
##                                 and abstracts them.

use strict;
use warnings::register;

use URI;
use Scalar::Util qw ( blessed );

our $VERSION = 1.00;

sub new {
  my $class = shift;
  my $args  = { @_ };

  ##
  ## check for required parameters
  ##
  if (!(exists $args->{uri})) {
    if (warnings::enabled) {
      warnings::warn("no URI passed to $class");
    }
    return undef;
  }

  ## we are using a hashref for the object
  my $self = bless {} => $class;

  if (!$self->setURI( $args->{uri} )) {
    return undef;
  }

  ##
  ## optionals
  ##
  $self->setOriginator( $args->{originator} || 'GenericServer' );
  $self->setDescriptive( $args->{descriptive} || 'web' );
  $self->setArguments( $args->{args} );

  $self->setCookies( $args->{cookies} );

  return $self;
}

sub getURI {
  return URI->new( $_[0]->{uri} );
}

sub setURI {
  my $self = shift;
  if (blessed $_[0] && $_[0]->isa( 'URI' )) {
    $self->{uri} = $_[0]->canonical();
    warnings::warn("[abstractrequest] uri is $self->{uri}") if (warnings::enabled && $OpenFrame::DEBUG);
    return 1;
  } else {
    if (warnings::enabled) {
      warnings::warn("not a URI object");
    }
    return 0;
  }
}

sub setOriginator : method {
  $_[0]->{origin} = $_[1];
  return 1;
}

sub getOriginator : method {
  return $_[0]->{origin};
}

sub setDescriptive : method {
  $_[0]->{desc} = $_[1];
  return 1;
}

sub getDescriptive : method {
  return $_[0]->{desc};
}

sub getCookies : method {
  return $_[0]->{cookies};
}

sub setCookies : method {
  my $self = shift;
  $self->{cookies} = shift;
  return 1;
}

sub getArguments : method {
  my $self = shift;
  return $self->{args};
}

sub setArguments : method {
  my $self = shift;
  $self->{args} = shift;
}



1;
