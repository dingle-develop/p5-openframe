package OpenFrame::Slot::Images;

use strict;

use File::MMagic;
use File::Spec;
use FileHandle;
use OpenFrame::Slot;
use OpenFrame::Response;
use OpenFrame::Constants;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::Request'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $absrq = shift;
  my $uri = $absrq->uri();

  warn("[slot:images] checking to make sure we are processing images") if $Openframe::DEBUG;

  my $file = $uri->path();

  my($volume,$directories,$splitfile) = File::Spec->splitpath($file);
  if (not $splitfile) {
    warn("[slot:images] file $file directory, was not handled as an image") if $OpenFrame::DEBUG;
    return;
  }

  if ($config->{directory}) {
    $file = File::Spec->catfile($config->{directory}, $file);
  }

  if (-e $file && -r _) {
    my $mm = File::MMagic->new();
    my $type = $mm->checktype_filename($file);

    warn("[slot:images] file $file has type $type") if $OpenFrame::DEBUG;

    if ($type =~ /^image/) {
      warn("[slot:images] file $file is being handled as an image") if $OpenFrame::DEBUG;

      my $response = OpenFrame::Response->new();
      $response->code(ofOK);
      $response->mimetype($type);
      my $fh = FileHandle->new("<$file");
      my $message;
      if ($fh) {
	local $/ = undef;
	$message = <$fh>;
	$fh->close;
      }
      $response->message($message);
      return $response;
    }
  }
  warn("[slot:images] file $file was not handled as an image") if $OpenFrame::DEBUG;

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
