package OpenFrame::AbstractCookie;
use strict;

use Scalar::Util qw ( blessed );

our $VERSION = '1.01';

sub new {
  my $class = shift;

  ## this is the object
  my $self  = {
	       cookies => {},
	      };

  bless $self, $class;
}


sub addCookie {
  my $self = shift;
  my $args = { @_ };

  my $cookie = {};

  if (!($args->{Name} && $args->{Value})) {
    if ($args->{Cookie} && blessed( $args->{Cookie} ) && $args->{Cookie}->isa( 'OpenFrame::AbstractCookie::CookieElement' )) {
      $self->{cookies}->{$args->{Cookie}->getName()} = $args->{Cookie};
      return 1;
     } else {
       warn("usage: addCookie( Cookie => \$cookie )");
       return undef;
     }
  } else {
    my $cookie = OpenFrame::AbstractCookie::CookieElement->new(
							       Name  => $args->{Name},
							       Value => $args->{Value},
							      );
    if ($cookie) {
      $self->{cookies}->{$cookie->getName()} = $cookie;
    }
    return 1;
  }
}


##
## gets a cookie from the collection of cookies
##
sub getCookie {
  my $self = shift;
  my $name = shift;

  return $self->{cookies}->{$name};
}

sub getCookies {
  my $self = shift;
  return values %{$self->{cookies}};
}

##
## deletes a cookie from the collection of cookies
##
sub delCookie {
  my $self = shift;
  my $name = shift;

  delete $self->{cookies}->{$name};
}


package OpenFrame::AbstractCookie::CookieElement;

use strict;

sub new {
  my $class = shift;
  my $args  = { @_ };

  my $self = {};

  bless $self, $class;

  foreach my $arg (keys %$args) {
    my $method = 'set' . ucfirst($arg);
    my $sub = $self->can( $method );
    if ( $sub ) {
      $sub->($self, $args->{$arg});
    } else {
      warn("usage __PACAKGE__->new( Name => 'CookieName', Value => 'CookieValue' )");
      return undef;
    }
  }

  return $self;
}

sub setName {
  my $self = shift;
  $self->{Name} = shift;
}

sub setValue {
  my $self = shift;
  $self->{Value} = shift;
}

sub getName {
  return $_[0]->{Name};
}

sub getValue {
  return $_[0]->{Value};
}

1;

__END__

=head1 NAME

OpenFrame::AbstractCookie - An abstract cookie class

=head1 SYNOPSIS

  my $cookietin = OpenFrame::AbstractCookie->new();
  my $c = OpenFrame::AbstractCookie::CookieElement->new(
	      Name  => 'animal',
	      Value => 'parrot',
  );
  $cookietin->addCookie(Cookie => $c);
  my $c2 = $cookietin->getCookie("colour");
  my $colour = $c2->getValue();
  $cookietin->deleteCookie("colour");

=head1 DESCRIPTION

C<OpenFrame::AbstractCookie> represents cookies inside
OpenFrame. Cookies in OpenFrame represent some kind of storage option
on the requesting side.

Cookies are a general mechanism which server side connections can use
to both store and retrieve information on the client side of the
connection. The addition of a simple, persistent, client-side state
significantly extends the capabilities of Web-based client/server
applications. C<OpenFrame::AbstractCookie> is an abstract cookie class
for OpenFrame which can represent cookies no matter how they really
come to exist outside OpenFrame (such as CGI or Apache cookie
objects).

=head1 METHODS

=head2 new()

The new() method creates a new C<OpenFrame::AbstractCookie>
object. These can hold multiple cookies (although they must have
unique names) inside the cookie tin.

  my $cookietin = OpenFrame::AbstractCookie->new();

=head2 addCookie()

The addCookie() method adds a
C<OpenFrame::AbstractCookie::CookieElement> to the cookie tin.

  my $c = OpenFrame::AbstractCookie::CookieElement->new(
	      Name  => 'animal',
	      Value => 'parrot',
  );
  $cookietin->addCookie(Cookie => $c);

=head2 getCookie()

The getCookie() method returns a cookie element from the cookie tin
given its name.

  my $c2 = $cookietin->getCookie("colour");

=head2 deleteCookie()

The deleteCookie() method removes a cookie element from the cookie tin
given its name.

  $cookietin->deleteCookie("colour");

=head2 getCookies()

The getCookie() method returns a list of all the cookies in the cookie
tin.

  my @cookies = $cookietin->getCookies();
  foreach my $cookie (@cookies) {
    print $cookie->getName() . ' = ' . $cookie->getValue() . "\n"
  }

=head1 C<OpenFrame::AbstractCookie::CookieElement>

The C<OpenFrame::AbstractCookie::CookieElement> objects represent
individual cookies inside of the C<OpenFrame::AbstractCookie> object.

The following methods can be called on them:

=head2 new()

The new() method creates a new cookie ready to be inserted into a
C<OpenFrame::AbstractCookie> object using that object's addCookie()
method:

  my $c = OpenFrame::AbstractCookie::CookieElement->new(
	      Name  => 'animal',
	      Value => 'parrot',
  );

=head2 getName()

The getName() method returns the name of the cookie.

  my $name = $c->getName();

=head2 getValue()

The getValue() method returns the value of the cookie.

  my $value = $c->getValue();

=head2 setValue()

The setValue() method sets the value of an existing cookie.

  $c->setValue("green");

=head1 AUTHOR

James Duncan <jduncan@fotango.com>

=cut
