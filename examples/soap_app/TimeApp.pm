package TimeApp;

use strict;
use lib '../../lib';
use OpenFrame::Application;
use OpenFrame::Request;
use base qw(OpenFrame::Application);

sub default {
  my $class = shift;
  my $session = shift;
  my $request = shift;
  my $config = shift;

  my $uri = $request->uri;

  my $message = "The current time via SOAP is: " .
    scalar(localtime) . "<br>\n";
  $message .= "URI was: " . $uri->path . "\n";

  $class->{message} = $message;
  return $message;
}

1;

__END__

=head1 NAME

TimeApp - Return the time

=head1 SYNOPSIS

=head1 DESCRIPTION

C<TimeApp> is a simple application which is used in this example as a
remote SOAP application.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

