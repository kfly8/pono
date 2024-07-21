use v5.40;
use experimental qw(class);

use Stump::JSON;
use Stump::Util;

class Stump::Context {
    field $request :param; # Stump::Request
    field $response :param; # Stump::Response
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

    method html($code, $text) {
        $response->code($code);
        $response->header('Content-Type', 'text/html');
        $response->body($text);
        $response;
    }

    method text($code, $text) {
        $response->code($code);
        $response->header('Content-Type', 'text/plain');
        $response->body($text);
        $response;
    }

    method json($code, $data, $spec = undef) {
        my $json = Stump::JSON::encode_json($data, $spec);

        $response->code($code);
        $response->header('Content-Type', 'application/json');
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
                Carp::croak "Value for '$key' must be $type, got ", Stump::Util::ddf($value) unless $type->check($value);
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
