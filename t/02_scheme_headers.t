use Mojo::Base -strict;
use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

our $TEST = __FILE__;
$TEST =~ s/(?>t\/)?(.+)\.t/$1/;

plugin 'RealIP';

# Returns current connection scheme as 'http' or 'https'
get '/scheme' => sub {
  my $c = shift;
  $c->render(text => $c->req->is_secure ? 'https' : 'http');
};

# Test suite variables
my $t   = Test::Mojo->new;
my $tid = 0;
my $tc  = 0;

# Baseline
$tid++;
$tc += 3;
$t->get_ok('/scheme')
  ->status_is(200)->content_is('http', sprintf(
    '[%s.%d] Assert baseline that req->is_secure == false',
    $TEST, $tid)
  );

# Header: [default] X-SSL: 0
$tid++;
$tc += 3;
$t->get_ok('/scheme' => {'X-SSL' => 0})
  ->status_is(200)->content_is('http', sprintf(
    '[%s.%d] Assert from header X-SSL => 0 that req->is_secure == false',
    $TEST, $tid)
  );

# Header: [default] X-SSL: 1
$tid++;
$tc += 3;
$t->get_ok('/scheme' => {'X-SSL' => 1})
  ->status_is(200)->content_is('https', sprintf(
    '[%s.%d] Assert from header X-SSL => 1 that req->is_secure == true',
    $TEST, $tid)
  );

# Header: [default] X-Forwarded-Protocol: http
$tid++;
$tc += 3;
$t->get_ok('/scheme' => {'X-Forwarded-Protocol' => 'http'})
  ->status_is(200)->content_is('http', sprintf(
    '[%s.%d] Assert from header X-Forwarded-Protocol => http that req->is_secure == false',
    $TEST, $tid)
  );

# Header: [default] X-Forwarded-Protocol: https
$tid++;
$tc += 3;
$t->get_ok('/scheme' => {'X-Forwarded-Protocol' => 'https'})
  ->status_is(200)->content_is('https', sprintf(
    '[%s.%d] Assert from header X-Forwarded-Protocol => https that req->is_secure == true',
    $TEST, $tid)
  );

done_testing($tc);
