package OpenFrame::Server::HTTP;

use strict;
use warnings;
use warnings::register;

use CGI;
use CGI::Cookie;
use URI;
use Scalar::Util qw (blessed);

use OpenFrame::Server;
use OpenFrame::AbstractCookie;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;
use OpenFrame::Constants;
use HTTP::Daemon;
use HTTP::Status;

our $VERSION = '1.00';

sub new {
  my $class = shift;
  my $config = shift;

  my $self = {};
  $self->{_config} = $config || OpenFrame::Config->new();

  bless $self, $class;

  return $self;
}

sub handle {
  my $self = shift;

  my $port = $self->{_config}->{server_http_port} || 8000;
  my $d = HTTP::Daemon->new(LocalPort => $port, Reuse => 1, ReuseAddr => 1) || die;
  while (my $c = $d->accept) {
    while (my $r = $c->get_request) {
      my $uri = URI->new($r->url);
      my $cgi = CGI->new($uri->query);
      my $args = { map { ($_, $cgi->param($_)) } $cgi->param() };
      $uri->query(undef);

      my $cookietin  = OpenFrame::AbstractCookie->new();

      if ($r->header('Cookie')) {
	foreach my $ctext (split /; ?/, $r->header('Cookie')) {
	  my($cname, $cvalue) = split /=/, $ctext;
	  $cookietin->addCookie(
	      Cookie => OpenFrame::AbstractCookie::CookieElement->new(
		      Name  => $cname,
		      Value => $cvalue,
		     ),
	      );
	}
      }

      my $abstractRequest = OpenFrame::AbstractRequest->new(
							    uri         => $uri,
							    descriptive => 'web',
							    arguments   => $args,
							    cookies     => $cookietin,
							   );
      my $http_response;

      if (!$abstractRequest) {
	if (warnings::enabled) {
	  warnings::warn("could not create abstract request object") if (warnings::enabled || $OpenFrame::DEBUG);
	}
	$http_response = HTTP::Response->new(RC_INTERNAL_SERVER_ERROR, "Some sort of error. Drat.");
      } else {
	my $response = OpenFrame::Server->action($abstractRequest, $self->{_config});
	my $newcookietin = $response->cookies();
	if ($response->code == ofOK) {
          my $h = HTTP::Headers->new();
	  foreach my $cookie ($newcookietin->getCookies) {
	    my $cookie = CGI::Cookie->new(-name    =>  $cookie->getName,
				     -value   =>  $cookie->getValue,
				     -expires =>  '+1M');
	    $h->header('Set-Cookie' => "$cookie");
	  }
	  $h->content_type($response->mimetype() || 'text/html');
	  $http_response = HTTP::Response->new(RC_OK, undef, $h, $response->message);
	} else {
	  $http_response = HTTP::Response->new(RC_INTERNAL_SERVER_ERROR, "Some sort of error. Drat.");
	}
      }
      $c->send_response($http_response);
    }
    $c->close;
    undef($c);
  }
}

1;

__END__

=head1 NAME

OpenFrame::Server::HTTP - Provide standalone HTTP access to OpenFrame

=head1 SYNOPSIS

  use OpenFrame::Server::HTTP;
  my $h = OpenFrame::Server::HTTP->new($config);
  $h->handle();

=head1 DESCRIPTION

C<OpenFrame::Server::HTTP> provides a standalone webserver which gives
web access to an OpenFrame application (without having to set up
Apache). The port that the webserver listens on is set by the value of
the server_http_port key in the configuration, although it defaults to
port 8000.

=head1 NOTES

This module requires HTTP::Daemon to be installed.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=cut
