package OpenFrame::Slot;

##
## OpenFrame::Slot - abstract class for layers
##

use strict;
use warnings::register;

use SOAP::Lite;
use Data::Dumper;
#use Attribute::Abstract;
#use Attribute::Signature;
use OpenFrame::AbstractResponse;


our $VERSION = (split(/ /, q{$Id: Slot.pm,v 1.7 2001/11/02 17:02:31 james Exp $ }))[2];
sub what ();

sub action : {
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
      $varstore->store( $class->dispatchLocally( $slot, $varstore ) );
    } elsif ($slot->{dispatch} eq 'SOAP') {
      warnings::warn("[slot] $slot->{name} being dispatched via soap") if (warnings::enabled || $OpenFrame::DEBUG);
      $varstore->store( $class->dispatchViaSOAP( $slot, $varstore ) );
    } else {
      warnings::warn("[slot] unknown slot dispatch mechanism") if (warnings::enabled || $OpenFrame::DEBUG);
      next;
    }

    ## return if we see an AbstractResponse object
    if ($varstore->lookup( 'OpenFrame::AbstractResponse' )) {
      return $varstore->lookup('OpenFrame::AbstractResponse');
    } else {
      next;
    }
  }

  my $response = OpenFrame::AbstractResponse->new();
  $response->setMessageCode( ofERROR );

  return $response;
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


  return $slotclass->action( map { $varstore->lookup( $_ ) } @{$slotclass->what} );
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

  my $result = $soapslot->action( @args )->result();

  if ($soapslot->fault()) {
    warnings::warn("error in soap dispatch " . $soapslot->faultstring()) if (warnings::enabled() && $OpenFrame::DEBUG);
  } else {
    return $result;
  }
}


package OpenFrame::SlotStore;

sub new {
  my $class = shift;
  my $self  = {};
  $self->{STORE} = {};
  bless $self, $class;
}

sub store {
  my $self = shift;

  foreach my $this (@_) {
    if (defined($this)) {
      $self->{STORE}->{ref($this)} = $this;
    }
  }

}

sub lookup {
  return $_[0]->{STORE}->{$_[1]};
}

1;


