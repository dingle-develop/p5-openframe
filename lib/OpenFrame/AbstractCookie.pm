package OpenFrame::AbstractCookie;

##
## AbstractCookie class to get rid of apache calls inside sessions
##
##

use strict;
use warnings::register;

use Scalar::Util qw ( blessed );

our $VERSION = '1.00';

sub new {
  my $class = shift;

  ## this is the object
  my $self  = {
	       cookies => [],
	      };
  
  bless $self, $class;
}


##
## adds a cookie to the collection of cookies
##
sub addCookie {
  my $self = shift;
  my $args = { @_ };

  my $cookie = {};

  if (!($args->{Name} && $args->{Value})) {
    if ($args->{Cookie} && blessed( $args->{Cookie} ) && $args->{Cookie}->isa( 'OpenFrame::AbstractCookie::CookieElement' )) {
      push @{$self->{cookies}}, $args->{Cookie}
     }
  } else {
    my $cookie = OpenFrame::AbstractCookie::CookieElement->new(
							       Name  => $args->{Name},
							       Value => $args->{Value},
							      );
    if ($cookie) {
      push @{$self->{cookies}}, $cookie;
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
  
  my $idx  = $self->getCookieIndex( $name );
  if (defined( $idx )) {
    return $self->{cookies}->[$idx];
  } else {
    return "";
  }
}

sub getCookieIndex {
  my $self = shift;
  my $name = shift;
  my $idx  = 0;
  foreach my $cookie (@{$self->{cookies}}) {    
    if ($cookie->getName eq $name) {
      return $idx;
    }
    $idx++;
  }
}


sub getCookies {
  my $self = shift;
  return @{$self->{cookies}};
}

##
## deletes a cookie from the collection of cookies
##
sub delCookie {
  my $self = shift;
  my $name = shift;
  
  my $idx  = $self->getCookieIndex( $name );
  splice(@{$self->{cookies}}, $idx, 1);
}


package OpenFrame::AbstractCookie::CookieElement;

use strict;
use warnings::register;

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
      warnings::warn("usage __PACAKGE__->new( Name => 'CookieName', Value => 'CookieValue' )");
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

