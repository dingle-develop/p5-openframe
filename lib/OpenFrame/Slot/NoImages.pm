package OpenFrame::Slot::NoImages;

use strict;

use OpenFrame::Slot;
use OpenFrame::Constants;
use OpenFrame::AbstractResponse;
use OpenFrame::AbstractResponse;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $absrq = shift;
  my $uri = $absrq->uri();


  warn("[slot:noimages] checking to make sure we are processing images") if $OpenFrame::DEBUG;

  if ($uri->path() =~ /\/$/) {
    return;
  }

  if ($uri->path() !~ /\.html$/) {
    warn("[slot:noimages] DECLINING " . $uri->path()) if $OpenFrame::DEBUG;
    my $response = OpenFrame::AbstractResponse->new();
    $response->code( ofDECLINED );
    $response->message( "not a request for an HTML page" );
    return $response;
  } else {
    warn("[slot:noimages] accepting request for " . $uri->path()) if $OpenFrame::DEBUG;
  }
}

1;

__END__

=head1 NAME

OpenFrame::Slot::NoImages - Decline serving image files

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::NoImages',
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::NoImages> is an OpenFrame slot that declines
handling images. It takes the path from the
C<OpenFrame::AbstractRequest> and returns a declining response if the
file is not a .html file.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
