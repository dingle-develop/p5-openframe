use strict;
use Test::Simple tests => 9;
use OpenFrame::AbstractRequest;
use OpenFrame::AbstractCookie;
use URI;

ok(1, "Should load ok");
my $uri = URI->new("http://localhost/");
my $r = OpenFrame::AbstractRequest->new(uri => $uri,
	originator => 'testing',
	descriptive => 'test',
	arguments => { colour => 'red' },
	cookies => OpenFrame::AbstractCookie->new());
ok($r, "Should get back blessed object");
ok($r->uri() eq $uri, "uri() should return URI");
my $uri2 = URI->new("http://localhost/foo/");
$r->uri($uri2);
ok($r->uri eq $uri2, "uri() should return changed URI");
ok($r->originator eq 'testing', "originator() should return originator");
ok($r->descriptive eq 'test', "descriptive() should return originator");
ok($r->arguments, "arguments() should return arguments");
ok($r->arguments->{colour} eq 'red', "arguments() should return correct argument");
ok(ref($r->cookies) eq 'OpenFrame::AbstractCookie', "cookies() should return cookies");


