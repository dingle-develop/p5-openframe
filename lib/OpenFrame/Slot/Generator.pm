package OpenFrame::Slot::Generator;

use strict;
use warnings::register;

use Template;
use OpenFrame::Config;
use OpenFrame::Constants;
use OpenFrame::AbstractResponse;

our $VERSION = (split(/ /, q{$Id: Generator.pm,v 1.7 2001/11/12 12:16:16 james Exp $ }))[2];

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
  my $locale      = $session->{country} . $session->{language};

  warnings::warn("[slot::generator] template dir is $templatedir/$locale") if (warnings::enabled || $OpenFrame::DEBUG);

  my $tt = Template->new(
			 {
			  INCLUDE_PATH => $templatedir . '/' . $locale,
			  POST_CHOMP   => 1,
			  RELATIVE     => 1,
			  COMPILE_EXT  => "tt2",
			  COMPILE_DIR  => $config->{presentation} . "/compcache/",
			 }
			);

  my $output;

  if (substr($request->uri()->path, -1) eq '/') {
    warnings::warn("[slot::generator] no file, using index.html") if (warnings::enabled || $OpenFrame::DEBUG);
    $request->uri( URI->new( $request->uri()->canonical() . 'index.html' ) );
  }

  unless ($tt->process(substr($request->uri()->path(), 1), $session, \$output)) {
    warnings::warn("[slot::generator] could not process template (" . $tt->error . ")") if (warnings::enabled || $OpenFrame::DEBUG);
  }

  my $response = OpenFrame::AbstractResponse->new();
  $response->message( $output );
  $response->code( ofOK );
  $response->cookies( $cookie );

  return $response;
}

1;



