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

__END__

=head1 NAME

OpenFrame::Slot::ErrorText - Slot that returns an error

=head1 SYNOPSIS

  # as part of the SLOTS entry in OpenFrame::Config:
  {
  dispatch => 'Local',
  name     => 'OpenFrame::Slot::ErrorText',
  },

=head1 DESCRIPTION

C<OpenFrame::Slot::ErrorText> is an OpenFrame slot that simply returns
a response containing an HTML page indicating an error.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
