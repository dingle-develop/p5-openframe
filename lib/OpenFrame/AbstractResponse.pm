package OpenFrame::AbstractResponse;

use strict;
use warnings::register;

use Exporter;
use base qw ( Exporter );
our @EXPORT = qw ( ofOK ofERROR ofREDIRECT ofDECLINED ofAUTHERR ofNOTFOUND );

use constant ofOK       => 0x01;  ## response ok
use constant ofERROR    => 0x02;  ## respond with error
use constant ofREDIRECT => 0x03;  ## respond with pointer to new location
use constant ofDECLINED => 0x04;  ## respond with decline
use constant ofAUTHERR  => 0x05;  ## some sort of authentication error
use constant ofNOTFOUND => 0x06;  ## not found, multiple meanings for example: application not found

sub new : method {
  my $class = shift;
  my $self  = {};
  bless $self, $class;
}

sub mimeType {

}

sub setCookie : method {
  my $self = shift;
  $self->{_cookie} = shift;
}

sub getCookie : method {
  return $_[0]->{_cookie};
}

sub setMessage : method {
  my $self = shift;
  $self->{_message} = shift;
}

sub getMessage : method {
  my $self = shift;
  return $self->{_message};
}

sub getMessageCode : method {
  my $self = shift;
  return $self->{_messageCode};
}

sub setMessageCode : method {
  my $self = shift;
  $self->{_messageCode} = shift;
}

1;
