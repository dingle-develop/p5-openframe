package OpenFrame::SlotStore;

use strict;
use OpenFrame::Constants qw( :debug );
use Scalar::Util qw ( blessed );

my  $RESPONSE = 'OpenFrame::Response';
our $DEBUG   = ($OpenFrame::DEBUG || 0) & ofDEBUG_STORE;
*warn = \&OpenFrame::warn;


sub new {
  my $class = shift;

 $DEBUG = ($OpenFrame::DEBUG || 0) & ofDEBUG_STORE;

  my $self  = {
      STORE    => { },
  };
  bless $self, $class;
  return $self;
}


sub get {
  my($self, $key) = @_;
  return $self if ref($self) eq $key;
  return $self->{STORE}->{$key};
}


sub set {
  my $self = shift;
  &warn("storing @_") if $DEBUG;

  my $moreslots = [];
  foreach my $this (@_) {
    if (defined($this) && blessed($this)) {
      $self->{STORE}->{ref($this)} = $this;
    } 
    elsif (defined($this) && $this !~ /^(\d+|\d+\.\d+)$/) {
      push @$moreslots, $this;
    }
  }

  return $moreslots;
}


1;


=head1 NAME

OpenFrame::SlotStore - general storage for slot data

=head1 SYNOPSIS

    use OpenFrame::SlotStore;

    my $store = OpenFrame::SlotStore->new();

    $store->set($something);

    $thing = $store->get('Some::Thing::Class');

=head1 DESCRIPTION

This module implements a general storage faciity which keeps 
track of the objects returned by OpenFrame slots.

=head1 METHODS

=head2 get()

The C<get()> method takes a class name as a string, and returns an
object of that class if it exists within the store or undef if not.

=head2 set()

The C<set()> method takes one parameter, any object.  This object is
stored under its class name and is available for use from any other
slot.  If an object of a class that is already stored is placed in the
slot store the old object is overwritten.

=head2 response()

The C<set()> method makes special note of any object stored which is
an object of the OpenFrame::Response class.  This can then be
retrieved via the C<response()> method.  This is implemented as an
optimisation for the OpenFrame::Slot class which uses this method to
determine when a slot has generated a response which requires the
remaining slot list to be short-circuited.

=head2 NOTES

The slot store also keeps a copy of itself, so if you make a request
for OpenFrame::SlotStore in your paramter list returned from C<what()>
then you can get access to everything in the store.

=head1 AUTHORS

James A. Duncan <jduncan@fotango.com> with minor changes from Andy
Wardley <abw@kfs.org>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.


