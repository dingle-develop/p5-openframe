package OpenFrame::Slot;

##
## OpenFrame::Slot - abstract class for layers
##

use strict;
use warnings::register;

use SOAP::Lite;
use Data::Dumper;
use OpenFrame::Constants;
use OpenFrame::AbstractResponse;

our $VERSION = (split(/ /, q{$Id: Slot.pm,v 1.13 2001/11/12 13:57:04 james Exp $ }))[2];
sub what ();

sub action {
  my $class = shift;
  my $absrq = shift;
  my $slots = shift;

  if (!ref($slots)) {
    $slots = [ $slots ];
  }

  my $varstore = OpenFrame::SlotStore->new();

  $varstore->store( $absrq );

  foreach my $slot (@$slots) {
    next if (!$slot);

    ##
    ## dispatch mechanisms (local vs. SOAP)
    ##
    if ($slot->{dispatch} eq 'Local') {
      warnings::warn("[slot] $slot->{name} being dispatched locally") if (warnings::enabled || $OpenFrame::DEBUG);

      my $result = $varstore->store( $class->dispatchLocally( $slot, $varstore ) );
      if (scalar @$result) {
	push @$slots, map { { name => $_, dispatch => $slot->{dispatch}, config => $slot->{config} } } @$result;
      }

    } elsif ($slot->{dispatch} eq 'SOAP') {
      warnings::warn("[slot] $slot->{name} being dispatched via soap") if (warnings::enabled || $OpenFrame::DEBUG);

      my $result = $varstore->store( $class->dispatchViaSOAP( $slot, $varstore ) );
      if (scalar @$result) {
	push @$slots, map { { name => $_, dispatch => $slot->{dispatch}, config => {%{$slot->{config}}} } } @$result;
      }

   } else {
      warnings::warn("[slot] unknown slot dispatch mechanism") if (warnings::enabled || $OpenFrame::DEBUG);
      next;
    }


    if ($varstore->lookup( 'OpenFrame::AbstractResponse')) {
      my $response = $varstore->lookup( 'OpenFrame::AbstractResponse' );
      unless ($response->code() eq ofOK || $response->code() eq ofERROR) {
	return $response;
      } else {
	next;
      }
    }

  }

  if ($varstore->lookup( 'OpenFrame::AbstractResponse' )) {
    return $varstore->lookup('OpenFrame::AbstractResponse');
  } else {
    return OpenFrame::AbstractResponse->new( code => ofERROR );
  }
}

sub dispatchLocally {
  my $class    = shift;
  my $slot     = shift;
  my $varstore = shift;

  my $slotclass = $slot->{name};

  eval "use $slotclass";
  if ($@) {
    warnings::warn($@);
    return undef;
  }


  return $slotclass->action( $slot->{config}, map { $varstore->lookup( $_ ) } @{$slotclass->what} );
}

sub dispatchViaSOAP {
  my $class    = shift;
  my $slot     = shift;
  my $varstore = shift;

  my $soapslot;
  if ($slot->{proxy} && $slot->{uri}) {
    my $uri   = $slot->{uri};
    my $proxy = $slot->{proxy};

    $soapslot = new SOAP::Lite->uri( $uri )->proxy( $proxy );

  } elsif ($slot->{service}) {
    my $service = $slot->{service};
    $soapslot = SOAP::Lite->service( $service );
  }

  my $args = $soapslot->what()->result();

  my @args = map { $varstore->lookup( $_ ) } @$args;

  my $result = $soapslot->action( $slot->{config}, @args )->result();

  if ($soapslot->fault()) {
    warnings::warn("error in soap dispatch " . $soapslot->faultstring()) if (warnings::enabled() && $OpenFrame::DEBUG);
  } else {
    return $result;
  }
}


package OpenFrame::SlotStore;

use strict;
use warnings::register;
use Scalar::Util qw ( blessed );

sub new {
  my $class = shift;
  my $self  = {};
  $self->{STORE} = {};
  bless $self, $class;
}

sub store {
  my $self = shift;

  my $moreslots = [];
  foreach my $this (@_) {
    if (defined($this) && blessed($this)) {
      $self->{STORE}->{ref($this)} = $this;
    } elsif (defined($this) && $this !~ /^\d+$/) {
      push @$moreslots, $this;
    }
  }

  return $moreslots;
}

sub lookup {
  return $_[0]->{STORE}->{$_[1]};
}

1;


