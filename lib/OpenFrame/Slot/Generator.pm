package OpenFrame::Slot::Generator;

use strict;

use Template;
use OpenFrame::Config;
use OpenFrame::Constants;
use OpenFrame::AbstractResponse;

our $VERSION = (split(/ /, q{$Id: Generator.pm,v 1.11 2001/11/21 14:16:36 leon Exp $ }))[2];

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
  my $cachedir    = $config->{presentationcache} || $config->{presentation} . "/compcache/";
  my $locale      = $session->{country} . $session->{language};

  warn("[slot::generator] template dir is $templatedir/$locale") if $OpenFrame::DEBUG;

  my $tt = Template->new(
			 {
			  INCLUDE_PATH => $templatedir . '/' . $locale,
			  POST_CHOMP   => 1,
			  RELATIVE     => 1,
			  COMPILE_EXT  => "tt2",
			  COMPILE_DIR  => $cachedir,
			 }
			);

  my $output;

  if (substr($request->uri()->path, -1) eq '/') {
    warn("[slot::generator] no file, using index.html") if $OpenFrame::DEBUG;
    $request->uri( URI->new( $request->uri()->canonical() . 'index.html' ) );
  }

  if ($request->uri->path() =~ /\.html$/) {
    unless ($tt->process(substr($request->uri()->path(), 1), $session, \$output)) {
      warn("[slot::generator] could not process template (" . $tt->error . ")") if $OpenFrame::DEBUG;
    }
    delete $session->{template}; # delete spurious entry by TT

    my $response = OpenFrame::AbstractResponse->new();
    $response->message( $output );
    $response->code( ofOK );
    $response->cookies( $cookie );

    return $response;
  }
  warn("[slot:generator] file was not handled as template") if $OpenFrame::DEBUG;

}

1;



