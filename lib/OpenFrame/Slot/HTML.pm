package OpenFrame::Slot::HTML;

use strict;

use Cache::MemoryCache;
use File::MMagic;
use File::Spec;
use IO::File;
use OpenFrame::Slot;
use OpenFrame::Response;
use OpenFrame::Constants;
use base qw ( OpenFrame::Slot );

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

  warn("[slot:html] checking to make sure we are processing html") if $OpenFrame::DEBUG;

  my $file = $uri->path();

  my($volume,$directories,$splitfile) = File::Spec->splitpath($file);
  if (not $splitfile) {
    $file .= File::Spec->catfile($file, "index.html");
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
      warn "** image cache miss for $file = $type\n" if $OpenFrame::DEBUG;
    }

    warn("[slot:html] file $file has type $type") if $OpenFrame::DEBUG;

    if ($type eq "text/html") {
      warn("[slot:html] file $file is being handled as HTML") if $OpenFrame::DEBUG;

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
      return $response;
    }
  }
  warn("[slot:html] file $file was not  handled as HTML") if $OpenFrame::DEBUG;

}

1;

__END__

=head1 NAME

OpenFrame::Slot::HTML - Serve static HTML files

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::HTML',
  config   => { directory => 'htdocs/' },
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::HTML> is an OpenFrame slot that can handle static
HTML files. It takes the path from the C<OpenFrame::Request>
and looks for HTML files starting from the value of the "directory"
configuration option. It returns an C<OpenFrame::AbstraceResponse>
containing the HTML file.

It defaults to "index.html" if the path is a directory.

It will only serve the file if C<File::MMagic> reckons the file has
MIME type "text/html".

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

