package Hangman::Generator;

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

#  print "* processing $filename\n";

  return unless -e $templatedir . $filename && -r _;

  $tt->process($filename, $session, \$output) || ($output = $tt->error);

  my $response = OpenFrame::AbstractResponse->new();
  $response->message($output);
  $response->code(ofOK);
  $response->mimetype('text/html');
  $response->cookies($cookie);

  return $response;
}

1;



