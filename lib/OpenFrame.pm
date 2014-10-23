package OpenFrame;

use strict;
use warnings::register;

our $VERSION = '3.00';

%OpenFrame::DEBUG = (
		     ALL => 0,
		    );

use Pipeline;
use base qw ( Pipeline );

sub init {
  my $self = shift;
  $self->SUPER::init();
}

sub debug_level {
  my $self = shift;

  ## is this a set, a get, or what?
  if (@_ == 0) {
    ## this is a get of ALL
    return $OpenFrame::DEBUG{ ALL };
  } elsif (@_ == 1) {
    ## this could either be a set of ALL, or a request for an individual package's
    ## debug value.
    if ($_[0] =~ /\D/) {
      ## we have non-digit characters, we are getting the value for a specific
      ## package
      return $OpenFrame::DEBUG{ $_[0] };
    } else {
      ## these are digits, we are setting ALL
      $OpenFrame::DEBUG{ ALL } = $_[0]
    }	    
  } elsif (@_ == 2) {
    $OpenFrame::DEBUG{ shift @_ } = shift @_ ;
  } else {
    die "invalid number of parameters to &OpenFrame::debug_level";
  }
}


1;

=head1 NAME

OpenFrame - a framework for network enabled applications

=head1 SYNOPSIS

  use OpenFrame;

=head1 DESCRIPTION

OpenFrame is a framework for network services serving to multiple
media channels - for instance, the web, WAP, and digital television.
It is built around the Pipeline API, and provides extra abstraction to
make delivery of a single application to multiple channels easier.

=head1 GLOBAL VARIABLES

The most important thing that this module does is provide a wrapper
around OpenFrame specific debug information - for example, the
information provided by OpenFrame segments.

This variable is a hash called %DEBUG in the OpenFrame package.  If
you set the ALL key to a true value, then debugging information about
all segments will be printed.  If you want to resolve your debugging
output to a single module, then set a key that matches the segments
name to a true value.  For example, setting
$OpenFrame::DEBUG{'OpenFrame::Segment::HTTP::Request'} to 1 would mean
that all the debug messages from the HTTP::Request segment would get
printed.

=head1 SETTING UP YOUR SERVER

This will briefly explain how to set up a stand-alone OpenFrame
server. It uses the code listing below.

The first few lines (01-08) simply load all the modules that are
needed to setup the various constituent parts of an OpenFrame server.
Lines 9 creates an HTTP daemon listening on port 8080 for requests, in
the case that the server cannot be created line 10 provides error
reporting to the screen.

The first real piece of OpenFrame code is found at line 14, where we
create a Pipeline object, followed quickly by lines 16, 17 and 18
which create a couple of pipeline segments that will be added to the
pipeline at line 21. Lines 24 and 26 create a loop to listen for and
accept connections, and fetch HTTP requests from those connections as
and when it is needed.

At line 28 we create a Pipeline::Store::Simple object, which will act
as our data container for the information flowing down the
pipeline. We add the request to the store and the store to the
pipeline at line 31, and then call the dispatch() method on the
pipeline at line 34. This sets the OpenFrame side of things going. At
line 37 we ask the pipeline for the store and the store for an
HTTP::Response object, and then send it back to the client at line 40.

The real work of OpenFrame is in the segments that are created, and
the order in which they are inserted into the Pipeline. With this in
mind, you know everything there is to know about OpenFrame.

=head1 CODE LISTING

  01: use strict;
  02: use warnings;
  03:
  04: use Pipeline;
  05: use HTTP::Daemon;
  06: use OpenFrame::Segment::HTTP::Request;
  07: use OpenFrame::Segment::ContentLoader;
  08:
  09: my $d = HTTP::Daemon->new( LocalPort => '8080', Reuse => 1);
  10: die $! unless $d;
  11:
  12: print "server running at http://localhost:8080/\n";
  13:
  14: my $pipeline = Pipeline->new();
  15:
  16: my $hr = OpenFrame::Segment::HTTP::Request->new();
  17: my $cl = OpenFrame::Segment::ContentLoader->new()
  18:                                        ->directory("./webpages");
  19:
  20:
  21: $pipeline->add_segment( $hr, $cl );
  22:
  23:
  24: while(my $c = $d->accept()) {
  25:
  26:   while(my $r = $c->get_request) {
  27:
  28:     my $store = Pipeline::Store::Simple->new();
  29:
  30:
  31:     $pipeline->store( $store->set( $r ) );
  32:
  33:
  34:     $pipeline->dispatch();
  35:
  36:
  37:     my $response = $pipeline->store->get('HTTP::Response');
  38:
  39:
  40:     $c->send_response( $response );
  41:   }
  42: }


=head1 SEE ALSO

perl(1) Pipeline(3) OpenFrame::Config(3)

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=cut


1;
