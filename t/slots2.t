use Test::More tests => 8;

use strict;

use lib qw( ./lib ../lib ./t/lib ../t/lib );

use OpenFrame;
use OpenFrame::Config;
use OpenFrame::Server;
use OpenFrame::Request;
use OpenFrame::Slot;
use OpenFrame::Constants;
use URI;

#------------------------------------------------------------------------
my @data;
$SIG{__WARN__} = sub { push(@data, @_) };
#------------------------------------------------------------------------

my $config = OpenFrame::Config->new();

$config->setKey(
    SLOTS => [ 
	{
	    dispatch => 'Local',
	    name     => 'OpenFrame::Slot::Misc',
	    config   => { msg => "I'm just a teenage dirtbag" },
	},
	{
	    dispatch => 'Local',
	    name     => 'OpenFrame::Slot::Cleanup',
	    config   => { msg => 'clean your room' },
	},
	{
	    dispatch => 'Local',
	    name     => 'OpenFrame::Slot::Short',
	    config   => { msg => 'I am a short-circuiting slot' },
	},
	{
	    dispatch => 'Local',
	    name     => 'OpenFrame::Slot::Misc',
	    config   => { msg => "THIS SHOULDN'T HAPPEN" },
	},
    ]
);

ok( $config, 'config is defined' );

my $request  = OpenFrame::Request->new(uri => URI->new('choose life'));
my $response = OpenFrame::Server->action($request, $config);

ok( $response, 'response is defined' );
die "failed to generate response" unless $response;

is( $data[0], "misc message: I'm just a teenage dirtbag\n", 'message 0' );
is( $data[1], "cleanup message: clean your room\n", 'message 1' );
is( $data[2], "short message: I am a short-circuiting slot\n", 'message 2' );
is( $data[3], "cleaner message: clean your room (modified by cleanup initiator)\n", 'message 2' );

is( $response->code, ofOK, 'response is OK' );
is( $response->message, 'a response in response to the message: I am a short-circuiting slot', 'response message correct' );

