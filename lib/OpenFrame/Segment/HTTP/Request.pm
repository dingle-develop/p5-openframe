package OpenFrame::Segment::HTTP::Request;

use strict;
use warnings::register;

use CGI;

use Pipeline::Segment;
use OpenFrame::Object;
use OpenFrame::Cookies;
use OpenFrame::Request;
use OpenFrame::Segment::HTTP::Response;

use base qw ( Pipeline::Segment OpenFrame::Object );

sub init {
  my $self = shift;
  $self->respond( 1 );
  $self->SUPER::init( @_ );
}

sub respond {
  my $self = shift;
  my $respond = shift;
  if (defined( $respond )) {
    $self->{respond} = $respond;
    return $self;
  } else {
    return $self->{respond};
  }
}

sub dispatch {
  my $self  = shift;
  my $store = shift->store();
  my $httpr = $store->get('HTTP::Request');

  return undef unless $httpr;

  my ($ofr,$cookies) = $self->req2ofr( $httpr );

  if ($self->respond) {
    return ($ofr, $cookies, OpenFrame::Segment::HTTP::Response->new());
  } else {
    return ($ofr, $cookies);
  }
}

##
## turns an HTTP::Request object into an OpenFrame::Request object
##
sub req2ofr {
  my $self = shift;
  my $r    = shift;
  my $uri  = $r->uri();
  my $args = $self->req2args( $r );
  my $ctin = $self->req2ctin( $r );

  my $ofr  = OpenFrame::Request->new()
                               ->arguments( $args )
			       ->uri( $uri );

  return ($ofr,$ctin);
}

sub req2ctin {
  my $self = shift;
  my $r    = shift;
  my $ctin = OpenFrame::Cookies->new();

  if ($r->header('Cookie')) {
    foreach my $ctext (split(/; ?/, $r->header('Cookie'))) {
      my ($cname, $cvalue) = split /=/, $ctext;
      $ctin->set( $cname, $cvalue );
    }
  }

  return $ctin;
}

##
## shameless copied from acme's original
##
sub req2args {
  my $self = shift;
  my $r    = shift;
  my $args = {};

  my $method = $r->method;

  if ($method eq 'GET' || $method eq 'HEAD') {
    my $cgi = CGI->new($r->uri->equery);

    $args = {
	      map {
		   my $return;
		   my @results = $cgi->param($_);
		   if (scalar(@results) > 1) {
 		     $return = [@results];
		   } else {
		     $return = $results[0];
   		   }
		   ($_, $return)
		  } $cgi->param()
	    };

    $r->uri->query(undef);
  } elsif ($method eq 'POST') {
    my $content_type = $r->content_type;
    if (!$content_type || $content_type eq "application/x-www-form-urlencoded") {
      my $cgi = CGI->new($r->content);
      $args->{$_} = $cgi->param($_) foreach ($cgi->param());
      $r->uri->query(undef);
    } elsif ($content_type eq "multipart/form-data") {
      $args = parse_multipart_data($r);
    } else {
      warn "[server:http] invalid content type: $content_type";
    }
  } else {
    warn "[server::http] unsupported method: $method";
  }

  return $args;
}

1;

