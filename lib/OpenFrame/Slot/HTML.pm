package OpenFrame::Slot::HTML;

use strict;
use warnings::register;

use File::MMagic;
use FileHandle;
use OpenFrame::Slot;
use OpenFrame::AbstractResponse;
use OpenFrame::Constants;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $class = shift;
  my $config = shift;
  my $absrq = shift;
  my $uri = $absrq->uri();

  warnings::warn("[slot:html] checking to make sure we are processing html") if (warnings::enabled || $OpenFrame::DEBUG);


  my $file = $uri->path();
  $file =~ s|^/||;

  if ($uri->path() =~ /\/$/) {
    $file .= "index.html";
  }

  if ($config->{directory}) {
    $file = $config->{directory} . $file;
  }

  if (-e $file && -r _) {
    my $mm = File::MMagic->new();
    my $type = $mm->checktype_filename($file);

    warnings::warn("[slot:html] file $file has type $type") if (warnings::enabled || $OpenFrame::DEBUG);

    if ($type eq "text/html") {
      warnings::warn("[slot:html] file $file is being handled as HTML") if (warnings::enabled || $OpenFrame::DEBUG);

      my $response = OpenFrame::AbstractResponse->new();
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
  warnings::warn("[slot:html] file $file was not  handled as HTML") if (warnings::enabled || $OpenFrame::DEBUG);

}

1;

__END__

=head1 NAME

OpenFrame::Slot::HTML - serve static HTML files

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::HTML',
  config   => { directory => 'htdocs/' },
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::HTML> is an OpenFrame slot that can handle static
HTML files. It takes the path from the C<OpenFrame::AbstractRequest>
and looks for HTML files starting from the value of the "directory"
configuration option. It returns an C<OpenFrame::AbstraceResponse>
containing the HTML file.

It defaults to "index.html" if the path is a directory.

It will only serve the file if C<File::MMagic> reckons the file has
MIME type "text/html".

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

