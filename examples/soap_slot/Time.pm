package Time;

use strict;
use lib '../../lib';
use OpenFrame::Slot;
use OpenFrame::Request;
use OpenFrame::Response;
use OpenFrame::Constants;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::Request'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $request = shift;
  my $uri = $request->uri;

  my $message = "The current time via SOAP is: " .
    scalar(localtime) . "\n";
  $message .= "URI was: " . $uri->path . "\n";

  my $response = OpenFrame::Response->new();
  $response->code(ofOK);
  $response->mimetype("text/plain");
  $response->message($message);
  return $response;
}

1;

__END__

=head1 NAME

Time - Return the time

=head1 SYNOPSIS

=head1 DESCRIPTION

C<Time> is a simple slot which is used in this example as a remote
SOAP slot.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

