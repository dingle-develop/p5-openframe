
package OpenFrame::Slot::SessionSaver;

use strict;
use warnings::register;

use Data::Dumper;
use OpenFrame::Slot;
use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::Session'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $session = shift;
  
  warnings::warn("[slot::sessionsaver] saving $session $session->{id}") if (warnings::enabled || $OpenFrame::DEBUG);

  $session->writeSession( $config );
}

1;
