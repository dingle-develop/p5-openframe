package OpenFrame::Slot::Debugger;

use strict;
use Data::Dumper;
use OpenFrame::Slot;
use OpenFrame::AbstractResponse;
use OpenFrame::Constants;

use base qw (OpenFrame::Slot);

sub what {
  return ['OpenFrame::AbstractRequest', 'OpenFrame::AbstractResponse',
          'OpenFrame::Session'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $request = shift;
  my $response = shift;
  my $session = shift;

  warn("[slot:debugger] run") if $OpenFrame::DEBUG;

  my $uri = $request->uri();

  my $sessioncopy;
  eval Data::Dumper->Dump([$session], ["sessioncopy"]);
  delete $sessioncopy->{debug};

  push @{$session->{debug}}, { request => $request,
			       response => $response,
			       session => $sessioncopy,
			       time => scalar(localtime),
			     };

}

1;

__END__

=head1 NAME

OpenFrame::Slot::Debugger - Debug OpenFrame applications

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::Debugger',
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::Debugger> is an OpenFrame slot that can add tracing
information to the current session so that the request, response, and
session for each stage. Look at the debug example for how to display
the information.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

