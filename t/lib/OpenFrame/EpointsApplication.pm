package OpenFrame::EpointsApplication;

use strict;
use lib '..';

use OpenFrame::Application;
use OpenFrame::AbstractResponse;

use base qw (OpenFrame::Application);

our $epoints = sub {
  my $args = shift;
  if ($args->{foo}) {
    return 'bar';
  } elsif ($args->{bar}) {
    return 'quux';
  } elsif ($args->{quux}) {
    return 'foo';
  }
  return 'default';
};

sub default {
  my $self = shift;
  $self->{message} = "default";
}

sub foo {
  my $self = shift;
  $self->{message} = "foo";
}

sub bar {
  my $self = shift;
  $self->{message} = "bar";
}

sub quux {
  my $self = shift;
  $self->{message} = "quux";
}

1;
