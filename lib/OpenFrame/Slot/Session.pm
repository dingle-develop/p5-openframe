package OpenFrame::Slot::Session;

use strict;
use warnings::register;

use FileHandle;
use OpenFrame::Config;
use OpenFrame::AbstractCookie;
use Digest::MD5 qw(md5_hex);

use Data::Dumper;

our $VERSION = (split(/ /, q{$Id: Session.pm,v 1.16 2001/11/13 14:30:44 leon Exp $ }))[2];

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $req   = shift;

  if (!ref($req)) {
    warnings::warn("[slot::session] no abstract request received") if (warnings::enabled || $OpenFrame::DEBUG);
    return undef;
  }

  my $session = {};
  my $key     = '';

  my $cookietin = $req->cookies();

  if (!$cookietin) {
    warnings::warn("[slot::session] did not fetch any cookies");
  }

  if (!$cookietin->getCookie("session") || !$cookietin->getCookie("session")->getValue()) {
    $session = $config->{default_session};

    $key  = generate_key();
    warnings::warn("[slot::session] key is $key") if (warnings::enabled || $OpenFrame::DEBUG);

    $session->{id} = $key;


    my $cookie = OpenFrame::AbstractCookie::CookieElement->new(
							       Name  => 'session',
							       Value => $key,
							      );
    $cookietin->addCookie( Cookie => $cookie );

    bless $session, 'OpenFrame::Session';
  } else {

    my $sessiondir = $config->{sessiondir};
    my $id         = $cookietin->getCookie("session")->getValue();

    my $fh = FileHandle->new("<$sessiondir/$id");
    if ($fh) {
      local $/ = undef;
      {
	no strict;
	$session = eval <$fh>;
	if ($@) {
	  warnings::warn("[slot::session] cannot recreate cookie $@") if (warnings::enabled || $OpenFrame::DEBUG);
	}
      }
      $fh->close();

      bless $session, 'OpenFrame::Session';
    } else {
      warnings::warn("[slot::session] reviving expired session $id") if (warnings::enabled || $OpenFrame::DEBUG);

      $session = $config->{default_session};
      $session->{id} = $id;

      bless $session, 'OpenFrame::Session';
    }

    my $cookie = OpenFrame::AbstractCookie::CookieElement->new(
							       Name  => 'session',
							       Value => $id,
							      );
    $cookietin->addCookie( Cookie => $cookie );



  }
  $session->{transactions}++;

  warnings::warn("Session is " . Dumper( $session )) if (warnings::enabled || $OpenFrame::DEBUG);

  delete $session->{system}->{parameters};
  $session->{system}->{parameters} = $req->arguments();

  return ($session,$cookietin,'OpenFrame::Slot::SessionSaver');
}

sub OpenFrame::Session::writeSession {
  my $self   = shift;
  my $config = shift;

  if ((!defined($config) && !ref($config)) || $self->{nosave}) {
    warnings::warn("[session] not saving session") if (warnings::enabled || $OpenFrame::DEBUG);
    return;
  }

  my $caller = caller();
  my $fh = FileHandle->new( ">$config->{sessiondir}/$self->{id}");
  if ($fh) {
    $fh->print(Dumper($self));
    $fh->close();
  } else {
    warnings::warn("[slot::session] could not write session object") if (warnings::enabled || $OpenFrame::DEBUG);
  }
  return;
}

sub generate_key {
  # See page 5 of ftp://ftp.rsasecurity.com/pub/cryptobytes/crypto1n1.pdf
  # for why we are hashing twice
  return substr(md5_hex(time() . md5_hex(time(). {}. rand(). $$)), 0, 16);
}

1;

__END__

=head1 NAME

OpenFrame::Slot::Session - handle cookie-based sessions

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::Session',
  config   => {
    sessiondir => "../../t/sessiondir",
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

Sessions are currently stored on disk and are not expired. The
directory where they are stored is passed as the configuration option
"sessiondir", and a default session can be passed as "default_session".

After this slot is run, slots may request C<OpenFrame::Session>
objects. Applications using C<OpenFrame::Slot::Dispatch> automatically
get the session passed to them.

Any information stored in the session hash will be magically available
upon the next request by the same user. This is handled behind the
scenes by sending and receiving a cookie.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
