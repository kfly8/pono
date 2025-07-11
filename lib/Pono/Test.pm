use v5.42;
use utf8;
use experimental qw(class);

use Carp ();
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

use Encode ();
use Pono::JSON;

class Pono::Test {
    field $app :param; # Pono

    method request($http_request) {
        unless ($http_request isa HTTP::Request) {
            Carp::croak 'request() requires an HTTP::Request object';
        }

        $http_request->uri->scheme('http')    unless defined $http_request->uri->scheme;
        $http_request->uri->host('localhost') unless defined $http_request->uri->host;

        my $env = $http_request->to_psgi;

        my $res;
        try {
            $res = HTTP::Response->from_psgi($app->psgi->($env));
        } catch($err) {
            $res = HTTP::Response->from_psgi([ 500, [ 'Content-Type' => 'text/plain' ], [ $err ] ]);
        };

        $res->request($http_request);
        return $res;
    }
}

sub HTTP::Response::json($self) {
    Pono::JSON::decode_json(Encode::decode_utf8($self->content));
}
