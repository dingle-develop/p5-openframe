package OpenFrame::Slot;

use strict;

use SOAP::Lite;
use Data::Dumper;
use Scalar::Util qw ( blessed );
use OpenFrame::Constants;
use OpenFrame::Exception;
use OpenFrame::Response;
use OpenFrame::SlotStore;

our $VERSION = 2.00;
sub what ();

my $RESPONSE = 'OpenFrame::Response';
my $DISPATCH = {
    Local => \&dispatchLocally,
    SOAP  => \&dispatchViaSOAP,
};


sub action {
    my $class = shift;
    my $absrq = shift;
    my $slots = shift;
    my @cleanups;
    
    if (!ref($slots)) {
	$slots = [ $slots ];
    }

    my $varstore = OpenFrame::SlotStore->new();
    my ($slot, $dispatch, $dispatcher, $result, $response);

    $varstore->set( $absrq );

    #
    # dispatch regular slots
    #

    foreach $slot (@$slots) {
	next unless $slot;
	next unless $slot->{name}; # Patches bug, but what causes it?

	# determine dispatch type
	$dispatch = $slot->{ dispatch } || 'Local';

	warn("[slot] $slot->{name} dispatch: $dispatch") if $OpenFrame::DEBUG;
	
	# fetch associated dispatcher method
	unless ($dispatcher = $DISPATCH->{ $dispatch }) {
	    warn("[slot] unknown slot dispatch mechanism: $dispatch") 
		if $OpenFrame::DEBUG;
	    next;
	}

	# go forth and dispatch
	$result = $varstore->set($class->$dispatcher($slot, $varstore));

	# any results not gobbled off by the varstore are cleanup operations
	if (scalar @$result) {
	    push @cleanups, map { 
		{ 
		    name     => $_, 
		    dispatch => $dispatch, 
		    config   => $slot->{config} 
		} 
	    } @$result;
	}

	# look for any exceptions thrown
	if (scalar( @OpenFrame::Exception::stack )) {
	    $varstore->set( @OpenFrame::Exception::stack );
	}

	# look for a response generated which should short-circuit the 
	# rest of the regular dispatch slots
	last if ($response = $varstore->get($RESPONSE));
    }

    #
    # dispatch cleanup slots
    #

    while (@cleanups) {
	$slot = shift @cleanups;

	# determine dispatch type
	$dispatch = $slot->{ dispatch } || 'Local';

	warn("[slot] $slot->{name} cleanup dispatch: $dispatch") if $OpenFrame::DEBUG;
	
	# fetch associated dispatcher method
	unless ($dispatcher = $DISPATCH->{ $dispatch }) {
	    warn("[slot] unknown cleanup slot dispatch mechanism: $dispatch") 
		if $OpenFrame::DEBUG;
	    next;
	}

	# go forth and dispatch
	$result = $varstore->set($class->$dispatcher($slot, $varstore));

	# any results not gobbled off by the varstore are cleanup operations
	if (scalar @$result) {
	    push @cleanups, map { 
		{ 
		    name     => $_, 
		    dispatch => $dispatch, 
		    config   => $slot->{config} 
		} 
	    } @$result;
	}

	# look for any exceptions thrown
	if (scalar( @OpenFrame::Exception::stack )) {
	    $varstore->set( @OpenFrame::Exception::stack );
	}
    }

    unless ($response ||= $varstore->get($RESPONSE)) {
	warn("[slot] none of the slots returned a response") if $OpenFrame::DEBUG;
	$response = $RESPONSE->new(
	    message  => 'None of the OpenFrame slots returned a response object',
	    mimetype => 'text/plain',
	    code     => ofERROR );
    }

    return $response;
}


sub dispatchLocally {
  my $class    = shift;
  my $slot     = shift;
  my $varstore = shift;

  my $slotclass = $slot->{name};

  my $slotfile = $slotclass;
  $slotfile =~ s|::|/|g;
  $slotfile .= ".pm";

  {
    no strict 'refs';
    if (not exists $INC{$slotfile} || keys %{*{$slotclass .'::'}}) {
      eval "use $slotclass";
      if ($@) {
        my $excp = OpenFrame::Exception::Perl->new( $@ );
        $excp->throw();
        return undef;
      }
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
    my $argo = $varstore->get( $arg );
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
  if ($slot->{soap_proxy} && $slot->{soap_uri}) {
    my $uri   = $slot->{soap_uri} . $slot->{name};
    my $proxy = $slot->{soap_proxy};

    $soapslot = new SOAP::Lite->uri( $uri )->proxy( $proxy );

  } elsif ($slot->{service}) {
    my $service = $slot->{service};
    $soapslot = SOAP::Lite->service( $service );
  }

  my $args = $soapslot->what()->result();

  my @args = map { $varstore->get($_) } @$args;

  my $result = $soapslot->action(($slot->{config} || {}), @args);

  if ($result->fault()) {
    my $excp = OpenFrame::Exception::Perl->new($result->faultstring());
    $excp->throw();
  } else {
    return $result->result;
  }
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
    return ['OpenFrame::Request'];
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
transmogrification takes place.  An I<OpenFrame::Request>
object is poured into the top, and when it comes out of the bottom it
should be an I<OpenFrame::Response>, that contains all the
information that is needed by any server to deliver content to a
browser.  In between the top and the bottom of the pipe functionality
is executed in a serial fashion.  

A second pipeline known as the "cleanup pipeline" is used to schedule 
slots that should be run after the main slot pipeline has completed
(e.g. to perform post-processing cleanup operations).  This is initially
empty and may be filled by slots in the regular pipeline as they are
run.

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
OpenFrame::Request object in order to perform its action, and
therefore returns it inside an array when its I<what()> method is
called.  A slot can also place OpenFrame::SlotStore in its required
parameters list and then receive the entire slot store.

=head2 action()

The I<action()> method takes the parameters that you specify in the
I<what()> method as well as a the config that the slot is installed
with and does something with them.  If it returns an object then that
object gets kept for future use by other slots.  For example, the
I<OpenFrame::Slot::Session> class returns both an
I<OpenFrame::Session> object and a I<OpenFrame::Cookietin> object,
that are later used by other slots.  If the I<action()> method returns
a string, that string is interpreted as the name of another slot which
should be added to the end of the cleanup pipeline.

The action method can return values as a single scalar, or as a
list. In the case of a list of Slots to be executed they go onto the
cleanup pipeline in the same order as the I<action()> method returns
them.

If a slot returns an OpenFrame::Response object then the request is
deemed complete and the remaining slots in the main pipeline are 
bypassed.  At this point, any slots in the cleanup pipeline are then
run.

=head1 THE SLOT STORE

The Slot Store is the storage area that the pipeline maintains to
provide data to the various slots as needed.  This is implemented 
by the OpenFrame::SlotStore module.

=head1 NOTES

The slot store also keeps a copy of itself, so if you make a request for
OpenFrame::SlotStore in your paramter list returned from C<what()> then
you can get access to everything in the store.

=head1 AUTHORS

James A. Duncan <jduncan@fotango.com> and Andy Wardley <abw@kfs.org>.

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
