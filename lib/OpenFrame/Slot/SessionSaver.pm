package OpenFrame::Slot::SessionSaver;

use strict;

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

  warn("[slot::sessionsaver] saving $session") if $OpenFrame::DEBUG;
  (tied %$session)->cleanup();
}

1;

__END__

=head1 NAME

OpenFrame::Slot::SessionSaver - Handle cookie-based sessions

=head1 SYNOPSIS

  # None

=head1 DESCRIPTION

See C<OpenFrame::Slot::Session>
instead. C<OpenFrame::Slot::SessionSaver> is the slot that handles
saving the session, but you should not need to invoke it manually.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
