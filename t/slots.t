use Test::Simple tests => 4;

use URI;
use strict;

use OpenFrame::Slot;
use OpenFrame::Config;
use OpenFrame::Constants;
use OpenFrame::AbstractRequest;

use lib './t/lib';

my $config   = OpenFrame::Config->new();
ok($config, "should have a configuration");

my $response = OpenFrame::Slot->action(
				       OpenFrame::AbstractRequest->new(
								       uri => URI->new( "http://localhost:8000/" )
								      ),
				       [
					{
					 name     => 'OpenFrame::Slot::TestSlot',
					 dispatch => 'Local',
					 config   => {
						      This => 'Is',
						      My   => 'Config',
						     },
					}
				       ]
				      );
ok($response->code() eq ofOK, "should not receive an error code - OpenFrame::Slot::TestSlot2 setting ofOK");

$response = OpenFrame::Slot->action();
ok($response->code() eq ofERROR, "should receive an error code - not doing anything to set an ofOK");

$response = OpenFrame::Slot->action(OpenFrame::AbstractResponse->new( code => ofOK ), []);
ok($response->code() eq ofOK, "should not receive an error code - putting an ofOK response into the whole thing");







1;
