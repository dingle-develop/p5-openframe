package OpenFrame::Response;

use strict;
use warnings::register;

use Exporter;
use OpenFrame::Object;
use Pipeline::Production;
use base qw ( OpenFrame::Object Pipeline::Production Exporter );

our $VERSION = '3.01';

use constant ofOK       => 1;
use constant ofREDIRECT => 2;
use constant ofDECLINE  => 4;
use constant ofERROR    => 8;

##
## we export this because its good
##
our @EXPORT = qw ( ofOK ofREDIRECT ofDECLINE ofERROR );

sub last_modified { }

sub cookies {
  my $self = shift;
  my $cookies = shift;
  if (defined( $cookies )) {
    $self->{cookies} = $cookies;
    return $self;
  } else {
    return $self->{cookies};
  }
}

sub mimetype {
  my $self = shift;
  my $mime = shift;
  if (defined( $mime )) {
    $self->{mimetype} = $mime;
    return $self;
  } else {
    return $self->{mimetype};
  }
}

sub contents {
  my $self = shift;
  return $self;
}

sub message {
  my $self = shift;
  my $mesg = shift;
  if (defined( $mesg )) {
    $self->{ mesg } = $mesg ;
    return $self;
  } else {
    return $self->{ mesg };
  }
}

sub code {
  my $self = shift;
  my $code = shift;
  if (defined( $code )) {
    $self->{ code } = $code;
    return $self;
  } else {
    return $self->{ code }
  }
}


##
## for backwards compatibility we have a package called
##  OpenFrame::Constants
##
package OpenFrame::Constants;


1;

