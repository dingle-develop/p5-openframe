package OpenFrame::Segment::HTTP::Response;

use strict;

#no strict 'subs';

use warnings::register;

use CGI::Cookie;
use HTTP::Status;
use HTTP::Headers;
use HTTP::Response;
use Pipeline::Segment;
use OpenFrame::Object;
use OpenFrame::Response;

use base qw ( Pipeline::Segment OpenFrame::Object );

our $VERSION = '3.01';

sub dispatch {
  my $self  = shift;
  my $store = shift->store();

  my $response;

  my $cookies = $store->get( 'OpenFrame::Cookies' );
  $response   = $store->get( 'OpenFrame::Response' );

  if (!$response) {
    ## time to make an error response
    $response = OpenFrame::Response->new();
    $response->code( ofERROR );
    $response->message(
		       q{
			 <h1>There was an error processing your request</h1>
			 <p>No segments produced an OpenFrame::Response object</p>
			}
		      );
    $self->error("no response available");
  }

  return $self->ofr2httpr( $response, $cookies );
}

##
## turns an openframe response to an http response
##
sub ofr2httpr {
  my $self = shift;
  my $ofr  = shift;
  my $cookies = shift;
  my $h;

  if ( defined( $cookies ) ) {
    my %cookies = $cookies->get_all();
    $h = HTTP::Headers->new();
    foreach my $name (keys %cookies) {
      my $cookie = $cookies{ $name };
      $h->header('Set-Cookie' => "$cookie");
    }
  }

  my $mesg = HTTP::Response->new(
				 $self->ofcode2status( $ofr ),
				 undef,
				 $h,
				 $ofr->message,
				);

  $mesg->content_type( $ofr->mimetype || "text/html" );

  return $mesg;
}

sub ofcode2status {
  my $self = shift;
  my $ofr  = shift;
  if ($ofr->code() eq ofOK) {
    return RC_OK;
  } elsif ($ofr->code() eq ofREDIRECT) {
    return RC_FOUND;
  } else {
    return RC_INTERNAL_SERVER_ERROR;
  }
}

1;










