package OpenFrame::Slot::Generator;

use strict;
use warnings::register;

use Template;
use OpenFrame::Config;
use OpenFrame::AbstractResponse;

our $VERSION = (split(/ /, q{$Id: Generator.pm,v 1.5 2001/11/02 14:17:13 james Exp $ }))[2];

sub what {
  return ['OpenFrame::Session', 'OpenFrame::AbstractRequest', 'OpenFrame::AbstractCookie'];
}

sub action {
  my $class   = shift;
  my $session = shift;
  my $request = shift;
  my $cookie  = shift;

  my $config      = OpenFrame::Config->new();
  my $templatedir = $config->getKey( 'presentation' );
  my $locale      = $session->{country} . $session->{language};

  warnings::warn("[slot::generator] template dir is $templatedir/$locale") if (warnings::enabled || $OpenFrame::DEBUG);

  my $tt = Template->new(
			 {
			  INCLUDE_PATH => $templatedir . '/' . $locale,
			  POST_CHOMP   => 1,
			  RELATIVE     => 1,
			  COMPILE_EXT  => "tt2",
			  COMPILE_DIR  => $config->getKey( "presentation" ) . "/compcache/",
			 }
			);

  my $output;

  if (substr($request->getURI()->path, -1) eq '/') {
    warnings::warn("[slot::generator] no file, using index.html") if (warnings::enabled || $OpenFrame::DEBUG);
    $request->setURI( URI->new( $request->getURI()->canonical() . 'index.html' ) );
  }

  unless ($tt->process(substr($request->getURI()->path(), 1), $session, \$output)) {
    warnings::warn("[slot::generator] could not process template (" . $tt->error . ")") if (warnings::enabled || $OpenFrame::DEBUG);
  }

  my $response = OpenFrame::AbstractResponse->new();
  $response->setMessage( $output );
  $response->setMessageCode( ofOK );
  $response->setCookie( $cookie );

  return $response;
}

1;



