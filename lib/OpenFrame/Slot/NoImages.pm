package OpenFrame::Slot::NoImages;

use strict;
use File::MMagic;
use File::Spec;
use OpenFrame::Slot;
use OpenFrame::Constants;
use OpenFrame::Response;
use OpenFrame::Response;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::Request'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $absrq = shift;
  my $uri = $absrq->uri();

  warn("[slot:noimages] checking to make sure we are processing images") if $OpenFrame::DEBUG;

  my $file = $uri->path();

  my($volume,$directories,$splitfile) = File::Spec->splitpath($file);
  if (not $splitfile) {
    warn("[slot:noimages] file $file directory, was not handled as an image") if $OpenFrame::DEBUG;
    return;
  }

  if ($config->{directory}) {
    $file = File::Spec->catfile($config->{directory}, $file);
  }

  if (-e $file && -r _) {
    my $mm = File::MMagic->new();
    my $type = $mm->checktype_filename($file);

    warn("[slot:noimages] file $file has type $type") if $OpenFrame::DEBUG;

    if ($type =~ /^image/) {
      warn("[slot:noimages] DECLINING " . $uri->path()) if $OpenFrame::DEBUG;
      my $response = OpenFrame::Response->new();
      $response->code( ofDECLINED );
      $response->message( "not a request for an HTML page" );
      return $response;
    }
  }

  warn("[slot:noimages] file $file was not handled as an image") if $OpenFrame::DEBUG;
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
C<OpenFrame::Request> and returns a declining response if the
file is not a .html file.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
