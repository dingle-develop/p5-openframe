package OpenFrame::Slot::ErrorText;

use OpenFrame::Slot;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;
use OpenFrame::Constants;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $class  = shift;
  my $config = shift;
  my $response = OpenFrame::AbstractResponse->new();
  $response->message(
			q{
			  <html>
			  <head>
			    <title>Error</title>
			  </head>
			  <body>
			    <h1>Error</h1>
                            <p>There was an error processing your request</p>
			  </body>
			  </html>
			 }
		       );

  $response->code(ofOK);
  return $response;
}

1;
