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

use OpenFrame;
use OpenFrame::Server;
use OpenFrame::Constants;
use OpenFrame::Cookietin;
use OpenFrame::Request;
use OpenFrame::Response;

our $VERSION = 2.12;

Apache::add_version_component("OpenFrame/" . $OpenFrame::VERSION);


sub handler {
  my $request = shift;

  ##
  ## make sure we have a valid request
  ##
  unless (blessed( $request)) {
    warn("invalid call to handler") if $OpenFrame::DEBUG;
    return undef;
  }

  my $url = 'http://' . $request->hostname . ':' . $request->get_server_port . $request->uri;

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
  my $args = {
              map {
                   my $return;
                   my @results = $ar->param($_);
                   if (scalar(@results) > 1) {
                     $return = [@results];
                   } else {
                     $return = $results[0];
                   }
                   ($_, $return)
                  } $ar->param()
            };



  foreach my $upload ( $ar->upload ) {
    $args->{ $upload->name } = $upload->fh;
  }

  my $cookietin  = OpenFrame::Cookietin->new();
  my %apcookies  = Apache::Cookie->fetch();

  foreach my $key (keys %apcookies) {
    $cookietin->set($apcookies{$key}->name(), $apcookies{$key}->value());
  }

  my $abstractRequest = OpenFrame::Request->new(
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

    if (blessed( $response ) && $response->isa( 'OpenFrame::Response' )) {
      if ($response->code() eq ofOK) {
	## first prepare the cookie

	my $abcookies = $response->cookies();
	my %cookies = $abcookies->get_all;

	foreach my $name (keys %cookies) {
	  my $cookie = Apache::Cookie->new(
					   Apache->request,
					   -name => $name,
					   -value => $cookies{$name},
					   -expires => '+1M',
					   -path    => '/',
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
        my $url = $response->message;
	warn("[apache] redirect to $url") if $OpenFrame::DEBUG;
	$request->header_out("Location" => $url);
        $request->status(REDIRECT);
	$request->send_http_header;
	return OK;
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

sub import {
  print STDERR "THIS MODULE HAS BEEN USE'd\n";
}
1;

__END__

=head1 NAME

OpenFrame::Server::Apache - Apache extension for OpenFrame

=head1 SYNOPSIS

This is a mod_perl extension, see the INSTALL guide for information on how to install it.

=head1 DESCRIPTION

I<OpenFrame::Server::Apache> is an Apache extension.  It is
responsible for creating an I<OpenFrame::Request> object and
passing it back to the main server class.  It also delivers the
I<OpenFrame::Response> object to the client.

Note that any file upload objects are in the arguments of the
Request and their value is a filehandle pointing to the
object.

=head1 DEPENDENCIES

=over 4

=item Apache

=item OpenFrame::Request

=back

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 BUGS

None known

=cut
