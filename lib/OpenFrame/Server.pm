package OpenFrame::Server;

use strict;
use OpenFrame::Config;
use OpenFrame::Request;
use OpenFrame::Response;
use OpenFrame::Slot;

our $VERSION = 2.12;
our $SLOTCLASS = 'OpenFrame::Slot';

sub action {
  my $class = shift;
  my $req   = shift;

  my $response;

  my $config   = OpenFrame::Config->new();

  $OpenFrame::DEBUG = $config->getKey('DEBUG');

  # Go through the slots
  my $SLOTS    = $config->getKey('SLOTS');
  if ($SLOTS && ref($SLOTS) eq 'ARRAY') {
    $response = $SLOTCLASS->action($req, $SLOTS);
  }

  # Go through the postslots
  my $POST = $config->getKey('POSTSLOTS');
  if ($POST && ref($POST) eq 'ARRAY') {
    $SLOTCLASS->action($req,  $POST);
  }

  return $response;
}

1;



=head1 NAME

OpenFrame::Server - Class representing an OpenFrame installation

=head1 SYNOPSIS

  use OpenFrame::Server;
  OpenFrame::Server->action( $abstract_request )

=head1 DESCRIPTION

The I<OpenFrame::Server> class represents an installation of OpenFrame.  It takes
an I<OpenFrame::Request> object and starts the slot execution process (see
C<OpenFrame::Slot>.  Its method, I<action()> returns an Request object.

=head1 BUGS

Need to return a blank Request if nothing happens of any consequence.  That
in itself being consequential.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright 2001-2 Fotango Ltd
This module is released under the same terms as Perl.

=cut
