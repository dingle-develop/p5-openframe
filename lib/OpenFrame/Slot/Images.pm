package OpenFrame::Slot::Images;

use strict;

use Cache::MemoryCache;
use File::MMagic;
use File::Spec;
use IO::File;
use OpenFrame::Slot;
use OpenFrame::Response;
use OpenFrame::Constants qw( :all );
use base qw ( OpenFrame::Slot );

our $DEBUG  = ($OpenFrame::DEBUG || 0) & ofDEBUG_IMAGES;
*warn = \&OpenFrame::warn;

my $mm = File::MMagic->new();
my $cache = Cache::MemoryCache->new({
  'namespace' => 'mmagic',
  'default_expires_in' => 600,
});

sub what {
  return ['OpenFrame::Request'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $absrq = shift;
  my $uri = $absrq->uri();

  $DEBUG = ($OpenFrame::DEBUG || 0) & ofDEBUG_IMAGES;

  &warn("checking to make sure we are processing images") if $DEBUG;

  my $file = $uri->path();

  my($volume,$directories,$splitfile) = File::Spec->splitpath($file);
  if (not $splitfile) {
    &warn("file $file directory, was not handled as an image") if $DEBUG;
    return;
  }

  if ($config->{directory}) {
    $file = File::Spec->catfile($config->{directory}, $file);
  }

  if (-e $file && -r _) {

    my $type = $cache->get($file);

    if (not defined $type) {
      # cache miss
      $type = $mm->checktype_filename($file);
      $cache->set($file, $type);
      &warn("image cache miss for $file = $type") if $DEBUG;
    }

    &warn("file $file has type $type") if $DEBUG;

    if ($type =~ /^image/) {
      &warn("file $file is being handled as an image") if $DEBUG;

      my $response = OpenFrame::Response->new();
      $response->code(ofOK);
      $response->mimetype($type);
      my $fh = IO::File->new("<$file");
      my $message;
      if ($fh) {
	local $/ = undef;
	$message = <$fh>;
	$fh->close;
      }
      $response->message($message);
      my $time = (stat($file))[9];
      $response->last_modified($time);
      return $response;
    }
  }
  &warn("file $file was not handled as an image") if $DEBUG;

}

1;

__END__

=head1 NAME

OpenFrame::Slot::Images - Serve static image files

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::Images',
  config   => { directory => 'htdocs/' },
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::Images> is an OpenFrame slot that can handle static
images. It takes the path from the C<OpenFrame::Request> and
looks for image files starting from the value of the "directory"
configuration option. It returns an C<OpenFrame::AbstraceResponse>
containing the image file.

It will only serve the file if C<File::MMagic> reckons the file does
not have MIME type "text/html", and will set the proper MIME type for
the image.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
