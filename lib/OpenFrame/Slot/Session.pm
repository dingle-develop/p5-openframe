package OpenFrame::Slot::Session;

use strict;
use warnings::register;

use FileHandle;
use OpenFrame::Config;
use OpenFrame::AbstractCookie;

use Data::Dumper;

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $class = shift;
  my $req   = shift;

  if (!ref($req)) {
    warnings::warn("[slot::session] no abstract request received") if (warnings::enabled || $OpenFrame::DEBUG);
    return undef;
  }

  my $session = {};
  my $key     = '';

  my $config    = OpenFrame::Config->new();
  my $cookietin = $req->getCookies();

  if (!$cookietin) {
    warnings::warn("[slot::session] did not fetch any cookies");
  }

  if (!($cookietin->getCookie("session"))) {
    $session = $config->getKey('default_session');

    $key  = generate_key();
    warnings::warn("[slot::session] key is $key") if (warnings::enabled || $OpenFrame::DEBUG);

    $session->{id} = $key;


    my $cookie = OpenFrame::AbstractCookie::CookieElement->new(
							       Name  => 'session',
							       Value => $key,
							      );
    $cookietin->addCookie( $cookie );

    warnings::warn("cookie should be in the tin by now") if (warnings::enabled || $OpenFrame::DEBUG);
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
    }
  }
  $session->{transactions}++;

  warnings::warn("Session is " . Dumper( $session )) if (warnings::enabled || $OpenFrame::DEBUG);

  delete $session->{system}->{parameters};
  $session->{system}->{parameters} = $req->getArguments();
  return ($session,$cookietin);
}

sub OpenFrame::Session::writeSession {
  my $self = shift;

  if ($self->{nosave}) {
    warnings::warn("[session] not saving session -- no save is true")  if (warnings::enabled || $OpenFrame::DEBUG);
    return 1;
  }

  my $caller = caller();
  warnings::warn("[session] writing session file from $caller") if (warnings::enabled || $OpenFrame::DEBUG);
  my $config = OpenFrame::Config->new();
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
  my $fh = FileHandle->new("</dev/random");
  if (!$fh) {
    warnings::warn("[slot::session] could not generate session key") if (warnings::enabled || $OpenFrame::DEBUG);
    return undef;
  } else {
    my $buf;
    $fh->read($buf, 8);
    my $rc = unpack("h8", $buf);
    $fh->close();
    return $rc;
  }
}

1;
