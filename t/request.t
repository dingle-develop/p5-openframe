use strict;
use Test::Simple tests => 9;
use lib qw( ../lib );
use OpenFrame;
use URI;

ok(1, "Should load ok");
my $host = 'localhost';
my $path = '/foo/bar';
my $uri  = URI->new("http://$host$path");
my $r    = OpenFrame::Request->new( uri => $uri,
				    originator => 'testing',
				    descriptive => 'test',
				    arguments => { colour => 'red' },
				    cookies => OpenFrame::Cookietin->new() );

ok($r, "Should get back blessed object");
ok($r->uri() eq $uri, "uri() should return URI");

my $uri2 = URI->new("http://$host$path/new");
$r->uri($uri2);
ok($r->uri eq $uri2, "uri() should return changed URI");

ok($r->originator eq 'testing', "originator() should return originator");
ok($r->descriptive eq 'test', "descriptive() should return originator");
ok($r->arguments, "arguments() should return arguments");
ok($r->arguments->{colour} eq 'red', "arguments() should return correct argument");
ok(ref($r->cookies) eq 'OpenFrame::Cookietin', "cookies() should return cookies");


