package OpenFrame::Cookies;

use strict;
use warnings::register;

our $VERSION = '3.00';

use OpenFrame::Cookie;
use OpenFrame::Object;
use base qw ( OpenFrame::Object );

sub init {
  my $self = shift;
  $self->cookies( {} );
}

sub cookies {
  my $self = shift;
  my $val  = shift;
  if (defined( $val )) {
    $self->{cookies} = $val;
    return $self;
  } else {
    return $self->{cookies};
  }
}

sub set {
  my $self = shift;
  my $key  = shift;
  my $val  = shift;

  if (defined($key) && !defined($val)) {
    ## chances are we have a Cookie object
    if ($key->isa('OpenFrame::Cookie')) {
      ## get the name out of the cookie, and we store it
      $self->cookies->{ $key->name } = $key;
    } else {
      $self->error("object $key is not an OpenFrame::Cookie");
      return undef;
    }
  } elsif (defined($key) && defined($val)) {
    ## right, we have a key value pair that we need to turn
    ## into an OpenFrame::Cookie object

    my $cookie = OpenFrame::Cookie->new();
    $cookie->name( $key );
    $cookie->value( [ $val ] );

    ## call this method again with the cookie as the parameter
    $self->set( $cookie );

  } else {
    $self->error("usage: ->set( <COOKIE || KEY, VALUE> )");
  }

}

sub get {
  my $self = shift;
  my $key  = shift;
  if (defined( $key )) {
    return $self->cookies->{ $key };
  } else {
    $self->error("no key specified");
  }
}

sub delete {
  my $self = shift;
  my $key  = shift;
  if (defined( $key )) {
    delete $self->{ cookies }->{ $key };
  } else {
    $self->error("no key specified");
  }
}

sub get_all {
  my $self = shift;
  return %{$self->cookies};
}

1;

