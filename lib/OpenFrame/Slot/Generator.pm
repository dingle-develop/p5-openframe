package OpenFrame::Slot::Generator;

use strict;

use Template;
use OpenFrame::Config;
use OpenFrame::Constants;
use OpenFrame::Response;

our $VERSION = 2.00;

my $tt;

sub what {
  return ['OpenFrame::Session', 'OpenFrame::Request', 'OpenFrame::Cookietin'];
}

sub action {
  my $class   = shift;
  my $config  = shift;
  my $session = shift;
  my $request = shift;
  my $cookie  = shift;
  my $uri = $request->uri;

  my $templatedir = $config->{presentation};
  my $cachedir    = $config->{presentationcache} || $config->{presentation} . "/compcache/";
  my $locale      = $session->{country} . $session->{language};

  warn("[slot::generator] template dir is $templatedir/$locale") if $OpenFrame::DEBUG;

  if (not defined $tt) {
    $tt = Template->new(
			{
			 INCLUDE_PATH => $templatedir . '/' . $locale,
			 POST_CHOMP   => 1,
			 RELATIVE     => 1,
			 COMPILE_EXT  => ".tt2",
			 COMPILE_DIR  => $cachedir,
			}
		       );
  }

  my $output;

  if (substr($uri->path, -1) eq '/') {
    warn("[slot::generator] no file, using index.html") if $OpenFrame::DEBUG;
    $request->uri( URI->new( $uri->canonical() . 'index.html' ) );
    $uri = $request->uri;
  }

  if ($uri->path() =~ /\.html$/) {
    unless ($tt->process(substr($uri->path(), 1), $session, \$output)) {
      warn("[slot::generator] could not process template (" . $tt->error . ")") if $OpenFrame::DEBUG;
    }
    delete $session->{template}; # delete spurious entry by TT

    my $response = OpenFrame::Response->new();
    $response->message( $output );
    $response->code( ofOK );
    $response->cookies( $cookie );

    return $response;
  }
  warn("[slot:generator] file was not handled as template") if $OpenFrame::DEBUG;

}

1;

__END__

=head1 NAME

OpenFrame::Slot::Generator - Generate HTML using TT

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::Generator',
  config   => { presentation => 'htdocs/' },
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::Generator> is an OpenFrame slot that can generate
HTML using the Template Toolkit. It takes the path from the
C<OpenFrame::Request> and looks for templates starting from
the value of the "presentation" configuration option. It returns an
C<OpenFrame::AbstraceResponse> containing the generated output.

It will only serve the file has extension "html" and will pass the
entire session to the template as the "session" variable.

=head1 AUTHOR

James Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.


