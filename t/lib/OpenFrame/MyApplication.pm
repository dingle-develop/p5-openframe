package OpenFrame::MyApplication;

use strict;
use warnings::register;
use lib '..';

use OpenFrame::Application;
use OpenFrame::AbstractResponse;

use base qw (OpenFrame::Application);

our $epoints = { example => [ 'param' ]};

sub default {
  my $self = shift;
  $self->{message} = "No parameters were passed";
}

sub example {
  my $self = shift;
  my $session = shift;
  $self->{message} = "A parameter was passed: ";
  $self->{message} .= $session->{system}->{parameters}->{param};
}

1;
