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
  warnings::warn("[slot::sessionsaver] in session saver") if (warnings::enabled || $OpenFrame::DEBUG);
  my $class   = shift;
  my $session = shift;
  
  warnings::warn("[slot::sessionsaver] Session is " .  Dumper( $session )) if (warnings::enabled || $OpenFrame::DEBUG);

  $session->writeSession();
}

1;
