package OpenFrame::Server::Apache;

##
## OpenFrame::Server::Apache
## Creates an abstract request
##

use strict;
use warnings;
use warnings::register;

use URI;
use Apache;
use Scalar::Util qw ( blessed );

use Apache::Cookie;
use Apache::Request;
use Apache::Constants qw ( :response );

use OpenFrame::Server;
use OpenFrame::AbstractCookie;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;

our $VERSION = (split(/ /, q{$Id: Apache.pm,v 1.7 2001/11/02 16:34:42 james Exp $ }))[2];

sub handler {
  my $request = shift;

  ##
  ## make sure we have a valid request
  ##
  if (!$request || !blessed( $request) || !$request->isa('Apache')) {
    if (warnings::enabled) {
      warnings::warn("invalid call to handler") if (warnings::enabled || $OpenFrame::DEBUG);
    }
    return undef;
  }

  my $url = 'http://' . $request->hostname . $request->uri;

  my $uri = URI->new( $url );
  if ($uri) {
    $uri->path( $request->uri() );
    $uri->host( $request->hostname() );
    $uri->scheme( 'http' );
  } else {
    warnings::warn("server could not create URI object") if (warnings::enabled || $OpenFrame::DEBUG);
    return SERVER_ERROR;
  }

  ##
  ## abstract the request
  ##
  my $ar = Apache::Request->new( $request );

  my $args = { map { ($_, $ar->param($_)) } $ar->param() };

  my $cookietin  = OpenFrame::AbstractCookie->new();
  my %apcookies  = Apache::Cookie->fetch();

  foreach my $key (keys %apcookies) {
    $cookietin->addCookie(
			  Cookie => OpenFrame::AbstractCookie::CookieElement->new(
										  Name  => $apcookies{$key}->name(),
										  Value => $apcookies{$key}->value(),
										 ),
			 );
  }

  my $abstractRequest = OpenFrame::AbstractRequest->new(
							uri         => $uri,
							originator  => ref( $request ),
							descriptive => 'web',
							args        => $args,
							cookies     => $cookietin,
						       );

  if (!$abstractRequest) {

    if (warnings::enabled) {
      warnings::warn("could not create abstract request object") if (warnings::enabled || $OpenFrame::DEBUG);
    }

    return undef;

  } else {

    my $response = OpenFrame::Server->action( $abstractRequest );

    if (blessed( $response ) && $response->isa( 'OpenFrame::AbstractResponse' )) {
      if ($response->getMessageCode() eq ofOK) {



	## first prepare the cookie

	my $abcookies = $response->getCookie();
	foreach my $biscuit ($abcookies->getCookies()) {
	  my $nom    = $biscuit->getName();
	  my $val    = $biscuit->getValue();
	  my $cookie = Apache::Cookie->new(
					   Apache->request,
					   -name  => $nom,
					   -value => $val,
					  );

	  warnings::warn("[slot::session] rewrite cookie is $cookie") if (warnings::enabled || $OpenFrame::DEBUG);
	  Apache->request()->header_out(
					"Set-Cookie" => $cookie->as_string
				       );
	}


	warnings::warn("[apache] ok") if (warnings::enabled || $OpenFrame::DEBUG);
	$request->no_cache(1);
	$request->send_http_header( $response->mimeType() || 'text/html' );
	$request->print( $response->getMessage() );

	return OK;
      } elsif ($response->getMessageCode() eq ofDECLINED) {
	warnings::warn("[apache] declined") if (warnings::enabled || $OpenFrame::DEBUG);
	return DECLINED;
      } elsif ($response->getMessageCode() eq ofREDIRECT) {
	warnings::warn("[apache] redirect") if (warnings::enabled || $OpenFrame::DEBUG);
	return REDIRECT;
      } elsif ($response->getMessageCode() eq ofERROR) {
	warnings::warn("[apache] server error") if (warnings::enabled || $OpenFrame::DEBUG);
	warnings::warn($response->getMessage());
	return SERVER_ERROR;
      } else {
	warnings::warn("[apache] unrecognized response");
      }
    }

  }
}


1;

__END__

=head1 NAME

OpenFrame::Server::Apache - Apache extension for OpenFrame

=head1 SYNOPSIS

This is a mod_perl extension, see the INSTALL guide for information on how to install it.

=head1 DESCRIPTION

I<OpenFrame::Server::Apache> is an Apache extension.  It is responsible for creating an
I<OpenFrame::AbstractRequest> object and passing it back to the main server class.  It also
delivers the I<OpenFrame::AbstractResponse> object to the client.

=head1 DEPENDANCIES

=over 4

=item Apache

=item OpenFrame::AbstractRequest

=back

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 BUGS

None known

=cut
