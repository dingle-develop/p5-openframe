package OpenFrame::Server::Apache;

##
## OpenFrame::Server::Apache
## Creates an abstract request
##

use strict;

use URI;
use Apache;
use Scalar::Util qw ( blessed );

use Apache::Cookie;
use Apache::Request;
use Apache::Constants qw ( :response );

use OpenFrame::Server;
use OpenFrame::Constants;
use OpenFrame::AbstractCookie;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;

our $VERSION = (split(/ /, q{$Id: Apache.pm,v 1.15 2001/11/27 14:59:17 james Exp $ }))[2];

sub handler {
  my $request = shift;

  ##
  ## make sure we have a valid request
  ##
  if (!$request || !blessed( $request) || !$request->isa('Apache')) {
    warn("invalid call to handler") if $OpenFrame::DEBUG;
    return undef;
  }

  my $url = 'http://' . $request->hostname . $request->uri;

  my $uri = URI->new( $url );
  if ($uri) {
    $uri->path( $request->uri() );
    $uri->host( $request->hostname() );
    $uri->scheme( 'http' );
  } else {
    warn("server could not create URI object") if $OpenFrame::DEBUG;
    return SERVER_ERROR;
  }

  ##
  ## abstract the request
  ##
  my $ar = Apache::Request->new( $request );

  my %args;
  my $args = { map { ($_, $ar->param($_)) } $ar->param() };
  $args{$_->name} = $_->fh foreach $ar->upload;

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
							arguments   => $args,
							cookies     => $cookietin,
						       );

  if (!$abstractRequest) {
    warn("could not create abstract request object") if $OpenFrame::DEBUG;
    return undef;

  } else {

    my $response = OpenFrame::Server->action( $abstractRequest );

    if (blessed( $response ) && $response->isa( 'OpenFrame::AbstractResponse' )) {
      if ($response->code() eq ofOK) {
	## first prepare the cookie

	my $abcookies = $response->cookies();
	foreach my $biscuit ($abcookies->getCookies()) {
	  my $nom    = $biscuit->getName();
	  my $val    = $biscuit->getValue();
	  my $cookie = Apache::Cookie->new(
					   Apache->request,
					   -name  => $nom,
					   -value => $val,
					  );

	  Apache->request()->header_out(
					"Set-Cookie" => $cookie->as_string
				       );
	}


	warn("[apache] ok") if $OpenFrame::DEBUG;
	$request->no_cache(1);
	$request->send_http_header( $response->mimetype() || 'text/html' );
	$request->print( $response->message() );

	return OK;
      } elsif ($response->code() eq ofDECLINED) {
	warn("[apache] declined") if $OpenFrame::DEBUG;
	return DECLINED;
      } elsif ($response->code() eq ofREDIRECT) {
	warn("[apache] redirect") if $OpenFrame::DEBUG;
	Apache->request()->header_out(
				      "Location" => $response->message()
				     );
	return REDIRECT;
      } elsif ($response->code() eq ofERROR) {
	warn("[apache] server error") if $OpenFrame::DEBUG;
	warn($response->message()) if $OpenFrame::DEBUG;
	return SERVER_ERROR;
      } else {
	warn("[apache] unrecognized response");
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

I<OpenFrame::Server::Apache> is an Apache extension.  It is
responsible for creating an I<OpenFrame::AbstractRequest> object and
passing it back to the main server class.  It also delivers the
I<OpenFrame::AbstractResponse> object to the client.

Note that any file upload objects are in the arguments of the
AbstractRequest and their value is a filehandle pointing to the
object.

=head1 DEPENDENCIES

=over 4

=item Apache

=item OpenFrame::AbstractRequest

=back

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 BUGS

None known

=cut
