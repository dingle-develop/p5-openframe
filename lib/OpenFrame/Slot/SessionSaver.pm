package OpenFrame::Slot::SessionSaver;

use strict;

use Data::Dumper;
use OpenFrame::Slot;
use OpenFrame::Constants qw( :debug );
use base qw ( OpenFrame::Slot );

our $DEBUG = ($OpenFrame::DEBUG || 0) & ofDEBUG_SESSION;
*warn = \&OpenFrame::warn;

sub what {
  return ['OpenFrame::Session', 'OpenFrame::Request', 'Cache::FileCache'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $session = shift;
  my $request = shift;
  my $cache = shift;
  my $dir = $config->{directory};

  $DEBUG = ($OpenFrame::DEBUG || 0) & ofDEBUG_SESSION;

  # Parameters don't need to be saved
  delete $session->{system}->{parameters};

  &warn("saving $session") if $DEBUG;
  my $cookietin = $request->cookies();
  my $id = $cookietin->get("session");
  $cache->set($id, $session);
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

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
