package OpenFrame::Cookietin;
use strict;

our $VERSION = '1.02';

=head1 NAME

OpenFrame::Cookietin - An abstract cookie class

=head1 SYNOPSIS

  use OpenFrame;
  my $cookietin = OpenFrame::Cookietin->new();
  $cookietin->set("animal" => "parrot");
  my $colour = $cookietin->get("colour");
  $cookietin->delete("colour");
  my %cookies = $cookietin->get_all();

=head1 DESCRIPTION

C<OpenFrame::Cookietin> represents cookies inside
OpenFrame. Cookies in OpenFrame represent some kind of storage option
on the requesting side.

Cookies are a general mechanism which server side connections can use
to both store and retrieve information on the client side of the
connection. The addition of a simple, persistent, client-side state
significantly extends the capabilities of Web-based client/server
applications. C<OpenFrame::Cookietin> is an abstract cookie class
for OpenFrame which can represent cookies no matter how they really
come to exist outside OpenFrame (such as CGI or Apache cookie
objects).

=head1 METHODS

=head2 new()

The new() method creates a new C<OpenFrame::Cookietin>
object. These can hold multiple cookies (although they must have
unique names) inside the cookie tin.

  my $cookietin = OpenFrame::Cookietin->new();

=cut

sub new {
  my $class = shift;

  my $self  = { cookies => {} };
  bless $self, $class;
}


=head2 set()

The set() method adds an entry to the cookie tin:

  $cookietin->set("animal" => "parrot");

=cut

sub set {
  my $self  = shift;
  my $name  = shift;
  my $value = shift;

  $self->{cookies}->{$name} = $value;
}


=head2 get()

The get() method returns a cookie value from the cookie tin
given its name:

  my $colour = $cookietin->get("colour");

=cut

sub get {
  my $self = shift;
  my $name = shift;

  return $self->{cookies}->{$name};
}


=head2 delete()

The delete() method removes a cookie element from the cookie tin
given its name:

  $cookietin->delete("colour");

=cut

sub delete {
  my $self = shift;
  my $name = shift;

  delete $self->{cookies}->{$name};
}


=head2 get_all()

The get_all() method returns a hash of all the cookies in the cookie
tin:

  my %cookies = $cookietin->get_all();

=cut

sub get_all {
  my $self = shift;
  return %{$self->{cookies}};
}

1;

=head1 AUTHOR

James Duncan <jduncan@fotango.com>,
Leon Brocard <leon@fotango.com>

=cut
