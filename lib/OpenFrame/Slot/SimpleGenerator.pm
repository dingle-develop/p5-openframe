package OpenFrame::Slot::SimpleGenerator;

use strict;
use Storable qw(dclone);
use OpenFrame::Config;
use OpenFrame::Response;
use OpenFrame::Constants;

sub what {
  return ['OpenFrame::Session', 'OpenFrame::Request', 'OpenFrame::Cookietin'];
}

sub action {
  my $class     = shift;
  my $config    = shift;
  my $session   = shift;
  my $request   = shift;
  my $cookietin = shift;

  my $sessioncopy = dclone($session);

  my $response = OpenFrame::Response->new();
  $response->message($sessioncopy);
  $response->code(ofOK);
  $response->mimetype('openframe/session');
  $response->cookies($cookietin);

  return $response;
}

1;

=head1 NAME

OpenFrame::Slot::SimpleGenerator - Generator that returns the session

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::SimpleGenerator',
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::SimpleGenerator> is an OpenFrame slot that acts
much like C<OpenFrame::Slot::Generator> except it does not process a
template but instead returns the OpenFrame session. It is very handy
for testing purposes.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.




