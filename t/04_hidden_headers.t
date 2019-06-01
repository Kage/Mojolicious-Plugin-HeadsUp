use Mojo::Base -strict;
use Test::More;
use Mojolicious::Lite;
use Test::Mojo;

our $TEST = __FILE__;
$TEST =~ s/(?>t\/)?(.+)\.t/$1/;

plugin 'RealIP' => {
  hide_headers => 1,
};

# Returns all header names
get '/headers' => sub {
  my $c = shift;
  $c->render(json => $c->req->headers->names);
};

# Test suite variables
my $t   = Test::Mojo->new;
my $tid = 0;
my $tc  = 0;

# Iterate through headers and ensure they're not present
my $headers = {
  'X-Real-IP'       => '1.1.1.1',
  'X-Forwarded-For' => '1.1.1.1',
  'X-SSL'           => 1,
};
$tc += 2;
my $test = $t->get_ok('/headers' => $headers)->status_is(200);
foreach my $header (keys %$headers) {
  $tid++;
  $tc++;
  $test->json_hasnt('/'.lc $header, sprintf(
    '[%s.%d] Assert header "%s" not present',
    $TEST, $tid, lc $header)
  );
}

done_testing($tc);
