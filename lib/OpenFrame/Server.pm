package OpenFrame::Server;

use strict;
use OpenFrame::Config;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;
use OpenFrame::Slot;

our $VERSION = (split(/ /, q{$Id: Server.pm,v 1.8 2001/12/03 14:20:00 leon Exp $ }))[2];


sub action {
  my $class = shift;
  my $req   = shift;

  my $response;

  my $config   = OpenFrame::Config->new();

  $OpenFrame::DEBUG = $config->getKey('DEBUG');

  # Go through the slots
  my $SLOTS    = $config->getKey('SLOTS');
  if ($SLOTS && ref($SLOTS) eq 'ARRAY') {
    $response = OpenFrame::Slot->action($req, $SLOTS);
  }

  # Go through the postslots
  my $POST = $config->getKey('POSTSLOTS');
  if ($POST && ref($POST) eq 'ARRAY') {
    OpenFrame::Slot->action($req,  $POST);
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
an I<OpenFrame::AbstractRequest> object and starts the slot execution process (see
C<OpenFrame::Slot>.  Its method, I<action()> returns an AbstractRequest object.

=head1 BUGS

Need to return a blank AbstractRequest if nothing happens of any consequence.  That
in itself being consequential.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright 2001 Fotango Ltd
This module is released under the same terms as Perl.

=cut
