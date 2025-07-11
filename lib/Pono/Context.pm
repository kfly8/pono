use v5.42;
use experimental qw(class);

use Pono::JSON;
use Pono::Util;

class Pono::Context {
    field $request :param; # Pono::Request
    field $response :param; # Pono::Response
    field $match_result :param :reader;
    field $not_found_handler :param; # CodeRef: (Context: $c) -> Response
    field $var = {};
    field $Variables :param = undef;

    method res() { $response }
    method req() { $request }

    method header($name, $value=undef) {
        if (defined $value) {
            $response->header($name, $value);
        }
        $response->header($name);
    }

    method body($text=undef) {
        if (defined $text) {
            $response->body($text);
        }
        $response->body;
    }

    method html($text, $code) {
        $response->code($code) if defined $code;
        $response->header('Content-Type', 'text/html; charset=UTF-8');
        $response->body($text);
        $response;
    }

    method text($text, $code = undef) {
        $response->code($code) if defined $code;
        $response->header('Content-Type', 'text/plain; charset=UTF-8');
        $response->body($text);
        $response;
    }

    method json($data, @rest) {
        my ($spec, $code) = @rest == 0 ? (undef, undef)
                          : @rest == 1 ? (undef, $rest[0])
                          : @rest == 2 ? @rest
                          : Carp::croak "json() takes 0, 1 or 2 arguments, got ", scalar @rest;

        my $json = Pono::JSON::encode_json($data, $spec);

        $response->code($code) if defined $code;
        $response->header('Content-Type', 'application/json; charset=UTF-8');
        $response->body($json);
        $response;
    }

    method not_found() {
        $not_found_handler->($self);
    }

    method redirect($url, $code=302) {
        $response->code($code);
        $response->header('Location' => $url);
        $response;
    }

    method set($key, $value) {
        if ($Variables) {
            if (my $type = $Variables->{$key}) {
                Carp::croak "Value for '$key' must be $type, got ", Pono::Util::ddf($value) unless $type->check($value);
            }
            else {
                Carp::croak "Variables $key is not exists";
            }
        }

        $var->{$key} = $value;
    }

    method get($key) {
        if ($Variables) {
            Carp::croak "Variables $key is not exists" unless exists $Variables->{$key};
        }

        $var->{$key}
    }
}
