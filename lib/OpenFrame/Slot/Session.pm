package OpenFrame::Slot::Session;

use strict;
use Cache::SizeAwareFileCache;
use Data::Denter;
use OpenFrame::Config;
use OpenFrame::AbstractCookie;
use Digest::MD5 qw(md5_hex);

our $VERSION = (split(/ /, q{$Id: Session.pm,v 1.25 2002/01/30 12:31:13 leon Exp $ }))[2];

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $req   = shift;
  my $dir = $config->{directory};

  my $cache = Cache::FileCache->new({
    'cache_root' => $config->{directory},
    'namespace' => 'openframe',
    'default_expires_in' => 60*60,
  });

  my $cookietin = $req->cookies();

  my $id;
  my $session = {};
  my $new = 0;

  if ($cookietin->get("session")) {
    # A cookie containing a session id has been sent to us, so read
    # the existing session from the cache
    $id = $cookietin->get("session");
    $session = $cache->get($id);
    if (not defined $session) {
      # A session id has been sent but the session itself has expired
      $session = {};
      $new = 1;
    }
  } else {
    # No cookie has been sent, so we create a new session id 
    $id = substr(md5_hex(time() . md5_hex(time(). {}. rand(). $$)), 0, 16);
    $new = 1;
  }

  if ($new) {
    # Populate the session with the session defaults if it is new or
    # if the session has expired
    $session->{$_} = $config->{default_session}->{$_}
      foreach keys %{$config->{default_session}};
  }

  bless $session, "OpenFrame::Session";

  $cookietin->set("session", $id);
  $session->{transactions}++;

  warn("Session is " . Denter($session)) if $OpenFrame::DEBUG;

  delete $session->{system}->{parameters};
  $session->{system}->{parameters} = $req->arguments();

  return ($session, $cookietin, $cache, 'OpenFrame::Slot::SessionSaver');
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
