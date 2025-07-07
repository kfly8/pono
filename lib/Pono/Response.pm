use v5.42;
use utf8;
use experimental qw(class);

use HTTP::Headers::Fast;
use Encode ();

class Pono::Response {
    field $code :param = 200;
    field $headers :reader :param = HTTP::Headers::Fast->new;
    field $body;

    method header($name, $value=undef) {
        if (defined $value) {
            $headers->header($name, $value);
        }
        $headers->header($name);
    }

    method code($c = undef) {
        if (defined $c) {
            $code = $c;
        }
        $code;
    }

    # alias for code
    method status($s = undef) {
        if (defined $s) {
            $code = $s;
        }
        $code;
    }

    method body($b = undef) {
        if (defined $b) {
            $body = $b;
        }
        $body;
    }

    method finalize {
        return [
            $code,
            $headers->psgi_flatten,
            [Encode::encode_utf8($body)],
        ]
    }
}
