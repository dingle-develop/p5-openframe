package OpenFrame::Slot::ErrorText;

use OpenFrame::Slot;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractResponse;

use base qw ( OpenFrame::Slot );

sub what {
  return ['OpenFrame::AbstractRequest'];
}

sub action {
  my $response = OpenFrame::AbstractResponse->new();
  $response->setMessage(
			q{
			  <html>
			  <head>
			    <title>Error</title>
			  </head>
			  <body>
			    Hooray!
			  </body>
			  </html>
			 }
		       );

  $response->setMessageCode( ofOK );
  return $response;
}

1;
