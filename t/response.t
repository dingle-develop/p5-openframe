use strict;
use Test::Simple tests => 6;
use OpenFrame;
use OpenFrame::Constants;

ok(1, "Should load ok");

my $r = OpenFrame::Response->new(
  message  => "<html><body>Hello world!</body></html>",
  mimetype => 'text/html',
  code     => ofOK(),
  cookies  => OpenFrame::Cookietin->new()
  );
ok($r, "Should get back blessed object");
ok($r->message() eq "<html><body>Hello world!</body></html>", "message() ok");
ok($r->mimetype() eq 'text/html', "mimetype() ok");
ok($r->code() == ofOK(), "code() ok");
ok(ref($r->cookies()) eq 'OpenFrame::Cookietin', "cookies() ok");
