use Test::Simple tests => 7;

sub BEGIN {
  {
    no warnings qw ( uninitialized );
    eval { 
      use OpenFrame::AbstractCookie;
    };
    ok( !$@, "loaded" );
  }
}

my $n = OpenFrame::AbstractCookie->new();
ok( $n, "instantiation" );
my $c = OpenFrame::AbstractCookie::CookieElement->new(
						      Name  => 'test',
						      Value => 'test',
						     );

ok( $c, "element instantiation" );
ok( $n->addCookie( Cookie => $c ), "cookie insertion" );
ok( $n->getCookie( 'test' ) eq $c, "get cookie" );
ok( $n->delCookie( 'test' ), "delete cookie" );
ok( !($n->getCookie( 'test' ) eq $c), "fetch after deletion" );

