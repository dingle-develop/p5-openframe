package OpenFrame::Slot;

use strict;

use SOAP::Lite;
use Data::Dumper;
use Scalar::Util qw ( blessed );
use OpenFrame::Constants;
use OpenFrame::Exception;
use OpenFrame::AbstractResponse;

our $VERSION = (split(/ /, q{$Id: Slot.pm,v 1.20 2001/11/19 15:41:36 leon Exp $ }))[2];
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
      warn("[slot] $slot->{name} being dispatched locally") if $OpenFrame::DEBUG;

      my $result = $varstore->store( $class->dispatchLocally( $slot, $varstore ) );
      if (scalar @$result) {
	push @$slots, map { { name => $_, dispatch => $slot->{dispatch}, config => $slot->{config} } } @$result;
      }

    } elsif ($slot->{dispatch} eq 'SOAP') {
      warn("[slot] $slot->{name} being dispatched via soap") if $OpenFrame::DEBUG;

      my $result = $varstore->store( $class->dispatchViaSOAP( $slot, $varstore ) );
      if (scalar @$result) {
	push @$slots, map { { name => $_, dispatch => $slot->{dispatch}, config => {%{$slot->{config}}} } } @$result;
      }

   } else {
      warn("[slot] unknown slot dispatch mechanism: $slot->{dispatch}") if $OpenFrame::DEBUG;
      next;
    }

    if (scalar( @OpenFrame::Exception::stack )) {
      $varstore->store( @OpenFrame::Exception::stack );
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
    warn("[slot] none of the slots returned a response") if $OpenFrame::DEBUG;
    my $r = OpenFrame::AbstractResponse->new();
    $r->message("None of the OpenFrame slots returned a response object");
    $r->mimetype("text/plain");
    $r->code(ofERROR);
    return $r;
  }
}

sub dispatchLocally {
  my $class    = shift;
  my $slot     = shift;
  my $varstore = shift;

  my $slotclass = $slot->{name};

  my $slotfile = $slotclass;
  $slotfile =~ s|::|/|g;
  $slotfile .= ".pm";

  if (not exists $INC{$slotfile}) {
    eval "use $slotclass";
    if ($@) {
      my $excp = OpenFrame::Exception::Perl->new( $@ );
      $excp->throw();
      return undef;
    }
  }

  my $args = $class->getSlotArgs( $varstore, $slotclass );
  if (defined($args)) {
    return $slotclass->action( $slot->{config}, @$args );
  } else {
    return undef;
  }
}

sub getSlotArgs {
  my $self = shift;
  my $varstore = shift;
  my $slotclass = shift;

  my @args;
  foreach my $arg (@{$slotclass->what()}) {
    my $argo = $varstore->lookup( $arg );
    if (defined( $argo )) {
      push @args, $argo;
    } else {
      my $excp = OpenFrame::Exception::Slot->new( "argtype $arg not available for $slotclass" );
      $excp->throw();
      return undef;
    }
  }
  return [@args];
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
    my $excp = OpenFrame::Exception::Perl->new( $soapslot->faultstring());
    $excp->throw();
  } else {
    return $result;
  }
}


package OpenFrame::SlotStore;

use strict;

use Scalar::Util qw ( blessed );

sub new {
  my $class = shift;
  my $self  = {};
  $self->{STORE} = {};
  bless $self, $class;
  $self->store( $self );
  return $self;
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

__END__

=head1 NAME

OpenFrame::Slot - Information about OpenFrame Slots

=head1 SYNOPSIS

  package OpenFrame::Slot::MyRequestNoter;

  use strict;

  use OpenFrame::Slot;
  use base qw ( OpenFrame::Slot );

  sub what {
    return ['OpenFrame::AbstractRequest'];
  }

  sub action {
    my $self = shift;
    my $conf = shift;
    my $req  = shift;

    warn("URL Requested is: " . $req->uri()->as_string());
  }

  1;

=head1 DESCRIPTION

OpenFrame Slot functionality is designed as a pipe where
transmogrification takes place.  An I<OpenFrame::AbstractRequest>
object is poured into the top, and when it comes out of the bottom it
should be an I<OpenFrame::AbstractResponse>, that contains all the
information that is needed by any server to deliver content to a
browser.  In between the top and the bottom of the pipe functionality
is executed in a serial fashion.  Futhermore, it is possible to alter
the slot pipeline at runtime, by returning a class name (string) from
a slot.  The class name given will be placed at the end of the slot
pipeline, and will inherit the configuration from the slot that
created placed it there.

=head1 WHAT'S IN A SLOT

Any slot should inherit from the I<OpenFrame::Slot> class.  This
provides the basic functionality that a slot needs to get going.
However, from any given slot there should be two methods that
programmers need to concern themselves with, I<what()> and
I<action()>.

=head2 what()

The I<what()> method returns an array reference containing the classes
that any given slot needs to function.  For instance, the packaged
class C<OpenFrame::Slot::Session> requires an
OpenFrame::AbstractRequest object in order to perform its action, and
therefore returns it inside an array when its I<what()> method is
called.  A slot can also place OpenFrame::SlotStore in its required
parameters list and then receive the entire slot store.

=head2 action()

The I<action()> method takes the parameters that you specify in the
I<what()> method as well as a the config that the slot is installed
with and does something with them.  If it returns an object then that
object gets kept for future use by other slots.  For example, the
I<OpenFrame::Slot::Session> class returns both an
I<OpenFrame::Session> object and a I<OpenFrame::AbstractCookie>
object, that are later used by other slots.  If the I<action()> method
returns a string, that string is interpreted as being another slot to
go on the end of the slot pipeline.  The action method can return
values as a single scalar, or as a list. In the case of a list of
Slots to be executed they go onto the pipeline in the same order as
the I<action()> method returns them.

=head1 THE SLOT STORE

The Slot Store is the storage area that the pipeline maintains to
provide data to the various slots as needed.  It has a couple of methods
that are useful to the programmer:

=head2 store()

The I<store()> method takes one parameter, any object.  This object is
stored under its class name and is available for use from any other slot.
If an object of a class that is already stored is placed in the slot store
the old object is overwritten.

=head2 lookup()

The I<lookup()> method takes a class name as a string, and returns an
object in the case that the slot store has something belonging to that
class inside.

=head2 NOTES

The slot store also keeps a copy of itself, so if you make a request for
OpenFrame::SlotStore in your paramter list returned from C<what()> then
you can get access to everything in the store.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
