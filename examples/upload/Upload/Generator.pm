package Upload::Generator;

use strict;
use warnings::register;

use Template;
use OpenFrame::Config;
use OpenFrame::AbstractResponse;
use OpenFrame::Constants;

sub what {
  return ['OpenFrame::Session', 'OpenFrame::AbstractRequest', 'OpenFrame::AbstractCookie'];
}

sub action {
  my $class   = shift;
  my $config  = shift;
  my $session = shift;
  my $request = shift;
  my $cookie  = shift;

  my $templatedir = $config->{presentation};

  my $name = $session->{application}->{current}->{name};

  my $tt = Template->new({
                          INCLUDE_PATH => $templatedir,
                          POST_CHOMP   => 1,
#                          RELATIVE     => 1,
			  LOAD_PERL    => 1,
                         });
  my $output;


  if (substr($request->uri()->path, -1) eq '/') {
    warnings::warn("[slot::generator] no file, using index.html") if (warnings::enabled || $OpenFrame::DEBUG);
    $request->uri( URI->new( $request->uri()->canonical() . 'index.html' ) );
  }

  my $filename = substr($request->uri()->path(), 1);

  return unless -e $templatedir . $filename && -r _;

  $tt->process($filename, $session, \$output) || ($output = $tt->error);
  delete $session->{template}; # delete spurious entry by TT

  my $response = OpenFrame::AbstractResponse->new();
  $response->message($output);
  $response->code(ofOK);
  $response->mimetype('text/html');
  $response->cookies($cookie);

  return $response;
}

1;

__END__

=head1 NAME

Upload::Generator - A templated output generator for Upload

=head1 DESCRIPTION

C<Upload::Generator> is a templated output generator for Upload. The
session is passed to a Template Toolkit template, which generates
output, and the code then generates a response.

Note that it explicity checks if the request is meant for the
application, rather than an image, by checking for "index.html" and
seeing if it can read the template file.

The template used is "templates/index.html" so investigate that to
understand the clear seperation between logic and presentation present
in this example Upload application.

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.



