package OpenFrame::Slot::SessionSaver;

use strict;

use Data::Dumper;
use OpenFrame::Slot;
use base qw ( OpenFrame::Slot );

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


  my $params = $session->{system}->{parameters};
  foreach my $key (keys %{$params}) {
      if (ref($params->{$key}) eq 'GLOB') {
	  delete $params->{$key};
      }
  }

  warn("[slot::sessionsaver] saving $session") if $OpenFrame::DEBUG;
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
