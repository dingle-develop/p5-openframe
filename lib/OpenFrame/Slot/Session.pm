package OpenFrame::Slot::Session;

use strict;
use Apache::Session;
use Apache::SessionX;
use Data::Denter;
use OpenFrame::Config;
use OpenFrame::AbstractCookie;

our $VERSION = (split(/ /, q{$Id: Session.pm,v 1.24 2001/12/05 18:01:08 leon Exp $ }))[2];

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $req   = shift;

  if (!ref($req)) {
    warn("[slot::session] no abstract request received") if $OpenFrame::DEBUG;
    return undef;
  }

  my $cookietin = $req->cookies();

  my $id;
  my $new = 0;

  if ($cookietin->get("session")) {
    $id = $cookietin->get("session");
  } else {
    $new = 1;
  }

  my %session;
  eval {
    tie %session, 'Apache::SessionX', $id;
  };
  if ($@) {
    tie %session, 'Apache::SessionX', $id, { create_unknown => 1};
    warn("[slot::session] recreating session") if $OpenFrame::DEBUG;
    $new = 1;
  }

  my $session = \%session;
  bless $session, "OpenFrame::Session";

  if ($new) {
    $session->{$_} = $config->{default_session}->{$_}
      foreach keys %{$config->{default_session}};
  }

  $cookietin->set("session", tied(%session)->getid);

  $session->{transactions}++;

  warn("Session is " . Denter($session)) if $OpenFrame::DEBUG;

  delete $session->{system}->{parameters};
  $session->{system}->{parameters} = $req->arguments();

  return ($session, $cookietin, 'OpenFrame::Slot::SessionSaver');
}

1;

__END__

=head1 NAME

OpenFrame::Slot::Session - Handle cookie-based sessions

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::Session',
  config   => {
    default_session => {
      language => 'en',
      country  => 'UK',
      application => {},
      },
    },
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::Session> is an OpenFrame slot that can handle
cookie-based session handling.

Apart from adding it as a SLOT early on in the slot process, the
handling of session is done fairly transparently.

Sessions are currently handled by the C<Apache::SessionX> modue and
are not expired. This is somewhat of a pain, as you have to set up
that module properly before being able to use sessions, but this
brings the advantage of transparently using the right session
environment, be that static files, a BerkeleyDB file or even a
database. A default session can be passed as "default_session".

After this slot is run, slots may request C<OpenFrame::Session>
objects. Applications using C<OpenFrame::Slot::Dispatch> automatically
get the session passed to them.

Any information stored in the session hash will be magically available
upon the next request by the same user. This is handled behind the
scenes by sending and receiving a cookie.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>,
Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
