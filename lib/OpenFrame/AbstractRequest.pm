package OpenFrame::AbstractRequest;

use strict;

use URI;
use Class::MethodMaker
           new_with_init => 'new',
           new_hash_init => 'hash_init',
           get_set       => [ qw/uri originator descriptive arguments cookies/ ];

use OpenFrame::AbstractCookie;

our $VERSION = 1.00;

sub init {
  my($self, %params) = @_;

  if ($params{uri}) {
    die "uri not URI object" if ref($params{uri}) !~ /^URI/;
  } else {
    die "no uri passed!";
  }

  $params{originator} ||= 'GenericServer';
  $params{descriptive} ||= 'web';
  $params{arguments} ||= {};
  $params{cookies} ||= OpenFrame::AbstractCookie->new();

  hash_init($self, %params);
}


__END__

=head1 NAME

OpenFrame::AbstractRequest - An abstract request class

=head1 SYNOPSIS

  use OpenFrame::AbstractRequest;
  use OpenFrame::AbstractCookie;
  my $uri = URI->new("http://localhost/");
  my $r = OpenFrame::AbstractRequest->new(uri => $uri,
	originator => 'http://www.example.com/',
	descriptive => 'web',
	argumentss => { colour => 'red' },
	cookies => OpenFrame::AbstractCookie->new());
  print "URI: " . $r->uri();
  print "Originator: " . $r->originator();
  print "Descriptive: " . $r->descriptive();
  my $args = $r->arguments();
  my $cookies = $r->cookies();

=head1 DESCRIPTION

C<OpenFrame::AbstractRequest> represents requests inside
OpenFrame. Requests represent some kind of request for information
given a URI.

This module abstracts the way clients can request data from
OpenFrame. For example C<OpenFrame::Server::Apache> converts
Apache::Request GET and POST requests into an
C<OpenFrame::AbstractRequest>, which is then used through OpenFrame.

=head1 METHODS

=head2 new()

The new() method creates a new C<OpenFrame::AbstractRequest> object. It
takes a variety of parameters, of which only the "uri" parameter is
mandatory.

The parameters are:

=over 4

=item  uri

The location this request is for. This must be a URI object.

=item originator

A string describing the originator of the request. Defaults to
"GenericServer".

=item descriptive

A string describing the type of the request. Defaults to "web".

=item arguments

A hash reference which are the arguments passed along with the
request.

=item cookies

An C<OpenFrame::AbstractCookie> object which contains any cookies
passed with the request.

=back

  my $uri = URI->new("http://localhost/");
  my $r = OpenFrame::AbstractRequest->new(uri => $uri,
	originator => 'secret agent',
	descriptive => 'web',
	arguments => { colour => 'red' },
	cookies => OpenFrame::AbstractCookie->new());

=head2 uri()

This method gets and sets the URI.

  print "URI: " . $r->uri();
  $r->uri(URI->new("http://foo.com/"));

=head2 originator()

This method gets and sets the originator string.

  print "Originator: " . $r->originator();
  $r->setOriginator("me");

=head2 descriptive()

This method gets and sets the descriptive string.

  print "Descriptive: " . $r->descriptive();
  $r->descriptive("smtp");

=head2 cookies()

This method gets and sets the C<OpenFrame::AbstractCookie> object
associated with this request.

  my $cookietin = $r->cookies();
  $r->cookies($cookietin);

=head2 arguments()

This method gets and sets the argument hash reference associated with
this request.

  my $args = $r->arguments();
  $r->arguments({colour => "blue"});

=head1 AUTHOR

James Duncan <jduncan@fotango.com>

=cut

1;
