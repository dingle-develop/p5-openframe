package OpenFrame::Slot::SimpleGenerator;

use strict;
use warnings::register;

use Template;
use OpenFrame::Config;
use OpenFrame::AbstractResponse;

sub what {
  return ['OpenFrame::Session', 'OpenFrame::AbstractRequest', 'OpenFrame::AbstractCookie'];
}

sub action {
  my $class   = shift;
  my $session = shift;
  my $request = shift;
  my $cookie  = shift;

  my $output;

  $output .= "Here is the output of SimpleGenerator for ";
  $output .= $request->getURI()->path();
  $output .= "\n";
  $output .= $session->{application}->{myapp}->{message};

  my $response = OpenFrame::AbstractResponse->new();
  $response->setMessage($output);
  $response->setMessageCode(ofOK);

  return $response;
}

1;



