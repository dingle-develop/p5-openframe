
##
## -*- Mode: CPerl -*-
##

use strict;
use warnings;

use Test::Simple tests => 7;
use OpenFrame::Response;
use Pipeline::Segment::Tester;

use OpenFrame::Cookies;
use OpenFrame::Segment::HTTP::Request;

use HTTP::Request;

$OpenFrame::DEBUG{ ALL } = 1;

## generic
ok(1, "all modules loaded okay");

## create various bits we'll need
my $hr = HTTP::Request->new(GET => "http://opensource.fotango.com");

my $pt = Pipeline::Segment::Tester->new();
my $sr = OpenFrame::Segment::HTTP::Request->new();

## test the results of the request segment
ok($sr && $pt && $hr, "we have our utility objects");
my $results = [$pt->test($sr, $hr)];
my $thing   = ref($results->[0]); ## this should be an openframe request
my $alsorun = ref($results->[2]); ## this should be the response segment
ok($thing eq 'OpenFrame::Request', "segment produced correct output: $thing");
ok($alsorun =~ /HTTP::Response$/,"also produced an an http response ($alsorun)");
my $http_response = $results->[2];
my $cookies       = $results->[1];

## okay, if we generate an OpenFrame::Response, then we can see what the
## OpenFrame::Segment::HTTP:Response does with it.
my $response = OpenFrame::Response->new()
		 		  ->code(ofOK)
				  ->message("Hello!");

$cookies = OpenFrame::Cookies->new();
my $cookie = OpenFrame::Cookie->new();
$cookie->name( "test" );
$cookie->value( "value" );
$cookies->set( $cookie );

$results = [$pt->test($http_response, $response, $cookies)];
my $okay = ref($results->[0]);

ok($okay eq 'HTTP::Response', "we have an http response object");
ok($results->[0]->content() eq 'Hello!', "message is still fine");
ok($results->[0]->is_success, "looks like the code is fine too!");
