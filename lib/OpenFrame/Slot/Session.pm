package OpenFrame::Slot::Session;

use strict;
use warnings::register;

use FileHandle;
use OpenFrame::Config;
use OpenFrame::AbstractCookie;
use Digest::MD5 qw(md5_hex);

use Data::Dumper;

our $VERSION = (split(/ /, q{$Id: Session.pm,v 1.15 2001/11/12 12:37:45 james Exp $ }))[2];

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
