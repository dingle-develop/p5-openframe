use Test::Simple tests => 4;

use lib qw( lib ../lib );
use strict;
use OpenFrame;
use OpenFrame::Constants;
use URI;

use lib './t/lib';

my $config   = OpenFrame::Config->new();
ok($config, "should have a configuration");

my $response = OpenFrame::Slot->action(
				       OpenFrame::Request->new(
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
print "response: ", $response->code, "\n";
print "message: ", $response->message, "\n";

$response = OpenFrame::Slot->action(OpenFrame::Response->new( code => ofOK ), []);
ok($response->code() eq ofOK, "should not receive an error code - putting an ofOK response into the whole thing");







1;
